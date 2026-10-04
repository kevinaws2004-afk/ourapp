import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/time/local_date.dart';
import 'package:daylog/features/activity_types/data/db_activity_type_repository.dart';
import 'package:daylog/features/activity_types/domain/activity_type_use_cases.dart';
import 'package:daylog/features/plans/data/db_plan_repository.dart';
import 'package:daylog/features/plans/domain/plan.dart';
import 'package:daylog/features/plans/domain/plan_use_cases.dart';
import 'package:daylog/features/plans/presentation/item/item_notifier.dart';
import 'package:daylog/features/plans/presentation/item/item_screen.dart';
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

/// Opens an item by tapping it on a day's list.
Future<void> openItem(WidgetTester tester, Finder item) async {
  await tester.tap(item);
  await tester.pumpAndSettle();
  expect(find.byType(ItemScreen), findsOneWidget);
}

/// Lets an item's auto-save run (it saves shortly after typing stops).
Future<void> waitForSave(WidgetTester tester) async {
  await tester.pump(ItemNotifier.saveDelay + const Duration(milliseconds: 50));
  await tester.pumpAndSettle();
}

/// Leaves an item, back to the day.
Future<void> closeItem(WidgetTester tester) async {
  await tester.pageBack();
  await tester.pumpAndSettle();
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

  testAppWidgets('opening a planned activity is where you log into it: it '
      'saves as you type, and the plan shows as done with what was logged', (
    tester,
  ) async {
    await pumpTestApp(tester, preferences: _onboarded, seed: seedReadingPlan);
    await openPlan(tester);

    await openItem(tester, find.text('Read'));
    expect(find.text('Mark done'), findsOneWidget);
    expect(find.text('Save'), findsNothing, reason: 'no Save button');
    await enterField(tester, 'Book *', 'Antifragile');
    await waitForSave(tester);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    await closeItem(tester);
    expect(find.textContaining('Done'), findsOneWidget, reason: 'its status');
    expect(find.text('Antifragile'), findsOneWidget, reason: 'summary');
    expect(find.byIcon(AppIcons.taskDone), findsOneWidget, reason: '✓');

    // Coming back to it shows what was logged, ready for more.
    await openItem(tester, find.text('Read'));
    expect(find.text('Antifragile'), findsOneWidget);
  });

  testAppWidgets('leaving an item right after typing still saves it', (
    tester,
  ) async {
    await pumpTestApp(tester, preferences: _onboarded, seed: seedReadingPlan);
    await openPlan(tester);

    await openItem(tester, find.text('Read'));
    await enterField(tester, 'Book *', 'Skin in the Game');
    await closeItem(tester);
    await waitForSave(tester);

    expect(find.text('Skin in the Game'), findsOneWidget);
  });

  testAppWidgets('plan options: move to tomorrow, with Undo', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded, seed: seedReadingPlan);
    await openPlan(tester);

    await tester.tap(find.byTooltip('Plan options'));
    await tester.pumpAndSettle();
    expect(find.text('Record it'), findsNothing, reason: 'open it instead');
    expect(find.text('Mark as done'), findsNothing, reason: 'tasks only');
    await scrollAndTap(tester, find.text('Move to tomorrow'));

    expect(find.text('Nothing planned for this day.'), findsOneWidget);
    expect(find.text('Moved to tomorrow'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Read'), findsOneWidget);
  });

  testAppWidgets('a task opens like any item and can be marked done there', (
    tester,
  ) async {
    await pumpTestApp(tester, preferences: _onboarded);
    await openPlan(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Add something to this day'),
      'Call mum',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    await openItem(tester, find.text('Call mum'));
    await tester.tap(find.text('Mark done'));
    await tester.pumpAndSettle();
    expect(find.text('Done'), findsOneWidget);

    await closeItem(tester);
    expect(find.byTooltip('Mark as not done'), findsOneWidget);
  });

  testAppWidgets('anything can be logged: notes on a new name save it as '
      'done, with an activity of its own', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded);
    await openPlan(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Add something to this day'),
      'Doctor call',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    await openItem(tester, find.text('Doctor call'));
    await enterField(tester, 'Notes', 'Take vitamin D; check again in May');
    await waitForSave(tester);
    expect(find.text('Saved'), findsOneWidget);

    await closeItem(tester);
    expect(
      find.byTooltip('Mark as not done'),
      findsNothing,
      reason:
          'not a '
          'bare task any more',
    );
    expect(find.byIcon(AppIcons.taskDone), findsOneWidget, reason: '✓');
  });

  testAppWidgets('Today: "Now" adds an item and opens it to log straight '
      'away', (tester) async {
    await pumpTestApp(
      tester,
      preferences: _onboarded,
      seed: (db, clock) => CreateActivityType(
        DbActivityTypeRepository(db, clock),
        SequentialIdGenerator(),
      )(readingDefinition()),
    );

    expect(find.text('Good morning'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Add something to this day'),
      'Reading',
    );
    await tester.tap(find.widgetWithText(FilterChip, 'Now'));
    await tester.pumpAndSettle();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.byType(ItemScreen), findsOneWidget);
    await enterField(tester, 'Book *', 'Deep Work');
    await closeItem(tester);
    await waitForSave(tester);
    expect(find.text('Deep Work'), findsOneWidget);
    expect(find.textContaining('1 done'), findsOneWidget);
  });

  testAppWidgets('an empty Today invites adding to the day', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded);

    expect(
      find.text(
        "Add what you're doing or planning. Open it later to log how it went.",
      ),
      findsOneWidget,
    );
    expect(find.text('Add something to this day'), findsOneWidget);
  });

  testAppWidgets('typing an activity\'s name plans that activity, so its '
      'item has its fields', (tester) async {
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

    await openItem(tester, find.text('reading'));
    expect(find.text('Book *'), findsOneWidget, reason: 'not a task');
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
    await openItem(tester, find.byType(PlanItemTile));
    await tester.scrollUntilVisible(
      find.text('Add Exercise'),
      200,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    expect(find.text('Add Exercise'), findsOneWidget);
  });

  testAppWidgets('"Mark done" on a 21:10–21:55 plan records its 45 minutes', (
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

    await openItem(tester, find.text('Read'));
    await tester.tap(find.text('Mark done'));
    await tester.pumpAndSettle();
    await closeItem(tester);

    expect(find.textContaining('Done · 45 min of 45 min'), findsOneWidget);
  });

  group('anything can be logged, added right inside the item', () {
    Future<void> openNewItem(WidgetTester tester, String name) async {
      await pumpTestApp(tester, preferences: _onboarded);
      await openPlan(tester);
      await tester.enterText(
        find.widgetWithText(TextField, 'Add something to this day'),
        name,
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await openItem(tester, find.text(name));
    }

    testAppWidgets('Sets & reps in one tap, then log a set', (tester) async {
      await openNewItem(tester, 'Leg day');

      await scrollAndTap(tester, find.text('Add to log'));
      await tester.tap(find.text('Sets & reps'));
      await tester.pumpAndSettle();

      await scrollAndTap(tester, find.text('Add Exercise'));
      await enterField(tester, 'Exercise', 'Squat');
      await scrollAndTap(tester, find.text('Add Set'));
      final weight = find.widgetWithText(TextField, 'Weight').first;
      await tester.ensureVisible(weight);
      await tester.enterText(weight, '80');
      await tester.pumpAndSettle();
      await waitForSave(tester);
      expect(find.text('Saved'), findsOneWidget);

      await closeItem(tester);
      expect(find.byIcon(AppIcons.taskDone), findsOneWidget, reason: '✓');
    });

    testAppWidgets('one number, named by the user, logged straight away', (
      tester,
    ) async {
      await openNewItem(tester, 'Lunch');

      await scrollAndTap(tester, find.text('Add to log'));
      await scrollAndTap(tester, find.text('Number'));
      await tester.enterText(
        find.widgetWithText(TextField, 'Field name'),
        'Calories',
      );
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      await enterField(tester, 'Calories', '650');
      await waitForSave(tester);
      await closeItem(tester);
      expect(find.text('650'), findsOneWidget, reason: 'summary');
    });

    testAppWidgets('a list can get another detail where it is', (tester) async {
      await openNewItem(tester, 'Doctor visit');

      await scrollAndTap(tester, find.text('Add to log'));
      await tester.tap(find.text('Checklist'));
      await tester.pumpAndSettle();
      await scrollAndTap(tester, find.text('Add detail'));
      await scrollAndTap(tester, find.text('Text'));
      await tester.enterText(
        find.widgetWithText(TextField, 'Field name'),
        'Dose',
      );
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      await scrollAndTap(tester, find.text('Add Item'));
      expect(find.text('Dose'), findsOneWidget);
    });
  });

  group('planner: week, month, repeat, plan next (ADR-036)', () {
    testAppWidgets('repeat a plan on chosen days; the week shows each one', (
      tester,
    ) async {
      await pumpTestApp(tester, preferences: _onboarded, seed: seedReadingPlan);
      await openPlan(tester);

      await tester.tap(find.byTooltip('Plan options'));
      await tester.pumpAndSettle();
      await scrollAndTap(tester, find.text('Repeat…'));
      // Starts on the plan's weekday (Sat 3 Oct); add Monday.
      await tester.tap(find.widgetWithText(FilterChip, 'Mon'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Repeats Mon, Sat'), findsOneWidget);

      await tester.tap(find.text('Week'));
      await tester.pumpAndSettle();
      // Week of Sat 3 Oct (locale weeks start on Sunday): Sat 3 only;
      // next week: Mon 5 and Sat 10.
      await tester.tap(find.byTooltip('Next week'));
      await tester.pumpAndSettle();
      expect(find.text('Read'), findsNWidgets(2));
      expect(find.byIcon(AppIcons.repeat), findsNWidgets(2));
    });

    testAppWidgets('month shows the calendar; tapping a day opens it', (
      tester,
    ) async {
      await pumpTestApp(tester, preferences: _onboarded, seed: seedReadingPlan);
      await openPlan(tester);

      await tester.tap(find.text('Month'));
      await tester.pumpAndSettle();
      expect(find.text('October 2026'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Saturday, October 3, 2026'));
      await tester.pumpAndSettle();
      expect(find.text('Read'), findsOneWidget, reason: 'day view');
    });

    testAppWidgets('plan next from inside an item', (tester) async {
      await pumpTestApp(tester, preferences: _onboarded, seed: seedReadingPlan);
      await openPlan(tester);
      await openItem(tester, find.text('Read'));

      await scrollAndTap(tester, find.text('Plan next…'));
      // The date picker suggests a week later.
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Planned for Sat, Oct 10'), findsOneWidget);
      await closeItem(tester);
      await tester.tap(find.byTooltip('Next week'));
      await tester.pumpAndSettle();
      expect(find.text('Read'), findsOneWidget);
    });
  });
}
