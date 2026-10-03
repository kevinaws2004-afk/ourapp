import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/features/activity_logs/presentation/log_editor_screen.dart';
import 'package:daylog/features/activity_types/data/db_activity_type_repository.dart';
import 'package:daylog/features/activity_types/domain/activity_type_use_cases.dart';
import 'package:daylog/features/activity_types/presentation/builder/activity_builder_screen.dart';
import 'package:daylog/features/settings/domain/preferences_snapshot.dart';
import 'package:daylog/features/settings/domain/theme_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_clock.dart';
import '../support/fixtures.dart';
import '../support/test_app.dart';

const _onboarded = PreferencesSnapshot(
  themePreference: ThemePreference.light,
  onboardingCompleted: true,
);

Future<void> seedReading(AppDatabase db, FakeClock clock) => CreateActivityType(
  DbActivityTypeRepository(db, clock),
  SequentialIdGenerator(),
)(readingDefinition());

void main() {
  testAppWidgets(
    'Quick Record is available on every tab and records an unplanned activity in two taps',
    (tester) async {
      await pumpTestApp(tester, preferences: _onboarded, seed: seedReading);

      for (final tab in ['Today', 'Plan', 'Insights', 'Me']) {
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text(tab),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.widgetWithText(FloatingActionButton, 'Record'),
          findsOneWidget,
          reason: tab,
        );
      }

      await tester.tap(find.widgetWithText(FloatingActionButton, 'Record'));
      await tester.pumpAndSettle();
      expect(find.text('What did you do?'), findsOneWidget);
      await tester.tap(find.text('Reading'));
      await tester.pumpAndSettle();

      expect(find.byType(LogEditorScreen), findsOneWidget);
      expect(find.text('Record Reading'), findsOneWidget);
    },
  );

  testAppWidgets('with no activities, Quick Record offers to create one', (
    tester,
  ) async {
    await pumpTestApp(tester, preferences: _onboarded);

    await tester.tap(find.widgetWithText(FloatingActionButton, 'Record'));
    await tester.pumpAndSettle();
    expect(
      find.text('Create an activity first, then record it here.'),
      findsOneWidget,
    );
    await tester.tap(find.text('New activity'));
    await tester.pumpAndSettle();

    expect(find.byType(ActivityBuilderScreen), findsOneWidget);
  });

  testAppWidgets(
    'expanded windows put the Record action in the navigation rail',
    (tester) async {
      await pumpTestApp(
        tester,
        size: const Size(1280, 800),
        preferences: _onboarded,
      );

      expect(
        find.descendant(
          of: find.byType(NavigationRail),
          matching: find.byTooltip('Record'),
        ),
        findsOneWidget,
      );
    },
  );

  testAppWidgets(
    'Me links to Activities, where reusable activities are managed',
    (tester) async {
      await pumpTestApp(tester, preferences: _onboarded, seed: seedReading);
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Me'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Activities'));
      await tester.pumpAndSettle();

      expect(
        find.text('The reusable activities you plan and record.'),
        findsOneWidget,
      );
      expect(find.text('Reading'), findsOneWidget);
    },
  );
}
