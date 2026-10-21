import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/done_records.dart';
import '../../../core/database/reactive_query.dart';
import '../../../core/database/soft_delete.dart';
import '../../../core/database/storage_guard.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/local_date.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../domain/challenge.dart';
import '../domain/challenge_repository.dart';

/// drift implementation of [ChallengeRepository] (database.md §3.12). A
/// challenge row holds only its definition; the days it counts come from one
/// query over the activity's logs. Internal integer IDs stay here.
class DbChallengeRepository implements ChallengeRepository {
  DbChallengeRepository(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  int _now() => _clock.nowUtc().millisecondsSinceEpoch;

  static DateTime _instant(int ms) =>
      DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);

  JoinedSelectStatement<HasResultSet, dynamic> _withType() =>
      _db.select(_db.challenges).join([
        innerJoin(
          _db.activityTypes,
          _db.activityTypes.internalId.equalsExp(_db.challenges.activityTypeId),
        ),
        leftOuterJoin(
          _db.activityFields,
          _db.activityFields.internalId.equalsExp(_db.challenges.amountFieldId),
        ),
      ]);

  Challenge _toDomain(TypedResult joined) {
    final row = joined.readTable(_db.challenges);
    final type = joined.readTable(_db.activityTypes);
    final field = joined.readTableOrNull(_db.activityFields);
    return Challenge(
      id: ChallengeId(row.publicId),
      activityTypeId: ActivityTypeId(type.publicId),
      title: row.title,
      startDate: LocalDate.parse(row.startDate),
      targetDays: row.targetDays,
      createdAt: _instant(row.createdAt),
      updatedAt: _instant(row.updatedAt),
      kind: GoalKind.fromStorageKey(row.kind),
      timesPerWeek: row.timesPerWeek,
      amount: row.amount,
      amountFieldId: field == null ? null : ActivityFieldId(field.publicId),
      amountPeriod: GoalPeriod.fromStorageKey(row.amountPeriod),
      restDays: row.restDays,
      startValue: row.startValue,
    );
  }

  Stream<T> _watch<T>(Future<T> Function() load) => reactiveQuery(
    _db.tableUpdates(
      TableUpdateQuery.onAllTables([
        _db.challenges,
        _db.activityTypes,
        _db.activityFields,
        _db.activityLogs,
        _db.logValues,
        _db.plans,
      ]),
    ),
    load,
  );

  @override
  Stream<List<Challenge>> watchChallenges() => guardStorageStream(
    'watchChallenges',
    _watch(() async {
      final query = _withType()
        ..where(isActive(_db.challenges.deletedAt))
        ..orderBy([
          OrderingTerm.asc(_db.challenges.createdAt),
          OrderingTerm.asc(_db.challenges.internalId),
        ]);
      return [for (final row in await query.get()) _toDomain(row)];
    }),
  );

  @override
  Stream<Challenge?> watchChallenge(ChallengeId id) =>
      guardStorageStream('watchChallenge', _watch(() => _find(id)));

  @override
  Future<Challenge?> getChallenge(ChallengeId id) =>
      guardStorage('getChallenge', () => _find(id));

