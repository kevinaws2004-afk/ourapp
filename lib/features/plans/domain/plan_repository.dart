import '../../../core/time/local_date.dart';
import 'plan.dart';
import 'plan_series.dart';

/// Persistence for plans (ADR-018). Default reads exclude deleted plans
/// (ADR-022). Throws only `AppException`s.
abstract interface class PlanRepository {
  /// A date's plans (`idx_plans_day`), unordered for display; see
  /// [orderPlans].
  Stream<List<Plan>> watchPlansForDay(LocalDate date);

  Future<Plan?> getPlan(PlanId id);

  /// The sort order after the date's last plan.
  Future<int> nextSortOrder(LocalDate date);

  /// Whether any non-deleted record fulfils the plan.
  Future<bool> hasRecords(PlanId id);

  Future<void> create(Plan plan);

  /// Writes every property of [plan] (title, date, times, order, status…).
  Future<void> update(Plan plan);

  /// Rewrites `sort_order` of [order] (plans of one date) to 0..n-1, in one
  /// transaction.
  Future<void> reorder(List<PlanId> order, DateTime updatedAt);

  Future<void> softDelete(PlanId id);

  Future<void> restore(PlanId id);

  /// Plans dated [from]..[to] inclusive (`idx_plans_day`), for the week and
  /// month planner.
  Stream<List<Plan>> watchPlansForRange(LocalDate from, LocalDate to);

  // Repeating plans (ADR-036).

  Future<void> createSeries(PlanSeries series);

  Future<PlanSeries?> getSeries(PlanSeriesId id);

  /// Active series with possible occurrences between [from] and [to].
  Future<List<PlanSeries>> seriesBetween(LocalDate from, LocalDate to);

  /// Sets (or clears) the last date a series repeats on.
  Future<void> setSeriesEnd(PlanSeriesId id, LocalDate? end, DateTime now);

  Future<void> deleteSeries(PlanSeriesId id, DateTime now);

  /// Makes an existing plan an occurrence of [seriesId].
  Future<void> linkToSeries(PlanId id, PlanSeriesId seriesId);

  /// Creates an occurrence unless its series already has one on that date
  /// (deleted ones included, so a deleted occurrence stays deleted). Returns
  /// whether it was created.
  Future<bool> createOccurrence(Plan plan);

  /// Soft-deletes the series' occurrences on or after [from] that are still
  /// open (planned, nothing logged). Returns them.
  Future<List<PlanId>> deleteOpenOccurrences(
    PlanSeriesId id,
    LocalDate from,
    DateTime now,
  );
}
