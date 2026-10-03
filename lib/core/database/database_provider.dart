import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// The opened database. Always overridden: by `bootstrap()` in the app and
/// with an in-memory database in tests.
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw StateError('appDatabaseProvider must be overridden.'),
);
