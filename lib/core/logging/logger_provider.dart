import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_logger.dart';
import 'diagnostics_log.dart';

final loggerProvider = Provider<AppLogger>((ref) => const AppLogger());

/// The on-phone diagnostics log; null in tests or when storage failed.
final diagnosticsLogProvider = Provider<DiagnosticsLog?>((ref) => null);
