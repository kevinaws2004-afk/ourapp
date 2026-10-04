import '../../activity_logs/domain/activity_log.dart';
import 'focus_session.dart';

/// Persistence for focus sessions (ADR-031). At most one session is active
/// (running or paused); the database enforces it. Throws only
/// `AppException`s.
abstract interface class FocusSessionRepository {
  /// The active session, if any (`ux_focus_sessions_one_active`).
  Stream<FocusSession?> watchActive();

  Future<FocusSession?> getActive();

  Future<FocusSession?> getSession(FocusSessionId id);

  Future<void> create(FocusSession session);

  /// Writes the pause state ([FocusSession.pausedAt], paused total, state).
  Future<void> updatePause(FocusSession session);

  /// Marks the session finished with its record. Called inside the same
  /// unit of work that created the record.
  Future<void> markFinished(
    FocusSessionId id, {
    required ActivityLogId logId,
    required DateTime endedAt,
    required int durationMs,
    required DateTime updatedAt,
  });

  /// Discards the session: no record is created (soft-deleted, ADR-022).
  Future<void> discard(FocusSessionId id, DateTime now);
}
