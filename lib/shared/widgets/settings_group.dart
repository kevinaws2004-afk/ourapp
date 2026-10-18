import 'package:flutter/material.dart';

import '../../core/design/app_icons.dart';
import '../../core/design/context_ext.dart';
import '../../core/design/tokens/radius.dart';
import '../../core/design/tokens/spacing.dart';
import 'app_card.dart';

/// A titled group of rows in one card, divided by hairlines (Me, settings).
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, this.title, required this.children});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title case final t?)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.xs,
                bottom: AppSpacing.sm,
              ),
              child: Semantics(
                header: true,
                child: Text(
                  t.toUpperCase(),
                  style: context.textStyles.labelSmall?.copyWith(
                    color: c.textTertiary,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          AppCard(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: AppRadius.cardAll,
              child: Column(
                children: [
                  for (final (i, child) in children.indexed) ...[
                    if (i > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 68),
                        child: Divider(height: 1, color: c.borderSubtle),
                      ),
                    child,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One row of a [SettingsGroup]: a tinted icon tile, a title, an optional
/// value or subtitle, and a chevron (or [trailing]).
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.onTap,
    this.trailing,
    this.iconColor,
    this.iconBackground,
    this.destructive = false,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  /// A short current value shown on the right ("Lavender").
  final String? value;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;
  final Color? iconBackground;
  final bool destructive;

  /// Off: shown dimmed, as a setting that doesn't apply right now (its
  /// switch or parent is off).
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = destructive ? c.danger : (iconColor ?? c.brandPrimary);
    final bg = destructive
        ? c.dangerContainer
        : (iconBackground ?? c.brandPrimarySoft);
    // Each row is its own node for screen readers, even without a tap
    // action, and reads as one ("Focus round, 25 min").
    // A row with only a switch flips it when tapped anywhere.
    var tap = onTap;
    final toggle = trailing;
    if (tap == null && toggle is Switch) {
      if (toggle.onChanged case final changed?) {
        tap = () => changed(!toggle.value);
      }
    }
    final row = InkWell(
      onTap: enabled ? tap : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: AppRadius.smAll,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 20, color: fg),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textStyles.titleMedium?.copyWith(
                        color: destructive ? c.danger : null,
                      ),
                    ),
                    if (subtitle case final s?)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xxs),
                        child: Text(
                          s,
                          style: context.textStyles.bodySmall?.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // A long value shares the row instead of squeezing the title
              // away.
              if (value case final v?)
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.sm),
                    child: Text(
                      v,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                ),
              if (trailing case final t?)
                t
              else if (onTap != null)
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.xs),
                  child: Icon(
                    AppIcons.chevron,
                    size: 18,
                    color: c.textTertiary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    return MergeSemantics(
      child: Semantics(
        container: true,
        enabled: enabled,
        child: enabled ? row : Opacity(opacity: 0.45, child: row),
      ),
    );
  }
}
