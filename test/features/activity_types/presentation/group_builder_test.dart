import 'package:daylog/features/activity_types/presentation/activity_type_screen.dart';
import 'package:daylog/features/settings/domain/preferences_snapshot.dart';
import 'package:daylog/features/settings/domain/theme_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_app.dart';
import 'activities_flow_test.dart' show openActivities, scrollAndTap;

const _onboarded = PreferencesSnapshot(
  themePreference: ThemePreference.light,
  onboardingCompleted: true,
);

void main() {
  testAppWidgets('building a repeating group with a sub-field', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded);
    await openActivities(tester);
    await tester.tap(find.text('New activity'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name'),
      'Climbing',
    );

    await scrollAndTap(tester, find.text('Add field'));
    await tester.dragUntilVisible(
      find.text('List'),
      find.byType(ListView).last,
      const Offset(0, -200),
    );
    await tester.tap(find.text('List'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Field name'),
      'Routes',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Item name'),
      'Route',
    );
    await tester.pumpAndSettle();

    // Sub-fields are added in a nested sheet.
    await scrollAndTap(tester, find.text('Add field to item'));
    await tester.tap(find.text('Number'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Field name').last,
      'Grade',
    );
    await tester.tap(find.text('Done').last);
    await tester.pumpAndSettle();
    expect(find.text('Grade'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Grade'), findsNothing, reason: 'nested sheet closed');
    await tester.scrollUntilVisible(
      find.text('Add Route'),
      200,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    expect(find.text('Add Route'), findsOneWidget, reason: 'live preview');

    await scrollAndTap(tester, find.widgetWithText(FilledButton, 'Save'));
    expect(find.byType(ActivityTypeScreen), findsOneWidget);
    expect(find.text('Climbing'), findsOneWidget);
  });
}
