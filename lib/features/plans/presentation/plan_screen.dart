import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../activity_logs/domain/activity_log.dart';
import '../domain/plan.dart';
import 'activity_chooser.dart';
import 'plan_date_notifier.dart';
import 'plan_views.dart';

/// Plan tab (ADR-028, ADR-036, A1): the date-based planner, as a week or a
/// month. Tapping a day opens it ([onOpenDay]), shown the same way Today
/// shows today; the tab has no separate day view.
class PlanScreen extends ConsumerWidget {
  const PlanScreen({
    super.key,
    required this.onOpenItem,
    required this.onOpenRecord,
    required this.onOpenDay,
    required this.chooser,
  });

  /// Opens a plan's item screen.
  final ValueChanged<PlanId> onOpenItem;

  /// Opens a record made without a plan.
  final ValueChanged<ActivityLog> onOpenRecord;

  /// Opens the selected date's day screen.
  final VoidCallback onOpenDay;

  /// Picks a template or makes a new activity for what's added to a day.
  final ActivityChooser chooser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final margin = WindowSizeClass.of(context).screenMargin;
    void openDay(LocalDate date) {
      ref.read(planSelectedDateProvider.notifier).select(date);
      onOpenDay();
    }

    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppContentWidth.list),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              margin,
              AppSpacing.huge,
              margin,
              AppSpacing.giant,
            ),
            children: [
              Text(l10n.navPlan, style: context.textStyles.displayMedium),
              const SizedBox(height: AppSpacing.lg),
              const PlanViewSwitch(),
              const SizedBox(height: AppSpacing.lg),
              switch (ref.watch(planViewProvider)) {
                PlanView.week => PlanWeekView(
                  onOpenItem: onOpenItem,
                  onOpenRecord: onOpenRecord,
                  onOpenDay: openDay,
                  chooser: chooser,
                ),
                PlanView.month => PlanMonthView(onOpenDay: openDay),
              },
            ],
          ),
        ),
      ),
    );
  }
}
