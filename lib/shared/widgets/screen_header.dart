import 'package:flutter/material.dart';

import 'app_logo.dart';

import '../../core/design/context_ext.dart';
import '../../core/design/tokens/radius.dart';
import '../../core/design/tokens/spacing.dart';

/// The top of every tab, like a product app bar: the app's logo, a tiny
/// [overline] (the app's name unless given), the screen [title], and round
/// [actions] on the right (an avatar, a button). An optional [subtitle]
/// sits under it. One header, so every tab reads as the same product.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.overline,
    this.subtitle,
    this.actions = const [],
    this.showMark = true,
  });

  final String title;
  final String? overline;
  final String? subtitle;
  final List<Widget> actions;

  /// The app's logo on the left (tabs); off for pushed screens.
  final bool showMark;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs, bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (showMark) ...[
                const AppLogo(size: 42),
                const SizedBox(width: AppSpacing.sm + AppSpacing.xxs),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (overline ?? appBrandName).toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.labelSmall?.copyWith(
                        color: c.textTertiary,
                        letterSpacing: 1.2,
                        fontSize: 9.5,
                      ),
                    ),
                    Semantics(
                      header: true,
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          height: 1.15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              for (final action in actions) ...[
                const SizedBox(width: AppSpacing.sm),
                action,
              ],
            ],
          ),
          if (subtitle case final s?)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Text(
                s,
                style: context.textStyles.bodyMedium?.copyWith(
                  color: c.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A round, quiet icon button for [ScreenHeader] actions.
class HeaderIconButton extends StatelessWidget {
  const HeaderIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: c.surfaceBase,
        shape: CircleBorder(side: BorderSide(color: c.borderSubtle)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox.square(
            dimension: 38,
            child: Icon(icon, size: 19, color: c.textPrimary),
          ),
        ),
      ),
    );
  }
}

/// A small rounded label: "3 items", "This week".
class CountPill extends StatelessWidget {
  const CountPill({super.key, required this.label, this.color, this.onColor});

  final String label;
  final Color? color;
  final Color? onColor;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? c.surfaceSunken,
        borderRadius: AppRadius.pillAll,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + AppSpacing.xxs,
          vertical: AppSpacing.xxs,
        ),
        child: Text(
          label,
          style: context.textStyles.labelSmall?.copyWith(
            color: onColor ?? c.textSecondary,
          ),
        ),
      ),
    );
  }
}
