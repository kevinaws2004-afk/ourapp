/// How new timed items get a reminder.
enum NewItemReminders {
  /// "Want a reminder?" every time something timed is added.
  ask,

  /// Always [NotificationSettings.defaultMinutes] before, without asking.
  always,

  /// Never, without asking.
  never;

  static NewItemReminders fromName(Object? name) =>
      values.where((v) => v.name == name).firstOrNull ?? ask;
}

/// Everything about notifications the user can change (Me → Notifications).
/// Times are minutes of the day, local.
class NotificationSettings {
  const NotificationSettings({
    this.enabled = true,
    this.newItems = NewItemReminders.ask,
    this.defaultMinutes = 10,
    this.timerAlerts = true,
    this.morningPlan = false,
    this.morningMinute = 8 * 60,
    this.eveningReview = false,
    this.eveningMinute = 21 * 60,
    this.goalStreaks = true,
    this.weeklyRecap = true,
  });

  static const defaults = NotificationSettings();

  /// Reminder choices offered: at start, or this many minutes before.
  static const choices = [0, 5, 10, 30, 60];

  /// The master switch: off means nothing is scheduled.
  final bool enabled;
  final NewItemReminders newItems;

  /// Minutes before for [NewItemReminders.always] (0 = at start).
  final int defaultMinutes;

  /// An ongoing notification while a timer runs, and one when its planned
  /// length is reached.
  final bool timerAlerts;
  final bool morningPlan;
  final int morningMinute;
  final bool eveningReview;
  final int eveningMinute;

  /// An evening nudge when a running goal's activity isn't done yet today.
  final bool goalStreaks;

  /// Sunday evening: the week's recap is ready.
  final bool weeklyRecap;

  /// When the weekly recap arrives on Sundays (local minute of the day).
  static const weeklyRecapMinute = 19 * 60;

  /// The reminder a new timed item starts with (Me → Notifications →
  /// Default reminder); null for none.
  int? get defaultBefore =>
      newItems == NewItemReminders.always ? defaultMinutes : null;

  NotificationSettings copyWith({
    bool? enabled,
    NewItemReminders? newItems,
    int? defaultMinutes,
    bool? timerAlerts,
    bool? morningPlan,
    int? morningMinute,
    bool? eveningReview,
    int? eveningMinute,
    bool? goalStreaks,
    bool? weeklyRecap,
  }) => NotificationSettings(
    enabled: enabled ?? this.enabled,
    newItems: newItems ?? this.newItems,
    defaultMinutes: defaultMinutes ?? this.defaultMinutes,
    timerAlerts: timerAlerts ?? this.timerAlerts,
    morningPlan: morningPlan ?? this.morningPlan,
    morningMinute: morningMinute ?? this.morningMinute,
    eveningReview: eveningReview ?? this.eveningReview,
    eveningMinute: eveningMinute ?? this.eveningMinute,
    goalStreaks: goalStreaks ?? this.goalStreaks,
    weeklyRecap: weeklyRecap ?? this.weeklyRecap,
  );

  Map<String, Object> toJson() => {
    'enabled': enabled,
    'newItems': newItems.name,
    'defaultMinutes': defaultMinutes,
    'timerAlerts': timerAlerts,
    'morningPlan': morningPlan,
    'morningMinute': morningMinute,
    'eveningReview': eveningReview,
    'eveningMinute': eveningMinute,
    'goalStreaks': goalStreaks,
    'weeklyRecap': weeklyRecap,
  };

  factory NotificationSettings.fromJson(Object? json) {
    if (json is! Map) return defaults;
    T read<T>(String key, T fallback) => switch (json[key]) {
      final T v => v,
      _ => fallback,
    };
    const d = defaults;
    return NotificationSettings(
      enabled: read('enabled', d.enabled),
      newItems: NewItemReminders.fromName(json['newItems']),
      defaultMinutes: read('defaultMinutes', d.defaultMinutes),
      timerAlerts: read('timerAlerts', d.timerAlerts),
      morningPlan: read('morningPlan', d.morningPlan),
      morningMinute: read('morningMinute', d.morningMinute),
      eveningReview: read('eveningReview', d.eveningReview),
      eveningMinute: read('eveningMinute', d.eveningMinute),
      goalStreaks: read('goalStreaks', d.goalStreaks),
      weeklyRecap: read('weeklyRecap', d.weeklyRecap),
    );
  }
}
