import '../../../core/async/combine_latest.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/local_date.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/domain/activity_type_repository.dart';
import 'challenge.dart';
import 'challenge_progress.dart';
import 'challenge_repository.dart';
import 'challenge_validator.dart';

// Use cases for challenges (ADR-023: verb + domain object; `call`).

LocalDate _today(Clock clock) {
  final now = clock.nowUtc();
  return LocalDate.ofInstant(now, clock.offsetAt(now));
}

/// A challenge with where it stands today.
class ChallengeView {
  const ChallengeView(this.challenge, this.progress);

  final Challenge challenge;
  final ChallengeProgress progress;
}

/// Composite read (ADR-023): every active challenge with its progress and
/// streaks, worked out from the days its activity was done. Active ones
/// (target not reached) come first, then completed ones; each group keeps
/// the order they were started in.
class WatchChallenges {
  const WatchChallenges(this._challenges, this._clock);

  final ChallengeRepository _challenges;
  final Clock _clock;

  ChallengeView _view(
    Challenge challenge,
    Map<ActivityTypeId, Set<LocalDate>> days,
    LocalDate today,
  ) => ChallengeView(
    challenge,
    ChallengeProgress.compute(
      doneDays: days[challenge.activityTypeId] ?? const {},
      startDate: challenge.startDate,
      today: today,
      targetDays: challenge.targetDays,
    ),
  );

  Stream<List<ChallengeView>> call() => combineLatest2(
    _challenges.watchChallenges(),
    _challenges.watchDoneDays(),
    (challenges, days) {
      final today = _today(_clock);
      final views = [for (final c in challenges) _view(c, days, today)];
      return [
        ...views.where((v) => !v.progress.isCompleted),
        ...views.where((v) => v.progress.isCompleted),
      ];
    },
  );

  /// One challenge, or null once it has ended.
  Stream<ChallengeView?> one(ChallengeId id) => combineLatest2(
    _challenges.watchChallenge(id),
    _challenges.watchDoneDays(),
    (challenge, days) =>
        challenge == null ? null : _view(challenge, days, _today(_clock)),
  );
}

class CreateChallenge {
  const CreateChallenge(this._challenges, this._types, this._ids, this._clock);

  final ChallengeRepository _challenges;
  final ActivityTypeRepository _types;
  final IdGenerator _ids;
  final Clock _clock;

  Future<ChallengeId> call(ChallengeDraft draft) async {
    final type = await _types.getType(draft.activityTypeId);
    if (type == null || type.isDeleted) {
      throw const ValidationException([
        ValidationIssue(ValidationCode.required, target: 'activity'),
      ], debugContext: 'CreateChallenge activity');
    }
    ChallengeValidator.validate(
      title: draft.title,
      targetDays: draft.targetDays,
      startDate: draft.startDate,
      today: _today(_clock),
    ).throwIfInvalid(debugContext: 'CreateChallenge');
    final now = _clock.nowUtc();
    final id = ChallengeId(_ids.newId());
    await _challenges.create(
      Challenge(
        id: id,
        activityTypeId: draft.activityTypeId,
        title: draft.title.trim(),
        startDate: draft.startDate,
        targetDays: draft.targetDays,
        createdAt: now,
        updatedAt: now,
      ),
    );
    return id;
  }
}

/// Renames a challenge or changes its number of days. The activity and the
/// start are fixed (to count from a new day, restart it).
class UpdateChallenge {
  const UpdateChallenge(this._challenges, this._clock);

  final ChallengeRepository _challenges;
  final Clock _clock;

  Future<void> call(
    ChallengeId id, {
    required String title,
    required int targetDays,
  }) async {
    final challenge = await _challenges.getChallenge(id);
    if (challenge == null) {
      throw NotFoundException(debugContext: 'UpdateChallenge ${id.value}');
    }
    ChallengeValidator.validate(
      title: title,
      targetDays: targetDays,
      startDate: challenge.startDate,
      today: _today(_clock),
    ).throwIfInvalid(debugContext: 'UpdateChallenge');
    await _challenges.update(
      challenge.copyWith(
        title: title.trim(),
        targetDays: targetDays,
        updatedAt: _clock.nowUtc(),
      ),
    );
  }
}

/// Starts the count again from today: earlier days no longer count. Returns
/// the previous start so the screen can offer Undo.
class RestartChallenge {
  const RestartChallenge(this._challenges, this._clock);

  final ChallengeRepository _challenges;
  final Clock _clock;

  Future<LocalDate> call(ChallengeId id) async {
    final challenge = await _challenges.getChallenge(id);
    if (challenge == null) {
      throw NotFoundException(debugContext: 'RestartChallenge ${id.value}');
    }
    await _challenges.update(
      challenge.copyWith(startDate: _today(_clock), updatedAt: _clock.nowUtc()),
    );
    return challenge.startDate;
  }
}

/// Puts a challenge's start back (Undo of a restart).
class SetChallengeStart {
  const SetChallengeStart(this._challenges, this._clock);

  final ChallengeRepository _challenges;
  final Clock _clock;

  Future<void> call(ChallengeId id, LocalDate startDate) async {
    final challenge = await _challenges.getChallenge(id);
    if (challenge == null) {
      throw NotFoundException(debugContext: 'SetChallengeStart ${id.value}');
    }
    await _challenges.update(
      challenge.copyWith(startDate: startDate, updatedAt: _clock.nowUtc()),
    );
  }
}

/// Ends a challenge (soft delete, ADR-022). Its records are untouched.
class EndChallenge {
  const EndChallenge(this._challenges);

  final ChallengeRepository _challenges;

  Future<void> call(ChallengeId id) => _challenges.softDelete(id);
}

class RestoreChallenge {
  const RestoreChallenge(this._challenges);

  final ChallengeRepository _challenges;

  Future<void> call(ChallengeId id) => _challenges.restore(id);
}
