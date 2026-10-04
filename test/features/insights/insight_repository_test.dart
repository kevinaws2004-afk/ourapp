import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/logging/app_logger.dart';
import 'package:daylog/core/time/local_date.dart';
import 'package:daylog/features/activity_logs/data/db_activity_log_repository.dart';
import 'package:daylog/features/activity_logs/domain/activity_log.dart';
import 'package:daylog/features/activity_logs/domain/activity_log_use_cases.dart';
import 'package:daylog/features/activity_logs/domain/field_value.dart';
import 'package:daylog/features/activity_types/data/db_activity_type_repository.dart';
import 'package:daylog/features/activity_types/domain/activity_ids.dart';
import 'package:daylog/features/activity_types/domain/activity_type.dart';
import 'package:daylog/features/activity_types/domain/activity_type_definition.dart';
import 'package:daylog/features/activity_types/domain/activity_type_use_cases.dart';
import 'package:daylog/features/insights/data/db_insight_repository.dart';
import 'package:daylog/features/insights/domain/insight.dart';
import 'package:daylog/features/insights/domain/insight_use_cases.dart';
import 'package:daylog/features/measurements/data/db_measurement_repository.dart';
import 'package:daylog/features/measurements/domain/measurement.dart';
import 'package:daylog/features/measurements/domain/measurement_use_cases.dart';
import 'package:daylog/features/plans/data/db_plan_repository.dart';
import 'package:daylog/features/plans/domain/plan.dart';
import 'package:daylog/features/plans/domain/plan_use_cases.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';
import '../../support/fixtures.dart';
import '../../support/test_app.dart';

