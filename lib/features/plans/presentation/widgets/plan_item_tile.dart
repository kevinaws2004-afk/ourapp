import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/app_icons.dart';
import '../../../../core/design/context_ext.dart';
import '../../../../core/design/keys/activity_icon_ids.dart';
import '../../../../core/design/tokens/activity_palette.dart';
import '../../../../core/time/clock_provider.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/activity_badge.dart';
import '../../../../shared/widgets/done_check.dart';
import '../../../../shared/widgets/item_card.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../activity_logs/presentation/value_formatting.dart';
import '../../../challenges/presentation/challenge_providers.dart';
import '../../../focus/presentation/focus_providers.dart';
import '../../../focus/presentation/focus_screen.dart';
import '../../domain/plan.dart';
import '../../domain/watch_day_overview.dart';
import '../plan_formatting.dart';

/// One thing on a day as a timeline row (ADR-046), the same on Today and in
/// Plan. Its sub-line says what matters now:
/// - open: what's logged so far, else its planned length
/// - running: "Running · 12:04" (live)
/// - done: its result ("32 pages", "45 min", "Done")
/// - skipped / cancelled: says so, the row faded (never red)
///
/// A 🔥 shows the streak of a running challenge on its activity. The circle
/// marks it done or not done ([onToggleDone], A17); tapping the row opens it
/// ([onTap], ADR-035); long-press for options ([onLongPress]).
class PlanItemTile extends ConsumerWidget {
  const PlanItemTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onToggleDone,
    this.onLongPress,
    this.dragHandle,
  });

  final PlannedItem item;
  final VoidCallback onTap;

  /// Null when the circle can't toggle (e.g. skipped, or done by itself).
  final VoidCallback? onToggleDone;

  /// Options (B7).
  final VoidCallback? onLongPress;

  /// A drag handle for manual reordering, when the list allows it (Plan).
  final Widget? dragHandle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final plan = item.plan;
    final type = item.type;
    final activity = type == null
        ? null
        : context.tokens.activity(
            ActivityColorKey.fromName(type.colorKey) ?? ActivityColorKey.slate,
          );
    final status = item.status;
    final done = status == EffectivePlanStatus.completed;
    final running = status == EffectivePlanStatus.inProgress;
    final inactive =
        status == EffectivePlanStatus.skipped ||
        status == EffectivePlanStatus.cancelled;
    final streak = type == null
        ? null
        : ref.watch(activityStreaksProvider)[type.id];
    final now = ref.watch(clockProvider).nowUtc();

    String? subline;
    if (running) {
      ref.watch(focusTickProvider);
      final session = ref.watch(activeFocusSessionProvider).value;
      subline = session == null
          ? l10n.planStatusInProgress
          : l10n.itemRunning(formatTimer(session.elapsedMs(now)));
    } else if (done) {
      final result = formatItemResult(context, item);
      subline = result == l10n.planStatusDone ? null : result;
    } else if (inactive) {
      subline = null;
    } else if ((type, item.records.firstOrNull) case (final type?, final log?)
        when summarizeLog(context, type, log).isNotEmpty) {
      // Logged into but not done yet: what's in it so far.
      subline = summarizeLog(context, type, log);
    } else if (plan.plannedEndAt == null) {
      if (plan.plannedLengthMs case final length?) {
        subline = formatDuration(l10n, length);
      }
    }

    // Its time window contains now (or it started in the last 15 minutes).
    final start = plan.plannedStartAt;
    final end = start?.add(
      Duration(
        milliseconds:
            plan.plannedLengthMs ?? const Duration(minutes: 15).inMilliseconds,
      ),
    );
    final isNow =
        item.isOpen &&
        !running &&
        start != null &&
        !start.isAfter(now) &&
        end!.isAfter(now);

    // The state as a chip next to the time.
    final (String?, StatusTone) chip = switch (status) {
      EffectivePlanStatus.completed => (l10n.planStatusDone, StatusTone.done),
      EffectivePlanStatus.inProgress => (
        l10n.planStatusInProgress,
        StatusTone.active,
      ),
      EffectivePlanStatus.skipped => (
        l10n.planStatusSkipped,
        StatusTone.neutral,
      ),
      EffectivePlanStatus.cancelled => (
        l10n.planStatusCancelled,
        StatusTone.neutral,
      ),
      _ when isNow => (l10n.nowNextNow, StatusTone.active),
      _ when start != null => (l10n.statusScheduled, StatusTone.scheduled),
      _ => (null, StatusTone.neutral),
    };

    // Say what a tap does (ADR-030).
    final tapHint = plan.isTask
        ? null
        : done
        ? l10n.planOpenRecordHint
        : l10n.planRecordHint(plan.title);
    return ItemCard(
      title: plan.title,
      startTime: formatPlanStart(context, plan),
      endTime: formatPlanEnd(context, plan),
      subline: subline,
      status: chip.$1,
      statusTone: chip.$2,
      streak: streak?.days,
      repeats: plan.isRepeating,
      faded: inactive,
      emphasized: isNow,
      onTap: onTap,
      onLongPress: onLongPress,
      tapHint: tapHint,
      longPressHint: onLongPress == null ? null : l10n.planQuickActionsHint,
      // The type can briefly be missing while the types stream catches up
      // with a just-created activity.
      leading: plan.isTask
          ? const _TaskMark()
          : ActivityBadge(
              iconId: type?.iconId ?? ActivityIconIds.fallback,
              colorKey: type?.colorKey ?? ActivityColorKey.slate.name,
            ),
      trailing: [
        DoneCheck(
          done: done,
          color: inactive
              ? colors.textTertiary
              : activity?.solid ?? colors.textSecondary,
          onPressed: onToggleDone,
        ),
        ?dragHandle,
      ],
    );
  }
}

/// A plain task's mark in the agenda: a quiet checklist tile, so tasks line
/// up with activities.
class _TaskMark extends StatelessWidget {
  const _TaskMark();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: c.surfaceSunken,
        borderRadius: BorderRadius.circular(40 * 0.32),
      ),
      alignment: Alignment.center,
      child: Icon(AppIcons.browse, size: 20, color: c.textSecondary),
    );
  }
}
