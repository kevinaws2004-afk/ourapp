import 'package:flutter/material.dart';
import 'package:daylog/features/focus/presentation/focus_screen.dart';
import 'package:daylog/features/plans/presentation/item/item_screen.dart';
import 'package:daylog/features/settings/domain/preferences_snapshot.dart';
import 'package:daylog/features/today/presentation/now_next_card.dart';
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
/// runs, Finish → back where it was opened, done with its time and
/// everything logged (ADR-046).
void main() {
  testAppWidgets('an item is timed while you log into it; Finish returns to '
      'the day after "How did it go?", the row shows the result, and the '
      'done item (A7) has its time', (tester) async {
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
    await tester.tap(find.text('Start'));
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

    expect(find.text('How did it go?'), findsOneWidget);
    expect(find.text('Read · 42 min'), findsOneWidget, reason: 'subtitle');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.byType(ItemScreen), findsNothing, reason: 'back to Today');
    expect(find.text('Read done'), findsOneWidget, reason: 'snackbar');
    expect(find.byTooltip('Mark as not done'), findsOneWidget);
    expect(
      find.text('Fooled by Randomness'),
      findsOneWidget,
      reason: 'its result on the row',
    );

    await openItem(tester, find.text('Read'));
    expect(find.text('Not done'), findsOneWidget, reason: 'A7');
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
  });

  testAppWidgets('a running timer is the Running card on Today; tapping it '
      'goes back to its item, which can open it full screen', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded, seed: seedReadingPlan);
    await openItem(tester, find.text('Read'));
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    await closeItem(tester);

    final card = find.byType(NowNextCard);
    expect(
      find.descendant(of: card, matching: find.text('RUNNING')),
      findsOneWidget,
    );
    expect(find.descendant(of: card, matching: find.text('Finish')), findsOne);
    expect(find.textContaining('Running · '), findsOneWidget, reason: 'row');
    await tester.tap(find.descendant(of: card, matching: find.text('Read')));
    await tester.pumpAndSettle();
    expect(find.byType(ItemScreen), findsOneWidget);

    await tester.tap(find.byTooltip('Full screen timer'));
    await tester.pumpAndSettle();
    expect(find.byType(FocusScreen), findsOneWidget);
  });
}
