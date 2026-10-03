import 'dart:math';

import '../time/clock.dart';

/// Generates stable, globally unique record IDs.
abstract interface class IdGenerator {
  String newId();
}

/// UUID version 7 (RFC 9562): a 48-bit Unix-millisecond timestamp followed by
/// random bits, so IDs sort roughly by creation time and index well.
///
/// Follows the recommendation in pending ADR-P02. No table uses IDs yet, so
/// this can still change at no cost until Phase 2.
class Uuid7IdGenerator implements IdGenerator {
  Uuid7IdGenerator({required this._clock, Random? random})
    : _random = random ?? Random.secure();

  final Clock _clock;
  final Random _random;

  @override
  String newId() {
    final millis = _clock.nowUtc().millisecondsSinceEpoch;
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    for (var i = 0; i < 6; i++) {
      bytes[i] = (millis >> (8 * (5 - i))) & 0xff;
    }
    bytes[6] = 0x70 | (bytes[6] & 0x0f); // version 7
    bytes[8] = 0x80 | (bytes[8] & 0x3f); // RFC 9562 variant
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
