import 'package:flutter/material.dart';

import '../../core/design/app_icons.dart';
import '../../core/design/context_ext.dart';
import '../../core/design/tokens/sizes.dart';
import '../../core/design/tokens/spacing.dart';
import '../../core/design/tokens/typography.dart';
import 'app_card.dart';
import 'streak_badge.dart';

/// One thing on a day as a timeline row (ADR-046): the time, the name, one
/// sub-line (its length, "Running · 12:04", or its result once done), a 🔥
/// streak when its activity is in a running challenge, then [trailing] (the
/// done circle).
///
/// Themes with a time column put [startTime] (and [endTime]) in a column on
/// the left; others lead with [leading] (the activity badge) and put the
/// time into the sub-line. No per-row chips, menus or handles: options are
/// a long-press.
class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.title,
    required this.onTap,
    this.leading,
    this.startTime,
    this.endTime,
    this.subline,
    this.streak,
    this.repeats = false,
    this.trailing = const [],
    this.onLongPress,
    this.faded = false,
    this.emphasized = false,
    this.tapHint,
    this.longPressHint,
  });

  final Widget? leading;

  /// "07:00"; null for an Anytime thing.
  final String? startTime;
  final String? endTime;
  final String title;
  final String? subline;

  /// Current streak days, if its activity is in a running challenge.
  final int? streak;

  /// It repeats (ADR-036): a small mark by its title.
  final bool repeats;
  final List<Widget> trailing;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  /// Skipped: dimmed.
  final bool faded;

  /// Its time is now: a soft tint.
  final bool emphasized;

  /// What a tap does, for screen readers (ADR-030).
  final String? tapHint;
  final String? longPressHint;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final timeColumn = context.tokens.treatments.timeColumn;
    final start = startTime;
    final sub = [
      if (!timeColumn && start != null)
        endTime == null ? start : '$start–$endTime',
      if (subline case final s? when s.isNotEmpty) s,
    ].join(' · ');
    // A time column only where there's a time (or a badge) to put in it.
    final Widget? lead = !timeColumn
        ? leading
        : start == null
        ? leading
        : SizedBox(
            width: AppSpacing.giant - AppSpacing.sm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    start,
                    maxLines: 1,
                    style: AppTypography.numericMedium.copyWith(
                      fontSize: 16,
                      color: c.textPrimary,
                    ),
                  ),
                ),
                if (endTime case final end?)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      end,
                      maxLines: 1,
                      style: context.textStyles.labelSmall?.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          );
    final body = Row(
      children: [
        if (lead != null) ...[lead, const SizedBox(width: AppSpacing.md)],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.titleMedium,
                    ),
                  ),
                  if (repeats) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      AppIcons.repeat,
                      size: AppSizes.iconSmall,
                      color: c.textTertiary,
                    ),
                  ],
                ],
              ),
              if (sub.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xxs),
                  child: Text(
                    sub,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (streak case final days?) ...[
          const SizedBox(width: AppSpacing.sm),
          StreakBadge(days: days),
        ],
        ...trailing,
      ],
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Semantics(
        onTapHint: tapHint,
        onLongPressHint: longPressHint,
        child: AppCard(
          color: emphasized
              ? Color.alphaBlend(
                  c.brandPrimarySoft.withValues(alpha: 0.6),
                  c.surfaceBase,
                )
              : null,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
          ),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Opacity(opacity: faded ? 0.55 : 1, child: body),
        ),
      ),
    );
  }
}
