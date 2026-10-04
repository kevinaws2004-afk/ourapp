import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/time/local_date.dart';
import 'package:daylog/features/activity_logs/presentation/log_editor_screen.dart';
import 'package:daylog/features/activity_types/data/db_activity_type_repository.dart';
import 'package:daylog/features/activity_types/domain/activity_type_use_cases.dart';
import 'package:daylog/features/plans/data/db_plan_repository.dart';
import 'package:daylog/features/plans/domain/plan.dart';
import 'package:daylog/features/plans/domain/plan_use_cases.dart';
import 'package:daylog/features/plans/presentation/widgets/plan_item_tile.dart';
import 'package:daylog/features/settings/domain/preferences_snapshot.dart';
import 'package:daylog/features/settings/domain/theme_preference.dart';
import 'package:daylog/core/design/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_clock.dart';
import '../../../support/fixtures.dart';
import '../../../support/test_app.dart';
import '../../activity_types/presentation/activities_flow_test.dart'
    show enterField, scrollAndTap;
import 'plan_screen_test.dart' show openPlan;

const _onboarded = PreferencesSnapshot(
  themePreference: ThemePreference.light,
  onboardingCompleted: true,
);

/// The test app's "today" (FakeClock 2026-10-03 08:00 UTC, offset 0).
final _today = LocalDate(2026, 10, 3);

/// Reading, plus a plan "Read" for today lasting an hour.
Future<void> seedReadingPlan(AppDatabase db, FakeClock clock) async {
  final ids = SequentialIdGenerator();
  final types = DbActivityTypeRepository(db, clock);
  final typeId = await CreateActivityType(types, ids)(readingDefinition());
  await CreatePlan(DbPlanRepository(db, clock), types, ids, clock)(
    PlanDraft(
      planDate: _today,
      title: 'Read',
      activityTypeId: typeId,
      plannedDurationMs: 3600000,
    ),
  );
}

/// Taps a planned activity; timer activities first ask "Start focus" or
/// "Record now" (F5), and this picks Record now.
Future<void> tapToRecord(WidgetTester tester, Finder plan) async {
  await tester.tap(plan);
  await tester.pumpAndSettle();
  if (find.text('Record now').evaluate().isNotEmpty) {
    await tester.tap(find.text('Record now'));
    await tester.pumpAndSettle();
  }
}

