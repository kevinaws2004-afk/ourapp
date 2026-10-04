import '../../../core/errors/app_exception.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/local_date.dart';
import '../../../core/units/unit_registry.dart';
import 'measurement.dart';
import 'measurement_repository.dart';

// Body measurement use cases (ADR-023).

/// Pure validation: a finite, positive value in a unit of the type's
/// dimension; body fat at most 100 %. Targets: `value`, `unit`, `notes`.
ValidationResult validateMeasurement(MeasurementDraft draft) {
  final issues = <ValidationIssue>[];
  if (!draft.value.isFinite) {
    issues.add(
      const ValidationIssue(ValidationCode.notANumber, target: 'value'),
    );
  } else if (draft.value <= 0) {
    issues.add(
      const ValidationIssue(ValidationCode.belowMinimum, target: 'value'),
    );
  } else if (draft.type == MeasurementType.bodyFat && draft.value > 100) {
    issues.add(
      const ValidationIssue(ValidationCode.aboveMaximum, target: 'value'),
    );
  }
  if (!UnitRegistry.belongsTo(draft.unitCode, draft.type.dimension)) {
    issues.add(
      const ValidationIssue(ValidationCode.unitRequired, target: 'unit'),
    );
  }
  if ((draft.notes?.length ?? 0) > 10000) {
    issues.add(
      const ValidationIssue(ValidationCode.textTooLong, target: 'notes'),
    );
  }
  return ValidationResult(issues);
}

Measurement _build(
  MeasurementId id,
  MeasurementDraft draft,
  Clock clock, {
  DateTime? createdAt,
}) {
  final now = clock.nowUtc();
  final recordedAt = draft.recordedAt.toUtc();
  final offset = clock.offsetAt(recordedAt);
  final notes = draft.notes?.trim();
  return Measurement(
    id: id,
    type: draft.type,
    value: draft.value,
    unitCode: draft.unitCode,
    normalizedValue: UnitRegistry.byCode(draft.unitCode)!
        .toCanonical(draft.value),
    recordedAt: recordedAt,
    tzOffsetMinutes: offset.inMinutes,
    localDate: LocalDate.ofInstant(recordedAt, offset),
    notes: notes == null || notes.isEmpty ? null : notes,
    createdAt: createdAt ?? now,
    updatedAt: now,
  );
}

class RecordMeasurement {
  const RecordMeasurement(this._repository, this._ids, this._clock);

  final MeasurementRepository _repository;
  final IdGenerator _ids;
  final Clock _clock;

  Future<MeasurementId> call(MeasurementDraft draft) async {
    validateMeasurement(draft)
        .throwIfInvalid(debugContext: 'RecordMeasurement');
    final id = MeasurementId(_ids.newId());
    await _repository.create(_build(id, draft, _clock));
    return id;
  }
}

class UpdateMeasurement {
  const UpdateMeasurement(this._repository, this._clock);

  final MeasurementRepository _repository;
  final Clock _clock;

  Future<void> call(Measurement existing, MeasurementDraft draft) async {
    validateMeasurement(draft)
        .throwIfInvalid(debugContext: 'UpdateMeasurement');
    await _repository.update(
      _build(existing.id, draft, _clock, createdAt: existing.createdAt),
    );
  }
}

class DeleteMeasurement {
  const DeleteMeasurement(this._repository);

  final MeasurementRepository _repository;

  Future<void> call(MeasurementId id) => _repository.softDelete(id);
}

class RestoreMeasurement {
  const RestoreMeasurement(this._repository);

  final MeasurementRepository _repository;

  Future<void> call(MeasurementId id) => _repository.restore(id);
}
