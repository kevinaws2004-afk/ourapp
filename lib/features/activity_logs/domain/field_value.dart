import '../../../core/time/local_date.dart';
import '../../../core/units/unit_registry.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/domain/field_type.dart';

/// A typed value for one field (data_architecture.md §4, ADR-019). Each
/// variant maps to exactly one storage column.
sealed class FieldValue {
  const FieldValue();

  /// The field type this value belongs to.
  FieldType get fieldType;
}

final class TextValue extends FieldValue {
  const TextValue(this.text);

  final String text;

  @override
  FieldType get fieldType => FieldType.text;

  @override
  bool operator ==(Object other) => other is TextValue && other.text == text;

  @override
  int get hashCode => text.hashCode;
}

/// A number as entered, in [unitCode] when the field has a dimension.
final class NumberValue extends FieldValue {
  const NumberValue(this.value, {this.unitCode});

  final double value;
  final String? unitCode;

  /// The value in the dimension's canonical unit (ADR-020), computed at write
  /// time. Equals [value] when unitless.
  double get normalized {
    final unit = unitCode == null ? null : UnitRegistry.byCode(unitCode!);
    return unit == null ? value : unit.toCanonical(value);
  }

  @override
  FieldType get fieldType => FieldType.number;

  @override
  bool operator ==(Object other) =>
      other is NumberValue &&
      other.value == value &&
      other.unitCode == unitCode;

  @override
  int get hashCode => Object.hash(value, unitCode);
}

final class BooleanValue extends FieldValue {
  const BooleanValue(this.value);

  final bool value;

  @override
  FieldType get fieldType => FieldType.boolean;

  @override
  bool operator ==(Object other) =>
      other is BooleanValue && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

final class SingleSelectValue extends FieldValue {
  const SingleSelectValue(this.optionId);

  final SelectOptionId optionId;

  @override
  FieldType get fieldType => FieldType.singleSelect;

  @override
  bool operator ==(Object other) =>
      other is SingleSelectValue && other.optionId == optionId;

  @override
  int get hashCode => optionId.hashCode;
}

final class MultiSelectValue extends FieldValue {
  const MultiSelectValue(this.optionIds);

  /// Selection order; never empty when stored (empty = no value).
  final List<SelectOptionId> optionIds;

  @override
  FieldType get fieldType => FieldType.multiSelect;

  @override
  bool operator ==(Object other) =>
      other is MultiSelectValue &&
      other.optionIds.length == optionIds.length &&
      Iterable<int>.generate(optionIds.length)
          .every((i) => other.optionIds[i] == optionIds[i]);

  @override
  int get hashCode => Object.hashAll(optionIds);
}

final class DateValue extends FieldValue {
  const DateValue(this.date);

  final LocalDate date;

  @override
  FieldType get fieldType => FieldType.date;

  @override
  bool operator ==(Object other) => other is DateValue && other.date == date;

  @override
  int get hashCode => date.hashCode;
}

final class TimeValue extends FieldValue {
  const TimeValue(this.time);

  final LocalTime time;

  @override
  FieldType get fieldType => FieldType.time;

  @override
  bool operator ==(Object other) => other is TimeValue && other.time == time;

  @override
  int get hashCode => time.hashCode;
}

/// An additional user-defined duration. The activity's own elapsed time is
/// the log's `durationMs`, never a field (ADR-021).
final class DurationValue extends FieldValue {
  const DurationValue(this.milliseconds);

  final int milliseconds;

  @override
  FieldType get fieldType => FieldType.duration;

  @override
  bool operator ==(Object other) =>
      other is DurationValue && other.milliseconds == milliseconds;

  @override
  int get hashCode => milliseconds.hashCode;
}

final class RatingValue extends FieldValue {
  const RatingValue(this.stars);

  final int stars;

  @override
  FieldType get fieldType => FieldType.rating;

  @override
  bool operator ==(Object other) =>
      other is RatingValue && other.stars == stars;

  @override
  int get hashCode => stars.hashCode;
}
