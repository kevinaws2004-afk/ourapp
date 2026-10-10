import 'package:flutter/material.dart';

import '../../core/design/app_icons.dart';
import '../../core/design/context_ext.dart';
import '../../l10n/generated/app_localizations.dart';

/// 🔥 and a streak's days ("13"), on an activity that's in a running
/// challenge (ADR-046). Read as "13 day streak".
class StreakBadge extends StatelessWidget {
  const StreakBadge({super.key, required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: AppLocalizations.of(context).streakBadgeLabel(days),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.streak, size: 16, color: c.accentDawn),
          const SizedBox(width: 2),
          Text(
            '$days',
            style: context.textStyles.labelMedium?.copyWith(
              color: c.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
