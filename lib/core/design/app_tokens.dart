import 'package:flutter/material.dart';

import 'themes/app_theme_id.dart';
import 'themes/dark_theme.dart';
import 'themes/lavender_theme.dart';
import 'themes/palette_themes.dart';
import 'themes/papaya_theme.dart';
import 'themes/rose_theme.dart';
import 'tokens/activity_palette.dart';
import 'tokens/color_tokens.dart';
import 'tokens/elevation.dart';
import 'tokens/treatments.dart';

/// One theme's tokens that Material's [ThemeData] doesn't model: the full
/// color role set, shadows, treatments and the activity palette (ADR-045).
/// Every theme comes in light and dark.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.id,
    required this.colors,
    required this.shadows,
    required this.treatments,
    required this.palette,
    this.brightness = Brightness.light,
  });

  static final Map<AppThemeId, AppTokens> _dark = {};

  static AppTokens of(
    AppThemeId id, {
    Brightness brightness = Brightness.light,
  }) {
    final light = switch (id) {
      AppThemeId.rose => roseTokens,
      AppThemeId.lavender => lavenderTokens,
      AppThemeId.papaya => papayaTokens,
      AppThemeId.ocean => oceanTokens,
      AppThemeId.matcha => matchaTokens,
      AppThemeId.lilac => lilacTokens,
      AppThemeId.sky => skyTokens,
      AppThemeId.honey => honeyTokens,
      AppThemeId.slate => slateTokens,
      AppThemeId.mint => mintTokens,
      AppThemeId.cherry => cherryTokens,
      AppThemeId.forest => forestTokens,
      AppThemeId.midnight => midnightTokens,
      AppThemeId.mocha => mochaTokens,
      AppThemeId.roseGold => roseGoldTokens,
    };
    return brightness == Brightness.light
        ? light
        : _dark.putIfAbsent(id, () => darkTokensFrom(light));
  }

  final AppThemeId id;

  /// Light or dark: each theme has both.
  final Brightness brightness;

  bool get isDark => brightness == Brightness.dark;
  final AppColors colors;
  final AppShadows shadows;
  final AppTreatments treatments;
  final ActivityPalette palette;

  ActivityColors activity(ActivityColorKey key) => palette.resolve(key);

  @override
  AppTokens copyWith({
    AppThemeId? id,
    AppColors? colors,
    AppShadows? shadows,
    AppTreatments? treatments,
    ActivityPalette? palette,
    Brightness? brightness,
  }) => AppTokens(
    id: id ?? this.id,
    colors: colors ?? this.colors,
    shadows: shadows ?? this.shadows,
    treatments: treatments ?? this.treatments,
    palette: palette ?? this.palette,
    brightness: brightness ?? this.brightness,
  );

  /// Colors cross-fade when the theme changes; the rest switches halfway.
  @override
  AppTokens lerp(covariant AppTokens? other, double t) {
    if (other == null) return this;
    final half = t < 0.5 ? this : other;
    return AppTokens(
      id: half.id,
      colors: AppColors.lerp(colors, other.colors, t),
      shadows: half.shadows,
      treatments: half.treatments,
      palette: half.palette,
      brightness: half.brightness,
    );
  }
}
