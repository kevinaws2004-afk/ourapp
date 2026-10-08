import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/logging/app_logger.dart';
import 'package:daylog/core/time/local_date.dart';
import 'package:daylog/features/activity_logs/data/db_activity_log_repository.dart';
import 'package:daylog/features/activity_logs/domain/activity_log.dart';
import 'package:daylog/features/activity_logs/domain/activity_log_use_cases.dart';
import 'package:daylog/features/activity_types/data/db_activity_type_repository.dart';
import 'package:daylog/features/activity_types/domain/activity_type_definition.dart';
import 'package:daylog/features/activity_types/domain/activity_type_use_cases.dart';
import 'package:daylog/features/challenges/data/db_challenge_repository.dart';
import 'package:daylog/features/challenges/domain/challenge.dart';
import 'package:daylog/features/challenges/domain/challenge_use_cases.dart';
import 'package:daylog/features/challenges/presentation/challenge_card.dart';
import 'package:daylog/features/challenges/presentation/challenge_screen.dart';
import 'package:daylog/features/challenges/presentation/today_challenges.dart';
import 'package:daylog/features/plans/data/db_plan_repository.dart';
import 'package:daylog/features/settings/domain/preferences_snapshot.dart';
import 'package:daylog/core/design/themes/app_theme_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';
import '../../support/fixtures.dart';
import '../../support/test_app.dart';
import '../activity_types/presentation/activities_flow_test.dart'
    show scrollAndTap;

const _onboarded = PreferencesSnapshot(
  theme: AppThemeId.lavender,
  onboardingCompleted: true,
);

/// The test app's "today": Oct 3, 2026.
final _today = LocalDate(2026, 10, 3);

/// Seeds a Meditation activity and a 75-day challenge starting [start] with
/// the activity done on [done].
Future<void> Function(AppDatabase, FakeClock) seedChallenge({
  required LocalDate start,
  required Iterable<LocalDate> done,
  int target = 75,
}) => (db, clock) async {
  final ids = SequentialIdGenerator();
  final types = DbActivityTypeRepository(db, clock);
  final logs = DbActivityLogRepository(db, clock, const AppLogger());
  final meditation = await CreateActivityType(types, ids)(
    const ActivityTypeDefinition(
      name: 'Meditation',
      iconId: 'flower-lotus',
      colorKey: 'teal',
      supportsTimer: true,
      fields: [],
    ),
  );
  for (final day in done) {
    await LogActivity(types, logs, DbPlanRepository(db, clock), ids, clock)(
      meditation,
      ActivityLogDraft(
        startedAt: DateTime.utc(day.year, day.month, day.day, 7),
        durationMs: 600000,
        values: const {},
      ),
    );
  }
  await CreateChallenge(DbChallengeRepository(db, clock), types, ids, clock)(
    ChallengeDraft(
      activityTypeId: meditation,
      title: '$target days of Meditation',
      startDate: start,
      targetDays: target,
    ),
  );
};

List<LocalDate> run(LocalDate from, int count) => [
  for (var i = 0; i < count; i++) from.addDays(i),
];

Future<void> openTab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label)),
  );
  await tester.pumpAndSettle();
}

Future<void> openChallenges(WidgetTester tester) =>
    openTab(tester, 'Challenges');

/// Records Meditation today, straight through the repositories (the way an
/// item would), then lets the app notice.
Future<void> recordToday(WidgetTester tester, AppDatabase db) async {
  await tester.runAsync(() async {
    final clock = FakeClock(DateTime.utc(2026, 10, 3, 8));
    final types = DbActivityTypeRepository(db, clock);
    final id = (await types.getActiveTypes()).single.id;
    await LogActivity(
      types,
      DbActivityLogRepository(db, clock, const AppLogger()),
      DbPlanRepository(db, clock),
      SequentialIdGenerator(),
      clock,
    )(
      id,
      ActivityLogDraft(
        startedAt: DateTime.utc(2026, 10, 3, 8),
        durationMs: 600000,
        values: const {},
      ),
    );
  });
  await tester.pumpAndSettle();
}

