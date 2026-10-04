import '../../activity_types/domain/activity_ids.dart';
import 'plan.dart';

/// Orders [items] by how much they're used in [plans] (A7): most plans
/// first, ties broken by the latest plan date. Items that aren't used keep
/// their given order, after the used ones.
List<T> rankByUse<T>(
  Iterable<T> items,
  Iterable<Plan> plans,
  ActivityTypeId Function(T) idOf,
) {
  final counts = <ActivityTypeId, int>{};
  final latest = <ActivityTypeId, String>{};
  for (final plan in plans) {
    final id = plan.activityTypeId;
    if (id == null) continue;
    counts[id] = (counts[id] ?? 0) + 1;
    final date = plan.planDate.toIso();
    if ((latest[id] ?? '').compareTo(date) < 0) latest[id] = date;
  }
  final list = items.toList();
  final position = {for (var i = 0; i < list.length; i++) idOf(list[i]): i};
  return list..sort((a, b) {
    final byCount = (counts[idOf(b)] ?? 0).compareTo(counts[idOf(a)] ?? 0);
    if (byCount != 0) return byCount;
    final byDate = (latest[idOf(b)] ?? '').compareTo(latest[idOf(a)] ?? '');
    if (byDate != 0) return byDate;
    return position[idOf(a)]!.compareTo(position[idOf(b)]!);
  });
}
