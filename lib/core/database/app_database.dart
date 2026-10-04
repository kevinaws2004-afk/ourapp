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
  /// v3: relational Repeating Groups (ADR-027). v4: plans (ADR-018).
  /// v5: focus sessions (ADR-031). v6: measurements, insight charts
  /// (ADR-034). v7: repeating plans (ADR-036).
  /// Every schema change bumps this, adds a step below, regenerates the step
  /// helpers with `dart run drift_dev make-migrations`, and adds migration
  /// tests (docs/architecture/database.md §7).
  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from > to || to > schemaVersion) {
        // A newer on-disk database (downgrade) or an unknown future target: fail loudly instead
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
    from2To3: (m, schema) async {
      // Sub-fields of Repeating Groups.
      await m.addColumn(
        schema.activityFields,
        schema.activityFields.parentFieldId,
      );
      await m.create(schema.idxActivityFieldsParent);
      // Items.
      await m.createTable(schema.logGroupItems);
      await m.create(schema.idxLogGroupItemsLog);
      // log_values: add group_item_id and replace the table-level
      // UNIQUE (log_id, field_id) with partial unique indexes. SQLite can't
      // drop a table constraint, so the table is rebuilt (data copied). Old
      // triggers on it are dropped first and recreated in their v3 form.
      for (final trigger in [
        'trg_log_values_insert_check',
        'trg_log_values_update_check',
        // Its body reads log_values; drop it so the rebuild's rename is clean.
        'trg_activity_fields_semantics_locked',
      ]) {
        await m.database.customStatement('DROP TRIGGER IF EXISTS $trigger');
      }
      await m.alterTable(
        TableMigration(
          schema.logValues,
          newColumns: [schema.logValues.groupItemId],
        ),
      );
      for (final index in [
        schema.idxLogValuesLog,
        schema.uxLogValuesTopLevel,
        schema.uxLogValuesItem,
      ]) {
        await m.create(index);
      }
      for (final trigger in [
        schema.trgLogValuesInsertCheck,
        schema.trgLogValuesUpdateCheck,
        schema.trgActivityFieldsSemanticsLocked,
        schema.trgActivityFieldsParentCheck,
        schema.trgActivityFieldsParentImmutable,
        schema.trgLogGroupItemsInsertCheck,
        schema.trgLogGroupItemsStructureImmutable,
      ]) {
        await m.create(trigger);
      }
    },
    from3To4: (m, schema) async {
      await m.createTable(schema.plans);
      await m.create(schema.idxPlansDay);
      await m.create(schema.idxPlansTypeDay);
      // A nullable FK column with no default can be added in place.
      await m.addColumn(schema.activityLogs, schema.activityLogs.planId);
      await m.create(schema.idxActivityLogsPlan);
      for (final trigger in [
        schema.trgActivityLogsPlanCheckInsert,
        schema.trgActivityLogsPlanCheckUpdate,
        schema.trgPlansTypeLocked,
        schema.trgPlansPublicIdImmutable,
      ]) {
        await m.create(trigger);
      }
    },
    from4To5: (m, schema) async {
      await m.createTable(schema.focusSessions);
      await m.create(schema.uxFocusSessionsOneActive);
      await m.create(schema.idxFocusSessionsPlan);
      await m.create(schema.trgFocusSessionsPlanCheck);
      await m.create(schema.trgFocusSessionsPublicIdImmutable);
    },
    from5To6: (m, schema) async {
      await m.createTable(schema.measurements);
      await m.create(schema.idxMeasurementsTypeDay);
      await m.createTable(schema.insightCharts);
      await m.create(schema.trgMeasurementsPublicIdImmutable);
    },
    from6To7: (m, schema) async {
      await m.createTable(schema.planSeries);
      await m.create(schema.trgPlanSeriesPublicIdImmutable);
      // A nullable FK column with no default can be added in place.
      await m.addColumn(schema.plans, schema.plans.seriesId);
      await m.create(schema.uxPlansSeriesDate);
    },
  );
}
