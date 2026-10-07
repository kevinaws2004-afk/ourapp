import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/time/local_date.dart';
import 'package:daylog/features/activity_types/data/db_activity_type_repository.dart';
import 'package:daylog/features/activity_types/domain/activity_type_use_cases.dart';
import 'package:daylog/features/plans/data/db_plan_repository.dart';
import 'package:daylog/features/plans/domain/plan.dart';
import 'package:daylog/features/plans/domain/plan_use_cases.dart';
import 'package:daylog/features/plans/presentation/day_screen.dart';
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
    show enterField, findTemplate, scrollAndTap;
import 'plan_screen_test.dart' show openPlan, openPlanTab;

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

/// An item's row on the day (its name is also a "Recent" chip).
Finder itemRow(String name) =>
    find.descendant(of: find.byType(PlanItemTile), matching: find.text(name));

/// Saves the builder a new name opens in quick add: the name is filled in
/// and the user chooses what to log (here: nothing yet).
Future<void> saveOwnActivity(WidgetTester tester, String name) async {
  expect(find.text('New activity'), findsOneWidget);
  expect(find.widgetWithText(TextField, name), findsOneWidget);
  await scrollAndTap(tester, find.text('Save'));
}

/// Leaves an item, back to the day.
Future<void> closeItem(WidgetTester tester) async {
  await tester.pageBack();
  await tester.pumpAndSettle();
}

