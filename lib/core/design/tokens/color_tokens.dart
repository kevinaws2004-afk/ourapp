import 'package:flutter/material.dart';

/// Raw palette (private). Neutrals are the provisional v0 base (ADR-016);
/// every other color is an activity-palette color (ADR-029). Feature code uses
/// [AppColors] roles, never these.
abstract final class _Palette {
  // Light neutrals ("Linen").
  static const linenCanvas = Color(0xFFF5F1EA);
  static const linenBase = Color(0xFFFBF8F3);
  static const linenRaised = Color(0xFFFFFDF9);
  static const linenSunken = Color(0xFFECE6DB);
  static const linenBorderSubtle = Color(0xFFE2DACB);
  static const linenBorderStrong = Color(0xFF8C8270);
  static const inkPrimary = Color(0xFF1F1D2B);
  static const inkSecondary = Color(0xFF5E5A6B);
  static const inkTertiary = Color(0xFF8A8595);

  // Dark neutrals ("Night ink").
  static const nightCanvas = Color(0xFF12141B);
  static const nightBase = Color(0xFF1A1D26);
  static const nightRaised = Color(0xFF232735);
  static const nightSunken = Color(0xFF0D0F14);
  static const nightBorderSubtle = Color(0xFF2C3040);
  static const nightBorderStrong = Color(0xFF6E7488);
  static const paperPrimary = Color(0xFFF1EEE8);
  static const paperSecondary = Color(0xFFB4B0BE);
  static const paperTertiary = Color(0xFF86839A);

  // Every non-neutral color comes from the activity palette (ADR-029):
  // brand = teal, accent = apricot, success = moss, warning = apricot,
  // danger = rose. Values must stay identical to activity_palette.dart.
  static const tealSolidLight = Color(0xFF2F8180);
  static const tealSolidDark = Color(0xFF7CCBC8);
  static const tealSoftLight = Color(0xFFDDF0EF);
  static const tealSoftDark = Color(0xFF162B2B);
  static const white = Color(0xFFFFFFFF);
  static const apricotSolidLight = Color(0xFFB8642F);
  static const apricotSolidDark = Color(0xFFF2A877);

  // Status.
  static const mossSolidLight = Color(0xFF6B7A2E);
  static const mossSolidDark = Color(0xFFB8C87A);
  static const mossSoftLight = Color(0xFFEDF0DA);
  static const mossSoftDark = Color(0xFF262A17);
  static const apricotSoftLight = Color(0xFFFBE9DC);
  static const apricotSoftDark = Color(0xFF33231A);
  static const roseSolidLight = Color(0xFFB04E62);
  static const roseSolidDark = Color(0xFFEE9AAA);
  static const roseSoftLight = Color(0xFFF8E3E7);
  static const roseSoftDark = Color(0xFF331E24);

  // Scrims.
  static const scrimLight = Color(0x661F1D2B); // ink @ 40%
  static const scrimDark = Color(0x99000000); // black @ 60%
}

/// Semantic color roles (design_system.md §2.2–2.3). Theme-aware.
@immutable
class AppColors {
  const AppColors({
    required this.surfaceCanvas,
    required this.surfaceBase,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.borderSubtle,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.brandPrimary,
    required this.onBrandPrimary,
    required this.brandPrimarySoft,
    required this.onBrandPrimarySoft,
    required this.accentDawn,
    required this.scrim,
    required this.success,
    required this.successContainer,
    required this.warning,
    required this.warningContainer,
    required this.danger,
    required this.dangerContainer,
  });

  static const light = AppColors(
    surfaceCanvas: _Palette.linenCanvas,
    surfaceBase: _Palette.linenBase,
    surfaceRaised: _Palette.linenRaised,
    surfaceSunken: _Palette.linenSunken,
    borderSubtle: _Palette.linenBorderSubtle,
    borderStrong: _Palette.linenBorderStrong,
    textPrimary: _Palette.inkPrimary,
    textSecondary: _Palette.inkSecondary,
    textTertiary: _Palette.inkTertiary,
    brandPrimary: _Palette.tealSolidLight,
    onBrandPrimary: _Palette.white,
    brandPrimarySoft: _Palette.tealSoftLight,
    onBrandPrimarySoft: _Palette.inkPrimary,
    accentDawn: _Palette.apricotSolidLight,
    scrim: _Palette.scrimLight,
    success: _Palette.mossSolidLight,
    successContainer: _Palette.mossSoftLight,
    warning: _Palette.apricotSolidLight,
    warningContainer: _Palette.apricotSoftLight,
    danger: _Palette.roseSolidLight,
    dangerContainer: _Palette.roseSoftLight,
  );

