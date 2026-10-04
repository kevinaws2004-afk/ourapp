import 'package:flutter/material.dart';

/// Type scale (design_system.md §3). Styles carry no color; the theme or the
/// caller applies a text color role.
///
/// Both fonts are bundled variable fonts, so weight and optical size are set
/// through [FontVariation]s as well as [FontWeight] (the fallback).
abstract final class AppTypography {
  static const displayFamily = 'Fraunces';
  static const uiFamily = 'DMSans';
  static const numericFamily = 'DMMono';

  static final displayLarge = _display(
    size: 40,
    lineHeight: 46,
    tracking: -0.5,
  );
  static final displayMedium = _display(
    size: 32,
    lineHeight: 38,
    tracking: -0.4,
  );
  static final headlineLarge = _display(
    size: 26,
    lineHeight: 32,
    tracking: -0.2,
  );
  static final headlineSmall = _display(size: 21, lineHeight: 27, tracking: 0);

  static final titleLarge = _ui(size: 18, lineHeight: 24, weight: 600);
  static final titleMedium = _ui(size: 16, lineHeight: 22, weight: 600);
  static final bodyLarge = _ui(size: 16, lineHeight: 24, weight: 400);
  static final bodyMedium = _ui(
    size: 14,
    lineHeight: 20,
    weight: 400,
    tracking: 0.1,
  );
  static final labelLarge = _ui(
    size: 15,
    lineHeight: 20,
    weight: 600,
    tracking: 0.1,
  );
  static final labelMedium = _ui(
    size: 13,
    lineHeight: 18,
    weight: 600,
    tracking: 0.2,
  );
  static final labelSmall = _ui(
    size: 11,
    lineHeight: 14,
    weight: 600,
    tracking: 0.5,
  );

  // Numeric styles use DM Mono (ADR-032): every digit has the same width, so
  // a running timer doesn't jitter. Its static weights are Regular and Medium.
  static final numericHero = _numeric(
    size: 72,
    lineHeight: 76,
    weight: FontWeight.w400,
    tracking: -2,
  );
  static final numericLarge = _numeric(
    size: 34,
    lineHeight: 40,
    weight: FontWeight.w500,
    tracking: -0.5,
  );
  static final numericMedium = _numeric(
    size: 20,
    lineHeight: 24,
    weight: FontWeight.w500,
  );

  /// Material [TextTheme] from the scale. Slots the scale doesn't define map
  /// to their nearest token.
  static TextTheme textTheme(Color color) {
    TextStyle c(TextStyle style) => style.copyWith(color: color);
    return TextTheme(
      displayLarge: c(displayLarge),
      displayMedium: c(displayMedium),
      displaySmall: c(headlineLarge),
      headlineLarge: c(headlineLarge),
      headlineMedium: c(headlineSmall),
      headlineSmall: c(headlineSmall),
      titleLarge: c(titleLarge),
      titleMedium: c(titleMedium),
      titleSmall: c(labelLarge),
      bodyLarge: c(bodyLarge),
      bodyMedium: c(bodyMedium),
      bodySmall: c(bodyMedium),
      labelLarge: c(labelLarge),
      labelMedium: c(labelMedium),
      labelSmall: c(labelSmall),
    );
  }

  static TextStyle _display({
    required double size,
    required double lineHeight,
    required double tracking,
  }) => TextStyle(
    fontFamily: displayFamily,
    fontSize: size,
    height: lineHeight / size,
    letterSpacing: tracking,
    fontWeight: FontWeight.w600,
    fontVariations: [
      const FontVariation.weight(560),
      FontVariation.opticalSize(size),
      // Soft, low-contrast settings for a warm, calm voice.
      const FontVariation('SOFT', 50),
      const FontVariation('WONK', 0),
    ],
  );

  static TextStyle _numeric({
    required double size,
    required double lineHeight,
    required FontWeight weight,
    double tracking = 0,
  }) => TextStyle(
    fontFamily: numericFamily,
    fontSize: size,
    height: lineHeight / size,
    letterSpacing: tracking,
    fontWeight: weight,
  );

  static TextStyle _ui({
    required double size,
    required double lineHeight,
    required int weight,
    double tracking = 0,
  }) => TextStyle(
    fontFamily: uiFamily,
    fontSize: size,
    height: lineHeight / size,
    letterSpacing: tracking,
    fontWeight: FontWeight.values.firstWhere((w) => w.value >= weight),
    fontVariations: [
      FontVariation.weight(weight.toDouble()),
      // DM Sans' optical-size axis spans 9–40.
      FontVariation.opticalSize(size.clamp(9, 40).toDouble()),
    ],
  );
}
