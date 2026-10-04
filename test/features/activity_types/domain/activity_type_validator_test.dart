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
      colorKey: 'teal',
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

  group('repeating groups', () {
    const reps = FieldDefinition(
      name: 'Reps',
      type: FieldType.number,
      config: NumberFieldConfig(),
    );
    FieldDefinition group(
      String name, {
      String itemLabel = 'Item',
      List<FieldDefinition> subFields = const [reps],
    }) => FieldDefinition(
      name: name,
      type: FieldType.repeatingGroup,
      config: RepeatingGroupFieldConfig(itemLabel: itemLabel),
      subFields: subFields,
    );

    test('the gym template (a group inside a group) is valid', () {
      expect(codes(gymDefinition()), isEmpty);
    });

    test('a group needs at least one sub-field and an item name', () {
      expect(
        codes(withFields([group('Sets', subFields: const [])])),
        contains(ValidationCode.subFieldsRequired),
      );
      expect(
        codes(withFields([group('Sets', itemLabel: ' ')])),
        contains(ValidationCode.itemLabelRequired),
      );
    });

    test('groups nest at most two levels', () {
      final tooDeep = group(
        'A',
        subFields: [
          group('B', subFields: [group('C')]),
        ],
      );
      expect(
        codes(withFields([tooDeep])),
        contains(ValidationCode.nestingTooDeep),
      );
    });

    test('sub-field names are unique per group, not across groups', () {
      expect(codes(withFields([group('A'), group('B')])), isEmpty);
      expect(
        codes(
          withFields([
            group('A', subFields: const [reps, reps]),
          ]),
        ),
        contains(ValidationCode.duplicateFieldName),
      );
    });

    test('issues inside a group target the sub-field', () {
      final result = ActivityTypeValidator.validate(
        withFields([
          group(
            'A',
            subFields: const [
              FieldDefinition(
                name: '',
                type: FieldType.text,
                config: TextFieldConfig(),
              ),
            ],
          ),
        ]),
      );
      expect(result.issues.single.target, 'new:0.0');
    });

    test('only a group may have sub-fields', () {
      expect(
        codes(
          withFields([
            reps.copyWith(subFields: const [reps]),
          ]),
        ),
        contains(ValidationCode.valueTypeMismatch),
      );
    });
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
      colorKey: 'teal',
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