void main() {
  testAppWidgets('quick add creates a task, which completes with a tap', (
    tester,
  ) async {
    await pumpTestApp(tester, preferences: _onboarded);
    await openPlan(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'Add something to this day'),
      'Buy groceries',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Buy groceries'), findsOneWidget);

    await tester.tap(find.byTooltip('Mark as done'));
    await tester.pumpAndSettle();
    expect(find.text('Done'), findsWidgets, reason: 'status and snackbar');
    expect(find.byTooltip('Mark as not done'), findsOneWidget);
  });

  testAppWidgets('tapping a planned activity opens its record form; saving '
      'completes the plan, and tapping it again opens the record', (
    tester,
  ) async {
    await pumpTestApp(tester, preferences: _onboarded, seed: seedReadingPlan);
    await openPlan(tester);

    await tapToRecord(tester, find.text('Read'));
    expect(find.byType(LogEditorScreen), findsOneWidget);
    expect(find.textContaining('Planned · Read · '), findsOneWidget);
    await enterField(tester, 'Book *', 'Antifragile');
    await scrollAndTap(tester, find.widgetWithText(FilledButton, 'Save'));

    expect(find.byType(LogEditorScreen), findsNothing);
    expect(find.textContaining(' · Recorded'), findsOneWidget);
    expect(find.byIcon(AppIcons.taskDone), findsOneWidget, reason: '✓');
    expect(find.text('Everything recorded was planned.'), findsOneWidget);

    await tester.tap(find.text('Read'));
    await tester.pumpAndSettle();
    expect(find.text('Edit record'), findsOneWidget);
  });

  testAppWidgets('plan options: move to tomorrow, with Undo', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded, seed: seedReadingPlan);
    await openPlan(tester);

    await tester.tap(find.byTooltip('Plan options'));
    await tester.pumpAndSettle();
    expect(find.text('Record it'), findsOneWidget);
    expect(find.text('Mark as done'), findsNothing, reason: 'tasks only');
    await scrollAndTap(tester, find.text('Move to tomorrow'));

    expect(find.text('Nothing planned for this day.'), findsOneWidget);
    expect(find.text('Moved to tomorrow'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Read'), findsOneWidget);
  });

  testAppWidgets('tapping a task marks it done', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded);
    await openPlan(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Add something to this day'),
      'Call mum',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Call mum'));
    await tester.pumpAndSettle();
    expect(find.text('Track details'), findsOneWidget);
    await tester.tap(find.text('Mark as done'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Mark as not done'), findsOneWidget);
  });

  testAppWidgets('any plan can be tracked with fields the user chooses: '
      '"Food" → track details → add a field → record it', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded);
    await openPlan(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Add something to this day'),
      'Food',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Track details'));
    await tester.pumpAndSettle();

    // The builder starts with the plan's name; the user picks the fields.
    expect(find.widgetWithText(TextFormField, 'Food'), findsOneWidget);
    await scrollAndTap(tester, find.text('Add field'));
    await tester.tap(find.text('Number'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Field name'),
      'Calories',
    );
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    await scrollAndTap(tester, find.widgetWithText(FilledButton, 'Save'));

    // Straight into recording the plan with those fields.
    expect(find.byType(LogEditorScreen), findsOneWidget);
    expect(find.textContaining('Planned · Food'), findsOneWidget);
    await enterField(tester, 'Calories', '650');
    await scrollAndTap(tester, find.widgetWithText(FilledButton, 'Save'));

    expect(find.byIcon(AppIcons.taskDone), findsOneWidget, reason: 'Food ✓');
  });

  testAppWidgets('Today greets and tapping today\'s plan records it', (
    tester,
  ) async {
    await pumpTestApp(tester, preferences: _onboarded, seed: seedReadingPlan);

    expect(find.text('Good morning'), findsOneWidget);
    expect(find.text("Today's plan"), findsOneWidget);

    await tester.tap(find.text('Read'));
    await tester.pumpAndSettle();
    expect(find.text('Start focus'), findsOneWidget, reason: 'timer activity');
    await tester.tap(find.text('Record now'));
    await tester.pumpAndSettle();
    expect(find.byType(LogEditorScreen), findsOneWidget);
  });

  testAppWidgets('an empty Today offers to plan the day', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded);

    expect(find.text('A fresh day'), findsOneWidget);
    await tester.tap(find.text('Plan your day'));
    await tester.pumpAndSettle();

    expect(find.text('Add something to this day'), findsOneWidget);
  });

  testAppWidgets('typing an activity\'s name plans that activity, with a '
      'from–to slot that prefills the record', (tester) async {
    await pumpTestApp(
      tester,
      preferences: _onboarded,
      seed: (db, clock) => CreateActivityType(
        DbActivityTypeRepository(db, clock),
        SequentialIdGenerator(),
      )(readingDefinition()),
    );
    await openPlan(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'Add something to this day'),
      'reading',
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Reading'))
          .selected,
      isTrue,
      reason: 'the typed name selects the activity',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    await tapToRecord(tester, find.text('reading'));
    expect(find.byType(LogEditorScreen), findsOneWidget, reason: 'not a task');
  });

  testAppWidgets('typing a starter template\'s name installs it and plans it', (
    tester,
  ) async {
    await pumpTestApp(tester, preferences: _onboarded);
    await openPlan(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'Add something to this day'),
      'Gym',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ChoiceChip, 'Gym'), findsOneWidget);
    expect(find.textContaining('Added the Gym activity'), findsOneWidget);
    // Let the confirmation snackbar leave before tapping the plan.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tapToRecord(tester, find.byType(PlanItemTile));
    expect(find.byType(LogEditorScreen), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Add Exercise'),
      200,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    expect(find.text('Add Exercise'), findsOneWidget);
  });

  testAppWidgets('recording a 21:10–21:55 plan prefills its 45 minutes', (
    tester,
  ) async {
    await pumpTestApp(
      tester,
      preferences: _onboarded,
      seed: (db, clock) async {
        final ids = SequentialIdGenerator();
        final types = DbActivityTypeRepository(db, clock);
        final typeId = await CreateActivityType(types, ids)(
          readingDefinition(),
        );
        final start = DateTime(2026, 10, 3, 21, 10).toUtc();
        await CreatePlan(DbPlanRepository(db, clock), types, ids, clock)(
          PlanDraft(
            planDate: _today,
            title: 'Read',
            activityTypeId: typeId,
            plannedStartAt: start,
            plannedEndAt: start.add(const Duration(minutes: 45)),
          ),
        );
      },
    );
    await openPlan(tester);

    await tapToRecord(tester, find.text('Read'));
    await enterField(tester, 'Book *', 'Fooled by Randomness');
    await scrollAndTap(tester, find.widgetWithText(FilledButton, 'Save'));

    expect(find.textContaining('Recorded 45 min of 45 min'), findsOneWidget);
  });
}
