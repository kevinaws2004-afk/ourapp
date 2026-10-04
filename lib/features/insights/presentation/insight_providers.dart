import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/async/combine_latest.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/ids/id_generator_provider.dart';
import '../../../core/time/clock_provider.dart';
import '../../activity_logs/presentation/activity_log_providers.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/domain/field_type.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../../plans/presentation/plan_date_notifier.dart';
import '../data/db_insight_repository.dart';
import '../domain/auto_insights.dart';
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
      // Both stay live (A20): asyncExpand used to wait on the inner stream
      // forever, so the list stopped updating after its first value.
      return combineLatest2(
        repo.watchActivityTotals(from, to),
        repo.watchActivityTotals(prevFrom, prevTo),
        (current, previous) => (current, previous),
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

/// An activity's automatic charts (ADR-037), from its fields and the list
/// row names logged so far (e.g. each exercise).
final autoChartsProvider = FutureProvider.autoDispose
    .family<List<AutoChart>, ActivityTypeId>((ref, typeId) async {
      final type = await ref.watch(activityTypeProvider(typeId).future);
      if (type == null) return const [];
      final logs = ref.watch(activityLogRepositoryProvider);
      final rowNames = <ActivityFieldId, List<String>>{
        for (final field in type.fields)
          if (field.parentId != null &&
              !field.isRemoved &&
              field.type == FieldType.text)
            field.id: await logs.textSuggestions(field.id, limit: 8),
      };
      return autoChartsFor(type, rowNames);
    });
