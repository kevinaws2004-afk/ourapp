import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/clock_provider.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/errors/error_copy.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/state_views.dart';
import '../../../shared/widgets/streak_badge.dart';
import '../../activity_logs/presentation/value_formatting.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../activity_types/domain/activity_type_definition.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../../activity_types/presentation/built_in_activities.dart';
import '../../challenges/presentation/challenge_providers.dart';
import '../../plans/domain/day_edges.dart';
import '../../plans/domain/plan.dart';
import '../../plans/domain/watch_day_overview.dart';
import '../../plans/presentation/plan_actions.dart';
import '../../plans/presentation/plan_date_notifier.dart';
import '../../plans/presentation/plan_formatting.dart';
import '../../plans/presentation/plan_providers.dart';
import '../../plans/presentation/widgets/plan_time_sheet.dart';

/// The local hour now, from the injected clock.
int _localHour(Clock clock) {
  final now = clock.nowUtc();
  return now.add(clock.offsetAt(now)).hour;
}

/// "From yesterday" (T2, ADR-046): yesterday's unfinished things, each with
/// **Do today** and **Let it go**, in the morning only. Gone once nothing is
/// left to decide (derived, nothing stored).
class FromYesterdaySection extends ConsumerWidget {
  const FromYesterdaySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final clock = ref.watch(clockProvider);
    final today = currentLocalDate(clock);
    final yesterday = ref.watch(dayOverviewProvider(today.addDays(-1))).value;
    if (yesterday == null) return const SizedBox.shrink();
    final left = leftFromYesterday(yesterday, _localHour(clock));
    if (left.isEmpty) return const SizedBox.shrink();
    final actions = PlanActions(context, ref);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.fromYesterdayTitle,
              style: context.textStyles.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final item in left)
              _DecideRow(
                item: item,
                primary: l10n.fromYesterdayDoToday,
                onPrimary: () => unawaited(actions.doToday([item], today)),
                onLetGo: () => unawaited(actions.letGo([item])),
              ),
            if (left.length > 1)
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  TextButton(
                    onPressed: () => unawaited(actions.doToday(left, today)),
                    child: Text(l10n.fromYesterdayAllToday),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: c.textSecondary,
                    ),
                    onPressed: () => unawaited(actions.letGo(left)),
                    child: Text(l10n.fromYesterdayLetAllGo),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// One unfinished thing with a way forward ([primary]) and **Let it go**.
class _DecideRow extends StatelessWidget {
  const _DecideRow({
    required this.item,
    required this.primary,
    required this.onPrimary,
    required this.onLetGo,
  });

  final PlannedItem item;
  final String primary;
  final VoidCallback onPrimary;
  final VoidCallback onLetGo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final time = formatPlanStart(context, item.plan);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.sm,
        children: [
          Text.rich(
            TextSpan(
              text: item.plan.title,
              style: context.textStyles.bodyLarge,
              children: [
                if (time != null)
                  TextSpan(
                    text: ' · $time',
                    style: TextStyle(color: c.textSecondary),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(onPressed: onPrimary, child: Text(primary)),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: c.textSecondary),
                onPressed: onLetGo,
                child: Text(l10n.fromYesterdayLetGo),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Today's evening review (T7/T8, ADR-046): how the day went in one
/// sentence, the streaks kept, any at risk, what's left (**Tomorrow** /
/// **Let it go**), and **Plan tomorrow**. Once nothing is left, one line.
class EveningReviewCard extends ConsumerWidget {
  const EveningReviewCard({
    super.key,
    required this.review,
    required this.onOpenItem,
    required this.onPlanDate,
  });

  final EveningReview review;
  final ValueChanged<PlanId> onOpenItem;

  /// Opens Plan on a date (tomorrow).
  final ValueChanged<LocalDate> onPlanDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final today = currentLocalDate(ref.watch(clockProvider));
    final tomorrow = today.addDays(1);
    final progress = review.progress;
    final planTomorrow = AppButton(
      label: l10n.eveningPlanTomorrow,
      icon: AppIcons.planNext,
      variant: AppButtonVariant.secondary,
      onPressed: () => onPlanDate(tomorrow),
    );

    if (review.closed && !progress.allDone) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.lg),
        child: AppCard(
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              Text(
                l10n.eveningClosed(progress.done, progress.total),
                style: context.textStyles.bodyLarge,
              ),
              planTomorrow,
            ],
          ),
        ),
      );
    }

