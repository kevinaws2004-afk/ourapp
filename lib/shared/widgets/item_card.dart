import 'package:flutter/material.dart';

import '../../core/design/context_ext.dart';
import '../../core/design/tokens/spacing.dart';
import 'app_card.dart';

/// One item on a day as a card (ADR-045): [leading] (the activity badge),
/// then a meta row ([time] and a status [chip]), the [title] and an optional
/// [summary] of what was logged, then [trailing] actions (the done check).
/// [faded] dims it (skipped, cancelled).
class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.title,
    required this.onTap,
    this.leading,
    this.time,
    this.chip,
    this.summary,
    this.trailing = const [],
    this.onLongPress,
    this.faded = false,
    this.tapHint,
    this.longPressHint,
  });

  final Widget? leading;
  final String? time;
  final Widget? chip;
  final String title;
  final String? summary;
  final List<Widget> trailing;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool faded;

  /// What a tap does, for screen readers (ADR-030).
  final String? tapHint;
  final String? longPressHint;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final body = Row(
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: AppSpacing.md),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (time != null || chip != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (time != null)
                        Text(
                          time!,
                          style: context.textStyles.labelMedium?.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                      ?chip,
                    ],
                  ),
                ),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.titleMedium,
              ),
              if (summary != null && summary!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xxs),
                  child: Text(
                    summary!,
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
        ...trailing,
      ],
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Semantics(
        onTapHint: tapHint,
        onLongPressHint: longPressHint,
        child: AppCard(
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
