import 'package:flutter/material.dart';

import '../../core/design/app_icons.dart';
import '../../core/design/context_ext.dart';
import '../../core/design/tokens/sizes.dart';
import '../../core/design/tokens/spacing.dart';
import 'app_card.dart';
import 'status_chip.dart';
import 'streak_badge.dart';

/// One thing on a day (ADR-046), the same on Today and in Plan: the
/// activity's icon tile, then a top line with its time and a status chip
/// ("Done", "Scheduled", "Running"), its name, and one quiet detail line
/// (its length, its result once done). A 🔥 streak when its activity is in a
/// running goal, then [trailing] (the done circle). Options are a
/// long-press.
class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.title,
    required this.onTap,
    this.leading,
    this.startTime,
    this.endTime,
    this.subline,
    this.status,
    this.statusTone = StatusTone.neutral,
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

  /// A short state shown as a chip next to the time ("Done").
  final String? status;
  final StatusTone statusTone;

  /// Current streak days, if its activity is in a running goal.
  final int? streak;

  /// It repeats (ADR-036): a small mark by its title.
  final bool repeats;
  final List<Widget> trailing;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  /// Skipped: dimmed.
  final bool faded;

  /// Its time is now: outlined in the theme's color.
  final bool emphasized;

  /// What a tap does, for screen readers (ADR-030).
  final String? tapHint;
  final String? longPressHint;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final start = startTime;
    final time = start == null
        ? null
        : endTime == null
        ? start
        : '$start – $endTime';
    final hasTop = time != null || status != null;

    final body = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (leading case final l?) ...[
          l,
          const SizedBox(width: AppSpacing.md),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasTop)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xxs + 1),
                  child: Row(
                    children: [
                      if (time != null)
                        Flexible(
                          child: Text(
                            time,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textStyles.labelMedium?.copyWith(
                              color: emphasized
                                  ? c.brandPrimary
                                  : c.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                      if (time != null && status != null)
                        const SizedBox(width: AppSpacing.sm),
                      if (status case final s?)
                        StatusChip(label: s, tone: statusTone),
                    ],
                  ),
                ),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (repeats) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      AppIcons.repeat,
                      size: AppSizes.iconSmall - 4,
                      color: c.textTertiary,
                    ),
                  ],
                ],
              ),
              if (subline case final s? when s.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xxs),
                  child: Text(
                    s,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodySmall?.copyWith(
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
      padding: const EdgeInsets.only(bottom: AppSpacing.sm + AppSpacing.xxs),
      child: Semantics(
        onTapHint: tapHint,
        onLongPressHint: longPressHint,
        child: DecoratedBox(
          decoration: emphasized
              ? BoxDecoration(
                  borderRadius: _radius,
                  border: Border.all(color: c.brandPrimary, width: 1.5),
                )
              : const BoxDecoration(),
          child: Material(
            type: MaterialType.transparency,
            child: Ink(
              decoration: cardDecoration(
                context,
                borderRadius: _radius,
                flat: !emphasized,
              ),
              child: InkWell(
                borderRadius: _radius,
                onTap: onTap,
                onLongPress: onLongPress,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md + 2,
                    AppSpacing.md + 2,
                    AppSpacing.xxs,
                    AppSpacing.md + 2,
                  ),
                  child: Opacity(opacity: faded ? 0.5 : 1, child: body),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const _radius = BorderRadius.all(Radius.circular(20));
}
