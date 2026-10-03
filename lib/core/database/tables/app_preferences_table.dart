import 'package:drift/drift.dart';

/// Key/value app preferences. An accepted exception to the timestamp rule:
/// text key as primary key and `updated_at` only (ADR-012). Rows are never
/// deleted; "reset" writes the default value.
@DataClassName('AppPreferenceRow')
class AppPreferences extends Table {
  @override
  String get tableName => 'app_preferences';

  TextColumn get key => text()();

  TextColumn get valueJson => text()();

  /// UTC epoch milliseconds (ADR-013).
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
