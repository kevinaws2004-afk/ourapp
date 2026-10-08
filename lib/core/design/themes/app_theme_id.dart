/// The app's three light themes (ADR-045): one product, three visual
/// personalities. The names are working names; the stored value is [name],
/// so the shown names can change without touching saved preferences.
enum AppThemeId {
  rose,
  lavender,
  papaya;

  /// The theme a new install starts with.
  static const fallback = AppThemeId.lavender;

  /// The theme stored as [name], or [fallback] for anything unknown.
  static AppThemeId fromName(String? name) {
    for (final id in values) {
      if (id.name == name) return id;
    }
    return fallback;
  }
}
