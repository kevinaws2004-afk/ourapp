import 'package:daylog/core/errors/app_exception.dart';
import 'package:daylog/core/time/local_date.dart';
import 'package:daylog/features/activity_types/domain/activity_ids.dart';
import 'package:daylog/features/insights/data/insight_chart_codec.dart';
import 'package:daylog/features/insights/domain/insight.dart';
import 'package:daylog/features/insights/domain/insight_repository.dart';
import 'package:daylog/features/insights/domain/insight_use_cases.dart';
import 'package:daylog/shared/widgets/charts/chart_axis.dart';
import 'package:daylog/features/measurements/domain/measurement.dart';
import 'package:daylog/features/measurements/domain/measurement_use_cases.dart';
import 'package:flutter_test/flutter_test.dart';

DataPoint p(int month, int day, double v) =>
    DataPoint(LocalDate(2026, month, day), v);

void main() {
  group('series', () {
    test('weeks start on Monday; months on the 1st', () {
      // 2026-10-01 is a Thursday.
      expect(
        bucketStart(LocalDate(2026, 10, 1), Bucket.week),
        LocalDate(2026, 9, 28),
      );
      expect(
        bucketStart(LocalDate(2026, 10, 17), Bucket.month),
        LocalDate(2026, 10, 1),
      );
    });

    test('daily buckets cover the range; sums fill gaps with 0, others '
        'leave gaps', () {
      final points = [p(9, 28, 30), p(9, 28, 15), p(9, 30, 45)];
      final sum = buildSeries(
        points,
        from: LocalDate(2026, 9, 28),
        to: LocalDate(2026, 9, 30),
        bucket: Bucket.day,
        aggregation: Aggregation.sum,
      );
      expect(sum.buckets.map((b) => b.value), [45, 0, 45]);
      expect(sum.total, 90);
      expect(sum.count, 3);
      expect(sum.best, p(9, 30, 45));

      final best = buildSeries(
        points,
        from: LocalDate(2026, 9, 28),
        to: LocalDate(2026, 9, 30),
        bucket: Bucket.day,
        aggregation: Aggregation.max,
      );
      expect(best.buckets.map((b) => b.value), [30, null, 45]);
    });

    test('aggregations', () {
      final points = [p(9, 1, 80), p(9, 3, 82), p(9, 2, 90)];
      expect(aggregate(points, Aggregation.average), closeTo(84, 0.001));
      expect(aggregate(points, Aggregation.min), 80);
      expect(aggregate(points, Aggregation.latest), 82, reason: 'by date');
      expect(aggregate(points, Aggregation.count), 3);
      expect(aggregate(const [], Aggregation.sum), 0);
      expect(aggregate(const [], Aggregation.max), isNull);
    });

    test('this period vs the previous one', () {
      final today = LocalDate(2026, 10, 14);
      final (from, to) = InsightRange.week.window(today);
      final (pFrom, pTo) = InsightRange.week.previous(today);
      expect((from, to), (LocalDate(2026, 10, 8), today));
      expect((pFrom, pTo), (LocalDate(2026, 10, 1), LocalDate(2026, 10, 7)));
      final points = [p(10, 3, 100), p(10, 10, 120)];
      final change = relativeChange(
        periodValue(points, from, to, Aggregation.sum),
        periodValue(points, pFrom, pTo, Aggregation.sum),
      );
      expect(change, closeTo(0.2, 0.0001));
      expect(relativeChange(5, 0), isNull);
    });
  });

  test('chart configs round-trip through versioned JSON', () {
    const filter = TextFilter(
      fieldId: ActivityFieldId('ex'),
      value: 'Chest Press',
    );
    final sources = <InsightSource>[
      const ActivityDurationSource(ActivityTypeId('t')),
      const ActivityCountSource(ActivityTypeId('t')),
      const FieldValueSource(
        ActivityTypeId('t'),
        ActivityFieldId('w'),
        filter: filter,
      ),
      const VolumeSource(
        ActivityTypeId('t'),
        groupFieldId: ActivityFieldId('sets'),
        amountFieldId: ActivityFieldId('w'),
        countFieldId: ActivityFieldId('r'),
      ),
      const MeasurementSource(MeasurementType.bodyFat),
      const PlannedVsActualSource(),
      const PlannedVsActualSource(ActivityTypeId('t')),
    ];
    for (final source in sources) {
      final chart = InsightChartConfig(
        id: const InsightChartId('c'),
        title: 'T',
        source: source,
        aggregation: Aggregation.max,
        bucket: Bucket.month,
        kind: ChartKind.bar,
      );
      final decoded = InsightChartCodec.decode(
        'c',
        InsightChartCodec.encode(chart),
      )!;
      expect(decoded.source, source);
      expect(
        (decoded.aggregation, decoded.bucket, decoded.kind),
        (Aggregation.max, Bucket.month, ChartKind.bar),
      );
    }
    expect(InsightChartCodec.decode('c', '{"v": 99}'), isNull);
  });

  test('measurement validation: positive, body fat ≤ 100 %, unit of the '
      'right dimension', () {
    List<ValidationCode> codes(MeasurementType t, double v, String unit) =>
        validateMeasurement(
          MeasurementDraft(
            type: t,
            value: v,
            unitCode: unit,
            recordedAt: DateTime.utc(2026),
          ),
        ).issues.map((i) => i.code).toList();
    expect(codes(MeasurementType.weight, 84.2, 'kg'), isEmpty);
    expect(codes(MeasurementType.weight, 0, 'kg'), [
      ValidationCode.belowMinimum,
    ]);
    expect(codes(MeasurementType.bodyFat, 120, 'percent'), [
      ValidationCode.aboveMaximum,
    ]);
    expect(codes(MeasurementType.waist, 80, 'kg'), [
      ValidationCode.unitRequired,
    ]);
    expect(codes(MeasurementType.waist, 31.5, 'in'), isEmpty);
  });

  group('insights rework (ADR-043)', () {
    test('every bucket is whole: the first week also counts its days '
        'before the period, the stats don\'t (A2)', () {
      // Period Oct 1 (Thu) – Oct 14; its first week starts Mon Sep 28.
      final series = buildSeries(
        [p(9, 28, 10), p(10, 1, 5), p(10, 13, 7)],
        from: LocalDate(2026, 10, 1),
        to: LocalDate(2026, 10, 14),
        bucket: Bucket.week,
        aggregation: Aggregation.sum,
      );
      expect(series.buckets.first.start, LocalDate(2026, 9, 28));
      expect(series.buckets.map((b) => b.value), [15, 0, 7]);
      expect(series.total, 12, reason: 'stats cover the period only');
    });

    test('a saved chart\'s grouping gets coarser for long ranges (D3)', () {
      expect(
        InsightRange.year.fit(Bucket.day),
        Bucket.week,
        reason: '53 weeks',
      );
      expect(InsightRange.quarter.fit(Bucket.day), Bucket.week);
      expect(InsightRange.year.fit(Bucket.week), Bucket.week);
      expect(InsightRange.month.fit(Bucket.day), Bucket.day);
    });

    test('best by direction (A3)', () {
      final points = [p(9, 1, 120), p(9, 2, 110), p(9, 3, 130)];
      expect(bestOf(points, BestIs.highest), p(9, 3, 130));
      expect(bestOf(points, BestIs.lowest), p(9, 2, 110));
      expect(bestOf(points, BestIs.none), isNull);
    });

    test('week streaks: the run goes on until a week is missed (H4)', () {
      final today = LocalDate(2026, 10, 14); // Wednesday
      final days = [
        LocalDate(2026, 9, 1), // a lone week, long ago
        LocalDate(2026, 9, 22),
        LocalDate(2026, 9, 29),
        LocalDate(2026, 10, 6), // last week; nothing yet this week
      ];
      expect(weekStreaks(days, today), (current: 3, longest: 3));
      expect(weekStreaks([LocalDate(2026, 9, 22)], today), (
        current: 0,
        longest: 1,
      ));
      expect(weekStreaks(const [], today), (current: 0, longest: 0));
    });

    test('choices: most picked first, ties in the field\'s order (B3)', () {
      expect(
        optionCounts(
          [
            ['b'],
            ['a', 'b'],
            ['c'],
          ],
          ['a', 'b', 'c'],
        ),
        [('b', 2), ('a', 1), ('c', 1)],
      );
    });

    test('parts of the day', () {
      expect(partOfDay(4 * 60 + 59), PartOfDay.night);
      expect(partOfDay(5 * 60), PartOfDay.morning);
      expect(partOfDay(12 * 60), PartOfDay.afternoon);
      expect(partOfDay(17 * 60), PartOfDay.evening);
      expect(partOfDay(22 * 60), PartOfDay.night);
    });

    test('plan vs reality per bucket; none planned is a gap (H3)', () {
      final shares = planShareBuckets(
        [
          PlanDay(LocalDate(2026, 10, 1), planned: 4, done: 3),
          PlanDay(LocalDate(2026, 10, 3), planned: 0, done: 0),
        ],
        LocalDate(2026, 10, 1),
        LocalDate(2026, 10, 3),
        Bucket.day,
      );
      expect(shares.map((s) => s.$2), [0.75, null, null]);
    });

    test('an activity nobody times changes by how often it was done (A7)', () {
      expect(
        activityChange(
          const ActivityTotals(durationMs: 0, count: 6),
          const ActivityTotals(durationMs: 0, count: 3),
        ),
        1.0,
      );
      expect(
        activityChange(
          const ActivityTotals(durationMs: 3000, count: 1),
          const ActivityTotals(durationMs: 6000, count: 9),
        ),
        -0.5,
        reason: 'timed: by time',
      );
      expect(
        activityChange(const ActivityTotals(durationMs: 0, count: 1), null),
        isNull,
      );
    });

    test('a line axis fits its values instead of starting at 0 (D1)', () {
      final weight = ChartAxis.fitRange(70.2, 72.4);
      expect(weight.min, greaterThan(60));
      expect(weight.min, lessThanOrEqualTo(70.2));
      expect(weight.max, greaterThanOrEqualTo(72.4));
      final cold = ChartAxis.fitRange(-6, 4);
      expect(cold.min, lessThanOrEqualTo(-6));
      final one = ChartAxis.fitRange(50, 50);
      expect(one.min, lessThan(50));
      expect(one.max, greaterThan(50));
      expect(ChartAxis.fit(7, wholeNumbers: true).min, 0, reason: 'bars');
    });

    test('a volume\'s formula round-trips, older charts read as a product', () {
      const source = VolumeSource(
        ActivityTypeId('gym'),
        groupFieldId: ActivityFieldId('sets'),
        amountFieldId: ActivityFieldId('kg'),
        countFieldId: ActivityFieldId('reps'),
        formula: VolumeFormula.estimatedMax,
      );
      const chart = InsightChartConfig(
        id: InsightChartId('c'),
        title: 'Max',
        source: source,
        aggregation: Aggregation.max,
        bucket: Bucket.week,
        kind: ChartKind.line,
      );
      final json = InsightChartCodec.encode(chart);
      expect(InsightChartCodec.decode('c', json), chart);
      final old = json.replaceFirst(',"formula":"estimatedMax"', '');
      expect(
        (InsightChartCodec.decode('c', old)!.source as VolumeSource).formula,
        VolumeFormula.product,
      );
    });
  });
}
