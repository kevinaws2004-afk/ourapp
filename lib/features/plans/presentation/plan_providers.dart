import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/ids/id_generator_provider.dart';
import '../../../core/time/clock_provider.dart';
import '../../../core/time/local_date.dart';
import '../../activity_logs/presentation/activity_log_providers.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../../focus/presentation/focus_providers.dart';
import '../data/db_plan_repository.dart';
import '../domain/item_use_cases.dart';
import '../domain/plan_repository.dart';
import '../domain/plan_use_cases.dart';
import '../domain/watch_day_overview.dart';

final planRepositoryProvider = Provider<PlanRepository>(
  (ref) => DbPlanRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(clockProvider),
  ),
);

/// A date's plans paired with what was recorded (Today, Plan tab).
final dayOverviewProvider = StreamProvider.autoDispose
    .family<DayOverview, LocalDate>(
      (ref, date) => WatchDayOverview(
        ref.watch(planRepositoryProvider),
        ref.watch(activityLogRepositoryProvider),
        ref.watch(activityTypeRepositoryProvider),
        planInFocus: () => ref
            .watch(focusSessionRepositoryProvider)
            .watchActive()
            .map((s) => s?.planId),
      )(date),
    );

final createPlanProvider = Provider(
  (ref) => CreatePlan(
    ref.watch(planRepositoryProvider),
    ref.watch(activityTypeRepositoryProvider),
    ref.watch(idGeneratorProvider),
    ref.watch(clockProvider),
  ),
);

final updatePlanProvider = Provider(
  (ref) => UpdatePlan(
    ref.watch(planRepositoryProvider),
    ref.watch(activityTypeRepositoryProvider),
    ref.watch(clockProvider),
  ),
);

final assignPlanActivityProvider = Provider(
  (ref) => AssignPlanActivity(
    ref.watch(updatePlanProvider),
    ref.watch(planRepositoryProvider),
  ),
);

final setPlanStatusProvider = Provider(
  (ref) => SetPlanStatus(
    ref.watch(planRepositoryProvider),
    ref.watch(clockProvider),
  ),
);

final movePlanProvider = Provider(
  (ref) =>
      MovePlan(ref.watch(planRepositoryProvider), ref.watch(clockProvider)),
);

final reorderPlansProvider = Provider(
  (ref) =>
      ReorderPlans(ref.watch(planRepositoryProvider), ref.watch(clockProvider)),
);

final ensureItemActivityProvider = Provider(
  (ref) => EnsureItemActivity(
    ref.watch(planRepositoryProvider),
    ref.watch(activityTypeRepositoryProvider),
    ref.watch(createActivityTypeProvider),
    ref.watch(assignPlanActivityProvider),
  ),
);

final markItemDoneProvider = Provider(
  (ref) => MarkItemDone(
    ref.watch(planRepositoryProvider),
    ref.watch(activityLogRepositoryProvider),
    ref.watch(logActivityProvider),
    ref.watch(setPlanStatusProvider),
    ref.watch(clockProvider),
  ),
);

final deleteItemProvider = Provider(
  (ref) => DeleteItem(
    ref.watch(planRepositoryProvider),
    ref.watch(activityLogRepositoryProvider),
  ),
);

final restoreItemProvider = Provider(
  (ref) => RestoreItem(
    ref.watch(planRepositoryProvider),
    ref.watch(activityLogRepositoryProvider),
  ),
);

final addItemFieldProvider = Provider(
  (ref) => AddItemField(
    ref.watch(activityTypeRepositoryProvider),
    ref.watch(ensureItemActivityProvider),
    ref.watch(updateActivityTypeProvider),
  ),
);
