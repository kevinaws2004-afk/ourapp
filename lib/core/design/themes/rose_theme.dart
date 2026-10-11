import 'package:flutter/painting.dart';

import '../app_tokens.dart';
import '../tokens/activity_palette.dart';
import '../tokens/color_tokens.dart';
import '../tokens/elevation.dart';
import '../tokens/treatments.dart';
import 'app_theme_id.dart';

/// Pastel Confection (stored as `rose`): blush canvas, pink #FF5D9E
/// signature, teal #48C9B0 action, butter #FEF9C3 accent, ink #2D3142.
const roseTokens = AppTokens(
  id: AppThemeId.rose,
  colors: AppColors(
    surfaceCanvas: Color(0xFFFFF6F9),
    surfaceBase: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFFCEAF1),
    borderSubtle: Color(0xFFF9DCE7),
    borderStrong: Color(0xFF9A7F8C),
    textPrimary: Color(0xFF2D3142),
    textSecondary: Color(0xFF5A5E70),
    textTertiary: Color(0xFF8D90A0),
    brandPrimary: Color(0xFFFF5D9E),
    onBrandPrimary: Color(0xFFFFFFFF),
    brandPrimarySoft: Color(0xFFFFE3EE),
    onBrandPrimarySoft: Color(0xFFB0195F),
    action: Color(0xFF48C9B0),
    onAction: Color(0xFFFFFFFF),
    actionSoft: Color(0xFFD7F5EF),
    onActionSoft: Color(0xFF1F7A69),
    accent: Color(0xFFCA8A04),
    accentSoft: Color(0xFFFEF9C3),
    onAccentSoft: Color(0xFF713F12),
    accentDawn: Color(0xFFF59E0B),
    scrim: Color(0x662B2330),
    success: Color(0xFF2BAE96),
    successContainer: Color(0xFFD7F5EF),
    warning: Color(0xFFE8833A),
    warningContainer: Color(0xFFFDEBDC),
    danger: Color(0xFFE11D48),
    dangerContainer: Color(0xFFFFE4E9),
  ),
  shadows: AppShadows(
    card: [
      BoxShadow(
        color: Color(0x1AFF5D9E),
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
        color: Color(0x24FF5D9E),
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
    progressGradient: [Color(0xFFFF5D9E)],
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
