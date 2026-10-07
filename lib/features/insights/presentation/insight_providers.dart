import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/async/combine_latest.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/ids/id_generator_provider.dart';
import '../../../core/time/clock_provider.dart';
import '../../../core/time/local_date.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../../plans/presentation/plan_date_notifier.dart';
import '../../plans/presentation/plan_providers.dart';
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

/// The selected range's `[from, to]` and the period before it.
({LocalDate from, LocalDate to, LocalDate prevFrom, LocalDate prevTo}) _periods(
  Ref ref,
) {
  final range = ref.watch(insightRangeProvider);
  final today = currentLocalDate(ref.watch(clockProvider));
  final (from, to) = range.window(today);
  final (prevFrom, prevTo) = range.previous(today);
  return (from: from, to: to, prevFrom: prevFrom, prevTo: prevTo);
}

/// A chart's result for the selected range. "Best" follows the charted
/// field's "better is" (ADR-043); planned vs actual first makes sure
/// repeating plans have their occurrences in the period (A5).
final insightResultProvider = StreamProvider.autoDispose
    .family<InsightResult, InsightChartConfig>((ref, chart) async* {
      final range = ref.watch(insightRangeProvider);
      final today = currentLocalDate(ref.watch(clockProvider));
      var bestIs = BestIs.highest;
      switch (chart.source) {
        case FieldValueSource(:final typeId, :final fieldId):
          final type = await ref.watch(activityTypeProvider(typeId).future);
          if (type?.fieldById(fieldId) case final field?) {
            bestIs = bestIsFor(field);
          }
        case PlannedVsActualSource():
          await ref.read(ensureSeriesOccurrencesProvider)(
            range.loadFrom(today, range.fit(chart.bucket)),
            today,
          );
        default:
      }
      yield* WatchInsight(ref.watch(insightRepositoryProvider))(
        chart,
        range,
        today,
        bestIs: bestIs,
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

/// An activity's automatic page: its charts and choice breakdowns, from
/// its fields and the list row names used in the period, most used first
/// (ADR-037, C1); live, so a newly logged exercise shows up at once (C2).
/// [showAll] lists every row name instead of the top six (C3).
final autoChartsProvider = StreamProvider.autoDispose
    .family<
      ({List<AutoChart> charts, List<AutoBreakdown> breakdowns, bool hasMore}),
      ({ActivityTypeId typeId, bool showAll})
    >((ref, args) async* {
      final type = await ref.watch(activityTypeProvider(args.typeId).future);
      if (type == null) {
        yield (charts: const [], breakdowns: const [], hasMore: false);
        return;
      }
      final p = _periods(ref);
      yield* ref
          .watch(insightRepositoryProvider)
          .watchRowNames(args.typeId, p.from, p.to)
          .map(
            (names) => (
              charts: autoChartsFor(
                type,
                names,
                maxRows: args.showAll ? null : 6,
              ),
              breakdowns: autoBreakdownsFor(type),
              hasMore: hasMoreRows(type, names),
            ),
          );
    });

/// Records done per day in the range, for one activity or all (the
/// consistency calendar).
final dayCountsProvider = StreamProvider.autoDispose
    .family<Map<LocalDate, int>, ActivityTypeId?>((ref, typeId) {
      final p = _periods(ref);
      return ref
          .watch(insightRepositoryProvider)
          .watchDayCounts(typeId, p.from, p.to);
    });

/// The range at a glance against the period before (H5): days active,
/// recorded time and records done.
final insightSummaryProvider = StreamProvider.autoDispose<InsightSummary>((
  ref,
) {
  final p = _periods(ref);
  final repo = ref.watch(insightRepositoryProvider);
  return combineLatest2(
    combineLatest2(
      repo.watchDayCounts(null, p.from, p.to),
      repo.watchDayCounts(null, p.prevFrom, p.prevTo),
      (now, before) => (now, before),
    ),
    combineLatest2(
      repo.watchActivityTotals(p.from, p.to),
      repo.watchActivityTotals(p.prevFrom, p.prevTo),
      (now, before) => (now, before),
    ),
    (days, totals) => InsightSummary.of(days.$1, days.$2, totals.$1, totals.$2),
  );
});

/// Recorded time per activity and day in the range (where the time went).
final timeByActivityProvider =
    StreamProvider.autoDispose<List<ActivityDayTime>>((ref) {
      final p = _periods(ref);
      return ref
          .watch(insightRepositoryProvider)
          .watchTimeByActivity(p.from, p.to);
    });

/// Plans per day over the range and the one before (plan vs reality),
/// with repeating plans' occurrences made first (A5).
final planAdherenceProvider = StreamProvider.autoDispose<List<PlanDay>>((
  ref,
) async* {
  final p = _periods(ref);
  final today = currentLocalDate(ref.watch(clockProvider));
  await ref.read(ensureSeriesOccurrencesProvider)(p.prevFrom, today);
  yield* ref
      .watch(insightRepositoryProvider)
      .watchPlanAdherence(p.prevFrom, today);
});

/// Every day each activity was done on (streaks, and which activities have
/// any history at all).
final activeDaysProvider =
    StreamProvider.autoDispose<Map<ActivityTypeId, Set<LocalDate>>>(
      (ref) => ref.watch(insightRepositoryProvider).watchActiveDays(),
    );

/// The options picked in a choice field over the range.
final choicePicksProvider = StreamProvider.autoDispose
    .family<List<List<String>>, ActivityFieldId>((ref, fieldId) {
      final p = _periods(ref);
      return ref
          .watch(insightRepositoryProvider)
          .watchChoicePicks(fieldId, p.from, p.to);
    });

/// When an activity's records started over the range (local minutes).
final startMinutesProvider = StreamProvider.autoDispose
    .family<List<int>, ActivityTypeId>((ref, typeId) {
      final p = _periods(ref);
      return ref
          .watch(insightRepositoryProvider)
          .watchStartMinutes(typeId, p.from, p.to);
    });
