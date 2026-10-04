import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/errors/app_exception.dart';
import 'package:daylog/core/logging/app_logger.dart';
import 'package:daylog/core/time/local_date.dart';
import 'package:daylog/features/activity_logs/data/db_activity_log_repository.dart';
import 'package:daylog/features/activity_logs/domain/activity_log.dart';
import 'package:daylog/features/activity_logs/domain/activity_log_use_cases.dart';
import 'package:daylog/features/activity_logs/domain/field_value.dart';
import 'package:daylog/features/activity_types/data/db_activity_type_repository.dart';
import 'package:daylog/features/activity_types/domain/activity_ids.dart';
import 'package:daylog/features/activity_types/domain/activity_type_use_cases.dart';
import 'package:daylog/features/plans/data/db_plan_repository.dart';
import 'package:daylog/features/plans/domain/item_use_cases.dart';
import 'package:daylog/features/plans/domain/plan.dart';
import 'package:daylog/features/plans/domain/plan_use_cases.dart';
import 'package:daylog/features/plans/domain/watch_day_overview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_clock.dart';
import '../../../support/fixtures.dart';
import '../../../support/test_app.dart';

/// Items (ADR-035) against a real in-memory database.
void main() {
  late AppDatabase db;
  late FakeClock clock;
  late SequentialIdGenerator ids;
  late DbActivityTypeRepository types;
  late DbActivityLogRepository logs;
  late DbPlanRepository plans;
  late CreatePlan createPlan;
  late LogActivity logActivity;
  late EnsureItemActivity ensure;
  final today = LocalDate(2026, 10, 4);

  setUp(() {
    db = newTestDatabase();
    clock = FakeClock(DateTime.utc(2026, 10, 4, 9));
    ids = SequentialIdGenerator();
    types = DbActivityTypeRepository(db, clock);
    logs = DbActivityLogRepository(db, clock, const AppLogger());
    plans = DbPlanRepository(db, clock);
    createPlan = CreatePlan(plans, types, ids, clock);
    logActivity = LogActivity(types, logs, plans, ids, clock);
    ensure = EnsureItemActivity(
      plans,
      types,
      CreateActivityType(types, ids),
      AssignPlanActivity(UpdatePlan(plans, types, clock), plans),
    );
  });

  tearDown(() => db.close());

  Future<PlanId> task(String title) =>
      createPlan(PlanDraft(planDate: today, title: title));

  group('EnsureItemActivity', () {
    test('a new name gets a plain activity of its own, once', () async {
      final id = await task('Doctor call');

      final typeId = await ensure(id);

      final type = (await types.getType(typeId))!;
      expect(type.name, 'Doctor call');
      expect(type.fields, isEmpty);
      expect(type.supportsTimer, isTrue);
      expect((await plans.getPlan(id))!.activityTypeId, typeId);
      expect(await ensure(id), typeId, reason: 'idempotent');
      expect(await types.getActiveTypes(), hasLength(1));
    });

    test('a name matching an existing activity reuses it', () async {
      final reading = await CreateActivityType(types, ids)(readingDefinition());
      final id = await task('  reading ');

      expect(await ensure(id), reading);
    });
  });

  group('MarkItemDone', () {
    MarkItemDone markDone() => MarkItemDone(
      plans,
      logs,
      logActivity,
      SetPlanStatus(plans, clock),
      clock,
    );

    test(
      'an activity item gets a log at its planned time and length',
      () async {
        final reading = await CreateActivityType(types, ids)(
          readingDefinition(), // Book is required: done without details anyway
        );
        final start = DateTime.utc(2026, 10, 4, 7);
        final id = await createPlan(
          PlanDraft(
            planDate: today,
            title: '',
            activityTypeId: reading,
            plannedStartAt: start,
            plannedDurationMs: 1800000,
          ),
        );

        final created = await markDone()(id);
        expect(await markDone()(id), isNull, reason: 'nothing new to create');
        expect((await plans.getPlan(id))!.status, PlanStatus.completed);

        final log = (await logs.getLogForPlan(id))!;
        expect(log.id, created, reason: 'returned for Undo');
        expect(log.startedAt, start);
        expect(log.durationMs, 1800000);
        final count = await db
            .customSelect('SELECT COUNT(*) AS c FROM activity_logs')
            .getSingle();
        expect(count.read<int>('c'), 1, reason: 'no second log');
      },
    );

    test('a task is ticked off', () async {
      final id = await task('Buy groceries');

      await markDone()(id);

      expect((await plans.getPlan(id))!.status, PlanStatus.completed);
      expect(await logs.getLogForPlan(id), isNull);
    });
  });

  test('a partial log saves without required values; a full one still '
      'needs them', () async {
    final reading = await CreateActivityType(types, ids)(readingDefinition());
    final draft = ActivityLogDraft(
      startedAt: clock.nowUtc(),
      values: const {},
      notes: 'Started chapter 3',
    );

    await expectLater(
      logActivity(reading, draft),
      throwsA(isA<ValidationException>()),
    );
    final id = await logActivity(reading, draft, partial: true);
    expect((await logs.getLog(id))!.notes, 'Started chapter 3');
  });

  test('deleting an item deletes what was logged into it; Undo restores '
      'both', () async {
    final typeId = await ensure(await task('Doctor call'));
    final id = (await plans.watchPlansForDay(today).first).single.id;
    await logActivity(
      typeId,
      ActivityLogDraft(
        startedAt: clock.nowUtc(),
        values: const {},
        notes: 'Vitamin D',
        planId: id,
      ),
      partial: true,
    );

    final deleted = await DeleteItem(plans, logs)(id);
    expect(await plans.getPlan(id), isNull);
    expect(await logs.getLogForPlan(id), isNull);

    await RestoreItem(plans, logs)(id, deleted);
    expect(await plans.getPlan(id), isNotNull);
    expect((await logs.getLogForPlan(id))!.notes, 'Vitamin D');
  });

  test('a day lists plans and unplanned records as one time-ordered list, '
      'untimed plans last', () async {
    final reading = await CreateActivityType(types, ids)(readingDefinition());
    final book = (await types.getType(reading))!.activeFields.first.id;
    Future<void> record(DateTime at, {PlanId? plan}) => logActivity(
      reading,
      ActivityLogDraft(
        startedAt: at,
        values: {book: const TextValue('x')},
        planId: plan,
      ),
    );
    final evening = await createPlan(
      PlanDraft(
        planDate: today,
        title: 'Evening read',
        activityTypeId: reading,
        plannedStartAt: DateTime.utc(2026, 10, 4, 20),
      ),
    );
    final untimedDone = await createPlan(
      PlanDraft(planDate: today, title: 'Read', activityTypeId: reading),
    );
    await task('Buy groceries');
    await record(DateTime.utc(2026, 10, 4, 12), plan: untimedDone);
    await record(DateTime.utc(2026, 10, 4, 8)); // unplanned

    final overview = await WatchDayOverview(plans, logs, types, clock)(today)
        .first;
    final order = [
      for (final e in overview.entries)
        switch (e) {
          PlanEntry(:final item) => item.plan.id.value,
          RecordEntry() => 'unplanned',
        },
    ];

    expect(order, [
      'unplanned', // 08:00
      untimedDone.value, // logged at 12:00
      evening.value, // planned for 20:00
      isNot(anyOf('unplanned', untimedDone.value, evening.value)), // task
    ]);
  });

  test('getLogForPlan ignores deleted logs', () async {
    final typeId = await ensure(await task('Run'));
    final id = (await plans.watchPlansForDay(today).first).single.id;
    final logId = await logActivity(
      typeId,
      ActivityLogDraft(startedAt: clock.nowUtc(), values: const {}, planId: id),
      partial: true,
    );
    await logs.softDelete(logId);

    expect(await logs.getLogForPlan(id), isNull);
    expect(typeId, isA<ActivityTypeId>());
  });
}
