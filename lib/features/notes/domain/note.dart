extension type const NoteId(String value) {}

/// A free-form note: a title and text, optionally pinned and tinted with
/// one of the activity colors.
class Note {
  const Note({
    required this.id,
    required this.title,
    required this.body,
    required this.pinned,
    required this.createdAt,
    required this.updatedAt,
    this.colorKey,
  });

  final NoteId id;
  final String title;
  final String body;

  /// An `ActivityColorKey` name, or null for the plain card.
  final String? colorKey;
  final bool pinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isEmpty => title.trim().isEmpty && body.trim().isEmpty;

  /// Does [query] appear in the title or text (any case)?
  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return title.toLowerCase().contains(q) || body.toLowerCase().contains(q);
  }
}
