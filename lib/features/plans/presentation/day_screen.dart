import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../core/time/clock_provider.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../activity_logs/domain/activity_log.dart';
import '../domain/plan.dart';
import 'activity_chooser.dart';
import 'plan_date_notifier.dart';
import 'widgets/day_items.dart';

/// One day of the planner, opened from Plan → Week or Month (A1). It shows
/// the selected date exactly like Today shows today; arrows step a day.
class DayScreen extends ConsumerWidget {
  const DayScreen({
    super.key,
    required this.onOpenItem,
    required this.onOpenRecord,
    required this.chooser,
  });

  /// Opens a plan's item screen.
  final ValueChanged<PlanId> onOpenItem;

  /// Opens a record made without a plan.
  final ValueChanged<ActivityLog> onOpenRecord;

  /// Picks a template or makes a new activity for what's added to a day.
  final ActivityChooser chooser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final margin = WindowSizeClass.of(context).screenMargin;
    final selected = ref.watch(planSelectedDateProvider);
    final today = currentLocalDate(ref.watch(clockProvider));
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppContentWidth.list),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                margin,
                AppSpacing.sm,
                margin,
                AppSpacing.giant,
              ),
              children: [
                _DateHeading(selected: selected, today: today),
                const SizedBox(height: AppSpacing.lg),
                DayItems(
                  date: selected,
                  emptyMessage: l10n.planPlannedEmpty,
                  onOpenItem: onOpenItem,
                  onOpenRecord: onOpenRecord,
                  chooser: chooser,
                  onStartNow: selected == today ? onOpenItem : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateHeading extends ConsumerWidget {
  const _DateHeading({required this.selected, required this.today});

  final LocalDate selected;
  final LocalDate today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    final notifier = ref.read(planSelectedDateProvider.notifier);
    final relative = switch (selected) {
      _ when selected == today => l10n.planToday,
      _ when selected == today.addDays(1) => l10n.planTomorrow,
      _ when selected == today.addDays(-1) => l10n.planYesterday,
      _ => null,
    };
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (relative != null)
                Text(
                  relative,
                  style: context.textStyles.labelMedium?.copyWith(
                    color: context.colors.brandPrimary,
                  ),
                ),
              Text(
                material.formatFullDate(
                  DateTime(selected.year, selected.month, selected.day),
                ),
                style: context.textStyles.headlineSmall,
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: l10n.dayPreviousDay,
          icon: const Icon(AppIcons.previous),
          onPressed: () => notifier.shiftDays(-1),
        ),
        IconButton(
          tooltip: l10n.planChooseDate,
          icon: const Icon(AppIcons.date),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime(
                selected.year,
                selected.month,
                selected.day,
              ),
              currentDate: DateTime(today.year, today.month, today.day),
              firstDate: DateTime(1900),
              lastDate: DateTime(2200),
            );
            if (picked != null) {
              notifier.select(LocalDate(picked.year, picked.month, picked.day));
            }
          },
        ),
        IconButton(
          tooltip: l10n.dayNextDay,
          icon: const Icon(AppIcons.chevron),
          onPressed: () => notifier.shiftDays(1),
        ),
      ],
    );
  }
}
