import 'package:daylog/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Verifies the database-level integrity rules of schema v2 (database.md
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
  }) async {
    await exec(
      'INSERT INTO activity_fields (public_id, activity_type_id, name, field_type, dimension, '
      'position, created_at, updated_at) VALUES (?, ?, ?, ?, ?, 0, 1, 1)',
      [publicId, typeId, 'Field $publicId', fieldType, dimension],
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
        contains('sqlite_autoindex_log_values_1'),
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
