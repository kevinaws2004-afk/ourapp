import 'dart:async';

import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/database/reactive_query.dart';
import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_app.dart';

void main() {
  test('loads on listen and again on every change', () async {
    final changes = StreamController<void>();
    var value = 0;
    final emitted = <int>[];
    final sub = reactiveQuery(
      changes.stream,
      () async => value,
    ).listen(emitted.add);
    await pumpEventQueue();

    value = 1;
    changes.add(null);
    await pumpEventQueue();

    expect(emitted, [0, 1]);
    await sub.cancel();
    await changes.close();
  });

  test('a paused listener gets the latest value on resume, without querying while paused', () async {
    final changes = StreamController<void>();
    var value = 0;
    var loads = 0;
    final emitted = <int>[];
    final sub = reactiveQuery(changes.stream, () async {
      loads++;
      return value;
    }).listen(emitted.add);
    await pumpEventQueue();

    sub.pause();
    value = 5;
    changes.add(null);
    await pumpEventQueue();
    expect(loads, 1, reason: 'no query runs while paused');

    sub.resume();
    await pumpEventQueue();
    expect(emitted.last, 5);

    value = 7;
    changes.add(null);
    await pumpEventQueue();
    expect(
      emitted.last,
      7,
      reason: 'changes keep arriving after a pause/resume cycle',
    );
    await sub.cancel();
    await changes.close();
  });

  test('resuming without changes does not re-query', () async {
    final changes = StreamController<void>();
    var loads = 0;
    final sub = reactiveQuery(
      changes.stream,
      () async => ++loads,
    ).listen((_) {});
    await pumpEventQueue();

    sub.pause();
    sub.resume();
    await pumpEventQueue();

    expect(loads, 1);
    await sub.cancel();
    await changes.close();
  });

  test('out-of-order results from overlapping loads are discarded', () async {
    final changes = StreamController<void>();
    final slow = Completer<int>();
    var call = 0;
    final emitted = <int>[];
    final sub = reactiveQuery(changes.stream, () {
      call++;
      return call == 1 ? slow.future : Future.value(2);
    }).listen(emitted.add);
    await pumpEventQueue(); // initial (slow, stale) load in flight

    changes.add(null); // fresh load
    await pumpEventQueue();
    slow.complete(1);
    await pumpEventQueue();

    expect(emitted, [2]);
    await sub.cancel();
    await changes.close();
  });

  test('drift tableUpdates drive re-queries on every write, even with an unchanged result shape', () async {
    final db = newTestDatabase();
    addTearDown(db.close);
    final emitted = <int>[];
    final sub = reactiveQuery(
      db.tableUpdates(TableUpdateQuery.onAllTables([db.appPreferences])),
      () async => (await db.select(db.appPreferences).get()).length,
    ).listen(emitted.add);
    await pumpEventQueue();

    for (final key in ['a', 'b']) {
      await db
          .into(db.appPreferences)
          .insert(
            AppPreferencesCompanion.insert(
              key: key,
              valueJson: '1',
              updatedAt: 1,
            ),
          );
      await pumpEventQueue();
    }

    expect(emitted, [0, 1, 2]);
    await sub.cancel();
  });
}
