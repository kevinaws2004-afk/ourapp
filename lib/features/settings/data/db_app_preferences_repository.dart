import 'dart:convert';

import '../../../core/database/app_database.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/time/clock.dart';
import '../domain/app_preferences_repository.dart';
import '../domain/preferences_snapshot.dart';
import '../../../core/design/themes/app_theme_id.dart';

/// Stores preferences as JSON values keyed by name in `app_preferences`
/// (ADR-012). Unreadable values fall back to the default instead of failing.
/// The old `theme_mode` (system/light/dark) value is ignored since the app
/// became light-only with three themes (ADR-045).
class DbAppPreferencesRepository implements AppPreferencesRepository {
  DbAppPreferencesRepository(this._db, this._clock, this._logger);

  static const themeKey = 'theme';
  static const onboardingCompletedKey = 'onboarding_completed';

  final AppDatabase _db;
  final Clock _clock;
  final AppLogger _logger;

  @override
  Future<PreferencesSnapshot> load() async {
    final rows = await _db.select(_db.appPreferences).get();
    final byKey = {for (final row in rows) row.key: row.valueJson};
    return PreferencesSnapshot(
      theme: _decodeTheme(byKey[themeKey]),
      onboardingCompleted: _decodeBool(
        byKey[onboardingCompletedKey],
        key: onboardingCompletedKey,
      ),
    );
  }

  @override
  Stream<AppThemeId> watchTheme() =>
      _watchRaw(themeKey).map(_decodeTheme).distinct();

  @override
  Future<void> setTheme(AppThemeId value) => _write(themeKey, value.name);

  @override
  Stream<bool> watchOnboardingCompleted() =>
      _watchRaw(onboardingCompletedKey)
          .map((raw) => _decodeBool(raw, key: onboardingCompletedKey))
          .distinct();

  @override
  Future<void> setOnboardingCompleted({required bool completed}) =>
      _write(onboardingCompletedKey, completed);

  Stream<String?> _watchRaw(String key) =>
      (_db.select(_db.appPreferences)..where((t) => t.key.equals(key)))
          .watchSingleOrNull()
          .map((row) => row?.valueJson);

  Future<void> _write(String key, Object value) => _db
      .into(_db.appPreferences)
      .insertOnConflictUpdate(
        AppPreferencesCompanion.insert(
          key: key,
          valueJson: jsonEncode(value),
          updatedAt: _clock.nowUtc().millisecondsSinceEpoch,
        ),
      );

  AppThemeId _decodeTheme(String? raw) {
    final decoded = _decode(raw, key: themeKey);
    if (decoded == null) return PreferencesSnapshot.defaults.theme;
    for (final value in AppThemeId.values) {
      if (value.name == decoded) return value;
    }
    _logger.warning('Unknown value for preference "$themeKey"; using default.');
    return PreferencesSnapshot.defaults.theme;
  }

  bool _decodeBool(String? raw, {required String key}) {
    final decoded = _decode(raw, key: key);
    if (decoded is bool) return decoded;
    if (decoded != null) {
      _logger.warning('Non-boolean value for preference "$key"; using false.');
    }
    return false;
  }

  Object? _decode(String? raw, {required String key}) {
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } on FormatException catch (error, stackTrace) {
      _logger.warning(
        'Unreadable JSON for preference "$key"; using default.',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}
