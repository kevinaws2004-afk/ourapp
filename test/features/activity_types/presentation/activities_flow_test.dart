import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/features/activity_types/data/db_activity_type_repository.dart';
import 'package:daylog/features/activity_types/domain/activity_type_use_cases.dart';
import 'package:daylog/features/activity_logs/presentation/form/field_editor_shell.dart';
import 'package:daylog/features/activity_types/presentation/activity_type_screen.dart';
import 'package:daylog/features/settings/domain/preferences_snapshot.dart';
import 'package:daylog/features/plans/presentation/item/item_screen.dart';
import 'package:daylog/core/design/themes/app_theme_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_clock.dart';
import '../../../support/fixtures.dart';
import '../../../support/test_app.dart';
import '../../plans/presentation/plans_flow_test.dart'
    show closeItem, waitForSave;

const _onboarded = PreferencesSnapshot(
  theme: AppThemeId.lavender,
  onboardingCompleted: true,
);

/// Me → Activities (ADR-028).
Future<void> openActivities(WidgetTester tester) async {
  await tester.tap(
    find.descendant(of: find.byType(NavigationBar), matching: find.text('Me')),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Activities'));
  await tester.pumpAndSettle();
}

/// Finds an activity in the list of activities by searching for [query],
/// then taps [name] (a built-in one opens its preview).
Future<void> findActivity(
  WidgetTester tester,
  String query,
  String name,
) async {
  await tester.enterText(
    find.widgetWithText(TextField, 'Search activities'),
    query,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text(name));
  await tester.pumpAndSettle();
}

Future<void> scrollAndTap(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).hitTestable().first,
  );
  // Fully in view, not just peeking at the edge.
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Types into the text input of the field labelled [label].
Future<void> enterField(WidgetTester tester, String label, String text) async {
  final input = find.descendant(
    of: find.widgetWithText(FieldEditorShell, label),
    matching: find.byType(TextField),
  );
  await tester.scrollUntilVisible(
    input,
    -200,
    scrollable: find.byType(Scrollable).hitTestable().first,
  );
  await tester.enterText(input, text);
  await tester.pumpAndSettle();
}

Future<void> seedReading(AppDatabase db, FakeClock clock) async {
  await CreateActivityType(
    DbActivityTypeRepository(db, clock),
    SequentialIdGenerator(),
  )(readingDefinition());
}

