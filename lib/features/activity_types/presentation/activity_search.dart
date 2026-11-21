/// How well an activity matches a search, best first: its name exactly,
/// then starting with it, then a word of it starting with it, then
/// containing it, then its group, then one of its fields ("read" finds
/// Reading before Blood sugar's "Reading" field). Null: no match.
int? activitySearchRank(
  String query,
  String name,
  Iterable<String> details, [
  String group = '',
]) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return 0;
  final n = name.toLowerCase();
  if (n == q) return 0;
  if (n.startsWith(q)) return 1;
  if (n.split(RegExp(r'[\s\-/&]+')).any((w) => w.startsWith(q))) return 2;
  if (n.contains(q)) return 3;
  if (group.toLowerCase().contains(q)) return 4;
  if (details.any((d) => d.toLowerCase().contains(q))) return 5;
  return null;
}

/// [items] that match [query], best match first (stable within a rank).
List<T> rankBySearch<T>(
  String query,
  Iterable<T> items,
  int? Function(T item) rank,
) {
  final ranked = [
    for (final (i, item) in items.indexed)
      if (rank(item) case final r?) (r, i, item),
  ]..sort((a, b) => a.$1 != b.$1 ? a.$1 - b.$1 : a.$2 - b.$2);
  return [for (final (_, _, item) in ranked) item];
}