    final types = <ActivityTypeId, ActivityType>{
      for (final ActivityType t
          in ref.watch(activeActivityTypesProvider).value ?? const [])
        t.id: t,
    };
    final streaks = ref.watch(activityStreaksProvider);
    final kept = [
      for (final MapEntry(:key, :value) in streaks.entries)
        if (value.doneToday && types[key] != null)
          l10n.eveningStreakKept(types[key]!.name, value.days),
    ];
    final atRisk = [
      for (final MapEntry(:key, :value) in streaks.entries)
        if (!value.doneToday && value.days > 0 && types[key] != null)
          (types[key]!, value.days),
    ];
    final headline = progress.allDone
        ? l10n.eveningAllDone(progress.total)
        : progress.recordedMs > 0
        ? l10n.eveningSummaryTime(
            progress.done,
            progress.total,
            formatDuration(l10n, progress.recordedMs),
          )
        : l10n.eveningSummary(progress.done, progress.total);
    final actions = PlanActions(context, ref);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(headline, style: context.textStyles.headlineSmall),
            if (kept.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(AppIcons.streak, size: 18, color: c.accentDawn),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      l10n.eveningStreaksKept(kept.join(' · ')),
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            for (final (type, days) in atRisk) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.sm,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StreakBadge(days: days),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Text(
                          l10n.eveningAtRisk(type.name, days),
                          style: context.textStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () =>
                        unawaited(_doItNow(context, ref, type, today)),
                    child: Text(l10n.eveningDoItNow),
                  ),
                ],
              ),
            ],
            if (review.unfinished.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.eveningNotDone,
                style: context.textStyles.labelLarge?.copyWith(
                  color: c.textSecondary,
                ),
              ),
              for (final item in review.unfinished)
                _DecideRow(
                  item: item,
                  primary: l10n.eveningTomorrow,
                  onPrimary: () => unawaited(actions.moveToTomorrow(item)),
                  onLetGo: () => unawaited(actions.letGo([item])),
                ),
            ],
            const SizedBox(height: AppSpacing.md),
            Align(alignment: Alignment.centerLeft, child: planTomorrow),
          ],
        ),
      ),
    );
  }

  /// Opens today's open thing for [type], adding one (Anytime) if there is
  /// none.
  Future<void> _doItNow(
    BuildContext context,
    WidgetRef ref,
    ActivityType type,
    LocalDate today,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final day = await ref.read(dayOverviewProvider(today).future);
      final open = day.planned
          .where((i) => i.isOpen && i.plan.activityTypeId == type.id)
          .firstOrNull;
      final id =
          open?.plan.id ??
          await ref.read(createPlanProvider)(
            PlanDraft(planDate: today, title: '', activityTypeId: type.id),
          );
      onOpenItem(id);
    } catch (error) {
      if (context.mounted) {
        showMessageSnackBar(context, errorMessage(l10n, error));
      }
    }
  }
}

/// Today with nothing on it (T9/T10, ADR-046). First use: one obvious step
/// (**Add to today**) and three common activities that add in one tap.
/// Later: what you usually do on this weekday, each one tap, and **Start
/// something now**.
class NoPlanCard extends ConsumerWidget {
  const NoPlanCard({super.key, required this.onAdd, required this.onStartNow});

