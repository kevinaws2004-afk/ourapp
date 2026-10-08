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
      ]);

  Challenge _toDomain(TypedResult joined) {
    final row = joined.readTable(_db.challenges);
    final type = joined.readTable(_db.activityTypes);
    return Challenge(
      id: ChallengeId(row.publicId),
      activityTypeId: ActivityTypeId(type.publicId),
      title: row.title,
      startDate: LocalDate.parse(row.startDate),
      targetDays: row.targetDays,
      createdAt: _instant(row.createdAt),
      updatedAt: _instant(row.updatedAt),
    );
  }

  Stream<T> _watch<T>(Future<T> Function() load) => reactiveQuery(
    _db.tableUpdates(
      TableUpdateQuery.onAllTables([
        _db.challenges,
        _db.activityTypes,
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
