import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/reactive_query.dart';
import '../../../core/database/soft_delete.dart';
import '../../../core/database/storage_guard.dart';
import '../../../core/time/local_date.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../domain/insight.dart';
import '../domain/insight_repository.dart';
import 'insight_chart_codec.dart';

/// drift implementation of [InsightRepository]. Every series is a plain
/// relational query over typed, unit-normalized columns (ADR-019/020/027);
/// nested Repeating Group values are integer joins, never JSON.
class DbInsightRepository implements InsightRepository {
  DbInsightRepository(this._db);

  final AppDatabase _db;

  /// Resolves a public ID to its internal one inside SQL.
  static const _type =
      '(SELECT internal_id FROM activity_types WHERE public_id = ?)';
  static const _field =
      '(SELECT internal_id FROM activity_fields WHERE public_id = ?)';

  Stream<T> _watch<T>(Future<T> Function() load) => reactiveQuery(
    _db.tableUpdates(
      TableUpdateQuery.onAllTables([
        _db.activityLogs,
        _db.logValues,
        _db.logGroupItems,
        _db.plans,
        _db.measurements,
        _db.activityFields,
      ]),
    ),
    load,
  );

  Future<List<DataPoint>> _points(String sql, List<Variable> vars) async {
    final rows = await _db
        .customSelect(
          sql,
          variables: vars,
          readsFrom: {
            _db.activityLogs,
            _db.logValues,
            _db.logGroupItems,
            _db.plans,
            _db.measurements,
          },
        )
        .get();
    return [
      for (final r in rows)
        DataPoint(LocalDate.parse(r.read<String>('d')), r.read<double>('v')),
    ];
  }

  /// Keeps rows whose item ([itemColumn]), parent item, or record has the
  /// filter's text value.
  static String _filterSql(String itemColumn, String logColumn) =>
      'AND EXISTS (SELECT 1 FROM log_values t '
      'WHERE t.field_id = $_field AND t.text_value = ? COLLATE NOCASE AND ('
      't.group_item_id = $itemColumn OR '
      't.group_item_id = (SELECT parent_item_id FROM log_group_items '
      'WHERE internal_id = $itemColumn) OR '
      '(t.group_item_id IS NULL AND t.log_id = $logColumn)))';

  static List<Variable> _filterVars(TextFilter? f) =>
      f == null ? const [] : [Variable(f.fieldId.value), Variable(f.value)];

  @override
  Stream<List<DataPoint>> watchPoints(InsightSource source) =>
      guardStorageStream('watchInsightPoints', _watch(() => _load(source)));

  Future<List<DataPoint>> _load(InsightSource source) => switch (source) {
    // idx_activity_logs_type_day.
    ActivityDurationSource(:final typeId) => _points(
      'SELECT local_date AS d, CAST(duration_ms AS REAL) AS v '
      'FROM activity_logs WHERE activity_type_id = $_type '
      'AND deleted_at IS NULL AND duration_ms IS NOT NULL ORDER BY local_date',
      [Variable(typeId.value)],
    ),
    ActivityCountSource(:final typeId) => _points(
      'SELECT local_date AS d, 1.0 AS v FROM activity_logs '
      'WHERE activity_type_id = $_type AND deleted_at IS NULL '
      'ORDER BY local_date',
      [Variable(typeId.value)],
    ),
    // idx_log_values_field_normalized, then the log by primary key.
    FieldValueSource(:final fieldId, :final filter) => _points(
      'SELECT l.local_date AS d, v.normalized_value AS v FROM log_values v '
      'JOIN activity_logs l ON l.internal_id = v.log_id '
      'WHERE v.field_id = $_field AND v.normalized_value IS NOT NULL '
      'AND l.deleted_at IS NULL '
      '${filter == null ? '' : _filterSql('v.group_item_id', 'v.log_id')} '
      'ORDER BY l.local_date',
      [Variable(fieldId.value), ..._filterVars(filter)],
    ),
    // One point per group item: amount × count (e.g. kg × reps per set).
    VolumeSource(
      :final groupFieldId,
      :final amountFieldId,
      :final countFieldId,
      :final filter,
    ) =>
      _points(
        'SELECT l.local_date AS d, a.normalized_value * c.normalized_value AS v '
        'FROM log_group_items i '
        'JOIN log_values a ON a.group_item_id = i.internal_id '
        'AND a.field_id = $_field '
        'JOIN log_values c ON c.group_item_id = i.internal_id '
        'AND c.field_id = $_field '
        'JOIN activity_logs l ON l.internal_id = i.log_id '
        'WHERE i.field_id = $_field AND l.deleted_at IS NULL '
        '${filter == null ? '' : _filterSql('i.internal_id', 'i.log_id')} '
        'ORDER BY l.local_date',
        [
          Variable(amountFieldId.value),
          Variable(countFieldId.value),
          Variable(groupFieldId.value),
          ..._filterVars(filter),
        ],
      ),
    // idx_measurements_type_day.
    MeasurementSource(:final type) => _points(
      'SELECT local_date AS d, normalized_value AS v FROM measurements '
      'WHERE measurement_type = ? AND deleted_at IS NULL '
      'ORDER BY local_date, recorded_at',
      [Variable(type.storageKey)],
    ),
    PlannedVsActualSource() => throw ArgumentError(
      'Use watchPlannedVsActual for planned vs actual',
    ),
  };

