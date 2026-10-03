// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:daylog/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

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
}
