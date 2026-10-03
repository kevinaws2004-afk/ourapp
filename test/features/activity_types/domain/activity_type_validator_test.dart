import 'package:daylog/core/errors/app_exception.dart';
import 'package:daylog/core/units/unit_registry.dart';
import 'package:daylog/features/activity_types/domain/activity_ids.dart';
import 'package:daylog/features/activity_types/domain/activity_type.dart';
import 'package:daylog/features/activity_types/domain/activity_type_definition.dart';
import 'package:daylog/features/activity_types/domain/activity_type_validator.dart';
import 'package:daylog/features/activity_types/domain/field_config.dart';
import 'package:daylog/features/activity_types/domain/field_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fixtures.dart';

ActivityTypeDefinition withFields(List<FieldDefinition> fields) =>
    ActivityTypeDefinition(
      name: 'Test',
      iconId: 'sparkle',
      colorKey: 'sage',
      fields: fields,
    );

List<ValidationCode> codes(
  ActivityTypeDefinition d, {
  ActivityType? existing,
  Set<ActivityFieldId> withValues = const {},
}) => ActivityTypeValidator.validate(
  d,
  existing: existing,
  fieldsWithValues: withValues,
).issues.map((i) => i.code).toList();

void main() {
  test('the reference templates are valid', () {
    expect(codes(readingDefinition()), isEmpty);
    expect(codes(languageDefinition()), isEmpty);
    expect(codes(walkingDefinition()), isEmpty);
  });

  test('an activity may have no fields (e.g. "Lunch")', () {
    expect(codes(withFields(const [])), isEmpty);
  });

  test('name, icon and color must be valid', () {
    const bad = ActivityTypeDefinition(
      name: '  ',
      iconId: 'nope',
      colorKey: 'purple',
      fields: [],
    );
    expect(
      codes(bad),
      containsAll([
        ValidationCode.nameRequired,
        ValidationCode.unknownIcon,
        ValidationCode.unknownColor,
      ]),
    );
  });

  test(
    'field names must be unique within a type, ignoring case and spaces',
    () {
      final d = withFields(const [
        FieldDefinition(
          name: 'Pages',
          type: FieldType.number,
          config: NumberFieldConfig(),
        ),
        FieldDefinition(
          name: ' pages ',
          type: FieldType.text,
          config: TextFieldConfig(),
        ),
      ]);
      expect(codes(d), [ValidationCode.duplicateFieldName]);
    },
  );

  test('repeating groups cannot be created before Phase 3', () {
    final d = withFields(const [
      FieldDefinition(
        name: 'Sets',
        type: FieldType.repeatingGroup,
        config: RepeatingGroupFieldConfig(),
      ),
    ]);
    expect(codes(d), contains(ValidationCode.fieldTypeNotSupportedYet));
  });

  group('number fields', () {
    test('a dimension requires a default unit of that dimension', () {
      final missing = withFields(const [
        FieldDefinition(
          name: 'Weight',
          type: FieldType.number,
          dimension: Dimension.mass,
          config: NumberFieldConfig(),
        ),
      ]);
      final wrong = withFields(const [
        FieldDefinition(
          name: 'Weight',
          type: FieldType.number,
          dimension: Dimension.mass,
          config: NumberFieldConfig(defaultUnitCode: 'km'),
        ),
      ]);
      expect(codes(missing), [ValidationCode.unitRequired]);
      expect(codes(wrong), [ValidationCode.unitRequired]);
    });

    test('min must not exceed max and decimals are bounded', () {
      final d = withFields(const [
        FieldDefinition(
          name: 'X',
          type: FieldType.number,
          config: NumberFieldConfig(decimals: 4, min: 5, max: 1),
        ),
      ]);
      expect(
        codes(d),
        containsAll([
          ValidationCode.tooManyDecimals,
          ValidationCode.invalidMinMax,
        ]),
      );
    });

    test('duration is not a valid Number dimension', () {
      final d = withFields(const [
        FieldDefinition(
          name: 'X',
          type: FieldType.number,
          dimension: Dimension.duration,
          config: NumberFieldConfig(defaultUnitCode: 'min'),
        ),
      ]);
      expect(codes(d), contains(ValidationCode.unitNotAllowed));
    });
  });

  test('select fields need at least one active, uniquely labelled option', () {
    final none = withFields(const [
      FieldDefinition(
        name: 'S',
        type: FieldType.singleSelect,
        config: SelectFieldConfig(options: []),
      ),
    ]);
    final dup = withFields(const [
      FieldDefinition(
        name: 'S',
        type: FieldType.multiSelect,
        config: SelectFieldConfig(
          options: [
            SelectOption(id: SelectOptionId('a'), label: 'Red'),
            SelectOption(id: SelectOptionId('b'), label: 'red'),
          ],
        ),
      ),
    ]);
    expect(codes(none), [ValidationCode.optionsRequired]);
    expect(codes(dup), [ValidationCode.duplicateOption]);
  });

  test('rating scale must be between 3 and 10', () {
    final d = withFields(const [
      FieldDefinition(
        name: 'R',
        type: FieldType.rating,
        config: RatingFieldConfig(max: 12),
      ),
    ]);
    expect(codes(d), [ValidationCode.invalidRatingScale]);
  });

  test('a field with values cannot change type or dimension', () {
    const fieldId = ActivityFieldId('f1');
    final existing = ActivityType(
      id: const ActivityTypeId('t1'),
      name: 'Test',
      iconId: 'sparkle',
      colorKey: 'sage',
      supportsTimer: false,
      supportsPlanning: true,
      sortOrder: 0,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      fields: const [
        ActivityField(
          id: fieldId,
          name: 'Pages',
          type: FieldType.number,
          position: 0,
          required: false,
          measurable: true,
          config: NumberFieldConfig(),
        ),
      ],
    );
    final changed = withFields(const [
      FieldDefinition(
        id: fieldId,
        name: 'Pages',
        type: FieldType.text,
        config: TextFieldConfig(),
      ),
    ]);
    expect(codes(changed, existing: existing, withValues: {fieldId}), [
      ValidationCode.fieldSemanticsLocked,
    ]);
    expect(
      codes(changed, existing: existing),
      isEmpty,
      reason: 'allowed before any value exists',
    );
  });
}