  final VoidCallback onAdd;
  final VoidCallback onStartNow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final clock = ref.watch(clockProvider);
    final today = currentLocalDate(clock);
    final types = ref.watch(activeActivityTypesProvider).value;
    if (types == null) return const SizedBox.shrink();
    final firstUse = types.isEmpty;
    final usual = firstUse
        ? const <UsualActivity>[]
        : ref.watch(usualActivitiesProvider);
    final byId = {for (final t in types) t.id: t};
    final weekday = DateFormat.EEEE(Localizations.localeOf(context).toString())
        .format(DateTime(today.year, today.month, today.day));

    final chips = <Widget>[
      if (firstUse)
        for (final definition in _common(l10n))
          ActionChip(
            avatar: const Icon(AppIcons.add, size: 18),
            label: Text(definition.name),
            onPressed: () => unawaited(
              _add(context, ref, definition.name, () async {
                return ref.read(addBuiltInActivityProvider)(definition);
              }),
            ),
          )
      else
        for (final u in usual)
          if (byId[u.activityTypeId] case final type?)
            ActionChip(
              avatar: const Icon(AppIcons.add, size: 18),
              label: Text(
                u.startMinute == null
                    ? type.name
                    : '${type.name} · ${formatLocalTime(context, LocalTime.hm(u.startMinute! ~/ 60, u.startMinute! % 60))}',
              ),
              onPressed: () => unawaited(
                _add(
                  context,
                  ref,
                  type.name,
                  () async => type.id,
                  startMinute: u.startMinute,
                ),
              ),
            ),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            firstUse ? l10n.noPlanFirstTitle : l10n.noPlanReturningTitle,
            style: context.textStyles.titleLarge,
          ),
          if (firstUse) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.noPlanFirstMessage,
              style: context.textStyles.bodyLarge?.copyWith(
                color: c.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (firstUse)
            AppButton(
              label: l10n.todayAdd,
              icon: AppIcons.add,
              variant: AppButtonVariant.primary,
              expand: true,
              onPressed: onAdd,
            ),
          if (chips.isNotEmpty) ...[
            if (firstUse) const SizedBox(height: AppSpacing.lg),
            Text(
              firstUse ? l10n.noPlanTryOne : l10n.noPlanUsual(weekday),
              style: context.textStyles.labelLarge?.copyWith(
                color: c.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: chips,
            ),
          ],
          if (!firstUse) ...[
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l10n.noPlanStartNow,
              icon: AppIcons.start,
              variant: AppButtonVariant.secondary,
              expand: true,
              onPressed: onStartNow,
            ),
          ],
        ],
      ),
    );
  }

  /// Walk, Read, Meditate: built-in starting points (T9).
  static List<ActivityTypeDefinition> _common(AppLocalizations l10n) {
    final names = [
      l10n.builtInWalking,
      l10n.builtInReading,
      l10n.builtInMeditation,
    ];
    final all = builtInActivities(l10n);
    return [
      for (final name in names) ?all.where((d) => d.name == name).firstOrNull,
    ];
  }

  /// Adds the activity [resolve] gives to today, at [startMinute] unless
  /// that has passed (then Anytime).
  Future<void> _add(
    BuildContext context,
    WidgetRef ref,
    String name,
    Future<ActivityTypeId> Function() resolve, {
    int? startMinute,
  }) async {
    final l10n = AppLocalizations.of(context);
    final clock = ref.read(clockProvider);
    final today = currentLocalDate(clock);
    try {
      final typeId = await resolve();
      DateTime? start;
      if (startMinute != null) {
        final utc = DateTime(
          today.year,
          today.month,
          today.day,
          startMinute ~/ 60,
          startMinute % 60,
        ).toUtc();
        if (!utc.isBefore(clock.nowUtc())) start = utc;
      }
      await ref.read(createPlanProvider)(
        PlanDraft(
          planDate: today,
          title: '',
          activityTypeId: typeId,
          plannedStartAt: start,
        ),
      );
      if (context.mounted) {
        showMessageSnackBar(context, l10n.addedToToday(name));
      }
    } catch (error) {
      if (context.mounted) {
        showMessageSnackBar(context, errorMessage(l10n, error));
      }
    }
  }
}
