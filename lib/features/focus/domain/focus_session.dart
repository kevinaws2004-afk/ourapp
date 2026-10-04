import '../../activity_logs/domain/activity_log.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../plans/domain/plan.dart';

extension type const FocusSessionId(String value) {}

enum FocusState {
  running('running'),
  paused('paused'),
  finished('finished'),
  discarded('discarded');

  const FocusState(this.storageKey);

  final String storageKey;

  static FocusState fromStorageKey(String key) =>
      values.firstWhere((s) => s.storageKey == key);

  bool get isActive => this == running || this == paused;
}

/// A focus timer for an activity (§16, §17; ADR-031). Elapsed time is
/// derived from persisted timestamps and the clock, never counted in memory,
/// so it survives backgrounding and process death (FR-FO-06).
class FocusSession {
  const FocusSession({
    required this.id,
    required this.activityTypeId,
    required this.state,
    required this.startedAt,
    required this.pausedDurationMs,
    required this.createdAt,
    required this.updatedAt,
    this.planId,
    this.logId,
    this.pausedAt,
    this.endedAt,
    this.durationMs,
  });

  final FocusSessionId id;
  final ActivityTypeId activityTypeId;

  /// The plan being done, if started from one ("in progress").
  final PlanId? planId;

  /// The record created on finish.
  final ActivityLogId? logId;
  final FocusState state;
  final DateTime startedAt;

  /// Set while paused.
  final DateTime? pausedAt;

  /// Total of completed pauses.
  final int pausedDurationMs;
  final DateTime? endedAt;
  final int? durationMs;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Focused time at [now]: `(end or now) − start − pauses`, where a paused
  /// session stops at its pause.
  int elapsedMs(DateTime now) {
    if (durationMs case final d?) return d;
    final end = endedAt ?? pausedAt ?? now;
    final elapsed = end.difference(startedAt).inMilliseconds - pausedDurationMs;
    return elapsed < 0 ? 0 : elapsed;
  }

  FocusSession paused(DateTime now) =>
      _copy(state: FocusState.paused, pausedAt: () => now, updatedAt: now);

  FocusSession resumed(DateTime now) => _copy(
    state: FocusState.running,
    pausedAt: () => null,
    pausedDurationMs:
        pausedDurationMs + now.difference(pausedAt ?? now).inMilliseconds,
    updatedAt: now,
  );

  FocusSession _copy({
    required FocusState state,
    required DateTime? Function() pausedAt,
    required DateTime updatedAt,
    int? pausedDurationMs,
  }) => FocusSession(
    id: id,
    activityTypeId: activityTypeId,
    planId: planId,
    logId: logId,
    state: state,
    startedAt: startedAt,
    pausedAt: pausedAt(),
    pausedDurationMs: pausedDurationMs ?? this.pausedDurationMs,
    endedAt: endedAt,
    durationMs: durationMs,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
