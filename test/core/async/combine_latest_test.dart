import 'dart:async';

import 'package:daylog/core/async/combine_latest.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('emits once both sources have a value, then on every change', () async {
    final a = StreamController<int>();
    final b = StreamController<String>();
    final emitted = <String>[];
    final sub = combineLatest2(
      a.stream,
      b.stream,
      (int x, String y) => '$x$y',
    ).listen(emitted.add);

    a.add(1);
    await pumpEventQueue();
    expect(emitted, isEmpty);
    b.add('a');
    a.add(2);
    b.add('b');
    await pumpEventQueue();

    expect(emitted, ['1a', '2a', '2b']);
    await sub.cancel();
  });

  test('pausing the result pauses both sources', () async {
    var pausedA = false;
    var pausedB = false;
    final a = StreamController<int>(
      onPause: () => pausedA = true,
      onResume: () => pausedA = false,
    );
    final b = StreamController<int>(
      onPause: () => pausedB = true,
      onResume: () => pausedB = false,
    );
    final sub = combineLatest2(
      a.stream,
      b.stream,
      (int x, int y) => x + y,
    ).listen((_) {});
    await pumpEventQueue();

    sub.pause();
    expect((pausedA, pausedB), (true, true));
    sub.resume();
    expect((pausedA, pausedB), (false, false));
    await sub.cancel();
  });
}
