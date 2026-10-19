import 'dart:convert';

import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/features/settings/data/data_export.dart';
import 'package:daylog/features/settings/data/data_restore.dart';
import 'package:daylog/core/design/themes/app_theme_id.dart';
import 'package:daylog/core/logging/app_logger.dart';
import 'package:daylog/features/settings/data/db_app_preferences_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';

/// Backup → restore (spec §40): everything comes back, older backups
/// restore into the current schema, and foreign files are refused.
void main() {
  late AppDatabase source;
  late AppDatabase target;

  setUp(() {
    source = AppDatabase(NativeDatabase.memory());
    target = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await source.close();
    await target.close();
  });

  Future<void> seed(AppDatabase db) async {
    await db.customStatement(
      'INSERT INTO activity_types (internal_id, public_id, name, icon_id, '
      'color_key, created_at, updated_at) VALUES '
      "(1, '00000000-0000-7000-8000-000000000001', 'Reading', 'book-open', "
      "'sky', 1, 1)",
    );
    await db.customStatement(
      'INSERT INTO activity_fields (internal_id, public_id, activity_type_id, '
      'name, field_type, position, required, measurable, config_json, '
      'created_at, updated_at) VALUES '
      "(1, '00000000-0000-7000-8000-000000000002', 1, 'Pages', 'number', 0, "
      "0, 1, '{}', 1, 1)",
    );
    await db.customStatement(
      'INSERT INTO plans (internal_id, public_id, plan_date, activity_type_id, '
      'title, created_at, updated_at) VALUES '
      "(1, '00000000-0000-7000-8000-000000000003', '2026-10-01', 1, "
      "'Reading', 1, 1)",
    );
    await db.customStatement(
      'INSERT INTO activity_logs (internal_id, public_id, activity_type_id, '
      'started_at, tz_offset_minutes, local_date, created_at, updated_at, '
      'plan_id, duration_ms) VALUES '
      "(1, '00000000-0000-7000-8000-000000000004', 1, 1000, 0, '2026-10-01', "
      '1, 1, 1, 2700000)',
    );
    await db.customStatement(
      'INSERT INTO log_values (log_id, field_id, number_value, '
      'normalized_value, created_at, updated_at) VALUES (1, 1, 42, 42, 1, 1)',
    );
    await db.customStatement(
      'INSERT INTO challenges (public_id, activity_type_id, title, start_date, '
      'target_days, created_at, updated_at, kind, amount, amount_field_id, '
      'amount_period) VALUES '
      "('00000000-0000-7000-8000-000000000005', 1, '20 pages a day', "
      "'2026-10-01', 30, 1, 1, 'amount', 20, 1, 'day')",
    );
    await db.customStatement(
      'INSERT INTO app_preferences (key, value_json, updated_at) '
      "VALUES ('user_name', '\"Sam\"', 1)",
    );
  }

  Future<int> count(AppDatabase db, String table) async =>
      (await db.customSelect('SELECT COUNT(*) AS n FROM $table').getSingle())
          .read<int>('n');

  test('a backup restores everything into another database', () async {
    await seed(source);
    final json = jsonEncode(await DataExport(source).build(DateTime.utc(2026)));
    // Something already there is replaced, not merged.
    await target.customStatement(
      'INSERT INTO app_preferences (key, value_json, updated_at) '
      "VALUES ('theme', '\"rose\"', 1)",
    );

    final restore = DataRestore(target);
    final contents = restore.parse(json);
    expect(contents.activities, 1);
    expect(contents.records, 1);
    expect(contents.goals, 1);
    await restore.restore(contents);

    for (final table in [
      'activity_types',
      'activity_fields',
      'plans',
      'activity_logs',
      'log_values',
      'challenges',
    ]) {
      expect(await count(target, table), 1, reason: table);
    }
    final prefs = await target.select(target.appPreferences).get();
    expect(prefs.map((p) => p.key), ['user_name']);
    final goal = await target.select(target.challenges).getSingle();
    expect(goal.kind, 'amount');
    expect(goal.amountFieldId, 1);
  });

  test('a backup from before weekly goals restores with daily goals', () async {
    await seed(source);
    final data = await DataExport(source).build(DateTime.utc(2026));
    final tables = data['tables']! as Map<String, Object?>;
    // As a v10 backup: no goal kinds yet.
    tables['challenges'] = [
      for (final row in tables['challenges']! as List)
        {
          for (final e in (row as Map<String, Object?>).entries)
            if (!{
              'kind',
              'times_per_week',
              'amount',
              'amount_field_id',
              'amount_period',
              'rest_days',
            }.contains(e.key))
              e.key: e.value,
        },
    ];
    data['schemaVersion'] = 10;

    final restore = DataRestore(target);
    await restore.restore(restore.parse(jsonEncode(data)));
    final goal = await target.select(target.challenges).getSingle();
    expect(goal.kind, 'daily');
    expect(goal.restDays, 0);
  });

  test('other files and newer backups are refused', () {
    final restore = DataRestore(target);
    expect(
      () => restore.parse('not json'),
      throwsA(
        isA<RestoreException>().having(
          (e) => e.problem,
          'problem',
          RestoreProblem.notABackup,
        ),
      ),
    );
    expect(
      () => restore.parse(
        jsonEncode({'app': 'Other', 'tables': <String, Object?>{}}),
      ),
      throwsA(isA<RestoreException>()),
    );
    expect(
      () => restore.parse(
        jsonEncode({
          'app': 'Daylog',
          'format': 1,
          'schemaVersion': target.schemaVersion + 1,
          'tables': <String, Object?>{},
        }),
      ),
      throwsA(
        isA<RestoreException>().having(
          (e) => e.problem,
          'problem',
          RestoreProblem.newerVersion,
        ),
      ),
    );
  });

  test('preferences (the theme) come back with the backup', () async {
    final prefs = DbAppPreferencesRepository(
      source,
      FakeClock(DateTime.utc(2026)),
      const AppLogger(),
    );
    await prefs.setTheme(AppThemeId.lavender);
    final json = jsonEncode(await DataExport(source).build(DateTime.utc(2026)));
    await prefs.setTheme(AppThemeId.rose);

    final restore = DataRestore(source);
    await restore.restore(restore.parse(json));

    expect(await prefs.watchTheme().first, AppThemeId.lavender);
  });
}
