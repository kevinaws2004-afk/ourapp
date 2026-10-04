import 'measurement.dart';

/// Persistence for body measurements. Default reads exclude deleted ones
/// (ADR-022). Throws only `AppException`s.
abstract interface class MeasurementRepository {
  /// A type's history, newest first (`idx_measurements_type_day`).
  Stream<List<Measurement>> watchForType(MeasurementType type);

  /// The newest measurement of each type that has one.
  Stream<Map<MeasurementType, Measurement>> watchLatest();

  Future<void> create(Measurement measurement);

  Future<void> update(Measurement measurement);

  Future<void> softDelete(MeasurementId id);

  Future<void> restore(MeasurementId id);
}
