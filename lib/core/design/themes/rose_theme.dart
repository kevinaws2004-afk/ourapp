import 'package:flutter/painting.dart';

import '../app_tokens.dart';
import '../tokens/activity_palette.dart';
import '../tokens/color_tokens.dart';
import '../tokens/elevation.dart';
import '../tokens/treatments.dart';
import 'app_theme_id.dart';

/// Rose (ADR-045): blush canvas, rose signature, teal action, butter
/// accent. Built from the app's own rose and teal, not another product's
/// palette.
const roseTokens = AppTokens(
  id: AppThemeId.rose,
  colors: AppColors(
    surfaceCanvas: Color(0xFFFBF4F5),
    surfaceBase: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFF7E8EB),
    borderSubtle: Color(0xFFF1DEE3),
    borderStrong: Color(0xFF8F6F79),
    textPrimary: Color(0xFF2B2330),
    textSecondary: Color(0xFF5C5262),
    textTertiary: Color(0xFF8C8291),
    brandPrimary: Color(0xFFB04E62),
    onBrandPrimary: Color(0xFFFFFFFF),
    brandPrimarySoft: Color(0xFFF9E1E7),
    onBrandPrimarySoft: Color(0xFF7A2C3D),
    action: Color(0xFF2F8180),
    onAction: Color(0xFFFFFFFF),
    actionSoft: Color(0xFFDDF0EF),
    onActionSoft: Color(0xFF1D5655),
    accent: Color(0xFF9A6A12),
    accentSoft: Color(0xFFFBF0D5),
    onAccentSoft: Color(0xFF6B4A0C),
    accentDawn: Color(0xFFD9822B),
    scrim: Color(0x662B2330),
    success: Color(0xFF2F8180),
    successContainer: Color(0xFFDDF0EF),
    warning: Color(0xFFB4582A),
    warningContainer: Color(0xFFFBE8DC),
    danger: Color(0xFFB4233F),
    dangerContainer: Color(0xFFFBE3E8),
  ),
  shadows: AppShadows(
    card: [
      BoxShadow(
        color: Color(0x1AB04E62),
        offset: Offset(0, 8),
        blurRadius: 24,
        spreadRadius: -6,
      ),
      BoxShadow(
        color: Color(0x062B2330),
        offset: Offset(0, 2),
        blurRadius: 6,
        spreadRadius: 0,
      ),
    ],
    floating: [
      BoxShadow(
        color: Color(0x24B04E62),
        offset: Offset(0, 16),
        blurRadius: 36,
        spreadRadius: -8,
      ),
      BoxShadow(
        color: Color(0x0A2B2330),
        offset: Offset(0, 4),
        blurRadius: 12,
        spreadRadius: 0,
      ),
    ],
    glowAlpha: 0.3,
  ),
  treatments: AppTreatments(
    cardEdge: CardEdge.none,
    navStyle: NavStyle.bar,
    progressGradient: [Color(0xFF2F8180)],
    heroWash: Color(0xFFDDF0EF),
    factsAsChips: false,
    timeColumn: true,
  ),
  palette: ActivityPalette({
    ActivityColorKey.sky: ActivityColors(
      solid: Color(0xFF4A78A8),
      soft: Color(0xFFE1ECF7),
    ),
    ActivityColorKey.lilac: ActivityColors(
      solid: Color(0xFF7A62B5),
      soft: Color(0xFFECE6F8),
    ),
    ActivityColorKey.rose: ActivityColors(
      solid: Color(0xFFB04E62),
      soft: Color(0xFFF8E3E7),
    ),
    ActivityColorKey.teal: ActivityColors(
      solid: Color(0xFF2F8180),
      soft: Color(0xFFDDF0EF),
    ),
    ActivityColorKey.coral: ActivityColors(
      solid: Color(0xFFC0503E),
      soft: Color(0xFFFBE4DF),
    ),
    ActivityColorKey.slate: ActivityColors(
      solid: Color(0xFF5D6A80),
      soft: Color(0xFFE6E9EF),
    ),
  }),
);
