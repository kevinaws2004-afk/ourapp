import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/design/app_tokens.dart';
import 'package:daylog/core/design/themes/app_theme_id.dart';
import 'package:daylog/core/time/local_date.dart';
import 'package:daylog/features/activity_types/data/db_activity_type_repository.dart';
import 'package:daylog/features/activity_types/domain/activity_type_use_cases.dart';
import 'package:daylog/features/plans/data/db_plan_repository.dart';
import 'package:daylog/features/plans/domain/plan.dart';
import 'package:daylog/features/plans/domain/plan_use_cases.dart';
import 'package:daylog/features/plans/presentation/item/item_screen.dart';
import 'package:daylog/features/settings/domain/preferences_snapshot.dart';
import 'package:daylog/features/settings/presentation/appearance_screen.dart';
import 'package:daylog/features/today/presentation/today_screen.dart';
import 'package:daylog/features/today/presentation/now_next_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';
import '../../support/fixtures.dart';
import '../../support/test_app.dart';
import '../activity_types/presentation/activities_flow_test.dart'
    show scrollAndTap;

/// The first vertical slice of the redesign (ADR-045): Today → open an
/// item → record → done, in every theme, and Me → Appearance.
const _onboarded = PreferencesSnapshot(
  theme: AppThemeId.lavender,
  onboardingCompleted: true,
);

/// Reading at 9:00 today for 30 minutes (the test clock is 08:00).
Future<void> seedReadingAtNine(AppDatabase db, FakeClock clock) async {
  final ids = SequentialIdGenerator();
  final types = DbActivityTypeRepository(db, clock);
  final typeId = await CreateActivityType(types, ids)(readingDefinition());
  await CreatePlan(DbPlanRepository(db, clock), types, ids, clock)(
    PlanDraft(
      planDate: LocalDate(2026, 10, 3),
      title: 'Read',
      activityTypeId: typeId,
      plannedStartAt: DateTime.utc(2026, 10, 3, 9),
      plannedDurationMs: 30 * 60000,
    ),
  );
}

AppThemeId _themeOf(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(Scaffold).first))
        .extension<AppTokens>()!
        .id;

void main() {
  testAppWidgets('Me → Appearance switches the whole app and remembers it', (
    tester,
  ) async {
    await pumpTestApp(tester, preferences: _onboarded);
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Me'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Lavender'), findsOneWidget, reason: 'the theme in use');

    await scrollAndTap(tester, find.text('Appearance'));
    expect(find.byType(AppearanceScreen), findsOneWidget);
    await scrollAndTap(tester, find.text('Papaya'));
    expect(_themeOf(tester), AppThemeId.papaya);
    expect(
      find.bySemanticsLabel(RegExp('^Papaya')),
      findsOneWidget,
      reason: 'each theme is one selectable option',
    );

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Papaya'), findsOneWidget, reason: 'Me shows it');
  });

  testAppWidgets('an empty day says so and offers a way in', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded);
    expect(find.text('Nothing on today yet'), findsOneWidget);
    expect(find.byType(NowNextCard), findsNothing);
  });

  testAppWidgets('Next shows the next thing; Start times it and opens it', (
    tester,
  ) async {
    await pumpTestApp(tester, preferences: _onboarded, seed: seedReadingAtNine);

    final next = find.byType(NowNextCard);
    expect(next, findsOneWidget);
    expect(
      find.descendant(of: next, matching: find.text('in 1h 0m')),
      findsOneWidget,
    );

    await scrollAndTap(
      tester,
      find.descendant(of: next, matching: find.text('Start')),
    );
    expect(find.byType(ItemScreen), findsOneWidget);
    expect(find.text('LIVE'), findsOneWidget);
    expect(find.text('Finish'), findsOneWidget);
  });

  testAppWidgets('Start → Finish → How did it go? → back on Today with the '
      'result on the row (ADR-046)', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded, seed: seedReadingAtNine);
    await scrollAndTap(
      tester,
      find.descendant(
        of: find.byType(NowNextCard),
        matching: find.text('Start'),
      ),
    );
    expect(find.byType(ItemScreen), findsOneWidget);

    await scrollAndTap(tester, find.text('Finish'));
    expect(
      find.text('How did it go?'),
      findsOneWidget,
      reason: 'Reading has meaningful details (pages)',
    );
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.byType(ItemScreen), findsNothing, reason: 'not A7');
    expect(find.byType(TodayScreen), findsOneWidget);
    expect(find.text('All 1 done'), findsOneWidget, reason: 'the status');
  });

  testAppWidgets('Done on an open thing returns to Today; tapping the done '
      'row opens it to inspect (A7)', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded, seed: seedReadingAtNine);
    await scrollAndTap(tester, find.text('Read').last);
    expect(find.byType(ItemScreen), findsOneWidget);
    expect(find.text('Planned'), findsOneWidget);

    await scrollAndTap(tester, find.text('Done').first);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.byType(ItemScreen), findsNothing);

    await scrollAndTap(tester, find.text('Read').last);
    expect(find.byType(ItemScreen), findsOneWidget);
    expect(find.text('Not done'), findsOneWidget, reason: 'A7');
    expect(find.text('1 of 1 done today'), findsOneWidget);
  });

  for (final id in AppThemeId.values) {
    testAppWidgets('Today and an open item lay out in ${id.name} at 200% '
        'text', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpTestApp(
        tester,
        size: const Size(360, 780),
        preferences: PreferencesSnapshot(theme: id, onboardingCompleted: true),
        seed: seedReadingAtNine,
      );
      expect(find.byType(TodayScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      await scrollAndTap(
        tester,
        find.descendant(
          of: find.byType(NowNextCard),
          matching: find.text('Start'),
        ),
      );
      expect(find.byType(ItemScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
