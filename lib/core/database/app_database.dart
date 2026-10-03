import 'package:drift/drift.dart';

import '../errors/app_exception.dart';
import 'app_database.steps.dart';
import 'tables/app_preferences_table.dart';

part 'app_database.g.dart';

/// The app's single SQLite database (ADR-002, ADR-011).
///
/// All table definitions live in `tables/` (Dart and `.drift` files) so this
/// class can list the whole schema without importing features. Feature
/// repositories query it.
@DriftDatabase(
  tables: [AppPreferences],
  include: {'tables/activity_engine.drift'},
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// v1: `app_preferences` (ADR-012). v2: activity engine (ADR-017–026).
  /// Every schema change bumps this, adds a step below, regenerates the step
  /// helpers with `dart run drift_dev make-migrations`, and adds migration
  /// tests (docs/architecture/database.md §7).
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from > to || to != schemaVersion) {
        // A newer on-disk database, or an unknown target: fail loudly instead
        // of guessing. The app shows the startup failure screen and never
        // deletes data.
        throw MigrationException(
          debugContext: 'No migration path from schema $from to $to.',
        );
      }
      await _steps(m, from, to);
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  static final _steps = stepByStep(
    from1To2: (m, schema) async {
      await m.createTable(schema.activityTypes);
      await m.createTable(schema.activityFields);
      await m.createTable(schema.activityLogs);
      await m.createTable(schema.logValues);
      for (final index in [
        schema.idxActivityFieldsTypePosition,
        schema.idxActivityLogsDay,
        schema.idxActivityLogsTypeDay,
        schema.idxLogValuesFieldNormalized,
      ]) {
        await m.create(index);
      }
      for (final trigger in [
        schema.trgLogValuesInsertCheck,
        schema.trgLogValuesUpdateCheck,
        schema.trgActivityFieldsSemanticsLocked,
        schema.trgActivityFieldsOwnerImmutable,
        schema.trgActivityLogsTypeImmutable,
        schema.trgActivityTypesPublicIdImmutable,
        schema.trgActivityFieldsPublicIdImmutable,
        schema.trgActivityLogsPublicIdImmutable,
      ]) {
        await m.create(trigger);
      }
    },
  );
}
