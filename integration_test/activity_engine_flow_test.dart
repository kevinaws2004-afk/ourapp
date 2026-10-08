import 'package:daylog/app/app.dart';
import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/database/database_provider.dart';
import 'package:daylog/features/activity_logs/presentation/form/field_editor_shell.dart';
import 'package:daylog/features/activity_types/presentation/activity_type_screen.dart';
import 'package:daylog/features/settings/data/db_app_preferences_repository.dart';
import 'package:daylog/core/logging/app_logger.dart';
import 'package:daylog/core/time/clock.dart';
import 'package:daylog/features/settings/domain/preferences_snapshot.dart';
import 'package:daylog/core/design/themes/app_theme_id.dart';
import 'package:daylog/features/settings/presentation/preferences_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// The generic activity engine on a real device (native SQLite, STRICT
/// tables, triggers): use a built-in activity, log it, see it in history.
/// Uses an in-memory database so the device's real app data is untouched.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'use a built-in activity, record an entry, and see it in history',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      await DbAppPreferencesRepository(
        db,
        const SystemClock(),
        const AppLogger(),
      ).setOnboardingCompleted(completed: true);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            initialPreferencesProvider.overrideWithValue(
              const PreferencesSnapshot(
                theme: AppThemeId.lavender,
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
      // One list of activities: search it, then tap the built-in one (ADR-042).
      await tester.enterText(
        find.widgetWithText(TextField, 'Search activities'),
        'Walking',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Walking'));
      await tester.pumpAndSettle();
      // Its preview shows the form; Use saves it as one of yours (B8).
      await tester.scrollUntilVisible(
        find.text('Use Walking'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text('Use Walking'));
      await tester.pumpAndSettle();
      expect(find.byType(ActivityTypeScreen), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Record'));
      await tester.pumpAndSettle();
      final distance = find.descendant(
        of: find.widgetWithText(FieldEditorShell, 'Distance'),
        matching: find.byType(TextField),
      );
      await tester.enterText(distance, '3.2');
      final location = find.descendant(
        of: find.widgetWithText(FieldEditorShell, 'Location'),
        matching: find.byType(TextField),
      );
      await tester.scrollUntilVisible(
        location,
        200,
        scrollable: find.byType(Scrollable).hitTestable().first,
      );
      await tester.enterText(location, 'Riverside');
      // Dismiss the soft keyboard, which otherwise covers the Save button.
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      final save = find.widgetWithText(FilledButton, 'Save');
      await tester.scrollUntilVisible(
        save,
        200,
        scrollable: find.byType(Scrollable).hitTestable().first,
      );
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(find.text('3.2 km · Riverside'), findsOneWidget);

      final stored = await db.select(db.logValues).get();
      expect(
        stored.firstWhere((v) => v.unitCode == 'km').normalizedValue,
        3200,
      );
      await db.close();
    },
  );
}
