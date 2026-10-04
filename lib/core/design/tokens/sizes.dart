/// Component sizes (design_system.md §6). Feature code uses these, never
/// literals, so the visual pass can retune them in one place.
abstract final class AppSizes {
  /// Minimum touch target (accessibility).
  static const double touchTarget = 48;

  // Activity badge sizes.
  static const double badgeSmall = 32;
  static const double badge = 40;
  static const double badgeLarge = 56;
  static const double badgeHero = 64;

  /// Day cell height in the Plan week strip.
  static const double dayCell = 56;

  /// One planned item on a month-calendar day.
  static const double monthDot = 6;

  /// Width of one hours/minutes box in a duration input.
  static const double durationBox = 96;

  /// Small inline icon (e.g. a lock beside a field).
  static const double iconSmall = 18;

  // Strokes.
  static const double outline = 1.5;
  static const double selectionRing = 2;
  static const double hairline = 1;

  // Charts.
  static const double chartHeight = 180;
  static const double chartLine = 2.5;
  static const double chartDot = 3;
}
