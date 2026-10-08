import '../../../core/time/local_date.dart';
import '../../activity_types/domain/activity_ids.dart';
import 'challenge.dart';

/// Read/write model for challenges (ADR-044). Streams update when the
/// challenges or the records behind them change. Throws only
/// `AppException`s.
abstract interface class ChallengeRepository {
  /// Active (not ended) challenges, oldest first.
  Stream<List<Challenge>> watchChallenges();

  Stream<Challenge?> watchChallenge(ChallengeId id);

  Future<Challenge?> getChallenge(ChallengeId id);

  /// The local days each activity that has a challenge was done on. A day
  /// counts when a live record of the activity has something in it (a time,
  /// notes or a value) or its item is marked done: the same rule as the
  /// activity counts in Insights (`core/database/done_records.dart`).
  Stream<Map<ActivityTypeId, Set<LocalDate>>> watchDoneDays();

  Future<void> create(Challenge challenge);

  /// Replaces [challenge]'s title, start and target.
  Future<void> update(Challenge challenge);

  /// Ends the challenge (soft delete, ADR-022).
  Future<void> softDelete(ChallengeId id);

  Future<void> restore(ChallengeId id);
}
