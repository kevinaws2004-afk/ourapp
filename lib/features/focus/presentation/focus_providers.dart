import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/database/db_unit_of_work.dart';
import '../../../core/ids/id_generator_provider.dart';
import '../../../core/time/clock_provider.dart';
import '../../activity_logs/presentation/activity_log_providers.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../../plans/presentation/plan_providers.dart';
import '../data/db_focus_session_repository.dart';
import '../domain/focus_session.dart';
import '../domain/focus_session_repository.dart';
import '../domain/focus_use_cases.dart';

final focusSessionRepositoryProvider = Provider<FocusSessionRepository>(
  (ref) => DbFocusSessionRepository(ref.watch(appDatabaseProvider)),
);

/// The running or paused session, if any (survives restarts: it's in SQLite).
final activeFocusSessionProvider = StreamProvider<FocusSession?>(
  (ref) => ref.watch(focusSessionRepositoryProvider).watchActive(),
);

/// Ticks once a second while something shows a live timer. The elapsed time
/// itself is always derived from timestamps and the clock (ADR-031).
final focusTickProvider = StreamProvider.autoDispose<DateTime>((ref) {
  final clock = ref.watch(clockProvider);
  return Stream<DateTime>.periodic(
    const Duration(seconds: 1),
    (_) => clock.nowUtc(),
  );
});

final startFocusSessionProvider = Provider(
  (ref) => StartFocusSession(
    ref.watch(focusSessionRepositoryProvider),
    ref.watch(activityTypeRepositoryProvider),
    ref.watch(planRepositoryProvider),
    ref.watch(idGeneratorProvider),
    ref.watch(clockProvider),
  ),
);

final pauseFocusSessionProvider = Provider(
  (ref) => PauseFocusSession(
    ref.watch(focusSessionRepositoryProvider),
    ref.watch(clockProvider),
  ),
);

final resumeFocusSessionProvider = Provider(
  (ref) => ResumeFocusSession(
    ref.watch(focusSessionRepositoryProvider),
    ref.watch(clockProvider),
  ),
);

final discardFocusSessionProvider = Provider(
  (ref) => DiscardFocusSession(
    ref.watch(focusSessionRepositoryProvider),
    ref.watch(clockProvider),
  ),
);

final finishFocusSessionProvider = Provider(
  (ref) => FinishFocusSession(
    ref.watch(focusSessionRepositoryProvider),
    ref.watch(planRepositoryProvider),
    ref.watch(activityLogRepositoryProvider),
    ref.watch(logActivityProvider),
    ref.watch(updateActivityLogProvider),
    DbUnitOfWork(ref.watch(appDatabaseProvider)),
    ref.watch(clockProvider),
  ),
);
