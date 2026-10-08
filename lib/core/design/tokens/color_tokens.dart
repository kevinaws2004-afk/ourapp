import 'package:flutter/material.dart';

/// Semantic color roles (design_system.md §2, ADR-045). Every theme fills
/// every role; feature code uses roles, never hex values. The theme files in
/// `lib/core/design/themes/` hold the values.
///
/// Contrast rules (guarded by `color_contrast_test.dart`):
/// - text roles: 4.5:1 on canvas, base, sunken and every soft container
/// - `on*` roles: 4.5:1 on their fill
/// - graphic roles (brand, success, accent, warning, danger): 3:1
@immutable
class AppColors {
  const AppColors({
    required this.surfaceCanvas,
    required this.surfaceBase,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.borderSubtle,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.brandPrimary,
    required this.onBrandPrimary,
    required this.brandPrimarySoft,
    required this.onBrandPrimarySoft,
    required this.action,
    required this.onAction,
    required this.actionSoft,
    required this.onActionSoft,
    required this.accent,
    required this.accentSoft,
    required this.onAccentSoft,
    required this.accentDawn,
    required this.scrim,
    required this.success,
    required this.successContainer,
    required this.warning,
    required this.warningContainer,
    required this.danger,
    required this.dangerContainer,
  });

  /// The screen background (tinted per theme).
  final Color surfaceCanvas;

  /// Cards and sheets.
  final Color surfaceBase;
  final Color surfaceRaised;

  /// Wells: inputs, tracks, inner panels.
  final Color surfaceSunken;

  /// Decorative only (hairlines); below 3:1 by design.
  final Color borderSubtle;

  /// Input outlines and meaningful boundaries (≥ 3:1).
  final Color borderStrong;
  final Color textPrimary;
  final Color textSecondary;

  /// Placeholders, disabled, large decorative text. Not for small essential
  /// text.
  final Color textTertiary;

  /// The theme's signature color: selection, active states, primary actions.
  final Color brandPrimary;
  final Color onBrandPrimary;
  final Color brandPrimarySoft;
  final Color onBrandPrimarySoft;

  /// The "go" color of big actions (Start, Mark done): mint or teal.
  final Color action;
  final Color onAction;
  final Color actionSoft;
  final Color onActionSoft;

  /// The theme's third color (scheduled, info).
  final Color accent;
  final Color accentSoft;
  final Color onAccentSoft;

  /// Rating stars and highlights. Graphics only; never small text.
  final Color accentDawn;
  final Color scrim;

  /// Done. Icons and fills; text on [successContainer] uses text roles.
  final Color success;
  final Color successContainer;

  /// At risk. Icons and fills.
  final Color warning;
  final Color warningContainer;

  /// Errors; meets 4.5:1 on canvas and base, so it may be used for text.
  final Color danger;
  final Color dangerContainer;

  Color get info => accent;
  Color get infoContainer => accentSoft;

  static AppColors lerp(AppColors a, AppColors b, double t) {
    Color l(Color x, Color y) => Color.lerp(x, y, t)!;
    return AppColors(
      surfaceCanvas: l(a.surfaceCanvas, b.surfaceCanvas),
      surfaceBase: l(a.surfaceBase, b.surfaceBase),
      surfaceRaised: l(a.surfaceRaised, b.surfaceRaised),
      surfaceSunken: l(a.surfaceSunken, b.surfaceSunken),
      borderSubtle: l(a.borderSubtle, b.borderSubtle),
      borderStrong: l(a.borderStrong, b.borderStrong),
      textPrimary: l(a.textPrimary, b.textPrimary),
      textSecondary: l(a.textSecondary, b.textSecondary),
      textTertiary: l(a.textTertiary, b.textTertiary),
      brandPrimary: l(a.brandPrimary, b.brandPrimary),
      onBrandPrimary: l(a.onBrandPrimary, b.onBrandPrimary),
      brandPrimarySoft: l(a.brandPrimarySoft, b.brandPrimarySoft),
      onBrandPrimarySoft: l(a.onBrandPrimarySoft, b.onBrandPrimarySoft),
      action: l(a.action, b.action),
      onAction: l(a.onAction, b.onAction),
      actionSoft: l(a.actionSoft, b.actionSoft),
      onActionSoft: l(a.onActionSoft, b.onActionSoft),
      accent: l(a.accent, b.accent),
      accentSoft: l(a.accentSoft, b.accentSoft),
      onAccentSoft: l(a.onAccentSoft, b.onAccentSoft),
      accentDawn: l(a.accentDawn, b.accentDawn),
      scrim: l(a.scrim, b.scrim),
      success: l(a.success, b.success),
      successContainer: l(a.successContainer, b.successContainer),
      warning: l(a.warning, b.warning),
      warningContainer: l(a.warningContainer, b.warningContainer),
      danger: l(a.danger, b.danger),
      dangerContainer: l(a.dangerContainer, b.dangerContainer),
    );
  }
}
