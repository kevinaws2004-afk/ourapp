/// The app's color themes: one product, several palettes, each in light and
/// dark. The stored value is [name], so shown names can change without
/// touching saved preferences; never rename a value. Declaration order is
/// the order Appearance shows them in.
enum AppThemeId {
  lavender,
  rose,
  papaya,
  ocean,
  matcha,
  lilac,
  sky,
  honey,
  slate,
  mint,
  cherry,
  forest,
  midnight,
  mocha,
  roseGold;

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
