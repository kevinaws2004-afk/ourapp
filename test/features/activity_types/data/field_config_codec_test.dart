import 'package:daylog/features/activity_types/data/field_config_codec.dart';
import 'package:daylog/features/activity_types/domain/activity_ids.dart';
import 'package:daylog/features/activity_types/domain/field_config.dart';
import 'package:daylog/features/activity_types/domain/field_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final cases = <FieldType, FieldConfig>{
    FieldType.text: const TextFieldConfig(multiline: true),
    FieldType.number: const NumberFieldConfig(
      decimals: 2,
      min: 0,
      max: 500,
      defaultUnitCode: 'kg',
    ),
    FieldType.boolean: const BooleanFieldConfig(),
    FieldType.singleSelect: const SelectFieldConfig(
      options: [
        SelectOption(id: SelectOptionId('a'), label: 'Spanish'),
        SelectOption(id: SelectOptionId('b'), label: 'French', archived: true),
      ],
    ),
    FieldType.date: const DateFieldConfig(),
    FieldType.time: const TimeFieldConfig(),
    FieldType.duration: const DurationFieldConfig(),
    FieldType.rating: const RatingFieldConfig(max: 10),
  };

  for (final MapEntry(key: type, value: config) in cases.entries) {
    test('${type.name} config round-trips through JSON', () {
      expect(
        FieldConfigCodec.decode(type, FieldConfigCodec.encode(config)),
        config,
      );
    });
  }

  test('decoding tolerates missing and unknown keys', () {
    expect(
      FieldConfigCodec.decode(FieldType.rating, '{"future": 1}'),
      const RatingFieldConfig(),
    );
    expect(
      FieldConfigCodec.decode(FieldType.number, '{}'),
      const NumberFieldConfig(),
    );
    expect(
      FieldConfigCodec.decode(
        FieldType.singleSelect,
        '{"options": [{"label": "no id"}]}',
      ),
      const SelectFieldConfig(options: []),
    );
  });

  test('options are identified by stable IDs, not labels', () {
    final json = FieldConfigCodec.encode(cases[FieldType.singleSelect]!);
    expect(json, contains('"id":"a"'));
  });
}
