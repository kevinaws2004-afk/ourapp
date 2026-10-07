import 'activity_ids.dart';
import 'field_type.dart';

/// Field-type-specific configuration (`activity_fields.config_json`).
/// Only genuinely flexible settings live here (ADR-026).
sealed class FieldConfig {
  const FieldConfig();

  static FieldConfig defaultFor(FieldType type) => switch (type) {
    FieldType.text => const TextFieldConfig(),
    FieldType.number => const NumberFieldConfig(),
    FieldType.boolean => const BooleanFieldConfig(),
    FieldType.singleSelect ||
    FieldType.multiSelect => const SelectFieldConfig(options: []),
    FieldType.date => const DateFieldConfig(),
    FieldType.time => const TimeFieldConfig(),
    FieldType.duration => const DurationFieldConfig(),
    FieldType.rating => const RatingFieldConfig(),
    FieldType.repeatingGroup => const RepeatingGroupFieldConfig(),
  };

  /// Whether this config is the right shape for [type].
  bool matches(FieldType type) => switch (this) {
    TextFieldConfig() => type == FieldType.text,
    NumberFieldConfig() => type == FieldType.number,
    BooleanFieldConfig() => type == FieldType.boolean,
    SelectFieldConfig() =>
      type == FieldType.singleSelect || type == FieldType.multiSelect,
    DateFieldConfig() => type == FieldType.date,
    TimeFieldConfig() => type == FieldType.time,
    DurationFieldConfig() => type == FieldType.duration,
    RatingFieldConfig() => type == FieldType.rating,
    RepeatingGroupFieldConfig() => type == FieldType.repeatingGroup,
  };
}

final class TextFieldConfig extends FieldConfig {
  const TextFieldConfig({
    this.multiline = false,
    this.suggestFromHistory = false,
  });

  final bool multiline;

  /// Offer previously entered values while typing (e.g. exercise names).
  final bool suggestFromHistory;

  @override
  bool operator ==(Object other) =>
      other is TextFieldConfig &&
      other.multiline == multiline &&
      other.suggestFromHistory == suggestFromHistory;

  @override
  int get hashCode => Object.hash(multiline, suggestFromHistory);
}

/// How a Number field is summed up over time in Insights (ADR-043): an
/// amount adds up (pages, kilometres), a reading is averaged (blood
/// pressure, score), a level shows its latest value (odometer, balance).
enum NumberSummary { total, average, latest }

/// Which way is better for a Number field (ADR-043): it decides what
/// "best" means in Insights. [neither] shows no best at all (e.g. money
/// spent or a temperature).
enum BetterDirection { higher, lower, neither }

final class NumberFieldConfig extends FieldConfig {
  const NumberFieldConfig({
    this.decimals = 0,
    this.min,
    this.max,
    this.defaultUnitCode,
    this.summary = NumberSummary.total,
    this.better = BetterDirection.higher,
  });

  static const maxDecimals = 3;

  final int decimals;
  final double? min;
  final double? max;

  /// Display/entry default within the field's dimension; null when unitless.
  final String? defaultUnitCode;

  /// How Insights sums it up over a period (ADR-043).
  final NumberSummary summary;

  /// Which way is better, for "best" in Insights (ADR-043).
  final BetterDirection better;

  NumberFieldConfig copyWith({
    int? decimals,
    double? Function()? min,
    double? Function()? max,
    String? Function()? defaultUnitCode,
    NumberSummary? summary,
    BetterDirection? better,
  }) => NumberFieldConfig(
    decimals: decimals ?? this.decimals,
    min: min != null ? min() : this.min,
    max: max != null ? max() : this.max,
    defaultUnitCode: defaultUnitCode != null
        ? defaultUnitCode()
        : this.defaultUnitCode,
    summary: summary ?? this.summary,
    better: better ?? this.better,
  );

  @override
  bool operator ==(Object other) =>
      other is NumberFieldConfig &&
      other.decimals == decimals &&
      other.min == min &&
      other.max == max &&
      other.defaultUnitCode == defaultUnitCode &&
      other.summary == summary &&
      other.better == better;

  @override
  int get hashCode =>
      Object.hash(decimals, min, max, defaultUnitCode, summary, better);
}

final class BooleanFieldConfig extends FieldConfig {
  const BooleanFieldConfig();

  @override
  bool operator ==(Object other) => other is BooleanFieldConfig;

  @override
  int get hashCode => 0;
}

/// Options for Single and Multi Select, each with a stable ID (ADR-019).
final class SelectFieldConfig extends FieldConfig {
  const SelectFieldConfig({required this.options});

  final List<SelectOption> options;

  List<SelectOption> get activeOptions =>
      options.where((o) => !o.archived).toList();

  SelectOption? optionById(SelectOptionId id) {
    for (final option in options) {
      if (option.id == id) return option;
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is SelectFieldConfig && _listEquals(other.options, options);

  @override
  int get hashCode => Object.hashAll(options);
}

class SelectOption {
  const SelectOption({
    required this.id,
    required this.label,
    this.archived = false,
  });

  final SelectOptionId id;
  final String label;

  /// Kept so historical values still render; not offered for new values.
  final bool archived;

  SelectOption copyWith({String? label, bool? archived}) => SelectOption(
    id: id,
    label: label ?? this.label,
    archived: archived ?? this.archived,
  );

  @override
  bool operator ==(Object other) =>
      other is SelectOption &&
      other.id == id &&
      other.label == label &&
      other.archived == archived;

  @override
  int get hashCode => Object.hash(id, label, archived);
}

final class DateFieldConfig extends FieldConfig {
  const DateFieldConfig();

  @override
  bool operator ==(Object other) => other is DateFieldConfig;

  @override
  int get hashCode => 1;
}

final class TimeFieldConfig extends FieldConfig {
  const TimeFieldConfig();

  @override
  bool operator ==(Object other) => other is TimeFieldConfig;

  @override
  int get hashCode => 2;
}

final class DurationFieldConfig extends FieldConfig {
  const DurationFieldConfig();

  @override
  bool operator ==(Object other) => other is DurationFieldConfig;

  @override
  int get hashCode => 3;
}

final class RatingFieldConfig extends FieldConfig {
  const RatingFieldConfig({this.max = 5});

  static const minScale = 3;
  static const maxScale = 10;

  final int max;

  @override
  bool operator ==(Object other) =>
      other is RatingFieldConfig && other.max == max;

  @override
  int get hashCode => max.hashCode;
}

/// Repeating Group presentation config. Its sub-fields are real fields with
/// `parent_field_id` (ADR-027), not part of this config.
final class RepeatingGroupFieldConfig extends FieldConfig {
  const RepeatingGroupFieldConfig({this.itemLabel = ''});

  /// What one item is called ("Exercise", "Set"); shown on "Add …" buttons.
  final String itemLabel;

  @override
  bool operator ==(Object other) =>
      other is RepeatingGroupFieldConfig && other.itemLabel == itemLabel;

  @override
  int get hashCode => itemLabel.hashCode;
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
