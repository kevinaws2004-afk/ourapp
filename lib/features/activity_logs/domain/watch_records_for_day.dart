import '../../../core/async/combine_latest.dart';
import '../../../core/time/local_date.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../activity_types/domain/activity_type_repository.dart';
import 'activity_log.dart';
import 'activity_log_repository.dart';

/// A record (Activity Log) with the activity type needed to render it.
class DayRecord {
  const DayRecord(this.log, this.type);

  final ActivityLog log;
  final ActivityType type;
}

/// Composite read (ADR-023): what was recorded on a date, with each record's
/// activity type (including archived ones). Updates when either changes.
class WatchRecordsForDay {
  const WatchRecordsForDay(this._logs, this._types);

  final ActivityLogRepository _logs;
  final ActivityTypeRepository _types;

  Stream<List<DayRecord>> call(LocalDate date) => combineLatest2(
    _logs.watchLogsForDay(date),
    _types.watchAllTypes(),
    (logs, types) {
      final byId = {for (final t in types) t.id: t};
      return [
        for (final log in logs)
          if (byId[log.activityTypeId] case final type?) DayRecord(log, type),
      ];
    },
  );
}
