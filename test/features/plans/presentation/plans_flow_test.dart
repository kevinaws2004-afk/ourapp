import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/time/local_date.dart';
import 'package:daylog/features/activity_types/data/db_activity_type_repository.dart';
import 'package:daylog/features/activity_types/domain/activity_type_use_cases.dart';
import 'package:daylog/features/plans/data/db_plan_repository.dart';
import 'package:daylog/features/plans/domain/plan.dart';
import 'package:daylog/features/plans/domain/plan_use_cases.dart';
import 'package:daylog/features/plans/presentation/plan_views.dart';
import 'package:daylog/features/plans/presentation/item/item_notifier.dart';
import 'package:daylog/features/plans/presentation/item/item_screen.dart';
import 'package:daylog/features/plans/presentation/widgets/plan_item_tile.dart';
import 'package:daylog/features/settings/domain/preferences_snapshot.dart';
import 'package:daylog/core/design/themes/app_theme_id.dart';
import 'package:daylog/core/design/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:daylog/shared/widgets/app_button.dart';
import 'package:daylog/shared/widgets/item_card.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_clock.dart';
import '../../../support/fixtures.dart';
import '../../../support/test_app.dart';
import '../../activity_types/presentation/activities_flow_test.dart'
    show enterField, findActivity, scrollAndTap;
import 'plan_screen_test.dart' show openPlan, openPlanTab, selectDay;

