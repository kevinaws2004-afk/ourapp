import '../../../core/errors/app_exception.dart';
import '../../../core/time/local_date.dart';
import '../../../core/units/unit_registry.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../activity_types/domain/field_config.dart';
import '../../activity_types/domain/field_type.dart';
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
    if (draft.endedAt case final ended?) {
      if (ended.isBefore(draft.startedAt)) {
        issues.add(
          const ValidationIssue(ValidationCode.endBeforeStart, target: 'start'),
        );
      } else if (duration != null &&
          duration > ended.difference(draft.startedAt).inMilliseconds) {
        issues.add(
          const ValidationIssue(
            ValidationCode.durationExceedsElapsed,
            target: 'duration',
          ),
        );
      }
    }
    if ((draft.notes?.length ?? 0) > ActivityLogDraft.maxNotesLength) {
      issues.add(
        const ValidationIssue(ValidationCode.textTooLong, target: 'notes'),
      );
    }

    _validateScope(
      type,
      fields: type.activeFields,
      parentId: null,
      values: draft.values,
      existing: existing,
      targetPrefix: '',
      issues: issues,
    );
    return ValidationResult(issues);
  }

  /// Issue target for a value inside a Repeating Group item.
  static String itemTarget(GroupItemId itemId, ActivityFieldId fieldId) =>
      '${itemId.value}/${fieldId.value}';

  /// Validates the values of one scope: the top level, or one group item
  /// (whose allowed fields are the group's sub-fields).
  static void _validateScope(
    ActivityType type, {
    required List<ActivityField> fields,
    required ActivityFieldId? parentId,
    required Map<ActivityFieldId, FieldValue> values,
    required Map<ActivityFieldId, FieldValue> existing,
    required String targetPrefix,
    required List<ValidationIssue> issues,
  }) {
    String target(ActivityFieldId id) => '$targetPrefix${id.value}';
    for (final field in fields) {
      if (field.required && !values.containsKey(field.id)) {
        issues.add(
          ValidationIssue(ValidationCode.required, target: target(field.id)),
        );
      }
    }
    for (final MapEntry(key: fieldId, :value) in values.entries) {
      final field = type.fieldById(fieldId);
      final previous = existing[fieldId];
      final inScope = field != null && field.parentId == parentId;
      final unchangedHistorical =
          inScope && field.isRemoved && previous == value;
      if (!inScope || (field.isRemoved && !unchangedHistorical)) {
        issues.add(
          ValidationIssue(ValidationCode.unknownField, target: target(fieldId)),
        );
        continue;
      }
      if (unchangedHistorical) continue;
      if (value is RepeatingGroupValue &&
          field.type == FieldType.repeatingGroup) {
        _validateGroup(type, field, value, previous, targetPrefix, issues);
      } else {
        for (final issue in validateValue(field, value, previous: previous)) {
          issues.add(ValidationIssue(issue.code, target: target(fieldId)));
        }
      }
    }
  }

  static void _validateGroup(
    ActivityType type,
    ActivityField group,
    RepeatingGroupValue value,
    FieldValue? previous,
    String targetPrefix,
    List<ValidationIssue> issues,
  ) {
    final previousItems = {
      if (previous is RepeatingGroupValue)
        for (final item in previous.items) item.id: item,
    };
    final seen = <GroupItemId>{};
    for (final item in value.items) {
      if (!seen.add(item.id)) {
        issues.add(
          ValidationIssue(
            ValidationCode.valueTypeMismatch,
            target: '$targetPrefix${group.id.value}',
          ),
        );
      }
      _validateScope(
        type,
        fields: type.subFieldsOf(group.id),
        parentId: group.id,
        values: item.values,
        existing: previousItems[item.id]?.values ?? const {},
        targetPrefix: '${item.id.value}/',
        issues: issues,
      );
    }
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
      case (RepeatingGroupValue(), _):
        // Validated item by item in [_validateGroup] (needs the activity type).
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
