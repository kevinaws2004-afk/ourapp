import '../../../core/async/combine_latest.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/local_date.dart';
import '../../activity_types/domain/activity_ids.dart';
import 'insight.dart';
import 'insight_repository.dart';

/// What a chart shows for a range: its series, the period value against the
/// previous period, and the all-time best (a personal record, FR-AN-08).
class InsightResult {
  const InsightResult({
    required this.series,
    required this.currentValue,
    required this.previousValue,
    required this.from,
    required this.to,
    required this.bucket,
    this.plannedSeries,
    this.personalBest,
    this.bestDay,
  });

  /// The period shown, `[from, to]` (one range for the whole screen, A20).
  final LocalDate from;
  final LocalDate to;

  /// The grouping used: the chart's, or coarser for a long range (D3).
  final Bucket bucket;

  /// The values (recorded time, for planned vs actual).
  final InsightSeries series;

  /// Planned lengths, for planned vs actual only.
  final InsightSeries? plannedSeries;
  final double? currentValue;
  final double? previousValue;

  /// Highest point ever recorded (for value-like sources): for a volume,
  /// the best single item (e.g. set).
  final DataPoint? personalBest;

  /// For a volume: the best day's total ever (A21).
  final DataPoint? bestDay;

  double? get change => relativeChange(currentValue, previousValue);

  /// Nothing recorded in the period.
  bool get isEmpty => series.isEmpty && (plannedSeries?.isEmpty ?? true);
}

/// Composite read (ADR-023): computes a chart from its source's points.
/// Only the shown period (and the one before, for the comparison) is read;
/// the all-time best comes from its own query (E1).
class WatchInsight {
  const WatchInsight(this._insights);

  final InsightRepository _insights;

  /// [bestIs] is what "best" means for the chart's values (ADR-043).
  Stream<InsightResult> call(
    InsightChartConfig chart,
    InsightRange range,
    LocalDate today, {
    BestIs bestIs = BestIs.highest,
  }) {
    final bucket = range.fit(chart.bucket);
    final (from, to) = range.window(today);
    final (prevFrom, prevTo) = range.previous(today);
    final loadFrom = range.loadFrom(today, bucket);
    InsightSeries series(List<DataPoint> points) => buildSeries(
      points,
      from: from,
      to: to,
      bucket: bucket,
      aggregation: chart.aggregation,
    );

    final source = chart.source;
    if (source is PlannedVsActualSource) {
      return _insights
          .watchPlannedVsActual(source.typeId, from: loadFrom, today: today)
          .map((data) {
            final (planned, actual) = data;
            return InsightResult(
              from: from,
              to: to,
              bucket: bucket,
              series: series(actual),
              plannedSeries: series(planned),
              currentValue: periodValue(actual, from, to, Aggregation.sum),
              previousValue: periodValue(planned, from, to, Aggregation.sum),
            );
          });
    }
    final tracksBest = source is FieldValueSource || source is VolumeSource;
    final best = tracksBest
        ? _insights.watchBest(source, bestIs)
        : Stream<DataPoint?>.value(null);
    final bestDay =
        source is VolumeSource && source.formula == VolumeFormula.product
        ? _insights.watchBestDay(source)
        : Stream<DataPoint?>.value(null);
    return combineLatest2(
      _insights.watchPoints(source, from: loadFrom),
      combineLatest2(best, bestDay, (a, b) => (a, b)),
      (points, records) => InsightResult(
        from: from,
        to: to,
        bucket: bucket,
        series: series(points),
        currentValue: periodValue(points, from, to, chart.aggregation),
        previousValue: periodValue(points, prevFrom, prevTo, chart.aggregation),
        personalBest: records.$1,
        bestDay: records.$2,
      ),
    );
  }
}

class SaveInsightChart {
  const SaveInsightChart(this._insights, this._ids, this._clock);

  final InsightRepository _insights;
  final IdGenerator _ids;
  final Clock _clock;

  /// Saves [chart]; a chart without an ID gets a new one.
  Future<InsightChartId> call(InsightChartConfig chart) async {
    final id = chart.id.value.isEmpty ? InsightChartId(_ids.newId()) : chart.id;
    await _insights.saveChart(
      InsightChartConfig(
        id: id,
        title: chart.title.trim(),
        source: chart.source,
        aggregation: chart.aggregation,
        bucket: chart.bucket,
        kind: chart.kind,
      ),
      _clock.nowUtc(),
    );
    return id;
  }
}

class DeleteInsightChart {
  const DeleteInsightChart(this._insights, this._clock);

  final InsightRepository _insights;
  final Clock _clock;

  Future<void> call(InsightChartId id) =>
      _insights.deleteChart(id, _clock.nowUtc());
}

/// The selected period at a glance against the one before (H5).
class InsightSummary {
  const InsightSummary({
    required this.daysActive,
    required this.previousDaysActive,
    required this.durationMs,
    required this.previousDurationMs,
    required this.count,
    required this.previousCount,
  });

  factory InsightSummary.of(
    Map<LocalDate, int> days,
    Map<LocalDate, int> previousDays,
    Map<ActivityTypeId, ActivityTotals> totals,
    Map<ActivityTypeId, ActivityTotals> previousTotals,
  ) {
    int ms(Map<ActivityTypeId, ActivityTotals> t) =>
        t.values.fold(0, (sum, x) => sum + x.durationMs);
    int count(Map<LocalDate, int> d) => d.values.fold(0, (sum, n) => sum + n);
    return InsightSummary(
      daysActive: days.length,
      previousDaysActive: previousDays.length,
      durationMs: ms(totals),
      previousDurationMs: ms(previousTotals),
      count: count(days),
      previousCount: count(previousDays),
    );
  }

  /// Days with at least one record done.
  final int daysActive;
  final int previousDaysActive;

  /// Recorded time.
  final int durationMs;
  final int previousDurationMs;

  /// Records done.
  final int count;
  final int previousCount;
}

/// An activity's change against the previous period (A7): by recorded time
/// when either period has any, otherwise by how often it was done, so
/// activities nobody times still show a change. Null when there's nothing to
/// compare with.
double? activityChange(ActivityTotals now, ActivityTotals? before) {
  if (before == null) return null;
  final timed = now.durationMs > 0 || before.durationMs > 0;
  return timed
      ? relativeChange(now.durationMs.toDouble(), before.durationMs.toDouble())
      : relativeChange(now.count.toDouble(), before.count.toDouble());
}

/// The share of planned items done per bucket over `[from, to]` (H3); null
/// for a bucket with nothing planned.
List<(LocalDate start, double? share)> planShareBuckets(
  List<PlanDay> days,
  LocalDate from,
  LocalDate to,
  Bucket bucket,
) {
  final planned = buildSeries(
    [for (final d in days) DataPoint(d.date, d.planned.toDouble())],
    from: from,
    to: to,
    bucket: bucket,
    aggregation: Aggregation.sum,
  );
  final done = buildSeries(
    [for (final d in days) DataPoint(d.date, d.done.toDouble())],
    from: from,
    to: to,
    bucket: bucket,
    aggregation: Aggregation.sum,
  );
  return [
    for (final (i, b) in planned.buckets.indexed)
      (
        b.start,
        (b.value ?? 0) == 0 ? null : (done.buckets[i].value ?? 0) / b.value!,
      ),
  ];
}
