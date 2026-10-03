/// Curated activity colors (design_system.md §2.4). The database stores the
/// key name (`color_key`), never a hex value. Pure Dart so the domain can
/// validate keys. Avoid renaming or removing keys; `sand` was removed by owner
/// decision (ADR-029), and any stored unknown key renders with the `slate`
/// fallback until the user picks a new color.
enum ActivityColorKey {
  sage,
  sky,
  lilac,
  apricot,
  rose,
  teal,
  coral,
  slate,
  moss;

  static ActivityColorKey? fromName(String name) {
    for (final key in values) {
      if (key.name == name) return key;
    }
    return null;
  }
}