const _onboarded = PreferencesSnapshot(
  theme: AppThemeId.lavender,
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

/// Opens an item by tapping it on a day's list (its name can also show on
/// Today's "Up next" card; the list's row is the one tapped).
Future<void> openItem(WidgetTester tester, Finder item) async {
  final inList = find.descendant(of: find.byType(ItemCard), matching: item);
  final target = inList.evaluate().isNotEmpty ? inList.first : item;
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
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

/// Opens the + sheet for the day on screen (Today or Plan's selected day).
Future<void> openAddSheet(WidgetTester tester) async {
  final plan = find.byTooltip('Add to this day');
  await tester.tap(
    plan.evaluate().isNotEmpty ? plan : find.byTooltip('Add to today'),
  );
  await tester.pumpAndSettle();
}

/// The + sheet's name field.
final addField = find.widgetWithText(TextField, 'What are you doing?');

/// Adds a new name from the + sheet: it becomes an activity of yours with
/// nothing to set up (AD3).
Future<void> addNew(WidgetTester tester, String name) async {
  await openAddSheet(tester);
  await tester.enterText(addField, name);
  await tester.pump();
  await tester.tap(find.text('Make “$name” yours'));
  await tester.pump();
  await tester.tap(find.widgetWithText(AppButton, 'Add'));
  await tester.pumpAndSettle();
}

/// Adds [text] from the + sheet as typed (an activity's name).
Future<void> addTyped(WidgetTester tester, String text) async {
  await openAddSheet(tester);
  await tester.enterText(addField, text);
  await tester.pump();
  await tester.tap(find.widgetWithText(AppButton, 'Add'));
  await tester.pumpAndSettle();
}

/// Long-presses a row for its options (B7).
Future<void> rowOptions(WidgetTester tester, String name) async {
  await tester.longPress(itemRow(name));
  await tester.pumpAndSettle();
}

/// Skips "How did it go?" after something with details is done.
Future<void> skipHowDidItGo(WidgetTester tester) async {
  expect(find.text('How did it go?'), findsOneWidget);
  await tester.tap(find.text('Skip'));
  await tester.pumpAndSettle();
}

/// The item's Done button.
final _doneButton = find.widgetWithText(AppButton, 'Done');

/// Leaves an item, back to the day.
Future<void> closeItem(WidgetTester tester) async {
  await tester.pageBack();
  await tester.pumpAndSettle();
}

void main() {
  testAppWidgets('a new name in the + sheet becomes yours with nothing to '
      'set up (AD3), then planned; it completes with a tap', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded);
    await openPlan(tester);

    await addNew(tester, 'Buy groceries');
    expect(itemRow('Buy groceries'), findsOneWidget);

    await tester.tap(find.byTooltip('Mark as done'));
    await tester.pumpAndSettle();
    expect(find.text('Done'), findsWidgets, reason: 'status and snackbar');
    expect(find.byTooltip('Mark as not done'), findsOneWidget);
  });

  testAppWidgets('opening a planned activity is where you log into it: it '
      'saves as you type, stays open until Done (ADR-046), which returns to '
      'the day showing it done; opening it again shows what was logged', (
    tester,
  ) async {
    await pumpTestApp(tester, preferences: _onboarded, seed: seedReadingPlan);
    await openPlan(tester);

    await openItem(tester, find.text('Read'));
    expect(find.text('Save'), findsNothing, reason: 'no Save button');
    await enterField(tester, 'Book *', 'Antifragile');
    await waitForSave(tester);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Done'), findsNothing, reason: 'logging doesn\'t finish');

    await closeItem(tester);
    expect(
      find.textContaining('In progress'),
      findsNothing,
      reason: 'one Done',
    );
    expect(find.text('Antifragile'), findsWidgets, reason: 'so far');

    await openItem(tester, find.text('Read'));
    await scrollAndTap(tester, _doneButton);
    await skipHowDidItGo(tester);
    expect(find.byType(ItemScreen), findsNothing, reason: 'back to the day');
    expect(find.byIcon(AppIcons.taskDone), findsOneWidget, reason: '✓');
    expect(find.byTooltip('Mark as not done'), findsOneWidget);

    // Coming back to it shows what was logged, ready for more.
    await openItem(tester, find.text('Read'));
    expect(find.text('Not done'), findsOneWidget, reason: 'A7');
    expect(find.text('Antifragile'), findsWidgets, reason: 'result + field');
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

    await rowOptions(tester, 'Read');
    expect(find.text('Record it'), findsNothing, reason: 'open it instead');
    expect(find.text('Mark as done'), findsOneWidget, reason: 'any item');
    await tester.tap(find.text('Move to tomorrow'));
    await tester.pumpAndSettle();

    expect(find.text('Nothing planned today.'), findsOneWidget);
    expect(find.text('Moved to tomorrow'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Read'), findsOneWidget);
  });

  testAppWidgets('a skipped thing says so and can be put back (A9)', (
    tester,
  ) async {
    await pumpTestApp(tester, preferences: _onboarded, seed: seedReadingPlan);
    await openPlan(tester);
    await rowOptions(tester, 'Read');
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    await openItem(tester, find.text('Read'));
    expect(find.text('Skipped'), findsWidgets, reason: 'chip (+ snackbar)');
    expect(find.text('Start'), findsNothing);
    await tester.tap(find.text('Undo skip'));
    await tester.pumpAndSettle();
    expect(find.text('Planned'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
  });

  testAppWidgets(
    'an item of your own opens like any item and can be marked done there',
    (tester) async {
      await pumpTestApp(tester, preferences: _onboarded);
      await openPlan(tester);
      await addNew(tester, 'Call mum');

      await openItem(tester, itemRow('Call mum'));
      await scrollAndTap(tester, _doneButton);
      expect(find.byType(ItemScreen), findsNothing, reason: 'back to the day');
      expect(find.text('How did it go?'), findsNothing, reason: 'no details');
      expect(find.byTooltip('Mark as not done'), findsOneWidget);
    },
  );

  testAppWidgets('anything can be logged: notes on a new name save it as '
      'done, with an activity of its own', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded);
    await openPlan(tester);
    await addNew(tester, 'Doctor call');

    await openItem(tester, itemRow('Doctor call'));
    await enterField(tester, 'Notes', 'Take vitamin D; check again in May');
    await waitForSave(tester);
    expect(find.text('Saved'), findsOneWidget);

    await closeItem(tester);
    // Logged into, so it has an activity; still open until done (ADR-046).
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
    await tester.tap(find.byTooltip('Add to today'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'What are you doing?'),
      'Reading',
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Now'));
    await tester.pump();
    await tester.tap(find.widgetWithText(AppButton, 'Start'));
    await tester.pumpAndSettle();

    expect(find.byType(ItemScreen), findsOneWidget);
    await enterField(tester, 'Book *', 'Deep Work');
    await closeItem(tester);
    await waitForSave(tester);
    expect(find.textContaining('Running'), findsWidgets, reason: 'timed');
    await openItem(tester, itemRow('Reading'));
    expect(find.text('Deep Work'), findsOneWidget);
  });

  testAppWidgets('an empty Today invites adding to the day', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded);

    expect(find.text('Your day is empty.'), findsOneWidget);
    expect(find.byTooltip('Add to today'), findsOneWidget, reason: 'the +');
  });

  group('the + sheet (AD1–AD6)', () {
    Future<void> seedReading(AppDatabase db, FakeClock clock) =>
        CreateActivityType(
          DbActivityTypeRepository(db, clock),
          SequentialIdGenerator(),
        )(readingDefinition());

    testAppWidgets('Add waits for something; "Recent" labels the activity '
        'chips; When offers Anytime and a time', (tester) async {
      await pumpTestApp(tester, preferences: _onboarded, seed: seedReading);
      await openPlan(tester);
      await openAddSheet(tester);

      expect(find.text('Add to today'), findsOneWidget, reason: 'its title');
      expect(find.text('Recent'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Reading'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Anytime'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Time…'), findsOneWidget);
      expect(
        tester
            .widget<AppButton>(find.widgetWithText(AppButton, 'Add'))
            .onPressed,
        isNull,
      );

      await tester.enterText(addField, 'Bath');
      await tester.pump();
      expect(
        tester
            .widget<AppButton>(find.widgetWithText(AppButton, 'Add'))
            .onPressed,
        isNotNull,
      );
    });

    testAppWidgets('"Browse all activities" chooses one from the list', (
      tester,
    ) async {
      await pumpTestApp(tester, preferences: _onboarded);
      await openPlan(tester);
      await openAddSheet(tester);

      await tester.tap(find.text('Browse all activities'));
      await tester.pumpAndSettle();
      expect(find.text('Choose an activity'), findsOneWidget);
      await findActivity(tester, 'walk', 'Walking');
      await scrollAndTap(tester, find.text('Use Walking'));
      expect(find.widgetWithText(TextField, 'Walking'), findsOneWidget);
      await tester.tap(find.widgetWithText(AppButton, 'Add'));
      await tester.pumpAndSettle();
      expect(itemRow('Walking'), findsOneWidget);
    });

    testAppWidgets('typing suggests built-in activities with what they log; '
        'tapping one fills the name', (tester) async {
      await pumpTestApp(tester, preferences: _onboarded);
      await openPlan(tester);
      await openAddSheet(tester);

      await tester.enterText(addField, 'gy');
      await tester.pump();
      expect(find.textContaining('Workout · Exercises'), findsOneWidget);
      expect(find.textContaining('Ready-made'), findsNothing, reason: 'one');

      await tester.tap(find.widgetWithText(ListTile, 'Gym'));
      await tester.pump();
      expect(find.widgetWithText(TextField, 'Gym'), findsOneWidget);
    });

    testAppWidgets('your activity is suggested instead of the built-in one '
        'with its name, so typing never makes a second one (A8)', (
      tester,
    ) async {
      await pumpTestApp(tester, preferences: _onboarded, seed: seedReading);
      await openPlan(tester);
      await openAddSheet(tester);

      await tester.enterText(addField, 'Rea');
      await tester.pump();
      // Others containing "rea" (Breathing…) may show; Reading only once.
      expect(find.widgetWithText(ListTile, 'Reading'), findsOneWidget);
      expect(find.text('Your activity'), findsNothing, reason: 'no labels');
    });

    testAppWidgets('Time… sets a suggested start and a length', (tester) async {
      await pumpTestApp(tester, preferences: _onboarded);
      await openPlan(tester);
      await openAddSheet(tester);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Time…'));
      await tester.pumpAndSettle();
      // The test clock is 08:00: the next half hours are suggested.
      expect(find.text('When?'), findsOneWidget);
      await tester.tap(find.widgetWithText(ChoiceChip, '9:00 AM'));
      await tester.tap(find.widgetWithText(ChoiceChip, '30 min'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(ChoiceChip, '9:00 AM–9:30 AM'),
        findsOneWidget,
      );

      await tester.enterText(addField, 'Bath');
      await tester.pump();
      await tester.tap(find.text('Make “Bath” yours'));
      await tester.pump();
      await tester.tap(find.widgetWithText(AppButton, 'Add'));
      await tester.pumpAndSettle();
      expect(itemRow('Bath'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(PlanItemTile),
          matching: find.text('9:00 AM'),
        ),
        findsOneWidget,
      );
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

    await openAddSheet(tester);
    await tester.enterText(addField, 'reading');
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Reading'))
          .selected,
      isTrue,
      reason: 'the typed name selects the activity',
    );
    await tester.tap(find.widgetWithText(AppButton, 'Add'));
    await tester.pumpAndSettle();

    await openItem(tester, itemRow('Reading'));
    expect(find.text('Book *'), findsOneWidget, reason: 'not a task');
  });

  testAppWidgets('typing a built-in activity\'s name saves it and plans it', (
    tester,
  ) async {
    await pumpTestApp(tester, preferences: _onboarded);
    await openPlan(tester);

    await addTyped(tester, 'Gym');

    expect(itemRow('Gym'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing, reason: 'no pop-up (A9)');
    await openItem(tester, find.byType(PlanItemTile));
    await tester.scrollUntilVisible(
      find.text('Add Exercise'),
      200,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    expect(find.text('Add Exercise'), findsOneWidget);
  });

  testAppWidgets('Done on a 21:10–21:55 plan records its 45 minutes', (
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
    await scrollAndTap(tester, _doneButton);
    await skipHowDidItGo(tester);

    expect(
      find.descendant(of: find.byType(ItemCard), matching: find.text('45 min')),
      findsOneWidget,
      reason: 'the result on the row',
    );
  });

  group('anything can be logged, added right inside the item', () {
    Future<void> openNewItem(WidgetTester tester, String name) async {
      await pumpTestApp(tester, preferences: _onboarded);
      await openPlan(tester);
      await addNew(tester, name);
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
      await tester.tap(find.text('Done').last);
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
      await tester.tap(find.text('Done').last);
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
      await skipHowDidItGo(tester);
      expect(find.byTooltip('Mark as not done'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ItemCard),
          matching: find.text('1h 0m'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Mark as done'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ItemCard),
          matching: find.text('1h 0m'),
        ),
        findsOneWidget,
        reason: 'no log: back to its planned length',
      );
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
        tester.getTopLeft(itemRow('Standup')).dy,
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
    testAppWidgets('repeat a plan on chosen days; the week shows each one', (
      tester,
    ) async {
      await pumpTestApp(tester, preferences: _onboarded, seed: seedReadingPlan);
      await openPlan(tester);

      await rowOptions(tester, 'Read');
      await tester.tap(find.text('Repeat…'));
      await tester.pumpAndSettle();
      // Starts on the plan's weekday (Sat 3 Oct); add Monday.
      await tester.tap(find.widgetWithText(FilterChip, 'Mon'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Repeats Mon, Sat'), findsOneWidget);

      expect(find.byIcon(AppIcons.repeat), findsOneWidget, reason: 'on row');
      // Next week (locale weeks start on Sunday): Mon 5 and Sat 10.
      await tester.tap(find.byTooltip('Next week'));
      await tester.pumpAndSettle();
      expect(itemRow('Read'), findsOneWidget, reason: 'Sat 10');
      await selectDay(tester, 'Monday, October 5, 2026');
      expect(itemRow('Read'), findsOneWidget);
      expect(find.byIcon(AppIcons.repeat), findsOneWidget);
    });

    testAppWidgets('month shows the calendar; tapping a day selects it in '
        'the week', (tester) async {
      await pumpTestApp(tester, preferences: _onboarded, seed: seedReadingPlan);
      await openPlanTab(tester);

      await tester.tap(find.text('Month'));
      await tester.pumpAndSettle();
      expect(find.text('October 2026'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Saturday, October 3, 2026'));
      await tester.pumpAndSettle();
      expect(find.byType(PlanWeekView), findsOneWidget);
      expect(itemRow('Read'), findsOneWidget);
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
      expect(itemRow('Read'), findsOneWidget, reason: 'Sat 10');
    });
  });
}
