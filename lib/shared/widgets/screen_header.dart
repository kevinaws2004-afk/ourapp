import 'package:flutter/material.dart';

import 'app_logo.dart';

import '../../core/design/context_ext.dart';
import '../../core/design/tokens/color_tokens.dart';
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
    this.leading,
  });

  final String title;

  /// Shown on the left instead of the logo (a back button).
  final Widget? leading;
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
              if (leading case final l?) ...[
                l,
                const SizedBox(width: AppSpacing.sm + AppSpacing.xxs),
              ] else if (showMark) ...[
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
    this.label,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  /// A short word next to the icon, for actions an icon alone doesn't say
  /// ("Report", "Chart"). At large text sizes the button is the round icon
  /// alone (the label stays in its tooltip and semantics), so the header
  /// keeps its title.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Its own node, so a reader never folds it into the title.
    return Semantics(container: true, button: true, child: _button(context, c));
  }

  Widget _button(BuildContext context, AppColors c) {
    final roomy = MediaQuery.textScalerOf(context).scale(1) <= 1.3;
    if (label case final text? when roomy) {
      return Tooltip(
        message: tooltip,
        child: Material(
          color: c.surfaceBase,
          shape: StadiumBorder(side: BorderSide(color: c.borderSubtle)),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onPressed,
            child: SizedBox(
              height: 38,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 17, color: c.textPrimary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      text,
                      style: context.textStyles.labelLarge?.copyWith(
                        color: c.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Tooltip(
      message: label ?? tooltip,
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
