import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/errors/app_exception.dart';
import 'package:daylog/core/logging/app_logger.dart';
import 'package:daylog/core/time/local_date.dart';
import 'package:daylog/features/activity_logs/data/db_activity_log_repository.dart';
import 'package:daylog/features/activity_logs/domain/activity_log.dart';
import 'package:daylog/features/activity_logs/domain/activity_log_use_cases.dart';
import 'package:daylog/features/activity_types/data/db_activity_type_repository.dart';
import 'package:daylog/features/activity_types/domain/activity_ids.dart';
import 'package:daylog/features/activity_types/domain/activity_type_definition.dart';
import 'package:daylog/features/activity_types/domain/activity_type_use_cases.dart';
import 'package:daylog/features/challenges/data/db_challenge_repository.dart';
import 'package:daylog/features/challenges/domain/challenge.dart';
import 'package:daylog/features/challenges/domain/challenge_progress.dart';
import 'package:daylog/features/challenges/domain/challenge_use_cases.dart';
import 'package:daylog/features/plans/data/db_plan_repository.dart';
import 'package:daylog/features/plans/domain/plan.dart';
import 'package:daylog/features/plans/domain/plan_use_cases.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';
import '../../support/fixtures.dart';
import '../../support/test_app.dart';

/// Challenges over real stored records (ADR-044): recording the linked
/// activity is what counts a day; progress and streak are derived.
void main() {
  late AppDatabase db;
  late FakeClock clock;
  late DbActivityTypeRepository types;
  late DbActivityLogRepository logs;
  late DbPlanRepository plans;
  late DbChallengeRepository challenges;
  late SequentialIdGenerator ids;
  late LogActivity logActivity;
  late CreateChallenge createChallenge;
  late WatchChallenges watch;

  setUp(() {
    db = newTestDatabase();
    // Sep 22, 2026, 20:00 local (UTC+0).
    clock = FakeClock(DateTime.utc(2026, 9, 22, 20));
    types = DbActivityTypeRepository(db, clock);
    logs = DbActivityLogRepository(db, clock, const AppLogger());
    plans = DbPlanRepository(db, clock);
    challenges = DbChallengeRepository(db, clock);
    ids = SequentialIdGenerator();
    logActivity = LogActivity(types, logs, plans, ids, clock);
    createChallenge = CreateChallenge(challenges, types, ids, clock);
    watch = WatchChallenges(challenges, clock);
  });

  tearDown(() => db.close());

  final start = LocalDate(2026, 9, 1);

  Future<ActivityTypeId> install(String name) => CreateActivityType(types, ids)(
    ActivityTypeDefinition(
      name: name,
      iconId: 'flower-lotus',
      colorKey: 'teal',
      supportsTimer: true,
      fields: const [],
    ),
  );

  /// A meditation of [minutes] on [day] (09:00 local).
  Future<ActivityLogId> record(
    ActivityTypeId type,
    LocalDate day, {
    int minutes = 10,
  }) => logActivity(
    type,
    ActivityLogDraft(
      startedAt: DateTime.utc(day.year, day.month, day.day, 9),
      durationMs: minutes * 60000,
      values: const {},
    ),
  );

  Future<ChallengeId> start75(ActivityTypeId type, {LocalDate? from}) =>
      createChallenge(
        ChallengeDraft(
          activityTypeId: type,
          title: '75 days of Meditation',
          startDate: from ?? start,
          targetDays: 75,
        ),
      );

  Future<ChallengeView> only() async => (await watch().first).single;

  test('recording the linked activity counts the day, with no extra step, '
      'and other activities don\'t', () async {
    final meditation = await install('Meditation');
    final reading = await install('Reading');
    await start75(meditation);

    expect((await only()).progress.progress, 0);

    await record(meditation, LocalDate(2026, 9, 21));
    await record(reading, LocalDate(2026, 9, 22));

    final view = await only();
    expect(view.progress.progress, 1);
    expect(view.progress.currentStreak, 1);
    expect(view.progress.today, ChallengeToday.atRisk);

    await record(meditation, LocalDate(2026, 9, 22));
    expect((await only()).progress.today, ChallengeToday.done);
  });

  test('the owner\'s example: 20 days, one missed, the next day done → '
      'progress 21, current streak 1, best streak 20', () async {
    final meditation = await install('Meditation');
    await start75(meditation);
    for (var i = 0; i < 20; i++) {
      await record(meditation, start.addDays(i)); // Sep 1–20
    }
    // Sep 21 missed; Sep 22 (today) done.
    await record(meditation, LocalDate(2026, 9, 22));

    final p = (await only()).progress;
    expect(p.progress, 21);
    expect(p.currentStreak, 1);
    expect(p.bestStreak, 20);
    expect(p.daysLeft, 54);
  });

  test('records before the start day don\'t count', () async {
    final meditation = await install('Meditation');
    await record(meditation, LocalDate(2026, 8, 30));
    await start75(meditation, from: LocalDate(2026, 9, 20));
    await record(meditation, LocalDate(2026, 9, 20));

    expect((await only()).progress.progress, 1);
  });

  test('a record with nothing in it doesn\'t count; notes, or the item '
      'marked done, do', () async {
    final meditation = await install('Meditation');
    await start75(meditation);

    // An item opened and left empty (saved while filling in, ADR-035).
    await logActivity(
      meditation,
      ActivityLogDraft(
        startedAt: DateTime.utc(2026, 9, 20, 9),
        values: const {},
      ),
    );
    expect((await only()).progress.progress, 0);

    await logActivity(
      meditation,
      ActivityLogDraft(
        startedAt: DateTime.utc(2026, 9, 21, 9),
        notes: 'Quiet one',
        values: const {},
      ),
    );
    final planId = await CreatePlan(plans, types, ids, clock)(
      PlanDraft(
        planDate: LocalDate(2026, 9, 22),
        title: 'Meditation',
        activityTypeId: meditation,
      ),
    );
    await SetPlanStatus(plans, clock)(planId, PlanStatus.completed);
    // The plan is marked done but has no record of its own: the item itself
    // counts only through a record it is linked to.
    await logActivity(
      meditation,
      ActivityLogDraft(
        startedAt: DateTime.utc(2026, 9, 22, 9),
        planId: planId,
        values: const {},
      ),
    );

    expect((await only()).progress.progress, 2);
  });

  test(
    'deleting a record takes the day back; restoring puts it back',
    () async {
      final meditation = await install('Meditation');
      await start75(meditation);
      await record(meditation, LocalDate(2026, 9, 21));
      final today = await record(meditation, LocalDate(2026, 9, 22));
      expect((await only()).progress.currentStreak, 2);

      await DeleteActivityLog(logs)(today);
      expect((await only()).progress.progress, 1);
      expect((await only()).progress.today, ChallengeToday.atRisk);

      await RestoreActivityLog(logs)(today);
      expect((await only()).progress.progress, 2);
    },
  );

  test('the view updates as soon as a record is made', () async {
    final meditation = await install('Meditation');
    await start75(meditation);
    final seen = <int>[];
    final sub = watch().listen((v) => seen.add(v.single.progress.progress));
    addTearDown(sub.cancel);
    await pumpEventQueue(times: 50);
    expect(seen, isNotEmpty);
    expect(seen.last, 0);

    await record(meditation, LocalDate(2026, 9, 22));
    await pumpEventQueue(times: 50);

    expect(seen.last, 1);
  });

  test('reaching the target completes it; completed ones sort last', () async {
    final meditation = await install('Meditation');
    final reading = await install('Reading');
    final short = await createChallenge(
      ChallengeDraft(
        activityTypeId: meditation,
        title: '3 days of Meditation',
        startDate: LocalDate(2026, 9, 20),
        targetDays: 3,
      ),
    );
    await start75(reading);
    for (var i = 0; i < 3; i++) {
      await record(meditation, LocalDate(2026, 9, 20).addDays(i));
    }

    final views = await watch().first;
    expect(views.map((v) => v.challenge.title), [
      '75 days of Meditation',
      '3 days of Meditation',
    ]);
    final done = views.last;
    expect(done.challenge.id, short);
    expect(done.progress.isCompleted, isTrue);
    expect(done.progress.completedOn, LocalDate(2026, 9, 22));
  });

  group('creating and changing', () {
    test('needs a live activity, a name, 1–1000 days and a start that '
        'isn\'t in the future', () async {
      final meditation = await install('Meditation');
      Future<void> create({
        ActivityTypeId? type,
        String title = 'Streak',
        int days = 30,
        LocalDate? from,
      }) async {
        await createChallenge(
          ChallengeDraft(
            activityTypeId: type ?? meditation,
            title: title,
            startDate: from ?? start,
            targetDays: days,
          ),
        );
      }

      Matcher issue(ValidationCode code) => throwsA(
        isA<ValidationException>().having(
          (e) => e.issues.map((i) => i.code),
          'codes',
          contains(code),
        ),
      );

      await expectLater(
        create(type: const ActivityTypeId('nope')),
        issue(ValidationCode.required),
      );
      await expectLater(
        create(title: '  '),
        issue(ValidationCode.nameRequired),
      );
      await expectLater(
        create(title: 'x' * 61),
        issue(ValidationCode.nameTooLong),
      );
      await expectLater(
        create(days: 0),
        issue(ValidationCode.invalidChallengeTarget),
      );
      await expectLater(
        create(days: 1001),
        issue(ValidationCode.invalidChallengeTarget),
      );
      await expectLater(
        create(from: LocalDate(2026, 9, 23)),
        issue(ValidationCode.challengeStartInFuture),
      );
      await create(days: 1000, from: LocalDate(2026, 9, 22));
      expect(await watch().first, hasLength(1));
    });

    test('an archived activity can\'t get a challenge', () async {
      final meditation = await install('Meditation');
      await DeleteActivityType(types)(meditation);

      await expectLater(
        createChallenge(
          ChallengeDraft(
            activityTypeId: meditation,
            title: 'Streak',
            startDate: start,
            targetDays: 7,
          ),
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('rename and change the days; the activity and start stay', () async {
      final meditation = await install('Meditation');
      final id = await start75(meditation);

      await UpdateChallenge(challenges, clock)(
        id,
        title: '  21 days of calm ',
        targetDays: 21,
      );

      final c = (await only()).challenge;
      expect(c.title, '21 days of calm');
      expect(c.targetDays, 21);
      expect(c.startDate, start);
      expect(c.activityTypeId, meditation);
      await expectLater(
        UpdateChallenge(challenges, clock)(id, title: 'x', targetDays: 0),
        throwsA(isA<ValidationException>()),
      );
    });

    test('restarting counts from today and Undo puts the start back', () async {
      final meditation = await install('Meditation');
      final id = await start75(meditation);
      for (var i = 0; i < 5; i++) {
        await record(meditation, start.addDays(i));
      }
      expect((await only()).progress.progress, 5);

      final previous = await RestartChallenge(challenges, clock)(id);
      expect(previous, start);
      expect((await only()).challenge.startDate, LocalDate(2026, 9, 22));
      expect((await only()).progress.progress, 0);

      await SetChallengeStart(challenges, clock)(id, previous);
      expect((await only()).progress.progress, 5);
    });

    test(
      'ending hides it, keeps the records, and Undo brings it back',
      () async {
        final meditation = await install('Meditation');
        final id = await start75(meditation);
        await record(meditation, LocalDate(2026, 9, 22));

        await EndChallenge(challenges)(id);
        expect(await watch().first, isEmpty);
        expect(await challenges.getChallenge(id), isNull);
        expect((await logs.recentLogsForType(meditation)), hasLength(1));

        await RestoreChallenge(challenges)(id);
        expect((await only()).progress.progress, 1);
      },
    );

    test(
      'a challenge sees the day by the device\'s local date (ADR-013)',
      () async {
        clock.offset = const Duration(hours: 5, minutes: 30);
        final meditation = await install('Meditation');
        await start75(meditation, from: LocalDate(2026, 9, 22));
        // 21:00 UTC on Sep 22 is 02:30 on Sep 23 locally: that's Sep 23.
        await logActivity(
          meditation,
          ActivityLogDraft(
            startedAt: DateTime.utc(2026, 9, 22, 21),
            durationMs: 60000,
            values: const {},
          ),
        );
        clock.advance(const Duration(hours: 6)); // now Sep 23 local

        final p = (await only()).progress;
        expect(p.doneToday, isTrue);
        expect(p.progress, 1);
      },
    );
  });
}
