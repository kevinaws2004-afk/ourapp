import 'package:flutter/material.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/motion.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/tokens/typography.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/progress_ring.dart';
import '../../activity_logs/presentation/value_formatting.dart';
import '../../plans/domain/day_progress.dart';

/// The top of Today, in one card: the greeting, one line about the
/// day, small facts (done, time tracked, best streak), and a ring of how
/// much is done. Theme colors only.
class DayHero extends StatelessWidget {
  const DayHero({
    super.key,
    required this.greeting,
    required this.statusLine,
    required this.progress,
    this.bestStreak,
  });

  final String greeting;

  /// One sentence about the day: "First up at 7:00".
  final String statusLine;

  /// Null while the day is loading.
  final DayProgress? progress;

  /// The longest running streak among your goals, in days.
  final int? bestStreak;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final progress = this.progress;
    final done = progress?.done ?? 0;
    final total = progress?.total ?? 0;
    final tracked = progress?.recordedMs ?? 0;

    Widget fact(IconData icon, Color color, String text) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: context.textStyles.labelMedium?.copyWith(
              color: c.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    greeting,
                    style: context.textStyles.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      height: 1.15,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  statusLine,
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: c.textSecondary,
                  ),
                ),
                if (total > 0) ...[
                  const SizedBox(height: AppSpacing.sm + 2),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.xs,
                    children: [
                      fact(
                        AppIcons.taskDone,
                        c.success,
                        l10n.heroDoneOf(done, total),
                      ),
                      fact(
                        AppIcons.timer,
                        c.brandPrimary,
                        tracked > 0
                            ? l10n.heroTrackedValue(
                                formatDuration(l10n, tracked),
                              )
                            : l10n.heroTrackedValue('0m'),
                      ),
                      if ((bestStreak ?? 0) > 0)
                        fact(
                          AppIcons.streak,
                          c.warning,
                          l10n.heroStreakLong(bestStreak!),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (total > 0) ...[
            const SizedBox(width: AppSpacing.md),
            TweenAnimationBuilder<double>(
              tween: Tween(end: progress?.fraction ?? 0),
              duration: AppMotion.celebrate,
              curve: AppMotion.emphasizedCurve,
              builder: (context, fraction, _) => ProgressRing(
                fraction: fraction,
                semanticLabel: l10n.todayProgress(done, total),
                size: 64,
                stroke: 6,
                color: c.brandPrimary,
                trackColor: c.brandPrimarySoft,
                child: Text(
                  '${((progress?.fraction ?? 0) * 100).round()}%',
                  style: AppTypography.numericMedium.copyWith(
                    color: c.textPrimary,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
