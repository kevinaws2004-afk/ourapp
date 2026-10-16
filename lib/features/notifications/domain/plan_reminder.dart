/// When to be reminded of a planned item: some minutes before its start
/// (follows the item if its time changes), or at a time of day on its date
/// (for items without a time, or when you just want a fixed time).
sealed class PlanReminder {
  const PlanReminder();

  /// Encoded for storage: `before` minutes, or `at` minute of the day.
  int get stored;
}

/// [minutes] before the item's start (0 = at the start).
final class ReminderBefore extends PlanReminder {
  const ReminderBefore(this.minutes);

  final int minutes;

  @override
  int get stored => minutes;

  @override
  bool operator ==(Object other) =>
      other is ReminderBefore && other.minutes == minutes;

  @override
  int get hashCode => minutes.hashCode;
}

/// At [minuteOfDay] (local) on the item's date.
final class ReminderAt extends PlanReminder {
  const ReminderAt(this.minuteOfDay);

  final int minuteOfDay;

  int get hour => minuteOfDay ~/ 60;
  int get minute => minuteOfDay % 60;

  @override
  int get stored => minuteOfDay;

  @override
  bool operator ==(Object other) =>
      other is ReminderAt && other.minuteOfDay == minuteOfDay;

  @override
  int get hashCode => minuteOfDay.hashCode;
}
