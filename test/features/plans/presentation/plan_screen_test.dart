import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/logging/app_logger.dart';
import 'package:daylog/features/activity_logs/data/db_activity_log_repository.dart';
import 'package:daylog/features/activity_logs/domain/activity_log.dart';
import 'package:daylog/features/activity_logs/domain/activity_log_use_cases.dart';
import 'package:daylog/features/activity_logs/domain/field_value.dart';
import 'package:daylog/features/activity_types/data/db_activity_type_repository.dart';
import 'package:daylog/features/plans/data/db_plan_repository.dart';
import 'package:daylog/features/plans/presentation/day_screen.dart';
import 'package:daylog/features/plans/presentation/item/item_screen.dart';
import 'package:daylog/features/activity_types/domain/activity_type_use_cases.dart';
import 'package:daylog/features/settings/domain/preferences_snapshot.dart';
import 'package:daylog/features/settings/domain/theme_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_clock.dart';
import '../../../support/fixtures.dart';
import '../../../support/test_app.dart';

const _onboarded = PreferencesSnapshot(
  themePreference: ThemePreference.light,
  onboardingCompleted: true,
);

/// Seeds a Reading type and one record for "today" (the FakeClock's date,
/// Sat Oct 3 2026).
Future<void> seedTodayRecord(AppDatabase db, FakeClock clock) async {
  final ids = SequentialIdGenerator();
  final types = DbActivityTypeRepository(db, clock);
  final typeId = await CreateActivityType(types, ids)(readingDefinition());
  final type = (await types.getType(typeId))!;
  await LogActivity(
    types,
    DbActivityLogRepository(db, clock, const AppLogger()),
    DbPlanRepository(db, clock),
    ids,
    clock,
  )(
    typeId,
    ActivityLogDraft(
      startedAt: clock.nowUtc(),
      durationMs: 2700000,
      values: {
        type.activeFields.first.id: const TextValue('Fooled by Randomness'),
      },
    ),
  );
}

/// Opens the Plan tab (its week view).
Future<void> openPlanTab(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Plan'),
    ),
  );
  await tester.pumpAndSettle();
}

/// Opens today's day from the Plan tab's week (A1). The test app's today is
/// Sat Oct 3 2026.
Future<void> openPlan(WidgetTester tester) async {
  await openPlanTab(tester);
  await tester.tap(find.text('Saturday, October 3, 2026'));
  await tester.pumpAndSettle();
  expect(find.byType(DayScreen), findsOneWidget);
}

void main() {
  testAppWidgets('Plan opens on the week; tapping today opens it as a day '
      'that lists what was done as an item', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded, seed: seedTodayRecord);
    await openPlanTab(tester);

    expect(find.text('Week'), findsOneWidget);
    expect(find.text('Day'), findsNothing, reason: 'no separate day view');
    expect(find.text('Fooled by Randomness'), findsOneWidget);

    await tester.tap(find.text('Saturday, October 3, 2026'));
    await tester.pumpAndSettle();
    expect(find.byType(DayScreen), findsOneWidget);
    expect(find.text('Today'), findsWidgets);
    expect(find.text('Recorded'), findsNothing, reason: 'one list of items');
    expect(find.text('Fooled by Randomness'), findsOneWidget);
    expect(
      find.byTooltip('Add plan'),
      findsOneWidget,
      reason: 'one "+" on the day (A2)',
    );
  });

  testAppWidgets('the day screen steps to other days', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded, seed: seedTodayRecord);
    await openPlan(tester);

    await tester.tap(find.byTooltip('Next day'));
    await tester.pumpAndSettle();
    expect(find.text('Sunday, October 4, 2026'), findsOneWidget);
    expect(find.text('Tomorrow'), findsOneWidget);
    expect(find.text('Nothing planned for this day.'), findsOneWidget);

    await tester.tap(find.byTooltip('Previous day'));
    await tester.tap(find.byTooltip('Previous day'));
    await tester.pumpAndSettle();
    expect(find.text('Friday, October 2, 2026'), findsOneWidget);
    expect(find.text('Yesterday'), findsOneWidget);
  });

  testAppWidgets('a record made without a plan opens as an item', (
    tester,
  ) async {
    await pumpTestApp(tester, preferences: _onboarded, seed: seedTodayRecord);
    await openPlan(tester);

    await tester.tap(find.text('Fooled by Randomness'));
    await tester.pumpAndSettle();

    expect(find.byType(ItemScreen), findsOneWidget);
    expect(find.byTooltip('Delete'), findsOneWidget);
  });

  testAppWidgets('the calendar button opens a date picker', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded);
    await openPlan(tester);

    await tester.tap(find.byTooltip('Choose a date'));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsOneWidget);
  });
}
