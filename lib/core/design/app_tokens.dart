import 'package:flutter/material.dart';

import 'tokens/activity_palette.dart';
import 'tokens/color_tokens.dart';
import 'tokens/elevation.dart';

/// Theme-dependent tokens that Material's [ThemeData] doesn't model:
/// the full color role set, shadows and the activity palette.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.brightness,
    required this.colors,
    required this.shadows,
  });

  static const light = AppTokens(
    brightness: Brightness.light,
    colors: AppColors.light,
    shadows: AppShadows.light,
  );

  static const dark = AppTokens(
    brightness: Brightness.dark,
    colors: AppColors.dark,
    shadows: AppShadows.dark,
  );

  final Brightness brightness;
  final AppColors colors;
  final AppShadows shadows;

  ActivityColors activity(ActivityColorKey key) =>
      ActivityPalette.resolve(key, brightness);

  @override
  AppTokens copyWith({
    Brightness? brightness,
    AppColors? colors,
    AppShadows? shadows,
  }) => AppTokens(
    brightness: brightness ?? this.brightness,
    colors: colors ?? this.colors,
    shadows: shadows ?? this.shadows,
  );

  @override
  AppTokens lerp(covariant AppTokens? other, double t) {
    if (other == null) return this;
    return AppTokens(
      brightness: t < 0.5 ? brightness : other.brightness,
      colors: AppColors.lerp(colors, other.colors, t),
      shadows: t < 0.5 ? shadows : other.shadows,
    );
  }
}
