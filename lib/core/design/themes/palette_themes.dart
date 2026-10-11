import 'package:flutter/painting.dart';

import '../app_tokens.dart';
import '../tokens/color_tokens.dart';
import '../tokens/elevation.dart';
import '../tokens/treatments.dart';
import 'app_theme_id.dart';
import 'lavender_theme.dart';

/// A theme from its palette, the way the design palettes are specified:
/// a primary (signature), a secondary (the "go" action), a tertiary
/// (accent) and a neutral ink, on a tinted canvas. Every other role (soft
/// fills, borders, text greys) is mixed from those, so each palette stays
/// coherent; activity colors are shared.
AppTokens paletteTokens({
  required AppThemeId id,
  required Color primary,
  required Color action,
  required Color accent,
  required Color ink,
  required Color canvas,
  Color onPrimary = const Color(0xFFFFFFFF),
  Color onAction = const Color(0xFFFFFFFF),
}) {
  const white = Color(0xFFFFFFFF);
  Color mix(Color c, double amount, [Color over = white]) =>
      Color.alphaBlend(c.withValues(alpha: amount), over);
  Color deep(Color c, double lightness) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness(lightness < hsl.lightness ? lightness : hsl.lightness)
        .toColor();
  }

  final success = deep(const Color(0xFF10B981), 0.40);
  return AppTokens(
    id: id,
    colors: AppColors(
      surfaceCanvas: canvas,
      surfaceBase: white,
      surfaceRaised: white,
      surfaceSunken: mix(primary, 0.07),
      borderSubtle: mix(primary, 0.13),
      borderStrong: mix(ink, 0.55),
      textPrimary: ink,
      textSecondary: mix(ink, 0.78),
      textTertiary: mix(ink, 0.52),
      brandPrimary: primary,
      onBrandPrimary: onPrimary,
      brandPrimarySoft: mix(primary, 0.14),
      onBrandPrimarySoft: deep(primary, 0.30),
      action: action,
      onAction: onAction,
      actionSoft: mix(action, 0.16),
      onActionSoft: deep(action, 0.26),
      accent: accent,
      accentSoft: mix(accent, 0.16),
      onAccentSoft: deep(accent, 0.28),
      accentDawn: const Color(0xFFF59E0B),
      scrim: ink.withValues(alpha: 0.4),
      success: success,
      successContainer: mix(success, 0.16),
      warning: const Color(0xFFEA580C),
      warningContainer: const Color(0xFFFFEDD5),
      danger: const Color(0xFFDC2626),
      dangerContainer: const Color(0xFFFEE2E2),
    ),
    shadows: AppShadows(
      card: [
        BoxShadow(
          color: primary.withValues(alpha: 0.08),
          offset: const Offset(0, 8),
          blurRadius: 24,
          spreadRadius: -4,
        ),
        BoxShadow(
          color: ink.withValues(alpha: 0.02),
          offset: const Offset(0, 2),
          blurRadius: 6,
        ),
      ],
      floating: [
        BoxShadow(
          color: primary.withValues(alpha: 0.14),
          offset: const Offset(0, 16),
          blurRadius: 36,
          spreadRadius: -8,
        ),
      ],
      glowAlpha: 0.32,
    ),
    treatments: AppTreatments(
      cardEdge: CardEdge.hairline,
      navStyle: NavStyle.bar,
      progressGradient: [primary],
      heroWash: mix(action, 0.16),
      factsAsChips: true,
      timeColumn: true,
    ),
    palette: lavenderTokens.palette,
  );
}

final oceanTokens = paletteTokens(
  id: AppThemeId.ocean,
  primary: const Color(0xFF3B82F6),
  action: const Color(0xFF10B981),
  accent: const Color(0xFFF59E0B),
  ink: const Color(0xFF172554),
  canvas: const Color(0xFFF5F8FF),
);

final matchaTokens = paletteTokens(
  id: AppThemeId.matcha,
  primary: const Color(0xFF65A30D),
  action: const Color(0xFF0EA5E9),
  accent: const Color(0xFFF472B6),
  ink: const Color(0xFF1A2E05),
  canvas: const Color(0xFFF7FBF1),
);

final lilacTokens = paletteTokens(
  id: AppThemeId.lilac,
  primary: const Color(0xFFA855F7),
  action: const Color(0xFFEC4899),
  accent: const Color(0xFF22D3EE),
  ink: const Color(0xFF2E1065),
  canvas: const Color(0xFFFBF7FF),
);

final skyTokens = paletteTokens(
  id: AppThemeId.sky,
  primary: const Color(0xFF0EA5E9),
  action: const Color(0xFFF472B6),
  accent: const Color(0xFF84CC16),
  ink: const Color(0xFF0C2A3D),
  canvas: const Color(0xFFF3FAFE),
);

final honeyTokens = paletteTokens(
  id: AppThemeId.honey,
  primary: const Color(0xFFF59E0B),
  onPrimary: const Color(0xFF3B2A05),
  action: const Color(0xFF10B981),
  accent: const Color(0xFF6366F1),
  ink: const Color(0xFF292524),
  canvas: const Color(0xFFFFFBF0),
);

final slateTokens = paletteTokens(
  id: AppThemeId.slate,
  primary: const Color(0xFF475569),
  action: const Color(0xFF10B981),
  accent: const Color(0xFFF59E0B),
  ink: const Color(0xFF0F172A),
  canvas: const Color(0xFFF6F7F9),
);
