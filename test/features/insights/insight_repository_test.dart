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
import 'package:daylog/features/insights/domain/auto_insights.dart';
import 'package:daylog/features/insights/domain/insight_repository.dart';
import 'package:daylog/features/activity_types/domain/field_config.dart';
import 'package:daylog/features/activity_types/domain/field_type.dart';
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
    await read(DateTime.utc(2026, 9, 30, 7), 0); // same day again

    final time = await insights
        .watchPoints(ActivityDurationSource(reading.id))
        .first;
    expect(aggregate(time, Aggregation.sum), 75 * 60000);
    final count = await insights
        .watchPoints(ActivityCountSource(reading.id))
        .first;
    expect(count, hasLength(3));
    final totals = await insights
        .watchActivityTotals(LocalDate(2026, 9, 25), LocalDate(2026, 10, 1))
        .first;
    expect(totals[reading.id]!.durationMs, 75 * 60000);
    expect(totals[reading.id]!.count, 3);
    expect(totals[reading.id]!.days, 2, reason: 'distinct days');
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
        .watchPlannedVsActual(
          reading.id,
          from: LocalDate(2026, 9, 1),
          today: LocalDate(2026, 10, 3),
        )
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

  test(
    'automatic charts (ADR-037): per exercise, most done first, the '
    'best weight, estimated 1-rep max, volume and total reps (B5, C1)',
    () async {
      final gym = await install(gymDefinition());
      await workout(gym, DateTime.utc(2026, 9, 28, 18), {
        'Chest Press': [(50, 12), (55, 10)],
        'Squat': [(80, 8)],
      });
      await workout(gym, DateTime.utc(2026, 9, 30, 18), {
        'Chest Press': [(60, 8)],
      });
      final exercise = field(gym, 'Exercise');
      final names = await insights
          .watchRowNames(gym.id, LocalDate(2026, 9, 1), LocalDate(2026, 10, 1))
          .first;

      expect(names[exercise], ['Chest Press', 'Squat'], reason: 'most used');
      final charts = autoChartsFor(gym, names);

      expect(
        [for (final c in charts) (c.kind, c.rowName, c.fieldName)],
        [
          (AutoChartKind.time, null, null),
          (AutoChartKind.count, null, null),
          (AutoChartKind.best, 'Chest Press', 'Weight'),
          (AutoChartKind.estimatedMax, 'Chest Press', null),
          (AutoChartKind.volume, 'Chest Press', null),
          (AutoChartKind.rowTotal, 'Chest Press', 'Reps'),
          (AutoChartKind.best, 'Squat', 'Weight'),
          (AutoChartKind.estimatedMax, 'Squat', null),
          (AutoChartKind.volume, 'Squat', null),
          (AutoChartKind.rowTotal, 'Squat', 'Reps'),
        ],
      );
      Future<List<DataPoint>> points(int i) =>
          insights.watchPoints(charts[i].config.source).first;
      expect(aggregate(await points(2), Aggregation.max), 60);
      // Epley: 50 × 1.4 = 70, 55 × 1.33 = 73.3, 60 × 1.27 = 76: the last set.
      expect(aggregate(await points(3), Aggregation.max), closeTo(76, 0.001));
      expect(
        aggregate(await points(4), Aggregation.sum),
        50 * 12 + 55 * 10 + 60 * 8,
      );
      expect(aggregate(await points(5), Aggregation.sum), 12 + 10 + 8);
    },
  );

  test(
    'automatic charts for a plain activity: its numbers and ratings',
    () async {
      final reading = await install(readingDefinition());

      final charts = autoChartsFor(reading, const {});

      expect(
        [for (final c in charts) (c.kind, c.fieldName, c.config.aggregation)],
        [
          (AutoChartKind.time, null, Aggregation.sum),
          (AutoChartKind.count, null, Aggregation.count),
          (AutoChartKind.value, 'Pages', Aggregation.sum),
          (AutoChartKind.value, 'Rating', Aggregation.average),
        ],
      );
    },
  );

  group('insights rework (ADR-043)', () {
    /// An activity with one field of each chartable kind.
    Future<ActivityType> installHealth() => install(
      const ActivityTypeDefinition(
        name: 'Health check',
        iconId: 'heart',
        colorKey: 'rose',
        fields: [
          FieldDefinition(
            name: 'Systolic',
            type: FieldType.number,
            config: NumberFieldConfig(
              summary: NumberSummary.average,
              better: BetterDirection.lower,
            ),
            measurable: true,
          ),
          FieldDefinition(
            name: 'Took meds',
            type: FieldType.boolean,
            config: BooleanFieldConfig(),
          ),
          FieldDefinition(
            name: 'Bedtime',
            type: FieldType.time,
            config: TimeFieldConfig(),
          ),
          FieldDefinition(
            name: 'Walk',
            type: FieldType.duration,
            config: DurationFieldConfig(),
            measurable: true,
          ),
          FieldDefinition(
            name: 'Feeling',
            type: FieldType.singleSelect,
            config: SelectFieldConfig(
              options: [
                SelectOption(id: SelectOptionId('ok'), label: 'OK'),
                SelectOption(id: SelectOptionId('low'), label: 'Low'),
              ],
            ),
          ),
          FieldDefinition(
            name: 'Tags',
            type: FieldType.multiSelect,
            config: SelectFieldConfig(
              options: [
                SelectOption(id: SelectOptionId('a'), label: 'A'),
                SelectOption(id: SelectOptionId('b'), label: 'B'),
              ],
            ),
          ),
        ],
      ),
    );

    Future<void> check(
      ActivityType t,
      DateTime at, {
      required double systolic,
      required bool meds,
      required LocalTime bedtime,
      required int walkMs,
      required String feeling,
      required List<String> tags,
    }) => logActivity(
      t.id,
      ActivityLogDraft(
        startedAt: at,
        values: {
          field(t, 'Systolic'): NumberValue(systolic),
          field(t, 'Took meds'): BooleanValue(meds),
          field(t, 'Bedtime'): TimeValue(bedtime),
          field(t, 'Walk'): DurationValue(walkMs),
          field(t, 'Feeling'): SingleSelectValue(SelectOptionId(feeling)),
          field(t, 'Tags'): MultiSelectValue([
            for (final tag in tags) SelectOptionId(tag),
          ]),
        },
      ),
    );

    test('durations, yes/no and times of day chart like numbers (B1, B2, '
        'B4); the lowest is best when lower is better (A3)', () async {
      final t = await installHealth();
      await check(
        t,
        DateTime.utc(2026, 9, 29, 8),
        systolic: 128,
        meds: true,
        bedtime: LocalTime.hm(23, 0),
        walkMs: 1800000,
        feeling: 'ok',
        tags: ['a', 'b'],
      );
      await check(
        t,
        DateTime.utc(2026, 9, 30, 8),
        systolic: 118,
        meds: false,
        bedtime: LocalTime.hm(22, 30),
        walkMs: 600000,
        feeling: 'ok',
        tags: ['b'],
      );
      Future<List<DataPoint>> values(String name) =>
          insights.watchPoints(FieldValueSource(t.id, field(t, name))).first;

      expect((await values('Walk')).map((p) => p.value), [1800000, 600000]);
      expect(aggregate(await values('Took meds'), Aggregation.average), 0.5);
      expect(
        aggregate(await values('Bedtime'), Aggregation.average),
        (23 * 60 + 22 * 60 + 30) / 2,
      );
      final systolic = FieldValueSource(t.id, field(t, 'Systolic'));
      expect(
        await insights.watchBest(systolic, BestIs.lowest).first,
        DataPoint(LocalDate(2026, 9, 30), 118),
      );
      expect(await insights.watchBest(systolic, BestIs.none).first, isNull);

      final picks = await insights
          .watchChoicePicks(
            field(t, 'Feeling'),
            LocalDate(2026, 9, 1),
            LocalDate(2026, 10, 1),
          )
          .first;
      expect(picks, [
        ['ok'],
        ['ok'],
      ]);
      final tags = await insights
          .watchChoicePicks(
            field(t, 'Tags'),
            LocalDate(2026, 9, 1),
            LocalDate(2026, 10, 1),
          )
          .first;
      expect(optionCounts(tags, ['a', 'b']), [('b', 2), ('a', 1)]);
    });

    test('automatic charts follow each field\'s type and "show as" '
        '(A1, ADR-043); choices become breakdowns (B3)', () async {
      final t = await installHealth();
      final charts = autoChartsFor(t, const {});
      expect(
        [
          for (final c in charts.skip(2))
            (c.kind, c.fieldName, c.config.aggregation, c.config.kind),
        ],
        [
          (
            AutoChartKind.value,
            'Systolic',
            Aggregation.average,
            ChartKind.line,
          ),
          (
            AutoChartKind.yesShare,
            'Took meds',
            Aggregation.average,
            ChartKind.bar,
          ),
          (AutoChartKind.value, 'Bedtime', Aggregation.average, ChartKind.line),
          (AutoChartKind.value, 'Walk', Aggregation.sum, ChartKind.bar),
        ],
      );
      expect(charts[2].bestIs, BestIs.lowest);
      expect(autoBreakdownsFor(t).map((b) => b.field.name), [
        'Feeling',
        'Tags',
      ]);
    });

    test('only the shown period is read; the all-time best is its own '
        'query (E1)', () async {
      final gym = await install(gymDefinition());
      await workout(gym, DateTime.utc(2026, 6, 1, 18), {
        'Squat': [(120, 3)],
      });
      await workout(gym, DateTime.utc(2026, 9, 30, 18), {
        'Squat': [(100, 5)],
      });
      final weight = FieldValueSource(gym.id, field(gym, 'Weight'));

      final recent = await insights
          .watchPoints(weight, from: LocalDate(2026, 9, 1))
          .first;
      expect(recent.map((p) => p.value), [100]);
      expect(
        await insights.watchBest(weight, BestIs.highest).first,
        DataPoint(LocalDate(2026, 6, 1), 120),
      );
    });

    test('an item opened and left empty doesn\'t count as done (A8)', () async {
      final reading = await install(readingDefinition());
      await logActivity(
        reading.id,
        ActivityLogDraft(startedAt: clock.nowUtc(), values: const {}),
        partial: true,
      );
      await logActivity(
        reading.id,
        ActivityLogDraft(
          startedAt: clock.nowUtc(),
          values: const {},
          notes: 'x',
        ),
        partial: true,
      );
      final from = LocalDate(2026, 9, 1);
      final to = LocalDate(2026, 10, 1);

      expect(
        (await insights.watchActivityTotals(from, to).first)[reading.id]!.count,
        1,
      );
      expect(await insights.watchDayCounts(reading.id, from, to).first, {
        LocalDate(2026, 10, 1): 1,
      });
      expect(
        await insights.watchPoints(ActivityCountSource(reading.id)).first,
        hasLength(1),
      );
    });

    test('plans: skipped ones and today\'s open ones aren\'t planned yet '
        '(A4, A6); done ones count for plan vs reality (H3)', () async {
      final reading = await install(readingDefinition());
      final create = CreatePlan(plans, types, ids, clock);
      final setStatus = SetPlanStatus(plans, clock);
      Future<PlanId> plan(LocalDate date) => create(
        PlanDraft(
          planDate: date,
          title: 'Read',
          activityTypeId: reading.id,
          plannedDurationMs: 3600000,
        ),
      );
      final today = LocalDate(2026, 10, 1);
      final done = await plan(LocalDate(2026, 9, 29));
      await setStatus(done, PlanStatus.completed);
      final skipped = await plan(LocalDate(2026, 9, 29));
      await setStatus(skipped, PlanStatus.skipped);
      await plan(LocalDate(2026, 9, 30)); // missed
      await plan(today); // still open today

      final (planned, _) = await insights
          .watchPlannedVsActual(
            reading.id,
            from: LocalDate(2026, 9, 1),
            today: today,
          )
          .first;
      expect(planned.map((p) => p.date), [
        LocalDate(2026, 9, 29),
        LocalDate(2026, 9, 30),
      ]);

      final days = await insights
          .watchPlanAdherence(LocalDate(2026, 9, 1), today)
          .first;
      expect(days, [
        PlanDay(LocalDate(2026, 9, 29), planned: 1, done: 1),
        PlanDay(LocalDate(2026, 9, 30), planned: 1, done: 0),
      ]);
    });

    test('streak days, time per activity and start times (local)', () async {
      final reading = await install(readingDefinition());
      // 22:30 UTC on Sep 30 with the clock's offset (0) is 22:30 local.
      await logActivity(
        reading.id,
        ActivityLogDraft(
          startedAt: DateTime.utc(2026, 9, 30, 22, 30),
          durationMs: 1200000,
          values: const {},
        ),
        partial: true,
      );
      final from = LocalDate(2026, 9, 1);
      final to = LocalDate(2026, 10, 1);

      expect((await insights.watchActiveDays().first)[reading.id], {
        LocalDate(2026, 9, 30),
      });
      final time = await insights.watchTimeByActivity(from, to).first;
      expect(time.single.durationMs, 1200000);
      expect(await insights.watchStartMinutes(reading.id, from, to).first, [
        22 * 60 + 30,
      ]);
    });
  });
}
