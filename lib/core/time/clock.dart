/// The single source of "now" and time-zone offsets (ADR-013). Inject it;
/// never call `DateTime.now()` anywhere else.
abstract interface class Clock {
  /// The current instant in UTC.
  DateTime nowUtc();

  /// The device's UTC offset at [instantUtc] (accounts for DST).
  Duration offsetAt(DateTime instantUtc);
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();

  @override
  Duration offsetAt(DateTime instantUtc) => instantUtc.toLocal().timeZoneOffset;
}

extension WallClockShift on Clock {
  /// [instantUtc] moved by [days] calendar days, keeping its local wall-clock
  /// time (so "09:00" stays 09:00 across a DST change).
  DateTime shiftDays(DateTime instantUtc, int days) {
    final offset = offsetAt(instantUtc);
    final local = instantUtc.toUtc().add(offset);
    final shifted = DateTime.utc(
      local.year,
      local.month,
      local.day + days,
      local.hour,
      local.minute,
      local.second,
      local.millisecond,
    );
    return shifted.subtract(offsetAt(shifted.subtract(offset)));
  }
}
