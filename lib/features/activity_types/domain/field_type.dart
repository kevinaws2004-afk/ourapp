/// The closed V1 field type catalog (OQ-01, data_architecture.md §4).
///
/// Domain-specific types (weight, distance, reps…) are compositions of these,
/// never new types.
enum FieldType {
  text('text'),
  number('number'),
  boolean('boolean'),
  singleSelect('single_select'),
  multiSelect('multi_select'),
  date('date'),
  time('time'),
  duration('duration'),
  rating('rating'),

  /// A list of items with typed sub-fields, stored relationally (ADR-027).
  repeatingGroup('repeating_group');

  const FieldType(this.storageKey);

  /// Value of `activity_fields.field_type`.
  final String storageKey;

  /// Types that can be created (all of them since Phase 3).
  bool get isAvailable => true;

  /// Types whose values can feed analytics (`measurable`).
  bool get canBeMeasurable =>
      this == number || this == rating || this == duration || this == boolean;

  /// Whether a new field of this type is measurable unless the user changes it.
  bool get measurableByDefault =>
      this == number || this == rating || this == duration;

  static FieldType fromStorageKey(String key) => values.firstWhere(
    (t) => t.storageKey == key,
    orElse: () => throw FormatException(key),
  );
}
