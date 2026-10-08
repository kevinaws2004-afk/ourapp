import 'package:flutter/material.dart';

import '../../core/design/context_ext.dart';
import '../../core/design/tokens/radius.dart';
import '../../core/design/tokens/spacing.dart';
import '../../core/design/tokens/treatments.dart';

/// The card everything on a screen sits in (ADR-045): a white surface on the
/// tinted canvas with the theme's soft glow, its edge drawn the theme's way.
/// [color] tints it (a soft activity or status color); [onTap] makes it
/// tappable with a ripple clipped to its shape.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.color,
    this.onTap,
    this.onLongPress,
    this.flat = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// No glow: for cards inside cards, and quiet rows.
  final bool flat;

  @override
  Widget build(BuildContext context) {
    final decoration = cardDecoration(context, color: color, flat: flat);
    if (onTap == null && onLongPress == null) {
      return DecoratedBox(
        decoration: decoration,
        child: Padding(padding: padding, child: child),
      );
    }
    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: decoration,
        child: InkWell(
          borderRadius: AppRadius.cardAll,
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// The card surface of the current theme, for widgets that draw their own.
BoxDecoration cardDecoration(
  BuildContext context, {
  Color? color,
  bool flat = false,
  BorderRadius borderRadius = AppRadius.cardAll,
}) {
  final tokens = context.tokens;
  final c = tokens.colors;
  final border = switch (tokens.treatments.cardEdge) {
    CardEdge.none => null,
    CardEdge.hairline => Border.all(color: c.borderSubtle),
    CardEdge.rim => Border.all(
      color: c.textPrimary.withValues(alpha: 0.05),
      width: 1.5,
    ),
  };
  return BoxDecoration(
    color: color ?? c.surfaceBase,
    borderRadius: borderRadius,
    border: border,
    boxShadow: flat ? null : tokens.shadows.card,
  );
}
