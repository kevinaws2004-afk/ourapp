import '../../../core/errors/app_exception.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../../../core/transactions/unit_of_work.dart';
import '../../activity_logs/domain/activity_log.dart';
import '../../activity_logs/domain/activity_log_use_cases.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/domain/activity_type_repository.dart';
import '../../plans/domain/plan.dart';
import '../../plans/domain/plan_repository.dart';
import 'focus_session.dart';
import 'focus_session_repository.dart';

// Focus session use cases (ADR-023, ADR-031).

ValidationException _invalid(ValidationCode code, String context) =>
    ValidationException([ValidationIssue(code)], debugContext: context);

/// Starts a focus timer for a timer-capable activity, optionally doing a
/// plan of that activity (FR-FO-01). One active session at a time (OQ-11).
class StartFocusSession {
  const StartFocusSession(
    this._sessions,
    this._types,
    this._plans,
    this._ids,
    this._clock,
  );

  final FocusSessionRepository _sessions;
  final ActivityTypeRepository _types;
  final PlanRepository _plans;
  final IdGenerator _ids;
  final Clock _clock;

  Future<FocusSessionId> call(ActivityTypeId typeId, {PlanId? planId}) async {
    final type = await _types.getType(typeId);
    if (type == null || type.isDeleted) {
      throw NotFoundException(debugContext: 'StartFocus ${typeId.value}');
    }
    if (!type.supportsTimer) {
      throw _invalid(ValidationCode.activityHasNoTimer, 'StartFocus');
    }
    if (planId != null) {
      final plan = await _plans.getPlan(planId);
      if (plan == null || plan.activityTypeId != typeId) {
        throw _invalid(ValidationCode.planRecordMismatch, 'StartFocus plan');
      }
    }
    if (await _sessions.getActive() != null) {
      throw _invalid(ValidationCode.focusAlreadyActive, 'StartFocus');
    }
    final now = _clock.nowUtc();
    final id = FocusSessionId(_ids.newId());
    await _sessions.create(
      FocusSession(
        id: id,
        activityTypeId: typeId,
        planId: planId,
        state: FocusState.running,
        startedAt: now,
        pausedDurationMs: 0,
        createdAt: now,
        updatedAt: now,
      ),
    );
    return id;
  }
}

Future<FocusSession> _active(
  FocusSessionRepository sessions,
  FocusSessionId id,
  String context,
) async {
  final session = await sessions.getSession(id);
  if (session == null || !session.state.isActive) {
    throw _invalid(ValidationCode.focusNotActive, context);
  }
  return session;
}

class PauseFocusSession {
  const PauseFocusSession(this._sessions, this._clock);

  final FocusSessionRepository _sessions;
  final Clock _clock;

  Future<void> call(FocusSessionId id) async {
    final session = await _active(_sessions, id, 'PauseFocus');
    if (session.state == FocusState.paused) return;
    await _sessions.updatePause(session.paused(_clock.nowUtc()));
  }
}

class ResumeFocusSession {
  const ResumeFocusSession(this._sessions, this._clock);

  final FocusSessionRepository _sessions;
  final Clock _clock;

  Future<void> call(FocusSessionId id) async {
    final session = await _active(_sessions, id, 'ResumeFocus');
    if (session.state == FocusState.running) return;
    await _sessions.updatePause(session.resumed(_clock.nowUtc()));
  }
}

/// Ends the timer without a record.
class DiscardFocusSession {
  const DiscardFocusSession(this._sessions, this._clock);

  final FocusSessionRepository _sessions;
  final Clock _clock;

  Future<void> call(FocusSessionId id) async {
    await _active(_sessions, id, 'DiscardFocus');
    await _sessions.discard(id, _clock.nowUtc());
  }
}

/// Finishes the session with the record the user confirmed (FR-FO-03): the
/// record (with the session's plan and end time) and the session's finished
/// state are written in one transaction. The session ends at its pause, or
/// now if running.
class FinishFocusSession {
  const FinishFocusSession(this._sessions, this._log, this._work, this._clock);

  final FocusSessionRepository _sessions;
  final LogActivity _log;
  final UnitOfWork _work;
  final Clock _clock;

  /// The session's end and focused time if it were finished now.
  static (DateTime, int) endOf(FocusSession session, DateTime now) {
    final end = session.pausedAt ?? now;
    return (end, session.elapsedMs(end));
  }

  Future<ActivityLogId> call(FocusSessionId id, ActivityLogDraft draft) async {
    final session = await _active(_sessions, id, 'FinishFocus');
    final now = _clock.nowUtc();
    final (end, elapsed) = endOf(session, now);
    final durationMs = draft.durationMs ?? elapsed;
    return _work.run(() async {
      final logId = await _log(
        session.activityTypeId,
        ActivityLogDraft(
          startedAt: draft.startedAt,
          endedAt: end,
          durationMs: durationMs,
          notes: draft.notes,
          values: draft.values,
          planId: session.planId,
        ),
      );
      await _sessions.markFinished(
        id,
        logId: logId,
        endedAt: end,
        durationMs: durationMs,
        updatedAt: now,
      );
      return logId;
    });
  }
}
