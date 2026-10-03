import 'dart:math';

import 'package:daylog/core/ids/id_generator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';

void main() {
  final uuid7Pattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );

  test('produces RFC 9562 version-7 UUID strings', () {
    final generator = Uuid7IdGenerator(
      clock: FakeClock(DateTime.utc(2026, 10, 3)),
    );

    for (var i = 0; i < 1000; i++) {
      expect(generator.newId(), matches(uuid7Pattern));
    }
  });

  test('embeds the clock time as the leading 48-bit millisecond timestamp', () {
    final now = DateTime.utc(2026, 10, 3, 8, 30, 15, 123);
    final id = Uuid7IdGenerator(clock: FakeClock(now)).newId();

    final timestampHex = id.replaceAll('-', '').substring(0, 12);
    expect(int.parse(timestampHex, radix: 16), now.millisecondsSinceEpoch);
  });

  test('IDs from a later millisecond sort after earlier ones', () {
    final clock = FakeClock(DateTime.utc(2026, 10, 3));
    final generator = Uuid7IdGenerator(clock: clock, random: Random(1));

    final earlier = generator.newId();
    clock.advance(const Duration(milliseconds: 1));
    final later = generator.newId();

    expect(later.compareTo(earlier), greaterThan(0));
  });

  test('IDs generated within the same millisecond are unique', () {
    final generator = Uuid7IdGenerator(
      clock: FakeClock(DateTime.utc(2026, 10, 3)),
    );

    final ids = {for (var i = 0; i < 10000; i++) generator.newId()};

    expect(ids, hasLength(10000));
  });
}
