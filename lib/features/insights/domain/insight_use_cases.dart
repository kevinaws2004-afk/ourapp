import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/local_date.dart';
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
    this.plannedSeries,
    this.personalBest,
    this.bestDay,
  });

  /// The period shown, `[from, to]` (one range for the whole screen, A20).
  final LocalDate from;
  final LocalDate to;

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
class WatchInsight {
  const WatchInsight(this._insights);

  final InsightRepository _insights;

  Stream<InsightResult> call(
    InsightChartConfig chart,
    InsightRange range,
    LocalDate today,
  ) {
    final (from, to) = range.window(today);
    final (prevFrom, prevTo) = range.previous(today);
    InsightSeries series(List<DataPoint> points) => buildSeries(
      points,
      from: from,
      to: to,
      bucket: chart.bucket,
      aggregation: chart.aggregation,
    );

    final source = chart.source;
    if (source is PlannedVsActualSource) {
      return _insights.watchPlannedVsActual(source.typeId).map((data) {
        final (planned, actual) = data;
        return InsightResult(
          from: from,
          to: to,
          series: series(actual),
          plannedSeries: series(planned),
          currentValue: periodValue(actual, from, to, Aggregation.sum),
          previousValue: periodValue(planned, from, to, Aggregation.sum),
        );
      });
    }
    final tracksBest = source is FieldValueSource || source is VolumeSource;
    return _insights
        .watchPoints(source)
        .map(
          (points) => InsightResult(
            from: from,
            to: to,
            series: series(points),
            currentValue: periodValue(points, from, to, chart.aggregation),
            previousValue: periodValue(
              points,
              prevFrom,
              prevTo,
              chart.aggregation,
            ),
            personalBest: tracksBest && points.isNotEmpty
                ? points.reduce((a, b) => b.value > a.value ? b : a)
                : null,
            bestDay: source is VolumeSource ? bestDayTotal(points) : null,
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
