import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/features/activity_types/data/db_activity_type_repository.dart';
import 'package:daylog/features/activity_types/domain/activity_type_use_cases.dart';
import 'package:daylog/features/settings/domain/preferences_snapshot.dart';
import 'package:daylog/core/design/themes/app_theme_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_clock.dart';
import '../support/fixtures.dart';
import '../support/test_app.dart';

const _onboarded = PreferencesSnapshot(
  theme: AppThemeId.lavender,
  onboardingCompleted: true,
);

Future<void> seedReading(AppDatabase db, FakeClock clock) => CreateActivityType(
  DbActivityTypeRepository(db, clock),
  SequentialIdGenerator(),
)(readingDefinition());

void main() {
  testAppWidgets('there is no floating Record button on any tab', (
    tester,
  ) async {
    await pumpTestApp(tester, preferences: _onboarded, seed: seedReading);
    for (final tab in ['Today', 'Plan', 'Challenges', 'Insights', 'Me']) {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(tab),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsNothing, reason: tab);
    }
  });

  testAppWidgets('expanded windows have no Record action in the rail', (
    tester,
  ) async {
    await pumpTestApp(
      tester,
      size: const Size(1280, 800),
      preferences: _onboarded,
    );

    expect(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.byType(FloatingActionButton),
      ),
      findsNothing,
    );
  });

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
        find.text(
          'Everything you can plan and record. Use any of them as it is, '
          'change it, or make your own.',
        ),
        findsOneWidget,
      );
      expect(find.text('Yours'), findsOneWidget);
      expect(find.text('Reading'), findsOneWidget, reason: 'listed once');
    },
  );
}
