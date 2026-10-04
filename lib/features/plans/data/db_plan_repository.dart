import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart' hide PlanSeries;
import '../../../core/database/reactive_query.dart';
import '../../../core/database/soft_delete.dart';
import '../../../core/database/storage_guard.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/local_date.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../domain/plan.dart';
import '../domain/plan_series.dart';
import '../domain/plan_repository.dart';

/// drift implementation of [PlanRepository] (database.md §3.7). A date's
/// plans load in one query on `idx_plans_day`, joined to activity types for
/// their public IDs. Internal integer IDs stay here.
class DbPlanRepository implements PlanRepository {
  DbPlanRepository(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  int _now() => _clock.nowUtc().millisecondsSinceEpoch;

  static DateTime? _instant(int? ms) =>
      ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);

  JoinedSelectStatement<HasResultSet, dynamic> _plansWithType() =>
      _db.select(_db.plans).join([
        leftOuterJoin(
          _db.activityTypes,
          _db.activityTypes.internalId.equalsExp(_db.plans.activityTypeId),
        ),
        leftOuterJoin(
          _db.planSeries,
          _db.planSeries.internalId.equalsExp(_db.plans.seriesId),
        ),
      ]);

  Plan _toDomain(TypedResult joined) {
    final row = joined.readTable(_db.plans);
    final type = joined.readTableOrNull(_db.activityTypes);
    final series = joined.readTableOrNull(_db.planSeries);
    return Plan(
      id: PlanId(row.publicId),
      planDate: LocalDate.parse(row.planDate),
      activityTypeId: type == null ? null : ActivityTypeId(type.publicId),
      title: row.title,
      notes: row.notes,
      plannedStartAt: _instant(row.plannedStartAt),
      plannedEndAt: _instant(row.plannedEndAt),
      plannedDurationMs: row.plannedDurationMs,
      sortOrder: row.sortOrder,
      status: PlanStatus.fromStorageKey(row.status),
      createdAt: _instant(row.createdAt)!,
      updatedAt: _instant(row.updatedAt)!,
      seriesId: series == null ? null : PlanSeriesId(series.publicId),
    );
  }

  @override
  Stream<List<Plan>> watchPlansForDay(LocalDate date) => guardStorageStream(
    'watchPlansForDay',
    reactiveQuery(
      _db.tableUpdates(
        TableUpdateQuery.onAllTables([
          _db.plans,
          _db.activityTypes,
          _db.planSeries,
        ]),
      ),
      () async {
        final query = _plansWithType()
          ..where(
            _db.plans.planDate.equals(date.toIso()) &
                isActive(_db.plans.deletedAt),
          )
          ..orderBy([OrderingTerm.asc(_db.plans.sortOrder)]);
        return [for (final row in await query.get()) _toDomain(row)];
      },
    ),
  );

  @override
  Future<Plan?> getPlan(PlanId id) => guardStorage('getPlan', () async {
    final query = _plansWithType()
      ..where(
        _db.plans.publicId.equals(id.value) & isActive(_db.plans.deletedAt),
      );
    final row = await query.getSingleOrNull();
    return row == null ? null : _toDomain(row);
  });

  @override
  Future<int> nextSortOrder(LocalDate date) =>
      guardStorage('nextSortOrder', () async {
        final row = await _db
            .customSelect(
              'SELECT COALESCE(MAX(sort_order), -1) + 1 AS n FROM plans '
              'WHERE plan_date = ? AND deleted_at IS NULL',
              variables: [Variable(date.toIso())],
              readsFrom: {_db.plans},
            )
            .getSingle();
        return row.read<int>('n');
      });

  @override
  Future<bool> hasRecords(PlanId id) => guardStorage('hasRecords', () async {
    final row = await _db
        .customSelect(
          'SELECT EXISTS (SELECT 1 FROM activity_logs l '
          'JOIN plans p ON p.internal_id = l.plan_id '
          'WHERE p.public_id = ? AND l.deleted_at IS NULL) AS e',
          variables: [Variable(id.value)],
          readsFrom: {_db.activityLogs, _db.plans},
        )
        .getSingle();
    return row.read<int>('e') == 1;
  });

  Future<int?> _typeInternalId(ActivityTypeId? id) async {
    if (id == null) return null;
    final row = await (_db.select(
      _db.activityTypes,
    )..where((t) => t.publicId.equals(id.value))).getSingleOrNull();
    return row?.internalId ??
        (throw NotFoundException(debugContext: 'plan type ${id.value}'));
  }

  PlansCompanion _columns(Plan plan, int? typeId) => PlansCompanion(
    planDate: Value(plan.planDate.toIso()),
    activityTypeId: Value(typeId),
    title: Value(plan.title),
    notes: Value(plan.notes),
    plannedStartAt: Value(plan.plannedStartAt?.millisecondsSinceEpoch),
    plannedEndAt: Value(plan.plannedEndAt?.millisecondsSinceEpoch),
    plannedDurationMs: Value(plan.plannedDurationMs),
    sortOrder: Value(plan.sortOrder),
    status: Value(plan.status.storageKey),
    updatedAt: Value(plan.updatedAt.millisecondsSinceEpoch),
  );

