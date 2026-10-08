// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:daylog/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;
import 'generated/schema_v6.dart' as v6;
import 'generated/schema_v7.dart' as v7;
import 'generated/schema_v8.dart' as v8;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  // Data-integrity tests: existing rows must survive each migration.
  test('migration from v1 to v2 keeps existing preferences', () async {
    final oldAppPreferencesData = <v1.AppPreferencesData>[
      const v1.AppPreferencesData(
        key: 'theme_mode',
        valueJson: '"dark"',
        updatedAt: 1791000000000,
      ),
      const v1.AppPreferencesData(
        key: 'onboarding_completed',
        valueJson: 'true',
        updatedAt: 1791000000001,
      ),
    ];
    final expectedNewAppPreferencesData = <v2.AppPreferencesData>[
      const v2.AppPreferencesData(
        key: 'theme_mode',
        valueJson: '"dark"',
        updatedAt: 1791000000000,
      ),
      const v2.AppPreferencesData(
        key: 'onboarding_completed',
        valueJson: 'true',
        updatedAt: 1791000000001,
      ),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.appPreferences, oldAppPreferencesData);
      },
      validateItems: (newDb) async {
        expect(
          expectedNewAppPreferencesData,
          await newDb.select(newDb.appPreferences).get(),
        );
      },
    );
  });

  test('migration from v2 to v3 keeps activity data and gains group storage', () async {
    final schema = await verifier.schemaAt(2);
    final old = v2.DatabaseAtV2(schema.newConnection());
    const type = '00000000-0000-7000-8000-000000000001';
    const field = '00000000-0000-7000-8000-000000000002';
    const log = '00000000-0000-7000-8000-000000000003';
    await old.customStatement(
      'INSERT INTO activity_types (internal_id, public_id, name, icon_id, color_key, created_at, updated_at) '
      "VALUES (1, '$type', 'Reading', 'book-open', 'sky', 1, 1)",
    );
    await old.customStatement(
      'INSERT INTO activity_fields (internal_id, public_id, activity_type_id, name, field_type, position, '
      "created_at, updated_at) VALUES (1, '$field', 1, 'Pages', 'number', 0, 1, 1)",
    );
    await old.customStatement(
      'INSERT INTO activity_logs (internal_id, public_id, activity_type_id, started_at, tz_offset_minutes, '
      "local_date, created_at, updated_at) VALUES (1, '$log', 1, 1000, 0, '2026-10-04', 1, 1)",
    );
    await old.customStatement(
      'INSERT INTO log_values (internal_id, log_id, field_id, number_value, normalized_value, created_at, '
      'updated_at) VALUES (7, 1, 1, 18, 18, 1, 1)',
    );
    await old.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 3);

    final value = await db.select(db.logValues).getSingle();
    expect(
      (value.internalId, value.logId, value.fieldId, value.numberValue),
      (7, 1, 1, 18.0),
    );
    expect(value.groupItemId, isNull);
    final field3 = await db.select(db.activityFields).getSingle();
    expect(field3.parentFieldId, isNull);
    expect(await db.select(db.logGroupItems).get(), isEmpty);
    // The partial unique index still forbids a second top-level value.
    await expectLater(
      db.customStatement(
        'INSERT INTO log_values (log_id, field_id, number_value, normalized_value, created_at, updated_at) '
        'VALUES (1, 1, 20, 20, 1, 1)',
      ),
      throwsA(isA<Object>()),
    );
    await db.close();
  });

  test('migration from v3 to v4 keeps logs and adds plans', () async {
    final schema = await verifier.schemaAt(3);
    final old = v3.DatabaseAtV3(schema.newConnection());
    const type = '00000000-0000-7000-8000-000000000001';
    const log = '00000000-0000-7000-8000-000000000003';
    const plan = '00000000-0000-7000-8000-000000000004';
    await old.customStatement(
      'INSERT INTO activity_types (internal_id, public_id, name, icon_id, color_key, created_at, updated_at) '
      "VALUES (1, '$type', 'Reading', 'book-open', 'sky', 1, 1)",
    );
    await old.customStatement(
      'INSERT INTO activity_logs (internal_id, public_id, activity_type_id, started_at, tz_offset_minutes, '
      "local_date, created_at, updated_at) VALUES (1, '$log', 1, 1000, 0, '2026-10-04', 1, 1)",
    );
    await old.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 4);

    final migrated = await db.select(db.activityLogs).getSingle();
    expect((migrated.publicId, migrated.planId), (log, null));
    // A plan of the log's type can now be linked.
    await db.customStatement(
      'INSERT INTO plans (internal_id, public_id, plan_date, activity_type_id, title, created_at, updated_at) '
      "VALUES (1, '$plan', '2026-10-04', 1, 'Read', 1, 1)",
    );
    await db.customStatement(
      'UPDATE activity_logs SET plan_id = 1 WHERE internal_id = 1',
    );
    expect((await db.select(db.activityLogs).getSingle()).planId, 1);
    await db.close();
  });

  test('migration from v4 to v5 adds focus sessions', () async {
    final schema = await verifier.schemaAt(4);
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 5);
    expect(await db.select(db.focusSessions).get(), isEmpty);
    await db.close();
  });

  test('migration from v5 to v6 adds measurements and saved charts', () async {
    final schema = await verifier.schemaAt(5);
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 6);
    expect(await db.select(db.measurements).get(), isEmpty);
    expect(await db.select(db.insightCharts).get(), isEmpty);
    await db.close();
  });

  test('migration from v6 to v7 keeps plans (no series) and adds repeating '
      'plans', () async {
    final schema = await verifier.schemaAt(6);
    final old = v6.DatabaseAtV6(schema.newConnection());
    const plan = '00000000-0000-7000-8000-000000000001';
    await old.customStatement(
      'INSERT INTO plans (internal_id, public_id, plan_date, title, created_at, updated_at) '
      "VALUES (1, '$plan', '2026-10-04', 'Bath', 1, 1)",
    );
    await old.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 7);

    final migrated = await db.select(db.plans).getSingle();
    expect((migrated.publicId, migrated.seriesId), (plan, null));
    expect(await db.select(db.planSeries).get(), isEmpty);
    await db.close();
  });

  test('migration from v7 to v8 keeps plans, their logs and series, and lets '
      'an activity plan be completed', () async {
    final schema = await verifier.schemaAt(7);
    final old = v7.DatabaseAtV7(schema.newConnection());
    const type = '00000000-0000-7000-8000-000000000001';
    const series = '00000000-0000-7000-8000-000000000002';
    const plan = '00000000-0000-7000-8000-000000000003';
    const task = '00000000-0000-7000-8000-000000000004';
    const log = '00000000-0000-7000-8000-000000000005';
    await old.customStatement(
      'INSERT INTO activity_types (internal_id, public_id, name, icon_id, color_key, created_at, updated_at) '
      "VALUES (1, '$type', 'Gym', 'barbell', 'coral', 1, 1)",
    );
    await old.customStatement(
      'INSERT INTO plan_series (internal_id, public_id, activity_type_id, title, weekdays, '
      'interval_weeks, start_date, created_at, updated_at) '
      "VALUES (1, '$series', 1, 'Gym', 1, 1, '2026-10-05', 1, 1)",
    );
    await old.customStatement(
      'INSERT INTO plans (internal_id, public_id, plan_date, activity_type_id, title, '
      'planned_start_at, sort_order, created_at, updated_at, series_id) '
      "VALUES (7, '$plan', '2026-10-05', 1, 'Gym', 1000, 3, 1, 2, 1)",
    );
    await old.customStatement(
      'INSERT INTO plans (internal_id, public_id, plan_date, title, status, created_at, updated_at) '
      "VALUES (8, '$task', '2026-10-05', 'Bath', 'completed', 1, 1)",
    );
    await old.customStatement(
      'INSERT INTO activity_logs (internal_id, public_id, activity_type_id, started_at, tz_offset_minutes, '
      "local_date, created_at, updated_at, plan_id) VALUES (1, '$log', 1, 1000, 0, '2026-10-05', 1, 1, 7)",
    );

    await old.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 8);

    final plans = await (db.select(
      db.plans,
    )..orderBy([(p) => OrderingTerm(expression: p.internalId)])).get();
    expect(
      [
        for (final p in plans)
          (p.internalId, p.publicId, p.status, p.seriesId, p.sortOrder),
      ],
      [(7, plan, 'planned', 1, 3), (8, task, 'completed', null, 0)],
    );
    expect((await db.select(db.activityLogs).getSingle()).planId, 7);

    // New in v8: an activity plan can be stored as completed.
    await db.customStatement(
      "UPDATE plans SET status = 'completed' WHERE internal_id = 7",
    );
    // The rebuilt table's triggers still guard it.
    await expectLater(
      db.customStatement(
        "UPDATE plans SET public_id = '00000000-0000-7000-8000-000000000009' "
        'WHERE internal_id = 7',
      ),
      throwsA(anything),
    );
    await expectLater(
      db.customStatement(
        'UPDATE plans SET activity_type_id = NULL WHERE internal_id = 7',
      ),
      throwsA(anything),
      reason: 'a plan with logs keeps its activity',
    );
    await db.close();
  });

  test('migration from v8 to v9 keeps activities and records and adds '
      'challenges', () async {
    final schema = await verifier.schemaAt(8);
    final old = v8.DatabaseAtV8(schema.newConnection());
    const type = '00000000-0000-7000-8000-000000000001';
    const log = '00000000-0000-7000-8000-000000000002';
    await old.customStatement(
      'INSERT INTO activity_types (internal_id, public_id, name, icon_id, color_key, created_at, updated_at) '
      "VALUES (1, '$type', 'Meditation', 'flower-lotus', 'teal', 1, 1)",
    );
    await old.customStatement(
      'INSERT INTO activity_logs (internal_id, public_id, activity_type_id, started_at, '
      'tz_offset_minutes, local_date, created_at, updated_at) '
      "VALUES (1, '$log', 1, 1000, 0, '2026-10-05', 1, 1)",
    );
    await old.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 9);

    expect((await db.select(db.activityTypes).getSingle()).name, 'Meditation');
    expect(
      (await db.select(db.activityLogs).getSingle()).localDate,
      '2026-10-05',
    );
    expect(await db.select(db.challenges).get(), isEmpty);

    // The new table is usable and guarded.
    const challenge = '00000000-0000-7000-8000-000000000003';
    await db.customStatement(
      'INSERT INTO challenges (public_id, activity_type_id, title, start_date, '
      'target_days, created_at, updated_at) '
      "VALUES ('$challenge', 1, '75 days of Meditation', '2026-10-05', 75, 1, 1)",
    );
    await expectLater(
      db.customStatement(
        "UPDATE challenges SET public_id = '00000000-0000-7000-8000-000000000009'",
      ),
      throwsA(anything),
      reason: 'public_id is immutable',
    );
    await expectLater(
      db.customStatement(
        'INSERT INTO challenges (public_id, activity_type_id, title, start_date, '
        'target_days, created_at, updated_at) '
        "VALUES ('00000000-0000-7000-8000-000000000004', 1, 'Zero', '2026-10-05', 0, 1, 1)",
      ),
      throwsA(anything),
      reason: 'a challenge lasts at least a day',
    );
    await db.close();
  });
}