  static const dark = AppColors(
    surfaceCanvas: _Palette.nightCanvas,
    surfaceBase: _Palette.nightBase,
    surfaceRaised: _Palette.nightRaised,
    surfaceSunken: _Palette.nightSunken,
    borderSubtle: _Palette.nightBorderSubtle,
    borderStrong: _Palette.nightBorderStrong,
    textPrimary: _Palette.paperPrimary,
    textSecondary: _Palette.paperSecondary,
    textTertiary: _Palette.paperTertiary,
    brandPrimary: _Palette.tealSolidDark,
    onBrandPrimary: _Palette.nightCanvas,
    brandPrimarySoft: _Palette.tealSoftDark,
    onBrandPrimarySoft: _Palette.paperPrimary,
    accentDawn: _Palette.apricotSolidDark,
    scrim: _Palette.scrimDark,
    success: _Palette.mossSolidDark,
    successContainer: _Palette.mossSoftDark,
    warning: _Palette.apricotSolidDark,
    warningContainer: _Palette.apricotSoftDark,
    danger: _Palette.roseSolidDark,
    dangerContainer: _Palette.roseSoftDark,
  );

  final Color surfaceCanvas;
  final Color surfaceBase;
  final Color surfaceRaised;
  final Color surfaceSunken;

  /// Decorative only (hairlines); below 3:1 by design.
  final Color borderSubtle;

  /// Input outlines and meaningful boundaries (≥ 3:1).
  final Color borderStrong;
  final Color textPrimary;
  final Color textSecondary;

  /// Placeholders, disabled, large decorative text. Not for small essential
  /// text in light mode.
  final Color textTertiary;
  final Color brandPrimary;
  final Color onBrandPrimary;
  final Color brandPrimarySoft;
  final Color onBrandPrimarySoft;

  /// Apricot accent (rating stars, highlights). Graphics only; never small text.
  final Color accentDawn;
  final Color scrim;

  /// Moss. Icons/fills on [successContainer]; never small text (below 4.5:1).
  final Color success;
  final Color successContainer;

  /// Apricot. Icons/fills on [warningContainer]; never small text (below 4.5:1).
  final Color warning;
  final Color warningContainer;

  /// Rose. Meets 4.5:1 on the canvas, so it may be used for error text.
  final Color danger;
  final Color dangerContainer;

  Color get info => brandPrimary;
  Color get infoContainer => brandPrimarySoft;

  static AppColors lerp(AppColors a, AppColors b, double t) {
    Color l(Color x, Color y) => Color.lerp(x, y, t)!;
    return AppColors(
      surfaceCanvas: l(a.surfaceCanvas, b.surfaceCanvas),
      surfaceBase: l(a.surfaceBase, b.surfaceBase),
      surfaceRaised: l(a.surfaceRaised, b.surfaceRaised),
      surfaceSunken: l(a.surfaceSunken, b.surfaceSunken),
      borderSubtle: l(a.borderSubtle, b.borderSubtle),
      borderStrong: l(a.borderStrong, b.borderStrong),
      textPrimary: l(a.textPrimary, b.textPrimary),
      textSecondary: l(a.textSecondary, b.textSecondary),
      textTertiary: l(a.textTertiary, b.textTertiary),
      brandPrimary: l(a.brandPrimary, b.brandPrimary),
      onBrandPrimary: l(a.onBrandPrimary, b.onBrandPrimary),
      brandPrimarySoft: l(a.brandPrimarySoft, b.brandPrimarySoft),
      onBrandPrimarySoft: l(a.onBrandPrimarySoft, b.onBrandPrimarySoft),
      accentDawn: l(a.accentDawn, b.accentDawn),
      scrim: l(a.scrim, b.scrim),
      success: l(a.success, b.success),
      successContainer: l(a.successContainer, b.successContainer),
      warning: l(a.warning, b.warning),
      warningContainer: l(a.warningContainer, b.warningContainer),
      danger: l(a.danger, b.danger),
      dangerContainer: l(a.dangerContainer, b.dangerContainer),
    );
  }
}
