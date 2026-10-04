import 'package:flutter/material.dart';

import '../../../../core/design/app_icons.dart';
import '../../../../core/design/tokens/sizes.dart';
import '../../../../core/design/context_ext.dart';
import '../../../../core/design/keys/activity_icon_ids.dart';
import '../../../../core/design/tokens/activity_palette.dart';
import '../../../../core/design/tokens/radius.dart';
import '../../../../core/design/tokens/spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/activity_badge.dart';
import '../../domain/plan.dart';
import '../../domain/watch_day_overview.dart';
import '../../../activity_logs/presentation/value_formatting.dart';
import '../plan_formatting.dart';

/// A plan in the Plan vs Reality grammar (design_system.md §1.2):
/// - open: outline in the activity color, secondary text; a check control
///   for a task
/// - recorded / done: filled with the activity's soft color, primary text, ✓
/// - skipped / cancelled: faint outline with a status label (never red)
///
/// Tapping it opens the item to log into it ([onTap], ADR-035); [onMore]
/// opens the plan options.
class PlanItemTile extends StatelessWidget {
  const PlanItemTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onMore,
    required this.onToggleTask,
    this.dragHandle,
  });

  final PlannedItem item;
  final VoidCallback onTap;
  final VoidCallback onMore;
  final VoidCallback onToggleTask;

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
    final recorded = status == EffectivePlanStatus.completed && !plan.isTask;
    final inactive =
        status == EffectivePlanStatus.skipped ||
        status == EffectivePlanStatus.cancelled;

    final decoration = BoxDecoration(
      color: recorded ? activity?.soft : null,
      borderRadius: AppRadius.mdAll,
      border: recorded
          ? null
          : Border.all(
              color: inactive
                  ? colors.borderSubtle
                  : activity?.solid ?? colors.borderStrong,
              width: AppSizes.outline,
            ),
    );
    final details = [
      ?formatPlanTime(context, plan),
      ?formatPlanOutcome(context, item),
    ].join(' · ');
    final titleColor = recorded ? colors.textPrimary : colors.textSecondary;
    // What was logged into it ("Chest Press 3 sets · …").
    final summary = switch ((type, item.records.firstOrNull)) {
      (final type?, final log?) => summarizeLog(context, type, log),
      _ => '',
    };

    // Say what a tap does (ADR-030).
    final tapHint = plan.isTask
        ? null
        : recorded
        ? l10n.planOpenRecordHint
        : l10n.planRecordHint(plan.title);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Semantics(
        onTapHint: tapHint,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: AppRadius.mdAll,
            onTap: onTap,
            child: Ink(
              decoration: decoration,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    if (plan.isTask)
                      IconButton(
                        tooltip: status == EffectivePlanStatus.completed
                            ? l10n.planReopenTask
                            : l10n.planCompleteTask,
                        icon: Icon(
                          status == EffectivePlanStatus.completed
                              ? AppIcons.taskDone
                              : AppIcons.taskOpen,
                          color: status == EffectivePlanStatus.completed
                              ? colors.success
                              : colors.textSecondary,
                        ),
                        onPressed: inactive ? null : onToggleTask,
                      )
                    else
                      Opacity(
                        opacity: inactive ? 0.5 : 1,
                        // The type can briefly be missing while the types
                        // stream catches up with a just-created activity.
                        child: ActivityBadge(
                          iconId: type?.iconId ?? ActivityIconIds.fallback,
                          colorKey:
                              type?.colorKey ?? ActivityColorKey.slate.name,
                        ),
                      ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.title,
                            style: context.textStyles.titleMedium?.copyWith(
                              color: inactive
                                  ? colors.textTertiary
                                  : titleColor,
                            ),
                          ),
                          if (details.isNotEmpty)
                            Text(
                              details,
                              style: context.textStyles.bodyMedium?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          if (summary.isNotEmpty)
                            Text(
                              summary,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.textStyles.bodyMedium?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (recorded)
                      Icon(
                        AppIcons.taskDone,
                        color: colors.success,
                        semanticLabel: l10n.planStatusRecorded,
                      ),
                    if (plan.isRepeating)
                      Icon(
                        AppIcons.repeat,
                        size: AppSpacing.lg,
                        color: colors.textSecondary,
                        semanticLabel: l10n.planRepeating,
                      ),
                    IconButton(
                      tooltip: l10n.planOptions,
                      icon: const Icon(AppIcons.more),
                      onPressed: onMore,
                    ),
                    ?dragHandle,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
