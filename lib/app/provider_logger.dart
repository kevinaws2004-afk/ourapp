import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/logging/app_logger.dart';

/// Logs provider failures locally (error_handling.md §5).
final class ProviderLogger extends ProviderObserver {
  const ProviderLogger(this._logger);

  final AppLogger _logger;

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    _logger.error(
      'Provider failed: ${context.provider.name ?? context.provider.runtimeType}',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
