import '../../../core/errors/app_exception.dart';
import '../../../core/time/local_date.dart';
import '../../../core/units/unit_registry.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../activity_types/domain/field_config.dart';
import 'activity_log.dart';
import 'field_value.dart';

/// Pure validation of a log draft against its activity type
/// (data_architecture.md §4). Issue targets are field public IDs, or
/// `duration` / `notes` for built-in properties.
abstract final class LogValidator {
  static const maxTextLength = 10000;

  /// [existing] values may keep referencing removed fields when editing.
  static ValidationResult validate(
    ActivityType type,
    ActivityLogDraft draft, {
    Map<ActivityFieldId, FieldValue> existing = const {},
  }) {
    final issues = <ValidationIssue>[];
    final duration = draft.durationMs;
    if (duration != null && duration < 0) {
      issues.add(
        const ValidationIssue(
          ValidationCode.negativeDuration,
          target: 'duration',
        ),
      );
    }
    if ((draft.notes?.length ?? 0) > ActivityLogDraft.maxNotesLength) {
      issues.add(
        const ValidationIssue(ValidationCode.textTooLong, target: 'notes'),
      );
    }

    for (final field in type.activeFields) {
      if (field.required && !draft.values.containsKey(field.id)) {
        issues.add(
          ValidationIssue(ValidationCode.required, target: field.id.value),
        );
      }
    }
    for (final MapEntry(key: fieldId, :value) in draft.values.entries) {
      final field = type.fieldById(fieldId);
      final unchangedHistorical =
          field != null && field.isRemoved && existing[fieldId] == value;
      if (field == null || (field.isRemoved && !unchangedHistorical)) {
        issues.add(
          ValidationIssue(ValidationCode.unknownField, target: fieldId.value),
        );
        continue;
      }
      if (unchangedHistorical) continue;
      issues.addAll(validateValue(field, value, previous: existing[fieldId]));
    }
    return ValidationResult(issues);
  }

  /// Validates one value. An archived option is accepted only if it was
  /// already stored ([previous]), so editing a historical log stays possible.
  static List<ValidationIssue> validateValue(
    ActivityField field,
    FieldValue value, {
    FieldValue? previous,
  }) {
    final target = field.id.value;
    final issues = <ValidationIssue>[];
    void add(ValidationCode code) =>
        issues.add(ValidationIssue(code, target: target));

    if (value.fieldType != field.type) {
      add(ValidationCode.valueTypeMismatch);
      return issues;
    }
    switch ((value, field.config)) {
      case (TextValue(:final text), _):
        if (text.trim().isEmpty) add(ValidationCode.required);
        if (text.length > maxTextLength) add(ValidationCode.textTooLong);
      case (
        NumberValue(:final value, :final unitCode),
        final NumberFieldConfig config,
      ):
        if (!value.isFinite) add(ValidationCode.notANumber);
        if (config.min != null && value < config.min!) {
          add(ValidationCode.belowMinimum);
        }
        if (config.max != null && value > config.max!) {
          add(ValidationCode.aboveMaximum);
        }
        if (_decimalPlaces(value) > config.decimals) {
          add(ValidationCode.tooManyDecimals);
        }
        final dimension = field.dimension;
        if (dimension == null && unitCode != null) {
          add(ValidationCode.unitNotAllowed);
        }
        if (dimension != null &&
            (unitCode == null ||
                !UnitRegistry.belongsTo(unitCode, dimension))) {
          add(ValidationCode.unitRequired);
        }
      case (SingleSelectValue(:final optionId), final SelectFieldConfig config):
        _checkOption(config, optionId, previous, add);
      case (MultiSelectValue(:final optionIds), final SelectFieldConfig config):
        if (optionIds.isEmpty) add(ValidationCode.required);
        if (optionIds.toSet().length != optionIds.length) {
          add(ValidationCode.duplicateOption);
        }
        for (final id in optionIds) {
          _checkOption(config, id, previous, add);
        }
      case (TimeValue(:final time), _):
        if (!LocalTime.isValidMinute(time.minuteOfDay)) {
          add(ValidationCode.invalidTime);
        }
      case (DurationValue(:final milliseconds), _):
        if (milliseconds < 0) add(ValidationCode.negativeDuration);
      case (RatingValue(:final stars), final RatingFieldConfig config):
        if (stars < 1 || stars > config.max) {
          add(ValidationCode.ratingOutOfRange);
        }
      case (BooleanValue() || DateValue(), _):
        break;
      default:
        add(ValidationCode.valueTypeMismatch);
    }
    return issues;
  }

  static void _checkOption(
    SelectFieldConfig config,
    SelectOptionId id,
    FieldValue? previous,
    void Function(ValidationCode) add,
  ) {
    final option = config.optionById(id);
    if (option == null) {
      add(ValidationCode.unknownOption);
    } else if (option.archived && !_previouslyHad(previous, id)) {
      add(ValidationCode.archivedOption);
    }
  }

  static bool _previouslyHad(FieldValue? previous, SelectOptionId id) =>
      switch (previous) {
        SingleSelectValue(:final optionId) => optionId == id,
        MultiSelectValue(:final optionIds) => optionIds.contains(id),
        _ => false,
      };

  static int _decimalPlaces(double value) {
    for (var places = 0; places <= 10; places++) {
      final scaled = value * _pow10(places);
      if ((scaled - scaled.roundToDouble()).abs() < 1e-6) return places;
    }
    return 11;
  }

  static double _pow10(int n) {
    var result = 1.0;
    for (var i = 0; i < n; i++) {
      result *= 10;
    }
    return result;
  }
}
