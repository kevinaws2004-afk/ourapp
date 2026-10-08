import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/ids/id_generator_provider.dart';
import '../../../core/time/clock_provider.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../data/db_challenge_repository.dart';
import '../domain/challenge.dart';
import '../domain/challenge_repository.dart';
import '../domain/challenge_use_cases.dart';

final challengeRepositoryProvider = Provider<ChallengeRepository>(
  (ref) => DbChallengeRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(clockProvider),
  ),
);

final _watchChallengesProvider = Provider(
  (ref) => WatchChallenges(
    ref.watch(challengeRepositoryProvider),
    ref.watch(clockProvider),
  ),
);

/// Every active challenge with its progress and streaks: running ones
/// first, completed ones last (ADR-044).
final challengesProvider = StreamProvider.autoDispose<List<ChallengeView>>(
  (ref) => ref.watch(_watchChallengesProvider)(),
);

/// One challenge with its progress; null once it has ended.
final challengeProvider = StreamProvider.autoDispose
    .family<ChallengeView?, ChallengeId>(
      (ref, id) => ref.watch(_watchChallengesProvider).one(id),
    );

final createChallengeProvider = Provider(
  (ref) => CreateChallenge(
    ref.watch(challengeRepositoryProvider),
    ref.watch(activityTypeRepositoryProvider),
    ref.watch(idGeneratorProvider),
    ref.watch(clockProvider),
  ),
);

final updateChallengeProvider = Provider(
  (ref) => UpdateChallenge(
    ref.watch(challengeRepositoryProvider),
    ref.watch(clockProvider),
  ),
);

final restartChallengeProvider = Provider(
  (ref) => RestartChallenge(
    ref.watch(challengeRepositoryProvider),
    ref.watch(clockProvider),
  ),
);

final setChallengeStartProvider = Provider(
  (ref) => SetChallengeStart(
    ref.watch(challengeRepositoryProvider),
    ref.watch(clockProvider),
  ),
);

final endChallengeProvider = Provider(
  (ref) => EndChallenge(ref.watch(challengeRepositoryProvider)),
);

final restoreChallengeProvider = Provider(
  (ref) => RestoreChallenge(ref.watch(challengeRepositoryProvider)),
);

/// The 🔥 on an activity's rows (ADR-046): its running challenge's current
/// streak, and whether today already counts.
class ActivityStreak {
  const ActivityStreak({
    required this.challengeId,
    required this.days,
    required this.doneToday,
  });

  final ChallengeId challengeId;

  /// Current streak (consecutive days).
  final int days;
  final bool doneToday;

  /// The streak once today is done ("Meditation done · 🔥 13").
  int get afterToday => doneToday ? days : days + 1;
}

/// Running (not completed) challenges by activity. When an activity has
/// several, the longest current streak shows.
final activityStreaksProvider =
    Provider.autoDispose<Map<ActivityTypeId, ActivityStreak>>((ref) {
      final views = ref.watch(challengesProvider).value ?? const [];
      final streaks = <ActivityTypeId, ActivityStreak>{};
      for (final view in views) {
        if (view.progress.isCompleted) continue;
        final id = view.challenge.activityTypeId;
        final streak = ActivityStreak(
          challengeId: view.challenge.id,
          days: view.progress.currentStreak,
          doneToday: view.progress.doneToday,
        );
        final other = streaks[id];
        if (other == null || streak.days > other.days) streaks[id] = streak;
      }
      return streaks;
    });
