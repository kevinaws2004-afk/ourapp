import '../../../core/design/keys/activity_color_key.dart';
import '../../../core/design/keys/activity_icon_ids.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/units/unit_registry.dart';
import 'activity_ids.dart';
import 'activity_type.dart';
import 'activity_type_definition.dart';
import 'field_config.dart';

/// Pure validation of an activity type definition (data_architecture.md §3.2).
///
/// Issue targets: `name`, `icon`, `color`, or a field key from [fieldKey].
abstract final class ActivityTypeValidator {
  /// Stable key for a field's issues: its ID, or `new:<index>` before it has one.
  static String fieldKey(FieldDefinition field, int index) =>
      field.id?.value ?? 'new:$index';

  /// Validates [definition]. When updating, pass the [existing] type and the
  /// IDs of fields that already have values, to enforce locked semantics.
  static ValidationResult validate(
    ActivityTypeDefinition definition, {
    ActivityType? existing,
    Set<ActivityFieldId> fieldsWithValues = const {},
  }) {
    final issues = <ValidationIssue>[];
    final name = definition.name.trim();
    if (name.isEmpty) {
      issues.add(
        const ValidationIssue(ValidationCode.nameRequired, target: 'name'),
      );
    } else if (name.length > ActivityTypeDefinition.maxNameLength) {
      issues.add(
        const ValidationIssue(ValidationCode.nameTooLong, target: 'name'),
      );
    }
    if (!ActivityIconIds.isKnown(definition.iconId)) {
      issues.add(
        const ValidationIssue(ValidationCode.unknownIcon, target: 'icon'),
      );
    }
    if (ActivityColorKey.fromName(definition.colorKey) == null) {
      issues.add(
        const ValidationIssue(ValidationCode.unknownColor, target: 'color'),
      );
    }

    final seenNames = <String>{};
    for (final (index, field) in definition.fields.indexed) {
      final key = fieldKey(field, index);
      issues.addAll(_validateField(field, key));
      final normalized = field.name.trim().toLowerCase();
      if (normalized.isNotEmpty && !seenNames.add(normalized)) {
        issues.add(
          ValidationIssue(ValidationCode.duplicateFieldName, target: key),
        );
      }
      final previous = field.id == null ? null : existing?.fieldById(field.id!);
      if (previous != null &&
          fieldsWithValues.contains(previous.id) &&
          (previous.type != field.type ||
              previous.dimension != field.dimension)) {
        issues.add(
          ValidationIssue(ValidationCode.fieldSemanticsLocked, target: key),
        );
      }
    }
    return ValidationResult(issues);
  }

  static List<ValidationIssue> _validateField(
    FieldDefinition field,
    String key,
  ) {
    final issues = <ValidationIssue>[];
    void add(ValidationCode code) =>
        issues.add(ValidationIssue(code, target: key));

    final name = field.name.trim();
    if (name.isEmpty) add(ValidationCode.nameRequired);
    if (name.length > FieldDefinition.maxNameLength) {
      add(ValidationCode.nameTooLong);
    }
    if (!field.type.isAvailable) add(ValidationCode.fieldTypeNotSupportedYet);
    if (field.measurable && !field.type.canBeMeasurable) {
      add(ValidationCode.unitNotAllowed);
    }
    if (!field.config.matches(field.type)) {
      add(ValidationCode.fieldTypeNotSupportedYet);
    }

    final dimension = field.dimension;
    if (dimension != null && !Dimension.numberDimensions.contains(dimension)) {
      add(ValidationCode.unitNotAllowed);
    }
    switch (field.config) {
      case NumberFieldConfig(
        :final decimals,
        :final min,
        :final max,
        :final defaultUnitCode,
      ):
        if (decimals < 0 || decimals > NumberFieldConfig.maxDecimals) {
          add(ValidationCode.tooManyDecimals);
        }
        if (min != null && max != null && min > max) {
          add(ValidationCode.invalidMinMax);
        }
        if (dimension == null && defaultUnitCode != null) {
          add(ValidationCode.unitNotAllowed);
        }
        if (dimension != null &&
            (defaultUnitCode == null ||
                !UnitRegistry.belongsTo(defaultUnitCode, dimension))) {
          add(ValidationCode.unitRequired);
        }
      case SelectFieldConfig(:final options):
        if (options.where((o) => !o.archived).isEmpty) {
          add(ValidationCode.optionsRequired);
        }
        final labels = <String>{};
        final ids = <SelectOptionId>{};
        for (final option in options) {
          if (option.label.trim().isEmpty) {
            add(ValidationCode.optionLabelRequired);
          }
          if (!ids.add(option.id)) add(ValidationCode.duplicateOption);
          if (!option.archived &&
              !labels.add(option.label.trim().toLowerCase())) {
            add(ValidationCode.duplicateOption);
          }
        }
      case RatingFieldConfig(:final max):
        if (max < RatingFieldConfig.minScale ||
            max > RatingFieldConfig.maxScale) {
          add(ValidationCode.invalidRatingScale);
        }
      case TextFieldConfig() ||
          BooleanFieldConfig() ||
          DateFieldConfig() ||
          TimeFieldConfig() ||
          DurationFieldConfig() ||
          RepeatingGroupFieldConfig():
        break;
    }
    return issues;
  }
}
