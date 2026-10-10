import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/design/themes/app_theme_id.dart';
import 'package:daylog/core/time/local_date.dart';
import 'package:daylog/features/activity_types/data/db_activity_type_repository.dart';
import 'package:daylog/features/activity_types/domain/activity_ids.dart';
import 'package:daylog/features/activity_types/domain/activity_type_use_cases.dart';
import 'package:daylog/features/plans/data/db_plan_repository.dart';
import 'package:daylog/features/plans/domain/plan.dart';
import 'package:daylog/features/plans/domain/plan_use_cases.dart';
import 'package:daylog/features/plans/presentation/plan_screen.dart';
import 'package:daylog/features/settings/domain/preferences_snapshot.dart';
import 'package:daylog/features/today/presentation/now_next_card.dart';
import 'package:daylog/shared/widgets/app_button.dart';
import 'package:daylog/shared/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';
import '../../support/fixtures.dart';
import '../../support/test_app.dart';

/// The edges of the day on Today (ADR-046, T2, T7–T10) and the + sheet
/// (AD1–AD5). The test clock is Sat Oct 3 2026, 08:00 (UTC).
const _onboarded = PreferencesSnapshot(
  theme: AppThemeId.rose,
  onboardingCompleted: true,
);

final _today = LocalDate(2026, 10, 3);

/// Reading, and plans for it: (date, hour or null for Anytime, title).
Future<ActivityTypeId> _seedReading(
  AppDatabase db,
  FakeClock clock,
  List<(LocalDate, int?, String)> plans,
) async {
  final ids = SequentialIdGenerator();
  final types = DbActivityTypeRepository(db, clock);
  final typeId = await CreateActivityType(types, ids)(readingDefinition());
  final create = CreatePlan(DbPlanRepository(db, clock), types, ids, clock);
  for (final (date, hour, title) in plans) {
    final start = hour == null
        ? null
        : DateTime.utc(date.year, date.month, date.day, hour);
    await create(
      PlanDraft(
        planDate: date,
        title: title,
        activityTypeId: typeId,
        plannedStartAt: start,
        plannedEndAt: start?.add(const Duration(minutes: 30)),
      ),
    );
  }
  return typeId;
}

Finder _row(String title) =>
    find.descendant(of: find.byType(ItemCard), matching: find.text(title));

