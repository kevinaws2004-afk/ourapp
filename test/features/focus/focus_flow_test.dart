import 'package:daylog/features/activity_logs/presentation/log_editor_screen.dart';
import 'package:daylog/features/focus/presentation/focus_screen.dart';
import 'package:daylog/features/settings/domain/preferences_snapshot.dart';
import 'package:daylog/features/settings/domain/theme_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';
import '../../support/test_app.dart';
import '../activity_types/presentation/activities_flow_test.dart'
    show enterField, scrollAndTap;
import '../plans/presentation/plans_flow_test.dart' show seedReadingPlan;

const _onboarded = PreferencesSnapshot(
  themePreference: ThemePreference.light,
  onboardingCompleted: true,
);

/// F5 + F7: a planned Reading → Start focus → timer → Finish → the record
/// form is prefilled → save → session complete, plan done.
void main() {
  testAppWidgets('a planned activity is timed with focus and recorded on '
      'finish', (tester) async {
    late FakeClock clock;
    await pumpTestApp(
      tester,
      preferences: _onboarded,
      seed: (db, c) async {
        clock = c;
        await seedReadingPlan(db, c);
      },
    );

    await tester.tap(find.text('Read'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start focus'));
    await tester.pumpAndSettle();
    expect(find.byType(FocusScreen), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);

    clock.advance(const Duration(minutes: 42));
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();

    expect(find.byType(LogEditorScreen), findsOneWidget);
    expect(find.textContaining('Planned · Read'), findsOneWidget);
    await enterField(tester, 'Book *', 'Fooled by Randomness');
    await scrollAndTap(tester, find.widgetWithText(FilledButton, 'Save'));

    expect(find.byType(FocusScreen), findsNothing);
    expect(find.text('Reading session complete · 42 min'), findsOneWidget);
    expect(find.textContaining('Recorded 42 min'), findsOneWidget);
  });

  testAppWidgets('a running session shows on Today and can be returned to', (
    tester,
  ) async {
    await pumpTestApp(tester, preferences: _onboarded, seed: seedReadingPlan);
    await tester.tap(find.text('Read'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start focus'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Return'), findsOneWidget);
    expect(find.textContaining('In progress'), findsOneWidget);
    await tester.tap(find.text('Return'));
    await tester.pumpAndSettle();
    expect(find.byType(FocusScreen), findsOneWidget);
  });
}
