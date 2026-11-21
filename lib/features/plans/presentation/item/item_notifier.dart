import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/time/clock.dart';
import '../../../../core/time/clock_provider.dart';
import '../../../../core/time/local_date.dart';
import '../../../activity_logs/domain/activity_log.dart';
import '../../../activity_logs/domain/activity_log_use_cases.dart';
import '../../../activity_logs/domain/checklist.dart';
import '../../../activity_logs/domain/log_memory.dart';
import '../../../../core/ids/id_generator_provider.dart';
import '../../../../core/database/json_preferences.dart';
import '../../../activity_logs/domain/field_value.dart';
import '../../../activity_logs/presentation/activity_log_providers.dart';
import '../../../activity_types/domain/activity_ids.dart';
import '../../../activity_types/domain/activity_type.dart';
import '../../../activity_types/presentation/activity_type_providers.dart';
import '../../domain/item_use_cases.dart';
import '../../domain/plan_use_cases.dart';
import '../../domain/plan.dart';
import '../plan_providers.dart';

/// Which item to open (ADR-035): a plan on a day, or a record made without
/// a plan (older data, or one created outside the planner).
class ItemArgs {
  const ItemArgs.plan(PlanId this.planId) : logId = null;

  const ItemArgs.log(ActivityLogId this.logId) : planId = null;

  final PlanId? planId;
  final ActivityLogId? logId;

  @override
  bool operator ==(Object other) =>
      other is ItemArgs && other.planId == planId && other.logId == logId;

  @override
  int get hashCode => Object.hash(planId, logId);
}

enum SaveStatus { idle, saving, saved, failed }

/// An item and what's been logged into it so far.
class ItemState {
  const ItemState({
    required this.startedAt,
    required this.values,
    this.plan,
    this.type,
    this.logId,
    this.durationMs,
    this.notes = '',
    this.issues = const [],
    this.saveStatus = SaveStatus.idle,
  });

  /// Null for a record without a plan.
  final Plan? plan;

  /// Null for a task nothing has been logged into yet.
  final ActivityType? type;

  /// Null until the first thing is logged.
  final ActivityLogId? logId;

  /// Local wall-clock start shown in the item.
  final DateTime startedAt;
  final int? durationMs;
  final String notes;
  final Map<ActivityFieldId, FieldValue> values;
  final List<ValidationIssue> issues;
  final SaveStatus saveStatus;

  String get title => plan?.title ?? type?.name ?? '';

  bool get hasLog => logId != null;

  /// Done on [today] (ADR-040): a record without a plan always is; an item
  /// follows [Plan.effectiveStatus] (marked done, or logged on a past day).
  bool isDoneOn(LocalDate today) => switch (plan) {
    null => hasLog,
    final plan =>
      plan.effectiveStatus(hasRecord: hasLog, today: today) ==
          EffectivePlanStatus.completed,
  };

  /// Active fields, plus removed fields that still hold a value here.
  List<ActivityField> get visibleFields => [
    ...?type?.activeFields,
    ...?type?.fields.where((f) => f.isRemoved && values.containsKey(f.id)),
  ];

  ItemState copyWith({
    Plan? plan,
    ActivityType? type,
    ActivityLogId? logId,
    DateTime? startedAt,
    int? Function()? durationMs,
    String? notes,
    Map<ActivityFieldId, FieldValue>? values,
    List<ValidationIssue>? issues,
    SaveStatus? saveStatus,
  }) => ItemState(
    plan: plan ?? this.plan,
    type: type ?? this.type,
    logId: logId ?? this.logId,
    startedAt: startedAt ?? this.startedAt,
    durationMs: durationMs != null ? durationMs() : this.durationMs,
    notes: notes ?? this.notes,
    values: values ?? this.values,
    issues: issues ?? this.issues,
    saveStatus: saveStatus ?? this.saveStatus,
  );
}

final itemProvider = AsyncNotifierProvider.autoDispose
    .family<ItemNotifier, ItemState, ItemArgs>(ItemNotifier.new);

/// Loads an item and saves what's logged into it as the user types
/// (ADR-035): no Save button, nothing to discard. The first change creates
/// the item's log (and, for a task, its activity); later changes update it.
class ItemNotifier extends AsyncNotifier<ItemState> {
  ItemNotifier(this.args);

  final ItemArgs args;

  static const saveDelay = Duration(milliseconds: 600);

  Timer? _debounce;
  Future<void> _saving = Future.value();

  /// Bumped on every edit; a save only marks the state clean if nothing
  /// changed while it ran.
  int _version = 0;
  int _savedVersion = 0;
  bool _disposed = false;

