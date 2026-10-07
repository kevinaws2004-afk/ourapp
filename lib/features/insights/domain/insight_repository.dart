import '../../../core/time/local_date.dart';
import '../../activity_types/domain/activity_ids.dart';
import 'insight.dart';

/// Totals of one activity over a period.
class ActivityTotals {
  const ActivityTotals({
    required this.durationMs,
    required this.count,
    this.days = 0,
  });

  final int durationMs;
  final int count;

  /// Distinct days it was done on.
  final int days;
}

/// Plans on one day: how many counted as planned and how many got done.
class PlanDay {
  const PlanDay(this.date, {required this.planned, required this.done});

  final LocalDate date;
  final int planned;
  final int done;

  @override
  bool operator ==(Object other) =>
      other is PlanDay &&
      other.date == date &&
      other.planned == planned &&
      other.done == done;

  @override
  int get hashCode => Object.hash(date, planned, done);
}

/// Recorded time of one activity on one day.
class ActivityDayTime {
  const ActivityDayTime(this.typeId, this.date, this.durationMs);

  final ActivityTypeId typeId;
  final LocalDate date;
  final int durationMs;
}

/// Read model for Insights (FR-AN-*) plus the saved charts. Streams update
/// when the underlying records, plans or measurements change. Throws only
/// `AppException`s.
///
/// A record counts as done (for counts, days and streaks) only when
/// something is in it: a time, notes, a value, or its plan marked done
/// (A8). Opening an item and leaving it empty doesn't count.
abstract interface class InsightRepository {
  /// Points of [source] (any [InsightSource] except [PlannedVsActualSource])
  /// on or after [from] (all when null), oldest first. Only the period a
  /// chart shows is read (E1).
  Stream<List<DataPoint>> watchPoints(InsightSource source, {LocalDate? from});

  /// The best single point of [source] ever, by [bestIs] (a personal record,
  /// FR-AN-08); null when there's none.
  Stream<DataPoint?> watchBest(InsightSource source, BestIs bestIs);

  /// The best day's total ever of a volume (A21).
  Stream<DataPoint?> watchBestDay(VolumeSource source);

  /// Planned lengths and recorded times of plans by plan date, in ms, from
  /// [from] to [today] (FR-AN-09). Skipped and cancelled plans don't count
  /// as planned (A4); today's plans only once they're done (A6).
  Stream<(List<DataPoint> planned, List<DataPoint> actual)>
  watchPlannedVsActual(
    ActivityTypeId? typeId, {
    required LocalDate from,
    required LocalDate today,
  });

  /// Per-activity recorded time and count over `[from, to]`.
  Stream<Map<ActivityTypeId, ActivityTotals>> watchActivityTotals(
    LocalDate from,
    LocalDate to,
  );

  /// Records done per day over `[from, to]`, for one activity or all (the
  /// consistency calendar).
  Stream<Map<LocalDate, int>> watchDayCounts(
    ActivityTypeId? typeId,
    LocalDate from,
    LocalDate to,
  );

  /// Recorded time per activity and day over `[from, to]` (where the time
  /// went).
  Stream<List<ActivityDayTime>> watchTimeByActivity(
    LocalDate from,
    LocalDate to,
  );

  /// Plans per day from [from] to [today]: planned (not skipped or
  /// cancelled; today's only once done) and done (marked done, or logged on
  /// a day that has passed, ADR-040).
  Stream<List<PlanDay>> watchPlanAdherence(LocalDate from, LocalDate today);

  /// Every day each activity was done on (streaks).
  Stream<Map<ActivityTypeId, Set<LocalDate>>> watchActiveDays();

  /// The options picked in a choice field, one list per record, over
  /// `[from, to]` (B3).
  Stream<List<List<String>>> watchChoicePicks(
    ActivityFieldId fieldId,
    LocalDate from,
    LocalDate to,
  );

  /// When records of an activity started, as local minutes after midnight,
  /// over `[from, to]`.
  Stream<List<int>> watchStartMinutes(
    ActivityTypeId typeId,
    LocalDate from,
    LocalDate to,
  );

  /// The names of an activity's list rows (e.g. exercises) used over
  /// `[from, to]`, per naming field, most used first (C1).
  Stream<Map<ActivityFieldId, List<String>>> watchRowNames(
    ActivityTypeId typeId,
    LocalDate from,
    LocalDate to,
  );

  Stream<List<InsightChartConfig>> watchCharts();

  /// Inserts or replaces a chart (by ID); new charts go last.
  Future<void> saveChart(InsightChartConfig chart, DateTime now);

  Future<void> deleteChart(InsightChartId id, DateTime now);
}
