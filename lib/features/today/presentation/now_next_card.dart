import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/icons/activity_icon_registry.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/tokens/typography.dart';
import '../../../core/time/clock_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../core/design/tokens/activity_palette.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../../shared/widgets/streak_badge.dart';
import '../../activity_logs/presentation/value_formatting.dart';
import '../../challenges/presentation/challenge_providers.dart';
import '../../focus/domain/focus_session.dart';
import '../../focus/presentation/focus_providers.dart';
import '../../focus/presentation/focus_screen.dart';
import '../../focus/presentation/pomodoro_line.dart';
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
    this.onFocusMode,
  });

  /// Focus mode for [item]: its timer (started if needed) full screen, the
  /// phone kept on it.
  final ValueChanged<PlannedItem>? onFocusMode;

  final PlannedItem item;
  final ValueChanged<PlanId> onOpenItem;

  /// Starts [item]'s timer and opens it.
  final ValueChanged<PlannedItem> onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final plan = item.plan;
    final type = item.type;
    final now = ref.watch(clockProvider).nowUtc();
    final kind = NowNextKind.of(item, now);
    final session = ref.watch(activeFocusSessionProvider).value;
    final streak = type == null
        ? null
        : ref.watch(activityStreaksProvider)[type.id];
    // A plain task is ticked off, never timed.
    final timed = !plan.isTask && (type == null || type.supportsTimer);
    final start = formatPlanStart(context, plan);

    final label = switch (kind) {
      NowNextKind.running =>
        session?.state == FocusState.paused
            ? l10n.nowNextPaused
            : l10n.nowNextRunning,
      NowNextKind.now => l10n.nowNextNow,
      NowNextKind.next => l10n.nowNextNext(start!),
      NowNextKind.anytime => l10n.nowNextAnytime,
    };
    String? soon;
    if (kind == NowNextKind.next) {
      final wait = plan.plannedStartAt!.difference(now).inMilliseconds;
      if (wait > 60000) soon = l10n.todayUpNextIn(formatDuration(l10n, wait));
    }

    final running = kind == NowNextKind.running && session != null;
    final c = context.colors;
    final ({String label, IconData icon, VoidCallback onPressed}) action =
        running
        ? (
            label: l10n.focusFinish,
            icon: AppIcons.check,
            onPressed: () => unawaited(
              PlanActions(
                context,
                ref,
              ).finish(session, title: plan.title, type: type),
            ),
          )
        : timed && session == null
        ? (
            label: l10n.nowNextStartRecord,
            icon: AppIcons.start,
            onPressed: () => onStart(item),
          )
        : (
            label: l10n.nowNextMarkDone,
            icon: AppIcons.check,
            onPressed: () =>
                unawaited(PlanActions(context, ref).complete(item)),
          );

    final length = plan.plannedLengthMs;
    final activity = type == null
        ? null
        : context.tokens.activity(
            ActivityColorKey.fromName(type.colorKey) ?? ActivityColorKey.slate,
          );
    final notes = plan.notes?.trim();

    // Tinted with the activity's own palette color.
    final tint = activity?.soft ?? c.brandPrimarySoft;
    return AppCard(
      onTap: () => onOpenItem(plan.id),
      color: tint,
      flat: true,
      padding: const EdgeInsets.all(AppSpacing.lg + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Wraps onto two lines when the text is large.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
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
              if (streak != null)
                StreakBadge(days: streak.days)
              else if (type != null &&
                  activity != null &&
                  type.name.trim() != plan.title.trim())
                StatusChip(label: type.name, tone: StatusTone.neutral),
            ],
          ),
          const SizedBox(height: AppSpacing.md + 2),
          Row(
            children: [
              if (type != null) ...[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: c.surfaceBase,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    ActivityIconRegistry.resolve(type.iconId),
                    size: 24,
                    color: activity?.solid ?? c.brandPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Text(
                  plan.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          if (notes != null && notes.isNotEmpty && !running) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              notes.split('\n').first,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodyMedium?.copyWith(
                color: c.textSecondary,
              ),
            ),
          ],
          if (running) ...[
            const SizedBox(height: AppSpacing.sm),
            _LiveTime(session: session),
          ] else if (start != null || length != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.xs,
              children: [
                if (start != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(AppIcons.time, size: 14, color: c.textSecondary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          switch (formatPlanEnd(context, plan)) {
                            final end? => l10n.planTimeRange(start, end),
                            null => start,
                          },
                          style: context.textStyles.labelMedium?.copyWith(
                            color: c.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                if (length != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(AppIcons.timer, size: 14, color: c.textSecondary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          formatDuration(l10n, length),
                          style: context.textStyles.labelMedium?.copyWith(
                            color: c.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: action.label,
            icon: action.icon,
            variant: AppButtonVariant.action,
            expand: true,
            onPressed: action.onPressed,
          ),
          if (onFocusMode case final focus?
              when timed && (running || session == null))
            Center(
              child: TextButton.icon(
                icon: const Icon(AppIcons.lock, size: 18),
                label: Text(l10n.focusModeAction),
                onPressed: () => focus(item),
              ),
            ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formatTimer(session.elapsedMs(now)),
          style: AppTypography.numericLarge.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        // "Round 2 · 12:30 to a break", "Break · 3:20 left".
        PomodoroLine(session: session, showToggle: false),
      ],
    );
  }
}
