import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/time/clock_provider.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../domain/activity_log.dart';
import '../domain/field_value.dart';
import 'activity_log_providers.dart';

/// Which log to edit: a new log for [typeId], or the existing [logId].
class LogEditorArgs {
  const LogEditorArgs.create(ActivityTypeId this.typeId) : logId = null;

  const LogEditorArgs.edit(ActivityLogId this.logId) : typeId = null;

  final ActivityTypeId? typeId;
  final ActivityLogId? logId;

  @override
  bool operator ==(Object other) =>
      other is LogEditorArgs && other.typeId == typeId && other.logId == logId;

  @override
  int get hashCode => Object.hash(typeId, logId);
}

/// Draft state of the log form (state_management.md §4).
class LogEditorState {
  const LogEditorState({
    required this.type,
    required this.startedAt,
    required this.values,
    required this.originalValues,
    this.logId,
    this.durationMs,
    this.notes = '',
    this.issues = const [],
    this.isSaving = false,
    this.isDirty = false,
  });

  final ActivityType type;
  final ActivityLogId? logId;

  /// Local wall-clock time shown in the form.
  final DateTime startedAt;
  final int? durationMs;
  final String notes;
  final Map<ActivityFieldId, FieldValue> values;
  final Map<ActivityFieldId, FieldValue> originalValues;
  final List<ValidationIssue> issues;
  final bool isSaving;
  final bool isDirty;

  bool get isNew => logId == null;

  /// Active fields, plus removed fields that still hold a value in this log.
  List<ActivityField> get visibleFields => [
    ...type.activeFields,
    ...type.fields.where((f) => f.isRemoved && values.containsKey(f.id)),
  ];

  LogEditorState copyWith({
    DateTime? startedAt,
    int? Function()? durationMs,
    String? notes,
    Map<ActivityFieldId, FieldValue>? values,
    List<ValidationIssue>? issues,
    bool? isSaving,
    bool? isDirty,
  }) => LogEditorState(
    type: type,
    logId: logId,
    startedAt: startedAt ?? this.startedAt,
    durationMs: durationMs != null ? durationMs() : this.durationMs,
    notes: notes ?? this.notes,
    values: values ?? this.values,
    originalValues: originalValues,
    issues: issues ?? this.issues,
    isSaving: isSaving ?? this.isSaving,
    isDirty: isDirty ?? this.isDirty,
  );
}

final logEditorProvider = AsyncNotifierProvider.autoDispose
    .family<LogEditorNotifier, LogEditorState, LogEditorArgs>(
      LogEditorNotifier.new,
    );

class LogEditorNotifier extends AsyncNotifier<LogEditorState> {
  LogEditorNotifier(this.args);

  final LogEditorArgs args;

  LogEditorState get _state => state.requireValue;

  @override
  Future<LogEditorState> build() async {
    final types = ref.read(activityTypeRepositoryProvider);
    if (args.logId case final logId?) {
      final log = await ref.read(activityLogRepositoryProvider).getLog(logId);
      if (log == null) {
        throw NotFoundException(debugContext: 'log editor ${logId.value}');
      }
      final type = await types.getType(log.activityTypeId);
      if (type == null) {
        throw const NotFoundException(debugContext: 'log editor type');
      }
      return LogEditorState(
        type: type,
        logId: logId,
        startedAt: log.startedAt.toLocal(),
        durationMs: log.durationMs,
        notes: log.notes ?? '',
        values: log.values,
        originalValues: log.values,
      );
    }
    final type = await types.getType(args.typeId!);
    if (type == null) {
      throw const NotFoundException(debugContext: 'log editor new');
    }
    return LogEditorState(
      type: type,
      startedAt: ref.read(clockProvider).nowUtc().toLocal(),
      values: const {},
      originalValues: const {},
    );
  }

  void setValue(ActivityFieldId fieldId, FieldValue? value) {
    final values = Map.of(_state.values);
    if (value == null) {
      values.remove(fieldId);
    } else {
      values[fieldId] = value;
    }
    state = AsyncData(
      _state.copyWith(
        values: values,
        isDirty: true,
        issues: _state.issues.where((i) => i.target != fieldId.value).toList(),
      ),
    );
  }

  void setStartedAt(DateTime startedAt) =>
      state = AsyncData(_state.copyWith(startedAt: startedAt, isDirty: true));

  void setDuration(int? milliseconds) => state = AsyncData(
    _state.copyWith(durationMs: () => milliseconds, isDirty: true),
  );

  void setNotes(String notes) =>
      state = AsyncData(_state.copyWith(notes: notes, isDirty: true));

  /// Saves the draft. Returns false (with inline issues) on validation
  /// failure; other `AppException`s propagate to the screen.
  Future<bool> save() async {
    final current = _state;
    state = AsyncData(current.copyWith(isSaving: true, issues: const []));
    final draft = ActivityLogDraft(
      startedAt: current.startedAt.toUtc(),
      durationMs: current.durationMs,
      notes: current.notes,
      values: current.values,
    );
    try {
      if (current.logId case final logId?) {
        await ref.read(updateActivityLogProvider)(logId, draft);
      } else {
        await ref.read(logActivityProvider)(current.type.id, draft);
      }
      state = AsyncData(current.copyWith(isSaving: false, isDirty: false));
      return true;
    } on ValidationException catch (e) {
      state = AsyncData(current.copyWith(isSaving: false, issues: e.issues));
      return false;
    } catch (_) {
      state = AsyncData(current.copyWith(isSaving: false));
      rethrow;
    }
  }
}
