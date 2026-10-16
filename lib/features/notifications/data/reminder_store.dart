import 'dart:convert';

import '../../../core/database/app_database.dart';
import '../../../core/time/clock.dart';
import '../../plans/domain/plan.dart';
import '../../plans/domain/plan_series.dart';
import '../domain/notification_settings.dart';
import '../domain/plan_reminder.dart';

/// Reminders and notification settings, kept in `app_preferences` as JSON
/// (no schema change). Reminders map `plan:ID` / `series:ID` to minutes
/// before the start (0 = at start, -1 = none) and `planAt:ID` / `seriesAt:ID`
/// to a minute of the day; further reminders of the same item are
/// `plan+:ID#n` / `series+:ID#n` ([_encodeExtra]). A plan's own entries win
/// over its series'; entries of deleted plans are simply never matched.
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

  /// Sets (or, with an empty list, turns off) [id]'s own reminders.
  Future<void> setPlanReminders(PlanId id, List<PlanReminder> reminders) =>
      _setReminders('plan', id.value, reminders, explicitNone: true);

  /// Sets the reminders every repeat of [id] gets.
  Future<void> setSeriesReminders(
    PlanSeriesId id,
    List<PlanReminder> reminders,
  ) => _setReminders('series', id.value, reminders, explicitNone: false);

  Future<void> _setReminders(
    String kind,
    String id,
    List<PlanReminder> reminders, {
    required bool explicitNone,
  }) async {
    final row = await (_db.select(
      _db.appPreferences,
    )..where((t) => t.key.equals(remindersKey))).getSingleOrNull();
    final decoded = _decode(row?.valueJson);
    final next = <String, int>{
      if (decoded is Map)
        for (final MapEntry(:key, :value) in decoded.entries)
          if (key is String && value is int) key: value,
    };
    final before = '$kind:$id';
    final at = '${kind}At:$id';
    final extra = '$kind+:$id#';
    next
      ..remove(before)
      ..remove(at)
      ..removeWhere((key, _) => key.startsWith(extra));
    switch (reminders.firstOrNull) {
      case ReminderBefore(:final minutes):
        next[before] = minutes;
      case ReminderAt(:final minuteOfDay):
        next[at] = minuteOfDay;
      case null:
        // An explicit "none" on a plan overrides its series'.
        if (explicitNone) next[before] = -1;
    }
    for (final (i, reminder) in reminders.skip(1).indexed) {
      next['$extra$i'] = _encodeExtra(reminder);
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

/// A further reminder as one number: minutes before as they are, a time of
/// day as `-(minute + 1)`.
int _encodeExtra(PlanReminder reminder) => switch (reminder) {
  ReminderBefore(:final minutes) => minutes,
  ReminderAt(:final minuteOfDay) => -(minuteOfDay + 1),
};

PlanReminder _decodeExtra(int value) =>
    value >= 0 ? ReminderBefore(value) : ReminderAt(-value - 1);

/// [plan]'s first reminder, or null for none.
PlanReminder? reminderFor(Plan plan, Map<String, int> reminders) =>
    remindersFor(plan, reminders).firstOrNull;

/// [plan]'s reminders (its own, else its series'), earliest set first.
List<PlanReminder> remindersFor(Plan plan, Map<String, int> reminders) {
  List<PlanReminder>? read(String kind, String id) {
    final PlanReminder first;
    if (reminders['$kind:$id'] case final m?) {
      if (m < 0) return const [];
      first = ReminderBefore(m);
    } else if (reminders['${kind}At:$id'] case final at?) {
      first = ReminderAt(at);
    } else {
      return null;
    }
    final prefix = '$kind+:$id#';
    final extras =
        reminders.entries.where((e) => e.key.startsWith(prefix)).toList()
          ..sort((a, b) => a.key.compareTo(b.key));
    return [first, for (final e in extras) _decodeExtra(e.value)];
  }

  return read('plan', plan.id.value) ??
      switch (plan.seriesId?.value) {
        final series? => read('series', series),
        null => null,
      } ??
      const [];
}
