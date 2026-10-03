import 'package:daylog/core/time/clock.dart';

/// A controllable clock for deterministic tests. [offset] is the device's UTC
/// offset (fixed unless a test changes it).
class FakeClock implements Clock {
  FakeClock(this._now, {this.offset = Duration.zero});

  DateTime _now;
  Duration offset;

  @override
  DateTime nowUtc() => _now.toUtc();

  @override
  Duration offsetAt(DateTime instantUtc) => offset;

  void advance(Duration duration) => _now = _now.add(duration);
}
