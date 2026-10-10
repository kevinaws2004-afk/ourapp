import '../../../core/time/local_date.dart';
import '../../activity_types/domain/activity_ids.dart';
import 'day_progress.dart';
import 'plan.dart';
import 'watch_day_overview.dart';

/// The edges of a day on Today (ADR-046, v1_ux_spec T2, T7–T10): what's left
/// from yesterday in the morning, the evening review, and what you usually
/// do when nothing is planned. All derived; nothing is stored.
abstract final class DayEdges {
  /// "From yesterday" shows until noon (local).
  static const fromYesterdayUntilHour = 12;

  /// The evening review shows from 17:00 (local).
  static const eveningFromHour = 17;

  /// How many weeks back "your usual Thursday" looks.
  static const usualWeeks = 4;

  /// At most this many usual activities are offered.
  static const maxUsual = 5;
}

/// Yesterday's things neither done, skipped nor running (T2), in the day's
/// order. Empty after noon ([localHour] ≥ 12): the morning is for deciding.
List<PlannedItem> leftFromYesterday(DayOverview yesterday, int localHour) {
  if (localHour >= DayEdges.fromYesterdayUntilHour) return const [];
  return [
    for (final item in yesterday.planned)
      if (item.status == EffectivePlanStatus.planned) item,
  ];
}

/// Today's evening review (T7/T8), or null when it isn't time for one.
///
/// It shows from 17:00 when at least one thing was planned and either every
/// planned thing is decided (done or skipped) or the last planned thing's
/// end has passed.
class EveningReview {
  const EveningReview({required this.progress, required this.unfinished});

  final DayProgress progress;

  /// Planned things neither done nor skipped (nor running), to move to
  /// tomorrow or let go.
  final List<PlannedItem> unfinished;

  /// Nothing left to decide: one closing line (T8), or the all-done card.
  bool get closed => unfinished.isEmpty;

  static EveningReview? of(
    DayOverview today, {
    required DateTime nowUtc,
    required int localHour,
  }) {
    if (localHour < DayEdges.eveningFromHour) return null;
    final planned = [
      for (final item in today.planned)
        if (item.status != EffectivePlanStatus.cancelled) item,
    ];
    if (planned.isEmpty) return null;
    if (planned.any((i) => i.status == EffectivePlanStatus.inProgress)) {
      return null; // still doing something
    }
    final unfinished = [
      for (final item in planned)
        if (item.status == EffectivePlanStatus.planned) item,
    ];
    DateTime? lastEnd;
    for (final item in planned) {
      final start = item.plan.plannedStartAt;
      if (start == null) continue;
      final end = start.add(
        Duration(milliseconds: item.plan.plannedLengthMs ?? 0),
      );
      if (lastEnd == null || end.isAfter(lastEnd)) lastEnd = end;
    }
    final lastPassed = lastEnd != null && !lastEnd.isAfter(nowUtc);
    if (unfinished.isNotEmpty && !lastPassed) return null;
    return EveningReview(
      progress: DayProgress.of(today),
      unfinished: unfinished,
    );
  }
}

/// An activity you usually do on a weekday (T10), with its usual start.
class UsualActivity {
  const UsualActivity({required this.activityTypeId, this.startMinute});

  final ActivityTypeId activityTypeId;

  /// Minutes after local midnight it usually starts; null when untimed.
  final int? startMinute;
}

/// What you usually do on [today]'s weekday (T10): activities planned and
/// not skipped on that weekday in the last [DayEdges.usualWeeks] weeks, the
/// most frequent first, each with its most frequent start.
///
/// [startMinuteOf] gives a plan's local start in minutes after midnight.
List<UsualActivity> usualForWeekday(
  Iterable<Plan> plans,
  LocalDate today,
  int? Function(Plan) startMinuteOf,
) {
  final from = today.addDays(-7 * DayEdges.usualWeeks);
  final counts = <ActivityTypeId, int>{};
  final starts = <ActivityTypeId, Map<int?, int>>{};
  for (final plan in plans) {
    final id = plan.activityTypeId;
    if (id == null) continue;
    final date = plan.planDate;
    if (date.compareTo(from) < 0 || date.compareTo(today) >= 0) continue;
    if (date.weekday != today.weekday) continue;
    if (plan.status == PlanStatus.skipped ||
        plan.status == PlanStatus.cancelled) {
      continue;
    }
    counts[id] = (counts[id] ?? 0) + 1;
    final byStart = starts.putIfAbsent(id, () => {});
    final start = startMinuteOf(plan);
    byStart[start] = (byStart[start] ?? 0) + 1;
  }
  final ids = counts.keys.toList()
    ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
  return [
    for (final id in ids.take(DayEdges.maxUsual))
      UsualActivity(
        activityTypeId: id,
        startMinute:
            (starts[id]!.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value)))
                .first
                .key,
      ),
  ];
}