  @override
  Future<void> create(Plan plan) => guardStorage('createPlan', () async {
    await _db.into(_db.plans).insert(await _newRow(plan));
  });

  Future<PlansCompanion> _newRow(Plan plan) async =>
      _columns(plan, await _typeInternalId(plan.activityTypeId)).copyWith(
        publicId: Value(plan.id.value),
        createdAt: Value(plan.createdAt.millisecondsSinceEpoch),
        seriesId: Value(
          plan.seriesId == null
              ? null
              : await _seriesInternalId(plan.seriesId!),
        ),
      );

  Future<int> _seriesInternalId(PlanSeriesId id) async {
    final row = await (_db.select(
      _db.planSeries,
    )..where((s) => s.publicId.equals(id.value))).getSingleOrNull();
    return row?.internalId ??
        (throw NotFoundException(debugContext: 'series ${id.value}'));
  }

  @override
  Future<void> update(Plan plan) => guardStorage('updatePlan', () async {
    final typeId = await _typeInternalId(plan.activityTypeId);
    final count =
        await (_db.update(_db.plans)..where(
              (p) => p.publicId.equals(plan.id.value) & isActive(p.deletedAt),
            ))
            .write(_columns(plan, typeId));
    if (count == 0) {
      throw NotFoundException(debugContext: 'updatePlan ${plan.id.value}');
    }
  });

  @override
  Future<void> reorder(List<PlanId> order, DateTime updatedAt) =>
      guardStorage('reorderPlans', () {
        return _db.transaction(() async {
          for (final (position, id) in order.indexed) {
            await (_db.update(
              _db.plans,
            )..where((p) => p.publicId.equals(id.value))).write(
              PlansCompanion(
                sortOrder: Value(position),
                updatedAt: Value(updatedAt.millisecondsSinceEpoch),
              ),
            );
          }
        });
      });

  @override
  Future<void> softDelete(PlanId id) => _setDeleted(id, deleted: true);

  @override
  Future<void> restore(PlanId id) => _setDeleted(id, deleted: false);

  Future<void> _setDeleted(PlanId id, {required bool deleted}) =>
      guardStorage(deleted ? 'deletePlan' : 'restorePlan', () async {
        final now = _now();
        final count =
            await (_db.update(
              _db.plans,
            )..where((p) => p.publicId.equals(id.value))).write(
              PlansCompanion(
                deletedAt: Value(deleted ? now : null),
                updatedAt: Value(now),
              ),
            );
        if (count == 0) {
          throw NotFoundException(debugContext: 'setDeleted ${id.value}');
        }
      });

  @override
  Stream<List<Plan>> watchPlansForRange(LocalDate from, LocalDate to) =>
      guardStorageStream(
        'watchPlansForRange',
        reactiveQuery(
          _db.tableUpdates(
            TableUpdateQuery.onAllTables([
              _db.plans,
              _db.activityTypes,
              _db.planSeries,
            ]),
          ),
          () async {
            final query = _plansWithType()
              ..where(
                _db.plans.planDate.isBetweenValues(from.toIso(), to.toIso()) &
                    isActive(_db.plans.deletedAt),
              )
              ..orderBy([
                OrderingTerm.asc(_db.plans.planDate),
                OrderingTerm.asc(_db.plans.sortOrder),
              ]);
            return [for (final row in await query.get()) _toDomain(row)];
          },
        ),
      );

  PlanSeries _seriesToDomain(PlanSeriesRow row, ActivityTypeRow? type) =>
      PlanSeries(
        id: PlanSeriesId(row.publicId),
        title: row.title,
        activityTypeId: type == null ? null : ActivityTypeId(type.publicId),
        notes: row.notes,
        startMinute: row.startMinute,
        durationMs: row.durationMs,
        rule: RepeatRule(
          weekdays: RepeatRule.weekdaysFromMask(row.weekdays),
          intervalWeeks: row.intervalWeeks,
          endDate: row.endDate == null ? null : LocalDate.parse(row.endDate!),
        ),
        startDate: LocalDate.parse(row.startDate),
        createdAt: _instant(row.createdAt)!,
        updatedAt: _instant(row.updatedAt)!,
      );

  JoinedSelectStatement<HasResultSet, dynamic> _seriesWithType() =>
      _db.select(_db.planSeries).join([
        leftOuterJoin(
          _db.activityTypes,
          _db.activityTypes.internalId.equalsExp(_db.planSeries.activityTypeId),
        ),
      ]);

