import 'package:flutter/painting.dart';

import '../app_tokens.dart';
import '../tokens/activity_palette.dart';
import '../tokens/color_tokens.dart';
import '../tokens/elevation.dart';
import '../tokens/treatments.dart';
import 'app_theme_id.dart';

/// Electric Lavender & Mint: porcelain canvas, lavender #7C5CFC signature,
/// mint #10B981 action, sky #38BDF8 accent, ink #1E1B4B.
const lavenderTokens = AppTokens(
  id: AppThemeId.lavender,
  colors: AppColors(
    surfaceCanvas: Color(0xFFF8F9FE),
    surfaceBase: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFF1EEFE),
    borderSubtle: Color(0xFFECE8FD),
    borderStrong: Color(0xFF8B86A8),
    textPrimary: Color(0xFF1E1B4B),
    textSecondary: Color(0xFF4B4870),
    textTertiary: Color(0xFF8582A3),
    brandPrimary: Color(0xFF7C5CFC),
    onBrandPrimary: Color(0xFFFFFFFF),
    brandPrimarySoft: Color(0xFFEDE9FE),
    onBrandPrimarySoft: Color(0xFF5B3BE0),
    action: Color(0xFF10B981),
    onAction: Color(0xFFFFFFFF),
    actionSoft: Color(0xFFD1FAE5),
    onActionSoft: Color(0xFF047857),
    accent: Color(0xFF0EA5E9),
    accentSoft: Color(0xFFE0F2FE),
    onAccentSoft: Color(0xFF0369A1),
    accentDawn: Color(0xFFF59E0B),
    scrim: Color(0x661E1B4B),
    success: Color(0xFF10B981),
    successContainer: Color(0xFFD1FAE5),
    warning: Color(0xFFEA580C),
    warningContainer: Color(0xFFFFEDD5),
    danger: Color(0xFFDC2626),
    dangerContainer: Color(0xFFFEE2E2),
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
    progressGradient: [Color(0xFF7C5CFC)],
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
