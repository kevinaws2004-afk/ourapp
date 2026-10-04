import 'package:daylog/app/app.dart';
import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/design/app_icons.dart';
import 'package:daylog/features/plans/presentation/widgets/plan_item_tile.dart';
import 'package:daylog/core/database/database_provider.dart';
import 'package:daylog/features/activity_logs/presentation/form/field_editor_shell.dart';
import 'package:daylog/features/activity_logs/presentation/log_editor_screen.dart';
import 'package:daylog/features/settings/domain/preferences_snapshot.dart';
import 'package:daylog/features/settings/domain/theme_preference.dart';
import 'package:daylog/features/settings/presentation/preferences_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Plans on a real device (ADR-018, ADR-030): install Reading, plan it for
/// today on the Plan tab, tap it to record it, and see it done on Today.
/// In-memory database, so the device's real app data is untouched.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Finder scrollable() => find.byType(Scrollable).hitTestable().first;

  testWidgets('plan an activity, record it from the plan, see it done', (
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
    Future<void> tapTab(String label) async {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        ),
      );
      await tester.pumpAndSettle();
    }

    await tapTab('Me');
    await tester.tap(find.text('Activities'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start from a template'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reading'));
    await tester.pumpAndSettle();

    await tapTab('Plan');
    await tester.tap(find.widgetWithText(ChoiceChip, 'Reading'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add plan'));
    await tester.pumpAndSettle();
    // Tapping the planned activity records it (ADR-030).
    await tester.tap(find.byType(PlanItemTile));
    await tester.pumpAndSettle();
    expect(find.byType(LogEditorScreen), findsOneWidget);
    await tester.enterText(
      find.descendant(
        of: find.widgetWithText(FieldEditorShell, 'Book'),
        matching: find.byType(TextField),
      ),
      'Antifragile',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    final save = find.widgetWithText(FilledButton, 'Save');
    await tester.scrollUntilVisible(save, 200, scrollable: scrollable());
    await tester.tap(save);
    await tester.pumpAndSettle();

    await tapTab('Today');
    expect(find.textContaining('Recorded'), findsWidgets);
    expect(find.byIcon(AppIcons.taskDone), findsOneWidget);

    await db.close();
  });
}
