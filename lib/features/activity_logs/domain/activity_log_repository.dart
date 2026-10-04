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

  /// Records that fulfil the (non-deleted) plans of [planDate], whatever day
  /// they were recorded on (`idx_activity_logs_plan`).
  Stream<List<ActivityLog>> watchLogsForPlanDate(LocalDate planDate);

  Stream<ActivityLog?> watchLog(ActivityLogId id);

  Future<ActivityLog?> getLog(ActivityLogId id);

  /// Distinct text values previously recorded for a text field (in any
  /// scope, including inside Repeating Group items) in non-deleted logs, most
  /// recently used first. Backs autocomplete (`suggestFromHistory`).
  Future<List<String>> textSuggestions(
    ActivityFieldId fieldId, {
    int limit = 50,
  });

  /// Inserts [log], including its plan link. The link never changes after.
  Future<void> create(ActivityLog log);

  /// Replaces the log's properties and values: values diffed by field per
  /// scope, Repeating Group items diffed by ID (identity kept).
  Future<void> update(ActivityLog log);

  Future<void> softDelete(ActivityLogId id);

  Future<void> restore(ActivityLogId id);
}
