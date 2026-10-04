import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/reactive_query.dart';
import '../../../core/database/soft_delete.dart';
import '../../../core/database/storage_guard.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/local_date.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../domain/plan.dart';
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
      ]);

  Plan _toDomain(TypedResult joined) {
    final row = joined.readTable(_db.plans);
    final type = joined.readTableOrNull(_db.activityTypes);
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
    );
  }

  @override
  Stream<List<Plan>> watchPlansForDay(LocalDate date) => guardStorageStream(
    'watchPlansForDay',
    reactiveQuery(
      _db.tableUpdates(
        TableUpdateQuery.onAllTables([_db.plans, _db.activityTypes]),
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
    final typeId = await _typeInternalId(plan.activityTypeId);
    await _db
        .into(_db.plans)
        .insert(
          _columns(plan, typeId).copyWith(
            publicId: Value(plan.id.value),
            createdAt: Value(plan.createdAt.millisecondsSinceEpoch),
          ),
        );
  });

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
}
