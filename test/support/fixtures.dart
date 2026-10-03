import 'package:daylog/core/ids/id_generator.dart';
import 'package:daylog/core/units/unit_registry.dart';
import 'package:daylog/features/activity_types/domain/activity_ids.dart';
import 'package:daylog/features/activity_types/domain/activity_type_definition.dart';
import 'package:daylog/features/activity_types/domain/field_config.dart';
import 'package:daylog/features/activity_types/domain/field_type.dart';

/// Deterministic, sortable IDs for tests (UUIDv7-shaped).
class SequentialIdGenerator implements IdGenerator {
  int _next = 1;

  @override
  String newId() =>
      '00000000-0000-7000-8000-${(_next++).toString().padLeft(12, '0')}';
}

/// Reading (§14): Book, Pages, Rating; duration and notes are built in.
ActivityTypeDefinition readingDefinition() => const ActivityTypeDefinition(
  name: 'Reading',
  iconId: 'book-open',
  colorKey: 'sky',
  supportsTimer: true,
  fields: [
    FieldDefinition(
      name: 'Book',
      type: FieldType.text,
      config: TextFieldConfig(),
      required: true,
    ),
    FieldDefinition(
      name: 'Pages',
      type: FieldType.number,
      config: NumberFieldConfig(),
      measurable: true,
    ),
    FieldDefinition(
      name: 'Rating',
      type: FieldType.rating,
      config: RatingFieldConfig(),
      measurable: true,
    ),
  ],
);

/// Language Learning (§31), exercising select and every scalar storage path.
ActivityTypeDefinition languageDefinition() => const ActivityTypeDefinition(
  name: 'Language Learning',
  iconId: 'translate',
  colorKey: 'lilac',
  fields: [
    FieldDefinition(
      name: 'Language',
      type: FieldType.singleSelect,
      config: SelectFieldConfig(
        options: [
          SelectOption(id: SelectOptionId('opt-es'), label: 'Spanish'),
          SelectOption(id: SelectOptionId('opt-fr'), label: 'French'),
        ],
      ),
    ),
    FieldDefinition(
      name: 'Topics',
      type: FieldType.multiSelect,
      config: SelectFieldConfig(
        options: [
          SelectOption(id: SelectOptionId('opt-verbs'), label: 'Verbs'),
          SelectOption(id: SelectOptionId('opt-food'), label: 'Food'),
        ],
      ),
    ),
    FieldDefinition(
      name: 'Words learned',
      type: FieldType.number,
      config: NumberFieldConfig(),
    ),
    FieldDefinition(
      name: 'Lesson',
      type: FieldType.text,
      config: TextFieldConfig(),
    ),
    FieldDefinition(
      name: 'Difficulty',
      type: FieldType.rating,
      config: RatingFieldConfig(),
    ),
    FieldDefinition(
      name: 'Homework done',
      type: FieldType.boolean,
      config: BooleanFieldConfig(),
    ),
    FieldDefinition(
      name: 'Class date',
      type: FieldType.date,
      config: DateFieldConfig(),
    ),
    FieldDefinition(
      name: 'Class time',
      type: FieldType.time,
      config: TimeFieldConfig(),
    ),
    FieldDefinition(
      name: 'Speaking time',
      type: FieldType.duration,
      config: DurationFieldConfig(),
    ),
  ],
);

/// Walking with a dimensioned number (distance in km, ADR-020).
ActivityTypeDefinition walkingDefinition() => const ActivityTypeDefinition(
  name: 'Walking',
  iconId: 'person-simple-walk',
  colorKey: 'sage',
  fields: [
    FieldDefinition(
      name: 'Distance',
      type: FieldType.number,
      dimension: Dimension.distance,
      config: NumberFieldConfig(decimals: 2, defaultUnitCode: 'km'),
      measurable: true,
    ),
  ],
);
