import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/app_database.dart';
import '../core/database/database_connection.dart';
import '../core/database/database_provider.dart';
import '../core/database/json_preferences.dart';
import '../core/logging/app_logger.dart';
import '../core/logging/diagnostics_log.dart';
import '../core/logging/logger_provider.dart';
import '../core/time/clock.dart';
import '../features/settings/data/db_app_preferences_repository.dart';
import '../features/settings/domain/preferences_snapshot.dart';
import '../features/settings/presentation/app_lock.dart';
import '../features/settings/presentation/preferences_providers.dart';
import '../core/notifications/notification_service.dart';
import '../features/notifications/presentation/notification_providers.dart';
import 'app.dart';
import 'launch_splash.dart';
import 'launch_theme_cache.dart';
import 'provider_logger.dart';
import 'startup_failure_app.dart';

/// Startup sequence (application_architecture.md §7): error handlers →
/// open + migrate the database → read preferences → run the app. The
/// animated splash shows meanwhile, for at least [_minSplash] so it never
/// just flickers.
const _minSplash = Duration(milliseconds: 900);

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  const logger = AppLogger();
  // Errors and crashes are kept on the phone for Send feedback.
  final diagnostics = await DiagnosticsLog.open();
  if (diagnostics != null) AppLogger.sink = diagnostics.record;

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

  runApp(LaunchSplash(look: await LaunchTheme.load()));
  final shown = Stopwatch()..start();

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

  // App lock: read now so the first frame is already covered.
  var appLock = false;
  try {
    appLock = readJson(
      await JsonPreferences(database, const SystemClock()).read(appLockKey),
      'enabled',
      false,
    );
  } catch (_) {
    // Unreadable: unlocked, as before app lock existed.
  }

  // Local notifications; a failure only disables them.
  final notifications = await NotificationService.start();

  final left = _minSplash - shown.elapsed;
  if (left > Duration.zero) await Future<void>.delayed(left);

  runApp(
    ProviderScope(
      observers: const [ProviderLogger(logger)],
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        loggerProvider.overrideWithValue(logger),
        initialPreferencesProvider.overrideWithValue(initialPreferences),
        notificationServiceProvider.overrideWithValue(notifications),
        initialAppLockProvider.overrideWithValue(appLock),
        diagnosticsLogProvider.overrideWithValue(diagnostics),
      ],
      child: const App(),
    ),
  );
}
