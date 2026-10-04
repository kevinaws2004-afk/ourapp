import 'dart:convert';

import '../../activity_types/domain/activity_ids.dart';
import '../../measurements/domain/measurement.dart';
import '../domain/insight.dart';

/// `insight_charts.config_json` ↔ [InsightChartConfig]. Versioned (`"v"`)
/// and references activities and fields by stable public IDs (ADR-019).
/// Unreadable configs decode to null and are skipped.
abstract final class InsightChartCodec {
  static const _version = 1;

  static String encode(InsightChartConfig c) => jsonEncode({
    'v': _version,
    'title': c.title,
    'aggregation': c.aggregation.name,
    'bucket': c.bucket.name,
    'kind': c.kind.name,
    'source': _source(c.source),
  });

  static Map<String, Object?> _filter(TextFilter? f) => f == null
      ? const {}
      : {
          'filter': {'field': f.fieldId.value, 'value': f.value},
        };

  static Map<String, Object?> _source(InsightSource s) => switch (s) {
    ActivityDurationSource(:final typeId) => {
      'kind': 'duration',
      'type': typeId.value,
    },
    ActivityCountSource(:final typeId) => {
      'kind': 'count',
      'type': typeId.value,
    },
    FieldValueSource(:final typeId, :final fieldId, :final filter) => {
      'kind': 'field',
      'type': typeId.value,
      'field': fieldId.value,
      ..._filter(filter),
    },
    VolumeSource(
      :final typeId,
      :final groupFieldId,
      :final amountFieldId,
      :final countFieldId,
      :final filter,
    ) =>
      {
        'kind': 'volume',
        'type': typeId.value,
        'group': groupFieldId.value,
        'amount': amountFieldId.value,
        'count': countFieldId.value,
        ..._filter(filter),
      },
    MeasurementSource(:final type) => {
      'kind': 'measurement',
      'measurement': type.storageKey,
    },
    PlannedVsActualSource(:final typeId) => {
      'kind': 'plannedVsActual',
      'type': ?typeId?.value,
    },
  };

  static InsightChartConfig? decode(String id, String json) {
    try {
      final map = jsonDecode(json) as Map<String, Object?>;
      if (map['v'] != _version) return null;
      final source = _decodeSource(map['source']! as Map<String, Object?>);
      if (source == null) return null;
      return InsightChartConfig(
        id: InsightChartId(id),
        title: map['title'] as String? ?? '',
        source: source,
        aggregation: Aggregation.values.byName(map['aggregation']! as String),
        bucket: Bucket.values.byName(map['bucket']! as String),
        kind: ChartKind.values.byName(map['kind']! as String),
      );
    } on Object {
      return null;
    }
  }

  static InsightSource? _decodeSource(Map<String, Object?> s) {
    ActivityTypeId type() => ActivityTypeId(s['type']! as String);
    ActivityFieldId field(String key) => ActivityFieldId(s[key]! as String);
    final rawFilter = s['filter'];
    final filter = rawFilter is Map
        ? TextFilter(
            fieldId: ActivityFieldId(rawFilter['field'] as String),
            value: rawFilter['value'] as String,
          )
        : null;
    return switch (s['kind']) {
      'duration' => ActivityDurationSource(type()),
      'count' => ActivityCountSource(type()),
      'field' => FieldValueSource(type(), field('field'), filter: filter),
      'volume' => VolumeSource(
        type(),
        groupFieldId: field('group'),
        amountFieldId: field('amount'),
        countFieldId: field('count'),
        filter: filter,
      ),
      'measurement' => switch (MeasurementType.fromStorageKey(
        s['measurement']! as String,
      )) {
        final t? => MeasurementSource(t),
        null => null,
      },
      'plannedVsActual' => PlannedVsActualSource(
        s['type'] is String ? type() : null,
      ),
      _ => null,
    };
  }
}
