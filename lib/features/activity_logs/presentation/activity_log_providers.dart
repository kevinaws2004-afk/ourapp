import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/ids/id_generator_provider.dart';
import '../../../core/logging/logger_provider.dart';
import '../../../core/time/clock_provider.dart';
import '../../../core/time/local_date.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../data/db_activity_log_repository.dart';
import '../domain/activity_log.dart';
import '../domain/activity_log_repository.dart';
import '../domain/activity_log_use_cases.dart';
import '../domain/watch_records_for_day.dart';

final activityLogRepositoryProvider = Provider<ActivityLogRepository>(
  (ref) => DbActivityLogRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(clockProvider),
    ref.watch(loggerProvider),
  ),
);

/// Recent logs of a type, newest first.
final logsForTypeProvider = StreamProvider.autoDispose
    .family<List<ActivityLog>, ActivityTypeId>(
      (ref, typeId) =>
          ref.watch(activityLogRepositoryProvider).watchLogsForType(typeId),
    );

/// What was recorded on a date (Plan tab, later Today).
final recordsForDayProvider = StreamProvider.autoDispose
    .family<List<DayRecord>, LocalDate>(
      (ref, date) => WatchRecordsForDay(
        ref.watch(activityLogRepositoryProvider),
        ref.watch(activityTypeRepositoryProvider),
      )(date),
    );

final logActivityProvider = Provider(
  (ref) => LogActivity(
    ref.watch(activityTypeRepositoryProvider),
    ref.watch(activityLogRepositoryProvider),
    ref.watch(idGeneratorProvider),
    ref.watch(clockProvider),
  ),
);

final updateActivityLogProvider = Provider(
  (ref) => UpdateActivityLog(
    ref.watch(activityTypeRepositoryProvider),
    ref.watch(activityLogRepositoryProvider),
    ref.watch(clockProvider),
  ),
);

final deleteActivityLogProvider = Provider(
  (ref) => DeleteActivityLog(ref.watch(activityLogRepositoryProvider)),
);

final restoreActivityLogProvider = Provider(
  (ref) => RestoreActivityLog(ref.watch(activityLogRepositoryProvider)),
);
