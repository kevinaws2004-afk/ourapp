import '../../../core/time/local_date.dart';
import '../../../core/units/unit_registry.dart';

extension type const MeasurementId(String value) {}

/// The fixed V1 body measurement types (§23; OQ-09, recommendation followed:
/// custom types are deferred). Keys are permanent.
enum MeasurementType {
  weight('weight', Dimension.mass, 'kg'),
  height('height', Dimension.distance, 'cm'),
  bodyFat('body_fat', Dimension.percentage, 'percent'),
  chest('chest', Dimension.distance, 'cm'),
  waist('waist', Dimension.distance, 'cm'),
  arms('arms', Dimension.distance, 'cm'),
  legs('legs', Dimension.distance, 'cm');

  const MeasurementType(this.storageKey, this.dimension, this.defaultUnitCode);

  final String storageKey;
  final Dimension dimension;
  final String defaultUnitCode;

  static MeasurementType? fromStorageKey(String key) {
    for (final t in values) {
      if (t.storageKey == key) return t;
    }
    return null;
  }
}

/// A body measurement at a point in time (§3.4, §23).
class Measurement {
  const Measurement({
    required this.id,
    required this.type,
    required this.value,
    required this.unitCode,
    required this.normalizedValue,
    required this.recordedAt,
    required this.tzOffsetMinutes,
    required this.localDate,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  final MeasurementId id;
  final MeasurementType type;

  /// As entered, in [unitCode].
  final double value;
  final String unitCode;

  /// In the dimension's canonical unit, computed at write (ADR-020).
  final double normalizedValue;
  final DateTime recordedAt;
  final int tzOffsetMinutes;
  final LocalDate localDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class MeasurementDraft {
  const MeasurementDraft({
    required this.type,
    required this.value,
    required this.unitCode,
    required this.recordedAt,
    this.notes,
  });

  final MeasurementType type;
  final double value;
  final String unitCode;
  final DateTime recordedAt;
  final String? notes;
}
