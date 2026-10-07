import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../activity_types/domain/field_config.dart';
import '../../activity_types/domain/field_type.dart';
import '../../../core/units/unit_registry.dart';
import 'insight.dart';

/// What an automatic chart shows, for its title (the UI words it).
enum AutoChartKind {
  /// Recorded time of the activity.
  time,

  /// How often it was done.
  count,

  /// A top-level field, summed up its own way (total, average, latest).
  value,

  /// A list number's best (by its "better is") per row.
  best,

  /// A list number per row, summed up its own way (when nothing is "best").
  rowValue,

  /// Weight × reps per row.
  volume,

  /// Estimated one-repetition maximum per row.
  estimatedMax,

  /// The second number of a weight × reps list, added up (total reps).
  rowTotal,

  /// The share of "yes" for a yes/no field.
  yesShare,
}

/// One chart worked out from an activity's fields (ADR-037, ADR-043).
class AutoChart {
  const AutoChart({
    required this.kind,
    required this.config,
    this.fieldName,
    this.rowName,
    this.bestIs = BestIs.highest,
  });

  final AutoChartKind kind;
  final InsightChartConfig config;

  /// The field it charts ("Weight", "Pages"), if any.
  final String? fieldName;

  /// The list row it's about ("Chest Press"), if any.
  final String? rowName;

  /// What "best" means for its values (ADR-043).
  final BestIs bestIs;
}

/// A choice field shown as how often each option was picked (B3).
class AutoBreakdown {
  const AutoBreakdown({required this.field});

  final ActivityField field;
}

/// What "best" means for a field's values (ADR-043): a number's "better
/// is"; higher for ratings and durations; nothing for yes/no and times.
BestIs bestIsFor(ActivityField field) => switch (field.config) {
  NumberFieldConfig(:final better) => switch (better) {
    BetterDirection.higher => BestIs.highest,
    BetterDirection.lower => BestIs.lowest,
    BetterDirection.neither => BestIs.none,
  },
  RatingFieldConfig() || DurationFieldConfig() => BestIs.highest,
  _ => BestIs.none,
};

Aggregation _summaryAggregation(ActivityField field) => switch (field.config) {
  NumberFieldConfig(:final summary) => switch (summary) {
    NumberSummary.total => Aggregation.sum,
    NumberSummary.average => Aggregation.average,
    NumberSummary.latest => Aggregation.latest,
  },
  RatingFieldConfig() ||
  BooleanFieldConfig() ||
  TimeFieldConfig() => Aggregation.average,
  _ => Aggregation.sum,
};

/// How a chart of [field] is summed up by default (the chart builder): a
/// Number's best by its "better is" (or its own summary when nothing is
/// best), a Rating, Yes/No or Time of day averaged, a Duration added up.
Aggregation defaultAggregationFor(ActivityField field) =>
    switch (bestIsFor(field)) {
      BestIs.highest when field.type == FieldType.number => Aggregation.max,
      BestIs.lowest => Aggregation.min,
      _ => _summaryAggregation(field),
    };

