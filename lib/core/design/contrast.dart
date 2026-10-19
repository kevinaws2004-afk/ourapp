import 'package:flutter/painting.dart';

import 'app_tokens.dart';
import 'tokens/activity_palette.dart';
import 'tokens/color_tokens.dart';

/// WCAG contrast ratio between two colors (1–21).
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

/// [color] moved away from every one of [against] (darker on light
/// backgrounds, lighter on dark ones) just until it meets [ratio] with each.
/// Its hue and saturation stay, so the palette keeps its character.
Color withContrast(Color color, List<Color> against, double ratio) {
  bool ok(Color c) => against.every((b) => contrastRatio(c, b) >= ratio);
  if (ok(color)) return color;
  final background = against.first.computeLuminance();
  final darken = color.computeLuminance() <= background || background > 0.4;
  var hsl = HSLColor.fromColor(color);
  for (var i = 0; i < 100; i++) {
    final l = (hsl.lightness + (darken ? -0.01 : 0.01)).clamp(0.0, 1.0);
    hsl = hsl.withLightness(l);
    final next = hsl.toColor().withValues(alpha: color.a);
    if (ok(next) || l == 0 || l == 1) return next;
  }
  return hsl.toColor();
}

/// [tokens] with every color role meeting its promise in
/// design_system.md §2 and §14: text 4.5:1 on its surfaces, filled roles
/// carrying their text at 4.5:1, graphics 3:1, brand and danger usable as
/// text. Roles that already pass are unchanged.
AppTokens withAccessibleContrast(AppTokens tokens) {
  final c = tokens.colors;
  final surfaces = [c.surfaceCanvas, c.surfaceBase];
  final allSurfaces = [
    ...surfaces,
    c.surfaceSunken,
    c.brandPrimarySoft,
    c.actionSoft,
    c.accentSoft,
    c.successContainer,
    c.warningContainer,
    c.dangerContainer,
  ];
  final textPrimary = withContrast(c.textPrimary, allSurfaces, 4.5);
  // Brand is also text on the canvas: settle it first, then pick the text
  // on it (white or ink, whichever reads better), and only then nudge it.
  var brand = withContrast(c.brandPrimary, surfaces, 4.5);
  Color bestOn(Color fill, Color current) {
    const white = Color(0xFFFFFFFF);
    final options = [current, white, textPrimary];
    options.sort(
      (a, b) => contrastRatio(b, fill).compareTo(contrastRatio(a, fill)),
    );
    return contrastRatio(current, fill) >= 4.5 ? current : options.first;
  }

  final onBrand = bestOn(brand, c.onBrandPrimary);
  brand = withContrast(brand, [onBrand], 4.5);
  final action0 = c.action;
  final onAction = bestOn(action0, c.onAction);
  final action = withContrast(action0, [onAction], 4.5);
  final colors = AppColors(
    surfaceCanvas: c.surfaceCanvas,
    surfaceBase: c.surfaceBase,
    surfaceRaised: c.surfaceRaised,
    surfaceSunken: c.surfaceSunken,
    borderSubtle: c.borderSubtle,
    borderStrong: withContrast(c.borderStrong, surfaces, 3),
    textPrimary: textPrimary,
    textSecondary: withContrast(c.textSecondary, allSurfaces, 4.5),
    textTertiary: c.textTertiary,
    brandPrimary: brand,
    onBrandPrimary: onBrand,
    brandPrimarySoft: c.brandPrimarySoft,
    onBrandPrimarySoft: withContrast(c.onBrandPrimarySoft, [
      c.brandPrimarySoft,
    ], 4.5),
    action: action,
    onAction: onAction,
    actionSoft: c.actionSoft,
    onActionSoft: withContrast(c.onActionSoft, [c.actionSoft], 4.5),
    accent: withContrast(c.accent, surfaces, 3),
    accentSoft: c.accentSoft,
    onAccentSoft: withContrast(c.onAccentSoft, [c.accentSoft], 4.5),
    accentDawn: c.accentDawn,
    scrim: c.scrim,
    success: withContrast(c.success, surfaces, 3),
    successContainer: c.successContainer,
    warning: withContrast(c.warning, surfaces, 3),
    warningContainer: c.warningContainer,
    danger: withContrast(c.danger, surfaces, 4.5),
    dangerContainer: c.dangerContainer,
  );
  return tokens.copyWith(
    colors: colors,
    palette: tokens.palette.map(
      (a) => ActivityColors(
        solid: withContrast(a.solid, [c.surfaceBase, a.soft], 3),
        soft: a.soft,
      ),
    ),
  );
}
