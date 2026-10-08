import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/errors/app_exception.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'a fresh database is created at schema v9 with the activity engine',
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

      expect(version.read<int>('user_version'), 9);
      expect(byType['table'], [
        'activity_fields',
        'activity_logs',
        'activity_types',
        'app_preferences',
        'challenges',
        'focus_sessions',
        'insight_charts',
        'log_group_items',
        'log_values',
        'measurements',
        'plan_series',
        'plans',
      ]);
      expect(byType['index'], [
        'idx_activity_fields_parent',
        'idx_activity_fields_type_position',
        'idx_activity_logs_day',
        'idx_activity_logs_plan',
        'idx_activity_logs_type_day',
        'idx_challenges_type',
        'idx_focus_sessions_plan',
        'idx_log_group_items_log',
        'idx_log_values_field_normalized',
        'idx_log_values_log',
        'idx_measurements_type_day',
        'idx_plans_day',
        'idx_plans_type_day',
        'ux_focus_sessions_one_active',
        'ux_log_values_item',
        'ux_log_values_top_level',
        'ux_plans_series_date',
      ]);
      expect(byType['trigger'], hasLength(21));
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
      'log_group_items',
      'log_values',
      'plans',
      'focus_sessions',
      'measurements',
      'insight_charts',
      'challenges',
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
          setup: (raw) => raw.execute('PRAGMA user_version = 10'),
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
