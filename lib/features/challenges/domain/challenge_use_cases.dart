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

  ChallengeView _view(Challenge challenge, _Facts facts, LocalDate today) =>
      ChallengeView(
        challenge,
        ChallengeProgress.compute(
          doneDays: facts.days[challenge.activityTypeId] ?? const {},
          startDate: challenge.startDate,
          today: today,
          targetDays: challenge.targetDays,
          kind: challenge.kind,
          timesPerWeek: challenge.timesPerWeek,
          amount: challenge.amount,
          amountPeriod: challenge.amountPeriod,
          amounts: facts.amounts[challenge.id] ?? const {},
          restDays: challenge.restDays,
          startValue: challenge.startValue,
        ),
      );

  /// The days each activity was done, and each amount goal's daily amounts.
  Stream<_Facts> _facts() => combineLatest2(
    _challenges.watchDoneDays(),
    _challenges.watchAmounts(),
    _Facts.new,
  );

  Stream<List<ChallengeView>> call() => combineLatest2(
    _challenges.watchChallenges(),
    _facts(),
    (challenges, facts) {
      final today = _today(_clock);
      final views = [for (final c in challenges) _view(c, facts, today)];
      return [
        ...views.where((v) => !v.progress.isCompleted),
        ...views.where((v) => v.progress.isCompleted),
      ];
    },
  );

  /// One challenge, or null once it has ended.
  Stream<ChallengeView?> one(ChallengeId id) => combineLatest2(
    _challenges.watchChallenge(id),
    _facts(),
    (challenge, facts) =>
        challenge == null ? null : _view(challenge, facts, _today(_clock)),
  );
}

class _Facts {
  const _Facts(this.days, this.amounts);

  final Map<ActivityTypeId, Set<LocalDate>> days;
  final Map<ChallengeId, Map<LocalDate, double>> amounts;
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
      kind: draft.kind,
      timesPerWeek: draft.timesPerWeek,
      amount: draft.amount,
      restDays: draft.restDays,
    ).throwIfInvalid(debugContext: 'CreateChallenge');
    // A target follows one number field.
    if (draft.kind == GoalKind.target && draft.amountFieldId == null) {
      throw const ValidationException([
        ValidationIssue(ValidationCode.required, target: 'field'),
      ], debugContext: 'CreateChallenge target field');
    }
    final now = _clock.nowUtc();
    final measured =
        draft.kind == GoalKind.amount || draft.kind == GoalKind.target;
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
        kind: draft.kind,
        timesPerWeek: draft.kind == GoalKind.weekly ? draft.timesPerWeek : null,
        amount: measured ? draft.amount : null,
        amountFieldId: measured ? draft.amountFieldId : null,
        amountPeriod: draft.kind == GoalKind.amount
            ? draft.amountPeriod ?? GoalPeriod.day
            : null,
        restDays: draft.kind == GoalKind.daily ? draft.restDays : 0,
        startValue: draft.kind == GoalKind.target ? draft.startValue : null,
      ),
    );
    return id;
  }
}

/// Renames a goal or changes its target: the number of days or weeks, times
/// a week, the amount, or rest days. The activity, the kind and the start
/// are fixed (to count from a new day, restart it).
class UpdateChallenge {
  const UpdateChallenge(this._challenges, this._clock);

  final ChallengeRepository _challenges;
  final Clock _clock;

  Future<void> call(
    ChallengeId id, {
    required String title,
    required int targetDays,
    int? timesPerWeek,
    double? amount,
    int? restDays,
    double? startValue,
  }) async {
    final challenge = await _challenges.getChallenge(id);
    if (challenge == null) {
      throw NotFoundException(debugContext: 'UpdateChallenge ${id.value}');
    }
    final next = challenge.copyWith(
      title: title.trim(),
      targetDays: targetDays,
      updatedAt: _clock.nowUtc(),
      timesPerWeek: challenge.kind == GoalKind.weekly && timesPerWeek != null
          ? () => timesPerWeek
          : null,
      amount:
          (challenge.kind == GoalKind.amount ||
                  challenge.kind == GoalKind.target) &&
              amount != null
          ? () => amount
          : null,
      restDays: challenge.kind == GoalKind.daily ? restDays : null,
      startValue: challenge.kind == GoalKind.target && startValue != null
          ? () => startValue
          : null,
    );
    ChallengeValidator.validate(
      title: title,
      targetDays: targetDays,
      startDate: challenge.startDate,
      today: _today(_clock),
      kind: next.kind,
      timesPerWeek: next.timesPerWeek,
      amount: next.amount,
      restDays: next.restDays,
    ).throwIfInvalid(debugContext: 'UpdateChallenge');
    await _challenges.update(next);
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
