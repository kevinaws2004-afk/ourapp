import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/time/clock_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/errors/error_copy.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/fact_pill.dart';
import '../../../shared/widgets/state_views.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../activity_logs/presentation/value_formatting.dart';
import '../../focus/presentation/focus_providers.dart';
import '../../plans/domain/plan.dart';
import '../../plans/domain/watch_day_overview.dart';
import '../../plans/presentation/plan_providers.dart';

/// Today's "Up next" (ADR-045): the item to do next ([upNext]), how soon,
/// its notes and planned time, and one big action. **Start** starts its
/// timer and opens it to record into; an item already in progress offers
/// **Continue**. Nothing here records by itself: you log inside the item.
class UpNextCard extends ConsumerWidget {
  const UpNextCard({super.key, required this.item, required this.onOpenItem});

  final PlannedItem item;
  final ValueChanged<PlanId> onOpenItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    final c = context.colors;
    final plan = item.plan;
    final now = ref.watch(clockProvider).nowUtc();
    final session = ref.watch(activeFocusSessionProvider).value;
    final doing = item.status == EffectivePlanStatus.inProgress;
    final start = plan.plannedStartAt;
    final canTime =
        session == null && (item.type == null || item.type!.supportsTimer);

    final String label;
    String? soon;
    if (doing) {
      label = l10n.todayDoingNow;
    } else if (start != null) {
      label =
          '${l10n.todayUpNext} · '
          '${material.formatTimeOfDay(TimeOfDay.fromDateTime(start.toLocal()))}';
      final wait = start.difference(now).inMilliseconds;
      if (wait > 60000) soon = l10n.todayUpNextIn(formatDuration(l10n, wait));
    } else {
      label = l10n.todayUpNext;
    }
    final length = plan.plannedLengthMs;
    final type = item.type;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
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
              if (type != null && type.name != plan.title)
                StatusChip(label: type.name, tone: StatusTone.neutral),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(plan.title, style: context.textStyles.headlineSmall),
          if (plan.notes case final notes? when notes.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              notes,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodyLarge?.copyWith(
                color: c.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              FactPill(
                icon: AppIcons.time,
                label: l10n.todayFactTime,
                value: _time(context, plan) ?? l10n.todayUpNextAnytime,
              ),
              if (length != null)
                FactPill(
                  icon: AppIcons.timer,
                  label: l10n.todayFactLength,
                  value: formatDuration(l10n, length),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: doing || !canTime
                ? l10n.todayUpNextContinue
                : l10n.todayUpNextStart,
            icon: doing || !canTime ? AppIcons.chevron : AppIcons.start,
            variant: AppButtonVariant.action,
            expand: true,
            onPressed: () => doing || !canTime
                ? onOpenItem(plan.id)
                : unawaited(_start(context, ref)),
          ),
        ],
      ),
    );
  }

  /// "6:00 PM" or "6:00 – 7:00 PM"; the length is its own fact.
  static String? _time(BuildContext context, Plan plan) {
    final material = MaterialLocalizations.of(context);
    String at(DateTime instant) =>
        material.formatTimeOfDay(TimeOfDay.fromDateTime(instant.toLocal()));
    return switch ((plan.plannedStartAt, plan.plannedEndAt)) {
      (final start?, final end?) => AppLocalizations.of(
        context,
      ).planTimeRange(at(start), at(end)),
      (final start?, null) => at(start),
      _ => null,
    };
  }

  /// Starts the item's timer, then opens it to record into.
  Future<void> _start(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final plan = item.plan;
    try {
      final typeId =
          item.type?.id ?? await ref.read(ensureItemActivityProvider)(plan.id);
      await ref.read(startFocusSessionProvider)(typeId, planId: plan.id);
    } catch (error) {
      if (context.mounted) {
        showMessageSnackBar(context, errorMessage(l10n, error));
      }
      return;
    }
    onOpenItem(plan.id);
  }
}
