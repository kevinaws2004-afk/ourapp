import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/logging/app_logger.dart';
import 'package:daylog/features/activity_logs/data/db_activity_log_repository.dart';
import 'package:daylog/features/activity_logs/domain/activity_log.dart';
import 'package:daylog/features/activity_logs/domain/activity_log_use_cases.dart';
import 'package:daylog/features/activity_logs/domain/field_value.dart';
import 'package:daylog/features/activity_logs/presentation/log_editor_screen.dart';
import 'package:daylog/features/activity_types/data/db_activity_type_repository.dart';
import 'package:daylog/features/plans/data/db_plan_repository.dart';
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

Future<void> openPlan(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Plan'),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testAppWidgets('Plan opens on today and shows what was recorded today', (
    tester,
  ) async {
    await pumpTestApp(tester, preferences: _onboarded, seed: seedTodayRecord);
    await openPlan(tester);

    expect(find.text('Today'), findsWidgets);
    expect(find.text('Saturday, October 3, 2026'), findsOneWidget);
    expect(find.text('Planned'), findsOneWidget);
    expect(find.text('Nothing planned for this day.'), findsOneWidget);
    expect(find.text('Recorded'), findsOneWidget);
    expect(find.text('Fooled by Randomness'), findsOneWidget);
  });

  testAppWidgets(
    'selecting another day shows that day; future days have no Recorded section',
    (tester) async {
      await pumpTestApp(tester, preferences: _onboarded, seed: seedTodayRecord);
      await openPlan(tester);

      await tester.tap(find.byTooltip('Next week'));
      await tester.pumpAndSettle();
      expect(find.text('Saturday, October 10, 2026'), findsOneWidget);
      expect(find.text('Recorded'), findsNothing);

      await tester.tap(find.widgetWithText(TextButton, 'Today'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Previous week'));
      await tester.pumpAndSettle();
      expect(find.text('Saturday, September 26, 2026'), findsOneWidget);
      expect(find.text('Nothing recorded on this day.'), findsOneWidget);
    },
  );

  testAppWidgets('tapping a recorded activity opens it for editing', (
    tester,
  ) async {
    await pumpTestApp(tester, preferences: _onboarded, seed: seedTodayRecord);
    await openPlan(tester);

    await tester.tap(find.text('Fooled by Randomness'));
    await tester.pumpAndSettle();

    expect(find.byType(LogEditorScreen), findsOneWidget);
    expect(find.text('Edit record'), findsOneWidget);
  });

  testAppWidgets('the calendar button opens a date picker', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded);
    await openPlan(tester);

    await tester.tap(find.byTooltip('Choose a date'));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsOneWidget);
  });
}