void main() {
  testAppWidgets('Activities is one list: New activity, then the built-in '
      'activities by category (nothing of yours yet, so no "Yours")', (
    tester,
  ) async {
    await pumpTestApp(tester, preferences: _onboarded);
    await openActivities(tester);

    expect(find.text('New activity'), findsOneWidget);
    expect(find.text('Sleep & self-care'), findsOneWidget, reason: 'heading');
    expect(find.text('Yours'), findsNothing);
    expect(find.textContaining('emplate'), findsNothing, reason: 'one word');
  });

  testAppWidgets('the list is searchable by name, category or what an '
      'activity logs', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded, seed: seedReading);
    await openActivities(tester);
    expect(find.text('Yours'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Search activities'),
      'systolic',
    );
    await tester.pumpAndSettle();
    expect(find.text('Blood pressure'), findsOneWidget);
    expect(find.text('Health'), findsOneWidget, reason: 'its category');
    expect(find.text('Gym'), findsNothing);

    await tester.enterText(
      find.widgetWithText(TextField, 'Search activities'),
      'pages',
    );
    await tester.pumpAndSettle();
    expect(find.text('Yours'), findsOneWidget, reason: 'your Reading logs it');
    expect(find.text('Reading'), findsOneWidget, reason: 'listed once');

    await tester.enterText(
      find.widgetWithText(TextField, 'Search activities'),
      'zzzz',
    );
    await tester.pumpAndSettle();
    expect(
      find.text('No activity matches. Make your own instead.'),
      findsOneWidget,
    );
  });

  testAppWidgets('using a built-in activity opens it; it then sits under '
      '"Yours" like any other', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded);
    await openActivities(tester);

    await findActivity(tester, 'walk', 'Walking');
    // The preview shows the real form before using it (B8).
    expect(find.text("What you'll log"), findsOneWidget);
    expect(find.text('Distance'), findsOneWidget);
    await scrollAndTap(tester, find.text('Use Walking'));

    expect(find.byType(ActivityTypeScreen), findsOneWidget);
    expect(
      find.text('Nothing recorded yet. Record it to start this history.'),
      findsOneWidget,
    );

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Yours'), findsOneWidget);
    expect(find.text('Walking'), findsOneWidget, reason: 'listed once');
    expect(find.text('Record'), findsOneWidget);
  });

  testAppWidgets('an activity of yours replaces the built-in one with its '
      'name, so each name appears once (A8)', (tester) async {
    await pumpTestApp(
      tester,
      preferences: _onboarded,
      seed: (db, clock) => CreateActivityType(
        DbActivityTypeRepository(db, clock),
        SequentialIdGenerator(),
      )(walkingDefinition()),
    );
    await openActivities(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'Search activities'),
      'walk',
    );
    await tester.pumpAndSettle();
    expect(find.text('Walking'), findsOneWidget);
    await tester.tap(find.text('Walking'));
    await tester.pumpAndSettle();
    expect(find.byType(ActivityTypeScreen), findsOneWidget, reason: 'yours');
  });

  testAppWidgets('building an activity with a field saves it and opens it', (
    tester,
  ) async {
    await pumpTestApp(tester, preferences: _onboarded);
    await openActivities(tester);

    await tester.tap(find.text('New activity'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name'),
      'Meditation',
    );
    await tester.pumpAndSettle();

    await scrollAndTap(tester, find.text('Add field'));
    await tester.tap(find.text('A rating'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Field name'),
      'Calm',
    );
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(
      find.text('Calm'),
      findsWidgets,
      reason: 'field listed and previewed',
    );

    await scrollAndTap(tester, find.widgetWithText(FilledButton, 'Save'));

    expect(find.byType(ActivityTypeScreen), findsOneWidget);
    expect(find.text('Meditation'), findsOneWidget);
  });

  testAppWidgets('the editor asks what you record before how it looks; it '
      'suggests 12 icons with named ones for screen readers (A25, A27)', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpTestApp(tester, preferences: _onboarded);
    await openActivities(tester);
    await tester.tap(find.text('New activity'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('More icons'),
      200,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    expect(
      tester.getTopLeft(find.text('Add field')).dy,
      lessThan(tester.getTopLeft(find.text('Icon')).dy),
      reason: 'what you record comes first',
    );
    expect(find.bySemanticsLabel('Walking'), findsOneWidget);
    expect(find.bySemanticsLabel('person-simple-walk'), findsNothing);
    expect(find.bySemanticsLabel('Hiking'), findsNothing, reason: 'not in 12');

    await scrollAndTap(tester, find.text('More icons'));
    expect(find.bySemanticsLabel('Hiking'), findsOneWidget);
    expect(find.text('Fewer icons'), findsOneWidget);
    semantics.dispose();
  });

  testAppWidgets('saving an activity without a name shows the issue inline', (
    tester,
  ) async {
    await pumpTestApp(tester, preferences: _onboarded);
    await openActivities(tester);

    await tester.tap(find.text('New activity'));
    await tester.pumpAndSettle();
    await scrollAndTap(tester, find.widgetWithText(FilledButton, 'Save'));

    await tester.scrollUntilVisible(
      find.text('Please enter a name.'),
      -200,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    expect(find.text('Please enter a name.'), findsOneWidget);
  });

  testAppWidgets(
    'recording an activity opens an item for now; what you log shows in its '
    'recent records',
    (tester) async {
      await pumpTestApp(tester, preferences: _onboarded, seed: seedReading);
      await openActivities(tester);

      await tester.tap(find.text('Reading'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Record'));
      await tester.pumpAndSettle();
      expect(find.byType(ItemScreen), findsOneWidget);

      await enterField(tester, 'Book *', 'Fooled by Randomness');
      await enterField(tester, 'Pages', '18');
      await closeItem(tester);
      await waitForSave(tester);

      expect(find.byType(ActivityTypeScreen), findsOneWidget);
      expect(find.text('Fooled by Randomness · 18'), findsOneWidget);
    },
  );

  testAppWidgets('deleting an item removes what was logged, and Undo brings '
      'it back', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded, seed: seedReading);
    await openActivities(tester);
    await tester.tap(find.text('Reading'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Record'));
    await tester.pumpAndSettle();
    await enterField(tester, 'Book *', 'Antifragile');
    await closeItem(tester);
    await waitForSave(tester);

    await tester.tap(find.text('Antifragile'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Item options'));
    await tester.pumpAndSettle();
    await scrollAndTap(tester, find.text('Delete'));

    expect(find.text('Antifragile'), findsNothing);
    expect(find.text('Deleted'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Antifragile'), findsOneWidget);
  });
}
