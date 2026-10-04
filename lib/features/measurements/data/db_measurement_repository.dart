import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/reactive_query.dart';
import '../../../core/database/soft_delete.dart';
import '../../../core/database/storage_guard.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/local_date.dart';
import '../domain/measurement.dart';
import '../domain/measurement_repository.dart';

/// drift implementation of [MeasurementRepository] (database.md §3.9).
class DbMeasurementRepository implements MeasurementRepository {
  DbMeasurementRepository(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  static DateTime _instant(int ms) =>
      DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);

  Measurement? _toDomain(MeasurementRow r) {
    final type = MeasurementType.fromStorageKey(r.measurementType);
    if (type == null) return null; // a type from a newer app version
    return Measurement(
      id: MeasurementId(r.publicId),
      type: type,
      value: r.value,
      unitCode: r.unitCode,
      normalizedValue: r.normalizedValue,
      recordedAt: _instant(r.recordedAt),
      tzOffsetMinutes: r.tzOffsetMinutes,
      localDate: LocalDate.parse(r.localDate),
      notes: r.notes,
      createdAt: _instant(r.createdAt),
      updatedAt: _instant(r.updatedAt),
    );
  }

  Stream<T> _watch<T>(Future<T> Function() load) => reactiveQuery(
    _db.tableUpdates(TableUpdateQuery.onAllTables([_db.measurements])),
    load,
  );

  @override
  Stream<List<Measurement>> watchForType(MeasurementType type) =>
      guardStorageStream(
        'watchMeasurements',
        _watch(() async {
          final rows =
              await (_db.select(_db.measurements)
                    ..where(
                      (m) =>
                          m.measurementType.equals(type.storageKey) &
                          isActive(m.deletedAt),
                    )
                    ..orderBy([
                      (m) => OrderingTerm.desc(m.localDate),
                      (m) => OrderingTerm.desc(m.recordedAt),
                    ]))
                  .get();
          return [...rows.map(_toDomain).nonNulls];
        }),
      );

  @override
  Stream<Map<MeasurementType, Measurement>> watchLatest() => guardStorageStream(
    'watchLatestMeasurements',
    _watch(() async {
      // One row per type: the newest (a handful of types, so a scan of the
      // index per type is cheap).
      final latest = <MeasurementType, Measurement>{};
      for (final type in MeasurementType.values) {
        final row =
            await (_db.select(_db.measurements)
                  ..where(
                    (m) =>
                        m.measurementType.equals(type.storageKey) &
                        isActive(m.deletedAt),
                  )
                  ..orderBy([
                    (m) => OrderingTerm.desc(m.localDate),
                    (m) => OrderingTerm.desc(m.recordedAt),
                  ])
                  ..limit(1))
                .getSingleOrNull();
        if (row != null) latest[type] = _toDomain(row)!;
      }
      return latest;
    }),
  );

  MeasurementsCompanion _columns(Measurement m) => MeasurementsCompanion(
    measurementType: Value(m.type.storageKey),
    value: Value(m.value),
    unitCode: Value(m.unitCode),
    normalizedValue: Value(m.normalizedValue),
    recordedAt: Value(m.recordedAt.millisecondsSinceEpoch),
    tzOffsetMinutes: Value(m.tzOffsetMinutes),
    localDate: Value(m.localDate.toIso()),
    notes: Value(m.notes),
    updatedAt: Value(m.updatedAt.millisecondsSinceEpoch),
  );

  @override
  Future<void> create(Measurement measurement) =>
      guardStorage('createMeasurement', () async {
        await _db
            .into(_db.measurements)
            .insert(
              _columns(measurement).copyWith(
                publicId: Value(measurement.id.value),
                createdAt: Value(measurement.createdAt.millisecondsSinceEpoch),
              ),
            );
      });

  @override
  Future<void> update(Measurement measurement) =>
      guardStorage('updateMeasurement', () async {
        final count =
            await (_db.update(_db.measurements)..where(
                  (m) =>
                      m.publicId.equals(measurement.id.value) &
                      isActive(m.deletedAt),
                ))
                .write(_columns(measurement));
        if (count == 0) {
          throw NotFoundException(
            debugContext: 'updateMeasurement ${measurement.id.value}',
          );
        }
      });

  @override
  Future<void> softDelete(MeasurementId id) => _setDeleted(id, deleted: true);

  @override
  Future<void> restore(MeasurementId id) => _setDeleted(id, deleted: false);

  Future<void> _setDeleted(MeasurementId id, {required bool deleted}) =>
      guardStorage(
        deleted ? 'deleteMeasurement' : 'restoreMeasurement',
        () async {
          final now = _clock.nowUtc().millisecondsSinceEpoch;
          final count =
              await (_db.update(
                _db.measurements,
              )..where((m) => m.publicId.equals(id.value))).write(
                MeasurementsCompanion(
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
