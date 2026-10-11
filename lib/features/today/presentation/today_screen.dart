import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/clock_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../activity_logs/domain/activity_log.dart';
import '../../challenges/domain/challenge.dart';
import '../../focus/presentation/focus_banner.dart';
import '../../../core/design/app_icons.dart';
import '../../../shared/errors/error_copy.dart';
import '../../../shared/widgets/state_views.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../challenges/presentation/challenge_providers.dart';
import '../../settings/presentation/preferences_providers.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../shared/widgets/user_avatar.dart';
import 'start_row.dart';
import 'today_timeline.dart';
import '../../focus/presentation/focus_providers.dart';
import '../../plans/domain/plan.dart';
import '../../plans/domain/watch_day_overview.dart';
import '../../plans/presentation/widgets/add_sheet.dart';
import '../../plans/presentation/activity_chooser.dart';
import '../../plans/presentation/plan_date_notifier.dart';
import '../../plans/domain/day_progress.dart';
import '../../plans/presentation/plan_providers.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../core/time/local_date.dart';
import '../../plans/domain/day_edges.dart';
import '../../plans/presentation/widgets/no_plan_card.dart';
import 'day_edges_sections.dart';
import 'day_hero.dart';
import 'now_next_card.dart';
import 'today_status.dart';

/// Today, "my day" (ADR-046): the date, a greeting and one status line;
/// the **Now/Next** card with one action (Start, Done or Finish); then the
/// day as a timeline with a now line. Doing something changes the row (✓,
/// result, 🔥) and the status line right here. Adding lives behind **+**.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({
    super.key,
    required this.onOpenItem,
    required this.onOpenRecord,
    required this.onOpenFocus,
    required this.onOpenChallenge,
    required this.onPlanDate,
    required this.chooser,
    required this.onOpenMe,
    required this.onStartActivity,
    required this.onOpenNotes,
  });

  /// Opens Notes.
  final VoidCallback onOpenNotes;

  /// Opens Me (the avatar).
  final VoidCallback onOpenMe;

  /// Starts one of your activities now ("Start something").
  final ValueChanged<ActivityType> onStartActivity;

  /// Opens a plan's item screen.
  final ValueChanged<PlanId> onOpenItem;

  /// Opens a record made without a plan.
  final ValueChanged<ActivityLog> onOpenRecord;

  /// Returns to the running timer's item.
  final VoidCallback onOpenFocus;

  /// Opens a challenge (ADR-044).
  final ValueChanged<ChallengeId> onOpenChallenge;

  /// Opens Plan on a date (the evening review's Plan tomorrow).
  final ValueChanged<LocalDate> onPlanDate;

  /// Picks an activity from the list, or makes a new one, for the day.
  final ActivityChooser chooser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final margin = WindowSizeClass.of(context).screenMargin;
    final clock = ref.watch(clockProvider);
    final today = currentLocalDate(clock);
    final overview = ref.watch(dayOverviewProvider(today)).value;
    final next = overview == null ? null : upNext(overview, clock.nowUtc());
    final running = next?.status == EffectivePlanStatus.inProgress
        ? next
        : null;
    final progress = overview == null ? null : DayProgress.of(overview);
    Future<void> start(PlannedItem item) => _startAndOpen(context, ref, item);
    void add({bool now = false}) => unawaited(
      showAddSheet(
        context,
        date: today,
        dayName: l10n.addToday,
        chooser: chooser,
        startNow: now,
        onStartNow: (id) =>
            unawaited(_startPlanAndOpen(context, ref, id, null)),
      ),
    );
    final nowUtc = clock.nowUtc();
    final review = overview == null
        ? null
        : EveningReview.of(
            overview,
            nowUtc: nowUtc,
            localHour: nowUtc.add(clock.offsetAt(nowUtc)).hour,
          );
    final empty =
        overview != null &&
        overview.planned.isEmpty &&
        overview.unplanned.isEmpty;
    final name = ref.watch(effectiveUserNameProvider);
    final streaks = ref.watch(activityStreaksProvider).values;
    final bestStreak = streaks.isEmpty
        ? null
        : streaks.map((s) => s.days).reduce((a, b) => a > b ? a : b);
    final greeting = _greeting(l10n, clock);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppContentWidth.list),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                margin,
                AppSpacing.md,
                margin,
                AppSpacing.huge,
              ),
              children: [
                ScreenHeader(
                  title: l10n.navToday,
                  actions: [
                    HeaderIconButton(
                      icon: AppIcons.notes.outline,
                      tooltip: l10n.notesTitle,
                      onPressed: onOpenNotes,
                    ),
                    UserAvatar(
                      name: name,
                      size: 38,
                      onTap: onOpenMe,
                      tooltip: l10n.navMe,
                    ),
                  ],
                ),
                DayHero(
                  greeting: name.isEmpty
                      ? greeting
                      : l10n.greetingNamed(greeting, name),
                  statusLine: heroLine(context, progress, running),
                  progress: progress,
                  bestStreak: bestStreak,
                ),
                const SizedBox(height: AppSpacing.xs),
                // A timer on something that isn't today's (e.g. another day).
                if (running == null) FocusBanner(onOpen: onOpenFocus),
                const FromYesterdaySection(),
                if (review != null)
                  EveningReviewCard(
                    review: review,
                    onOpenItem: onOpenItem,
                    onPlanDate: onPlanDate,
                  )
                else if (next != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  NowNextCard(
                    item: next,
                    onOpenItem: onOpenItem,
                    onStart: (item) => unawaited(start(item)),
                  ),
                ],
                if (empty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  NoPlanCard(
                    date: today,
                    onAdd: add,
                    onStartNow: () => add(now: true),
                  ),
                  StartRow(onStart: onStartActivity, margin: margin),
                ] else ...[
                  SectionHeader(
                    title: l10n.todayYourDay,
                    trailing: TextButton.icon(
                      onPressed: add,
                      icon: const Icon(AppIcons.add, size: 18),
                      label: Text(l10n.todayAddShort),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  if (overview != null)
                    TodayTimeline(
                      overview: overview,
                      onOpenItem: onOpenItem,
                      onOpenRecord: onOpenRecord,
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Starts [item]'s timer, then opens it running (ADR-046).
  Future<void> _startAndOpen(
    BuildContext context,
    WidgetRef ref,
    PlannedItem item,
  ) => _startPlanAndOpen(context, ref, item.plan.id, item.type?.id);

  Future<void> _startPlanAndOpen(
    BuildContext context,
    WidgetRef ref,
    PlanId planId,
    ActivityTypeId? typeId,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final type = typeId ?? await ref.read(ensureItemActivityProvider)(planId);
      await ref.read(startFocusSessionProvider)(type, planId: planId);
    } catch (error) {
      if (context.mounted) {
        showMessageSnackBar(context, errorMessage(l10n, error));
      }
      return;
    }
    onOpenItem(planId);
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
