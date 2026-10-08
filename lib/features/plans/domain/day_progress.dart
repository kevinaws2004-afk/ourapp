import 'plan.dart';
import 'watch_day_overview.dart';

/// How much of a day is done (the Today ring, ADR-045): items done out of
/// the items that count. Skipped and cancelled plans don't count; a record
/// made without a plan counts as one done item.
class DayProgress {
  const DayProgress({required this.done, required this.total});

  factory DayProgress.of(DayOverview overview) {
    var done = overview.unplanned.length;
    var total = overview.unplanned.length;
    for (final item in overview.planned) {
      switch (item.status) {
        case EffectivePlanStatus.skipped || EffectivePlanStatus.cancelled:
          continue;
        case EffectivePlanStatus.completed:
          done++;
          total++;
        case EffectivePlanStatus.planned || EffectivePlanStatus.inProgress:
          total++;
      }
    }
    return DayProgress(done: done, total: total);
  }

  final int done;
  final int total;

  double get fraction => total == 0 ? 0 : done / total;

  bool get isEmpty => total == 0;

  bool get allDone => total > 0 && done == total;
}

/// The item to do next on a day (Today's "Up next", ADR-045), or null when
/// nothing is open:
/// 1. one in progress (you're doing it),
/// 2. else the earliest timed one that hasn't ended by [nowUtc],
/// 3. else the first untimed one.
///
/// Timed items whose time has passed without being done are left to the list;
/// they aren't "next" any more.
PlannedItem? upNext(DayOverview overview, DateTime nowUtc) {
  final open = overview.planned.where((i) => i.isOpen).toList();
  for (final item in open) {
    if (item.status == EffectivePlanStatus.inProgress) return item;
  }
  PlannedItem? nextTimed;
  for (final item in open) {
    final start = item.plan.plannedStartAt;
    if (start == null) continue;
    final end = start.add(
      Duration(milliseconds: item.plan.plannedLengthMs ?? 0),
    );
    if (end.isBefore(nowUtc)) continue;
    if (nextTimed == null || start.isBefore(nextTimed.plan.plannedStartAt!)) {
      nextTimed = item;
    }
  }
  if (nextTimed != null) return nextTimed;
  for (final item in open) {
    if (item.plan.plannedStartAt == null) return item;
  }
  return null;
}
