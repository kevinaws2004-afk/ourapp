import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/activity_palette.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/tokens/typography.dart';
import '../../../core/time/clock_provider.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/activity_badge.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/progress_ring.dart';
import '../../../shared/widgets/segmented_tabs.dart';
import '../../activity_logs/presentation/value_formatting.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../../challenges/domain/challenge.dart';
import '../../challenges/domain/challenge_use_cases.dart';
import '../../challenges/presentation/challenge_providers.dart';
import '../../plans/presentation/plan_date_notifier.dart';
import '../domain/insight.dart';
import '../domain/insight_repository.dart';
import 'insight_formatting.dart';
import 'insight_providers.dart';

/// Week · Month · 3 months · Year as one segmented control.
class ProgressRangeTabs extends ConsumerWidget {
  const ProgressRangeTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return SegmentedTabs<InsightRange>(
      values: InsightRange.values,
      selected: ref.watch(insightRangeProvider),
      label: (r) => rangeLabel(l10n, r),
      onSelect: ref.read(insightRangeProvider.notifier).select,
    );
  }
}

/// The period at a glance: four numbers, each against the period before.
class ProgressSummaryGrid extends ConsumerWidget {
  const ProgressSummaryGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final summary = ref.watch(insightSummaryProvider).value;
    final days = ref.watch(planAdherenceProvider).value;
    final range = ref.watch(insightRangeProvider);
    final today = currentLocalDate(ref.watch(clockProvider));
    if (summary == null) return const SizedBox(height: 180);

    final (from, to) = range.window(today);
    final (prevFrom, prevTo) = range.previous(today);
    ({int planned, int done}) sum(LocalDate a, LocalDate b) {
      var planned = 0;
      var done = 0;
      for (final d in days ?? const <PlanDay>[]) {
        if (d.date.compareTo(a) < 0 || d.date.compareTo(b) > 0) continue;
        planned += d.planned;
        done += d.done;
      }
      return (planned: planned, done: done);
    }

    final plans = sum(from, to);
    final prevPlans = sum(prevFrom, prevTo);
    int? share(({int planned, int done}) s) =>
        s.planned == 0 ? null : (s.done * 100 / s.planned).round();
    final hit = share(plans);
    final prevHit = share(prevPlans);

    double? change(num now, num before) =>
        before == 0 ? null : (now - before) / before;