/// The charts an activity gets without anyone building them (ADR-037),
/// worked out from its fields only, never from what the activity is:
/// - time spent and how often
/// - every top-level field by its type: a Number summed up its own way
///   (total in bars; average or latest as a line, ADR-043), a Rating's
///   average, a Duration's total, the share of "yes" of a Yes/No, the
///   average Time of day
/// - inside lists, for each row name ([rowNames], most used first; e.g.
///   each exercise): the best of each Number (or its total/average/latest
///   when nothing is "best"); for a list with two Numbers (weight × reps),
///   the first one's best, its estimated one-rep maximum when it's a mass,
///   the volume, and the second one's total (B5); plus the share of "yes"
///   of each Yes/No in the list
///
/// [maxRows] row names per list (all when null). Choice fields are shown
/// as breakdowns instead ([autoBreakdownsFor]).
List<AutoChart> autoChartsFor(
  ActivityType type,
  Map<ActivityFieldId, List<String>> rowNames, {
  int? maxRows = 6,
}) {
  final charts = <AutoChart>[];
  InsightChartConfig chart(
    InsightSource source,
    Aggregation aggregation,
    ChartKind kind,
  ) => InsightChartConfig(
    id: const InsightChartId(''),
    title: '',
    source: source,
    aggregation: aggregation,
    bucket: Bucket.week,
    kind: kind,
  );
  ChartKind kindFor(Aggregation a) =>
      a == Aggregation.sum ? ChartKind.bar : ChartKind.line;

  charts
    ..add(
      AutoChart(
        kind: AutoChartKind.time,
        config: chart(
          ActivityDurationSource(type.id),
          Aggregation.sum,
          ChartKind.bar,
        ),
      ),
    )
    ..add(
      AutoChart(
        kind: AutoChartKind.count,
        config: chart(
          ActivityCountSource(type.id),
          Aggregation.count,
          ChartKind.bar,
        ),
      ),
    );

  for (final field in type.activeFields) {
    final AutoChartKind kind;
    switch (field.type) {
      case FieldType.number ||
          FieldType.rating ||
          FieldType.duration ||
          FieldType.time:
        kind = AutoChartKind.value;
      case FieldType.boolean:
        kind = AutoChartKind.yesShare;
      default:
        continue;
    }
    final aggregation = _summaryAggregation(field);
    charts.add(
      AutoChart(
        kind: kind,
        fieldName: field.name,
        bestIs: bestIsFor(field),
        config: chart(
          FieldValueSource(type.id, field.id),
          aggregation,
          kind == AutoChartKind.yesShare ? ChartKind.bar : kindFor(aggregation),
        ),
      ),
    );
  }

  /// The Text field naming a list's rows: the list's own first Text
  /// sub-field, or its parent list's.
  ActivityField? nameFieldOf(ActivityField group) {
    for (ActivityField? g = group; g != null;) {
      final text = type
          .subFieldsOf(g.id)
          .where((f) => f.type == FieldType.text)
          .firstOrNull;
      if (text != null) return text;
      g = g.parentId == null ? null : type.fieldById(g.parentId!);
    }
    return null;
  }

  void addList(ActivityField group) {
    final subFields = type.subFieldsOf(group.id);
    final numeric = subFields
        .where((f) => f.type == FieldType.number || f.type == FieldType.rating)
        .toList();
    final pair = numeric.where((f) => f.type == FieldType.number).toList();
    final nameField = nameFieldOf(group);
    final allNames = nameField == null
        ? const <String?>[null]
        : <String?>[...?rowNames[nameField.id]];
    final names = maxRows == null ? allNames : allNames.take(maxRows).toList();
    for (final name in names) {
      final filter = name == null
          ? null
          : TextFilter(fieldId: nameField!.id, value: name);
      void best(ActivityField field) {
        final bestIs = bestIsFor(field);
        final aggregation = switch (bestIs) {
          BestIs.highest when field.type == FieldType.number => Aggregation.max,
          BestIs.lowest => Aggregation.min,
          _ => _summaryAggregation(field),
        };
        charts.add(
          AutoChart(
            kind:
                aggregation == Aggregation.max || aggregation == Aggregation.min
                ? AutoChartKind.best
                : AutoChartKind.rowValue,
            fieldName: field.name,
            rowName: name,
            bestIs: bestIs,
            config: chart(
              FieldValueSource(type.id, field.id, filter: filter),
              aggregation,
              kindFor(aggregation) == ChartKind.bar
                  ? ChartKind.bar
                  : ChartKind.line,
            ),
          ),
        );
      }

      if (pair.length >= 2) {
        // Weight × reps: the best weight, its estimated maximum, the
        // volume and the reps tell the story (B5).
        final amount = pair[0];
        final count = pair[1];
        best(amount);
        if (amount.dimension == Dimension.mass &&
            bestIsFor(amount) == BestIs.highest) {
          charts.add(
            AutoChart(
              kind: AutoChartKind.estimatedMax,
              rowName: name,
              config: chart(
                VolumeSource(
                  type.id,
                  groupFieldId: group.id,
                  amountFieldId: amount.id,
                  countFieldId: count.id,
                  filter: filter,
                  formula: VolumeFormula.estimatedMax,
                ),
                Aggregation.max,
                ChartKind.line,
              ),
            ),
          );
        }
        charts
          ..add(
            AutoChart(
              kind: AutoChartKind.volume,
              rowName: name,
              config: chart(
                VolumeSource(
                  type.id,
                  groupFieldId: group.id,
                  amountFieldId: amount.id,
                  countFieldId: count.id,
                  filter: filter,
                ),
                Aggregation.sum,
                ChartKind.bar,
              ),
            ),
          )
          ..add(
            AutoChart(
              kind: AutoChartKind.rowTotal,
              fieldName: count.name,
              rowName: name,
              config: chart(
                FieldValueSource(type.id, count.id, filter: filter),
                Aggregation.sum,
                ChartKind.bar,
              ),
            ),
          );
        for (final other in numeric.where((f) => f != amount && f != count)) {
          best(other);
        }
      } else {
        numeric.forEach(best);
      }
    }
    for (final yesNo in subFields.where((f) => f.type == FieldType.boolean)) {
      charts.add(
        AutoChart(
          kind: AutoChartKind.yesShare,
          fieldName: yesNo.name,
          bestIs: BestIs.none,
          config: chart(
            FieldValueSource(type.id, yesNo.id),
            Aggregation.average,
            ChartKind.bar,
          ),
        ),
      );
    }
    for (final sub in subFields) {
      if (sub.type == FieldType.repeatingGroup) addList(sub);
    }
  }

  for (final field in type.activeFields) {
    if (field.type == FieldType.repeatingGroup) addList(field);
  }
  return charts;
}

/// The top-level choice fields of [type], each shown as how often each
/// option was picked (B3).
List<AutoBreakdown> autoBreakdownsFor(ActivityType type) => [
  for (final field in type.activeFields)
    if (field.type == FieldType.singleSelect ||
        field.type == FieldType.multiSelect)
      AutoBreakdown(field: field),
];

/// Whether any list of [type] has more row names than [maxRows] (C3).
bool hasMoreRows(
  ActivityType type,
  Map<ActivityFieldId, List<String>> rowNames, {
  int maxRows = 6,
}) => rowNames.values.any((names) => names.length > maxRows);
