import 'package:flutter/material.dart';

/// Type scale (design_system.md §3, ADR-045). One family, Plus Jakarta Sans,
/// for every theme: headlines are heavy with tight tracking, labels bold with
/// open tracking, body regular. Numbers use its tabular figures, so a running
/// timer doesn't jitter. Styles carry no color; the theme or the caller
/// applies a text color role.
abstract final class AppTypography {
  static const family = 'PlusJakartaSans';

  static const _tabular = [FontFeature.tabularFigures()];

  static const displayLarge = TextStyle(
    fontFamily: family,
    fontSize: 36,
    height: 44 / 36,
    letterSpacing: -0.9,
    fontWeight: FontWeight.w800,
  );
  static const displayMedium = TextStyle(
    fontFamily: family,
    fontSize: 30,
    height: 38 / 30,
    letterSpacing: -0.6,
    fontWeight: FontWeight.w800,
  );
  static const headlineLarge = TextStyle(
    fontFamily: family,
    fontSize: 26,
    height: 34 / 26,
    letterSpacing: -0.4,
    fontWeight: FontWeight.w700,
  );
  static const headlineSmall = TextStyle(
    fontFamily: family,
    fontSize: 22,
    height: 28 / 22,
    letterSpacing: -0.2,
    fontWeight: FontWeight.w700,
  );

  static const titleLarge = TextStyle(
    fontFamily: family,
    fontSize: 18,
    height: 24 / 18,
    letterSpacing: -0.1,
    fontWeight: FontWeight.w700,
  );
  static const titleMedium = TextStyle(
    fontFamily: family,
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w600,
  );
  static const bodyLarge = TextStyle(
    fontFamily: family,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
  );
  static const bodyMedium = TextStyle(
    fontFamily: family,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
  );
  static const bodySmall = TextStyle(
    fontFamily: family,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
  );
  static const labelLarge = TextStyle(
    fontFamily: family,
    fontSize: 15,
    height: 20 / 15,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w700,
  );
  static const labelMedium = TextStyle(
    fontFamily: family,
    fontSize: 13,
    height: 18 / 13,
    letterSpacing: 0.2,
    fontWeight: FontWeight.w600,
  );

  /// Chips and small caps-style labels ("UP NEXT").
  static const labelSmall = TextStyle(
    fontFamily: family,
    fontSize: 11,
    height: 14 / 11,
    letterSpacing: 0.5,
    fontWeight: FontWeight.w700,
  );

  static const numericHero = TextStyle(
    fontFamily: family,
    fontSize: 56,
    height: 64 / 56,
    letterSpacing: -1.5,
    fontWeight: FontWeight.w800,
    fontFeatures: _tabular,
  );
  static const numericLarge = TextStyle(
    fontFamily: family,
    fontSize: 32,
    height: 40 / 32,
    letterSpacing: -0.6,
    fontWeight: FontWeight.w800,
    fontFeatures: _tabular,
  );
  static const numericMedium = TextStyle(
    fontFamily: family,
    fontSize: 20,
    height: 26 / 20,
    letterSpacing: -0.2,
    fontWeight: FontWeight.w700,
    fontFeatures: _tabular,
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
      bodySmall: c(bodySmall),
      labelLarge: c(labelLarge),
      labelMedium: c(labelMedium),
      labelSmall: c(labelSmall),
    );
  }
}