    final c = context.colors;
    final tiles = [
      _Stat(
        icon: AppIcons.check,
        tint: c.action,
        label: l10n.statDone,
        value: '${summary.count}',
        change: change(summary.count, summary.previousCount),
      ),
      _Stat(
        icon: AppIcons.timer,
        tint: c.brandPrimary,
        label: l10n.statTime,
        value: summary.durationMs == 0
            ? '0m'
            : formatDuration(l10n, summary.durationMs),
        change: change(summary.durationMs, summary.previousDurationMs),
      ),
      _Stat(
        icon: AppIcons.dayDone,
        tint: c.accent,
        label: l10n.statActiveDays,
        value: l10n.statOfDays(summary.daysActive, range.days),
        change: change(summary.daysActive, summary.previousDaysActive),
      ),
      _Stat(
        icon: AppIcons.goal,
        tint: c.warning,
        label: l10n.statPlanHit,
        value: hit == null ? '–' : '$hit%',
        change: hit == null || prevHit == null || prevHit == 0
            ? null
            : (hit - prevHit) / prevHit,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 560 ? 4 : 2;
        const gap = AppSpacing.md;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final t in tiles) SizedBox(width: width, child: t),
          ],
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.tint,
    required this.label,
    required this.value,
    required this.change,
  });

  final IconData icon;
  final Color tint;
  final String label;
  final String value;

  /// Against the period before, as a fraction (0.12 = +12 %).
  final double? change;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final change = this.change;
    final up = change != null && change >= 0;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.14),
                  borderRadius: AppRadius.smAll,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 17, color: tint),
              ),
              const Spacer(),
              if (change != null && change.abs() >= 0.005)
                _ChangePill(change: change, up: up),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: AppTypography.numericLarge.copyWith(
                color: c.textPrimary,
                fontSize: 26,
              ),
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.bodySmall?.copyWith(
              color: c.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// "▲ 12%" in green, "▼ 8%" in the warning color.
class _ChangePill extends StatelessWidget {
  const _ChangePill({required this.change, required this.up});

  final double change;
  final bool up;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = up ? c.success : c.warning;
    final pct = (change.abs() * 100).round();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            up ? AppIcons.trendUp : AppIcons.trendDown,
            size: 12,
            color: color,
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            pct > 999 ? '999+%' : '$pct%',
            style: context.textStyles.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

/// An insight in words, with a spark: the first thing Progress tells you.
class InsightSentenceCard extends StatelessWidget {
  const InsightSentenceCard({
    super.key,
    required this.sentence,
    this.detail,
    this.icon = AppIcons.sparkle,
  });

  final String sentence;
  final String? detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: c.brandPrimarySoft,
                borderRadius: AppRadius.smAll,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 18, color: c.brandPrimary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sentence, style: context.textStyles.titleMedium),
                  if (detail case final d?) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      d,
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Your running goals as a scrolling row of rings, with a way to set one.
class GoalsStrip extends ConsumerWidget {
  const GoalsStrip({
    super.key,
    required this.onOpenGoal,
    required this.onOpenGoals,
    required this.margin,
  });

  final ValueChanged<ChallengeId> onOpenGoal;
  final VoidCallback onOpenGoals;
  final double margin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final views = ref.watch(challengesProvider).value;
    if (views == null) return const SizedBox(height: 8);
    final running = [
      for (final v in views)
        if (!v.progress.isCompleted) v,
    ];
    final types = {
      for (final t
          in ref.watch(activeActivityTypesProvider).value ??
              const <ActivityType>[])
        t.id: t,
    };
    if (running.isEmpty) {
      return _SetGoalCard(onTap: onOpenGoals, label: l10n.goalsEmptyCta);
    }
    return SizedBox(
      height: 168,
      child: LayoutBuilder(
        builder: (context, constraints) => OverflowBox(
          maxWidth: constraints.maxWidth + 2 * margin,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: margin),
            itemCount: running.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, i) => i == running.length
                ? SizedBox(
                    width: 140,
                    child: _SetGoalCard(
                      onTap: onOpenGoals,
                      label: l10n.goalsNew,
                      compact: true,
                    ),
                  )
                : _GoalCard(
                    view: running[i],
                    type: types[running[i].challenge.activityTypeId],
                    onTap: () => onOpenGoal(running[i].challenge.id),
                  ),
          ),
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.view,
    required this.type,
    required this.onTap,
  });

  final ChallengeView view;
  final ActivityType? type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final p = view.progress;
    final color = type == null
        ? c.brandPrimary
        : context.tokens
              .activity(
                ActivityColorKey.fromName(type!.colorKey) ??
                    ActivityColorKey.slate,
              )
              .solid;
    return SizedBox(
      width: 156,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ProgressRing(
                  fraction: p.fraction.clamp(0, 1),
                  semanticLabel: l10n.goalProgress(
                    p.daysDone.clamp(0, p.targetDays),
                    p.targetDays,
                  ),
                  size: 52,
                  stroke: 6,
                  color: color,
                  child: type == null
                      ? null
                      : ActivityBadge(
                          iconId: type!.iconId,
                          colorKey: type!.colorKey,
                          size: 30,
                        ),
                ),
                const Spacer(),
                if (p.currentStreak > 0)
                  Row(
                    children: [
                      Icon(AppIcons.streak, size: 14, color: c.warning),
                      Text(
                        '${p.currentStreak}',
                        style: context.textStyles.labelMedium?.copyWith(
                          color: c.warning,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const Spacer(),
            Text(
              view.challenge.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              l10n.goalProgress(
                p.daysDone.clamp(0, p.targetDays),
                p.targetDays,
              ),
              style: context.textStyles.bodySmall?.copyWith(
                color: c.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetGoalCard extends StatelessWidget {
  const _SetGoalCard({
    required this.onTap,
    required this.label,
    this.compact = false,
  });

  final VoidCallback onTap;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final icon = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: c.brandPrimarySoft,
        borderRadius: AppRadius.mdAll,
      ),
      alignment: Alignment.center,
      child: Icon(AppIcons.trophy, color: c.brandPrimary, size: 22),
    );
    return DottedCard(
      onTap: onTap,
      child: compact
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(height: AppSpacing.sm),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: context.textStyles.labelLarge?.copyWith(
                    color: c.brandPrimary,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                icon,
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: context.textStyles.titleMedium),
                      Text(
                        l10n.goalsEmptyHint,
                        style: context.textStyles.bodySmall?.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(AppIcons.chevron, size: 18, color: c.textTertiary),
              ],
            ),
    );
  }
}

/// A soft, outlined call-to-action card.
class DottedCard extends StatelessWidget {
  const DottedCard({super.key, required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: Color.alphaBlend(
        c.brandPrimarySoft.withValues(alpha: 0.35),
        c.surfaceCanvas,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardAll,
        side: BorderSide(
          color: c.brandPrimary.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: AppRadius.cardAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: child,
        ),
      ),
    );
  }
}
