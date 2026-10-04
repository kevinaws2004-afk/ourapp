import 'package:daylog/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Verifies the database-level integrity rules of schema v6 (database.md
/// §3.6, §8) with raw SQL, independent of the repositories.
void main() {
  late AppDatabase db;

  Future<void> exec(String sql, [List<Object?> args = const []]) =>
      db.customStatement(sql, args);

  Future<int> insertType(String publicId) async {
    await exec(
      'INSERT INTO activity_types (public_id, name, icon_id, color_key, created_at, updated_at) '
      "VALUES (?, 'Reading', 'book-open', 'sky', 1, 1)",
      [publicId],
    );
    return (await db
            .customSelect('SELECT last_insert_rowid() AS id')
            .getSingle())
        .read<int>('id');
  }

  Future<int> insertField(
    int typeId,
    String publicId,
    String fieldType, {
    String? dimension,
    int? parent,
  }) async {
    await exec(
      'INSERT INTO activity_fields (public_id, activity_type_id, name, field_type, dimension, '
      'parent_field_id, position, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, 0, 1, 1)',
      [publicId, typeId, 'Field $publicId', fieldType, dimension, parent],
    );
    return (await db
            .customSelect('SELECT last_insert_rowid() AS id')
            .getSingle())
        .read<int>('id');
  }

  Future<int> insertLog(int typeId, String publicId) async {
    await exec(
      'INSERT INTO activity_logs (public_id, activity_type_id, started_at, tz_offset_minutes, '
      "local_date, created_at, updated_at) VALUES (?, ?, 1000, 0, '2026-10-04', 1, 1)",
      [publicId, typeId],
    );
    return (await db
            .customSelect('SELECT last_insert_rowid() AS id')
            .getSingle())
        .read<int>('id');
  }

  String uuid(int n) =>
      '00000000-0000-7000-8000-${n.toString().padLeft(12, '0')}';

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.customSelect('SELECT 1').get(); // open + create
  });

  tearDown(() => db.close());

  Matcher abortsWith(String code) => throwsA(
    predicate((Object e) => e.toString().contains(code), 'aborts with $code'),
  );

  Future<int> insertItem(
    int logId,
    int fieldId,
    String publicId, {
    int? parent,
  }) async {
    await exec(
      'INSERT INTO log_group_items (public_id, log_id, field_id, parent_item_id, position, '
      'created_at, updated_at) VALUES (?, ?, ?, ?, 0, 1, 1)',
      [publicId, logId, fieldId, parent],
    );
    return (await db
            .customSelect('SELECT last_insert_rowid() AS id')
            .getSingle())
        .read<int>('id');
  }

  group('repeating group triggers (ADR-027)', () {
    test('a sub-field\'s parent must be a group of the same type', () async {
      final type = await insertType(uuid(1));
      final other = await insertType(uuid(2));
      final text = await insertField(type, uuid(3), 'text');
      final foreignGroup = await insertField(other, uuid(4), 'repeating_group');

      expect(
        insertField(type, uuid(5), 'number', parent: text),
        abortsWith('activity_field_parent_invalid'),
      );
      expect(
        insertField(type, uuid(6), 'number', parent: foreignGroup),
        abortsWith('activity_field_parent_invalid'),
      );
    });

    test('groups nest at most two levels', () async {
      final type = await insertType(uuid(1));
      final outer = await insertField(type, uuid(2), 'repeating_group');
      final inner = await insertField(
        type,
        uuid(3),
        'repeating_group',
        parent: outer,
      );

      expect(
        insertField(type, uuid(4), 'repeating_group', parent: inner),
        abortsWith('activity_field_parent_invalid'),
      );
      await insertField(type, uuid(5), 'number', parent: inner);
    });

    test('a field cannot move to another group', () async {
      final type = await insertType(uuid(1));
      final a = await insertField(type, uuid(2), 'repeating_group');
      final b = await insertField(type, uuid(3), 'repeating_group');
      final reps = await insertField(type, uuid(4), 'number', parent: a);

      expect(
        exec(
          'UPDATE activity_fields SET parent_field_id = ? WHERE internal_id = ?',
          [b, reps],
        ),
        abortsWith('activity_field_parent_immutable'),
      );
    });

    test('items must belong to a group of the log\'s type, under the right '
        'parent item', () async {
      final type = await insertType(uuid(1));
      final exercises = await insertField(type, uuid(2), 'repeating_group');
      final sets = await insertField(
        type,
        uuid(3),
        'repeating_group',
        parent: exercises,
      );
      final text = await insertField(type, uuid(4), 'text');
      final log = await insertLog(type, uuid(5));

      expect(
        insertItem(log, text, uuid(6)),
        abortsWith('group_item_field_invalid'),
      );
      expect(
        insertItem(log, sets, uuid(7)),
        abortsWith('group_item_parent_invalid'),
        reason: 'a nested item needs a parent item',
      );
      final exercise = await insertItem(log, exercises, uuid(8));
      expect(
        insertItem(log, exercises, uuid(9), parent: exercise),
        abortsWith('group_item_parent_invalid'),
        reason: 'a top-level item has no parent item',
      );
      await insertItem(log, sets, uuid(10), parent: exercise);
    });

    test('item structure is immutable; position may change', () async {
      final type = await insertType(uuid(1));
      final group = await insertField(type, uuid(2), 'repeating_group');
      final log = await insertLog(type, uuid(3));
      final item = await insertItem(log, group, uuid(4));

      expect(
        exec('UPDATE log_group_items SET public_id = ? WHERE internal_id = ?', [
          uuid(5),
          item,
        ]),
        abortsWith('group_item_structure_immutable'),
      );
      await exec(
        'UPDATE log_group_items SET position = 3 WHERE internal_id = ?',
        [item],
      );
    });

    test('values are scoped: sub-fields only inside an item of their group, '
        'groups never as a value row', () async {
      final type = await insertType(uuid(1));
      final group = await insertField(type, uuid(2), 'repeating_group');
      final reps = await insertField(type, uuid(3), 'number', parent: group);
      final top = await insertField(type, uuid(4), 'number');
      final log = await insertLog(type, uuid(5));
      final item = await insertItem(log, group, uuid(6));
      Future<void> value(int field, int? itemId) => exec(
        'INSERT INTO log_values (log_id, field_id, group_item_id, number_value, '
        'normalized_value, created_at, updated_at) VALUES (?, ?, ?, 1, 1, 1, 1)',
        [log, field, itemId],
      );

      expect(value(reps, null), abortsWith('log_value_scope_mismatch'));
      expect(value(top, item), abortsWith('log_value_scope_mismatch'));
      expect(
        exec(
          'INSERT INTO log_values (log_id, field_id, text_value, created_at, updated_at) '
          "VALUES (?, ?, 'x', 1, 1)",
          [log, group],
        ),
        throwsA(anything),
      );
      await value(reps, item);
      expect(value(reps, item), throwsA(anything), reason: 'one per item');
    });

    test('deleting an item removes its children and their values', () async {
      final type = await insertType(uuid(1));
      final exercises = await insertField(type, uuid(2), 'repeating_group');
      final sets = await insertField(
        type,
        uuid(3),
        'repeating_group',
        parent: exercises,
      );
      final reps = await insertField(type, uuid(4), 'number', parent: sets);
      final log = await insertLog(type, uuid(5));
      final exercise = await insertItem(log, exercises, uuid(6));
      final set = await insertItem(log, sets, uuid(7), parent: exercise);
      await exec(
        'INSERT INTO log_values (log_id, field_id, group_item_id, number_value, '
        'normalized_value, created_at, updated_at) VALUES (?, ?, ?, 12, 12, 1, 1)',
        [log, reps, set],
      );

      await exec('DELETE FROM log_group_items WHERE internal_id = ?', [
        exercise,
      ]);

      final items = await db
          .customSelect('SELECT COUNT(*) AS c FROM log_group_items')
          .getSingle();
      final values = await db
          .customSelect('SELECT COUNT(*) AS c FROM log_values')
          .getSingle();
      expect(items.read<int>('c'), 0);
      expect(values.read<int>('c'), 0);
    });
  });

  group('plan rules (ADR-018)', () {
    Future<int> insertPlan(
      String publicId, {
      int? typeId,
      String status = 'planned',
      int? start,
      int? end,
      int? duration,
    }) async {
      await exec(
        'INSERT INTO plans (public_id, plan_date, activity_type_id, title, status, '
        'planned_start_at, planned_end_at, planned_duration_ms, created_at, updated_at) '
        "VALUES (?, '2026-10-04', ?, 'Plan', ?, ?, ?, ?, 1, 1)",
        [publicId, typeId, status, start, end, duration],
      );
      return (await db
              .customSelect('SELECT last_insert_rowid() AS id')
              .getSingle())
          .read<int>('id');
    }

    test('any plan can store completed (v8, ADR-040)', () async {
      final type = await insertType(uuid(1));
      await insertPlan(uuid(2), status: 'completed');
      await insertPlan(uuid(3), typeId: type, status: 'completed');
      expect(insertPlan(uuid(4), status: 'done'), throwsA(anything));
    });

    test('one source of planned duration; end needs a later start', () async {
      expect(
        insertPlan(uuid(1), start: 1000, end: 2000, duration: 500),
        throwsA(anything),
      );
      expect(insertPlan(uuid(2), end: 2000), throwsA(anything));
      expect(insertPlan(uuid(3), start: 3000, end: 2000), throwsA(anything));
      expect(insertPlan(uuid(4), duration: 0), throwsA(anything));
      await insertPlan(uuid(5), start: 1000, duration: 500);
    });

    test('a record fulfils only a plan of its own activity', () async {
      final reading = await insertType(uuid(1));
      final walking = await insertType(uuid(2));
      final walkPlan = await insertPlan(uuid(3), typeId: walking);
      final task = await insertPlan(uuid(4));
      final log = await insertLog(reading, uuid(5));

      for (final planId in [walkPlan, task]) {
        expect(
          exec('UPDATE activity_logs SET plan_id = ? WHERE internal_id = ?', [
            planId,
            log,
          ]),
          abortsWith('log_plan_mismatch'),
        );
      }
      expect(
        exec(
          'INSERT INTO activity_logs (public_id, activity_type_id, started_at, '
          'tz_offset_minutes, local_date, plan_id, created_at, updated_at) VALUES '
          "(?, ?, 1000, 0, '2026-10-04', ?, 1, 1)",
          [uuid(6), reading, walkPlan],
        ),
        abortsWith('log_plan_mismatch'),
      );
    });

    test('a fulfilled plan keeps its activity', () async {
      final reading = await insertType(uuid(1));
      final walking = await insertType(uuid(2));
      final plan = await insertPlan(uuid(3), typeId: reading);
      final log = await insertLog(reading, uuid(4));
      await exec('UPDATE activity_logs SET plan_id = ? WHERE internal_id = ?', [
        plan,
        log,
      ]);

      expect(
        exec('UPDATE plans SET activity_type_id = ? WHERE internal_id = ?', [
          walking,
          plan,
        ]),
        abortsWith('plan_type_locked'),
      );
    });
  });

  group('log value triggers', () {
    test('a value for a field of another activity type is rejected', () async {
      final reading = await insertType(uuid(1));
      final walking = await insertType(uuid(2));
      final walkingField = await insertField(walking, uuid(3), 'text');
      final readingLog = await insertLog(reading, uuid(4));

      expect(
        exec(
          'INSERT INTO log_values (log_id, field_id, text_value, created_at, updated_at) '
          "VALUES (?, ?, 'x', 1, 1)",
          [readingLog, walkingField],
        ),
        abortsWith('log_value_field_not_in_log_type'),
      );
    });

    test(
      'a value stored in the wrong column for its field type is rejected',
      () async {
        final type = await insertType(uuid(1));
        final number = await insertField(type, uuid(2), 'number');
        final log = await insertLog(type, uuid(3));

        expect(
          exec(
            'INSERT INTO log_values (log_id, field_id, text_value, created_at, updated_at) '
            "VALUES (?, ?, '12', 1, 1)",
            [log, number],
          ),
          abortsWith('log_value_column_mismatch'),
        );
      },
    );

    test(
      'a dimensioned number requires a unit, and a unitless number forbids one',
      () async {
        final type = await insertType(uuid(1));
        final distance = await insertField(
          type,
          uuid(2),
          'number',
          dimension: 'distance',
        );
        final count = await insertField(type, uuid(3), 'number');
        final log = await insertLog(type, uuid(4));

        expect(
          exec(
            'INSERT INTO log_values (log_id, field_id, number_value, normalized_value, created_at, '
            'updated_at) VALUES (?, ?, 5, 5000, 1, 1)',
            [log, distance],
          ),
          abortsWith('log_value_column_mismatch'),
        );
        expect(
          exec(
            'INSERT INTO log_values (log_id, field_id, number_value, unit_code, normalized_value, '
            "created_at, updated_at) VALUES (?, ?, 5, 'km', 5, 1, 1)",
            [log, count],
          ),
          abortsWith('log_value_column_mismatch'),
        );
      },
    );

    test('exactly one value column must be populated', () async {
      final type = await insertType(uuid(1));
      final text = await insertField(type, uuid(2), 'text');
      final log = await insertLog(type, uuid(3));

      expect(
        exec(
          'INSERT INTO log_values (log_id, field_id, text_value, boolean_value, created_at, '
          "updated_at) VALUES (?, ?, 'x', 1, 1, 1)",
          [log, text],
        ),
        throwsA(isA<Object>()),
      );
    });
  });

  group('field semantics', () {
    test('field type can change before any value exists, but not after', () async {
      final type = await insertType(uuid(1));
      final field = await insertField(type, uuid(2), 'text');
      final log = await insertLog(type, uuid(3));

      await exec(
        "UPDATE activity_fields SET field_type = 'number' WHERE internal_id = ?",
        [field],
      );
      await exec(
        'INSERT INTO log_values (log_id, field_id, number_value, normalized_value, created_at, '
        'updated_at) VALUES (?, ?, 3, 3, 1, 1)',
        [log, field],
      );

      expect(
        exec(
          "UPDATE activity_fields SET field_type = 'rating' WHERE internal_id = ?",
          [field],
        ),
        abortsWith('activity_field_semantics_locked'),
      );
      expect(
        exec(
          "UPDATE activity_fields SET dimension = 'mass' WHERE internal_id = ?",
          [field],
        ),
        abortsWith('activity_field_semantics_locked'),
      );
      // Renaming stays allowed.
      await exec(
        "UPDATE activity_fields SET name = 'Renamed' WHERE internal_id = ?",
        [field],
      );
    });

    test('fields cannot move to another activity type, and logs cannot change type', () async {
      final a = await insertType(uuid(1));
      final b = await insertType(uuid(2));
      final field = await insertField(a, uuid(3), 'text');
      final log = await insertLog(a, uuid(4));

      expect(
        exec(
          'UPDATE activity_fields SET activity_type_id = ? WHERE internal_id = ?',
          [b, field],
        ),
        abortsWith('activity_field_owner_immutable'),
      );
      expect(
        exec(
          'UPDATE activity_logs SET activity_type_id = ? WHERE internal_id = ?',
          [b, log],
        ),
        abortsWith('activity_log_type_immutable'),
      );
    });
  });

  test('public IDs are immutable', () async {
    final type = await insertType(uuid(1));

    expect(
      exec('UPDATE activity_types SET public_id = ? WHERE internal_id = ?', [
        uuid(9),
        type,
      ]),
      abortsWith('public_id_immutable'),
    );
  });

  test('log duration cannot exceed the wall-clock span', () async {
    final type = await insertType(uuid(1));

    expect(
      exec(
        'INSERT INTO activity_logs (public_id, activity_type_id, started_at, ended_at, '
        'duration_ms, tz_offset_minutes, local_date, created_at, updated_at) '
        "VALUES (?, ?, 1000, 2000, 5000, 0, '2026-10-04', 1, 1)",
        [uuid(2), type],
      ),
      throwsA(isA<Object>()),
    );
  });

  group('query plans use the hot-path indexes', () {
    Future<String> plan(
      String sql, [
      List<Variable<Object>> vars = const [],
    ]) async {
      final rows = await db
          .customSelect('EXPLAIN QUERY PLAN $sql', variables: vars)
          .get();
      return rows.map((r) => r.read<String>('detail')).join(' | ');
    }

    test('logs for a day', () async {
      expect(
        await plan(
          'SELECT * FROM activity_logs WHERE local_date = ? AND deleted_at IS NULL '
          'ORDER BY started_at',
          [const Variable('2026-10-04')],
        ),
        contains('idx_activity_logs_day'),
      );
    });

    test('history of a type, newest first', () async {
      final detail = await plan(
        'SELECT * FROM activity_logs WHERE activity_type_id = ? AND deleted_at IS NULL '
        'ORDER BY local_date DESC, started_at DESC LIMIT 50',
        [const Variable(1)],
      );
      expect(detail, contains('idx_activity_logs_type_day'));
      expect(detail, isNot(contains('TEMP B-TREE')));
    });

    test('values for a set of logs', () async {
      expect(
        await plan('SELECT * FROM log_values WHERE log_id IN (?, ?)', [
          const Variable(1),
          const Variable(2),
        ]),
        contains('idx_log_values_log'),
      );
    });

    test('plans of a date, in manual order, with no temp sort', () async {
      final detail = await plan(
        'SELECT * FROM plans WHERE plan_date = ? AND deleted_at IS NULL '
        'ORDER BY sort_order',
        [const Variable('2026-10-04')],
      );
      expect(detail, contains('idx_plans_day'));
      expect(detail, isNot(contains('TEMP B-TREE')));
    });

    test('records fulfilling the plans of a date', () async {
      final detail = await plan(
        'SELECT l.* FROM activity_logs l JOIN plans p ON p.internal_id = l.plan_id '
        'WHERE p.plan_date = ? AND p.deleted_at IS NULL AND l.deleted_at IS NULL',
        [const Variable('2026-10-04')],
      );
      expect(detail, contains('idx_plans_day'));
      expect(detail, contains('idx_activity_logs_plan'));
    });

    test('a body measurement series', () async {
      expect(
        await plan(
          'SELECT local_date, normalized_value FROM measurements '
          'WHERE measurement_type = ? AND deleted_at IS NULL '
          'ORDER BY local_date, recorded_at',
          [const Variable('weight')],
        ),
        contains('idx_measurements_type_day'),
      );
    });

    test('the active focus session', () async {
      expect(
        await plan(
          "SELECT * FROM focus_sessions WHERE state IN ('running', 'paused') "
          'AND deleted_at IS NULL',
        ),
        contains('ux_focus_sessions_one_active'),
      );
    });

    test('group items of a set of logs, in order', () async {
      expect(
        await plan(
          'SELECT * FROM log_group_items WHERE log_id IN (?, ?) ORDER BY position',
          [const Variable(1), const Variable(2)],
        ),
        contains('idx_log_group_items_log'),
      );
    });

    test('sub-fields of a group', () async {
      expect(
        await plan('SELECT * FROM activity_fields WHERE parent_field_id = ?', [
          const Variable(1),
        ]),
        contains('idx_activity_fields_parent'),
      );
    });

    test('historical values of a field', () async {
      expect(
        await plan(
          'SELECT normalized_value FROM log_values WHERE field_id = ? ORDER BY normalized_value DESC LIMIT 1',
          [const Variable(1)],
        ),
        contains('idx_log_values_field_normalized'),
      );
    });

    test('ordered fields of a type', () async {
      expect(
        await plan(
          'SELECT * FROM activity_fields WHERE activity_type_id = ? ORDER BY position',
          [const Variable(1)],
        ),
        contains('idx_activity_fields_type_position'),
      );
    });
  });
}
