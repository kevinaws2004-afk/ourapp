import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/design/themes/app_theme_id.dart';
import 'package:daylog/core/logging/app_logger.dart';
import 'package:daylog/features/settings/data/db_app_preferences_repository.dart';
import 'package:daylog/features/settings/domain/preferences_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_clock.dart';
import '../../../support/test_app.dart';

void main() {
  late AppDatabase db;
  late FakeClock clock;
  late DbAppPreferencesRepository repository;

  setUp(() {
    db = newTestDatabase();
    clock = FakeClock(DateTime.utc(2026, 10, 3, 8));
    repository = DbAppPreferencesRepository(db, clock, const AppLogger());
  });

  tearDown(() => db.close());

  test('an empty database yields the default preferences', () async {
    expect(await repository.load(), PreferencesSnapshot.defaults);
  });

  test('saved preferences are read back', () async {
    await repository.setTheme(AppThemeId.papaya);
    await repository.setOnboardingCompleted(completed: true);

    expect(
      await repository.load(),
      const PreferencesSnapshot(
        theme: AppThemeId.papaya,
        onboardingCompleted: true,
      ),
    );
  });

  test('writes store JSON values and the clock time as UTC epoch ms', () async {
    await repository.setTheme(AppThemeId.rose);

    final row = await db.select(db.appPreferences).getSingle();
    expect(row.key, DbAppPreferencesRepository.themeKey);
    expect(row.valueJson, '"rose"');
    expect(row.updatedAt, clock.nowUtc().millisecondsSinceEpoch);
  });

  test(
    'updating a preference replaces its row and refreshes updated_at',
    () async {
      await repository.setTheme(AppThemeId.rose);
      clock.advance(const Duration(minutes: 5));
      await repository.setTheme(AppThemeId.papaya);

      final rows = await db.select(db.appPreferences).get();
      expect(rows, hasLength(1));
      expect(rows.single.valueJson, '"papaya"');
      expect(rows.single.updatedAt, clock.nowUtc().millisecondsSinceEpoch);
    },
  );

  test('the theme stream emits the default, then each change', () async {
    final emitted = repository.watchTheme().take(2).toList();
    await pumpEventQueue();

    await repository.setTheme(AppThemeId.rose);

    expect(await emitted, [AppThemeId.fallback, AppThemeId.rose]);
  });

  test('the old light/dark setting is ignored (ADR-045)', () async {
    await db
        .into(db.appPreferences)
        .insert(
          AppPreferencesCompanion.insert(
            key: 'theme_mode',
            valueJson: '"dark"',
            updatedAt: clock.nowUtc().millisecondsSinceEpoch,
          ),
        );

    expect((await repository.load()).theme, AppThemeId.fallback);
  });

  test('the onboarding stream reflects completion and reset', () async {
    final emitted = repository.watchOnboardingCompleted().take(3).toList();
    await pumpEventQueue();

    await repository.setOnboardingCompleted(completed: true);
    await pumpEventQueue();
    await repository.setOnboardingCompleted(completed: false);

    expect(await emitted, [false, true, false]);
  });

  test('unreadable or unknown stored values fall back to defaults', () async {
    final now = clock.nowUtc().millisecondsSinceEpoch;
    await db
        .into(db.appPreferences)
        .insert(
          AppPreferencesCompanion.insert(
            key: DbAppPreferencesRepository.themeKey,
            valueJson: '"sepia"',
            updatedAt: now,
          ),
        );
    await db
        .into(db.appPreferences)
        .insert(
          AppPreferencesCompanion.insert(
            key: DbAppPreferencesRepository.onboardingCompletedKey,
            valueJson: 'not json',
            updatedAt: now,
          ),
        );

    expect(await repository.load(), PreferencesSnapshot.defaults);
  });
}
