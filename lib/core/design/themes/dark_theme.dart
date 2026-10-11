import 'package:flutter/material.dart';

import '../app_tokens.dart';
import '../tokens/activity_palette.dart';
import '../tokens/color_tokens.dart';
import '../tokens/elevation.dart';
import '../tokens/treatments.dart';

/// The dark variant of a theme, derived from its light tokens so all three
/// themes keep their personality at night: deep ink surfaces tinted with the
/// theme's signature hue, the signature and action colors lifted for
/// contrast, and activity colors as luminous solids on dim tinted wells.
///
/// With [trueBlack] the canvas is pure black (OLED: premium contrast, less
/// battery) and cards are barely lifted near-black panels.
AppTokens darkTokensFrom(AppTokens light, {bool trueBlack = false}) {
  final l = light.colors;
  final hue = HSLColor.fromColor(l.brandPrimary).hue;

  // Ink surfaces carry a trace of the theme's hue.
  Color ink(double lightness, {double saturation = 0.22}) =>
      HSLColor.fromAHSL(1, hue, saturation, lightness).toColor();

  final canvas = trueBlack ? const Color(0xFF000000) : ink(0.065);
  final base = trueBlack ? ink(0.045, saturation: 0.12) : ink(0.095);
  final raised = trueBlack ? ink(0.075, saturation: 0.12) : ink(0.125);
  final sunken = trueBlack
      ? ink(0.09, saturation: 0.12)
      : ink(0.14, saturation: 0.18);

  final brand = _lift(l.brandPrimary, 0.72);
  final action = _lift(l.action, 0.56, saturation: 0.62);
  final accent = _lift(l.accent, 0.72);

  Color soft(Color c, [double alpha = 0.20]) =>
      Color.alphaBlend(c.withValues(alpha: alpha), base);

  final colors = AppColors(
    surfaceCanvas: canvas,
    surfaceBase: base,
    surfaceRaised: raised,
    surfaceSunken: sunken,
    borderSubtle: ink(0.17, saturation: 0.16),
    borderStrong: ink(0.52, saturation: 0.10),
    textPrimary: ink(0.95, saturation: 0.30),
    textSecondary: ink(0.76, saturation: 0.14),
    textTertiary: ink(0.58, saturation: 0.10),
    brandPrimary: brand,
    onBrandPrimary: ink(0.08),
    brandPrimarySoft: soft(brand, 0.18),
    onBrandPrimarySoft: _lift(l.brandPrimary, 0.84),
    action: action,
    onAction: ink(0.07),
    actionSoft: soft(action, 0.16),
    onActionSoft: _lift(l.action, 0.80),
    accent: accent,
    accentSoft: soft(accent, 0.16),
    onAccentSoft: _lift(l.accent, 0.84),
    accentDawn: const Color(0xFFFBBF24),
    scrim: const Color(0xB3000000),
    success: _lift(l.success, 0.60),
    successContainer: soft(l.success, 0.22),
    warning: _lift(l.warning, 0.66),
    warningContainer: soft(l.warning, 0.20),
    danger: const Color(0xFFFB7185),
    dangerContainer: soft(l.danger, 0.24),
  );

  return AppTokens(
    id: light.id,
    colors: colors,
    shadows: AppShadows(
      card: const [
        BoxShadow(
          color: Color(0x33000000),
          offset: Offset(0, 6),
          blurRadius: 18,
          spreadRadius: -6,
        ),
      ],
      floating: const [
        BoxShadow(
          color: Color(0x66000000),
          offset: Offset(0, 16),
          blurRadius: 36,
          spreadRadius: -8,
        ),
      ],
      glowAlpha: light.shadows.glowAlpha * 0.7,
    ),
    treatments: AppTreatments(
      cardEdge: CardEdge.hairline,
      navStyle: light.treatments.navStyle,
      progressGradient: [
        for (final c in light.treatments.progressGradient) _lift(c, 0.66),
      ],
      heroWash: soft(brand, 0.22),
      factsAsChips: light.treatments.factsAsChips,
      timeColumn: light.treatments.timeColumn,
    ),
    palette: light.palette.map(
      (c) => ActivityColors(solid: _lift(c.solid, 0.68), soft: soft(c.solid)),
    ),
    brightness: Brightness.dark,
  );
}

/// [color] at (at least) [lightness], keeping its hue and most of its
/// saturation, so it reads on dark surfaces.
Color _lift(Color color, double lightness, {double saturation = 0.92}) {
  final hsl = HSLColor.fromColor(color);
  return hsl
      .withLightness(hsl.lightness < lightness ? lightness : hsl.lightness)
      .withSaturation((hsl.saturation * saturation).clamp(0, 1))
      .toColor();
}
