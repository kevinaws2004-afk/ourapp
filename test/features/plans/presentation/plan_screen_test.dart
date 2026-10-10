import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/logging/app_logger.dart';
import 'package:daylog/features/activity_logs/data/db_activity_log_repository.dart';
import 'package:daylog/features/activity_logs/domain/activity_log.dart';
import 'package:daylog/features/activity_logs/domain/activity_log_use_cases.dart';
import 'package:daylog/features/activity_logs/domain/field_value.dart';
import 'package:daylog/features/activity_types/data/db_activity_type_repository.dart';
import 'package:daylog/features/plans/data/db_plan_repository.dart';
import 'package:daylog/features/plans/presentation/plan_views.dart';
import 'package:daylog/features/plans/presentation/item/item_screen.dart';
import 'package:daylog/features/activity_types/domain/activity_type_use_cases.dart';
import 'package:daylog/features/settings/domain/preferences_snapshot.dart';
import 'package:daylog/core/design/themes/app_theme_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_clock.dart';
import '../../../support/fixtures.dart';
import '../../../support/test_app.dart';

const _onboarded = PreferencesSnapshot(
  theme: AppThemeId.lavender,
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

/// Opens the Plan tab on today (ADR-046 P1: the week strip with today
/// selected and its day under it). The test app's today is Sat Oct 3 2026.
Future<void> openPlan(WidgetTester tester) async {
  await openPlanTab(tester);
  expect(find.byType(PlanWeekView), findsOneWidget);
  expect(find.text('Today · Saturday, October 3'), findsOneWidget);
}

/// Selects a day in the week strip by its full date ("Sunday, October 4,
/// 2026").
Future<void> selectDay(WidgetTester tester, String fullDate) async {
  await tester.tap(
    find.bySemanticsLabel(RegExp('^${RegExp.escape(fullDate)}:')),
  );
  await tester.pumpAndSettle();
}

void main() {
  testAppWidgets('Plan opens on the week with today selected; the day lists '
      'what was done; the strip rings today', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded, seed: seedTodayRecord);
    await openPlan(tester);

    expect(find.text('Week'), findsOneWidget);
    expect(find.text('Fooled by Randomness'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Saturday, October 3, 2026: 1 of 1 done'),
      findsOneWidget,
    );
    expect(find.byTooltip('Add to this day'), findsOneWidget, reason: 'the +');
  });

  testAppWidgets('tapping a day in the strip selects it; an empty day offers '
      'a way in (P4)', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded, seed: seedTodayRecord);
    await openPlan(tester);

    await selectDay(tester, 'Friday, October 2, 2026');
    expect(find.text('Yesterday · Friday, October 2'), findsOneWidget);
    expect(find.text('Nothing planned for Friday.'), findsOneWidget);
    expect(find.text('Add something'), findsOneWidget);

    await tester.tap(find.byTooltip('Next week'));
    await tester.pumpAndSettle();
    expect(find.text('Friday, October 9'), findsOneWidget);
    await selectDay(tester, 'Sunday, October 4, 2026');
    expect(find.text('Tomorrow · Sunday, October 4'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Today'));
    await tester.pumpAndSettle();
    expect(find.text('Today · Saturday, October 3'), findsOneWidget);
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

  for (final id in AppThemeId.values) {
    testAppWidgets('the week strip lays out in ${id.name} at 200% text', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpTestApp(
        tester,
        size: const Size(360, 780),
        preferences: PreferencesSnapshot(theme: id, onboardingCompleted: true),
        seed: seedTodayRecord,
      );
      await openPlanTab(tester);
      expect(find.byType(PlanWeekView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
