import 'package:flutter/material.dart';
import 'package:daylog/features/focus/presentation/focus_screen.dart';
import 'package:daylog/features/plans/presentation/item/item_screen.dart';
import 'package:daylog/features/settings/domain/preferences_snapshot.dart';
import 'package:daylog/core/design/themes/app_theme_id.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';
import '../../support/test_app.dart';
import '../activity_types/presentation/activities_flow_test.dart'
    show enterField;
import '../plans/presentation/plans_flow_test.dart'
    show closeItem, openItem, seedReadingPlan, waitForSave;

const _onboarded = PreferencesSnapshot(
  theme: AppThemeId.lavender,
  onboardingCompleted: true,
);

/// The timer lives in the item (ADR-035): start it, keep logging while it
/// runs, finish → the item has its time and everything logged.
void main() {
  testAppWidgets('an item is timed while you log into it; finishing fills '
      'its time', (tester) async {
    late FakeClock clock;
    await pumpTestApp(
      tester,
      preferences: _onboarded,
      seed: (db, c) async {
        clock = c;
        await seedReadingPlan(db, c);
      },
    );

    await openItem(tester, find.text('Read'));
    await tester.tap(find.text('Start timer'));
    await tester.pumpAndSettle();
    expect(find.text('00:00'), findsOneWidget);

    await enterField(tester, 'Book *', 'Fooled by Randomness');
    await waitForSave(tester);
    clock.advance(const Duration(minutes: 42));
    // Back to the top of the item, where the timer is.
    await tester.fling(
      find.byType(Scrollable).hitTestable().first,
      const Offset(0, 2000),
      2000,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();

    expect(find.text('Read session complete · 42 min'), findsOneWidget);
    expect(find.text('Fooled by Randomness'), findsOneWidget, reason: 'kept');
    expect(find.text('Done'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Minutes'),
      200,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    expect(
      find.widgetWithText(TextField, '42'),
      findsOneWidget,
      reason: 'the timed length fills the duration (A11)',
    );

    await closeItem(tester);
    // Finishing the timer finished the item (ADR-040).
    expect(find.textContaining('42 min of 1h 0m'), findsOneWidget);
    expect(find.byTooltip('Mark as not done'), findsOneWidget);
  });

  testAppWidgets('a running timer shows on Today; Return goes back to its '
      'item, which can open it full screen', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded, seed: seedReadingPlan);
    await openItem(tester, find.text('Read'));
    await tester.tap(find.text('Start timer'));
    await tester.pumpAndSettle();
    await closeItem(tester);

    expect(find.text('Return'), findsOneWidget);
    expect(find.textContaining('In progress'), findsOneWidget);
    await tester.tap(find.text('Return'));
    await tester.pumpAndSettle();
    expect(find.byType(ItemScreen), findsOneWidget);

    await tester.tap(find.byTooltip('Full screen timer'));
    await tester.pumpAndSettle();
    expect(find.byType(FocusScreen), findsOneWidget);
  });
}
