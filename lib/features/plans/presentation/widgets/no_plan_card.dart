import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/design/app_icons.dart';
import '../../../../core/design/context_ext.dart';
import '../../../../core/design/tokens/spacing.dart';
import '../../../../core/time/clock_provider.dart';
import '../../../../core/time/local_date.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/errors/error_copy.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../../activity_types/domain/activity_ids.dart';
import '../../../activity_types/domain/activity_type_definition.dart';
import '../../../activity_types/presentation/activity_type_providers.dart';
import '../../../activity_types/presentation/built_in_activities.dart';
import '../../domain/day_edges.dart';
import '../../domain/plan.dart';
import '../plan_date_notifier.dart';
import '../plan_providers.dart';
import 'plan_time_sheet.dart';

/// A day with nothing on it (ADR-046). Today, first use (T9): one obvious
/// step (**Add to today**) and three common activities that add in one
/// tap. Otherwise (T10, P4): what you usually do on that weekday, each one
/// tap, and **Start something now** (today) or **Add something**.
class NoPlanCard extends ConsumerWidget {
  const NoPlanCard({
    super.key,
    required this.date,
    required this.onAdd,
    this.onStartNow,
  });

  final LocalDate date;
  final VoidCallback onAdd;

  /// Today only: opens the add sheet set to Now.
  final VoidCallback? onStartNow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final today = currentLocalDate(ref.watch(clockProvider));
    final isToday = date == today;
    final types = ref.watch(activeActivityTypesProvider).value;
    if (types == null) return const SizedBox.shrink();
    final firstUse = types.isEmpty && isToday;
    final usual = firstUse
        ? const <UsualActivity>[]
        : ref.watch(usualActivitiesProvider(date));
    final byId = {for (final t in types) t.id: t};
    final weekday = DateFormat.EEEE(Localizations.localeOf(context).toString())
        .format(DateTime(date.year, date.month, date.day));

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
            firstUse
                ? l10n.noPlanFirstTitle
                : isToday
                ? l10n.noPlanReturningTitle
                : l10n.noPlanDayTitle(weekday),
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
            if (onStartNow case final startNow?)
              AppButton(
                label: l10n.noPlanStartNow,
                icon: AppIcons.start,
                variant: AppButtonVariant.secondary,
                expand: true,
                onPressed: startNow,
              )
            else
              AppButton(
                label: l10n.noPlanAddSomething,
                icon: AppIcons.add,
                variant: AppButtonVariant.secondary,
                expand: true,
                onPressed: onAdd,
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

  /// Adds the activity [resolve] gives to [date], at [startMinute] unless
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
    final today = date;
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
        showMessageSnackBar(
          context,
          today == currentLocalDate(clock)
              ? l10n.addedToToday(name)
              : l10n.addedToDay(name),
        );
      }
    } catch (error) {
      if (context.mounted) {
        showMessageSnackBar(context, errorMessage(l10n, error));
      }
    }
  }
}
