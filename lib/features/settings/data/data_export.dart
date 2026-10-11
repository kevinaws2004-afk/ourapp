import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/database/app_database.dart';

/// Your data, all of it, as one JSON file (spec §40): every table, row by
/// row, with the schema version so it can be read back later. Nothing
/// leaves the device unless you choose where to send the file.
class DataExport {
  const DataExport(this._db);

  final AppDatabase _db;

  /// Export format version, bumped if the file's shape changes.
  static const formatVersion = 1;

  /// Builds the export and returns its JSON.
  Future<Map<String, Object?>> build(DateTime nowUtc) async {
    final tables = <String, Object?>{};
    for (final table in _db.allTables) {
      final name = table.actualTableName;
      final rows = await _db.customSelect('SELECT * FROM "$name"').get();
      tables[name] = [for (final row in rows) row.data];
    }
    return {
      'app': 'Daylog',
      'format': formatVersion,
      'schemaVersion': _db.schemaVersion,
      'exportedAt': nowUtc.toIso8601String(),
      'tables': tables,
    };
  }

  /// Writes the export to a file and opens the share sheet, so you can save
  /// it to Files or Drive, or send it anywhere.
  Future<void> share(DateTime nowUtc, {required String subject}) async {
    final data = await build(nowUtc);
    final dir = await getTemporaryDirectory();
    final local = nowUtc.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    final stamp = '${local.year}-${two(local.month)}-${two(local.day)}';
    final file = File('${dir.path}/daylog-backup-$stamp.json');
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(data),
      flush: true,
    );
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        subject: subject,
      ),
    );
  }
}
