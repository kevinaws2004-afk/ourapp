import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/tokens/typography.dart';
import '../../../core/time/clock_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/fact_pill.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../../shared/widgets/streak_badge.dart';
import '../../activity_logs/presentation/value_formatting.dart';
import '../../challenges/presentation/challenge_providers.dart';
import '../../focus/domain/focus_session.dart';
import '../../focus/presentation/focus_providers.dart';
import '../../focus/presentation/focus_screen.dart';
import '../../plans/domain/day_progress.dart';
import '../../plans/domain/plan.dart';
import '../../plans/domain/watch_day_overview.dart';
import '../../plans/presentation/plan_actions.dart';
import '../../plans/presentation/plan_formatting.dart';

/// Today's Now/Next card (ADR-046): the one thing to do now ([upNext]) with
/// one action.
/// - RUNNING: big live time, **Finish** (done; "How did it go?" if it has
///   meaningful details; stays on Today)
/// - NOW / NEXT · 9:30 ("in 20 min") / ANYTIME: **Start** for something
///   timed (starts its timer and opens it), else **Done**
///
/// Tapping the card opens the thing.
class NowNextCard extends ConsumerWidget {
  const NowNextCard({
    super.key,
    required this.item,
    required this.onOpenItem,
    required this.onStart,
  });

  final PlannedItem item;
  final ValueChanged<PlanId> onOpenItem;

  /// Starts [item]'s timer and opens it.
  final ValueChanged<PlannedItem> onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final plan = item.plan;
    final type = item.type;
    final now = ref.watch(clockProvider).nowUtc();
    final kind = NowNextKind.of(item, now);
    final session = ref.watch(activeFocusSessionProvider).value;
    final streak = type == null
        ? null
        : ref.watch(activityStreaksProvider)[type.id];
    final timed = type == null || type.supportsTimer;
    final start = formatPlanStart(context, plan);

    final label = switch (kind) {
      NowNextKind.running => l10n.nowNextRunning,
      NowNextKind.now => l10n.nowNextNow,
      NowNextKind.next => l10n.nowNextNext(start!),
      NowNextKind.anytime => l10n.nowNextAnytime,
    };
    String? soon;
    if (kind == NowNextKind.next) {
      final wait = plan.plannedStartAt!.difference(now).inMilliseconds;
      if (wait > 60000) soon = l10n.todayUpNextIn(formatDuration(l10n, wait));
    }

    final Widget action;
    if (kind == NowNextKind.running && session != null) {
      action = AppButton(
        label: l10n.focusFinish,
        icon: AppIcons.check,
        variant: AppButtonVariant.action,
        expand: true,
        onPressed: () => unawaited(
          PlanActions(
            context,
            ref,
          ).finish(session, title: plan.title, type: type),
        ),
      );
    } else if (timed && session == null) {
      action = AppButton(
        label: l10n.todayUpNextStart,
        icon: AppIcons.start,
        variant: AppButtonVariant.action,
        expand: true,
        onPressed: () => onStart(item),
      );
    } else {
      action = AppButton(
        label: l10n.itemDone,
        icon: AppIcons.check,
        variant: AppButtonVariant.action,
        expand: true,
        onPressed: () => unawaited(PlanActions(context, ref).complete(item)),
      );
    }

    final length = plan.plannedLengthMs;
    return AppCard(
      onTap: () => onOpenItem(plan.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Flexible(
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusChip(
                      label: label.toUpperCase(),
                      tone: StatusTone.active,
                      filled: true,
                    ),
                    if (soon != null)
                      Text(
                        soon,
                        style: context.textStyles.labelMedium?.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              if (streak != null) StreakBadge(days: streak.days),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(plan.title, style: context.textStyles.headlineSmall),
          if (kind == NowNextKind.running && session != null)
            _LiveTime(session: session)
          else ...[
            if (plan.notes case final notes? when notes.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                notes.trim().split('\n').first,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.bodyLarge?.copyWith(
                  color: c.textSecondary,
                ),
              ),
            ],
            if (start != null || length != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  if (start != null)
                    FactPill(
                      icon: AppIcons.time,
                      label: l10n.todayFactTime,
                      value: switch (formatPlanEnd(context, plan)) {
                        final end? => l10n.planTimeRange(start, end),
                        null => start,
                      },
                    ),
                  if (length != null)
                    FactPill(
                      icon: AppIcons.timer,
                      label: l10n.todayFactLength,
                      value: formatDuration(l10n, length),
                    ),
                ],
              ),
            ],
          ],
          const SizedBox(height: AppSpacing.xl),
          action,
        ],
      ),
    );
  }
}

class _LiveTime extends ConsumerWidget {
  const _LiveTime({required this.session});

  final FocusSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(focusTickProvider);
    final now = ref.watch(clockProvider).nowUtc();
    return Text(
      formatTimer(session.elapsedMs(now)),
      style: AppTypography.numericLarge.copyWith(
        color: context.colors.textPrimary,
      ),
    );
  }
}
