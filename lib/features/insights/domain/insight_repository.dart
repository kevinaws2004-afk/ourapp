import '../../../core/time/local_date.dart';
import '../../activity_types/domain/activity_ids.dart';
import 'insight.dart';

/// Totals of one activity over a period.
class ActivityTotals {
  const ActivityTotals({required this.durationMs, required this.count});

  final int durationMs;
  final int count;
}

/// Read model for Insights (FR-AN-*) plus the saved charts. Streams update
/// when the underlying records, plans or measurements change. Throws only
/// `AppException`s.
abstract interface class InsightRepository {
  /// All points of [source] (any [InsightSource] except
  /// [PlannedVsActualSource]), oldest first.
  Stream<List<DataPoint>> watchPoints(InsightSource source);

  /// Planned lengths and recorded times of plans by plan date, in ms.
  Stream<(List<DataPoint> planned, List<DataPoint> actual)>
  watchPlannedVsActual(ActivityTypeId? typeId);

  /// Per-activity recorded time and count over `[from, to]`.
  Stream<Map<ActivityTypeId, ActivityTotals>> watchActivityTotals(
    LocalDate from,
    LocalDate to,
  );

  Stream<List<InsightChartConfig>> watchCharts();

  /// Inserts or replaces a chart (by ID); new charts go last.
  Future<void> saveChart(InsightChartConfig chart, DateTime now);

  Future<void> deleteChart(InsightChartId id, DateTime now);
}
