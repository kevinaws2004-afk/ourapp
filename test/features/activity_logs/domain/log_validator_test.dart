import 'package:daylog/core/errors/app_exception.dart';
import 'package:daylog/core/time/local_date.dart';
import 'package:daylog/core/units/unit_registry.dart';
import 'package:daylog/features/activity_logs/domain/activity_log.dart';
import 'package:daylog/features/activity_logs/domain/field_value.dart';
import 'package:daylog/features/activity_logs/domain/log_validator.dart';
import 'package:daylog/features/activity_types/domain/activity_ids.dart';
import 'package:daylog/features/activity_types/domain/activity_type.dart';
import 'package:daylog/features/activity_types/domain/field_config.dart';
import 'package:daylog/features/activity_types/domain/field_type.dart';
import 'package:flutter_test/flutter_test.dart';

ActivityField field(
  String id,
  FieldType type, {
  FieldConfig? config,
  Dimension? dimension,
  bool required = false,
  bool removed = false,
}) => ActivityField(
  id: ActivityFieldId(id),
  name: id,
  type: type,
  dimension: dimension,
  position: 0,
  required: required,
  measurable: false,
  config: config ?? FieldConfig.defaultFor(type),
  isRemoved: removed,
);

ActivityType typeWith(List<ActivityField> fields) => ActivityType(
  id: const ActivityTypeId('t'),
  name: 'T',
  iconId: 'sparkle',
  colorKey: 'teal',
  supportsTimer: false,
  supportsPlanning: true,
  sortOrder: 0,
  fields: fields,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

List<ValidationCode> issuesFor(
  ActivityField f,
  FieldValue value, {
  FieldValue? previous,
}) => LogValidator.validateValue(
  f,
  value,
  previous: previous,
).map((i) => i.code).toList();

const options = SelectFieldConfig(
  options: [
    SelectOption(id: SelectOptionId('a'), label: 'A'),
    SelectOption(id: SelectOptionId('old'), label: 'Old', archived: true),
  ],
);

void main() {
  test('every valid value of every Phase 2 type passes', () {
    final cases = <ActivityField, FieldValue>{
      field('text', FieldType.text): const TextValue('Fooled by Randomness'),
      field('n', FieldType.number): const NumberValue(18),
      field('b', FieldType.boolean): const BooleanValue(true),
      field('s', FieldType.singleSelect, config: options):
          const SingleSelectValue(SelectOptionId('a')),
      field('m', FieldType.multiSelect, config: options):
          const MultiSelectValue([SelectOptionId('a')]),
      field('d', FieldType.date): DateValue(LocalDate(2026, 10, 4)),
      field('t', FieldType.time): TimeValue(LocalTime.hm(21, 10)),
      field('du', FieldType.duration): const DurationValue(2700000),
      field('r', FieldType.rating): const RatingValue(4),
    };
    for (final MapEntry(key: f, :value) in cases.entries) {
      expect(issuesFor(f, value), isEmpty, reason: f.type.name);
    }
  });

  test('a value of the wrong type is rejected', () {
    expect(issuesFor(field('n', FieldType.number), const TextValue('12')), [
      ValidationCode.valueTypeMismatch,
    ]);
  });

  group('numbers', () {
    test('respect min, max and decimals', () {
      final f = field(
        'n',
        FieldType.number,
        config: const NumberFieldConfig(decimals: 1, min: 0, max: 10),
      );
      expect(issuesFor(f, const NumberValue(-1)), [
        ValidationCode.belowMinimum,
      ]);
      expect(issuesFor(f, const NumberValue(11)), [
        ValidationCode.aboveMaximum,
      ]);
      expect(issuesFor(f, const NumberValue(2.25)), [
        ValidationCode.tooManyDecimals,
      ]);
      expect(issuesFor(f, const NumberValue(2.5)), isEmpty);
    });

    test('a dimensioned field needs a unit of its dimension; a unitless field forbids units', () {
      final distance = field(
        'd',
        FieldType.number,
        dimension: Dimension.distance,
        config: const NumberFieldConfig(decimals: 2, defaultUnitCode: 'km'),
      );
      expect(issuesFor(distance, const NumberValue(5)), [
        ValidationCode.unitRequired,
      ]);
      expect(issuesFor(distance, const NumberValue(5, unitCode: 'kg')), [
        ValidationCode.unitRequired,
      ]);
      expect(
        issuesFor(distance, const NumberValue(5, unitCode: 'mi')),
        isEmpty,
      );
      expect(
        issuesFor(
          field('c', FieldType.number),
          const NumberValue(5, unitCode: 'km'),
        ),
        [ValidationCode.unitNotAllowed],
      );
    });

    test('normalize to the canonical unit (ADR-020)', () {
      expect(const NumberValue(5, unitCode: 'km').normalized, 5000);
      expect(const NumberValue(12).normalized, 12);
    });
  });

  test('archived options are only accepted when already stored', () {
    final f = field('s', FieldType.singleSelect, config: options);
    const old = SingleSelectValue(SelectOptionId('old'));
    expect(issuesFor(f, old), [ValidationCode.archivedOption]);
    expect(issuesFor(f, old, previous: old), isEmpty);
    expect(issuesFor(f, const SingleSelectValue(SelectOptionId('zzz'))), [
      ValidationCode.unknownOption,
    ]);
  });

  test('multi select rejects empty selections and duplicates', () {
    final f = field('m', FieldType.multiSelect, config: options);
    expect(issuesFor(f, const MultiSelectValue([])), [ValidationCode.required]);
    expect(
      issuesFor(
        f,
        const MultiSelectValue([SelectOptionId('a'), SelectOptionId('a')]),
      ),
      [ValidationCode.duplicateOption],
    );
  });

  test('rating must be within its scale', () {
    final f = field(
      'r',
      FieldType.rating,
      config: const RatingFieldConfig(max: 5),
    );
    expect(issuesFor(f, const RatingValue(0)), [
      ValidationCode.ratingOutOfRange,
    ]);
    expect(issuesFor(f, const RatingValue(6)), [
      ValidationCode.ratingOutOfRange,
    ]);
  });

  test('blank text counts as missing; negative durations are invalid', () {
    expect(issuesFor(field('t', FieldType.text), const TextValue('  ')), [
      ValidationCode.required,
    ]);
    expect(issuesFor(field('d', FieldType.duration), const DurationValue(-1)), [
      ValidationCode.negativeDuration,
    ]);
  });

  group('whole drafts', () {
    final book = field('book', FieldType.text, required: true);
    final gone = field('gone', FieldType.number, removed: true);
    final type = typeWith([book, gone]);
    final start = DateTime.utc(2026, 10, 4, 21, 10);

    test('required fields must be present', () {
      final result = LogValidator.validate(
        type,
        ActivityLogDraft(startedAt: start, values: const {}),
      );
      expect(result.issuesFor('book').single.code, ValidationCode.required);
    });

    test('values for removed fields are rejected unless unchanged history', () {
      final draft = ActivityLogDraft(
        startedAt: start,
        values: {
          book.id: const TextValue('Book'),
          gone.id: const NumberValue(3),
        },
      );
      expect(
        LogValidator.validate(type, draft).issuesFor('gone').single.code,
        ValidationCode.unknownField,
      );
      expect(
        LogValidator.validate(
          type,
          draft,
          existing: {gone.id: const NumberValue(3)},
        ).isValid,
        isTrue,
      );
    });

    test('the built-in duration cannot be negative', () {
      final draft = ActivityLogDraft(
        startedAt: start,
        durationMs: -5,
        values: {book.id: const TextValue('B')},
      );
      expect(
        LogValidator.validate(type, draft).issuesFor('duration').single.code,
        ValidationCode.negativeDuration,
      );
    });
  });

  group('repeating groups', () {
    const sets = ActivityFieldId('sets');
    const reps = ActivityFieldId('reps');
    const top = ActivityFieldId('note');
    final type = typeWith([
      field('sets', FieldType.repeatingGroup, required: true),
      const ActivityField(
        id: reps,
        parentId: sets,
        name: 'reps',
        type: FieldType.number,
        position: 0,
        required: true,
        measurable: true,
        config: NumberFieldConfig(min: 0),
      ),
      field('note', FieldType.text),
    ]);
    ActivityLogDraft draft(Map<ActivityFieldId, FieldValue> values) =>
        ActivityLogDraft(startedAt: DateTime.utc(2026), values: values);
    List<(ValidationCode, String?)> issues(
      Map<ActivityFieldId, FieldValue> values,
    ) => [
      for (final i in LogValidator.validate(type, draft(values)).issues)
        (i.code, i.target),
    ];
    const item = GroupItemId('i1');

    test('a required group needs at least one item', () {
      expect(issues({}), [(ValidationCode.required, 'sets')]);
    });

    test('sub-field issues target the item', () {
      expect(
        issues({
          sets: const RepeatingGroupValue([
            GroupItem(id: item, values: {reps: NumberValue(-1)}),
          ]),
        }),
        [(ValidationCode.belowMinimum, LogValidator.itemTarget(item, reps))],
      );
      expect(
        issues({
          sets: const RepeatingGroupValue([GroupItem(id: item, values: {})]),
        }),
        [(ValidationCode.required, LogValidator.itemTarget(item, reps))],
      );
    });

    test('a value must be in its own scope', () {
      expect(
        issues({
          sets: const RepeatingGroupValue([]),
          reps: const NumberValue(3),
        }),
        contains((ValidationCode.unknownField, 'reps')),
      );
      expect(
        issues({
          sets: const RepeatingGroupValue([
            GroupItem(
              id: item,
              values: {reps: NumberValue(3), top: TextValue('x')},
            ),
          ]),
        }),
        [(ValidationCode.unknownField, LogValidator.itemTarget(item, top))],
      );
    });

    test('item IDs are unique within a group', () {
      expect(
        issues({
          sets: const RepeatingGroupValue([
            GroupItem(id: item, values: {reps: NumberValue(3)}),
            GroupItem(id: item, values: {reps: NumberValue(4)}),
          ]),
        }),
        [(ValidationCode.valueTypeMismatch, 'sets')],
      );
    });
  });
}