/// The generic analytics engine (§24–26) over real stored records.
void main() {
  late AppDatabase db;
  late FakeClock clock;
  late DbActivityTypeRepository types;
  late DbActivityLogRepository logs;
  late DbPlanRepository plans;
  late DbInsightRepository insights;
  late SequentialIdGenerator ids;
  late LogActivity logActivity;
  var item = 0;
  GroupItemId itemId() => GroupItemId(
    '00000000-0000-7000-9000-${(item++).toString().padLeft(12, '0')}',
  );

  setUp(() {
    db = newTestDatabase();
    clock = FakeClock(DateTime.utc(2026, 10, 1, 12));
    types = DbActivityTypeRepository(db, clock);
    logs = DbActivityLogRepository(db, clock, const AppLogger());
    plans = DbPlanRepository(db, clock);
    insights = DbInsightRepository(db);
    ids = SequentialIdGenerator();
    logActivity = LogActivity(types, logs, plans, ids, clock);
  });

  tearDown(() => db.close());

  Future<ActivityType> install(ActivityTypeDefinition definition) async {
    final id = await CreateActivityType(types, ids)(definition);
    return (await types.getType(id))!;
  }

  ActivityFieldId field(ActivityType t, String name) =>
      t.fields.firstWhere((f) => f.name == name).id;

  /// A Gym session on [day] with [exercises]: name → [(kg, reps)].
  Future<void> workout(
    ActivityType gym,
    DateTime day,
    Map<String, List<(double, double)>> exercises,
  ) => logActivity(
    gym.id,
    ActivityLogDraft(
      startedAt: day,
      durationMs: 3600000,
      values: {
        field(gym, 'Exercises'): RepeatingGroupValue([
          for (final MapEntry(key: name, value: sets) in exercises.entries)
            GroupItem(
              id: itemId(),
              values: {
                field(gym, 'Exercise'): TextValue(name),
                field(gym, 'Sets'): RepeatingGroupValue([
                  for (final (kg, reps) in sets)
                    GroupItem(
                      id: itemId(),
                      values: {
                        field(gym, 'Weight'): NumberValue(kg, unitCode: 'kg'),
                        field(gym, 'Reps'): NumberValue(reps),
                      },
                    ),
                ]),
              },
            ),
        ]),
      },
    ),
  );

  test('nested set weights per exercise, and the personal best', () async {
    final gym = await install(gymDefinition());
    await workout(gym, DateTime.utc(2026, 9, 28, 7), {
      'Chest Press': [(50, 12), (55, 10)],
      'Squat': [(100, 5)],
    });
    await workout(gym, DateTime.utc(2026, 9, 30, 7), {
      'chest press': [(60, 8)],
    });

    final weights = await insights
        .watchPoints(
          FieldValueSource(
            gym.id,
            field(gym, 'Weight'),
            filter: TextFilter(
              fieldId: field(gym, 'Exercise'),
              value: 'Chest Press',
            ),
          ),
        )
        .first;
    expect(weights.map((p) => p.value), [50, 55, 60], reason: 'not Squat');

    final result = await WatchInsight(insights)(
      InsightChartConfig(
        id: const InsightChartId('c'),
        title: 'Chest press',
        source: FieldValueSource(
          gym.id,
          field(gym, 'Weight'),
          filter: TextFilter(
            fieldId: field(gym, 'Exercise'),
            value: 'Chest Press',
          ),
        ),
        aggregation: Aggregation.max,
        bucket: Bucket.day,
        kind: ChartKind.line,
      ),
      InsightRange.week,
      LocalDate(2026, 10, 1),
    ).first;
    expect(result.personalBest, DataPoint(LocalDate(2026, 9, 30), 60));
    expect(result.currentValue, 60);
  });

  test('volume is weight × reps per set, summed per day', () async {
    final gym = await install(gymDefinition());
    await workout(gym, DateTime.utc(2026, 9, 28, 7), {
      'Chest Press': [(50, 12), (55, 10)],
    });
    final points = await insights
        .watchPoints(
          VolumeSource(
            gym.id,
            groupFieldId: field(gym, 'Sets'),
            amountFieldId: field(gym, 'Weight'),
            countFieldId: field(gym, 'Reps'),
          ),
        )
        .first;
    expect(aggregate(points, Aggregation.sum), 50 * 12 + 55 * 10);
  });

  test('recorded time, counts and per-activity totals', () async {
    final reading = await install(readingDefinition());
    Future<void> read(DateTime at, int minutes) => logActivity(
      reading.id,
      ActivityLogDraft(
        startedAt: at,
        durationMs: minutes * 60000,
        values: {field(reading, 'Book'): const TextValue('Antifragile')},
      ),
    );
    await read(DateTime.utc(2026, 9, 29, 21), 45);
    await read(DateTime.utc(2026, 9, 30, 21), 30);

    final time = await insights
        .watchPoints(ActivityDurationSource(reading.id))
        .first;
    expect(aggregate(time, Aggregation.sum), 75 * 60000);
    final count = await insights
        .watchPoints(ActivityCountSource(reading.id))
        .first;
    expect(count, hasLength(2));
    final totals = await insights
        .watchActivityTotals(LocalDate(2026, 9, 25), LocalDate(2026, 10, 1))
        .first;
    expect(totals[reading.id]!.durationMs, 75 * 60000);
    expect(totals[reading.id]!.count, 2);
  });

  test('planned vs actual by plan date', () async {
    final reading = await install(readingDefinition());
    final planId = await CreatePlan(plans, types, ids, clock)(
      PlanDraft(
        planDate: LocalDate(2026, 9, 30),
        title: 'Read',
        activityTypeId: reading.id,
        plannedDurationMs: 3600000,
      ),
    );
    await logActivity(
      reading.id,
      ActivityLogDraft(
        startedAt: DateTime.utc(2026, 9, 30, 21),
        durationMs: 45 * 60000,
        planId: planId,
        values: {field(reading, 'Book'): const TextValue('Antifragile')},
      ),
    );

    final (planned, actual) = await insights
        .watchPlannedVsActual(reading.id)
        .first;
    expect(planned.single, DataPoint(LocalDate(2026, 9, 30), 3600000));
    expect(actual.single, DataPoint(LocalDate(2026, 9, 30), 45 * 60000));
  });

  test('body measurements are a canonical series', () async {
    final measurements = DbMeasurementRepository(db, clock);
    final record = RecordMeasurement(measurements, ids, clock);
    await record(
      MeasurementDraft(
        type: MeasurementType.weight,
        value: 85,
        unitCode: 'kg',
        recordedAt: DateTime.utc(2026, 9, 24, 7),
      ),
    );
    await record(
      MeasurementDraft(
        type: MeasurementType.weight,
        value: 185,
        unitCode: 'lb',
        recordedAt: DateTime.utc(2026, 10, 1, 7),
      ),
    );

    final points = await insights
        .watchPoints(const MeasurementSource(MeasurementType.weight))
        .first;
    expect(points.first.value, 85);
    expect(points.last.value, closeTo(83.91, 0.01), reason: '185 lb in kg');
  });

  test('charts are saved, listed in order and deleted', () async {
    final save = SaveInsightChart(insights, ids, clock);
    final id = await save(
      const InsightChartConfig(
        id: InsightChartId(''),
        title: ' Weight ',
        source: MeasurementSource(MeasurementType.weight),
        aggregation: Aggregation.latest,
        bucket: Bucket.week,
        kind: ChartKind.line,
      ),
    );
    final charts = await insights.watchCharts().first;
    expect(charts.single.id, id);
    expect(charts.single.title, 'Weight');
    expect(
      charts.single.source,
      const MeasurementSource(MeasurementType.weight),
    );

    await DeleteInsightChart(insights, clock)(id);
    expect(await insights.watchCharts().first, isEmpty);
  });
}
