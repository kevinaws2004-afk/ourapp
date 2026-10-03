import 'package:flutter/material.dart';

import '../../core/design/context_ext.dart';

enum AppButtonVariant { primary, secondary, tertiary, destructive }

/// The product button (ui_guidelines.md §3). Styling comes from the theme,
/// which is built from design tokens.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final child = Text(label);
    final iconWidget = icon == null ? null : Icon(icon);
    return switch (variant) {
      AppButtonVariant.primary =>
        iconWidget == null
            ? FilledButton(onPressed: onPressed, child: child)
            : FilledButton.icon(
                onPressed: onPressed,
                icon: iconWidget,
                label: child,
              ),
      AppButtonVariant.secondary => FilledButton.tonal(
        style: FilledButton.styleFrom(
          backgroundColor: colors.brandPrimarySoft,
          foregroundColor: colors.onBrandPrimarySoft,
        ),
        onPressed: onPressed,
        child: child,
      ),
      AppButtonVariant.tertiary => TextButton(
        onPressed: onPressed,
        child: child,
      ),
      AppButtonVariant.destructive => FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: colors.danger,
          foregroundColor: colors.surfaceRaised,
        ),
        onPressed: onPressed,
        child: child,
      ),
    };
  }
}
