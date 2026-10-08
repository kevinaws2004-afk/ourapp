import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/logging/app_logger.dart';
import 'package:daylog/core/time/local_date.dart';
import 'package:daylog/features/activity_logs/data/db_activity_log_repository.dart';
import 'package:daylog/features/activity_logs/domain/activity_log.dart';
import 'package:daylog/features/activity_logs/domain/activity_log_use_cases.dart';
import 'package:daylog/features/activity_logs/domain/field_value.dart';
import 'package:daylog/features/activity_types/data/db_activity_type_repository.dart';
import 'package:daylog/features/activity_types/domain/activity_ids.dart';
import 'package:daylog/features/activity_types/domain/activity_type_use_cases.dart';
import 'package:daylog/features/plans/data/db_plan_repository.dart';
import 'package:daylog/features/plans/domain/plan.dart';
import 'package:daylog/features/plans/domain/plan_use_cases.dart';
import 'package:daylog/features/plans/presentation/widgets/plan_item_tile.dart';
import 'package:daylog/features/settings/domain/preferences_snapshot.dart';
import 'package:daylog/core/design/themes/app_theme_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_clock.dart';
import '../../../support/fixtures.dart';
import '../../../support/test_app.dart';
import '../../activity_types/presentation/activities_flow_test.dart'
    show enterField, scrollAndTap;
import 'plan_screen_test.dart' show openPlan;
import 'plans_flow_test.dart'
    show closeItem, itemRow, openItem, saveOwnActivity, waitForSave;

const _onboarded = PreferencesSnapshot(
  theme: AppThemeId.lavender,
  onboardingCompleted: true,
);

/// Gym with one earlier session (Oct 2: Chest Press 60 kg × 8, twice) and a
/// Gym plan for today (Oct 3) with nothing logged yet.
Future<void> seedGymHistory(AppDatabase db, FakeClock clock) async {
  final ids = SequentialIdGenerator();
  final types = DbActivityTypeRepository(db, clock);
  final plans = DbPlanRepository(db, clock);
  final gymId = await CreateActivityType(types, ids)(gymDefinition());
  final gym = (await types.getType(gymId))!;
  ActivityFieldId f(String name) =>
      gym.fields.firstWhere((x) => x.name == name).id;
  GroupItem set() => GroupItem(
    id: GroupItemId(ids.newId()),
    values: {
      f('Weight'): const NumberValue(60, unitCode: 'kg'),
      f('Reps'): const NumberValue(8),
    },
  );
  await LogActivity(
    types,
    DbActivityLogRepository(db, clock, const AppLogger()),
    plans,
    ids,
    clock,
  )(
    gymId,
    ActivityLogDraft(
      startedAt: DateTime.utc(2026, 10, 2, 18),
      values: {
        f('Exercises'): RepeatingGroupValue([
          GroupItem(
            id: GroupItemId(ids.newId()),
            values: {
              f('Exercise'): const TextValue('Chest Press'),
              f('Sets'): RepeatingGroupValue([set(), set()]),
            },
          ),
        ]),
      },
    ),
  );
  await CreatePlan(plans, types, ids, clock)(
    PlanDraft(
      planDate: LocalDateFixture.today,
      title: '',
      activityTypeId: gymId,
    ),
  );
}

abstract final class LocalDateFixture {
  static final today = DateTime.utc(2026, 10, 3).toLocalDate();
}

extension on DateTime {
  LocalDate toLocalDate() => LocalDate(year, month, day);
}

void main() {
  testAppWidgets('a new session starts from last time in one tap (B1)', (
    tester,
  ) async {
    await pumpTestApp(tester, preferences: _onboarded, seed: seedGymHistory);
    await openPlan(tester);
    await openItem(tester, find.byType(PlanItemTile));

    expect(find.text('Last time · Fri, Oct 2'), findsOneWidget);
    await scrollAndTap(tester, find.text('Use last time'));
    await waitForSave(tester);
    expect(find.text('Use last time'), findsNothing, reason: 'filled now');

    await closeItem(tester);
    expect(find.textContaining('Chest Press 60 kg × 8 (×2)'), findsOneWidget);
  });

  testAppWidgets('naming a row shows what it was last time, and Use fills '
      'it (B2)', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded, seed: seedGymHistory);
    await openPlan(tester);
    await openItem(tester, find.byType(PlanItemTile));

    await scrollAndTap(tester, find.text('Add Exercise'));
    await enterField(tester, 'Exercise *', 'chest press');
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Last time: Chest Press 60 kg × 8 (×2)'),
      findsOneWidget,
    );

    await scrollAndTap(tester, find.widgetWithText(TextButton, 'Use'));
    expect(find.text('Set 2'), findsOneWidget, reason: 'both sets copied');
  });

  testAppWidgets('a rest timer runs between sets (B5)', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded, seed: seedGymHistory);
    await openPlan(tester);
    await openItem(tester, find.byType(PlanItemTile));
    await scrollAndTap(tester, find.text('Use last time'));

    await scrollAndTap(tester, find.widgetWithText(TextButton, 'Rest'));
    expect(find.text('Rest 01:30'), findsOneWidget);
    await tester.tap(find.text('+15 s'));
    await tester.pump();
    expect(find.text('Rest 01:45'), findsOneWidget);
    await tester.tap(find.text('Stop'));
    await tester.pump();
    expect(find.textContaining('Rest 01:'), findsNothing);
    await waitForSave(tester);
  });

  testAppWidgets('long-press a row for quick actions: duplicate, with Undo '
      '(B7)', (tester) async {
    await pumpTestApp(tester, preferences: _onboarded, seed: seedGymHistory);
    await openPlan(tester);

    await tester.longPress(find.byType(PlanItemTile));
    await tester.pumpAndSettle();
    expect(find.text('Move to tomorrow'), findsOneWidget);
    await tester.tap(find.text('Duplicate'));
    await tester.pumpAndSettle();
    expect(find.byType(PlanItemTile), findsNWidgets(2));

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.byType(PlanItemTile), findsOneWidget);
  });

  testAppWidgets('an item with nothing to log offers one-tap choices (B3); '
      'the field sheet keeps rare settings under Advanced (B4)', (
    tester,
  ) async {
    await pumpTestApp(tester, preferences: _onboarded);
    await openPlan(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Add an activity to this day'),
      'Lunch',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await saveOwnActivity(tester, 'Lunch');
    await openItem(tester, itemRow('Lunch'));

    await scrollAndTap(tester, find.widgetWithText(ActionChip, 'How it went'));
    expect(find.text('How it went'), findsOneWidget, reason: 'added at once');

    await scrollAndTap(tester, find.text('Add to log'));
    await scrollAndTap(tester, find.text('An amount'));
    expect(find.text('Required'), findsNothing);
    await tester.tap(find.text('Advanced'));
    await tester.pumpAndSettle();
    expect(find.text('Required'), findsOneWidget);
  });
}