void main() {
  testAppWidgets('with no challenge, Today shows no section and the '
      'Challenges tab invites starting one', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded);
    expect(find.byType(TodayChallenges), findsOneWidget);
    expect(find.text('Not yet today'), findsNothing);
    expect(find.byType(ChallengeCard), findsNothing);

    await openChallenges(tester);

    expect(find.text('No challenges yet'), findsOneWidget);
    expect(find.text('New challenge'), findsOneWidget);
  });

  testAppWidgets('Today shows a running challenge with its progress and '
      'streak, at risk until today is recorded, then done', (tester) async {
    final db = await pumpTestApp(
      tester,
      preferences: _onboarded,
      seed: seedChallenge(
        start: _today.addDays(-12),
        done: run(_today.addDays(-12), 12), // Sep 21 – Oct 2
      ),
    );

    await tester.scrollUntilVisible(
      find.byType(ChallengeCard),
      200,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    expect(find.text('75 days of Meditation'), findsOneWidget);
    expect(find.text('12 / 75 days · 12-day streak'), findsOneWidget);
    expect(find.text('Not yet today — streak at risk'), findsOneWidget);

    // Recording the activity counts the day, with nothing else to press.
    await recordToday(tester, db);
    expect(find.text('13 / 75 days · 13-day streak'), findsOneWidget);
    expect(find.text('Done today'), findsOneWidget);
    expect(find.text('Not yet today — streak at risk'), findsNothing);
  });

  testAppWidgets('after a missed day only the streak resets (progress stays) '
      'and nothing is at risk', (tester) async {
    await pumpTestApp(
      tester,
      preferences: _onboarded,
      seed: seedChallenge(
        start: _today.addDays(-10),
        done: run(_today.addDays(-10), 5), // Sep 23–27, then missed
      ),
    );

    await tester.scrollUntilVisible(
      find.byType(ChallengeCard),
      200,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    expect(find.text('5 / 75 days'), findsOneWidget);
    expect(find.text('Not yet today'), findsOneWidget);
  });

  testAppWidgets('the detail shows progress and streaks apart: 20 days, '
      'one missed, the next day → 21 / 75, streak 1, best 20', (tester) async {
    await pumpTestApp(
      tester,
      preferences: _onboarded,
      seed: seedChallenge(
        start: _today.addDays(-21), // Sep 12
        done: [
          ...run(_today.addDays(-21), 20),
          _today,
        ], // Sep 12 – Oct 1, Oct 3
      ),
    );
    await openChallenges(tester);
    await tester.tap(find.text('75 days of Meditation'));
    await tester.pumpAndSettle();

    expect(find.byType(ChallengeScreen), findsOneWidget);
    expect(find.text('21 / 75'), findsOneWidget);
    expect(find.text('Done today'), findsOneWidget);
    Finder stat(String label, String value) => find.descendant(
      of: find
          .ancestor(of: find.text(label), matching: find.byType(DecoratedBox))
          .first,
      matching: find.text(value),
    );
    expect(stat('Current streak', '1 day'), findsOneWidget);
    expect(stat('Best streak', '20 days'), findsOneWidget);
    expect(stat('Days done', '21 days'), findsOneWidget);
    expect(stat('Days left', '54 days'), findsOneWidget);
    expect(find.text('Your days'), findsOneWidget);
  });

  testAppWidgets('starting a challenge: choose an activity, the days, and '
      'it is listed', (tester) async {
    await pumpTestApp(
      tester,
      preferences: _onboarded,
      seed: (db, clock) async =>
          seedChallenge(start: _today, done: const [])(db, clock).then(
            (_) => DbChallengeRepository(db, clock).softDelete(
              // Keep the Meditation activity, drop the seeded challenge.
              const ChallengeId('00000000-0000-7000-8000-000000000002'),
            ),
          ),
    );
    await openChallenges(tester);
    expect(find.text('No challenges yet'), findsOneWidget);

    await tester.tap(find.text('New challenge'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Browse activities'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Meditation'));
    await tester.pumpAndSettle();
    // The chosen activity, then the days.
    expect(find.text('Recording it each day counts the day.'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, '21'));
    await tester.pumpAndSettle();
    await scrollAndTap(tester, find.text('Start challenge'));

    expect(find.text('21 days of Meditation'), findsOneWidget);
    expect(find.text('0 / 21 days'), findsOneWidget);
    expect(find.text('Not yet today'), findsOneWidget);
  });

  testAppWidgets('a challenge needs an activity', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded);
    await openChallenges(tester);

    await tester.tap(find.text('New challenge'));
    await tester.pumpAndSettle();
    await scrollAndTap(tester, find.text('Start challenge'));

    expect(find.text('This is required.'), findsWidgets);
    expect(find.text('New challenge'), findsWidgets, reason: 'sheet stays');
  });

  group('on the detail screen', () {
    Future<AppDatabase> openDetail(WidgetTester tester) async {
      final db = await pumpTestApp(
        tester,
        preferences: _onboarded,
        seed: seedChallenge(
          start: _today.addDays(-5),
          done: run(_today.addDays(-5), 5),
        ),
      );
      await openChallenges(tester);
      await tester.tap(find.text('75 days of Meditation'));
      await tester.pumpAndSettle();
      return db;
    }

    Future<void> menu(WidgetTester tester, String item) async {
      await tester.tap(find.byTooltip('Challenge options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(item));
      await tester.pumpAndSettle();
    }

    testAppWidgets('Edit renames it and changes the days', (tester) async {
      await openDetail(tester);

      await menu(tester, 'Edit');
      await tester.enterText(find.widgetWithText(TextField, '75'), '21');
      await tester.enterText(
        find.widgetWithText(TextField, '75 days of Meditation'),
        'Calm for three weeks',
      );
      await scrollAndTap(tester, find.text('Save'));

      expect(find.text('Calm for three weeks'), findsOneWidget);
      expect(find.text('5 / 21'), findsOneWidget);
    });

    testAppWidgets('Restart counts from today, and Undo puts it back', (
      tester,
    ) async {
      await openDetail(tester);
      expect(find.text('5 / 75'), findsOneWidget);

      await menu(tester, 'Restart from today');
      expect(find.text('0 / 75'), findsOneWidget);
      expect(find.text('Counting from today'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.text('5 / 75'), findsOneWidget);
    });

    testAppWidgets('End challenge leaves, keeps the records, and Undo '
        'brings it back', (tester) async {
      await openDetail(tester);

      await menu(tester, 'End challenge');
      expect(find.byType(ChallengeScreen), findsNothing);
      expect(find.text('Challenge ended'), findsOneWidget);
      expect(find.text('75 days of Meditation'), findsNothing);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.text('75 days of Meditation'), findsOneWidget);
    });
  });

  testAppWidgets('a completed challenge leaves Today and stays listed under '
      'Me as Completed', (tester) async {
    await pumpTestApp(
      tester,
      preferences: _onboarded,
      seed: seedChallenge(
        start: _today.addDays(-2),
        done: run(_today.addDays(-2), 3),
        target: 3,
      ),
    );
    expect(find.byType(ChallengeCard), findsNothing, reason: 'nothing running');

    await openChallenges(tester);

    expect(find.text('3 days of Meditation'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('3 / 3 days · 3-day streak'), findsOneWidget);
  });
}
