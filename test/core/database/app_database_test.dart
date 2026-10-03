import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/errors/app_exception.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'a fresh database is created at schema v2 with the activity engine',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final version = await db.customSelect('PRAGMA user_version').getSingle();
      final objects = await db
          .customSelect(
            "SELECT type, name FROM sqlite_master WHERE name NOT LIKE 'sqlite_%' ORDER BY type, name",
          )
          .get();
      final byType = <String, List<String>>{};
      for (final row in objects) {
        byType
            .putIfAbsent(row.read<String>('type'), () => [])
            .add(row.read<String>('name'));
      }

      expect(version.read<int>('user_version'), 2);
      expect(byType['table'], [
        'activity_fields',
        'activity_logs',
        'activity_types',
        'app_preferences',
        'log_values',
      ]);
      expect(byType['index'], [
        'idx_activity_fields_type_position',
        'idx_activity_logs_day',
        'idx_activity_logs_type_day',
        'idx_log_values_field_normalized',
      ]);
      expect(byType['trigger'], hasLength(8));
    },
  );

  test('activity engine tables are STRICT', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final rows = await db.customSelect('PRAGMA table_list').get();
    final strict = {
      for (final r in rows) r.read<String>('name'): r.read<int>('strict') == 1,
    };

    for (final table in [
      'activity_types',
      'activity_fields',
      'activity_logs',
      'log_values',
    ]) {
      expect(strict[table], isTrue, reason: table);
    }
  });

  test(
    'foreign key enforcement is switched on when the database opens',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final row = await db.customSelect('PRAGMA foreign_keys').getSingle();

      expect(row.read<int>('foreign_keys'), 1);
    },
  );

  test(
    'opening a database from a newer schema version fails instead of guessing',
    () async {
      final db = AppDatabase(
        NativeDatabase.memory(
          setup: (raw) => raw.execute('PRAGMA user_version = 3'),
        ),
      );
      addTearDown(db.close);

      await expectLater(
        db.select(db.appPreferences).get(),
        throwsA(isA<MigrationException>()),
      );
    },
  );
}
