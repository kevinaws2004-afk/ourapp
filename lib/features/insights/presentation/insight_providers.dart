import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/ids/id_generator_provider.dart';
import '../../../core/time/clock_provider.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../plans/presentation/plan_date_notifier.dart';
import '../data/db_insight_repository.dart';
import '../domain/insight.dart';
import '../domain/insight_repository.dart';
import '../domain/insight_use_cases.dart';

final insightRepositoryProvider = Provider<InsightRepository>(
  (ref) => DbInsightRepository(ref.watch(appDatabaseProvider)),
);

/// The range shown on the Insights tab (kept while the app runs).
final insightRangeProvider =
    NotifierProvider<InsightRangeNotifier, InsightRange>(
      InsightRangeNotifier.new,
    );

class InsightRangeNotifier extends Notifier<InsightRange> {
  @override
  InsightRange build() => InsightRange.month;

  void select(InsightRange range) => state = range;
}

final insightChartsProvider =
    StreamProvider.autoDispose<List<InsightChartConfig>>(
      (ref) => ref.watch(insightRepositoryProvider).watchCharts(),
    );

/// A chart's result for the selected range.
final insightResultProvider = StreamProvider.autoDispose
    .family<InsightResult, InsightChartConfig>((ref, chart) {
      final range = ref.watch(insightRangeProvider);
      final today = currentLocalDate(ref.watch(clockProvider));
      return WatchInsight(ref.watch(insightRepositoryProvider))(
        chart,
        range,
        today,
      );
    });

/// Per-activity totals for the selected range and the one before it.
final activityTotalsProvider =
    StreamProvider.autoDispose<
      (Map<ActivityTypeId, ActivityTotals>, Map<ActivityTypeId, ActivityTotals>)
    >((ref) {
      final range = ref.watch(insightRangeProvider);
      final today = currentLocalDate(ref.watch(clockProvider));
      final repo = ref.watch(insightRepositoryProvider);
      final (from, to) = range.window(today);
      final (prevFrom, prevTo) = range.previous(today);
      return repo
          .watchActivityTotals(from, to)
          .asyncExpand(
            (current) => repo
                .watchActivityTotals(prevFrom, prevTo)
                .map((previous) => (current, previous)),
          );
    });

final saveInsightChartProvider = Provider(
  (ref) => SaveInsightChart(
    ref.watch(insightRepositoryProvider),
    ref.watch(idGeneratorProvider),
    ref.watch(clockProvider),
  ),
);

final deleteInsightChartProvider = Provider(
  (ref) => DeleteInsightChart(
    ref.watch(insightRepositoryProvider),
    ref.watch(clockProvider),
  ),
);