  Future<Challenge?> _find(ChallengeId id) async {
    final query = _withType()
      ..where(
        _db.challenges.publicId.equals(id.value) &
            isActive(_db.challenges.deletedAt),
      );
    final row = await query.getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Stream<Map<ActivityTypeId, Set<LocalDate>>> watchDoneDays() =>
      guardStorageStream(
        'watchDoneDays',
        _watch(() async {
          // idx_challenges_type narrows to activities that have an active
          // challenge; idx_activity_logs_type_day serves the days.
          final rows = await _db
              .customSelect(
                'SELECT DISTINCT t.public_id AS id, l.local_date AS d '
                'FROM activity_logs l '
                'JOIN activity_types t ON t.internal_id = l.activity_type_id '
                'WHERE l.deleted_at IS NULL AND ${doneRecordSql('l')} '
                'AND EXISTS (SELECT 1 FROM challenges c '
                'WHERE c.activity_type_id = l.activity_type_id '
                'AND c.deleted_at IS NULL)',
                readsFrom: {
                  _db.activityLogs,
                  _db.activityTypes,
                  _db.challenges,
                  _db.logValues,
                  _db.plans,
                },
              )
              .get();
          final days = <ActivityTypeId, Set<LocalDate>>{};
          for (final r in rows) {
            days
                .putIfAbsent(ActivityTypeId(r.read<String>('id')), () => {})
                .add(LocalDate.parse(r.read<String>('d')));
          }
          return days;
        }),
      );

  @override
  Stream<Map<ChallengeId, Map<LocalDate, double>>>
  watchAmounts() => guardStorageStream(
    'watchAmounts',
    _watch(() async {
      // Time: the done records' durations. A field: its values (numbers
      // in their canonical unit, or durations), list rows included.
      final rows = await _db
          .customSelect(
            'SELECT c.public_id AS id, l.local_date AS d, '
            'SUM(l.duration_ms) AS v '
            'FROM challenges c '
            'JOIN activity_logs l ON l.activity_type_id = c.activity_type_id '
            "WHERE c.kind = 'amount' AND c.amount_field_id IS NULL "
            'AND c.deleted_at IS NULL AND l.deleted_at IS NULL '
            'AND l.duration_ms IS NOT NULL '
            'GROUP BY c.public_id, l.local_date '
            'UNION ALL '
            'SELECT c.public_id AS id, l.local_date AS d, '
            'SUM(COALESCE(v.normalized_value, v.duration_ms)) AS v '
            'FROM challenges c '
            'JOIN activity_logs l ON l.activity_type_id = c.activity_type_id '
            'JOIN log_values v ON v.log_id = l.internal_id '
            'AND v.field_id = c.amount_field_id '
            "WHERE c.kind = 'amount' AND c.amount_field_id IS NOT NULL "
            'AND c.deleted_at IS NULL AND l.deleted_at IS NULL '
            'GROUP BY c.public_id, l.local_date',
            readsFrom: {_db.challenges, _db.activityLogs, _db.logValues},
          )
          .get();
      final amounts = <ChallengeId, Map<LocalDate, double>>{};
      for (final r in rows) {
        final value = r.readNullable<double>('v');
        if (value == null) continue;
        amounts.putIfAbsent(
          ChallengeId(r.read<String>('id')),
          () => {},
        )[LocalDate.parse(r.read<String>('d'))] = value;
      }
      // Target goals: the value recorded each day (the day's last, so a
      // morning and an evening weigh-in don't add up), any date: one from
      // before the start is where it started.
      final targets = await _db
          .customSelect(
            'SELECT c.public_id AS id, l.local_date AS d, '
            'v.normalized_value AS v '
            'FROM challenges c '
            'JOIN activity_logs l ON l.activity_type_id = c.activity_type_id '
            'JOIN log_values v ON v.log_id = l.internal_id '
            'AND v.field_id = c.amount_field_id '
            "WHERE c.kind = 'target' AND c.deleted_at IS NULL "
            'AND l.deleted_at IS NULL AND v.normalized_value IS NOT NULL '
            'ORDER BY l.started_at, l.internal_id',
            readsFrom: {_db.challenges, _db.activityLogs, _db.logValues},
          )
          .get();
      for (final r in targets) {
        amounts.putIfAbsent(
          ChallengeId(r.read<String>('id')),
          () => {},
        )[LocalDate.parse(r.read<String>('d'))] = r.read<double>(
          'v',
        );
      }
      return amounts;
    }),
  );

  /// The internal ID of the field [id], or null.
  Future<int?> _fieldInternalId(ActivityFieldId? id) async {
    if (id == null) return null;
    final row = await (_db.select(
      _db.activityFields,
    )..where((f) => f.publicId.equals(id.value))).getSingleOrNull();
    if (row == null) {
      throw const NotFoundException(debugContext: 'challenge amount field');
    }
    return row.internalId;
  }

  @override
  Future<void> create(Challenge challenge) =>
      guardStorage('createChallenge', () async {
        final type =
            await (_db.select(_db.activityTypes)..where(
                  (t) => t.publicId.equals(challenge.activityTypeId.value),
                ))
                .getSingleOrNull();
        if (type == null) {
          throw const NotFoundException(
            debugContext: 'createChallenge activity type',
          );
        }
        await _db
            .into(_db.challenges)
            .insert(
              ChallengesCompanion.insert(
                publicId: challenge.id.value,
                activityTypeId: type.internalId,
                title: challenge.title,
                startDate: challenge.startDate.toIso(),
                targetDays: challenge.targetDays,
                createdAt: challenge.createdAt.millisecondsSinceEpoch,
                updatedAt: challenge.updatedAt.millisecondsSinceEpoch,
                kind: Value(challenge.kind.storageKey),
                timesPerWeek: Value(challenge.timesPerWeek),
                amount: Value(challenge.amount),
                amountFieldId: Value(
                  await _fieldInternalId(challenge.amountFieldId),
                ),
                amountPeriod: Value(challenge.amountPeriod?.storageKey),
                restDays: Value(challenge.restDays),
                startValue: Value(challenge.startValue),
              ),
            );
      });

  @override
  Future<void> update(
    Challenge challenge,
  ) => guardStorage('updateChallenge', () async {
    final updated =
        await (_db.update(_db.challenges)..where(
              (c) =>
                  c.publicId.equals(challenge.id.value) & isActive(c.deletedAt),
            ))
            .write(
              ChallengesCompanion(
                title: Value(challenge.title),
                startDate: Value(challenge.startDate.toIso()),
                targetDays: Value(challenge.targetDays),
                updatedAt: Value(challenge.updatedAt.millisecondsSinceEpoch),
                timesPerWeek: Value(challenge.timesPerWeek),
                amount: Value(challenge.amount),
                restDays: Value(challenge.restDays),
                startValue: Value(challenge.startValue),
              ),
            );
    if (updated == 0) {
      throw NotFoundException(
        debugContext: 'updateChallenge ${challenge.id.value}',
      );
    }
  });

  @override
  Future<void> softDelete(ChallengeId id) => guardStorage(
    'softDeleteChallenge',
    () async {
      final now = _now();
      await (_db.update(_db.challenges)
            ..where((c) => c.publicId.equals(id.value) & isActive(c.deletedAt)))
          .write(
            ChallengesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
          );
    },
  );

  @override
  Future<void> restore(ChallengeId id) =>
      guardStorage('restoreChallenge', () async {
        await (_db.update(
          _db.challenges,
        )..where((c) => c.publicId.equals(id.value))).write(
          ChallengesCompanion(
            deletedAt: const Value(null),
            updatedAt: Value(_now()),
          ),
        );
      });
}
