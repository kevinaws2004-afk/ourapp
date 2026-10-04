import 'package:daylog/app/app.dart';
import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/database/database_provider.dart';
import 'package:daylog/features/activity_logs/presentation/form/field_editor_shell.dart';
import 'package:daylog/features/activity_types/presentation/activity_type_screen.dart';
import 'package:daylog/features/plans/presentation/item/item_notifier.dart';
import 'package:daylog/features/settings/domain/preferences_snapshot.dart';
import 'package:daylog/features/settings/domain/theme_preference.dart';
import 'package:daylog/features/settings/presentation/preferences_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Repeating Groups on a real device (ADR-027): install the Gym template,
/// record an exercise with sets, and reopen it. In-memory database, so the
/// device's real app data is untouched.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Finder scrollable() => find.byType(Scrollable).hitTestable().first;

  Future<void> scrollAndTap(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(finder, 200, scrollable: scrollable());
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> enter(WidgetTester tester, Finder input, String text) async {
    await tester.ensureVisible(input);
    await tester.enterText(input, text);
    await tester.pumpAndSettle();
  }

  testWidgets('record an exercise with three sets and reopen it', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          initialPreferencesProvider.overrideWithValue(
            const PreferencesSnapshot(
              themePreference: ThemePreference.system,
              onboardingCompleted: true,
            ),
          ),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Me'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Activities'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start from a template'));
    await tester.pumpAndSettle();
    await scrollAndTap(tester, find.text('Gym'));
    expect(find.byType(ActivityTypeScreen), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Record'));
    await tester.pumpAndSettle();
    await scrollAndTap(tester, find.text('Add Exercise'));
    await enter(
      tester,
      find.descendant(
        of: find.widgetWithText(FieldEditorShell, 'Exercise *'),
        matching: find.byType(TextField),
      ),
      'Chest Press',
    );
    for (final (i, (kg, reps)) in [
      ('50', '12'),
      ('55', '10'),
      ('60', '8'),
    ].indexed) {
      await scrollAndTap(tester, find.text('Add Set'));
      await enter(tester, find.widgetWithText(TextField, 'Weight').at(i), kg);
      await enter(tester, find.widgetWithText(TextField, 'Reps').at(i), reps);
    }
    FocusManager.instance.primaryFocus?.unfocus();
    // The item saves as you type (ADR-035); leave once it has.
    await tester.pump(ItemNotifier.saveDelay * 2);
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(ActivityTypeScreen), findsOneWidget);
    // The summary carries the sets' numbers (A18).
    await tester.tap(find.textContaining('Chest Press'));
    await tester.pumpAndSettle();
    final lastReps = find.widgetWithText(TextField, 'Reps').at(2);
    await tester.ensureVisible(lastReps);
    expect(tester.widget<TextField>(lastReps).controller!.text, '8');

    await db.close();
  });
}
