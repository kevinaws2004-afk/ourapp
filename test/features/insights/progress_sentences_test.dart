import 'package:daylog/core/design/themes/app_theme_id.dart';
import 'package:daylog/core/logging/app_logger.dart';
import 'package:daylog/features/activity_logs/data/db_activity_log_repository.dart';
import 'package:daylog/features/activity_logs/domain/activity_log.dart';
import 'package:daylog/features/activity_logs/domain/activity_log_use_cases.dart';
import 'package:daylog/features/activity_logs/domain/field_value.dart';
import 'package:daylog/features/activity_types/data/db_activity_type_repository.dart';
import 'package:daylog/features/activity_types/domain/activity_type_use_cases.dart';
import 'package:daylog/features/plans/data/db_plan_repository.dart';
import 'package:daylog/features/settings/domain/preferences_snapshot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fixtures.dart';
import '../../support/test_app.dart';

const _onboarded = PreferencesSnapshot(
  theme: AppThemeId.papaya,
  onboardingCompleted: true,
);

void main() {
  testAppWidgets('Progress says how the period went in sentences first '
      '(ADR-046, PR1/PR4)', (tester) async {
    await pumpTestApp(
      tester,
      preferences: _onboarded,
      seed: (db, clock) async {
        final ids = SequentialIdGenerator();
        final types = DbActivityTypeRepository(db, clock);
        final reading = await CreateActivityType(types, ids)(
          readingDefinition(),
        );
        final book = (await types.getType(reading))!.activeFields.first.id;
        final log = LogActivity(
          types,
          DbActivityLogRepository(db, clock, const AppLogger()),
          DbPlanRepository(db, clock),
          ids,
          clock,
        );
        for (final day in [1, 2, 3]) {
          await log(
            reading,
            ActivityLogDraft(
              startedAt: DateTime.utc(2026, 10, day, 7),
              durationMs: 30 * 60000,
              values: {book: const TextValue('Antifragile')},
            ),
          );
        }
      },
    );
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Progress'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('You did 3 things this'), findsOneWidget);
    expect(
      find.text('Most of your time went to Reading (1h 30m).'),
      findsOneWidget,
    );
    expect(find.text('Progress builds as you go.'), findsNothing);
  });
}