  // Use cases are captured at build, so a save still runs after the screen
  // closes (the provider is disposed then).
  late LogActivity _logActivity;
  late UpdateActivityLog _updateLog;
  late EnsureItemActivity _ensureActivity;
  late SetPlanStatus _setPlanStatus;
  late JsonPreferences _prefs;

  /// Every step just got ticked: the item is done once it's saved.
  bool _completeAfterSave = false;

  ItemState get _state => state.requireValue;

  @override
  Future<ItemState> build() async {
    _logActivity = ref.read(logActivityProvider);
    _updateLog = ref.read(updateActivityLogProvider);
    _ensureActivity = ref.read(ensureItemActivityProvider);
    _setPlanStatus = ref.read(setPlanStatusProvider);
    _prefs = ref.read(jsonPreferencesProvider);
    ref.onDispose(() {
      _disposed = true;
      if (_version != _savedVersion) {
        _debounce?.cancel();
        unawaited(_enqueueSave());
      }
    });
    return _load();
  }

  Future<ItemState> _load() async {
    final logs = ref.read(activityLogRepositoryProvider);
    final types = ref.read(activityTypeRepositoryProvider);
    final plans = ref.read(planRepositoryProvider);
    final clock = ref.read(clockProvider);

    final ActivityLog? log;
    final Plan? plan;
    if (args.logId case final logId?) {
      log = await logs.getLog(logId);
      if (log == null) {
        throw NotFoundException(debugContext: 'item log ${logId.value}');
      }
      plan = log.planId == null ? null : await plans.getPlan(log.planId!);
    } else {
      plan = await plans.getPlan(args.planId!);
      if (plan == null) {
        throw NotFoundException(debugContext: 'item ${args.planId!.value}');
      }
      log = await logs.getLogForPlan(plan.id);
    }
    final typeId = log?.activityTypeId ?? plan?.activityTypeId;
    final type = typeId == null ? null : await types.getType(typeId);
    final values = await _withLastSteps(type, log);
    if (log != null) {
      return ItemState(
        plan: plan,
        type: type,
        logId: log.id,
        startedAt: log.startedAt.toLocal(),
        durationMs: log.durationMs,
        notes: log.notes ?? '',
        values: values,
      );
    }
    return ItemState(
      plan: plan,
      type: type,
      startedAt: _defaultStart(plan!, clock),
      values: values,
    );
  }

  /// [log]'s values, with each empty checklist (a routine's steps) filled
  /// with last time's steps, unticked: set them up once, tick them daily.
  /// Only shown until something is ticked or typed; nothing is saved here.
  Future<Map<ActivityFieldId, FieldValue>> _withLastSteps(
    ActivityType? type,
    ActivityLog? log,
  ) async {
    final values = log?.values ?? const <ActivityFieldId, FieldValue>{};
    final lists = [
      for (final list in Checklist.of(type))
        if (!values.containsKey(list.group)) list,
    ];
    if (lists.isEmpty) return values;
    final ids = ref.read(idGeneratorProvider);
    final prefs = ref.read(jsonPreferencesProvider);
    final steps = <ActivityFieldId, FieldValue>{};
    ActivityLog? last;
    var lastRead = false;
    for (final list in lists) {
      // The steps as last set up, else last time's.
      final saved = await prefs.read(_stepsKey(type!, list));
      if (saved is List && saved.isNotEmpty) {
        steps[list.group] = RepeatingGroupValue([
          for (final name in saved.whereType<String>())
            GroupItem(
              id: GroupItemId(ids.newId()),
              values: {list.name: TextValue(name)},
            ),
        ]);
        continue;
      }
      if (!lastRead) {
        lastRead = true;
        last = await LastLogOfType(ref.read(activityLogRepositoryProvider))(
          type.id,
          except: log?.id,
        );
      }
      if (last?.values case final v?) {
        if (list.fresh(v, ids) case final fresh?) steps[list.group] = fresh;
      }
    }
    return {...values, ...steps};
  }

  static String _stepsKey(ActivityType type, Checklist list) =>
      'steps:${type.id.value}:${list.group.value}';

  /// Remembers [values]' checklist steps (names only) for next time.
  Future<void> _rememberSteps(
    ActivityType? type,
    Map<ActivityFieldId, FieldValue> values,
    JsonPreferences prefs,
  ) async {
    if (type == null) return;
    for (final list in Checklist.of(type)) {
      final rows = switch (values[list.group]) {
        RepeatingGroupValue(:final items) => items,
        _ => const <GroupItem>[],
      };
      await prefs.write(_stepsKey(type, list), [
        for (final row in rows)
          if (list.nameOf(row).isNotEmpty) list.nameOf(row),
      ]);
    }
  }