void main() {
  testAppWidgets('a new name in quick add is made your own (the builder '
      'opens with it), then planned; it completes with a tap', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded);
    await openPlan(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'Add an activity to this day'),
      'Buy groceries',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await saveOwnActivity(tester, 'Buy groceries');
    expect(itemRow('Buy groceries'), findsOneWidget);

    await tester.tap(find.byTooltip('Mark as done'));
    await tester.pumpAndSettle();
    expect(find.text('Done'), findsWidgets, reason: 'status and snackbar');
    expect(find.byTooltip('Mark as not done'), findsOneWidget);
  });

  testAppWidgets('opening a planned activity is where you log into it: it '
      'saves as you type, stays in progress until Mark done (A10), then shows '
      'as done with what was logged', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded, seed: seedReadingPlan);
    await openPlan(tester);

    await openItem(tester, find.text('Read'));
    expect(find.text('Save'), findsNothing, reason: 'no Save button');
    await enterField(tester, 'Book *', 'Antifragile');
    await waitForSave(tester);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Done'), findsNothing, reason: 'logging doesn\'t finish');

    await closeItem(tester);
    expect(find.textContaining('In progress'), findsOneWidget);
    expect(find.text('Antifragile'), findsOneWidget, reason: 'summary');

    await openItem(tester, find.text('Read'));
    await scrollAndTap(tester, find.text('Mark done'));
    expect(find.text('Mark done'), findsNothing, reason: 'done now');
    await closeItem(tester);
    expect(find.textContaining('In progress'), findsNothing);
    expect(find.byIcon(AppIcons.taskDone), findsOneWidget, reason: '✓');
    expect(find.byTooltip('Mark as not done'), findsOneWidget);

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
    expect(find.text('Mark as done'), findsOneWidget, reason: 'any item');
    await scrollAndTap(tester, find.text('Move to tomorrow'));

    expect(find.text('Nothing planned for this day.'), findsOneWidget);
    expect(find.text('Moved to tomorrow'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Read'), findsOneWidget);
  });

  testAppWidgets(
    'an item of your own opens like any item and can be marked done there',
    (tester) async {
      await pumpTestApp(tester, preferences: _onboarded);
      await openPlan(tester);
      await tester.enterText(
        find.widgetWithText(TextField, 'Add an activity to this day'),
        'Call mum',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await saveOwnActivity(tester, 'Call mum');

      await openItem(tester, itemRow('Call mum'));
      await tester.tap(find.text('Mark done'));
      await tester.pumpAndSettle();
      expect(find.text('Done'), findsOneWidget);

      await closeItem(tester);
      expect(find.byTooltip('Mark as not done'), findsOneWidget);
    },
  );

  testAppWidgets('anything can be logged: notes on a new name save it as '
      'done, with an activity of its own', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded);
    await openPlan(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Add an activity to this day'),
      'Doctor call',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await saveOwnActivity(tester, 'Doctor call');

    await openItem(tester, itemRow('Doctor call'));
    await enterField(tester, 'Notes', 'Take vitamin D; check again in May');
    await waitForSave(tester);
    expect(find.text('Saved'), findsOneWidget);

    await closeItem(tester);
    // Logged into, so it has an activity and is in progress (ADR-040).
    expect(find.textContaining('In progress'), findsOneWidget);
    expect(find.byTooltip('Mark as done'), findsOneWidget, reason: 'check');
  });

  testAppWidgets('Today: "Start now" adds an item and opens it to log '
      'straight away (A4)', (tester) async {
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
      find.widgetWithText(TextField, 'Add an activity to this day'),
      'Reading',
    );
    await tester.pump();
    await tester.tap(find.text('Start now'));
    await tester.pumpAndSettle();

    expect(find.byType(ItemScreen), findsOneWidget);
    await enterField(tester, 'Book *', 'Deep Work');
    await closeItem(tester);
    await waitForSave(tester);
    expect(find.text('Deep Work'), findsOneWidget);
    expect(find.textContaining('In progress'), findsOneWidget);
  });

  testAppWidgets('an empty Today invites adding to the day', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded);

    expect(
      find.text(
        "Add what you're doing or planning. Open it later to log how it went.",
      ),
      findsOneWidget,
    );
    expect(find.text('Add an activity to this day'), findsOneWidget);
  });

  group('quick add (A4–A8)', () {
    Future<void> seedReading(AppDatabase db, FakeClock clock) =>
        CreateActivityType(
          DbActivityTypeRepository(db, clock),
          SequentialIdGenerator(),
        )(readingDefinition());

    testAppWidgets('"Start now" and the time only appear once something is '
        'typed; "Recent" labels the activity chips', (tester) async {
      await pumpTestApp(tester, preferences: _onboarded, seed: seedReading);

      expect(find.text('Start now'), findsNothing);
      expect(find.text('Set a time'), findsNothing);
      expect(find.text('Recent'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Reading'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Add an activity to this day'),
        'Bath',
      );
      await tester.pump();
      expect(find.text('Start now'), findsOneWidget);
      expect(find.text('Set a time'), findsOneWidget);
    });

    testAppWidgets('"Templates" plans one from the gallery; a new name is '
        'offered as your own, and backing out of the builder adds nothing', (
      tester,
    ) async {
      await pumpTestApp(tester, preferences: _onboarded);

      await tester.tap(find.text('Templates'));
      await tester.pumpAndSettle();
      await findTemplate(tester, 'walk', 'Walking');
      await scrollAndTap(tester, find.text('Add Walking'));
      // Back on the day, the new activity is chosen, ready to add.
      expect(find.widgetWithText(ChoiceChip, 'Walking'), findsOneWidget);
      expect(find.text('Set a time'), findsOneWidget);
      await tester.tap(find.byTooltip('Add plan'));
      await tester.pumpAndSettle();
      expect(itemRow('Walking'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Add an activity to this day'),
        'Piano',
      );
      await tester.pump();
      expect(find.text('Make “Piano” your own'), findsOneWidget);
      await tester.tap(find.text('Make “Piano” your own'));
      await tester.pumpAndSettle();
      expect(find.text('New activity'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(itemRow('Piano'), findsNothing, reason: 'nothing without one');
    });

    testAppWidgets('typing suggests ready-made templates; tapping one fills '
        'the name', (tester) async {
      await pumpTestApp(tester, preferences: _onboarded);

      await tester.enterText(
        find.widgetWithText(TextField, 'Add an activity to this day'),
        'gy',
      );
      await tester.pump();
      expect(find.textContaining('Ready-made · Workout'), findsOneWidget);

      await tester.tap(find.text('Gym'));
      await tester.pump();
      expect(find.widgetWithText(TextField, 'Gym'), findsOneWidget);
    });

    testAppWidgets('an existing activity is suggested instead of its '
        'template, so typing never makes a second one (A8)', (tester) async {
      await pumpTestApp(tester, preferences: _onboarded, seed: seedReading);

      await tester.enterText(
        find.widgetWithText(TextField, 'Add an activity to this day'),
        'Rea',
      );
      await tester.pump();
      expect(find.text('Your activity'), findsOneWidget);
      // Other templates containing "rea" (Breathing…) may show; Reading's not.
      expect(find.text('Ready-made · Book · Pages · Rating'), findsNothing);
    });

    testAppWidgets('one sheet sets the time: a suggested start and a length', (
      tester,
    ) async {
      await pumpTestApp(tester, preferences: _onboarded);

      await tester.enterText(
        find.widgetWithText(TextField, 'Add an activity to this day'),
        'Bath',
      );
      await tester.pump();
      await tester.tap(find.text('Set a time'));
      await tester.pumpAndSettle();
      // The test clock is 08:00: the next half hours are suggested.
      expect(find.text('When?'), findsOneWidget);
      await tester.tap(find.widgetWithText(ChoiceChip, '9:00 AM'));
      await tester.tap(find.widgetWithText(ChoiceChip, '30 min'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('9:00 AM–9:30 AM'), findsOneWidget, reason: 'button');

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await saveOwnActivity(tester, 'Bath');
      expect(itemRow('Bath'), findsOneWidget);
      expect(find.textContaining('9:00 AM–9:30 AM'), findsOneWidget);
    });
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
      find.widgetWithText(TextField, 'Add an activity to this day'),
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
      find.widgetWithText(TextField, 'Add an activity to this day'),
      'Gym',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ChoiceChip, 'Gym'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing, reason: 'no pop-up (A9)');
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
    await scrollAndTap(tester, find.text('Mark done'));
    await closeItem(tester);

    expect(find.textContaining('45 min of 45 min'), findsOneWidget);
    expect(
      find.textContaining('Done ·'),
      findsNothing,
      reason: 'the ✓ says it',
    );
  });

  group('anything can be logged, added right inside the item', () {
    Future<void> openNewItem(WidgetTester tester, String name) async {
      await pumpTestApp(tester, preferences: _onboarded);
      await openPlan(tester);
      await tester.enterText(
        find.widgetWithText(TextField, 'Add an activity to this day'),
        name,
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await saveOwnActivity(tester, name);
      await openItem(tester, itemRow(name));
    }

    testAppWidgets('Sets & reps in one tap, then log a set', (tester) async {
      await openNewItem(tester, 'Leg day');

      // An item with nothing to log offers the likely things (B3).
      await scrollAndTap(
        tester,
        find.widgetWithText(ActionChip, 'Sets & reps'),
      );

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
      expect(find.textContaining('Squat 80 kg'), findsOneWidget, reason: 'A18');
      expect(find.textContaining('In progress'), findsOneWidget);
    });

    testAppWidgets('one number, named by the user, logged straight away', (
      tester,
    ) async {
      await openNewItem(tester, 'Lunch');

      await scrollAndTap(tester, find.widgetWithText(ActionChip, 'An amount'));
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
      await openNewItem(tester, 'Clinic follow-up');

      await scrollAndTap(tester, find.widgetWithText(ActionChip, 'More…'));
      await tester.tap(find.text('Checklist'));
      await tester.pumpAndSettle();
      await scrollAndTap(tester, find.byTooltip('Item list options'));
      await tester.tap(find.text('Add a detail to each Item'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('More kinds of detail'));
      await tester.pumpAndSettle();
      await scrollAndTap(tester, find.text('Words'));
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

  group('day rows and the item (A9–A19)', () {
    testAppWidgets('the check on any row marks it done; Undo takes it back, '
        'including the log it created (A17)', (tester) async {
      await pumpTestApp(tester, preferences: _onboarded, seed: seedReadingPlan);
      await openPlan(tester);

      await tester.tap(find.byTooltip('Mark as done'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Mark as not done'), findsOneWidget);
      expect(find.textContaining('1h 0m of 1h 0m'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Mark as done'), findsOneWidget);
      expect(find.textContaining('of 1h 0m'), findsNothing, reason: 'no log');
    });

    testAppWidgets('untimed items sit under "Anytime" (A19)', (tester) async {
      await pumpTestApp(
        tester,
        preferences: _onboarded,
        seed: (db, clock) async {
          final ids = SequentialIdGenerator();
          final types = DbActivityTypeRepository(db, clock);
          final create = CreatePlan(
            DbPlanRepository(db, clock),
            types,
            ids,
            clock,
          );
          await create(
            PlanDraft(
              planDate: _today,
              title: 'Standup',
              plannedStartAt: DateTime.utc(2026, 10, 3, 9),
            ),
          );
          await create(PlanDraft(planDate: _today, title: 'Buy milk'));
        },
      );

      expect(find.text('Anytime'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Standup')).dy,
        lessThan(tester.getTopLeft(find.text('Anytime')).dy),
      );
      expect(
        tester.getTopLeft(find.text('Anytime')).dy,
        lessThan(tester.getTopLeft(find.text('Buy milk')).dy),
      );
    });

    testAppWidgets('a half-filled sheet asks before it is thrown away (A15)', (
      tester,
    ) async {
      await pumpTestApp(tester, preferences: _onboarded, seed: seedReadingPlan);
      await openPlan(tester);
      await openItem(tester, find.text('Read'));

      await scrollAndTap(tester, find.text('Add to log'));
      await scrollAndTap(tester, find.text('An amount'));
      await tester.enterText(
        find.widgetWithText(TextField, 'Field name'),
        'Pages',
      );
      await tester.pump();
      await tester.tapAt(const Offset(20, 20)); // outside the sheet
      await tester.pumpAndSettle();
      expect(find.text('Discard your changes?'), findsOneWidget);

      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, 'Pages'), findsOneWidget);
    });

    testAppWidgets('the duration boxes say what they are (A11)', (
      tester,
    ) async {
      await pumpTestApp(tester, preferences: _onboarded, seed: seedReadingPlan);
      await openPlan(tester);
      await openItem(tester, find.text('Read'));
      await tester.scrollUntilVisible(
        find.text('Hours'),
        200,
        scrollable: find.byType(Scrollable).hitTestable().first,
      );
      expect(find.text('Hours'), findsOneWidget);
      expect(find.text('Minutes'), findsOneWidget);
    });
  });

  group('planner: week, month, repeat, plan next (ADR-036)', () {
    testAppWidgets('the week\'s "+" plans an activity: no plain tasks; a '
        'new title is made your own on saving', (tester) async {
      await pumpTestApp(tester, preferences: _onboarded);
      await openPlanTab(tester);

      await tester.tap(find.byTooltip('New plan').first);
      await tester.pumpAndSettle();
      expect(find.text('Just a task'), findsNothing);
      expect(find.widgetWithText(ActionChip, 'Templates'), findsOneWidget);
      expect(find.widgetWithText(ActionChip, 'Make your own'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Swim');
      await scrollAndTap(tester, find.text('Save'));
      await saveOwnActivity(tester, 'Swim');
      expect(find.text('Swim'), findsWidgets);
      expect(find.text('New plan'), findsNothing, reason: 'sheet closed');
    });

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

      await tester.pageBack(); // back from the day to the week
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
      await openPlanTab(tester);

      await tester.tap(find.text('Month'));
      await tester.pumpAndSettle();
      expect(find.text('October 2026'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Saturday, October 3, 2026'));
      await tester.pumpAndSettle();
      expect(find.byType(DayScreen), findsOneWidget);
      expect(find.text('Read'), findsOneWidget);
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
      await tester.pageBack(); // back from the day to the week
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Next week'));
      await tester.pumpAndSettle();
      expect(find.text('Read'), findsOneWidget);
    });
  });
}
