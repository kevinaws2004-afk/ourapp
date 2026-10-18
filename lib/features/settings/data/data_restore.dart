import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import 'data_export.dart';

/// Why a file can't be restored.
enum RestoreProblem {
  /// Not JSON, or not a Daylog backup.
  notABackup,

  /// Made by a newer version of the app: update first.
  newerVersion,
}

class RestoreException implements Exception {
  const RestoreException(this.problem);

  final RestoreProblem problem;

  @override
  String toString() => 'RestoreException($problem)';
}

/// A backup file, read and checked, ready to restore: when it was made and
/// what's in it.
class BackupContents {
  const BackupContents._({
    required this.exportedAt,
    required this.schemaVersion,
    required this.tables,
  });

  final DateTime? exportedAt;
  final int schemaVersion;

  /// Rows by table name.
  final Map<String, List<Map<String, Object?>>> tables;

  int _live(String table) => (tables[table] ?? const [])
      .where((row) => row['deleted_at'] == null)
      .length;

  int get activities => _live('activity_types');
  int get records => _live('activity_logs');
  int get plans => _live('plans');
  int get goals => _live('challenges');
  int get notes => _live('notes');
  int get measurements => _live('measurements');
}

/// Reads a backup made by [DataExport] and puts it back in place of
/// everything in the database (spec §40). One transaction: either all of it
/// is restored or nothing changes. Older backups restore into the current
/// schema (columns added since take their defaults); newer ones are
/// refused.
class DataRestore {
  const DataRestore(this._db);

  final AppDatabase _db;

  /// Parses and checks [source]; throws [RestoreException].
  BackupContents parse(String source) {
    final Object? json;
    try {
      json = jsonDecode(source);
    } on FormatException {
      throw const RestoreException(RestoreProblem.notABackup);
    }
    if (json is! Map ||
        json['app'] != 'Daylog' ||
        json['tables'] is! Map ||
        json['schemaVersion'] is! int) {
      throw const RestoreException(RestoreProblem.notABackup);
    }
    final format = json['format'];
    final schema = json['schemaVersion'] as int;
    if (format is! int || format > DataExport.formatVersion) {
      throw const RestoreException(RestoreProblem.newerVersion);
    }
    if (schema > _db.schemaVersion) {
      throw const RestoreException(RestoreProblem.newerVersion);
    }
    final tables = <String, List<Map<String, Object?>>>{};
    for (final MapEntry(:key, :value) in (json['tables'] as Map).entries) {
      if (key is! String || value is! List) {
        throw const RestoreException(RestoreProblem.notABackup);
      }
      tables[key] = [
        for (final row in value)
          if (row is Map) {for (final e in row.entries) '${e.key}': e.value},
      ];
    }
    return BackupContents._(
      exportedAt: DateTime.tryParse('${json['exportedAt']}'),
      schemaVersion: schema,
      tables: tables,
    );
  }

  /// Replaces every table's rows with [backup]'s. Rows go in in table
  /// order and, within a table, by internal ID, so parents (fields, list
  /// rows, plans) exist before what points at them; foreign keys are
  /// checked once, at the end.
  Future<void> restore(BackupContents backup) async {
    final tables = _db.allTables.toList();
    await _db.transaction(() async {
      await _db.customStatement('PRAGMA defer_foreign_keys = ON');
      for (final table in tables.reversed) {
        await _db.customStatement('DELETE FROM "${table.actualTableName}"');
      }
      for (final table in tables) {
        final rows = backup.tables[table.actualTableName];
        if (rows == null || rows.isEmpty) continue;
        final known = {for (final c in table.$columns) c.name};
        final sorted = [...rows]
          ..sort((a, b) {
            final x = a['internal_id'];
            final y = b['internal_id'];
            return x is int && y is int ? x.compareTo(y) : 0;
          });
        for (final row in sorted) {
          final columns = [
            for (final name in row.keys)
              if (known.contains(name)) name,
          ];
          if (columns.isEmpty) continue;
          await _db.customInsert(
            'INSERT INTO "${table.actualTableName}" '
            '(${columns.map((c) => '"$c"').join(', ')}) '
            'VALUES (${List.filled(columns.length, '?').join(', ')})',
            variables: [for (final c in columns) _variable(row[c])],
          );
        }
      }
    });
    // Everything changed: every open screen reloads.
    _db.markTablesUpdated(tables);
  }

  static Variable<Object> _variable(Object? value) => switch (value) {
    null => const Variable(null),
    final bool b => Variable<int>(b ? 1 : 0),
    final int i => Variable<int>(i),
    final double d => Variable<double>(d),
    final String s => Variable<String>(s),
    final other => Variable<String>(jsonEncode(other)),
  };
}
