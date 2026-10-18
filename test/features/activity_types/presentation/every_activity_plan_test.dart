@Timeout(Duration(minutes: 10))
library;

import 'package:daylog/app/app.dart';
import 'package:daylog/app/router.dart';
import 'package:daylog/features/activity_types/presentation/activity_type_providers.dart';
import 'package:daylog/features/activity_types/presentation/built_in_activities.dart';
import 'package:daylog/features/plans/domain/plan.dart';
import 'package:daylog/features/plans/presentation/plan_date_notifier.dart';
import 'package:daylog/features/plans/presentation/plan_providers.dart';
import 'package:daylog/features/plans/presentation/item/item_screen.dart';
import 'package:daylog/features/settings/domain/preferences_snapshot.dart';
import 'package:daylog/core/design/themes/app_theme_id.dart';
import 'package:daylog/core/time/clock_provider.dart';
import 'package:daylog/l10n/generated/app_localizations_en.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_app.dart';

/// Every built-in activity can be added, planned for today, and opened as an
/// item that renders its fields without an error (E2E pass 2: "plan each
/// activity").
void main() {
  final builtIns = builtInActivities(AppLocalizationsEn());

  testAppWidgets('each built-in activity plans and opens', (tester) async {
    await pumpTestApp(
      tester,
      preferences: const PreferencesSnapshot(
        theme: AppThemeId.lavender,
        onboardingCompleted: true,
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    final container = ProviderScope.containerOf(
      tester.element(find.byType(App)),
    );
    final router = container.read(routerProvider);
    final today = currentLocalDate(container.read(clockProvider));

    for (final definition in builtIns) {
      late PlanId planId;
      await tester.runAsync(() async {
        final typeId = await container.read(addBuiltInActivityProvider)(
          definition,
        );
        planId = await container.read(createPlanProvider)(
          PlanDraft(planDate: today, title: '', activityTypeId: typeId),
        );
      });
      router.go(AppRoutes.today);
      await tester.pump(const Duration(milliseconds: 100));
      unawaited(router.push(AppRoutes.item(planId)));
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 150));
      }
      expect(tester.takeException(), isNull, reason: definition.name);
      expect(find.byType(ItemScreen), findsOneWidget, reason: definition.name);
      expect(
        find.text(definition.name),
        findsWidgets,
        reason: '${definition.name}: item screen shows it',
      );
    }
    expect(builtIns.length, greaterThan(100));
  });
}

void unawaited(Future<void> future) {}
