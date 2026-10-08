import 'package:daylog/app/app.dart';
import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/design/app_icons.dart';
import 'package:daylog/features/plans/presentation/widgets/plan_item_tile.dart';
import 'package:daylog/core/database/database_provider.dart';
import 'package:daylog/features/activity_logs/presentation/form/field_editor_shell.dart';
import 'package:daylog/features/plans/presentation/item/item_notifier.dart';
import 'package:daylog/features/plans/presentation/item/item_screen.dart';
import 'package:daylog/features/settings/domain/preferences_snapshot.dart';
import 'package:daylog/core/design/themes/app_theme_id.dart';
import 'package:daylog/features/settings/presentation/preferences_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/intl.dart';

/// Plans on a real device (ADR-018, ADR-035): install Reading, plan it for
/// today from the Plan tab's week (today's day screen), open it and log into it (saved as you type), and
/// see it done on Today.
/// In-memory database, so the device's real app data is untouched.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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
              theme: AppThemeId.lavender,
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
    // One list of activities: search it, then tap the built-in one (ADR-042).
    await tester.enterText(
      find.widgetWithText(TextField, 'Search activities'),
      'Reading',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reading'));
    await tester.pumpAndSettle();
    // Its preview shows the form; Use saves it as one of yours (B8).
    await tester.scrollUntilVisible(
      find.text('Use Reading'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Use Reading'));
    await tester.pumpAndSettle();

    await tapTab('Plan');
    // The week opens; tapping today's heading opens the day (A1).
    await tester.tap(
      find.text(DateFormat.yMMMMEEEEd('en_US').format(DateTime.now())),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Reading'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add plan'));
    await tester.pumpAndSettle();
    // Opening the planned activity is where you log into it (ADR-035).
    await tester.tap(find.byType(PlanItemTile));
    await tester.pumpAndSettle();
    expect(find.byType(ItemScreen), findsOneWidget);
    await tester.enterText(
      find.descendant(
        of: find.widgetWithText(FieldEditorShell, 'Book'),
        matching: find.byType(TextField),
      ),
      'Antifragile',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump(ItemNotifier.saveDelay * 2);
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsOneWidget);
    // Logging doesn't finish it; Mark done at the bottom does (ADR-040).
    await tester.scrollUntilVisible(
      find.text('Mark done'),
      200,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    await tester.ensureVisible(find.text('Mark done'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mark done'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tapTab('Today');
    expect(find.textContaining('1 done'), findsOneWidget);
    expect(find.byIcon(AppIcons.taskDone), findsOneWidget);

    await db.close();
  });
}