  @override
  Stream<(List<DataPoint>, List<DataPoint>)> watchPlannedVsActual(
    ActivityTypeId? typeId,
  ) => guardStorageStream(
    'watchPlannedVsActual',
    _watch(() async {
      final typeFilter = typeId == null
          ? 'AND p.activity_type_id IS NOT NULL'
          : 'AND p.activity_type_id = $_type';
      final vars = [if (typeId != null) Variable<String>(typeId.value)];
      final planned = await _points(
        'SELECT p.plan_date AS d, CAST(COALESCE(p.planned_end_at - '
        'p.planned_start_at, p.planned_duration_ms) AS REAL) AS v '
        'FROM plans p WHERE p.deleted_at IS NULL $typeFilter '
        'AND COALESCE(p.planned_end_at - p.planned_start_at, '
        'p.planned_duration_ms) IS NOT NULL ORDER BY p.plan_date',
        vars,
      );
      final actual = await _points(
        'SELECT p.plan_date AS d, CAST(l.duration_ms AS REAL) AS v '
        'FROM activity_logs l JOIN plans p ON p.internal_id = l.plan_id '
        'WHERE p.deleted_at IS NULL AND l.deleted_at IS NULL '
        'AND l.duration_ms IS NOT NULL $typeFilter ORDER BY p.plan_date',
        vars,
      );
      return (planned, actual);
    }),
  );

  @override
  Stream<Map<ActivityTypeId, ActivityTotals>> watchActivityTotals(
    LocalDate from,
    LocalDate to,
  ) => guardStorageStream(
    'watchActivityTotals',
    _watch(() async {
      final rows = await _db
          .customSelect(
            'SELECT t.public_id AS id, SUM(COALESCE(l.duration_ms, 0)) AS ms, '
            'COUNT(*) AS n FROM activity_logs l '
            'JOIN activity_types t ON t.internal_id = l.activity_type_id '
            'WHERE l.deleted_at IS NULL AND l.local_date BETWEEN ? AND ? '
            'GROUP BY l.activity_type_id',
            variables: [Variable(from.toIso()), Variable(to.toIso())],
            readsFrom: {_db.activityLogs, _db.activityTypes},
          )
          .get();
      return {
        for (final r in rows)
          ActivityTypeId(r.read<String>('id')): ActivityTotals(
            durationMs: r.read<int>('ms'),
            count: r.read<int>('n'),
          ),
      };
    }),
  );

  @override
  Stream<List<InsightChartConfig>> watchCharts() => guardStorageStream(
    'watchInsightCharts',
    reactiveQuery(
      _db.tableUpdates(TableUpdateQuery.onAllTables([_db.insightCharts])),
      () async {
        final rows =
            await (_db.select(_db.insightCharts)
                  ..where((c) => isActive(c.deletedAt))
                  ..orderBy([(c) => OrderingTerm.asc(c.position)]))
                .get();
        return [
          for (final r in rows)
            ?InsightChartCodec.decode(r.publicId, r.configJson),
        ];
      },
    ),
  );

  @override
  Future<void> saveChart(InsightChartConfig chart, DateTime now) =>
      guardStorage('saveInsightChart', () async {
        final ms = now.millisecondsSinceEpoch;
        final json = InsightChartCodec.encode(chart);
        final updated =
            await (_db.update(
              _db.insightCharts,
            )..where((c) => c.publicId.equals(chart.id.value))).write(
              InsightChartsCompanion(
                configJson: Value(json),
                updatedAt: Value(ms),
                deletedAt: const Value(null),
              ),
            );
        if (updated > 0) return;
        final next = await _db
            .customSelect(
              'SELECT COALESCE(MAX(position), -1) + 1 AS n FROM insight_charts',
            )
            .getSingle();
        await _db
            .into(_db.insightCharts)
            .insert(
              InsightChartsCompanion.insert(
                publicId: chart.id.value,
                position: Value(next.read<int>('n')),
                configJson: json,
                createdAt: ms,
                updatedAt: ms,
              ),
            );
      });

  @override
  Future<void> deleteChart(InsightChartId id, DateTime now) =>
      guardStorage('deleteInsightChart', () async {
        final ms = now.millisecondsSinceEpoch;
        await (_db.update(
          _db.insightCharts,
        )..where((c) => c.publicId.equals(id.value))).write(
          InsightChartsCompanion(deletedAt: Value(ms), updatedAt: Value(ms)),
        );
      });
}
