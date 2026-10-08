import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/done_records.dart';
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

  /// A record that counts as done: something is in it (A8).
  static String _counts(String log) => doneRecordSql(log);

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

  /// A field value as a number: unit-normalized numbers and ratings, then
  /// durations (ms), yes/no (1/0) and times of day (minutes, B1/B2/B4).
  static const _value =
      'COALESCE(v.normalized_value, CAST(v.duration_ms AS REAL), '
      'CAST(v.boolean_value AS REAL), CAST(v.time_value AS REAL))';

  /// The query of [source]'s points (columns `d`, `v`), from [from] on.
  static (String, List<Variable>) _query(
    InsightSource source,
    LocalDate? from,
  ) {
    final since = from == null ? '' : 'AND l.local_date >= ? ';
    final sinceVars = [if (from != null) Variable<String>(from.toIso())];
    return switch (source) {
      // idx_activity_logs_type_day.
      ActivityDurationSource(:final typeId) => (
        'SELECT l.local_date AS d, CAST(l.duration_ms AS REAL) AS v '
            'FROM activity_logs l WHERE l.activity_type_id = $_type '
            'AND l.deleted_at IS NULL AND l.duration_ms IS NOT NULL $since'
            'ORDER BY l.local_date',
        [Variable(typeId.value), ...sinceVars],
      ),
      ActivityCountSource(:final typeId) => (
        'SELECT l.local_date AS d, 1.0 AS v FROM activity_logs l '
            'WHERE l.activity_type_id = $_type AND l.deleted_at IS NULL '
            'AND ${_counts('l')} $since'
            'ORDER BY l.local_date',
        [Variable(typeId.value), ...sinceVars],
      ),
      // idx_log_values_field_normalized, then the log by primary key.
      FieldValueSource(:final fieldId, :final filter) => (
        'SELECT l.local_date AS d, $_value AS v FROM log_values v '
            'JOIN activity_logs l ON l.internal_id = v.log_id '
            'WHERE v.field_id = $_field AND $_value IS NOT NULL '
            'AND l.deleted_at IS NULL $since'
            '${filter == null ? '' : _filterSql('v.group_item_id', 'v.log_id')} '
            'ORDER BY l.local_date',
        [Variable(fieldId.value), ...sinceVars, ..._filterVars(filter)],
      ),
      // One point per group item: e.g. kg × reps per set, or its estimated
      // one-repetition maximum.
      VolumeSource(
        :final groupFieldId,
        :final amountFieldId,
        :final countFieldId,
        :final filter,
        :final formula,
      ) =>
        (
          'SELECT l.local_date AS d, ${switch (formula) {
                VolumeFormula.product => 'a.normalized_value * c.normalized_value',
                VolumeFormula.estimatedMax => 'CASE WHEN c.normalized_value <= 1 '
                    'THEN a.normalized_value ELSE a.normalized_value * '
                    '(1 + c.normalized_value / 30.0) END',
              }} AS v '
              'FROM log_group_items i '
              'JOIN log_values a ON a.group_item_id = i.internal_id '
              'AND a.field_id = $_field '
              'JOIN log_values c ON c.group_item_id = i.internal_id '
              'AND c.field_id = $_field '
              'JOIN activity_logs l ON l.internal_id = i.log_id '
              'WHERE i.field_id = $_field AND l.deleted_at IS NULL '
              'AND a.normalized_value IS NOT NULL '
              'AND c.normalized_value IS NOT NULL $since'
              '${filter == null ? '' : _filterSql('i.internal_id', 'i.log_id')} '
              'ORDER BY l.local_date',
          [
            Variable(amountFieldId.value),
            Variable(countFieldId.value),
            Variable(groupFieldId.value),
            ...sinceVars,
            ..._filterVars(filter),
          ],
        ),
      // idx_measurements_type_day.
      MeasurementSource(:final type) => (
        'SELECT local_date AS d, normalized_value AS v FROM measurements l '
            'WHERE measurement_type = ? AND deleted_at IS NULL $since'
            'ORDER BY local_date, recorded_at',
        [Variable(type.storageKey), ...sinceVars],
      ),
      PlannedVsActualSource() => throw ArgumentError(
        'Use watchPlannedVsActual for planned vs actual',
      ),
    };
  }

  @override
  Stream<List<DataPoint>> watchPoints(
    InsightSource source, {
    LocalDate? from,
  }) => guardStorageStream(
    'watchInsightPoints',
    _watch(() {
      final (sql, vars) = _query(source, from);
      return _points(sql, vars);
    }),
  );

  @override
  Stream<DataPoint?> watchBest(InsightSource source, BestIs bestIs) =>
      bestIs == BestIs.none
      ? Stream.value(null)
      : guardStorageStream(
          'watchInsightBest',
          _watch(() async {
            final (sql, vars) = _query(source, null);
            final order = bestIs == BestIs.highest ? 'DESC' : 'ASC';
            final rows = await _points(
              'SELECT d, v FROM ($sql) ORDER BY v $order, d DESC LIMIT 1',
              vars,
            );
            return rows.firstOrNull;
          }),
        );

  @override
  Stream<DataPoint?> watchBestDay(VolumeSource source) => guardStorageStream(
    'watchInsightBestDay',
    _watch(() async {
      final (sql, vars) = _query(source, null);
      final rows = await _points(
        'SELECT d, SUM(v) AS v FROM ($sql) GROUP BY d '
        'ORDER BY v DESC, d DESC LIMIT 1',
        vars,
      );
      return rows.firstOrNull;
    }),
  );

  @override
  Stream<(List<DataPoint>, List<DataPoint>)> watchPlannedVsActual(
    ActivityTypeId? typeId, {
    required LocalDate from,
    required LocalDate today,
  }) => guardStorageStream(
    'watchPlannedVsActual',
    _watch(() async {
      final typeFilter = typeId == null
          ? 'AND p.activity_type_id IS NOT NULL'
          : 'AND p.activity_type_id = $_type';
      // Skipped and cancelled plans aren't planned (A4); today's plans only
      // count once they're done or logged, as the day isn't over (A6).
      const counted =
          "AND p.status NOT IN ('skipped', 'cancelled') "
          'AND p.plan_date >= ? AND p.plan_date <= ? '
          "AND (p.plan_date < ? OR p.status = 'completed' OR EXISTS ("
          'SELECT 1 FROM activity_logs pl WHERE pl.plan_id = p.internal_id '
          'AND pl.deleted_at IS NULL))';
      final vars = [
        if (typeId != null) Variable<String>(typeId.value),
        Variable<String>(from.toIso()),
        Variable<String>(today.toIso()),
        Variable<String>(today.toIso()),
      ];
      final planned = await _points(
        'SELECT p.plan_date AS d, CAST(COALESCE(p.planned_end_at - '
        'p.planned_start_at, p.planned_duration_ms) AS REAL) AS v '
        'FROM plans p WHERE p.deleted_at IS NULL $typeFilter $counted '
        'AND COALESCE(p.planned_end_at - p.planned_start_at, '
        'p.planned_duration_ms) IS NOT NULL ORDER BY p.plan_date',
        vars,
      );
      final actual = await _points(
        'SELECT p.plan_date AS d, CAST(l.duration_ms AS REAL) AS v '
        'FROM activity_logs l JOIN plans p ON p.internal_id = l.plan_id '
        'WHERE p.deleted_at IS NULL AND l.deleted_at IS NULL '
        'AND l.duration_ms IS NOT NULL $typeFilter $counted '
        'ORDER BY p.plan_date',
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
            'COUNT(*) AS n, COUNT(DISTINCT l.local_date) AS d '
            'FROM activity_logs l '
            'JOIN activity_types t ON t.internal_id = l.activity_type_id '
            'WHERE l.deleted_at IS NULL AND l.local_date BETWEEN ? AND ? '
            'AND ${_counts('l')} '
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
            days: r.read<int>('d'),
          ),
      };
    }),
  );

  @override
  Stream<Map<LocalDate, int>> watchDayCounts(
    ActivityTypeId? typeId,
    LocalDate from,
    LocalDate to,
  ) => guardStorageStream(
    'watchDayCounts',
    _watch(() async {
      final rows = await _db
          .customSelect(
            'SELECT l.local_date AS d, COUNT(*) AS n FROM activity_logs l '
            'WHERE l.deleted_at IS NULL AND l.local_date BETWEEN ? AND ? '
            '${typeId == null ? '' : 'AND l.activity_type_id = $_type'} '
            'AND ${_counts('l')} GROUP BY l.local_date',
            variables: [
              Variable(from.toIso()),
              Variable(to.toIso()),
              if (typeId != null) Variable(typeId.value),
            ],
            readsFrom: {_db.activityLogs},
          )
          .get();
      return {
        for (final r in rows)
          LocalDate.parse(r.read<String>('d')): r.read<int>('n'),
      };
    }),
  );

  @override
  Stream<List<ActivityDayTime>> watchTimeByActivity(
    LocalDate from,
    LocalDate to,
  ) => guardStorageStream(
    'watchTimeByActivity',
    _watch(() async {
      final rows = await _db
          .customSelect(
            'SELECT t.public_id AS id, l.local_date AS d, '
            'SUM(l.duration_ms) AS ms FROM activity_logs l '
            'JOIN activity_types t ON t.internal_id = l.activity_type_id '
            'WHERE l.deleted_at IS NULL AND l.duration_ms IS NOT NULL '
            'AND l.local_date BETWEEN ? AND ? '
            'GROUP BY l.activity_type_id, l.local_date ORDER BY l.local_date',
            variables: [Variable(from.toIso()), Variable(to.toIso())],
            readsFrom: {_db.activityLogs, _db.activityTypes},
          )
          .get();
      return [
        for (final r in rows)
          ActivityDayTime(
            ActivityTypeId(r.read<String>('id')),
            LocalDate.parse(r.read<String>('d')),
            r.read<int>('ms'),
          ),
      ];
    }),
  );

  @override
  Stream<List<PlanDay>> watchPlanAdherence(LocalDate from, LocalDate today) =>
      guardStorageStream(
        'watchPlanAdherence',
        _watch(() async {
          // Done: marked done, or logged on a day that has passed (ADR-040).
          const done =
              "(p.status = 'completed' OR (p.plan_date < ?3 AND EXISTS ("
              'SELECT 1 FROM activity_logs pl WHERE pl.plan_id = p.internal_id '
              'AND pl.deleted_at IS NULL)))';
          final rows = await _db
              .customSelect(
                'SELECT p.plan_date AS d, COUNT(*) AS n, '
                'SUM(CASE WHEN $done THEN 1 ELSE 0 END) AS k FROM plans p '
                'WHERE p.deleted_at IS NULL '
                "AND p.status NOT IN ('skipped', 'cancelled') "
                'AND p.plan_date BETWEEN ?1 AND ?2 '
                'AND (p.plan_date < ?3 OR $done) '
                'GROUP BY p.plan_date ORDER BY p.plan_date',
                variables: [
                  Variable(from.toIso()),
                  Variable(today.toIso()),
                  Variable(today.toIso()),
                ],
                readsFrom: {_db.plans, _db.activityLogs},
              )
              .get();
          return [
            for (final r in rows)
              PlanDay(
                LocalDate.parse(r.read<String>('d')),
                planned: r.read<int>('n'),
                done: r.read<int>('k'),
              ),
          ];
        }),
      );

  @override
  Stream<Map<ActivityTypeId, Set<LocalDate>>> watchActiveDays() =>
      guardStorageStream(
        'watchActiveDays',
        _watch(() async {
          final rows = await _db
              .customSelect(
                'SELECT DISTINCT t.public_id AS id, l.local_date AS d '
                'FROM activity_logs l '
                'JOIN activity_types t ON t.internal_id = l.activity_type_id '
                'WHERE l.deleted_at IS NULL AND ${_counts('l')}',
                readsFrom: {_db.activityLogs, _db.activityTypes},
              )
              .get();
          final days = <ActivityTypeId, Set<LocalDate>>{};
          for (final r in rows) {
            days
                .putIfAbsent(ActivityTypeId(r.read<String>('id')), () => {})
                .add(LocalDate.parse(r.read<String>('d')));
          }
          return days;
        }),
      );

  @override
  Stream<List<List<String>>> watchChoicePicks(
    ActivityFieldId fieldId,
    LocalDate from,
    LocalDate to,
  ) => guardStorageStream(
    'watchChoicePicks',
    _watch(() async {
      final rows = await _db
          .customSelect(
            'SELECT v.text_value AS one, v.json_value AS many '
            'FROM log_values v JOIN activity_logs l ON l.internal_id = v.log_id '
            'WHERE v.field_id = $_field AND l.deleted_at IS NULL '
            'AND l.local_date BETWEEN ? AND ?',
            variables: [
              Variable(fieldId.value),
              Variable(from.toIso()),
              Variable(to.toIso()),
            ],
            readsFrom: {_db.logValues, _db.activityLogs},
          )
          .get();
      return [
        for (final r in rows)
          if (r.readNullable<String>('one') case final one?)
            [one]
          else
            _optionIds(r.readNullable<String>('many')),
      ];
    }),
  );

  /// Option IDs of a stored multi-select value (ADR-019).
  static List<String> _optionIds(String? json) {
    if (json == null) return const [];
    try {
      final decoded = jsonDecode(json);
      final ids = decoded is Map ? decoded['optionIds'] : null;
      return [
        if (ids is List)
          for (final id in ids)
            if (id is String) id,
      ];
    } on FormatException {
      return const [];
    }
  }

  @override
  Stream<List<int>> watchStartMinutes(
    ActivityTypeId typeId,
    LocalDate from,
    LocalDate to,
  ) => guardStorageStream(
    'watchStartMinutes',
    _watch(() async {
      final rows = await _db
          .customSelect(
            // Local minute of the day: UTC ms + the offset when recorded.
            'SELECT ((l.started_at / 60000 + l.tz_offset_minutes) % 1440 '
            '+ 1440) % 1440 AS m FROM activity_logs l '
            'WHERE l.activity_type_id = $_type AND l.deleted_at IS NULL '
            'AND l.local_date BETWEEN ? AND ? AND ${_counts('l')}',
            variables: [
              Variable(typeId.value),
              Variable(from.toIso()),
              Variable(to.toIso()),
            ],
            readsFrom: {_db.activityLogs},
          )
          .get();
      return [for (final r in rows) r.read<int>('m')];
    }),
  );

  @override
  Stream<Map<ActivityFieldId, List<String>>> watchRowNames(
    ActivityTypeId typeId,
    LocalDate from,
    LocalDate to,
  ) => guardStorageStream(
    'watchRowNames',
    _watch(() async {
      final rows = await _db
          .customSelect(
            'SELECT f.public_id AS f, MIN(v.text_value) AS t, COUNT(*) AS n '
            'FROM log_values v '
            'JOIN activity_fields f ON f.internal_id = v.field_id '
            'JOIN activity_logs l ON l.internal_id = v.log_id '
            "WHERE l.activity_type_id = $_type AND f.field_type = 'text' "
            'AND f.parent_field_id IS NOT NULL AND l.deleted_at IS NULL '
            'AND v.text_value IS NOT NULL AND l.local_date BETWEEN ? AND ? '
            'GROUP BY f.public_id, v.text_value COLLATE NOCASE '
            'ORDER BY n DESC, MAX(l.local_date) DESC',
            variables: [
              Variable(typeId.value),
              Variable(from.toIso()),
              Variable(to.toIso()),
            ],
            readsFrom: {_db.logValues, _db.activityFields, _db.activityLogs},
          )
          .get();
      final names = <ActivityFieldId, List<String>>{};
      for (final r in rows) {
        names
            .putIfAbsent(ActivityFieldId(r.read<String>('f')), () => [])
            .add(r.read<String>('t'));
      }
      return names;
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