  /// Steps written but nothing ticked or logged yet: set up, not done, so
  /// no record (and the day doesn't count) until something's ticked.
  static bool _onlySteps(ItemState s) {
    if (s.logId != null || s.notes.trim().isNotEmpty || s.durationMs != null) {
      return false;
    }
    final groups = {for (final l in Checklist.of(s.type)) l.group};
    if (groups.isEmpty || !s.values.keys.every(groups.contains)) return false;
    return (checklistProgress(s.type, s.values)?.done ?? 0) == 0;
  }

  static DateTime _defaultStart(Plan plan, Clock clock) =>
      recordStartFor(plan, clock).toLocal();

  /// Reloads after something outside the form changed the item (the plan
  /// sheet, a finished timer, a changed activity). Unsaved edits are saved
  /// first.
  Future<void> reload() async {
    await flush();
    if (_disposed) return;
    final fresh = await _load();
    if (!_disposed) state = AsyncData(fresh);
  }

  void setValue(ActivityFieldId fieldId, FieldValue? value) {
    final before = checklistProgress(_state.type, _state.values);
    final values = Map.of(_state.values);
    if (value == null) {
      values.remove(fieldId);
    } else {
      values[fieldId] = value;
    }
    _edit(
      _state.copyWith(
        values: values,
        // Edits inside a group clear its items' issues with its own.
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
    final after = checklistProgress(_state.type, values);
    final plan = _state.plan;
    if (plan != null &&
        plan.status == PlanStatus.planned &&
        after != null &&
        after.done == after.total &&
        (before == null || before.done < before.total)) {
      _completeAfterSave = true;
      unawaited(flush());
    }
  }

  void setStartedAt(DateTime startedAt) =>
      _edit(_state.copyWith(startedAt: startedAt));

  void setDuration(int? milliseconds) =>
      _edit(_state.copyWith(durationMs: () => milliseconds));

  void setNotes(String notes) => _edit(_state.copyWith(notes: notes));

  void _edit(ItemState next) {
    _version++;
    state = AsyncData(next);
    _debounce?.cancel();
    _debounce = Timer(saveDelay, () => unawaited(_enqueueSave()));
  }

  /// Saves pending edits now (before leaving, starting a timer, …).
  Future<void> flush() {
    _debounce?.cancel();
    return _enqueueSave();
  }

  /// Saves run one after another, so the first one's new log is known to the
  /// next.
  Future<void> _enqueueSave() =>
      _saving = _saving.then((_) => _save()).catchError((_) {});

  Future<void> _save() async {
    if (_version == _savedVersion || !state.hasValue) return;
    final version = _version;
    final current = _state;
    if (Checklist.of(current.type).isNotEmpty) {
      await _rememberSteps(current.type, current.values, _prefs);
    }
    if (_onlySteps(current)) {
      _savedVersion = version;
      _setStatus(SaveStatus.saved);
      return;
    }
    _setStatus(SaveStatus.saving);
    try {
      var logId = current.logId;
      var type = current.type;
      final draft = ActivityLogDraft(
        startedAt: current.startedAt.toUtc(),
        durationMs: current.durationMs,
        notes: current.notes,
        values: current.values,
        planId: current.plan?.id,
      );
      if (logId != null) {
        await _updateLog(logId, draft, partial: true);
      } else {
        final typeId = type?.id ?? await _ensureActivity(current.plan!.id);
        logId = await _logActivity(typeId, draft, partial: true);
        if (type == null && !_disposed) {
          type = await ref.read(activityTypeRepositoryProvider).getType(typeId);
        }
      }
      _savedVersion = version;
      if (_completeAfterSave && current.plan != null) {
        _completeAfterSave = false;
        await _setPlanStatus(current.plan!.id, PlanStatus.completed);
        if (!_disposed) {
          final plan = await ref
              .read(planRepositoryProvider)
              .getPlan(current.plan!.id);
          if (plan != null && !_disposed) {
            state = AsyncData(_state.copyWith(plan: plan));
          }
        }
      }
      if (_disposed) return;
      state = AsyncData(
        _state.copyWith(
          logId: logId,
          type: type,
          issues: const [],
          saveStatus: version == _version ? SaveStatus.saved : null,
        ),
      );
    } on ValidationException catch (e) {
      if (_disposed) return;
      state = AsyncData(
        _state.copyWith(issues: e.issues, saveStatus: SaveStatus.failed),
      );
    } catch (_) {
      _setStatus(SaveStatus.failed);
      rethrow;
    }
  }

  void _setStatus(SaveStatus status) {
    if (_disposed || !state.hasValue) return;
    state = AsyncData(_state.copyWith(saveStatus: status));
  }
}
