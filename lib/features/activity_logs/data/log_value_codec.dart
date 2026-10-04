import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/time/local_date.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/domain/field_type.dart';
import '../domain/field_value.dart';

/// [FieldValue] ↔ typed `log_values` columns (database.md §3.5, ADR-019).
abstract final class LogValueCodec {
  static const _multiSelectVersion = 1;

  /// Columns for [value]. Number values get `normalized_value` computed here,
  /// at write time (ADR-020). A Repeating Group has no value row of its own
  /// (its items are `log_group_items` rows, ADR-027), so it is rejected.
  static LogValuesCompanion columns(FieldValue value) => switch (value) {
    TextValue(:final text) => LogValuesCompanion(textValue: Value(text)),
    NumberValue(:final value, :final unitCode, :final normalized) =>
      LogValuesCompanion(
        numberValue: Value(value),
        unitCode: Value(unitCode),
        normalizedValue: Value(normalized),
      ),
    BooleanValue(:final value) => LogValuesCompanion(
      booleanValue: Value(value ? 1 : 0),
    ),
    SingleSelectValue(:final optionId) => LogValuesCompanion(
      textValue: Value(optionId.value),
    ),
    MultiSelectValue(:final optionIds) => LogValuesCompanion(
      jsonValue: Value(
        jsonEncode({
          'v': _multiSelectVersion,
          'optionIds': [for (final id in optionIds) id.value],
        }),
      ),
    ),
    DateValue(:final date) => LogValuesCompanion(
      dateValue: Value(date.toIso()),
    ),
    TimeValue(:final time) => LogValuesCompanion(
      timeValue: Value(time.minuteOfDay),
    ),
    DurationValue(:final milliseconds) => LogValuesCompanion(
      durationMs: Value(milliseconds),
    ),
    RatingValue(:final stars) => LogValuesCompanion(
      numberValue: Value(stars.toDouble()),
      normalizedValue: Value(stars.toDouble()),
    ),
    RepeatingGroupValue() => throw const UnsupportedException(
      debugContext: 'repeating_group has no log_values row',
    ),
  };

  /// Every value column set to null, so an update can switch columns safely.
  static const LogValuesCompanion _cleared = LogValuesCompanion(
    textValue: Value(null),
    numberValue: Value(null),
    unitCode: Value(null),
    normalizedValue: Value(null),
    booleanValue: Value(null),
    dateValue: Value(null),
    timeValue: Value(null),
    durationMs: Value(null),
    jsonValue: Value(null),
  );

  /// Columns for updating an existing row to [value].
  static LogValuesCompanion updateColumns(FieldValue value, int updatedAt) {
    final set = columns(value);
    return _cleared.copyWith(
      textValue: set.textValue.present ? set.textValue : null,
      numberValue: set.numberValue.present ? set.numberValue : null,
      unitCode: set.unitCode.present ? set.unitCode : null,
      normalizedValue: set.normalizedValue.present ? set.normalizedValue : null,
      booleanValue: set.booleanValue.present ? set.booleanValue : null,
      dateValue: set.dateValue.present ? set.dateValue : null,
      timeValue: set.timeValue.present ? set.timeValue : null,
      durationMs: set.durationMs.present ? set.durationMs : null,
      jsonValue: set.jsonValue.present ? set.jsonValue : null,
      updatedAt: Value(updatedAt),
    );
  }

  /// Reads a stored row for a field of [type]. Unreadable payloads raise
  /// [UnsupportedException] (e.g. a JSON version from a newer app).
  static FieldValue decode(FieldType type, LogValueRow row) {
    switch (type) {
      case FieldType.text:
        return TextValue(row.textValue!);
      case FieldType.number:
        return NumberValue(row.numberValue!, unitCode: row.unitCode);
      case FieldType.boolean:
        return BooleanValue(row.booleanValue == 1);
      case FieldType.singleSelect:
        return SingleSelectValue(SelectOptionId(row.textValue!));
      case FieldType.multiSelect:
        final decoded = jsonDecode(row.jsonValue!);
        if (decoded is! Map ||
            decoded['v'] != _multiSelectVersion ||
            decoded['optionIds'] is! List) {
          throw const UnsupportedException(
            debugContext: 'multi_select value version',
          );
        }
        return MultiSelectValue([
          for (final id in decoded['optionIds'] as List)
            SelectOptionId(id as String),
        ]);
      case FieldType.date:
        return DateValue(LocalDate.parse(row.dateValue!));
      case FieldType.time:
        return TimeValue(LocalTime(row.timeValue!));
      case FieldType.duration:
        return DurationValue(row.durationMs!);
      case FieldType.rating:
        return RatingValue(row.numberValue!.round());
      case FieldType.repeatingGroup:
        throw const UnsupportedException(
          debugContext: 'repeating_group has no log_values row',
        );
    }
  }

  /// [decode], or null when the row can't be read (used for change checks).
  static FieldValue? decodeOrNull(FieldType type, LogValueRow row) {
    try {
      return decode(type, row);
    } on Object {
      return null;
    }
  }
}
