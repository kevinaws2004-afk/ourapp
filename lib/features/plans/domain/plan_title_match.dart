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
