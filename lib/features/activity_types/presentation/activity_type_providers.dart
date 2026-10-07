import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/ids/id_generator_provider.dart';
import '../../../core/time/clock_provider.dart';
import '../data/db_activity_type_repository.dart';
import '../domain/activity_ids.dart';
import '../domain/activity_type.dart';
import '../domain/activity_type_repository.dart';
import '../domain/activity_type_use_cases.dart';

final activityTypeRepositoryProvider = Provider<ActivityTypeRepository>(
  (ref) => DbActivityTypeRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(clockProvider),
  ),
);

final activeActivityTypesProvider = StreamProvider<List<ActivityType>>(
  (ref) => ref.watch(activityTypeRepositoryProvider).watchActiveTypes(),
);

/// A type by ID (including a deleted one, for history).
final activityTypeProvider = StreamProvider.autoDispose
    .family<ActivityType?, ActivityTypeId>(
      (ref, id) => ref.watch(activityTypeRepositoryProvider).watchType(id),
    );

final createActivityTypeProvider = Provider(
  (ref) => CreateActivityType(
    ref.watch(activityTypeRepositoryProvider),
    ref.watch(idGeneratorProvider),
  ),
);

final updateActivityTypeProvider = Provider(
  (ref) => UpdateActivityType(
    ref.watch(activityTypeRepositoryProvider),
    ref.watch(idGeneratorProvider),
  ),
);

final deleteActivityTypeProvider = Provider(
  (ref) => DeleteActivityType(ref.watch(activityTypeRepositoryProvider)),
);

final restoreActivityTypeProvider = Provider(
  (ref) => RestoreActivityType(ref.watch(activityTypeRepositoryProvider)),
);

final addBuiltInActivityProvider = Provider(
  (ref) => AddBuiltInActivity(
    ref.watch(createActivityTypeProvider),
    ref.watch(idGeneratorProvider),
  ),
);
