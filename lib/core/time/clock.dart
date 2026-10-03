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
