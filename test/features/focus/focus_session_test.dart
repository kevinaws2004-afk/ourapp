import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/database/db_unit_of_work.dart';
import 'package:daylog/core/errors/app_exception.dart';
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
import 'package:daylog/features/focus/data/db_focus_session_repository.dart';
import 'package:daylog/features/focus/domain/focus_session.dart';
import 'package:daylog/features/focus/domain/focus_use_cases.dart';
import 'package:daylog/features/plans/data/db_plan_repository.dart';
import 'package:daylog/features/plans/domain/plan.dart';
import 'package:daylog/features/plans/domain/plan_use_cases.dart';
import 'package:daylog/features/plans/domain/watch_day_overview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';
import '../../support/fixtures.dart';
import '../../support/test_app.dart';

/// Focus sessions (ADR-031) against a real in-memory database.
void main() {
  late AppDatabase db;
  late FakeClock clock;
  late DbActivityTypeRepository types;
  late DbActivityLogRepository logs;
  late DbPlanRepository plans;
  late DbFocusSessionRepository sessions;
  late SequentialIdGenerator ids;
  late StartFocusSession start;
  late PauseFocusSession pause;
  late ResumeFocusSession resume;
  late FinishFocusSession finish;

  setUp(() {
    db = newTestDatabase();
    clock = FakeClock(DateTime.utc(2026, 10, 4, 21));
    types = DbActivityTypeRepository(db, clock);
    logs = DbActivityLogRepository(db, clock, const AppLogger());
    plans = DbPlanRepository(db, clock);
    sessions = DbFocusSessionRepository(db);
    ids = SequentialIdGenerator();
    start = StartFocusSession(sessions, types, plans, ids, clock);
    pause = PauseFocusSession(sessions, clock);
    resume = ResumeFocusSession(sessions, clock);
    finish = FinishFocusSession(
      sessions,
      LogActivity(types, logs, plans, ids, clock),
      DbUnitOfWork(db),
      clock,
    );
  });

  tearDown(() => db.close());

  Future<ActivityType> reading() async {
    final id = await CreateActivityType(types, ids)(readingDefinition());
    return (await types.getType(id))!;
  }

  ActivityLogDraft draft(ActivityType type, FocusSession s, {String? book}) =>
      ActivityLogDraft(
        startedAt: s.startedAt,
        values: {if (book != null) type.activeFields.first.id: TextValue(book)},
      );

  group('elapsed time is derived from timestamps', () {
    final t0 = DateTime.utc(2026, 10, 4, 21);
    final running = FocusSession(
      id: const FocusSessionId('s'),
      activityTypeId: const ActivityTypeId('t'),
      state: FocusState.running,
      startedAt: t0,
      pausedDurationMs: 0,
      createdAt: t0,
      updatedAt: t0,
    );

    test('pauses are excluded, and a paused session stands still', () {
      final paused = running.paused(t0.add(const Duration(minutes: 10)));
      expect(
        paused.elapsedMs(t0.add(const Duration(minutes: 30))),
        const Duration(minutes: 10).inMilliseconds,
      );
      final resumed = paused.resumed(t0.add(const Duration(minutes: 15)));
      expect(
        resumed.pausedDurationMs,
        const Duration(minutes: 5).inMilliseconds,
      );
      expect(
        resumed.elapsedMs(t0.add(const Duration(minutes: 20))),
        const Duration(minutes: 15).inMilliseconds,
      );
    });
  });

  test('a timer survives the app being killed: a new repository reads the '
      'same elapsed time', () async {
    final type = await reading();
    await start(type.id);
    clock.advance(const Duration(minutes: 25));

    final reopened = await DbFocusSessionRepository(db).getActive();
    expect(
      reopened!.elapsedMs(clock.nowUtc()),
      const Duration(minutes: 25).inMilliseconds,
    );
  });

  test('only timer activities, and one session at a time', () async {
    final type = await reading();
    final noTimer = await CreateActivityType(types, ids)(
      const ActivityTypeDefinition(
        name: 'Lunch',
        iconId: 'fork-knife',
        colorKey: 'apricot',
        fields: [],
      ),
    );
    await expectLater(
      start(noTimer),
      throwsA(
        isA<ValidationException>().having(
          (e) => e.issues.single.code,
          'code',
          ValidationCode.activityHasNoTimer,
        ),
      ),
    );
    await start(type.id);
    await expectLater(
      start(type.id),
      throwsA(
        isA<ValidationException>().having(
          (e) => e.issues.single.code,
          'code',
          ValidationCode.focusAlreadyActive,
        ),
      ),
    );
  });

  test(
    'finishing records the focused time and links the plan, atomically',
    () async {
      final type = await reading();
      final today = LocalDate(2026, 10, 4);
      final planId = await CreatePlan(plans, types, ids, clock)(
        PlanDraft(planDate: today, title: 'Read', activityTypeId: type.id),
      );
      final id = await start(type.id, planId: planId);
      final overview = WatchDayOverview(
        plans,
        logs,
        types,
        planInFocus: () => sessions.watchActive().map((s) => s?.planId),
      );
      expect(
        (await overview(today).first).planned.single.status,
        EffectivePlanStatus.inProgress,
      );

      clock.advance(const Duration(minutes: 30));
      await pause(id);
      clock.advance(const Duration(minutes: 5)); // paused: not counted
      await resume(id);
      clock.advance(const Duration(minutes: 12));
      final session = (await sessions.getActive())!;

      final logId = await finish(id, draft(type, session, book: 'Antifragile'));

      final log = (await logs.getLog(logId))!;
      expect(log.durationMs, const Duration(minutes: 42).inMilliseconds);
      expect(log.endedAt, clock.nowUtc());
      expect(log.planId, planId);
      expect(await sessions.getActive(), isNull);
      expect(
        (await overview(today).first).planned.single.status,
        EffectivePlanStatus.completed,
      );
    },
  );

  test('a record that fails validation leaves the session running', () async {
    final type = await reading(); // Book is required
    final id = await start(type.id);
    clock.advance(const Duration(minutes: 10));
    final session = (await sessions.getActive())!;

    await expectLater(
      finish(id, draft(type, session)),
      throwsA(isA<ValidationException>()),
    );

    expect((await sessions.getActive())!.state, FocusState.running);
    final count = await db
        .customSelect('SELECT COUNT(*) AS c FROM activity_logs')
        .getSingle();
    expect(count.read<int>('c'), 0);
  });

  test('discarding creates no record', () async {
    final type = await reading();
    final id = await start(type.id);

    await DiscardFocusSession(sessions, clock)(id);

    expect(await sessions.getActive(), isNull);
    expect(await sessions.getSession(id), isNull);
  });

  test('the database allows one active session and checks the plan', () async {
    final type = await reading();
    await start(type.id);
    final typeRow = await db
        .customSelect('SELECT internal_id FROM activity_types')
        .getSingle();
    await expectLater(
      db.customStatement(
        'INSERT INTO focus_sessions (public_id, activity_type_id, state, started_at, '
        "created_at, updated_at) VALUES ('00000000-0000-7000-8000-000000000999', ?, "
        "'running', 1, 1, 1)",
        [typeRow.read<int>('internal_id')],
      ),
      throwsA(anything),
    );
  });
}
