import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/clock_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../activity_logs/domain/activity_log.dart';
import '../../focus/presentation/focus_banner.dart';
import '../../plans/domain/plan.dart';
import '../../plans/presentation/activity_chooser.dart';
import '../../plans/presentation/plan_date_notifier.dart';
import '../../plans/presentation/widgets/day_items.dart';

/// Today tab (ADR-035): a greeting, then today as [DayItems]: a quick way to
/// add to the day (planned, or "Start now" to log it straight away) and the
/// day's items in time order. Opening an item is where you log into it.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({
    super.key,
    required this.onOpenItem,
    required this.onOpenRecord,
    required this.onOpenFocus,
    required this.chooser,
  });

  /// Opens a plan's item screen.
  final ValueChanged<PlanId> onOpenItem;

  /// Opens a record made without a plan.
  final ValueChanged<ActivityLog> onOpenRecord;

  /// Returns to the running timer's item.
  final VoidCallback onOpenFocus;

  /// Picks an activity from the list, or makes a new one, for the day.
  final ActivityChooser chooser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final margin = WindowSizeClass.of(context).screenMargin;
    final clock = ref.watch(clockProvider);
    final today = currentLocalDate(clock);
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
              Text(
                _greeting(l10n, clock),
                style: context.textStyles.displayMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                MaterialLocalizations.of(
                  context,
                ).formatFullDate(DateTime(today.year, today.month, today.day)),
                style: context.textStyles.titleMedium?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              FocusBanner(onOpen: onOpenFocus),
              const SizedBox(height: AppSpacing.lg),
              DayItems(
                date: today,
                emptyMessage: l10n.todayEmptyMessageItems,
                onOpenItem: onOpenItem,
                onOpenRecord: onOpenRecord,
                chooser: chooser,
                onStartNow: onOpenItem,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _greeting(AppLocalizations l10n, Clock clock) {
    final now = clock.nowUtc();
    final hour = now.add(clock.offsetAt(now)).hour;
    return switch (hour) {
      < 5 => l10n.todayGreetingEvening,
      < 12 => l10n.todayGreetingMorning,
      < 18 => l10n.todayGreetingAfternoon,
      _ => l10n.todayGreetingEvening,
    };
  }
}
