import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/time/clock_provider.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../domain/activity_log.dart';
import '../domain/field_value.dart';
import '../../plans/domain/plan.dart';
import '../../focus/domain/focus_session.dart';
import '../../focus/domain/focus_use_cases.dart';
import '../../focus/presentation/focus_providers.dart';
import '../../plans/presentation/plan_providers.dart';
import 'activity_log_providers.dart';

/// Which log to edit: a new log for [typeId] (optionally fulfilling
/// [planId], F5), the existing [logId], or the record that finishes focus
/// session [focusId] (F7, ADR-031).
class LogEditorArgs {
  const LogEditorArgs.create(ActivityTypeId this.typeId, {this.planId})
    : logId = null,
      focusId = null;

  const LogEditorArgs.edit(ActivityLogId this.logId)
    : typeId = null,
      planId = null,
      focusId = null;

  const LogEditorArgs.finishFocus(FocusSessionId this.focusId)
    : typeId = null,
      logId = null,
      planId = null;

  final ActivityTypeId? typeId;
  final ActivityLogId? logId;
  final PlanId? planId;
  final FocusSessionId? focusId;

  @override
  bool operator ==(Object other) =>
      other is LogEditorArgs &&
      other.typeId == typeId &&
      other.logId == logId &&
      other.planId == planId &&
      other.focusId == focusId;

  @override
  int get hashCode => Object.hash(typeId, logId, planId, focusId);
}

/// Draft state of the log form (state_management.md §4).
class LogEditorState {
  const LogEditorState({
    required this.type,
    required this.startedAt,
    required this.values,
    required this.originalValues,
    this.logId,
    this.plan,
    this.durationMs,
    this.notes = '',
    this.issues = const [],
    this.isSaving = false,
    this.isDirty = false,
  });

  final ActivityType type;
  final ActivityLogId? logId;

  /// The plan this record fulfils (ADR-030), shown as context in the form.
  final Plan? plan;

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
    ActivityType? type,
    DateTime? startedAt,
    int? Function()? durationMs,
    String? notes,
    Map<ActivityFieldId, FieldValue>? values,
    List<ValidationIssue>? issues,
    bool? isSaving,
    bool? isDirty,
  }) => LogEditorState(
    type: type ?? this.type,
    logId: logId,
    plan: plan,
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
      final plan = log.planId == null
          ? null
          : await ref.read(planRepositoryProvider).getPlan(log.planId!);
      return LogEditorState(
        type: type,
        logId: logId,
        plan: plan,
        startedAt: log.startedAt.toLocal(),
        durationMs: log.durationMs,
        notes: log.notes ?? '',
        values: log.values,
        originalValues: log.values,
      );
    }
    if (args.focusId case final focusId?) {
      // Finishing a focus session: its start and focused time prefill the
      // record (FR-FO-03); the user adds details and saves.
      final session = await ref
          .read(focusSessionRepositoryProvider)
          .getSession(focusId);
      if (session == null) {
        throw NotFoundException(debugContext: 'finish focus ${focusId.value}');
      }
      final type = await types.getType(session.activityTypeId);
      if (type == null) {
        throw const NotFoundException(debugContext: 'finish focus type');
      }
      final plan = session.planId == null
          ? null
          : await ref.read(planRepositoryProvider).getPlan(session.planId!);
      final (_, elapsed) = FinishFocusSession.endOf(
        session,
        ref.read(clockProvider).nowUtc(),
      );
      return LogEditorState(
        type: type,
        plan: plan,
        startedAt: session.startedAt.toLocal(),
        durationMs: elapsed,
        values: const {},
        originalValues: const {},
      );
    }
    final type = await types.getType(args.typeId!);
    if (type == null) {
      throw const NotFoundException(debugContext: 'log editor new');
    }
    final clock = ref.read(clockProvider);
    final plan = args.planId == null
        ? null
        : await ref.read(planRepositoryProvider).getPlan(args.planId!);
    return LogEditorState(
      type: type,
      plan: plan,
      startedAt: (plan == null ? clock.nowUtc() : recordStartFor(plan, clock))
          .toLocal(),
      // The planned length is a starting point for the actual one (e.g.
      // 21:10–21:55 → 45 min); the user corrects it to what happened.
      durationMs: plan?.plannedLengthMs,
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
        // A group's items carry their own issue targets (`item/field`); edits
        // inside a group clear them along with the group's own.
        issues: _state.issues
            .where(
              (i) =>
                  i.target != fieldId.value &&
                  !(value is RepeatingGroupValue &&
                      (i.target?.contains('/') ?? false)),
            )
            .toList(),
      ),
    );
  }

  /// Reloads the activity's fields after the user changed what it tracks,
  /// keeping everything entered so far.
  Future<void> reloadType() async {
    final type = await ref
        .read(activityTypeRepositoryProvider)
        .getType(_state.type.id);
    if (type != null) state = AsyncData(_state.copyWith(type: type));
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
      planId: args.planId,
    );
    try {
      if (current.logId case final logId?) {
        await ref.read(updateActivityLogProvider)(logId, draft);
      } else if (args.focusId case final focusId?) {
        await ref.read(finishFocusSessionProvider)(focusId, draft);
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
