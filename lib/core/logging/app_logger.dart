import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

enum LogLevel {
  debug(500),
  info(800),
  warning(900),
  error(1000);

  const LogLevel(this.value);

  /// Severity in `dart:developer` terms.
  final int value;
}

/// Local-only logging (no data leaves the device, NFR-03). Never pass user
/// content (notes, names, values) at info level or above; log IDs and
/// operation names instead.
class AppLogger {
  const AppLogger({this.name = 'app'});

  final String name;

  /// Release builds keep warnings and errors only.
  LogLevel get minimumLevel => kReleaseMode ? LogLevel.warning : LogLevel.debug;

  void debug(String message) => _log(LogLevel.debug, message);

  void info(String message) => _log(LogLevel.info, message);

  void warning(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.warning, message, error: error, stackTrace: stackTrace);

  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.error, message, error: error, stackTrace: stackTrace);

  void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level.value < minimumLevel.value) return;
    developer.log(
      message,
      name: name,
      level: level.value,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
