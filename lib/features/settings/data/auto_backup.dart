import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/json_preferences.dart';
import 'data_export.dart';

/// A backup file kept on the phone.
class BackupSnapshot {
  const BackupSnapshot(this.file, this.madeAt, {required this.beforeRestore});

  final File file;
  final DateTime madeAt;

  /// Made just before a restore, so the restore can be undone.
  final bool beforeRestore;
}

/// Automatic backups (spec §40): once a day, a full [DataExport] is written
/// to the app's private storage, keeping the last [keep]. Android's own
/// device backup carries these files (and the database) to a new phone
/// (`data_extraction_rules.xml`); from here they can be restored, or saved
/// anywhere with the share sheet. Nothing leaves the device by itself.
class AutoBackup {
  AutoBackup(this._db, this._prefs, {Future<Directory> Function()? root})
    : _root = root ?? getApplicationSupportDirectory;

  static const settingsKey = 'auto_backup';
  static const keep = 7;
  static const _autoPrefix = 'daylog-auto-';
  static const _restorePrefix = 'daylog-before-restore-';

  final AppDatabase _db;
  final JsonPreferences _prefs;
  final Future<Directory> Function() _root;

  Future<Directory> _dir() async {
    final dir = Directory('${(await _root()).path}/backups');
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  /// On unless turned off in Me → Backup & restore.
  Stream<bool> watchEnabled() =>
      _prefs.watch(settingsKey).map((json) => readJson(json, 'enabled', true));

  Future<void> setEnabled({required bool enabled}) =>
      _prefs.write(settingsKey, {'enabled': enabled});

  /// Writes today's backup unless there's one from the last day or
  /// automatic backups are off. Never throws: a failed backup is retried
  /// next time.
  Future<void> runIfDue(DateTime nowUtc) async {
    try {
      if (!readJson(await _prefs.read(settingsKey), 'enabled', true)) return;
      // One dated ahead of now (the phone's clock was changed) doesn't
      // count, or it would hold off backups until that date.
      final latest = (await list())
          .where((s) => !s.beforeRestore && !s.madeAt.isAfter(nowUtc))
          .map((s) => s.madeAt)
          .firstOrNull;
      if (latest != null &&
          nowUtc.difference(latest) < const Duration(hours: 20)) {
        return;
      }
      await _write(_autoPrefix, nowUtc);
      await _prune();
    } catch (_) {
      // Storage full or unavailable: try again next launch.
    }
  }

  /// A backup made now on request (kept with the daily ones, dated now).
  /// Unlike [runIfDue] it throws, so the screen can say it failed.
  Future<BackupSnapshot> backupNow(DateTime nowUtc) async {
    final snapshot = await _write(_autoPrefix, nowUtc);
    await _prune();
    return snapshot;
  }

  /// A backup of everything as it is now, before a restore replaces it.
  Future<BackupSnapshot> snapshotBeforeRestore(DateTime nowUtc) =>
      _write(_restorePrefix, nowUtc);

  /// Backups on the phone, newest first.
  Future<List<BackupSnapshot>> list() async {
    final dir = await _dir();
    final snapshots = <BackupSnapshot>[];
    for (final entity in dir.listSync()) {
      if (entity is! File || !entity.path.endsWith('.json')) continue;
      final name = entity.uri.pathSegments.last;
      final restore = name.startsWith(_restorePrefix);
      if (!restore && !name.startsWith(_autoPrefix)) continue;
      final stamp = int.tryParse(
        name
            .substring((restore ? _restorePrefix : _autoPrefix).length)
            .replaceAll('.json', ''),
      );
      if (stamp == null) continue;
      snapshots.add(
        BackupSnapshot(
          entity,
          DateTime.fromMillisecondsSinceEpoch(stamp, isUtc: true),
          beforeRestore: restore,
        ),
      );
    }
    return snapshots..sort((a, b) => b.madeAt.compareTo(a.madeAt));
  }

  Future<BackupSnapshot> _write(String prefix, DateTime nowUtc) async {
    final data = await DataExport(_db).build(nowUtc);
    final dir = await _dir();
    final file = File(
      '${dir.path}/$prefix${nowUtc.millisecondsSinceEpoch}.json',
    );
    // Written next to it first, so a crash never leaves half a backup.
    final temp = File('${file.path}.tmp');
    await temp.writeAsString(jsonEncode(data), flush: true);
    await temp.rename(file.path);
    return BackupSnapshot(
      file,
      nowUtc,
      beforeRestore: prefix == _restorePrefix,
    );
  }

  /// Keeps the newest [keep] daily backups and the newest two made before
  /// a restore.
  Future<void> _prune() async {
    final all = await list();
    final daily = all.where((s) => !s.beforeRestore).skip(keep);
    final restores = all.where((s) => s.beforeRestore).skip(2);
    for (final old in [...daily, ...restores]) {
      try {
        await old.file.delete();
      } on FileSystemException {
        // Gone already.
      }
    }
  }
}
