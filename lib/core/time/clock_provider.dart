import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'clock.dart';

final clockProvider = Provider<Clock>((ref) => const SystemClock());

/// Ticks at the start of every minute, for screens that show the time of
/// day (Today's now line, "in 12m"): watching it rebuilds them each minute.
final minuteTickProvider = StreamProvider.autoDispose<DateTime>((ref) {
  final clock = ref.watch(clockProvider);
  final ticks = StreamController<DateTime>();
  Timer? timer;
  void tick() {
    final now = clock.nowUtc();
    ticks.add(now);
    timer = Timer(
      Duration(milliseconds: 60000 - now.millisecondsSinceEpoch % 60000 + 50),
      tick,
    );
  }

  tick();
  // Back in the app: timers don't count time the phone slept, so catch up
  // at once (a new day, "Now" moved on).
  final lifecycle = AppLifecycleListener(
    onResume: () {
      timer?.cancel();
      tick();
    },
  );
  ref.onDispose(() {
    lifecycle.dispose();
    timer?.cancel();
    unawaited(ticks.close());
  });
  return ticks.stream;
});