  @override
  Future<void> createSeries(PlanSeries series) =>
      guardStorage('createSeries', () async {
        await _db
            .into(_db.planSeries)
            .insert(
              PlanSeriesCompanion.insert(
                publicId: series.id.value,
                activityTypeId: Value(
                  await _typeInternalId(series.activityTypeId),
                ),
                title: series.title,
                notes: Value(series.notes),
                startMinute: Value(series.startMinute),
                durationMs: Value(series.durationMs),
                weekdays: series.rule.weekdaysMask,
                intervalWeeks: Value(series.rule.intervalWeeks),
                startDate: series.startDate.toIso(),
                endDate: Value(series.rule.endDate?.toIso()),
                createdAt: series.createdAt.millisecondsSinceEpoch,
                updatedAt: series.updatedAt.millisecondsSinceEpoch,
              ),
            );
      });

  @override
  Future<PlanSeries?> getSeries(PlanSeriesId id) =>
      guardStorage('getSeries', () async {
        final query = _seriesWithType()
          ..where(
            _db.planSeries.publicId.equals(id.value) &
                isActive(_db.planSeries.deletedAt),
          );
        final row = await query.getSingleOrNull();
        return row == null
            ? null
            : _seriesToDomain(
                row.readTable(_db.planSeries),
                row.readTableOrNull(_db.activityTypes),
              );
      });

  @override
  Future<List<PlanSeries>> seriesBetween(LocalDate from, LocalDate to) =>
      guardStorage('seriesBetween', () async {
        final query = _seriesWithType()
          ..where(
            _db.planSeries.startDate.isSmallerOrEqualValue(to.toIso()) &
                (_db.planSeries.endDate.isNull() |
                    _db.planSeries.endDate.isBiggerOrEqualValue(from.toIso())) &
                isActive(_db.planSeries.deletedAt),
          );
        return [
          for (final row in await query.get())
            _seriesToDomain(
              row.readTable(_db.planSeries),
              row.readTableOrNull(_db.activityTypes),
            ),
        ];
      });

  @override
  Future<void> setSeriesEnd(PlanSeriesId id, LocalDate? end, DateTime now) =>
      guardStorage('setSeriesEnd', () async {
        await (_db.update(
          _db.planSeries,
        )..where((s) => s.publicId.equals(id.value))).write(
          PlanSeriesCompanion(
            endDate: Value(end?.toIso()),
            updatedAt: Value(now.millisecondsSinceEpoch),
          ),
        );
      });

  @override
  Future<void> deleteSeries(PlanSeriesId id, DateTime now) =>
      guardStorage('deleteSeries', () async {
        await (_db.update(
          _db.planSeries,
        )..where((s) => s.publicId.equals(id.value))).write(
          PlanSeriesCompanion(
            deletedAt: Value(now.millisecondsSinceEpoch),
            updatedAt: Value(now.millisecondsSinceEpoch),
          ),
        );
      });

  @override
  Future<void> linkToSeries(PlanId id, PlanSeriesId seriesId) =>
      guardStorage('linkToSeries', () async {
        final series = await _seriesInternalId(seriesId);
        await (_db.update(
          _db.plans,
        )..where((p) => p.publicId.equals(id.value))).write(
          PlansCompanion(seriesId: Value(series), updatedAt: Value(_now())),
        );
      });

  @override
  Future<bool> createOccurrence(Plan plan) =>
      guardStorage('createOccurrence', () async {
        final id = await _db
            .into(_db.plans)
            .insert(await _newRow(plan), mode: InsertMode.insertOrIgnore);
        // insertOrIgnore reports the last row ID even when it ignored the row.
        final row = await (_db.select(
          _db.plans,
        )..where((p) => p.publicId.equals(plan.id.value))).getSingleOrNull();
        return id > 0 && row != null;
      });

  @override
  Future<List<PlanId>> deleteOpenOccurrences(
    PlanSeriesId id,
    LocalDate from,
    DateTime now,
  ) => guardStorage('deleteOpenOccurrences', () async {
    final rows = await _db
        .customSelect(
          'SELECT p.public_id FROM plans p '
          'JOIN plan_series s ON s.internal_id = p.series_id '
          "WHERE s.public_id = ? AND p.plan_date >= ? AND p.status = 'planned' "
          'AND p.deleted_at IS NULL AND NOT EXISTS (SELECT 1 FROM activity_logs l '
          'WHERE l.plan_id = p.internal_id AND l.deleted_at IS NULL)',
          variables: [Variable(id.value), Variable(from.toIso())],
          readsFrom: {_db.plans, _db.planSeries, _db.activityLogs},
        )
        .get();
    final ids = [for (final r in rows) r.read<String>('public_id')];
    if (ids.isNotEmpty) {
      await (_db.update(_db.plans)..where((p) => p.publicId.isIn(ids))).write(
        PlansCompanion(
          deletedAt: Value(now.millisecondsSinceEpoch),
          updatedAt: Value(now.millisecondsSinceEpoch),
        ),
      );
    }
    return [for (final i in ids) PlanId(i)];
  });
}
