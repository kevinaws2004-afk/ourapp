import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
import 'plan_views.dart';
import 'widgets/add_sheet.dart';

/// Plan tab, "shape my days" (ADR-028, ADR-036, ADR-046 P1–P5): the week as
/// a strip with the selected day under it, or the month. Tapping a day in
/// either selects it; **+** adds to the selected day.
class PlanScreen extends ConsumerWidget {
  const PlanScreen({
    super.key,
    required this.onOpenItem,
    required this.onOpenRecord,
    required this.chooser,
  });

  /// Opens a plan's item screen.
  final ValueChanged<PlanId> onOpenItem;

  /// Opens a record made without a plan.
  final ValueChanged<ActivityLog> onOpenRecord;

  /// Picks an activity from the list, or makes a new one, for the day.
  final ActivityChooser chooser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final margin = WindowSizeClass.of(context).screenMargin;
    final selected = ref.watch(planSelectedDateProvider);
    final today = currentLocalDate(ref.watch(clockProvider));
    void add() => unawaited(
      showAddSheet(
        context,
        date: selected,
        dayName: selected == today
            ? l10n.addToday
            : DateFormat.EEEE(
                Localizations.localeOf(context).toString(),
              ).format(DateTime(selected.year, selected.month, selected.day)),
        chooser: chooser,
      ),
    );
    void openDay(LocalDate date) {
      ref.read(planSelectedDateProvider.notifier).select(date);
      ref.read(planViewProvider.notifier).show(PlanView.week);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        // Today and Plan both keep a + alive in the tab shell.
        heroTag: 'plan-add',
        tooltip: l10n.planAddToDay,
        onPressed: add,
        child: const Icon(AppIcons.add),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppContentWidth.list),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                margin,
                AppSpacing.huge,
                margin,
                AppSpacing.giant + AppSpacing.huge,
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
                    onAdd: add,
                    chooser: chooser,
                  ),
                  PlanView.month => PlanMonthView(onOpenDay: openDay),
                },
              ],
            ),
          ),
        ),
      ),
    );
  }
}
