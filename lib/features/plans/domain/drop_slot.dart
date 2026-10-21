/// Where something dragged between two timed things on a day would go: the
/// start that fits right after the one before (or right before the one
/// after), and whether it fits there at all.
class DropSlot {
  const DropSlot({
    required this.start,
    required this.fits,
    required this.free,
    required this.length,
  });

  /// Works out the slot for something [length] long, dropped after a thing
  /// ending at [previousEnd] and before one starting at [nextStart] (either
  /// may be missing), on the day from [dayStart] to [dayEnd]. Starts are
  /// rounded to [step]: up after the one before, down before the one after.
  factory DropSlot.between({
    required DateTime? previousEnd,
    required DateTime? nextStart,
    required Duration length,
    required DateTime dayStart,
    required DateTime dayEnd,
    Duration step = const Duration(minutes: 5),
  }) {
    final from = previousEnd ?? dayStart;
    final until = nextStart ?? dayEnd;
    final start = previousEnd != null
        ? _roundUp(previousEnd, step)
        : nextStart != null
        ? _roundDown(nextStart.subtract(length), step)
        : dayStart;
    final fits =
        !start.isBefore(dayStart) &&
        start.isBefore(dayEnd) &&
        !start.add(length).isAfter(until);
    final free = until.difference(from);
    return DropSlot(
      start: start,
      fits: fits,
      free: free.isNegative ? Duration.zero : free,
      length: length,
    );
  }

  /// The suggested start.
  final DateTime start;

  /// Whether [length] fits there.
  final bool fits;

  /// The time free between the two neighbours.
  final Duration free;
  final Duration length;

  static DateTime _roundUp(DateTime t, Duration step) {
    final ms = t.millisecondsSinceEpoch;
    final s = step.inMilliseconds;
    final rounded = (ms + s - 1) ~/ s * s;
    return DateTime.fromMillisecondsSinceEpoch(rounded, isUtc: t.isUtc);
  }

  static DateTime _roundDown(DateTime t, Duration step) {
    final ms = t.millisecondsSinceEpoch;
    final s = step.inMilliseconds;
    return DateTime.fromMillisecondsSinceEpoch(ms ~/ s * s, isUtc: t.isUtc);
  }
}
