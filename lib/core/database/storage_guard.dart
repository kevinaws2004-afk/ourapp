import 'package:drift/isolate.dart' show DriftRemoteException;

import '../errors/app_exception.dart';

/// Runs a data-layer operation and translates raw database errors into the
/// application error model (ADR-025). Repositories wrap every public method
/// with this so drift/SQLite exceptions never reach presentation.
///
/// Trigger error codes (database.md §3.6) that represent user-reachable rules
/// become [ValidationException]; every other constraint or driver failure is a
/// [StorageException] (it indicates a bug or a storage problem).
Future<T> guardStorage<T>(String operation, Future<T> Function() body) async {
  try {
    return await body();
  } on AppException {
    rethrow;
  } catch (error, stackTrace) {
    throw translateStorageError(
      error,
      operation: operation,
      stackTrace: stackTrace,
    );
  }
}

/// Stream variant of [guardStorage].
Stream<T> guardStorageStream<T>(String operation, Stream<T> stream) =>
    stream.handleError(
      (Object error, StackTrace stackTrace) => throw translateStorageError(
        error,
        operation: operation,
        stackTrace: stackTrace,
      ),
      test: (error) => error is! AppException,
    );

AppException translateStorageError(
  Object error, {
  required String operation,
  StackTrace? stackTrace,
}) {
  // Errors may arrive wrapped (e.g. DriftRemoteException from the background
  // isolate), so match on the message, which carries the RAISE code.
  final message = error is DriftRemoteException
      ? '${error.remoteCause}'
      : '$error';
  if (message.contains('activity_field_semantics_locked')) {
    return ValidationException(
      const [ValidationIssue(ValidationCode.fieldSemanticsLocked)],
      debugContext: operation,
      cause: error,
    );
  }
  if (message.contains('plan_type_locked')) {
    return ValidationException(
      const [
        ValidationIssue(ValidationCode.planActivityLocked, target: 'activity'),
      ],
      debugContext: operation,
      cause: error,
    );
  }
  return StorageException(debugContext: operation, cause: error);
}
