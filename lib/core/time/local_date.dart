/// A calendar date with no time or zone, stored as `YYYY-MM-DD` (ADR-013).
class LocalDate implements Comparable<LocalDate> {
  LocalDate(this.year, this.month, this.day) {
    final check = DateTime.utc(year, month, day);
    if (check.year != year || check.month != month || check.day != day) {
      throw FormatException('Invalid date $year-$month-$day');
    }
  }

  /// The local calendar day of [instantUtc] in a zone [offset] from UTC.
  factory LocalDate.ofInstant(DateTime instantUtc, Duration offset) {
    final local = instantUtc.toUtc().add(offset);
    return LocalDate(local.year, local.month, local.day);
  }

  /// Parses `YYYY-MM-DD`; throws [FormatException] otherwise.
  factory LocalDate.parse(String value) {
    final match = _pattern.firstMatch(value);
    if (match == null) throw FormatException('Invalid date "$value"');
    return LocalDate(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }

  static final _pattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  final int year;
  final int month;
  final int day;

  /// The date [days] later (negative for earlier). Calendar arithmetic in UTC,
  /// so DST never affects it.
  LocalDate addDays(int days) {
    final shifted = DateTime.utc(year, month, day + days);
    return LocalDate(shifted.year, shifted.month, shifted.day);
  }

  /// Calendar days from this date to [other] (negative if earlier).
  int daysUntil(LocalDate other) => DateTime.utc(
    other.year,
    other.month,
    other.day,
  ).difference(DateTime.utc(year, month, day)).inDays;

  /// Monday = 1 … Sunday = 7.
  int get weekday => DateTime.utc(year, month, day).weekday;

  /// `YYYY-MM-DD`.
  String toIso() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  @override
  int compareTo(LocalDate other) => toIso().compareTo(other.toIso());

  @override
  bool operator ==(Object other) =>
      other is LocalDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIso();
}

/// A local time of day at minute precision, stored as minutes since midnight.
class LocalTime {
  const LocalTime(this.minuteOfDay)
    : assert(minuteOfDay >= 0 && minuteOfDay < 1440);

  LocalTime.hm(int hour, int minute) : this(hour * 60 + minute);

  final int minuteOfDay;

  int get hour => minuteOfDay ~/ 60;
  int get minute => minuteOfDay % 60;

  static bool isValidMinute(int minuteOfDay) =>
      minuteOfDay >= 0 && minuteOfDay < 1440;

  @override
  bool operator ==(Object other) =>
      other is LocalTime && other.minuteOfDay == minuteOfDay;

  @override
  int get hashCode => minuteOfDay.hashCode;

  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
