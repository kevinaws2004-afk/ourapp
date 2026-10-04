import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/time/local_date.dart';
import 'package:daylog/features/activity_logs/presentation/form/field_editor_shell.dart';
import 'package:daylog/features/activity_logs/presentation/log_editor_screen.dart';
import 'package:daylog/features/activity_types/data/db_activity_type_repository.dart';
import 'package:daylog/features/activity_types/domain/activity_type_use_cases.dart';
import 'package:daylog/features/plans/data/db_plan_repository.dart';
import 'package:daylog/features/plans/domain/plan.dart';
import 'package:daylog/features/plans/domain/plan_use_cases.dart';
import 'package:daylog/features/settings/domain/preferences_snapshot.dart';
import 'package:daylog/features/settings/domain/theme_preference.dart';
import 'package:daylog/core/design/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_clock.dart';
import '../../../support/fixtures.dart';
import '../../../support/test_app.dart';
import '../../activity_types/presentation/activities_flow_test.dart'
    show scrollAndTap;
import 'plans_flow_test.dart' show tapToRecord;

const _onboarded = PreferencesSnapshot(
  themePreference: ThemePreference.light,
  onboardingCompleted: true,
);

/// Gym + a plan "Gym" for the test app's today (2026-10-03).
Future<void> seedGymPlan(AppDatabase db, FakeClock clock) async {
  final ids = SequentialIdGenerator();
  final types = DbActivityTypeRepository(db, clock);
  final typeId = await CreateActivityType(types, ids)(gymDefinition());
  await CreatePlan(DbPlanRepository(db, clock), types, ids, clock)(
    PlanDraft(
      planDate: LocalDate(2026, 10, 3),
      title: '',
      activityTypeId: typeId,
    ),
  );
}

Future<void> enterAt(
  WidgetTester tester,
  String label,
  int index,
  String text,
) async {
  final input = find.widgetWithText(TextField, label).at(index);
  await tester.ensureVisible(input);
  await tester.enterText(input, text);
  await tester.pumpAndSettle();
}

/// ADR-030: plan → tap → record the actual session (one record, many sets) →
/// the plan is done.
void main() {
  testAppWidgets('a planned Gym session is recorded with three sets from '
      'the plan, as one linked record', (tester) async {
    final db = await pumpTestApp(
      tester,
      preferences: _onboarded,
      seed: seedGymPlan,
    );

    await tapToRecord(tester, find.text('Gym'));
    expect(find.byType(LogEditorScreen), findsOneWidget);

    await scrollAndTap(tester, find.text('Add Exercise'));
    final exercise = find.descendant(
      of: find.widgetWithText(FieldEditorShell, 'Exercise *'),
      matching: find.byType(TextField),
    );
    await tester.ensureVisible(exercise);
    await tester.enterText(exercise, 'Chest Press');
    await tester.pumpAndSettle();
    for (final (i, (kg, reps)) in [
      ('60', '10'),
      ('65', '8'),
      ('70', '6'),
    ].indexed) {
      await scrollAndTap(tester, find.text('Add Set'));
      await enterAt(tester, 'Weight', i, kg);
      await enterAt(tester, 'Reps', i, reps);
    }
    FocusManager.instance.primaryFocus?.unfocus();
    await scrollAndTap(tester, find.widgetWithText(FilledButton, 'Save'));

    expect(find.byType(LogEditorScreen), findsNothing);
    expect(find.byIcon(AppIcons.taskDone), findsOneWidget, reason: '✓');

    final counts = await tester.runAsync(() async {
      final logs = await db
          .customSelect(
            'SELECT COUNT(*) AS c FROM activity_logs WHERE plan_id IS NOT NULL',
          )
          .getSingle();
      final items = await db
          .customSelect('SELECT COUNT(*) AS c FROM log_group_items')
          .getSingle();
      return (logs.read<int>('c'), items.read<int>('c'));
    });
    expect(counts, (1, 4), reason: 'one session: 1 exercise + 3 sets');
  });
}
