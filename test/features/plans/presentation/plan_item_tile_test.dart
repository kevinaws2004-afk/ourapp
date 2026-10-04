import 'package:daylog/core/design/app_theme.dart';
import 'package:daylog/core/time/local_date.dart';
import 'package:daylog/features/activity_types/domain/activity_ids.dart';
import 'package:daylog/features/plans/domain/plan.dart';
import 'package:daylog/features/plans/domain/watch_day_overview.dart';
import 'package:daylog/features/plans/presentation/widgets/plan_item_tile.dart';
import 'package:daylog/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Regression: the plans stream can emit a plan before the types stream has
  // its just-created activity type (seen on device); the tile must not throw.
  testWidgets('an activity plan whose type has not loaded yet still renders', (
    tester,
  ) async {
    final created = DateTime.utc(2026, 10, 4, 8);
    final plan = Plan(
      id: const PlanId('plan-1'),
      planDate: LocalDate(2026, 10, 4),
      activityTypeId: const ActivityTypeId('type-not-loaded'),
      title: 'Gym',
      sortOrder: 0,
      status: PlanStatus.planned,
      createdAt: created,
      updatedAt: created,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PlanItemTile(
            item: PlannedItem(
              plan: plan,
              type: null,
              records: const [],
              status: EffectivePlanStatus.planned,
            ),
            onTap: () {},
            onMore: () {},
            onToggleTask: () {},
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Gym'), findsOneWidget);
  });
}
