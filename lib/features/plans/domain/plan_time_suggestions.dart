import '../../../core/time/local_date.dart';

/// What the time sheet offers when planning something (A5): a few start
/// times, and lengths that still end on the same day.
abstract final class PlanTimeSuggestions {
  static const _minutesPerDay = 1440;
  static const _slotMinutes = 30;

  /// Lengths offered after a start time, in minutes.
  static const durations = [15, 30, 60, 120];

  /// Typical start times for a day other than today.
  static final otherDayStarts = [
    LocalTime.hm(8, 0),
    LocalTime.hm(9, 0),
    LocalTime.hm(12, 0),
    LocalTime.hm(14, 0),
    LocalTime.hm(18, 0),
    LocalTime.hm(20, 0),
  ];

  /// Start times to offer: on today, the next half hours after [now] (none
  /// past midnight); on other days, [otherDayStarts]. The first one is the
  /// default.
  static List<LocalTime> starts({
    required bool isToday,
    required LocalTime now,
    int count = 5,
  }) {
    if (!isToday) return otherDayStarts;
    final first = (now.minuteOfDay ~/ _slotMinutes + 1) * _slotMinutes;
    return [
      for (
        var m = first;
        m < _minutesPerDay && m < first + count * _slotMinutes;
        m += _slotMinutes
      )
        LocalTime(m),
    ];
  }

  /// The end of a [minutes]-long plan starting at [start], or null when it
  /// would run past midnight (a plan stays on its day).
  static LocalTime? endAfter(LocalTime start, int minutes) {
    final end = start.minuteOfDay + minutes;
    return LocalTime.isValidMinute(end) ? LocalTime(end) : null;
  }
}
