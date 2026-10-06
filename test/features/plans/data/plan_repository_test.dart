import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/errors/app_exception.dart';
import 'package:daylog/core/logging/app_logger.dart';
import 'package:daylog/core/time/local_date.dart';
import 'package:daylog/features/activity_logs/data/db_activity_log_repository.dart';
import 'package:daylog/features/activity_logs/domain/activity_log.dart';
import 'package:daylog/features/activity_logs/domain/activity_log_use_cases.dart';
import 'package:daylog/features/activity_logs/domain/log_memory.dart';
import 'package:daylog/features/activity_logs/domain/field_value.dart';
import 'package:daylog/features/activity_types/data/db_activity_type_repository.dart';
import 'package:daylog/features/activity_types/domain/activity_type.dart';
import 'package:daylog/features/activity_types/domain/activity_type_use_cases.dart';
import 'package:daylog/features/plans/data/db_plan_repository.dart';
import 'package:daylog/features/plans/domain/plan.dart';
import 'package:daylog/features/plans/domain/plan_use_cases.dart';
import 'package:daylog/features/plans/domain/watch_day_overview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_clock.dart';
import '../../../support/fixtures.dart';
import '../../../support/test_app.dart';

/// Plans (ADR-018) against a real in-memory database: persistence, use
/// cases, plan → record links and the derived day overview.
void main() {
  late AppDatabase db;
  late FakeClock clock;
  late DbActivityTypeRepository types;
  late DbActivityLogRepository logs;
  late DbPlanRepository plans;
  late SequentialIdGenerator ids;
  late CreatePlan createPlan;
  late LogActivity logActivity;
  final today = LocalDate(2026, 10, 4);

  setUp(() {
    db = newTestDatabase();
    clock = FakeClock(
      DateTime.utc(2026, 10, 4, 6),
      offset: const Duration(hours: 2),
    );
    types = DbActivityTypeRepository(db, clock);
    logs = DbActivityLogRepository(db, clock, const AppLogger());
    plans = DbPlanRepository(db, clock);
    ids = SequentialIdGenerator();
    createPlan = CreatePlan(plans, types, ids, clock);
    logActivity = LogActivity(types, logs, plans, ids, clock);
  });

  tearDown(() => db.close());

  Future<ActivityType> reading() async {
    final id = await CreateActivityType(types, ids)(readingDefinition());
    return (await types.getType(id))!;
  }

  Future<DayOverview> overview(LocalDate date) =>
      WatchDayOverview(plans, logs, types, clock)(date).first;

  Future<ActivityLogId> record(
    ActivityType type, {
    PlanId? planId,
    int durationMs = 2700000,
  }) => logActivity(
    type.id,
    ActivityLogDraft(
      startedAt: clock.nowUtc(),
      durationMs: durationMs,
      planId: planId,
      values: {type.activeFields.first.id: const TextValue('Antifragile')},
    ),
  );

  test('creating plans: activity name as title, appended order, '
      'planned duration', () async {
    final type = await reading();
    final readId = await createPlan(
      PlanDraft(
        planDate: today,
        title: '',
        activityTypeId: type.id,
        plannedDurationMs: 2700000,
      ),
    );
    final taskId = await createPlan(
      PlanDraft(planDate: today, title: ' Buy groceries '),
    );

    final read = (await plans.getPlan(readId))!;
    final task = (await plans.getPlan(taskId))!;
    expect(
      (read.title, read.sortOrder, read.plannedLengthMs),
      ('Reading', 0, 2700000),
    );
    expect(
      (task.title, task.sortOrder, task.isTask),
      ('Buy groceries', 1, true),
    );
  });

  test('recording from a plan links it; it is in progress that day and done '
      'once the day has passed (ADR-040)', () async {
    final type = await reading();
    final planId = await createPlan(
      PlanDraft(
        planDate: today,
        title: 'Read',
        activityTypeId: type.id,
        plannedDurationMs: 3600000,
      ),
    );
    expect((await overview(today)).planned.single.isOpen, isTrue);

    final logId = await record(type, planId: planId);

    expect((await logs.getLog(logId))!.planId, planId);
    final day = await overview(today);
    final item = day.planned.single;
    expect(item.status, EffectivePlanStatus.inProgress);
    expect(item.actualDurationMs, 2700000);
    expect(day.unplanned, isEmpty, reason: 'the record fulfils the plan');
    expect(await plans.hasRecords(planId), isTrue);

    clock.advance(const Duration(days: 1));
    expect(
      (await overview(today)).planned.single.status,
      EffectivePlanStatus.completed,
      reason: 'logged on a past day',
    );

    // Deleting the record reopens the plan: nothing was marked done.
    await DeleteActivityLog(logs)(logId);
    expect((await overview(today)).planned.single.isOpen, isTrue);
  });

  test('a record fulfilling a plan of another day pairs with that plan, '
      'and unplanned records are listed separately', () async {
    final type = await reading();
    final yesterday = today.addDays(-1);
    final planId = await createPlan(
      PlanDraft(planDate: yesterday, title: 'Read', activityTypeId: type.id),
    );
    await record(type, planId: planId);
    await record(type);

    final past = await overview(yesterday);
    expect(past.planned.single.records, hasLength(1));
    final now = await overview(today);
    expect(now.records, hasLength(2));
    expect(now.unplanned, hasLength(2), reason: 'no plans today');
  });

  test('a record can only fulfil a plan of its own activity', () async {
    final type = await reading();
    final taskId = await createPlan(PlanDraft(planDate: today, title: 'Call'));

    await expectLater(
      record(type, planId: taskId),
      throwsA(
        isA<ValidationException>().having(
          (e) => e.issues.single.code,
          'code',
          ValidationCode.planRecordMismatch,
        ),
      ),
    );
  });

  test('duplicating a plan copies it on the same day as a new, open one '
      '(B7)', () async {
    final type = await reading();
    final nine = DateTime.utc(2026, 10, 4, 7);
    final id = await createPlan(
      PlanDraft(
        planDate: today,
        title: 'Read',
        activityTypeId: type.id,
        notes: 'Chapter 3',
        plannedStartAt: nine,
        plannedDurationMs: 1800000,
      ),
    );
    await SetPlanStatus(plans, clock)(id, PlanStatus.completed);

    final copyId = await DuplicatePlan(plans, createPlan)(id);

    final copy = (await plans.getPlan(copyId))!;
    expect(copyId, isNot(id));
    expect(
      (copy.planDate, copy.title, copy.activityTypeId, copy.notes),
      (today, 'Read', type.id, 'Chapter 3'),
    );
    expect((copy.plannedStartAt, copy.plannedDurationMs), (nine, 1800000));
    expect(copy.status, PlanStatus.planned);
    expect(copy.seriesId, isNull);
  });

  test('the last log of an activity skips the item\'s own and empty ones '
      '(B1)', () async {
    final type = await reading();
    final older = await record(type);
    clock.advance(const Duration(hours: 1));
    final mine = await record(type);
    clock.advance(const Duration(hours: 1));
    await logActivity(
      type.id,
      ActivityLogDraft(startedAt: clock.nowUtc(), values: const {}),
      partial: true,
    );

    final last = await LastLogOfType(logs)(type.id, except: mine);
    expect(last?.id, older);
  });

  test('any item can be marked done by status (ADR-040)', () async {
    final type = await reading();
    final setStatus = SetPlanStatus(plans, clock);
    final taskId = await createPlan(PlanDraft(planDate: today, title: 'Call'));
    final readId = await createPlan(
      PlanDraft(planDate: today, title: 'Read', activityTypeId: type.id),
    );

    await setStatus(taskId, PlanStatus.completed);
    expect(
      (await overview(today)).planned
          .firstWhere((i) => i.plan.id == taskId)
          .status,
      EffectivePlanStatus.completed,
    );
    await setStatus(readId, PlanStatus.completed);
    expect(
      (await overview(today)).planned
          .firstWhere((i) => i.plan.id == readId)
          .status,
      EffectivePlanStatus.completed,
    );
  });

  test(
    'moving to tomorrow keeps the local time, reopens and appends',
    () async {
      final setStatus = SetPlanStatus(plans, clock);
      final tomorrow = today.addDays(1);
      await createPlan(PlanDraft(planDate: tomorrow, title: 'Existing'));
      final nine = DateTime.utc(2026, 10, 4, 7); // 09:00 at +2h
      final id = await createPlan(
        PlanDraft(
          planDate: today,
          title: 'Write',
          plannedStartAt: nine,
          plannedEndAt: nine.add(const Duration(hours: 1)),
        ),
      );
      await setStatus(id, PlanStatus.skipped);

      await MovePlan(plans, SequentialIdGenerator(), clock)(id, tomorrow);

      final moved = (await plans.getPlan(id))!;
      expect(moved.planDate, tomorrow);
      expect(moved.plannedStartAt, nine.add(const Duration(days: 1)));
      expect(moved.plannedLengthMs, 3600000);
      expect(moved.status, PlanStatus.planned);
      expect(moved.sortOrder, 1);
    },
  );

  test('reordering rewrites the manual order', () async {
    final a = await createPlan(PlanDraft(planDate: today, title: 'A'));
    final b = await createPlan(PlanDraft(planDate: today, title: 'B'));
    final c = await createPlan(PlanDraft(planDate: today, title: 'C'));

    await ReorderPlans(plans, clock)([c, a, b]);

    expect((await overview(today)).planned.map((i) => i.plan.title), [
      'C',
      'A',
      'B',
    ]);
  });

  test('a recorded plan keeps its activity', () async {
    final type = await reading();
    final id = await createPlan(
      PlanDraft(planDate: today, title: 'Read', activityTypeId: type.id),
    );
    await record(type, planId: id);

    await expectLater(
      UpdatePlan(plans, types, clock)(
        id,
        PlanDraft(planDate: today, title: 'Read'),
      ),
      throwsA(
        isA<ValidationException>().having(
          (e) => e.issues.single.code,
          'code',
          ValidationCode.planActivityLocked,
        ),
      ),
    );
  });

  test('delete hides a plan; restore brings it back', () async {
    final id = await createPlan(PlanDraft(planDate: today, title: 'Call'));

    await DeletePlan(plans)(id);
    expect((await overview(today)).planned, isEmpty);
    expect(await plans.getPlan(id), isNull);

    await RestorePlan(plans)(id);
    expect((await overview(today)).planned.single.plan.id, id);
  });

  test('the day overview updates when a plan is added', () async {
    final emissions = WatchDayOverview(plans, logs, types, clock)(today);
    final expectation = expectLater(
      emissions.map((o) => o.planned.length),
      emitsInOrder([0, 1]),
    );
    await Future<void>.delayed(Duration.zero);
    await createPlan(PlanDraft(planDate: today, title: 'Call'));
    await expectation;
  });
}
