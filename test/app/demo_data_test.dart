import 'package:daylog/app/dev/demo_data.dart';
import 'package:daylog/core/database/database_provider.dart';
import 'package:daylog/core/time/clock_provider.dart';
import 'package:daylog/core/time/local_date.dart';
import 'package:daylog/features/activity_logs/presentation/activity_log_providers.dart';
import 'package:daylog/features/activity_types/presentation/activity_type_providers.dart';
import 'package:daylog/features/insights/presentation/insight_providers.dart';
import 'package:daylog/features/plans/presentation/plan_providers.dart';
import 'package:daylog/l10n/generated/app_localizations_en.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_clock.dart';
import '../support/test_app.dart';

void main() {
  test('demo data loads through the use cases, once', () async {
    final db = newTestDatabase();
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(
          FakeClock(
            DateTime.utc(2026, 10, 4, 15),
            offset: const Duration(hours: 2),
          ),
        ),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
    final l10n = AppLocalizationsEn();

    expect(await loadDemoData(container, l10n), DemoDataResult.loaded);

    final types = await container
        .read(activityTypeRepositoryProvider)
        .watchActiveTypes()
        .first;
    expect(types, hasLength(4));
    final charts = await container
        .read(insightRepositoryProvider)
        .watchCharts()
        .first;
    expect(charts, hasLength(4));
    final todayPlans = await container
        .read(planRepositoryProvider)
        .watchPlansForDay(LocalDate(2026, 10, 4))
        .first;
    expect(todayPlans, isNotEmpty);

    // A second run never duplicates data.
    expect(await loadDemoData(container, l10n), DemoDataResult.alreadyLoaded);
  });

  test('demo data can cover just a range of days, e.g. the 10 before '
      'today', () async {
    final db = newTestDatabase();
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(
          FakeClock(DateTime.utc(2026, 10, 5, 10)),
        ),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });

    expect(
      await loadDemoData(
        container,
        AppLocalizationsEn(),
        from: LocalDate(2026, 9, 25),
        to: LocalDate(2026, 10, 4),
      ),
      DemoDataResult.loaded,
    );

    final logs = container.read(activityLogRepositoryProvider);
    Future<int> recordsOn(LocalDate d) async =>
        (await logs.watchLogsForDay(d).first).length;
    expect(await recordsOn(LocalDate(2026, 10, 4)), greaterThan(0));
    expect(await recordsOn(LocalDate(2026, 9, 25)), greaterThan(0));
    expect(await recordsOn(LocalDate(2026, 9, 24)), 0, reason: 'before');
    expect(await recordsOn(LocalDate(2026, 10, 5)), 0, reason: 'today');
    final todayPlans = await container
        .read(planRepositoryProvider)
        .watchPlansForDay(LocalDate(2026, 10, 5))
        .first;
    expect(todayPlans, isEmpty, reason: 'the range ends yesterday');
  });
}
