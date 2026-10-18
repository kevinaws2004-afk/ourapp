import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/database/json_preferences.dart';
import '../data/auto_backup.dart';
import '../data/data_restore.dart';

final autoBackupProvider = Provider<AutoBackup>(
  (ref) => AutoBackup(
    ref.watch(appDatabaseProvider),
    ref.watch(jsonPreferencesProvider),
  ),
);

final dataRestoreProvider = Provider<DataRestore>(
  (ref) => DataRestore(ref.watch(appDatabaseProvider)),
);

/// Whether a backup is made every day (on by default).
final autoBackupEnabledProvider = StreamProvider<bool>(
  (ref) => ref.watch(autoBackupProvider).watchEnabled(),
);

/// Backups kept on the phone, newest first. Invalidate after making or
/// deleting one.
final backupSnapshotsProvider =
    FutureProvider.autoDispose<List<BackupSnapshot>>(
      (ref) => ref.watch(autoBackupProvider).list(),
    );
