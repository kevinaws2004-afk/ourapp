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
import '../../plans/domain/plan.dart';
import '../domain/activity_log.dart';
import '../domain/activity_log_repository.dart';
import '../domain/field_value.dart';
import 'log_value_codec.dart';

/// drift implementation of [ActivityLogRepository].
///
/// Reads: one query for the logs (indexed by `idx_activity_logs_type_day`),
/// one for all their Repeating Group items and one for all their values
/// (`log_id IN (…)`), joined to fields for public IDs and types. No N+1.
/// Internal integer IDs never leave this class.
///
/// Repeating Groups are relational (ADR-027): each item is a
/// `log_group_items` row, its sub-field values are `log_values` rows with
/// `group_item_id`, and a group field has no value row of its own.
class DbActivityLogRepository implements ActivityLogRepository {
  DbActivityLogRepository(this._db, this._clock, this._logger);

  final AppDatabase _db;
  final Clock _clock;
  final AppLogger _logger;

  int _now() => _clock.nowUtc().millisecondsSinceEpoch;

  /// Re-runs [load] after any write to the tables it reads (no polling query).
  Stream<T> _watch<T>(Future<T> Function() load) => reactiveQuery(
    _db.tableUpdates(
      TableUpdateQuery.onAllTables([
        _db.activityLogs,
        _db.logGroupItems,
        _db.logValues,
      ]),
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
  Stream<List<ActivityLog>> watchLogsForPlanDate(LocalDate planDate) =>
      guardStorageStream(
        'watchLogsForPlanDate',
        reactiveQuery(
          _db.tableUpdates(
            TableUpdateQuery.onAllTables([
              _db.activityLogs,
              _db.logGroupItems,
              _db.logValues,
              _db.plans,
            ]),
          ),
          () async {
            final rows = await _db
                .customSelect(
                  'SELECT l.* FROM activity_logs l '
                  'JOIN plans p ON p.internal_id = l.plan_id '
                  'WHERE p.plan_date = ? AND p.deleted_at IS NULL '
                  'AND l.deleted_at IS NULL ORDER BY l.started_at',
                  variables: [Variable(planDate.toIso())],
                  readsFrom: {_db.activityLogs, _db.plans},
                )
                .asyncMap((row) => _db.activityLogs.mapFromRow(row))
                .get();
            if (rows.isEmpty) return const <ActivityLog>[];
            final types =
                await (_db.select(_db.activityTypes)..where(
                      (t) => t.internalId.isIn(
                        rows.map((r) => r.activityTypeId).toSet(),
                      ),
                    ))
                    .get();
            return _hydrate(rows, {
              for (final t in types) t.internalId: t.publicId,
            });
          },
        ),
      );

  @override
  Stream<ActivityLog?> watchLog(ActivityLogId id) =>
      guardStorageStream('watchLog', _watch(() => _load(id)));

  @override
  Future<ActivityLog?> getLog(ActivityLogId id) =>
      guardStorage('getLog', () => _load(id));

  @override
  Future<ActivityLog?> getLogForPlan(PlanId planId) =>
      guardStorage('getLogForPlan', () async {
        final row = await _db
            .customSelect(
              'SELECT l.public_id FROM activity_logs l '
              'JOIN plans p ON p.internal_id = l.plan_id '
              'WHERE p.public_id = ? AND l.deleted_at IS NULL '
              'ORDER BY l.started_at, l.internal_id LIMIT 1',
              variables: [Variable(planId.value)],
              readsFrom: {_db.activityLogs, _db.plans},
            )
            .getSingleOrNull();
        return row == null
            ? null
            : _load(ActivityLogId(row.read<String>('public_id')));
      });

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

  /// Loads all items and values for [rows] (two queries) and maps to domain
  /// logs, rebuilding each Repeating Group's item tree.
  Future<List<ActivityLog>> _hydrate(
    List<ActivityLogRow> rows,
    Map<int, String> typePublicIds,
  ) async {
    if (rows.isEmpty) return const [];
    final logIds = rows.map((r) => r.internalId);
    final planInternalIds = {
      for (final r in rows)
        if (r.planId != null) r.planId!,
    };
    final planPublicIds = planInternalIds.isEmpty
        ? const <int, String>{}
        : {
            for (final p in await (_db.select(
              _db.plans,
            )..where((p) => p.internalId.isIn(planInternalIds))).get())
              p.internalId: p.publicId,
          };

    final itemQuery =
        _db.select(_db.logGroupItems).join([
            innerJoin(
              _db.activityFields,
              _db.activityFields.internalId.equalsExp(
                _db.logGroupItems.fieldId,
              ),
            ),
          ])
          ..where(_db.logGroupItems.logId.isIn(logIds))
          ..orderBy([OrderingTerm.asc(_db.logGroupItems.position)]);
    // Items in position order, keyed by their parent scope: (log, parent item
    // or null for top level).
    final itemsByScope = <(int, int?), List<(LogGroupItemRow, String)>>{};
    for (final joined in await itemQuery.get()) {
      final item = joined.readTable(_db.logGroupItems);
      final field = joined.readTable(_db.activityFields);
      itemsByScope.putIfAbsent((item.logId, item.parentItemId), () => []).add((
        item,
        field.publicId,
      ));
    }

    final valueQuery = _db.select(_db.logValues).join([
      innerJoin(
        _db.activityFields,
        _db.activityFields.internalId.equalsExp(_db.logValues.fieldId),
      ),
    ])..where(_db.logValues.logId.isIn(logIds));
    // Scalar values keyed by scope: (log, group item or null for top level).
    final valuesByScope = <(int, int?), Map<ActivityFieldId, FieldValue>>{};
    for (final joined in await valueQuery.get()) {
      final value = joined.readTable(_db.logValues);
      final field = joined.readTable(_db.activityFields);
      try {
        valuesByScope.putIfAbsent((
          value.logId,
          value.groupItemId,
        ), () => {})[ActivityFieldId(field.publicId)] = LogValueCodec.decode(
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

    /// Scalar values of a scope plus its groups (child items by field).
    Map<ActivityFieldId, FieldValue> scope(int logId, int? itemId) {
      final values = {...?valuesByScope[(logId, itemId)]};
      final groups = <ActivityFieldId, List<GroupItem>>{};
      for (final (item, fieldPublicId)
          in itemsByScope[(logId, itemId)] ??
              const <(LogGroupItemRow, String)>[]) {
        groups
            .putIfAbsent(ActivityFieldId(fieldPublicId), () => [])
            .add(
              GroupItem(
                id: GroupItemId(item.publicId),
                values: scope(logId, item.internalId),
              ),
            );
      }
      for (final MapEntry(:key, value: items) in groups.entries) {
        values[key] = RepeatingGroupValue(items);
      }
      return values;
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
          values: scope(r.internalId, null),
          planId: r.planId == null ? null : PlanId(planPublicIds[r.planId]!),
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
  Future<List<String>> textSuggestions(
    ActivityFieldId fieldId, {
    int limit = 50,
  }) => guardStorage('textSuggestions', () async {
    // Uses idx_log_values_field_normalized (field_id prefix) for the field's
    // rows; case-insensitive distinct, newest use first.
    final rows = await _db
        .customSelect(
          'SELECT v.text_value AS t, MAX(v.updated_at) AS u '
          'FROM log_values v '
          'JOIN activity_fields f ON f.internal_id = v.field_id '
          'JOIN activity_logs l ON l.internal_id = v.log_id '
          'WHERE f.public_id = ? AND l.deleted_at IS NULL '
          'AND v.text_value IS NOT NULL '
          'GROUP BY v.text_value COLLATE NOCASE '
          'ORDER BY u DESC LIMIT ?',
          variables: [Variable(fieldId.value), Variable(limit)],
          readsFrom: {_db.logValues, _db.activityFields, _db.activityLogs},
        )
        .get();
    return [for (final r in rows) r.read<String>('t')];
  });

  @override
  Future<void> create(ActivityLog log) => guardStorage('createActivityLog', () {
    return _db.transaction(() async {
      final (typeId, fieldIds) = await _resolveType(log.activityTypeId);
      final planId = log.planId == null
          ? null
          : (await (_db.select(_db.plans)
                          ..where((p) => p.publicId.equals(log.planId!.value)))
                        .getSingleOrNull())
                    ?.internalId ??
                (throw NotFoundException(
                  debugContext: 'log plan ${log.planId!.value}',
                ));
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
              planId: Value(planId),
              createdAt: log.createdAt.millisecondsSinceEpoch,
              updatedAt: log.updatedAt.millisecondsSinceEpoch,
            ),
          );
      await _insertScope(
        logId: logId,
        parentItemId: null,
        values: log.values,
        fieldIds: fieldIds,
        now: log.createdAt.millisecondsSinceEpoch,
      );
    });
  });

  /// Inserts a scope's values: scalar rows, and for each group its items
  /// (in order) followed by their own scopes.
  Future<void> _insertScope({
    required int logId,
    required int? parentItemId,
    required Map<ActivityFieldId, FieldValue> values,
    required Map<String, int> fieldIds,
    required int now,
  }) async {
    for (final MapEntry(key: fieldId, :value) in values.entries) {
      final fieldInternalId = _fieldInternalId(fieldIds, fieldId);
      if (value is RepeatingGroupValue) {
        for (final (position, item) in value.items.indexed) {
          final itemId = await _insertItem(
            logId: logId,
            fieldId: fieldInternalId,
            parentItemId: parentItemId,
            item: item,
            position: position,
            now: now,
          );
          await _insertScope(
            logId: logId,
            parentItemId: itemId,
            values: item.values,
            fieldIds: fieldIds,
            now: now,
          );
        }
      } else {
        await _insertValue(logId, fieldInternalId, parentItemId, value, now);
      }
    }
  }

  Future<int> _insertItem({
    required int logId,
    required int fieldId,
    required int? parentItemId,
    required GroupItem item,
    required int position,
    required int now,
  }) => _db
      .into(_db.logGroupItems)
      .insert(
        LogGroupItemsCompanion.insert(
          publicId: item.id.value,
          logId: logId,
          fieldId: fieldId,
          parentItemId: Value(parentItemId),
          position: position,
          createdAt: now,
          updatedAt: now,
        ),
      );

  Future<void> _insertValue(
    int logId,
    int fieldId,
    int? groupItemId,
    FieldValue value,
    int now,
  ) => _db
      .into(_db.logValues)
      .insert(
        LogValueCodec.columns(value).copyWith(
          logId: Value(logId),
          fieldId: Value(fieldId),
          groupItemId: Value(groupItemId),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

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

      // Diff by identity, keeping internal_id/created_at of unchanged rows:
      // items by public ID (removed items are hard-deleted with their
      // children and values via cascade), values per scope by field. Aggregate
      // children have no tombstones (ADR-022).
      final storedItems = await (_db.select(
        _db.logGroupItems,
      )..where((i) => i.logId.equals(row.internalId))).get();
      final storedValues = await (_db.select(
        _db.logValues,
      )..where((v) => v.logId.equals(row.internalId))).get();
      final wantedItems = <String>{};
      void collect(Map<ActivityFieldId, FieldValue> values) {
        for (final value in values.values) {
          if (value is RepeatingGroupValue) {
            for (final item in value.items) {
              wantedItems.add(item.id.value);
              collect(item.values);
            }
          }
        }
      }

      collect(log.values);
      for (final item in storedItems) {
        if (!wantedItems.contains(item.publicId)) {
          await (_db.delete(
            _db.logGroupItems,
          )..where((x) => x.internalId.equals(item.internalId))).go();
        }
      }
      final valuesByScope = <int?, List<LogValueRow>>{};
      for (final v in storedValues) {
        valuesByScope.putIfAbsent(v.groupItemId, () => []).add(v);
      }
      await _syncScope(
        logId: row.internalId,
        parentItemId: null,
        values: log.values,
        fieldIds: fieldIds,
        storedItems: {for (final i in storedItems) i.publicId: i},
        storedValues: valuesByScope,
        now: now,
      );
    });
  });

  /// Brings one scope in line with [values]: updates changed value rows in
  /// place, inserts new ones, deletes cleared ones; keeps existing items
  /// (updating position only) and inserts new ones, recursing into each.
  Future<void> _syncScope({
    required int logId,
    required int? parentItemId,
    required Map<ActivityFieldId, FieldValue> values,
    required Map<String, int> fieldIds,
    required Map<String, LogGroupItemRow> storedItems,
    required Map<int?, List<LogValueRow>> storedValues,
    required int now,
  }) async {
    final stored = {
      for (final v in storedValues[parentItemId] ?? const <LogValueRow>[])
        v.fieldId: v,
    };
    final wantedScalar = <int>{};
    for (final MapEntry(key: fieldId, :value) in values.entries) {
      final fieldInternalId = _fieldInternalId(fieldIds, fieldId);
      if (value is! RepeatingGroupValue) {
        wantedScalar.add(fieldInternalId);
        final existing = stored[fieldInternalId];
        if (existing == null) {
          await _insertValue(logId, fieldInternalId, parentItemId, value, now);
        } else if (LogValueCodec.decodeOrNull(value.fieldType, existing) !=
            value) {
          await (_db.update(_db.logValues)
                ..where((x) => x.internalId.equals(existing.internalId)))
              .write(LogValueCodec.updateColumns(value, now));
        }
        continue;
      }
      for (final (position, item) in value.items.indexed) {
        final existing = storedItems[item.id.value];
        final int itemId;
        if (existing == null) {
          itemId = await _insertItem(
            logId: logId,
            fieldId: fieldInternalId,
            parentItemId: parentItemId,
            item: item,
            position: position,
            now: now,
          );
        } else {
          itemId = existing.internalId;
          if (existing.position != position) {
            await (_db.update(
              _db.logGroupItems,
            )..where((x) => x.internalId.equals(itemId))).write(
              LogGroupItemsCompanion(
                position: Value(position),
                updatedAt: Value(now),
              ),
            );
          }
        }
        await _syncScope(
          logId: logId,
          parentItemId: itemId,
          values: item.values,
          fieldIds: fieldIds,
          storedItems: storedItems,
          storedValues: storedValues,
          now: now,
        );
      }
    }
    for (final v in stored.values) {
      if (!wantedScalar.contains(v.fieldId)) {
        await (_db.delete(
          _db.logValues,
        )..where((x) => x.internalId.equals(v.internalId))).go();
      }
    }
  }

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
