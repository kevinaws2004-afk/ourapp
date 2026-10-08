import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Shadows of one theme (ADR-045): soft ambient glows tinted with the
/// theme's own color plus a faint contact shadow, never hard grey drops.
@immutable
class AppShadows {
  const AppShadows({
    required this.card,
    required this.floating,
    required this.glowAlpha,
  });

  /// Cards resting on the canvas.
  final List<BoxShadow> card;

  /// The floating navigation bar, menus, popovers.
  final List<BoxShadow> floating;

  /// Strength of a colored glow under a big action (0–1).
  final double glowAlpha;

  /// Menus and suggestion lists.
  List<BoxShadow> get overlay => floating;

  /// The glow under a big pill action of [color].
  List<BoxShadow> glow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: glowAlpha),
      offset: const Offset(0, 8),
      blurRadius: 28,
      spreadRadius: -10,
    ),
  ];

  static const List<BoxShadow> flat = [];
}
