import 'package:flutter/material.dart';

import '../../core/design/app_icons.dart';
import '../../core/design/context_ext.dart';
import '../../l10n/generated/app_localizations.dart';

/// 🔥 and a streak's days ("13"), on an activity that's in a running
/// challenge (ADR-046). Read as "13 day streak".
class StreakBadge extends StatelessWidget {
  const StreakBadge({super.key, required this.days, this.compact = false});

  final int days;

  /// Smaller, in the warm streak color (next to a title on a row).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    // No streak yet (or it broke): nothing to show, not a "0".
    if (days <= 0) return const SizedBox.shrink();
    final c = context.colors;
    return Semantics(
      label: AppLocalizations.of(context).streakBadgeLabel(days),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.streak,
            size: compact ? 13 : 16,
            color: compact ? c.warning : c.accentDawn,
          ),
          const SizedBox(width: 2),
          Text(
            '$days',
            style:
                (compact
                        ? context.textStyles.labelSmall
                        : context.textStyles.labelMedium)
                    ?.copyWith(
                      color: compact ? c.warning : c.textPrimary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
          ),
        ],
      ),
    );
  }
}
