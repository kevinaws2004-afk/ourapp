import 'package:daylog/app/dev/token_showcase_screen.dart';
import 'package:daylog/core/logging/app_logger.dart';
import 'package:daylog/features/onboarding/presentation/onboarding_screen.dart';
import 'package:daylog/features/plans/presentation/plan_screen.dart';
import 'package:daylog/features/settings/data/db_app_preferences_repository.dart';
import 'package:daylog/features/settings/domain/preferences_snapshot.dart';
import 'package:daylog/features/settings/domain/theme_preference.dart';
import 'package:daylog/features/today/presentation/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_clock.dart';
import '../support/test_app.dart';

const _onboarded = PreferencesSnapshot(
  themePreference: ThemePreference.system,
  onboardingCompleted: true,
);

void main() {
  group('onboarding redirect', () {
    testAppWidgets(
      'a fresh install opens onboarding, and finishing it lands on Today',
      (tester) async {
        await pumpTestApp(tester);

        expect(find.byType(OnboardingScreen), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);

        await tester.tap(find.text('Get started'));
        await tester.pumpAndSettle();

        expect(find.byType(TodayScreen), findsOneWidget);
        expect(find.byType(OnboardingScreen), findsNothing);
      },
    );

    testAppWidgets('a returning user opens directly on Today', (tester) async {
      await pumpTestApp(tester, preferences: _onboarded);

      expect(find.byType(TodayScreen), findsOneWidget);
    });
  });

  group('adaptive shell', () {
    testAppWidgets(
      'compact windows use a bottom navigation bar with the four tabs and no Track tab',
      (tester) async {
        await pumpTestApp(tester, preferences: _onboarded);

        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.byType(NavigationRail), findsNothing);
        expect(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Track'),
          ),
          findsNothing,
        );
        for (final label in ['Today', 'Plan', 'Challenges', 'Insights', 'Me']) {
          expect(
            find.descendant(
              of: find.byType(NavigationBar),
              matching: find.text(label),
            ),
            findsOneWidget,
          );
        }
      },
    );

    testAppWidgets('expanded windows use a navigation rail', (tester) async {
      await pumpTestApp(
        tester,
        size: const Size(1280, 800),
        preferences: _onboarded,
      );

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testAppWidgets('selecting a tab shows its screen', (tester) async {
      await pumpTestApp(tester, preferences: _onboarded);

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Plan'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PlanScreen), findsOneWidget);
    });
  });

  group('theme', () {
    testAppWidgets(
      'a saved dark preference switches the app to the dark theme',
      (tester) async {
        final db = await pumpTestApp(tester, preferences: _onboarded);
        expect(
          Theme.of(tester.element(find.byType(TodayScreen))).brightness,
          Brightness.light,
        );

        await DbAppPreferencesRepository(
          db,
          FakeClock(DateTime.utc(2026, 10, 3)),
          const AppLogger(),
        ).setThemePreference(ThemePreference.dark);
        await tester.pumpAndSettle();

        expect(
          Theme.of(tester.element(find.byType(TodayScreen))).brightness,
          Brightness.dark,
        );
      },
    );
  });

  group('token showcase (debug)', () {
    testAppWidgets('opens from Me and switches the theme from its control', (
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
      await tester.tap(find.text('Design tokens'));
      await tester.pumpAndSettle();

      expect(find.byType(TokenShowcaseScreen), findsOneWidget);

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(
        Theme.of(tester.element(find.byType(TokenShowcaseScreen))).brightness,
        Brightness.dark,
      );
    });

    for (final preference in [ThemePreference.light, ThemePreference.dark]) {
      testAppWidgets(
        'renders every section without layout errors (${preference.name})',
        (tester) async {
          await pumpTestApp(
            tester,
            preferences: PreferencesSnapshot(
              themePreference: preference,
              onboardingCompleted: true,
            ),
          );
          await tester.tap(
            find.descendant(
              of: find.byType(NavigationBar),
              matching: find.text('Me'),
            ),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text('Design tokens'));
          await tester.pumpAndSettle();

          await tester.scrollUntilVisible(
            find.text('Show onboarding again'),
            400,
          );

          expect(tester.takeException(), isNull);
        },
      );
    }
  });

  group('text scaling (200%)', () {
    testAppWidgets('onboarding and the shell lay out without overflow', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpTestApp(tester, size: const Size(360, 780));
      expect(tester.takeException(), isNull);

      await tester.ensureVisible(find.text('Get started'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();

      expect(find.byType(TodayScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  testAppWidgets(
    'localized strings and the temporary display name come from ARB files',
    (tester) async {
      await pumpTestApp(tester, preferences: _onboarded);

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(
        app.onGenerateTitle!(tester.element(find.byType(TodayScreen))),
        'OurApp',
      );
      expect(find.text('Add an activity to this day'), findsOneWidget);
    },
  );
}
