import 'package:flutter/painting.dart';

import '../app_tokens.dart';
import '../tokens/activity_palette.dart';
import '../tokens/color_tokens.dart';
import '../tokens/elevation.dart';
import '../tokens/treatments.dart';
import 'app_theme_id.dart';

/// Lavender (ADR-045): porcelain canvas, electric lavender signature, mint
/// action, sky accent.
const lavenderTokens = AppTokens(
  id: AppThemeId.lavender,
  colors: AppColors(
    surfaceCanvas: Color(0xFFF8F8FE),
    surfaceBase: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFF1EEFD),
    borderSubtle: Color(0xFFE8E4FA),
    borderStrong: Color(0xFF837E9E),
    textPrimary: Color(0xFF1E1B4B),
    textSecondary: Color(0xFF4B4868),
    textTertiary: Color(0xFF7D7A96),
    brandPrimary: Color(0xFF6847F0),
    onBrandPrimary: Color(0xFFFFFFFF),
    brandPrimarySoft: Color(0xFFECE8FE),
    onBrandPrimarySoft: Color(0xFF4A2BC2),
    action: Color(0xFF047857),
    onAction: Color(0xFFFFFFFF),
    actionSoft: Color(0xFFD9F7E8),
    onActionSoft: Color(0xFF065F46),
    accent: Color(0xFF0369A1),
    accentSoft: Color(0xFFE0F2FE),
    onAccentSoft: Color(0xFF075985),
    accentDawn: Color(0xFFF59E0B),
    scrim: Color(0x661E1B4B),
    success: Color(0xFF059669),
    successContainer: Color(0xFFD9F7E8),
    warning: Color(0xFFC2410C),
    warningContainer: Color(0xFFFFEDE0),
    danger: Color(0xFFBE123C),
    dangerContainer: Color(0xFFFFE4E8),
  ),
  shadows: AppShadows(
    card: [
      BoxShadow(
        color: Color(0x147C5CFC),
        offset: Offset(0, 8),
        blurRadius: 24,
        spreadRadius: -4,
      ),
      BoxShadow(
        color: Color(0x051F2438),
        offset: Offset(0, 2),
        blurRadius: 6,
        spreadRadius: 0,
      ),
    ],
    floating: [
      BoxShadow(
        color: Color(0x247C5CFC),
        offset: Offset(0, 16),
        blurRadius: 36,
        spreadRadius: -8,
      ),
      BoxShadow(
        color: Color(0x0F10B981),
        offset: Offset(0, 4),
        blurRadius: 12,
        spreadRadius: 0,
      ),
    ],
    glowAlpha: 0.35,
  ),
  treatments: AppTreatments(
    cardEdge: CardEdge.hairline,
    navStyle: NavStyle.bar,
    progressGradient: [Color(0xFF6847F0), Color(0xFF10B981)],
    heroWash: Color(0xFFD9F7E8),
    factsAsChips: false,
    timeColumn: true,
  ),
  palette: ActivityPalette({
    ActivityColorKey.sky: ActivityColors(
      solid: Color(0xFF0284C7),
      soft: Color(0xFFE0F2FE),
    ),
    ActivityColorKey.lilac: ActivityColors(
      solid: Color(0xFF7C5CFC),
      soft: Color(0xFFEDE9FE),
    ),
    ActivityColorKey.rose: ActivityColors(
      solid: Color(0xFFDB2777),
      soft: Color(0xFFFCE7F3),
    ),
    ActivityColorKey.teal: ActivityColors(
      solid: Color(0xFF059669),
      soft: Color(0xFFD9F7E8),
    ),
    ActivityColorKey.coral: ActivityColors(
      solid: Color(0xFFEA580C),
      soft: Color(0xFFFFEDE0),
    ),
    ActivityColorKey.slate: ActivityColors(
      solid: Color(0xFF64748B),
      soft: Color(0xFFEEF1F6),
    ),
  }),
);
