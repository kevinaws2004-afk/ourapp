import '../../../core/time/local_date.dart';
import '../../activity_types/domain/activity_ids.dart';
import 'insight.dart';
import 'insight_repository.dart';

/// One activity's week: its time and how often.
class RecapActivity {
  const RecapActivity(this.typeId, this.durationMs, this.count);

  final ActivityTypeId typeId;
  final int durationMs;
  final int count;
}

/// A week at a glance (Monday to Sunday): planned vs recorded time, things
/// done, active days, plans kept, the activities that took the time, the
/// best day, and the week before for comparison. Worked out from Insights'
/// reads (pure).
class WeekRecap {
  const WeekRecap({
    required this.weekStart,
    required this.plannedMs,
    required this.actualMs,
    required this.trackedMs,
    required this.done,
    required this.activeDays,
    required this.plansCounted,
    required this.plansDone,
    required this.activities,
    required this.bestDay,
    required this.bestDayMs,
    required this.previousTrackedMs,
    required this.previousDone,
  });

  factory WeekRecap.of({
    required LocalDate weekStart,
    required List<DataPoint> planned,
    required List<DataPoint> actual,
    required Map<ActivityTypeId, ActivityTotals> totals,
    required Map<ActivityTypeId, ActivityTotals> previousTotals,
    required Map<LocalDate, int> dayCounts,
    required List<ActivityDayTime> timeByDay,
    required List<PlanDay> adherence,
  }) {
    final weekEnd = weekStart.addDays(6);
    bool inWeek(LocalDate d) =>
        d.compareTo(weekStart) >= 0 && d.compareTo(weekEnd) <= 0;
    double sum(List<DataPoint> points) => points
        .where((p) => inWeek(p.date))
        .fold(0, (total, p) => total + p.value);
    final perDay = <LocalDate, int>{};
    for (final t in timeByDay) {
      if (inWeek(t.date)) perDay[t.date] = (perDay[t.date] ?? 0) + t.durationMs;
    }
    LocalDate? bestDay;
    var bestMs = 0;
    for (final MapEntry(:key, :value) in perDay.entries) {
      if (value > bestMs) {
        bestMs = value;
        bestDay = key;
      }
    }
    final week = adherence.where((d) => inWeek(d.date));
    final activities =
        [
          for (final MapEntry(:key, :value) in totals.entries)
            RecapActivity(key, value.durationMs, value.count),
        ]..sort((a, b) {
          final byTime = b.durationMs.compareTo(a.durationMs);
          return byTime != 0 ? byTime : b.count.compareTo(a.count);
        });
    int totalMs(Map<ActivityTypeId, ActivityTotals> t) =>
        t.values.fold(0, (s, v) => s + v.durationMs);
    int totalCount(Map<ActivityTypeId, ActivityTotals> t) =>
        t.values.fold(0, (s, v) => s + v.count);
    return WeekRecap(
      weekStart: weekStart,
      plannedMs: sum(planned).round(),
      actualMs: sum(actual).round(),
      trackedMs: totalMs(totals),
      done: totalCount(totals),
      activeDays: dayCounts.entries
          .where((e) => inWeek(e.key) && e.value > 0)
          .length,
      plansCounted: week.fold(0, (s, d) => s + d.planned),
      plansDone: week.fold(0, (s, d) => s + d.done),
      activities: activities,
      bestDay: bestDay,
      bestDayMs: bestMs,
      previousTrackedMs: totalMs(previousTotals),
      previousDone: totalCount(previousTotals),
    );
  }

  final LocalDate weekStart;
  LocalDate get weekEnd => weekStart.addDays(6);

  /// Planned lengths of the week's plans, and the time recorded on them.
  final int plannedMs;
  final int actualMs;

  /// All time recorded, planned or not.
  final int trackedMs;

  /// Records done.
  final int done;
  final int activeDays;

  /// Plans that counted (not skipped or cancelled) and those done.
  final int plansCounted;
  final int plansDone;

  /// Activities by time, then how often.
  final List<RecapActivity> activities;

  /// The day with the most recorded time.
  final LocalDate? bestDay;
  final int bestDayMs;

  final int previousTrackedMs;
  final int previousDone;

  bool get isEmpty => done == 0 && plansCounted == 0;

  /// Recorded of planned time, 0–1+ (null with nothing planned). Also null
  /// when lengths were planned for only a small part of what was done
  /// (2h planned on a 30-min reading, 8h done in all): "392% of plan"
  /// would say nothing true.
  double? get plannedShare =>
      plannedMs <= 0 || plannedMs * 2 < actualMs ? null : actualMs / plannedMs;

  /// Plans done of those that counted, 0–1 (null with none).
  double? get plansShare => plansCounted <= 0 ? null : plansDone / plansCounted;

  /// Change in recorded time against the week before (null without one).
  double? get timeChange => relativeChange(
    trackedMs.toDouble(),
    previousTrackedMs == 0 ? null : previousTrackedMs.toDouble(),
  );
}
