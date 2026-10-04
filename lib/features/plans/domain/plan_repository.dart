import '../../../core/time/local_date.dart';
import 'plan.dart';

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
}
