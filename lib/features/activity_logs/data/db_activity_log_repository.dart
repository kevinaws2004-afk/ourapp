import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/reactive_query.dart';
import '../../../core/database/soft_delete.dart';
import '../../../core/database/storage_guard.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/local_date.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/domain/field_type.dart';
import '../domain/activity_log.dart';
import '../domain/activity_log_repository.dart';
import '../domain/field_value.dart';
import 'log_value_codec.dart';

/// drift implementation of [ActivityLogRepository].
///
/// Reads: one query for the logs (indexed by `idx_activity_logs_type_day`),
/// one for all their values (`log_id IN (…)`), joined to fields for public IDs
/// and types. No N+1. Internal integer IDs never leave this class.
class DbActivityLogRepository implements ActivityLogRepository {
  DbActivityLogRepository(this._db, this._clock, this._logger);

  final AppDatabase _db;
  final Clock _clock;
  final AppLogger _logger;

  int _now() => _clock.nowUtc().millisecondsSinceEpoch;

  /// Re-runs [load] after any write to the tables it reads (no polling query).
  Stream<T> _watch<T>(Future<T> Function() load) => reactiveQuery(
    _db.tableUpdates(
      TableUpdateQuery.onAllTables([_db.activityLogs, _db.logValues]),
    ),
    load,
  );

  @override
  Stream<List<ActivityLog>> watchLogsForType(
    ActivityTypeId typeId, {
    int limit = 50,
  }) => guardStorageStream(
    'watchLogsForType',
    _watch(() async {
      final type = await (_db.select(
        _db.activityTypes,
      )..where((t) => t.publicId.equals(typeId.value))).getSingleOrNull();
      if (type == null) return const <ActivityLog>[];
      final rows =
          await (_db.select(_db.activityLogs)
                ..where(
                  (l) =>
                      l.activityTypeId.equals(type.internalId) &
                      isActive(l.deletedAt),
                )
                ..orderBy([
                  (l) => OrderingTerm.desc(l.localDate),
                  (l) => OrderingTerm.desc(l.startedAt),
                ])
                ..limit(limit))
              .get();
      return _hydrate(rows, {type.internalId: type.publicId});
    }),
  );

  @override
  Stream<List<ActivityLog>> watchLogsForDay(
    LocalDate date,
  ) => guardStorageStream(
    'watchLogsForDay',
    _watch(() async {
      final rows =
          await (_db.select(_db.activityLogs)
                ..where(
                  (l) =>
                      l.localDate.equals(date.toIso()) & isActive(l.deletedAt),
                )
                ..orderBy([(l) => OrderingTerm.asc(l.startedAt)]))
              .get();
      if (rows.isEmpty) return const <ActivityLog>[];
      final types =
          await (_db.select(_db.activityTypes)..where(
                (t) => t.internalId.isIn(
                  rows.map((r) => r.activityTypeId).toSet(),
                ),
              ))
              .get();
      return _hydrate(rows, {for (final t in types) t.internalId: t.publicId});
    }),
  );

  @override
  Stream<ActivityLog?> watchLog(ActivityLogId id) =>
      guardStorageStream('watchLog', _watch(() => _load(id)));

  @override
  Future<ActivityLog?> getLog(ActivityLogId id) =>
      guardStorage('getLog', () => _load(id));

  Future<ActivityLog?> _load(ActivityLogId id) async {
    final row =
        await (_db.select(_db.activityLogs)..where(
              (l) => l.publicId.equals(id.value) & isActive(l.deletedAt),
            ))
            .getSingleOrNull();
    if (row == null) return null;
    final type = await (_db.select(
      _db.activityTypes,
    )..where((t) => t.internalId.equals(row.activityTypeId))).getSingle();
    return (await _hydrate([row], {type.internalId: type.publicId})).single;
  }

  /// Loads all values for [rows] in one query and maps to domain logs.
  Future<List<ActivityLog>> _hydrate(
    List<ActivityLogRow> rows,
    Map<int, String> typePublicIds,
  ) async {
    if (rows.isEmpty) return const [];
    final query = _db.select(_db.logValues).join([
      innerJoin(
        _db.activityFields,
        _db.activityFields.internalId.equalsExp(_db.logValues.fieldId),
      ),
    ])..where(_db.logValues.logId.isIn(rows.map((r) => r.internalId)));
    final valuesByLog = <int, Map<ActivityFieldId, FieldValue>>{};
    for (final joined in await query.get()) {
      final value = joined.readTable(_db.logValues);
      final field = joined.readTable(_db.activityFields);
      try {
        valuesByLog.putIfAbsent(value.logId, () => {})[ActivityFieldId(
          field.publicId,
        )] = LogValueCodec.decode(
          FieldType.fromStorageKey(field.fieldType),
          value,
        );
      } on AppException catch (error) {
        // Render the rest of the log; the unreadable value is skipped and
        // logged with IDs only (error_handling.md §4).
        _logger.warning(
          'Unreadable value for field ${field.publicId}',
          error: error,
        );
      }
    }
    return [
      for (final r in rows)
        ActivityLog(
          id: ActivityLogId(r.publicId),
          activityTypeId: ActivityTypeId(typePublicIds[r.activityTypeId]!),
          startedAt: _instant(r.startedAt),
          endedAt: r.endedAt == null ? null : _instant(r.endedAt!),
          durationMs: r.durationMs,
          tzOffsetMinutes: r.tzOffsetMinutes,
          localDate: LocalDate.parse(r.localDate),
          notes: r.notes,
          values: valuesByLog[r.internalId] ?? const {},
          createdAt: _instant(r.createdAt),
          updatedAt: _instant(r.updatedAt),
        ),
    ];
  }

