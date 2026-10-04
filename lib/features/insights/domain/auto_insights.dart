import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../activity_types/domain/field_type.dart';
import 'insight.dart';

/// What an automatic chart shows, for its title (the UI words it).
enum AutoChartKind { time, count, value, best, volume }

/// One chart worked out from an activity's fields (ADR-037).
class AutoChart {
  const AutoChart({
    required this.kind,
    required this.config,
    this.fieldName,
    this.rowName,
  });

  final AutoChartKind kind;
  final InsightChartConfig config;

  /// The field it charts ("Weight", "Pages"), if any.
  final String? fieldName;

  /// The list row it's about ("Chest Press"), if any.
  final String? rowName;
}

/// The charts an activity gets without anyone building them (ADR-037),
/// worked out from its fields only, never from what the activity is:
/// - time spent and how often, per week
/// - every top-level Number (total per week) and Rating (average)
/// - inside lists: for each row name seen so far ([rowNames], keyed by the
///   list's first Text field; e.g. each exercise), the best of each Number,
///   and the volume (first Number × second Number per row, e.g. weight ×
///   reps) when a list has two Numbers (then only the first one's best)
///
/// At most [maxRows] row names per list and [maxCharts] charts in all.
List<AutoChart> autoChartsFor(
  ActivityType type,
  Map<ActivityFieldId, List<String>> rowNames, {
  int maxRows = 4,
  int maxCharts = 16,
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

  bool numeric(ActivityField f) =>
      f.type == FieldType.number || f.type == FieldType.rating;

  for (final field in type.activeFields.where(numeric)) {
    final rating = field.type == FieldType.rating;
    charts.add(
      AutoChart(
        kind: AutoChartKind.value,
        fieldName: field.name,
        config: chart(
          FieldValueSource(type.id, field.id),
          rating ? Aggregation.average : Aggregation.sum,
          rating ? ChartKind.line : ChartKind.bar,
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
    final numbers = subFields.where(numeric).toList();
    final nameField = nameFieldOf(group);
    final names = nameField == null
        ? const <String?>[null]
        : [...?rowNames[nameField.id]].take(maxRows).toList();
    for (final name in names) {
      final filter = name == null
          ? null
          : TextFilter(fieldId: nameField!.id, value: name);
      final pair = numbers.where((f) => f.type == FieldType.number).toList();
      // With weight × reps, the best weight and the volume tell the story.
      for (final number in pair.length >= 2 ? [pair.first] : numbers) {
        charts.add(
          AutoChart(
            kind: AutoChartKind.best,
            fieldName: number.name,
            rowName: name,
            config: chart(
              FieldValueSource(type.id, number.id, filter: filter),
              Aggregation.max,
              ChartKind.line,
            ),
          ),
        );
      }
      if (pair.length >= 2) {
        charts.add(
          AutoChart(
            kind: AutoChartKind.volume,
            rowName: name,
            config: chart(
              VolumeSource(
                type.id,
                groupFieldId: group.id,
                amountFieldId: pair[0].id,
                countFieldId: pair[1].id,
                filter: filter,
              ),
              Aggregation.sum,
              ChartKind.bar,
            ),
          ),
        );
      }
    }
    for (final sub in subFields) {
      if (sub.type == FieldType.repeatingGroup) addList(sub);
    }
  }

  for (final field in type.activeFields) {
    if (field.type == FieldType.repeatingGroup) addList(field);
  }
  return charts.take(maxCharts).toList();
}
