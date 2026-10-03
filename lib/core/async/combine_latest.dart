import 'dart:async';

/// Emits `combine(a, b)` once both streams have emitted, and again whenever
/// either emits. Pausing the result pauses both sources, so pause-aware
/// sources such as `reactiveQuery` defer their work.
Stream<R> combineLatest2<A, B, R>(
  Stream<A> a,
  Stream<B> b,
  R Function(A a, B b) combine,
) {
  late final StreamController<R> controller;
  StreamSubscription<A>? subA;
  StreamSubscription<B>? subB;
  A? lastA;
  B? lastB;
  var hasA = false;
  var hasB = false;
  var doneCount = 0;

  void emit() {
    if (hasA && hasB) controller.add(combine(lastA as A, lastB as B));
  }

  void done() {
    if (++doneCount == 2) unawaited(controller.close());
  }

  controller = StreamController<R>(
    onListen: () {
      subA = a.listen(
        (value) {
          lastA = value;
          hasA = true;
          emit();
        },
        onError: controller.addError,
        onDone: done,
      );
      subB = b.listen(
        (value) {
          lastB = value;
          hasB = true;
          emit();
        },
        onError: controller.addError,
        onDone: done,
      );
    },
    onPause: () {
      subA?.pause();
      subB?.pause();
    },
    onResume: () {
      subA?.resume();
      subB?.resume();
    },
    onCancel: () async {
      await subA?.cancel();
      await subB?.cancel();
    },
  );
  return controller.stream;
}
