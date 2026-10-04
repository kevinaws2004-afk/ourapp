import 'dart:convert';

import '../domain/activity_ids.dart';
import '../domain/field_config.dart';
import '../domain/field_type.dart';

/// `activity_fields.config_json` ↔ [FieldConfig] (ADR-019/026).
///
/// Decoding is tolerant (unknown keys ignored, missing keys default), so
/// older and newer configs keep reading.
abstract final class FieldConfigCodec {
  static String encode(FieldConfig config) => jsonEncode(switch (config) {
    TextFieldConfig(:final multiline, :final suggestFromHistory) => {
      if (multiline) 'multiline': true,
      if (suggestFromHistory) 'suggest': true,
    },
    NumberFieldConfig(
      :final decimals,
      :final min,
      :final max,
      :final defaultUnitCode,
    ) =>
      {
        'decimals': decimals,
        'min': ?min,
        'max': ?max,
        'defaultUnit': ?defaultUnitCode,
      },
    SelectFieldConfig(:final options) => {
      'options': [
        for (final o in options)
          {
            'id': o.id.value,
            'label': o.label,
            if (o.archived) 'archived': true,
          },
      ],
    },
    RatingFieldConfig(:final max) => {'max': max},
    RepeatingGroupFieldConfig(:final itemLabel) => {'itemLabel': itemLabel},
    BooleanFieldConfig() ||
    DateFieldConfig() ||
    TimeFieldConfig() ||
    DurationFieldConfig() => <String, Object?>{},
  });

  static FieldConfig decode(FieldType type, String json) {
    final decoded = jsonDecode(json);
    final map = decoded is Map<String, Object?>
        ? decoded
        : const <String, Object?>{};
    return switch (type) {
      FieldType.text => TextFieldConfig(
        multiline: map['multiline'] == true,
        suggestFromHistory: map['suggest'] == true,
      ),
      FieldType.number => NumberFieldConfig(
        decimals: _int(map['decimals']) ?? 0,
        min: _double(map['min']),
        max: _double(map['max']),
        defaultUnitCode: map['defaultUnit'] is String
            ? map['defaultUnit']! as String
            : null,
      ),
      FieldType.singleSelect || FieldType.multiSelect => SelectFieldConfig(
        options: [
          for (final raw
              in (map['options'] is List ? map['options']! as List : const []))
            if (raw is Map && raw['id'] is String && raw['label'] is String)
              SelectOption(
                id: SelectOptionId(raw['id'] as String),
                label: raw['label'] as String,
                archived: raw['archived'] == true,
              ),
        ],
      ),
      FieldType.rating => RatingFieldConfig(max: _int(map['max']) ?? 5),
      FieldType.boolean => const BooleanFieldConfig(),
      FieldType.date => const DateFieldConfig(),
      FieldType.time => const TimeFieldConfig(),
      FieldType.duration => const DurationFieldConfig(),
      FieldType.repeatingGroup => RepeatingGroupFieldConfig(
        itemLabel: map['itemLabel'] is String
            ? map['itemLabel']! as String
            : '',
      ),
    };
  }

  static int? _int(Object? value) => value is num ? value.toInt() : null;

  static double? _double(Object? value) =>
      value is num ? value.toDouble() : null;
}
