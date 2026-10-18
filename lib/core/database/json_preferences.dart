import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../time/clock.dart';
import '../time/clock_provider.dart';
import 'app_database.dart';
import 'database_provider.dart';

/// Small settings and state kept as JSON in `app_preferences` (ADR-012), so
/// a feature can store what it needs without a schema change: Pomodoro,
/// routines, app lock, automatic backups, the review prompt. Unreadable
/// values read as null; callers fall back to their defaults.
class JsonPreferences {
  JsonPreferences(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  Stream<Object?> watch(String key) =>
      (_db.select(_db.appPreferences)..where((t) => t.key.equals(key)))
          .watchSingleOrNull()
          .map((row) => _decode(row?.valueJson));

  Future<Object?> read(String key) async {
    final row = await (_db.select(
      _db.appPreferences,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return _decode(row?.valueJson);
  }

  Future<void> write(String key, Object? value) => _db
      .into(_db.appPreferences)
      .insertOnConflictUpdate(
        AppPreferencesCompanion.insert(
          key: key,
          valueJson: jsonEncode(value),
          updatedAt: _clock.nowUtc().millisecondsSinceEpoch,
        ),
      );

  static Object? _decode(String? raw) {
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }
}

final jsonPreferencesProvider = Provider<JsonPreferences>(
  (ref) =>
      JsonPreferences(ref.watch(appDatabaseProvider), ref.watch(clockProvider)),
);

/// Reads [key] from a JSON map, or [fallback] when missing or of another
/// type.
T readJson<T>(Object? json, String key, T fallback) {
  if (json is! Map) return fallback;
  final value = json[key];
  if (value is T) return value;
  // JSON numbers decode as int when whole.
  if (fallback is double && value is int) return value.toDouble() as T;
  return fallback;
}
