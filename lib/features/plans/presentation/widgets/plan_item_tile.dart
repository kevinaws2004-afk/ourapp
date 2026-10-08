import 'package:flutter/material.dart';

import '../../../../core/design/app_icons.dart';
import '../../../../core/design/tokens/sizes.dart';
import '../../../../core/design/context_ext.dart';
import '../../../../core/design/keys/activity_icon_ids.dart';
import '../../../../core/design/tokens/activity_palette.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/activity_badge.dart';
import '../../../../shared/widgets/done_check.dart';
import '../../../../shared/widgets/item_card.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../domain/plan.dart';
import '../../domain/watch_day_overview.dart';
import '../../../activity_logs/presentation/value_formatting.dart';
import '../plan_formatting.dart';

/// A plan as an item card (ADR-045) in the Plan vs Reality grammar
/// (design_system.md §1.2): the status chip says planned, in progress or
/// done, the check on the right fills when done, and skipped or cancelled
/// items fade (never red). The same for tasks and activities.
///
/// The check marks it done or not done ([onToggleDone], A17);
/// it's inactive when there's nothing to toggle. Tapping the row opens the
/// item to log into it ([onTap], ADR-035); [onMore] opens the plan options.
class PlanItemTile extends StatelessWidget {
  const PlanItemTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onMore,
    required this.onToggleDone,
    this.onLongPress,
    this.dragHandle,
  });

  /// Quick actions (B7).
  final VoidCallback? onLongPress;

  final PlannedItem item;
  final VoidCallback onTap;
  final VoidCallback onMore;

  /// Null when the check can't toggle (e.g. skipped, or done by itself).
  final VoidCallback? onToggleDone;

  /// A drag handle for manual reordering, when the list allows it.
  final Widget? dragHandle;

  @override
  Widget build(BuildContext context) {
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
    final inactive =
        status == EffectivePlanStatus.skipped ||
        status == EffectivePlanStatus.cancelled;
    final chip = switch (status) {
      EffectivePlanStatus.planned => StatusChip(
        label: l10n.planStatusPlanned,
        tone: StatusTone.scheduled,
      ),
      EffectivePlanStatus.inProgress => StatusChip(
        label: l10n.planStatusInProgress,
        tone: StatusTone.active,
      ),
      EffectivePlanStatus.completed => StatusChip(
        label: l10n.planStatusDone,
        tone: StatusTone.done,
        icon: AppIcons.check,
      ),
      EffectivePlanStatus.skipped => StatusChip(
        label: l10n.planStatusSkipped,
        tone: StatusTone.neutral,
      ),
      EffectivePlanStatus.cancelled => StatusChip(
        label: l10n.planStatusCancelled,
        tone: StatusTone.neutral,
      ),
    };
    // What was logged into it ("Bench press 60 kg × 8 (×2)", A18), or how
    // long it took against the plan once done.
    final logged = switch ((type, item.records.firstOrNull)) {
      (final type?, final log?) => summarizeLog(context, type, log),
      _ => '',
    };
    final outcome = done ? formatPlanOutcome(context, item) : null;
    final summary = [?outcome, if (logged.isNotEmpty) logged].join(' · ');

    // Say what a tap does (ADR-030).
    final tapHint = plan.isTask
        ? null
        : done
        ? l10n.planOpenRecordHint
        : l10n.planRecordHint(plan.title);
    return ItemCard(
      title: plan.title,
      time: formatPlanTime(context, plan),
      chip: chip,
      summary: summary,
      faded: inactive,
      onTap: onTap,
      onLongPress: onLongPress,
      tapHint: tapHint,
      longPressHint: onLongPress == null ? null : l10n.planQuickActionsHint,
      // The type can briefly be missing while the types stream catches up
      // with a just-created activity.
      leading: plan.isTask
          ? null
          : ActivityBadge(
              iconId: type?.iconId ?? ActivityIconIds.fallback,
              colorKey: type?.colorKey ?? ActivityColorKey.slate.name,
            ),
      trailing: [
        if (plan.isRepeating)
          Icon(
            AppIcons.repeat,
            size: AppSizes.iconSmall,
            color: colors.textSecondary,
            semanticLabel: l10n.planRepeating,
          ),
        DoneCheck(
          done: done,
          color: inactive
              ? colors.textTertiary
              : activity?.solid ?? colors.textSecondary,
          onPressed: onToggleDone,
        ),
        IconButton(
          tooltip: l10n.planOptions,
          icon: const Icon(AppIcons.more),
          color: colors.textSecondary,
          onPressed: onMore,
        ),
        ?dragHandle,
      ],
    );
  }
}
