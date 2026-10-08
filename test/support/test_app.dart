import 'package:daylog/app/app.dart';
import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/database/database_provider.dart';
import 'package:daylog/core/logging/app_logger.dart';
import 'package:daylog/core/time/clock_provider.dart';
import 'package:daylog/features/settings/data/db_app_preferences_repository.dart';
import 'package:daylog/features/settings/domain/preferences_snapshot.dart';
import 'package:daylog/features/settings/presentation/preferences_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:daylog/features/focus/presentation/focus_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_clock.dart';

/// A fresh in-memory database built through the production migrations.
AppDatabase newTestDatabase() => AppDatabase(NativeDatabase.memory());

final _openDatabases = <AppDatabase>[];

/// Like [testWidgets], but cleans up databases opened by [pumpTestApp]
/// inside the test body. drift stream subscriptions schedule zero-length
/// timers when cancelled, and closing the database needs real async, so this
/// can't happen in a tear-down callback.
void testAppWidgets(String description, WidgetTesterCallback body) {
  testWidgets(description, (tester) async {
    try {
      await body(tester);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
      final databases = List.of(_openDatabases);
      _openDatabases.clear();
      await tester.runAsync(() async {
        for (final db in databases) {
          await db.close();
        }
      });
    }
  });
}

/// Pumps the full app with an in-memory database at the given window size.
/// Like `bootstrap()`, the database holds [preferences] and the same values
/// are the startup snapshot. Only use inside [testAppWidgets].
Future<AppDatabase> pumpTestApp(
  WidgetTester tester, {
  Size size = const Size(412, 915),
  PreferencesSnapshot preferences = PreferencesSnapshot.defaults,
  Future<void> Function(AppDatabase db, FakeClock clock)? seed,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final clock = FakeClock(DateTime.utc(2026, 10, 3, 8));
  final db = newTestDatabase();
  _openDatabases.add(db);
  await tester.runAsync(() async {
    final repository = DbAppPreferencesRepository(db, clock, const AppLogger());
    await repository.setTheme(preferences.theme);
    await repository.setOnboardingCompleted(
      completed: preferences.onboardingCompleted,
    );
    await seed?.call(db, clock);
  });
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(clock),
        initialPreferencesProvider.overrideWithValue(preferences),
        // No once-a-second ticker in widget tests (it would keep frames
        // pending); timers still derive elapsed time from the fake clock.
        focusTickProvider.overrideWith((ref) => Stream.value(clock.nowUtc())),
      ],
      child: const App(),
    ),
  );
  await tester.pumpAndSettle();
  return db;
}
