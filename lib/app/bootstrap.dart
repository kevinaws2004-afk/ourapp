import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/app_database.dart';
import '../core/database/database_connection.dart';
import '../core/database/database_provider.dart';
import '../core/logging/app_logger.dart';
import '../core/logging/logger_provider.dart';
import '../core/time/clock.dart';
import '../features/settings/data/db_app_preferences_repository.dart';
import '../features/settings/domain/preferences_snapshot.dart';
import '../features/settings/presentation/preferences_providers.dart';
import 'app.dart';
import 'provider_logger.dart';
import 'startup_failure_app.dart';

/// Startup sequence (application_architecture.md §7): error handlers →
/// open + migrate the database → read preferences → run the app.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  const logger = AppLogger();

  FlutterError.onError = (details) {
    logger.error(
      'Flutter framework error',
      error: details.exception,
      stackTrace: details.stack,
    );
    if (kDebugMode) FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    logger.error('Uncaught error', error: error, stackTrace: stackTrace);
    return true;
  };

  AppDatabase? database;
  final PreferencesSnapshot initialPreferences;
  try {
    database = AppDatabase(openAppDatabaseConnection());
    // The first query opens the database and runs migrations.
    initialPreferences = await DbAppPreferencesRepository(
      database,
      const SystemClock(),
      logger,
    ).load();
  } catch (error, stackTrace) {
    logger.error(
      'Could not open the database',
      error: error,
      stackTrace: stackTrace,
    );
    await database?.close();
    runApp(StartupFailureApp(onRetry: () => unawaited(bootstrap())));
    return;
  }

  runApp(
    ProviderScope(
      observers: const [ProviderLogger(logger)],
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        loggerProvider.overrideWithValue(logger),
        initialPreferencesProvider.overrideWithValue(initialPreferences),
      ],
      child: const App(),
    ),
  );
}
