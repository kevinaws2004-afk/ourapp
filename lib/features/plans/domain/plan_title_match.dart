/// The item whose name equals [title] (trimmed, case-insensitive), if any.
/// Quick add uses it so typing "Gym" plans the Gym activity instead of a
/// task with that title (ADR-030).
T? matchByName<T>(String title, Iterable<T> items, String Function(T) nameOf) {
  final wanted = title.trim().toLowerCase();
  if (wanted.isEmpty) return null;
  for (final item in items) {
    if (nameOf(item).trim().toLowerCase() == wanted) return item;
  }
  return null;
}

/// Up to [limit] of [items] whose name contains [text] (trimmed,
/// case-insensitive), names starting with it first, otherwise in the given
/// order. Quick add shows them as suggestions while typing (A6).
List<T> suggestByName<T>(
  String text,
  Iterable<T> items,
  String Function(T) nameOf, {
  int limit = 4,
}) {
  final wanted = text.trim().toLowerCase();
  if (wanted.isEmpty) return const [];
  final starting = <T>[];
  final containing = <T>[];
  for (final item in items) {
    final name = nameOf(item).trim().toLowerCase();
    if (name.startsWith(wanted)) {
      starting.add(item);
    } else if (name.contains(wanted)) {
      containing.add(item);
    }
  }
  return [...starting, ...containing].take(limit).toList();
}
