/// Curated activity colors (design_system.md §2.4). The database stores the
/// key name (`color_key`), never a hex value. Pure Dart so the domain can
/// validate keys. Avoid renaming or removing keys: `sand` was removed by owner
/// decision (ADR-029), and `sage`, `apricot` and `moss` were removed when the
/// owner limited the app to six colors (ADR-038). Stored legacy keys resolve
/// through [fromName] to their replacement; any other unknown key renders with
/// the `slate` fallback until the user picks a new color.
enum ActivityColorKey {
  sky,
  lilac,
  rose,
  teal,
  coral,
  slate;

  /// Removed keys that may still be stored, and the color they now show as.
  static const Map<String, ActivityColorKey> _legacy = {
    'sage': ActivityColorKey.teal,
    'moss': ActivityColorKey.teal,
    'apricot': ActivityColorKey.coral,
  };

  static ActivityColorKey? fromName(String name) {
    for (final key in values) {
      if (key.name == name) return key;
    }
    return _legacy[name];
  }
}