void main() {
  group('From yesterday (T2)', () {
    testAppWidgets('Do today brings it to today; a passed time becomes '
        'Anytime', (tester) async {
      await pumpTestApp(
        tester,
        preferences: _onboarded,
        seed: (db, clock) =>
            _seedReading(db, clock, [(_today.addDays(-1), 7, 'Morning read')]),
      );
      expect(find.text('From yesterday'), findsOneWidget);
      expect(find.text('Morning read · 7:00 AM'), findsOneWidget);

      await tester.tap(find.text('Do today'));
      await tester.pumpAndSettle();

      expect(find.text('From yesterday'), findsNothing, reason: 'decided');
      expect(find.text('Moved to today'), findsOneWidget);
      expect(_row('Morning read'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(NowNextCard),
          matching: find.text('ANYTIME'),
        ),
        findsOneWidget,
        reason: '7:00 has passed',
      );
    });

    testAppWidgets('Let it go skips it on yesterday, with Undo', (
      tester,
    ) async {
      await pumpTestApp(
        tester,
        preferences: _onboarded,
        seed: (db, clock) => _seedReading(db, clock, [
          (_today.addDays(-1), 7, 'Morning read'),
          (_today.addDays(-1), 21, 'Night read'),
        ]),
      );
      await tester.tap(find.text('Let all go'));
      await tester.pumpAndSettle();
      expect(find.text('From yesterday'), findsNothing);
      expect(find.text('2 let go'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.text('From yesterday'), findsOneWidget);
    });

    testAppWidgets('not after noon', (tester) async {
      await pumpTestApp(
        tester,
        preferences: _onboarded,
        seed: (db, clock) async {
          await _seedReading(db, clock, [
            (_today.addDays(-1), 7, 'Morning read'),
          ]);
          clock.advance(const Duration(hours: 4)); // 12:00
        },
      );
      expect(find.text('From yesterday'), findsNothing);
    });
  });

  group('evening review (T7/T8)', () {
    Future<void> evening(AppDatabase db, FakeClock clock) async {
      await _seedReading(db, clock, [
        (_today, 9, 'Read'),
        (_today, 18, 'Evening read'),
      ]);
      clock.advance(const Duration(hours: 12)); // 20:00
    }

    testAppWidgets('after the last thing\'s time: the day in a sentence, '
        'what\'s not done with Tomorrow / Let it go, Plan tomorrow', (
      tester,
    ) async {
      await pumpTestApp(tester, preferences: _onboarded, seed: evening);

      expect(find.text('0 of 2 done'), findsOneWidget);
      expect(find.text('Not done'), findsOneWidget);
      expect(find.byType(NowNextCard), findsNothing, reason: 'replaced');

      await tester.tap(find.text('Tomorrow').first);
      await tester.pumpAndSettle();
      expect(find.text('Moved to tomorrow'), findsOneWidget);
      await tester.tap(find.text('Let it go'));
      await tester.pumpAndSettle();

      expect(find.text('Day closed · 0 of 0 done'), findsOneWidget);
      await tester.tap(find.text('Plan tomorrow'));
      await tester.pumpAndSettle();
      expect(find.byType(PlanScreen), findsOneWidget);
    });

    testAppWidgets('not before 17:00', (tester) async {
      await pumpTestApp(
        tester,
        preferences: _onboarded,
        seed: (db, clock) async {
          await _seedReading(db, clock, [(_today, 7, 'Read')]);
          clock.advance(const Duration(hours: 8)); // 16:00
        },
      );
      expect(find.text('Not done'), findsNothing);
      expect(find.text('Plan tomorrow'), findsNothing);
    });
  });

  group('nothing planned (T9/T10)', () {
    testAppWidgets('first use: one step, and common activities that add in '
        'one tap', (tester) async {
      await pumpTestApp(tester, preferences: _onboarded);
      expect(find.text('Your day is empty.'), findsOneWidget);
      expect(find.widgetWithText(AppButton, 'Add to today'), findsOneWidget);

      await tester.tap(find.widgetWithText(ActionChip, 'Walking'));
      await tester.pumpAndSettle();
      expect(find.text('Walking added to today'), findsOneWidget);
      expect(_row('Walking'), findsOneWidget);
    });

    testAppWidgets('returning: your usual Saturday, at its usual time', (
      tester,
    ) async {
      await pumpTestApp(
        tester,
        preferences: _onboarded,
        seed: (db, clock) => _seedReading(db, clock, [
          (_today.addDays(-7), 10, 'Read'),
          (_today.addDays(-14), 10, 'Read'),
        ]),
      );
      expect(find.text('Nothing planned today.'), findsOneWidget);
      expect(find.text('Your usual Saturday'), findsOneWidget);

      await tester.tap(find.widgetWithText(ActionChip, 'Reading · 10:00 AM'));
      await tester.pumpAndSettle();
      expect(_row('Reading'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ItemCard),
          matching: find.text('10:00 AM'),
        ),
        findsOneWidget,
      );
    });
  });

  group('the + sheet (AD1–AD5)', () {
    Future<void> openAdd(WidgetTester tester) async {
      await tester.tap(find.byTooltip('Add to today'));
      await tester.pumpAndSettle();
      expect(find.text('Add to today'), findsWidgets);
    }

    testAppWidgets('a new name becomes yours with nothing to set up', (
      tester,
    ) async {
      await pumpTestApp(tester, preferences: _onboarded);
      await openAdd(tester);
      expect(find.text('Common'), findsOneWidget, reason: 'first use');

      await tester.enterText(
        find.widgetWithText(TextField, 'What are you doing?'),
        'Pottery',
      );
      await tester.pump();
      await tester.tap(find.text('Make “Pottery” yours'));
      await tester.pump();
      await tester.tap(find.widgetWithText(AppButton, 'Add'));
      await tester.pumpAndSettle();

      expect(find.text('New activity'), findsNothing, reason: 'no builder');
      expect(_row('Pottery'), findsOneWidget);
    });

    testAppWidgets('a Recent activity adds in one tap', (tester) async {
      await pumpTestApp(
        tester,
        preferences: _onboarded,
        seed: (db, clock) =>
            _seedReading(db, clock, [(_today.addDays(-1), null, 'Read')]),
      );
      await openAdd(tester);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Reading'));
      await tester.pumpAndSettle();
      expect(find.text('What are you doing?'), findsNothing, reason: 'closed');
      expect(_row('Reading'), findsOneWidget);
    });

    testAppWidgets('Repeat on chosen weekdays', (tester) async {
      await pumpTestApp(tester, preferences: _onboarded);
      await openAdd(tester);
      await tester.enterText(
        find.widgetWithText(TextField, 'What are you doing?'),
        'Gym',
      );
      await tester.pump();
      await tester.tap(find.widgetWithText(ChoiceChip, 'Repeat'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'Mon'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ChoiceChip, 'Mon, Sat'), findsOneWidget);

      await tester.tap(find.widgetWithText(AppButton, 'Add'));
      await tester.pumpAndSettle();
      expect(_row('Gym'), findsOneWidget);
    });
  });
}
