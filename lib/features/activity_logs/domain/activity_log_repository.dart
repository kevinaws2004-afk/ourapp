import '../../../core/time/local_date.dart';
import '../../activity_types/domain/activity_ids.dart';
import 'activity_log.dart';

/// Persistence for activity logs and their values (one aggregate).
///
/// Default reads exclude deleted logs (ADR-022). A page of logs and all its
/// values load in two queries (no N+1). Throws only `AppException`s.
abstract interface class ActivityLogRepository {
  /// Logs of a type, newest first (activity history).
  Stream<List<ActivityLog>> watchLogsForType(
    ActivityTypeId typeId, {
    int limit = 50,
  });

  /// Logs whose local day is [date], in time order (`idx_activity_logs_day`).
  Stream<List<ActivityLog>> watchLogsForDay(LocalDate date);

  Stream<ActivityLog?> watchLog(ActivityLogId id);

  Future<ActivityLog?> getLog(ActivityLogId id);

  Future<void> create(ActivityLog log);

  /// Replaces the log's properties and values (values diffed by field).
  Future<void> update(ActivityLog log);

  Future<void> softDelete(ActivityLogId id);

  Future<void> restore(ActivityLogId id);
}
