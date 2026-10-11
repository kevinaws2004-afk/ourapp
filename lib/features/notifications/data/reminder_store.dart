import 'dart:convert';

import '../../../core/database/app_database.dart';
import '../../../core/time/clock.dart';
import '../../plans/domain/plan.dart';
import '../../plans/domain/plan_series.dart';
import '../domain/notification_settings.dart';

/// Reminders and notification settings, kept in `app_preferences` as JSON
/// (no schema change). Reminders map `plan:<id>` or `series:<id>` to minutes
/// before the start (0 = at start). A plan's own entry wins over its
/// series'; entries of deleted plans are simply never matched.
class ReminderStore {
  ReminderStore(this._db, this._clock);

  static const remindersKey = 'reminders';
  static const settingsKey = 'notification_settings';

  final AppDatabase _db;
  final Clock _clock;

  Stream<Map<String, int>> watchReminders() => _watch(remindersKey).map((raw) {
    final decoded = _decode(raw);
    if (decoded is! Map) return const <String, int>{};
    return {
      for (final MapEntry(:key, :value) in decoded.entries)
        if (key is String && value is int) key: value,
    };
  });

  Stream<NotificationSettings> watchSettings() =>
      _watch(settingsKey)
          .map((raw) => NotificationSettings.fromJson(_decode(raw)));

  Future<void> setSettings(NotificationSettings settings) =>
      _write(settingsKey, settings.toJson());

  Future<void> setPlanReminder(PlanId id, int? minutes) =>
      _setReminder('plan:${id.value}', minutes);

  Future<void> setSeriesReminder(PlanSeriesId id, int? minutes) =>
      _setReminder('series:${id.value}', minutes);

  Future<void> _setReminder(String key, int? minutes) async {
    final row = await (_db.select(
      _db.appPreferences,
    )..where((t) => t.key.equals(remindersKey))).getSingleOrNull();
    final decoded = _decode(row?.valueJson);
    final next = <String, int>{
      if (decoded is Map)
        for (final MapEntry(:key, :value) in decoded.entries)
          if (key is String && value is int) key: value,
    };
    if (minutes == null) {
      // An explicit "none" on a plan overrides its series.
      if (key.startsWith('plan:')) {
        next[key] = -1;
      } else {
        next.remove(key);
      }
    } else {
      next[key] = minutes;
    }
    await _write(remindersKey, next);
  }

  Stream<String?> _watch(String key) =>
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

  Object? _decode(String? raw) {
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }
}

/// [plan]'s reminder in minutes before its start, or null for none.
int? reminderFor(Plan plan, Map<String, int> reminders) {
  final own = reminders['plan:${plan.id.value}'];
  if (own != null) return own < 0 ? null : own;
  final series = plan.seriesId;
  if (series == null) return null;
  return reminders['series:${series.value}'];
}
