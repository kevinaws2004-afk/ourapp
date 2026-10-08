import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/keys/activity_color_key.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/activity_badge.dart';
import '../../../shared/widgets/progress_bar.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../domain/challenge_progress.dart';
import '../domain/challenge_use_cases.dart';

/// Today's state in words: "Done today", "Not yet today — streak at risk"…
String challengeTodayText(AppLocalizations l10n, ChallengeToday state) =>
    switch (state) {
      ChallengeToday.done => l10n.challengeTodayDone,
      ChallengeToday.atRisk => l10n.challengeTodayAtRisk,
      ChallengeToday.notYet => l10n.challengeTodayNotYet,
      ChallengeToday.completed => l10n.challengeCompleted,
    };

/// The state with an icon: a check once done or completed, a clock while
/// today is still open. The text stays in the normal text colors; only the
/// icon carries the state color.
class ChallengeStateLine extends StatelessWidget {
  const ChallengeStateLine({super.key, required this.state});

  final ChallengeToday state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final (icon, color) = switch (state) {
      ChallengeToday.done ||
      ChallengeToday.completed => (AppIcons.taskDone, colors.success),
      ChallengeToday.atRisk => (AppIcons.time, colors.warning),
      ChallengeToday.notYet => (AppIcons.time, colors.textTertiary),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            challengeTodayText(l10n, state),
            style: context.textStyles.labelLarge?.copyWith(
              color: colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// A challenge at a glance: its activity's badge, its name, progress out of
/// the target, the running streak and today's state (ADR-044). Shown on
/// Today and in the list under Me.
class ChallengeCard extends ConsumerWidget {
  const ChallengeCard({super.key, required this.view, required this.onTap});

  final ChallengeView view;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final challenge = view.challenge;
    final progress = view.progress;
    final type = ref
        .watch(activityTypeProvider(challenge.activityTypeId))
        .value;
    final key =
        ActivityColorKey.fromName(type?.colorKey ?? '') ??
        ActivityColorKey.slate;
    final palette = context.tokens.activity(key);
    final quiet = context.textStyles.bodyMedium?.copyWith(
      color: context.colors.textSecondary,
    );
    final summary = [
      l10n.challengeProgressDays(progress.progress, progress.targetDays),
      if (progress.currentStreak > 0)
        l10n.challengeStreakDays(progress.currentStreak),
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: palette.soft,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ActivityBadge(
                  iconId: type?.iconId ?? 'sparkle',
                  colorKey: type?.colorKey ?? key.name,
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        challenge.title,
                        style: context.textStyles.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppProgressBar(
                        fraction: progress.fraction,
                        color: palette.solid,
                        semanticLabel: summary,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(summary, style: quiet),
                      const SizedBox(height: AppSpacing.xs),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ChallengeStateLine(state: progress.today),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
