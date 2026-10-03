import 'dart:async';

/// A live query: emits `load()` once on listen and again whenever [changes]
/// fires (use drift's `tableUpdates` for the tables the query reads). While
/// the listener is paused it skips loading and remembers that data is stale;
/// on resume it loads once if anything changed.
///
/// Why:
/// - Riverpod 3 pauses providers whose widgets are hidden (e.g. a screen
///   covered by a pushed route). Deferring loads while paused and refreshing
///   on resume keeps revealed screens correct without querying for hidden ones.
/// - Changes must come from `tableUpdates`, not from watching a trigger query:
///   drift skips re-emitting a watched query whose result is unchanged, so a
///   constant trigger like `SELECT 1` fires only once.
/// Out-of-order results from overlapping loads are discarded.
Stream<T> reactiveQuery<T>(Stream<Object?> changes, Future<T> Function() load) {
  late final StreamController<T> controller;
  StreamSubscription<Object?>? subscription;
  var generation = 0;
  var stale = false;

  Future<void> emit() async {
    final current = ++generation;
    try {
      final value = await load();
      if (current != generation || controller.isClosed) return;
      if (controller.isPaused) {
        stale = true;
      } else {
        controller.add(value);
      }
    } catch (error, stackTrace) {
      if (current == generation && !controller.isClosed) {
        controller.addError(error, stackTrace);
      }
    }
  }

  controller = StreamController<T>(
    onListen: () {
      unawaited(emit());
      subscription = changes.listen((_) {
        if (controller.isPaused) {
          stale = true;
        } else {
          unawaited(emit());
        }
      }, onError: controller.addError);
    },
    onResume: () {
      if (stale) {
        stale = false;
        unawaited(emit());
      }
    },
    onCancel: () => subscription?.cancel(),
  );
  return controller.stream;
}
