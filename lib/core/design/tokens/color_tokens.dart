import 'package:flutter/material.dart';

/// Raw palette (private). The app uses only white shades, the brand mist
/// #DDF0EF and six activity-palette colors: sky, lilac, teal, rose, slate,
/// coral (ADR-029, ADR-038). Neutrals are white shades and slate shades (text,
/// borders, dark surfaces). Feature code uses [AppColors] roles, never these.
abstract final class _Palette {
  // Light neutrals: white shades + mist.
  static const white = Color(0xFFFFFFFF);
  static const whiteCanvas = Color(0xFFF7FBFB);
  static const mist = Color(0xFFDDF0EF); // = teal soft (light)
  static const slateHairline = Color(0xFFE6E9EF); // = slate soft (light)
  static const slateStrong = Color(0xFF5D6A80); // = slate solid (light)
  static const slateInk = Color(0xFF252C3A);
  static const slateInkSecondary = Color(0xFF515D72);
  static const slateInkTertiary = Color(0xFF7F889C);

  // Dark neutrals: deep slate shades + white shades for text.
  static const slateNightCanvas = Color(0xFF13171E);
  static const slateNightBase = Color(0xFF1A1F28);
  static const slateNightRaised = Color(0xFF232935);
  static const slateNightSunken = Color(0xFF0E1116);
  static const slateNightBorderSubtle = Color(0xFF2A313E);
  static const slateNightBorderStrong = Color(0xFF6F7A8F);
  static const whitePrimary = Color(0xFFF4FAF9);
  static const slateLight = Color(0xFFA8B3C7); // = slate solid (dark)
  static const slateLightTertiary = Color(0xFF808AA0);

  // Every non-neutral color comes from the activity palette (ADR-029):
  // brand = teal, accent = coral, success = teal, warning = coral,
  // danger = rose. Values must stay identical to activity_palette.dart.
  static const tealSolidLight = Color(0xFF2F8180);
  static const tealSolidDark = Color(0xFF7CCBC8);
  static const tealSoftLight = mist;
  static const tealSoftDark = Color(0xFF162B2B);
  static const coralSolidLight = Color(0xFFC0503E);
  static const coralSolidDark = Color(0xFFF29A89);
  static const coralSoftLight = Color(0xFFFBE4DF);
  static const coralSoftDark = Color(0xFF341E1A);
  static const roseSolidLight = Color(0xFFB04E62);
  static const roseSolidDark = Color(0xFFEE9AAA);
  static const roseSoftLight = Color(0xFFF8E3E7);
  static const roseSoftDark = Color(0xFF331E24);

  // Scrims.
  static const scrimLight = Color(0x66252C3A); // slate ink @ 40%
  static const scrimDark = Color(0x990E1116); // slate night @ 60%
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
    surfaceCanvas: _Palette.whiteCanvas,
    surfaceBase: _Palette.white,
    surfaceRaised: _Palette.white,
    surfaceSunken: _Palette.mist,
    borderSubtle: _Palette.slateHairline,
    borderStrong: _Palette.slateStrong,
    textPrimary: _Palette.slateInk,
    textSecondary: _Palette.slateInkSecondary,
    textTertiary: _Palette.slateInkTertiary,
    brandPrimary: _Palette.tealSolidLight,
    onBrandPrimary: _Palette.white,
    brandPrimarySoft: _Palette.tealSoftLight,
    onBrandPrimarySoft: _Palette.slateInk,
    accentDawn: _Palette.coralSolidLight,
    scrim: _Palette.scrimLight,
    success: _Palette.tealSolidLight,
    successContainer: _Palette.tealSoftLight,
    warning: _Palette.coralSolidLight,
    warningContainer: _Palette.coralSoftLight,
    danger: _Palette.roseSolidLight,
    dangerContainer: _Palette.roseSoftLight,
  );

  static const dark = AppColors(
    surfaceCanvas: _Palette.slateNightCanvas,
    surfaceBase: _Palette.slateNightBase,
    surfaceRaised: _Palette.slateNightRaised,
    surfaceSunken: _Palette.slateNightSunken,
    borderSubtle: _Palette.slateNightBorderSubtle,
    borderStrong: _Palette.slateNightBorderStrong,
    textPrimary: _Palette.whitePrimary,
    textSecondary: _Palette.slateLight,
    textTertiary: _Palette.slateLightTertiary,
    brandPrimary: _Palette.tealSolidDark,
    onBrandPrimary: _Palette.slateNightCanvas,
    brandPrimarySoft: _Palette.tealSoftDark,
    onBrandPrimarySoft: _Palette.whitePrimary,
    accentDawn: _Palette.coralSolidDark,
    scrim: _Palette.scrimDark,
    success: _Palette.tealSolidDark,
    successContainer: _Palette.tealSoftDark,
    warning: _Palette.coralSolidDark,
    warningContainer: _Palette.coralSoftDark,
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

  /// Coral accent (rating stars, highlights). Graphics only; never small text.
  final Color accentDawn;
  final Color scrim;

  /// Teal. Icons/fills on [successContainer]; never small text (below 4.5:1).
  final Color success;
  final Color successContainer;

  /// Coral. Icons/fills on [warningContainer]; never small text (below 4.5:1).
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
