import 'package:daylog/core/errors/app_exception.dart';
import 'package:daylog/core/time/local_date.dart';
import 'package:daylog/features/activity_types/domain/activity_ids.dart';
import 'package:daylog/features/insights/data/insight_chart_codec.dart';
import 'package:daylog/features/insights/domain/insight.dart';
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
}
