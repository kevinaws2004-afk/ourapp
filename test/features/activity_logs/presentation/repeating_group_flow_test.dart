import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/features/activity_logs/presentation/form/field_editor_shell.dart';
import 'package:daylog/features/activity_types/data/db_activity_type_repository.dart';
import 'package:daylog/features/activity_types/domain/activity_type_use_cases.dart';
import 'package:daylog/features/activity_types/presentation/activity_type_screen.dart';
import 'package:daylog/features/plans/presentation/item/item_screen.dart';
import 'package:daylog/features/settings/domain/preferences_snapshot.dart';
import 'package:daylog/features/settings/domain/theme_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_clock.dart';
import '../../../support/fixtures.dart';
import '../../../support/test_app.dart';
import '../../activity_types/presentation/activities_flow_test.dart'
    show enterField, openActivities, scrollAndTap;
import '../../plans/presentation/plans_flow_test.dart'
    show closeItem, waitForSave;

const _onboarded = PreferencesSnapshot(
  themePreference: ThemePreference.light,
  onboardingCompleted: true,
);

Future<void> seedGym(AppDatabase db, FakeClock clock) async {
  await CreateActivityType(
    DbActivityTypeRepository(db, clock),
    SequentialIdGenerator(),
  )(gymDefinition());
}

/// The [index]th input labelled [label] (compact set rows).
Finder labelledInput(String label, int index) =>
    find.widgetWithText(TextField, label).at(index);

Future<void> enterAt(
  WidgetTester tester,
  String label,
  int index,
  String text,
) async {
  final input = labelledInput(label, index);
  await tester.ensureVisible(input);
  await tester.enterText(input, text);
  await tester.pumpAndSettle();
}

Future<void> openGymRecord(WidgetTester tester) async {
  await openActivities(tester);
  await tester.tap(find.text('Gym'));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(FilledButton, 'Record'));
  await tester.pumpAndSettle();
  expect(find.byType(ItemScreen), findsOneWidget, reason: 'an item for now');
}

void main() {
  testAppWidgets('recording the §43 workout: an exercise with three sets', (
    tester,
  ) async {
    await pumpTestApp(tester, preferences: _onboarded, seed: seedGym);
    await openGymRecord(tester);

    await scrollAndTap(tester, find.text('Add Exercise'));
    expect(find.text('Exercise 1'), findsOneWidget);
    await enterField(tester, 'Exercise *', 'Chest Press');

    await scrollAndTap(tester, find.text('Add Set'));
    await enterAt(tester, 'Weight', 0, '50');
    await enterAt(tester, 'Reps', 0, '12');

    // A new set starts from the previous one.
    await scrollAndTap(tester, find.text('Add Set'));
    expect(find.text('Set 2'), findsOneWidget);
    final prefilled = tester.widget<TextField>(labelledInput('Weight', 1));
    expect(prefilled.controller!.text, '50');
    await enterAt(tester, 'Weight', 1, '55');
    await enterAt(tester, 'Reps', 1, '10');

    await scrollAndTap(tester, find.text('Add Set'));
    await enterAt(tester, 'Weight', 2, '60');
    await enterAt(tester, 'Reps', 2, '8');

    FocusManager.instance.primaryFocus?.unfocus();
    await waitForSave(tester);
    await closeItem(tester);

    expect(find.byType(ActivityTypeScreen), findsOneWidget);
    expect(find.text('Chest Press'), findsOneWidget);

    // Reopening shows every set as recorded.
    await tester.tap(find.text('Chest Press'));
    await tester.pumpAndSettle();
    expect(find.byType(ItemScreen), findsOneWidget);
    for (final (i, (kg, reps)) in [
      ('50', '12'),
      ('55', '10'),
      ('60', '8'),
    ].indexed) {
      final weight = labelledInput('Weight', i);
      await tester.ensureVisible(weight);
      expect(tester.widget<TextField>(weight).controller!.text, kg);
      expect(
        tester.widget<TextField>(labelledInput('Reps', i)).controller!.text,
        reps,
      );
    }
  });

  testAppWidgets('an exercise without a name yet is still saved (required '
      'is a hint while logging, ADR-035)', (tester) async {
    final db = await pumpTestApp(
      tester,
      preferences: _onboarded,
      seed: seedGym,
    );
    await openGymRecord(tester);

    await scrollAndTap(tester, find.text('Add Exercise'));
    await scrollAndTap(tester, find.text('Add Set'));
    await enterAt(tester, 'Reps', 0, '12');
    FocusManager.instance.primaryFocus?.unfocus();
    await waitForSave(tester);

    expect(find.text('Saved'), findsOneWidget);
    final items = await tester.runAsync(
      () => db
          .customSelect('SELECT COUNT(*) AS c FROM log_group_items')
          .getSingle(),
    );
    expect(items!.read<int>('c'), 2, reason: 'the exercise and its set');
  });

  testAppWidgets('exercise names are suggested from earlier workouts', (
    tester,
  ) async {
    await pumpTestApp(tester, preferences: _onboarded, seed: seedGym);
    await openGymRecord(tester);
    await scrollAndTap(tester, find.text('Add Exercise'));
    await enterField(tester, 'Exercise *', 'Chest Press');
    FocusManager.instance.primaryFocus?.unfocus();
    await waitForSave(tester);
    await closeItem(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Record'));
    await tester.pumpAndSettle();
    await scrollAndTap(tester, find.text('Add Exercise'));
    await enterField(tester, 'Exercise *', 'che');

    expect(find.widgetWithText(ListTile, 'Chest Press'), findsOneWidget);
    await tester.tap(find.widgetWithText(ListTile, 'Chest Press'));
    await tester.pumpAndSettle();
    final input = find.descendant(
      of: find.widgetWithText(FieldEditorShell, 'Exercise *'),
      matching: find.byType(TextField),
    );
    expect(tester.widget<TextField>(input).controller!.text, 'Chest Press');
    expect(find.widgetWithText(ListTile, 'Chest Press'), findsNothing);
  });
}
