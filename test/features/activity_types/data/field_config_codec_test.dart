import 'package:daylog/features/activity_types/data/field_config_codec.dart';
import 'package:daylog/features/activity_types/domain/activity_ids.dart';
import 'package:daylog/features/activity_types/domain/field_config.dart';
import 'package:daylog/features/activity_types/domain/field_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final cases = <FieldType, FieldConfig>{
    FieldType.text: const TextFieldConfig(
      multiline: true,
      suggestFromHistory: true,
    ),
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
    FieldType.repeatingGroup: const RepeatingGroupFieldConfig(itemLabel: 'Set'),
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

  test('a number keeps how Insights sums it up and which way is better, '
      'and older configs read as total / higher (ADR-043)', () {
    const config = NumberFieldConfig(
      summary: NumberSummary.average,
      better: BetterDirection.lower,
    );
    final json = FieldConfigCodec.encode(config);
    expect(FieldConfigCodec.decode(FieldType.number, json), config);
    expect(
      FieldConfigCodec.encode(const NumberFieldConfig()),
      isNot(contains('summary')),
    );
    final old = FieldConfigCodec.decode(FieldType.number, '{"decimals": 1}');
    expect(old, isA<NumberFieldConfig>());
    old as NumberFieldConfig;
    expect(old.summary, NumberSummary.total);
    expect(old.better, BetterDirection.higher);
  });

  test('options are identified by stable IDs, not labels', () {
    final json = FieldConfigCodec.encode(cases[FieldType.singleSelect]!);
    expect(json, contains('"id":"a"'));
  });
}