  static DateTime _instant(int ms) =>
      DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);

  /// Resolves the type's internal ID and its fields' public → internal IDs.
  Future<(int, Map<String, int>)> _resolveType(ActivityTypeId typeId) async {
    final type = await (_db.select(
      _db.activityTypes,
    )..where((t) => t.publicId.equals(typeId.value))).getSingleOrNull();
    if (type == null) {
      throw NotFoundException(debugContext: 'log type ${typeId.value}');
    }
    final fields = await (_db.select(
      _db.activityFields,
    )..where((f) => f.activityTypeId.equals(type.internalId))).get();
    return (
      type.internalId,
      {for (final f in fields) f.publicId: f.internalId},
    );
  }

  @override
  Future<void> create(ActivityLog log) => guardStorage('createActivityLog', () {
    return _db.transaction(() async {
      final (typeId, fieldIds) = await _resolveType(log.activityTypeId);
      final logId = await _db
          .into(_db.activityLogs)
          .insert(
            ActivityLogsCompanion.insert(
              publicId: log.id.value,
              activityTypeId: typeId,
              startedAt: log.startedAt.millisecondsSinceEpoch,
              endedAt: Value(log.endedAt?.millisecondsSinceEpoch),
              durationMs: Value(log.durationMs),
              tzOffsetMinutes: log.tzOffsetMinutes,
              localDate: log.localDate.toIso(),
              notes: Value(log.notes),
              createdAt: log.createdAt.millisecondsSinceEpoch,
              updatedAt: log.updatedAt.millisecondsSinceEpoch,
            ),
          );
      final now = log.createdAt.millisecondsSinceEpoch;
      for (final MapEntry(key: fieldId, :value) in log.values.entries) {
        await _db
            .into(_db.logValues)
            .insert(
              LogValueCodec.columns(value).copyWith(
                logId: Value(logId),
                fieldId: Value(_fieldInternalId(fieldIds, fieldId)),
                createdAt: Value(now),
                updatedAt: Value(now),
              ),
            );
      }
    });
  });

  int _fieldInternalId(Map<String, int> fieldIds, ActivityFieldId id) =>
      fieldIds[id.value] ??
      (throw NotFoundException(
        debugContext: 'field ${id.value} not in log type',
      ));

  @override
  Future<void> update(ActivityLog log) => guardStorage('updateActivityLog', () {
    return _db.transaction(() async {
      final row =
          await (_db.select(_db.activityLogs)..where(
                (l) => l.publicId.equals(log.id.value) & isActive(l.deletedAt),
              ))
              .getSingleOrNull();
      if (row == null) {
        throw const NotFoundException(debugContext: 'updateActivityLog');
      }
      final (_, fieldIds) = await _resolveType(log.activityTypeId);
      final now = log.updatedAt.millisecondsSinceEpoch;
      await (_db.update(
        _db.activityLogs,
      )..where((l) => l.internalId.equals(row.internalId))).write(
        ActivityLogsCompanion(
          startedAt: Value(log.startedAt.millisecondsSinceEpoch),
          endedAt: Value(log.endedAt?.millisecondsSinceEpoch),
          durationMs: Value(log.durationMs),
          tzOffsetMinutes: Value(log.tzOffsetMinutes),
          localDate: Value(log.localDate.toIso()),
          notes: Value(log.notes),
          updatedAt: Value(now),
        ),
      );

      // Diff values by field: update changed rows in place (keeping their
      // internal_id/created_at), insert new ones, hard-delete cleared ones
      // (aggregate children have no tombstones, ADR-022).
      final stored = await (_db.select(
        _db.logValues,
      )..where((v) => v.logId.equals(row.internalId))).get();
      final storedByField = {for (final v in stored) v.fieldId: v};
      final wanted = <int, FieldValue>{
        for (final MapEntry(key: fieldId, :value) in log.values.entries)
          _fieldInternalId(fieldIds, fieldId): value,
      };
      for (final v in stored) {
        if (!wanted.containsKey(v.fieldId)) {
          await (_db.delete(
            _db.logValues,
          )..where((x) => x.internalId.equals(v.internalId))).go();
        }
      }
      for (final MapEntry(key: fieldInternalId, :value) in wanted.entries) {
        final existing = storedByField[fieldInternalId];
        if (existing == null) {
          await _db
              .into(_db.logValues)
              .insert(
                LogValueCodec.columns(value).copyWith(
                  logId: Value(row.internalId),
                  fieldId: Value(fieldInternalId),
                  createdAt: Value(now),
                  updatedAt: Value(now),
                ),
              );
        } else {
          await (_db.update(_db.logValues)
                ..where((x) => x.internalId.equals(existing.internalId)))
              .write(LogValueCodec.updateColumns(value, now));
        }
      }
    });
  });

  @override
  Future<void> softDelete(ActivityLogId id) => _setDeleted(id, deleted: true);

  @override
  Future<void> restore(ActivityLogId id) => _setDeleted(id, deleted: false);

  Future<void> _setDeleted(ActivityLogId id, {required bool deleted}) =>
      guardStorage(
        deleted ? 'deleteActivityLog' : 'restoreActivityLog',
        () async {
          final now = _now();
          final count =
              await (_db.update(
                _db.activityLogs,
              )..where((l) => l.publicId.equals(id.value))).write(
                ActivityLogsCompanion(
                  deletedAt: Value(deleted ? now : null),
                  updatedAt: Value(now),
                ),
              );
          if (count == 0) {
            throw NotFoundException(debugContext: 'setDeleted ${id.value}');
          }
        },
      );
}
