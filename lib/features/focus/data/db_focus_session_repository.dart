import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/reactive_query.dart';
import '../../../core/database/soft_delete.dart';
import '../../../core/database/storage_guard.dart';
import '../../../core/errors/app_exception.dart';
import '../../activity_logs/domain/activity_log.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../plans/domain/plan.dart';
import '../domain/focus_session.dart';
import '../domain/focus_session_repository.dart';

/// drift implementation of [FocusSessionRepository] (database.md §3.8).
class DbFocusSessionRepository implements FocusSessionRepository {
  DbFocusSessionRepository(this._db);

  final AppDatabase _db;

  static DateTime? _instant(int? ms) =>
      ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);

  /// Sessions with the public IDs of their type, plan and record.
  Future<List<FocusSession>> _load(String where, List<Variable> vars) async {
    final rows = await _db
        .customSelect(
          'SELECT s.*, t.public_id AS type_pid, p.public_id AS plan_pid, '
          'l.public_id AS log_pid FROM focus_sessions s '
          'JOIN activity_types t ON t.internal_id = s.activity_type_id '
          'LEFT JOIN plans p ON p.internal_id = s.plan_id '
          'LEFT JOIN activity_logs l ON l.internal_id = s.activity_log_id '
          'WHERE $where',
          variables: vars,
          readsFrom: {
            _db.focusSessions,
            _db.activityTypes,
            _db.plans,
            _db.activityLogs,
          },
        )
        .get();
    return [
      for (final r in rows)
        FocusSession(
          id: FocusSessionId(r.read<String>('public_id')),
          activityTypeId: ActivityTypeId(r.read<String>('type_pid')),
          planId: switch (r.readNullable<String>('plan_pid')) {
            final id? => PlanId(id),
            null => null,
          },
          logId: switch (r.readNullable<String>('log_pid')) {
            final id? => ActivityLogId(id),
            null => null,
          },
          state: FocusState.fromStorageKey(r.read<String>('state')),
          startedAt: _instant(r.read<int>('started_at'))!,
          pausedAt: _instant(r.readNullable<int>('paused_at')),
          pausedDurationMs: r.read<int>('paused_duration_ms'),
          endedAt: _instant(r.readNullable<int>('ended_at')),
          durationMs: r.readNullable<int>('duration_ms'),
          createdAt: _instant(r.read<int>('created_at'))!,
          updatedAt: _instant(r.read<int>('updated_at'))!,
        ),
    ];
  }

  static const _activeWhere =
      "s.state IN ('running', 'paused') AND s.deleted_at IS NULL";

  @override
  Stream<FocusSession?> watchActive() => guardStorageStream(
    'watchActiveFocus',
    reactiveQuery(
      _db.tableUpdates(TableUpdateQuery.onAllTables([_db.focusSessions])),
      () async => (await _load(_activeWhere, const [])).firstOrNull,
    ),
  );

  @override
  Future<FocusSession?> getActive() => guardStorage(
    'getActiveFocus',
    () async => (await _load(_activeWhere, const [])).firstOrNull,
  );

  @override
  Future<FocusSession?> getSession(FocusSessionId id) => guardStorage(
    'getFocusSession',
    () async => (await _load('s.public_id = ? AND s.deleted_at IS NULL', [
      Variable(id.value),
    ])).firstOrNull,
  );

  @override
  Future<void> create(FocusSession session) => guardStorage(
    'createFocusSession',
    () async {
      final type =
          await (_db.select(_db.activityTypes)
                ..where((t) => t.publicId.equals(session.activityTypeId.value)))
              .getSingle();
      final plan = session.planId == null
          ? null
          : await (_db.select(_db.plans)
                  ..where((p) => p.publicId.equals(session.planId!.value)))
                .getSingle();
      await _db
          .into(_db.focusSessions)
          .insert(
            FocusSessionsCompanion.insert(
              publicId: session.id.value,
              activityTypeId: type.internalId,
              planId: Value(plan?.internalId),
              state: session.state.storageKey,
              startedAt: session.startedAt.millisecondsSinceEpoch,
              createdAt: session.createdAt.millisecondsSinceEpoch,
              updatedAt: session.updatedAt.millisecondsSinceEpoch,
            ),
          );
    },
  );

  Future<void> _write(
    String operation,
    FocusSessionId id,
    FocusSessionsCompanion columns,
  ) => guardStorage(operation, () async {
    final count =
        await (_db.update(_db.focusSessions)..where(
              (s) => s.publicId.equals(id.value) & isActive(s.deletedAt),
            ))
            .write(columns);
    if (count == 0) {
      throw NotFoundException(debugContext: '$operation ${id.value}');
    }
  });

  @override
  Future<void> updatePause(FocusSession session) => _write(
    'updateFocusPause',
    session.id,
    FocusSessionsCompanion(
      state: Value(session.state.storageKey),
      pausedAt: Value(session.pausedAt?.millisecondsSinceEpoch),
      pausedDurationMs: Value(session.pausedDurationMs),
      updatedAt: Value(session.updatedAt.millisecondsSinceEpoch),
    ),
  );

  @override
  Future<void> markFinished(
    FocusSessionId id, {
    required ActivityLogId logId,
    required DateTime endedAt,
    required int durationMs,
    required DateTime updatedAt,
  }) => guardStorage('finishFocusSession', () async {
    final log = await (_db.select(
      _db.activityLogs,
    )..where((l) => l.publicId.equals(logId.value))).getSingle();
    await _write(
      'finishFocusSession',
      id,
      FocusSessionsCompanion(
        state: Value(FocusState.finished.storageKey),
        pausedAt: const Value(null),
        activityLogId: Value(log.internalId),
        endedAt: Value(endedAt.millisecondsSinceEpoch),
        durationMs: Value(durationMs),
        updatedAt: Value(updatedAt.millisecondsSinceEpoch),
      ),
    );
  });

  @override
  Future<void> discard(FocusSessionId id, DateTime now) => _write(
    'discardFocusSession',
    id,
    FocusSessionsCompanion(
      state: Value(FocusState.discarded.storageKey),
      pausedAt: const Value(null),
      updatedAt: Value(now.millisecondsSinceEpoch),
      deletedAt: Value(now.millisecondsSinceEpoch),
    ),
  );
}
