import '../../../core/async/combine_latest.dart';
import '../../../core/time/local_date.dart';
import '../../activity_logs/domain/activity_log.dart';
import '../../activity_logs/domain/activity_log_repository.dart';
import '../../activity_logs/domain/watch_records_for_day.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../activity_types/domain/activity_type_repository.dart';
import 'plan.dart';
import 'plan_repository.dart';

/// A plan with what actually happened for it (Plan vs Reality, §20).
class PlannedItem {
  const PlannedItem({
    required this.plan,
    required this.type,
    required this.records,
    required this.status,
  });

  final Plan plan;

  /// The plan's activity type (possibly archived); null for a task.
  final ActivityType? type;

  /// Records fulfilling the plan, in time order (any day).
  final List<ActivityLog> records;
  final EffectivePlanStatus status;

  /// Total actual duration of [records], or null when none has one.
  int? get actualDurationMs {
    final durations = [
      for (final r in records)
        if (r.durationMs != null) r.durationMs!,
    ];
    return durations.isEmpty ? null : durations.reduce((a, b) => a + b);
  }

  /// Still open: not done, skipped or cancelled (in progress counts as
  /// open).
  bool get isOpen =>
      status == EffectivePlanStatus.planned ||
      status == EffectivePlanStatus.inProgress;
}

/// One date's plans paired with reality (Today, Plan tab; F3a, F11).
class DayOverview {
  const DayOverview({
    required this.date,
    required this.planned,
    required this.records,
    required this.unplanned,
  });

  final LocalDate date;

  /// The date's plans in display order ([orderPlans]).
  final List<PlannedItem> planned;

  /// Everything recorded on the date, in time order.
  final List<DayRecord> records;

  /// [records] that don't fulfil one of this date's plans.
  final List<DayRecord> unplanned;

  /// Total recorded duration on the date.
  int get recordedMs =>
      records.fold(0, (sum, r) => sum + (r.log.durationMs ?? 0));
}

/// Composite read (ADR-023): a date's plans, its records, the records that
/// fulfil its plans (possibly on another day) and the activity types needed
/// to render them. Updates when any of them changes.
class WatchDayOverview {
  const WatchDayOverview(
    this._plans,
    this._logs,
    this._types, {
    this.planInFocus,
  });

  final PlanRepository _plans;
  final ActivityLogRepository _logs;
  final ActivityTypeRepository _types;

  /// The plan an active focus session is doing, if any (ADR-031).
  final Stream<PlanId?> Function()? planInFocus;

  Stream<DayOverview> call(LocalDate date) => combineLatest2(
    planInFocus?.call() ?? Stream<PlanId?>.value(null),
    _overview(date),
    (inFocus, overview) => inFocus == null
        ? overview
        : DayOverview(
            date: overview.date,
            records: overview.records,
            unplanned: overview.unplanned,
            planned: [
              for (final item in overview.planned)
                PlannedItem(
                  plan: item.plan,
                  type: item.type,
                  records: item.records,
                  status: item.plan.effectiveStatus(
                    hasRecord: item.records.isNotEmpty,
                    inFocus: item.plan.id == inFocus,
                  ),
                ),
            ],
          ),
  );

  Stream<DayOverview> _overview(LocalDate date) => combineLatest2(
    combineLatest2(
      _plans.watchPlansForDay(date),
      _logs.watchLogsForDay(date),
      (plans, dayLogs) => (plans, dayLogs),
    ),
    combineLatest2(
      _logs.watchLogsForPlanDate(date),
      _types.watchAllTypes(),
      (linked, types) => (linked, types),
    ),
    (a, b) {
      final (plans, dayLogs) = a;
      final (linked, types) = b;
      final typesById = {for (final t in types) t.id: t};
      final recordsByPlan = <PlanId, List<ActivityLog>>{};
      for (final log in linked) {
        recordsByPlan.putIfAbsent(log.planId!, () => []).add(log);
      }
      final planIds = {for (final p in plans) p.id};
      final records = [
        for (final log in dayLogs)
          if (typesById[log.activityTypeId] case final type?)
            DayRecord(log, type),
      ];
      return DayOverview(
        date: date,
        planned: [
          for (final plan in orderPlans(plans))
            PlannedItem(
              plan: plan,
              type: plan.activityTypeId == null
                  ? null
                  : typesById[plan.activityTypeId],
              records: recordsByPlan[plan.id] ?? const [],
              status: plan.effectiveStatus(
                hasRecord: recordsByPlan.containsKey(plan.id),
              ),
            ),
        ],
        records: records,
        unplanned: [
          for (final record in records)
            if (!planIds.contains(record.log.planId)) record,
        ],
      );
    },
  );
}
