import 'package:flutter/painting.dart';

import '../app_tokens.dart';
import '../tokens/activity_palette.dart';
import '../tokens/color_tokens.dart';
import '../tokens/elevation.dart';
import '../tokens/treatments.dart';
import 'app_theme_id.dart';

/// Papaya (ADR-045): warm porcelain canvas, papaya signature, aqua mint
/// action (dark text on it), periwinkle accent; rimmed cards, a floating
/// navigation bar, gradient progress and facts as chips.
const papayaTokens = AppTokens(
  id: AppThemeId.papaya,
  colors: AppColors(
    surfaceCanvas: Color(0xFFFBF9F7),
    surfaceBase: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFF4EFEA),
    borderSubtle: Color(0xFFEEE6E0),
    borderStrong: Color(0xFF8A746D),
    textPrimary: Color(0xFF1E232F),
    textSecondary: Color(0xFF4F5563),
    textTertiary: Color(0xFF828795),
    brandPrimary: Color(0xFFC93A1B),
    onBrandPrimary: Color(0xFFFFFFFF),
    brandPrimarySoft: Color(0xFFFFE9E2),
    onBrandPrimarySoft: Color(0xFF9A2A10),
    action: Color(0xFF2DD4BF),
    onAction: Color(0xFF1E232F),
    actionSoft: Color(0xFFDDF8F4),
    onActionSoft: Color(0xFF0F6B62),
    accent: Color(0xFF4F46E5),
    accentSoft: Color(0xFFEEF0FF),
    onAccentSoft: Color(0xFF3730A3),
    accentDawn: Color(0xFFFF6B4A),
    scrim: Color(0x661E232F),
    success: Color(0xFF0D9488),
    successContainer: Color(0xFFDDF8F4),
    warning: Color(0xFFC2410C),
    warningContainer: Color(0xFFFFEDE0),
    danger: Color(0xFFBE123C),
    dangerContainer: Color(0xFFFFE4E8),
  ),
  shadows: AppShadows(
    card: [
      BoxShadow(
        color: Color(0x0FFF6B4A),
        offset: Offset(0, 12),
        blurRadius: 32,
        spreadRadius: -4,
      ),
      BoxShadow(
        color: Color(0x081E232F),
        offset: Offset(0, 4),
        blurRadius: 12,
        spreadRadius: 0,
      ),
    ],
    floating: [
      BoxShadow(
        color: Color(0x24FF6B4A),
        offset: Offset(0, 20),
        blurRadius: 40,
        spreadRadius: -8,
      ),
      BoxShadow(
        color: Color(0x0A1E232F),
        offset: Offset(0, 4),
        blurRadius: 12,
        spreadRadius: 0,
      ),
    ],
    glowAlpha: 0.35,
  ),
  treatments: AppTreatments(
    cardEdge: CardEdge.rim,
    navStyle: NavStyle.floating,
    progressGradient: [Color(0xFFFF6B4A), Color(0xFFFDBA74)],
    heroWash: Color(0xFFDDF8F4),
    factsAsChips: true,
    timeColumn: false,
  ),
  palette: ActivityPalette({
    ActivityColorKey.sky: ActivityColors(
      solid: Color(0xFF0284C7),
      soft: Color(0xFFE0F2FE),
    ),
    ActivityColorKey.lilac: ActivityColors(
      solid: Color(0xFF5B5BD6),
      soft: Color(0xFFEEF0FF),
    ),
    ActivityColorKey.rose: ActivityColors(
      solid: Color(0xFFE11D48),
      soft: Color(0xFFFFE4E9),
    ),
    ActivityColorKey.teal: ActivityColors(
      solid: Color(0xFF0D9488),
      soft: Color(0xFFD9F7F3),
    ),
    ActivityColorKey.coral: ActivityColors(
      solid: Color(0xFFE8512F),
      soft: Color(0xFFFFEAE3),
    ),
    ActivityColorKey.slate: ActivityColors(
      solid: Color(0xFF5B6170),
      soft: Color(0xFFEEF0F3),
    ),
  }),
);
