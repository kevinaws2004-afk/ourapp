import 'package:flutter/material.dart';

import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/tokens/typography.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/progress_ring.dart';
import '../../plans/domain/day_progress.dart';

/// The top of Today (ADR-045, ADR-046): the date, a greeting, the status
/// line about the day
/// and a ring of how much of it is done.
class DayHero extends StatelessWidget {
  const DayHero({
    super.key,
    required this.date,
    required this.greeting,
    required this.statusLine,
    required this.progress,
  });

  /// Already formatted ("Saturday, October 3").
  final String date;
  final String greeting;

  /// One sentence about the day (ADR-046): "2 of 5 done · 1 h so far".
  final String statusLine;

  /// Null while the day is loading.
  final DayProgress? progress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final progress = this.progress;
    final line = statusLine;
    final ring = progress == null || progress.isEmpty
        ? null
        : ProgressRing(
            fraction: progress.fraction,
            semanticLabel: l10n.todayProgress(progress.done, progress.total),
            size: 88,
            stroke: 9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${progress.done}/${progress.total}',
                  style: AppTypography.numericMedium.copyWith(
                    color: c.textPrimary,
                  ),
                ),
                Text(
                  l10n.todayRingCenter,
                  style: context.textStyles.labelSmall?.copyWith(
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          );
    return DecoratedBox(
      decoration: cardDecoration(context),
      child: ClipRRect(
        borderRadius: AppRadius.cardAll,
        child: DecoratedBox(
          // A soft glow in the corner, the theme's own wash.
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.bottomLeft,
              radius: 1.1,
              colors: [
                context.tokens.treatments.heroWash,
                c.surfaceBase.withValues(alpha: 0),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: c.brandPrimarySoft,
                          borderRadius: AppRadius.pillAll,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          child: Text(
                            date.toUpperCase(),
                            style: context.textStyles.labelSmall?.copyWith(
                              color: c.onBrandPrimarySoft,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Semantics(
                        header: true,
                        child: Text(
                          greeting,
                          style: context.textStyles.displayMedium,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        line,
                        style: context.textStyles.bodyLarge?.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (ring != null) ...[
                  const SizedBox(width: AppSpacing.md),
                  ring,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
