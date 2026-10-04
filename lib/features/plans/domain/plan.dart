import '../../../core/time/clock.dart';
import '../../../core/time/local_date.dart';
import '../../activity_types/domain/activity_ids.dart';

extension type const PlanId(String value) {}

/// What is stored about a plan's progress (ADR-018). Completion of an
/// *activity* plan is never stored: it is derived from linked records (see
/// [EffectivePlanStatus]). `completed` is stored only for tasks.
enum PlanStatus {
  planned('planned'),
  completed('completed'),
  skipped('skipped'),
  cancelled('cancelled');

  const PlanStatus(this.storageKey);

  final String storageKey;

  static PlanStatus fromStorageKey(String key) =>
      values.firstWhere((s) => s.storageKey == key);
}

/// The status the user sees: reality (a linked record) wins over a stored
/// `skipped` or `cancelled` (ADR-018); an active focus session on the plan
/// makes it `inProgress` (ADR-031).
enum EffectivePlanStatus { planned, inProgress, completed, skipped, cancelled }

/// An intention for a date (§3.2): an activity plan, or a Task when it has no
/// activity type (§21).
class Plan {
  const Plan({
    required this.id,
    required this.planDate,
    required this.title,
    required this.sortOrder,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.activityTypeId,
    this.notes,
    this.plannedStartAt,
    this.plannedEndAt,
    this.plannedDurationMs,
  });

  static const maxTitleLength = 120;

  final PlanId id;
  final LocalDate planDate;

  /// Null for a Task.
  final ActivityTypeId? activityTypeId;
  final String title;
  final String? notes;

  /// Optional planned time range (UTC instants).
  final DateTime? plannedStartAt;
  final DateTime? plannedEndAt;

  /// Planned length without fixed times ("Read for 45 minutes"). Never set
  /// together with [plannedEndAt]: one source of planned duration.
  final int? plannedDurationMs;

  /// Manual order among the date's untimed plans.
  final int sortOrder;
  final PlanStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isTask => activityTypeId == null;

  bool get isTimed => plannedStartAt != null;

  /// The planned length, from the time range or [plannedDurationMs].
  int? get plannedLengthMs => plannedEndAt != null
      ? plannedEndAt!.difference(plannedStartAt!).inMilliseconds
      : plannedDurationMs;

  /// The effective status, given whether a non-deleted record fulfils it and
  /// whether a focus session is running on it.
  EffectivePlanStatus effectiveStatus({
    required bool hasRecord,
    bool inFocus = false,
  }) {
    if (!isTask && hasRecord) return EffectivePlanStatus.completed;
    if (inFocus) return EffectivePlanStatus.inProgress;
    return switch (status) {
      PlanStatus.planned => EffectivePlanStatus.planned,
      PlanStatus.completed => EffectivePlanStatus.completed,
      PlanStatus.skipped => EffectivePlanStatus.skipped,
      PlanStatus.cancelled => EffectivePlanStatus.cancelled,
    };
  }

  Plan copyWith({
    LocalDate? planDate,
    DateTime? Function()? plannedStartAt,
    DateTime? Function()? plannedEndAt,
    int? sortOrder,
    PlanStatus? status,
    DateTime? updatedAt,
  }) => Plan(
    id: id,
    planDate: planDate ?? this.planDate,
    activityTypeId: activityTypeId,
    title: title,
    notes: notes,
    plannedStartAt: plannedStartAt != null
        ? plannedStartAt()
        : this.plannedStartAt,
    plannedEndAt: plannedEndAt != null ? plannedEndAt() : this.plannedEndAt,
    plannedDurationMs: plannedDurationMs,
    sortOrder: sortOrder ?? this.sortOrder,
    status: status ?? this.status,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

/// User input for creating or editing a plan.
class PlanDraft {
  const PlanDraft({
    required this.planDate,
    required this.title,
    this.activityTypeId,
    this.notes,
    this.plannedStartAt,
    this.plannedEndAt,
    this.plannedDurationMs,
  });

  final LocalDate planDate;
  final String title;
  final ActivityTypeId? activityTypeId;
  final String? notes;
  final DateTime? plannedStartAt;
  final DateTime? plannedEndAt;
  final int? plannedDurationMs;
}

/// Default start of a record fulfilling [plan] (ADR-030): its planned start
/// when it has one (the day planner's slot, e.g. 21:10); otherwise now for
/// today's plan, or the plan's date at the current local time of day.
DateTime recordStartFor(Plan plan, Clock clock) {
  if (plan.plannedStartAt case final start?) return start;
  final now = clock.nowUtc();
  final offset = clock.offsetAt(now);
  if (plan.planDate == LocalDate.ofInstant(now, offset)) return now;
  final local = now.add(offset);
  final date = plan.planDate;
  final naive = DateTime.utc(
    date.year,
    date.month,
    date.day,
    local.hour,
    local.minute,
  );
  return naive.subtract(clock.offsetAt(naive.subtract(offset)));
}

/// Display order of a date's plans (ui_guidelines.md §4.2): timed plans by
/// start time, then untimed plans in their manual order.
List<Plan> orderPlans(Iterable<Plan> plans) {
  final timed = plans.where((p) => p.isTimed).toList()
    ..sort((a, b) {
      final byTime = a.plannedStartAt!.compareTo(b.plannedStartAt!);
      return byTime != 0 ? byTime : a.sortOrder.compareTo(b.sortOrder);
    });
  final untimed = plans.where((p) => !p.isTimed).toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  return [...timed, ...untimed];
}
