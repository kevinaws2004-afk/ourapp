import 'package:flutter/material.dart';

import '../../core/design/context_ext.dart';
import '../../core/design/tokens/radius.dart';

enum AppButtonVariant {
  /// The theme's signature color.
  primary,

  /// The "go" color of big actions: Start, Mark done (ADR-045).
  action,

  /// Soft tint of the signature color.
  secondary,

  /// Text only.
  tertiary,
  destructive,
}

/// The product button (ui_guidelines.md §3): a pill. With [expand] it fills
/// the width and, for [AppButtonVariant.primary] and
/// [AppButtonVariant.action], glows in its own color.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final child = Text(label);
    final iconWidget = icon == null ? null : Icon(icon);
    final big = expand ? const Size.fromHeight(56) : null;
    ButtonStyle filled(Color background, Color foreground) =>
        FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          minimumSize: big,
        );
    Widget filledButton(ButtonStyle style) => iconWidget == null
        ? FilledButton(style: style, onPressed: onPressed, child: child)
        : FilledButton.icon(
            style: style,
            onPressed: onPressed,
            icon: iconWidget,
            label: child,
          );
    Widget glowing(Color color, Widget button) => !expand || onPressed == null
        ? button
        : DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: AppRadius.pillAll,
              boxShadow: context.tokens.shadows.glow(color),
            ),
            child: button,
          );
    return switch (variant) {
      AppButtonVariant.primary => glowing(
        colors.brandPrimary,
        filledButton(filled(colors.brandPrimary, colors.onBrandPrimary)),
      ),
      AppButtonVariant.action => glowing(
        colors.action,
        filledButton(filled(colors.action, colors.onAction)),
      ),
      AppButtonVariant.secondary => filledButton(
        filled(colors.brandPrimarySoft, colors.onBrandPrimarySoft),
      ),
      AppButtonVariant.tertiary => TextButton.icon(
        style: TextButton.styleFrom(minimumSize: big),
        onPressed: onPressed,
        icon: iconWidget,
        label: child,
      ),
      AppButtonVariant.destructive => FilledButton(
        style: filled(colors.danger, colors.surfaceRaised),
        onPressed: onPressed,
        child: child,
      ),
    };
  }
}
