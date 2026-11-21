import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/tokens/typography.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/text_input_dialog.dart';
import '../../challenges/presentation/challenge_providers.dart';
import '../domain/day_streak.dart';
import 'garden_providers.dart';
import 'plant_view.dart';

/// The plant's name: the person's, or "Sprout".
String plantNameOf(AppLocalizations l10n, WidgetRef ref) =>
    ref.watch(plantNameProvider).value ?? l10n.gardenPlantName;

String stageName(AppLocalizations l10n, PlantStage stage) => switch (stage) {
  PlantStage.seed => l10n.stageSeed,
  PlantStage.sprout => l10n.stageSprout,
  PlantStage.seedling => l10n.stageSeedling,
  PlantStage.young => l10n.stageYoung,
  PlantStage.budding => l10n.stageBudding,
  PlantStage.blooming => l10n.stageBlooming,
  PlantStage.tree => l10n.stageTree,
  PlantStage.grandTree => l10n.stageGrandTree,
};

/// Today's plant and day streak: watered (something done today) or
/// thirsty, what keeps the streak, and the rest days saved. Opens the
/// garden.
class GardenCard extends ConsumerWidget {
  const GardenCard({super.key, required this.onOpenYear});

  /// Opens the year in pixels.
  final VoidCallback onOpenYear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final streak = ref.watch(dayStreakProvider);
    if (streak == null) return const SizedBox.shrink();
    final name = plantNameOf(l10n, ref);
    final stage = PlantStage.of(streak.totalDays);
    final line = switch (streak) {
      DayStreak(doneToday: true) => l10n.gardenWatered(name),
      DayStreak(current: > 0) => l10n.gardenAtRisk(name),
      DayStreak(totalDays: 0) => l10n.gardenFirst(name),
      _ => l10n.gardenRestart(name),
    };
    final small = context.textStyles.labelMedium?.copyWith(
      color: c.textSecondary,
      fontWeight: FontWeight.w600,
    );
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Semantics(
        button: true,
        hint: l10n.gardenOpenHint,
        child: AppCard(
          onTap: () => unawaited(showGarden(context, onOpenYear: onOpenYear)),
          color: streak.atRisk ? c.warning.withValues(alpha: 0.08) : null,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              PlantView(stage: stage, thirsty: !streak.doneToday, size: 64),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (streak.current > 0) ...[
                          Icon(
                            AppIcons.streak,
                            size: 18,
                            color: streak.doneToday
                                ? c.warning
                                : c.textTertiary,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: Text(
                            streak.current > 0
                                ? l10n.gardenStreak(streak.current)
                                : l10n.gardenStartTitle,
                            style: context.textStyles.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      line,
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                    if (streak.current > 0) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        streak.restDays > 0
                            ? '❄ ${l10n.gardenRestDays(streak.restDays)}'
                            : l10n.gardenNextRestDay(streak.daysToRestDay),
                        style: small,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(AppIcons.chevron, color: c.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

/// The garden: the plant big, its name (tap to rename), how far to its
/// next stage, the streak numbers, how it works, and milestones.
Future<void> showGarden(BuildContext context, {VoidCallback? onOpenYear}) =>
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => _GardenSheet(onOpenYear: onOpenYear),
    );

class _GardenSheet extends ConsumerWidget {
  const _GardenSheet({this.onOpenYear});

  final VoidCallback? onOpenYear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final streak = ref.watch(dayStreakProvider) ?? DayStreak.empty;
    final name = plantNameOf(l10n, ref);
    final stage = PlantStage.of(streak.totalDays);
    final next = stage.next;
    final badges = gardenBadges(l10n, ref, streak);
    final earned = badges.where((b) => b.earned).length;

    Widget stat(String label, String value) => Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.numericLarge.copyWith(color: c.textPrimary),
          ),
          Text(
            label,
            style: context.textStyles.labelMedium?.copyWith(
              color: c.textSecondary,
            ),
          ),
        ],
      ),
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        children: [
          Center(
            child: PlantView(
              stage: stage,
              thirsty: !streak.doneToday,
              size: 140,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: TextButton.icon(
              onPressed: () async {
                final picked = await showTextInputDialog(
                  context,
                  title: l10n.gardenRename,
                  initial: ref.read(plantNameProvider).value ?? '',
                  hint: l10n.gardenRenameHint,
                  maxLength: 20,
                  capitalization: TextCapitalization.words,
                );
                if (picked != null) await renamePlant(ref, picked);
              },
              icon: const Icon(AppIcons.edit, size: 16),
              label: Text(
                name,
                style: context.textStyles.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          Text(
            '${l10n.gardenSheetDays(streak.totalDays)} · ${stageName(l10n, stage)}',
            textAlign: TextAlign.center,
            style: context.textStyles.bodyMedium?.copyWith(
              color: c.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (next != null) ...[
            ClipRRect(
              borderRadius: AppRadius.pillAll,
              child: LinearProgressIndicator(
                value:
                    (streak.totalDays - stage.fromDays) /
                    (next.fromDays - stage.fromDays),
                minHeight: 8,
                backgroundColor: c.surfaceSunken,
                color: c.action,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.gardenToNext(
                next.fromDays - streak.totalDays,
                stageName(l10n, next),
              ),
              textAlign: TextAlign.center,
              style: context.textStyles.labelMedium?.copyWith(
                color: c.textSecondary,
              ),
            ),
          ] else
            Text(
              l10n.gardenTopStage,
              textAlign: TextAlign.center,
              style: context.textStyles.labelMedium,
            ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Row(
              children: [
                stat(l10n.gardenStatStreak, '${streak.current}'),
                stat(l10n.gardenStatBest, '${streak.best}'),
                stat(l10n.gardenStatRest, '${streak.restDays}'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.gardenHowTitle, style: context.textStyles.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          for (final (icon, text) in [
            (AppIcons.streak, l10n.gardenHow1),
            (AppIcons.breakTime, l10n.gardenHow2),
            (AppIcons.heart, l10n.gardenHow3),
          ])
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 18, color: c.brandPrimary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(text, style: context.textStyles.bodyMedium),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.gardenBadges,
                  style: context.textStyles.titleMedium,
                ),
              ),
              Text(
                l10n.gardenBadgesCount(earned, badges.length),
                style: context.textStyles.labelMedium?.copyWith(
                  color: c.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = AppSpacing.sm;
              final columns = constraints.maxWidth > 420 ? 4 : 3;
              final width =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final b in badges)
                    SizedBox(
                      width: width,
                      child: _BadgeTile(badge: b),
                    ),
                ],
              );
            },
          ),
          if (onOpenYear case final open?) ...[
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                open();
              },
              icon: const Icon(AppIcons.dayDone),
              label: Text(l10n.gardenYear),
            ),
          ],
        ],
      ),
    );
  }
}

/// A milestone: earned, or still to come (with how to get it).
class GardenBadge {
  const GardenBadge(this.icon, this.title, this.hint, {required this.earned});

  final String icon;
  final String title;
  final String hint;
  final bool earned;
}

/// The milestones, from what's already known (streaks, days, goals and
/// check-ins). Nothing stored: earned is worked out each time.
List<GardenBadge> gardenBadges(
  AppLocalizations l10n,
  WidgetRef ref,
  DayStreak s,
) {
  final goalsDone =
      ref.watch(challengesProvider).value?.any((v) => v.progress.isCompleted) ??
      false;
  final checkIns = ref.watch(checkInsProvider).value?.length ?? 0;
  return [
    GardenBadge(
      '🌱',
      l10n.badgeFirstDay,
      l10n.badgeFirstDayHint,
      earned: s.totalDays >= 1,
    ),
    GardenBadge(
      '🔥',
      l10n.badgeStreak3,
      l10n.badgeStreak3Hint,
      earned: s.best >= 3,
    ),
    GardenBadge(
      '⭐',
      l10n.badgeStreak7,
      l10n.badgeStreak7Hint,
      earned: s.best >= 7,
    ),
    GardenBadge(
      '❄️',
      l10n.badgeRestDay,
      l10n.badgeRestDayHint,
      earned: s.restedOn.isNotEmpty,
    ),
    GardenBadge(
      '🔟',
      l10n.badgeDays10,
      l10n.badgeDays10Hint,
      earned: s.totalDays >= 10,
    ),
    GardenBadge(
      '🌸',
      l10n.badgeBloom,
      l10n.badgeBloomHint,
      earned: s.totalDays >= PlantStage.blooming.fromDays,
    ),
    GardenBadge('🏆', l10n.badgeGoal, l10n.badgeGoalHint, earned: goalsDone),
    GardenBadge(
      '💭',
      l10n.badgeCheckIns,
      l10n.badgeCheckInsHint,
      earned: checkIns >= 7,
    ),
    GardenBadge(
      '🌙',
      l10n.badgeStreak30,
      l10n.badgeStreak30Hint,
      earned: s.best >= 30,
    ),
    GardenBadge(
      '🌳',
      l10n.badgeDays50,
      l10n.badgeDays50Hint,
      earned: s.totalDays >= 50,
    ),
    GardenBadge(
      '💯',
      l10n.badgeStreak100,
      l10n.badgeStreak100Hint,
      earned: s.best >= 100,
    ),
    GardenBadge(
      '👑',
      l10n.badgeDays100,
      l10n.badgeDays100Hint,
      earned: s.totalDays >= 100,
    ),
  ];
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge});

  final GardenBadge badge;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tooltip(
      message: badge.hint,
      triggerMode: TooltipTriggerMode.tap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: badge.earned ? c.brandPrimarySoft : c.surfaceSunken,
          borderRadius: AppRadius.lgAll,
          border: badge.earned
              ? Border.all(color: c.brandPrimary, width: 1.5)
              : null,
        ),
        child: Column(
          children: [
            Opacity(
              opacity: badge.earned ? 1 : 0.3,
              child: Text(badge.icon, style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              badge.title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: badge.earned ? c.textPrimary : c.textTertiary,
              ),
            ),
            if (!badge.earned)
              Text(
                badge.hint,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.labelSmall?.copyWith(
                  color: c.textTertiary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
