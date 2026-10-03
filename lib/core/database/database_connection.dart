import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// Opens the on-device database file in a background isolate.
QueryExecutor openAppDatabaseConnection() => driftDatabase(
  name: 'app_database',
  native: DriftNativeOptions(
    setup: (database) {
      database.execute('PRAGMA journal_mode = WAL');
      database.execute('PRAGMA synchronous = NORMAL');
    },
  ),
);
