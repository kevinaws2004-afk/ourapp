import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/json_preferences.dart';
import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_card.dart';
import '../../challenges/presentation/challenge_providers.dart';
import '../../challenges/presentation/challenge_sheet.dart';
import '../../insights/presentation/insight_providers.dart';
import '../../plans/domain/watch_day_overview.dart';
import '../../plans/presentation/activity_chooser.dart';
import '../../plans/presentation/plan_actions.dart';

const _dismissedKey = 'habitHintDismissed';

final _habitHintDismissedProvider = StreamProvider.autoDispose<bool>(
  (ref) => ref
      .watch(jsonPreferencesProvider)
      .watch(_dismissedKey)
      .map((v) => v == true),
);

/// Early on, under the day: what to do next with the first thing you
/// planned (**Repeat it** / **Set a goal**). Shown in the first week until
/// you have a goal or close it.
class HabitHintCard extends ConsumerWidget {
  const HabitHintCard({
    super.key,
    required this.overview,
    required this.chooser,
  });

  final DayOverview overview;
  final ActivityChooser chooser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final dismissed = ref.watch(_habitHintDismissedProvider).value ?? true;
    final goals = ref.watch(challengesProvider).value;
    final item = overview.planned.where((i) => i.type != null).firstOrNull;
    // Only in the first week of use.
    final days = ref.watch(activeDaysProvider).value;
    final early =
        days != null && {for (final set in days.values) ...set}.length < 7;
    if (dismissed ||
        !early ||
        goals == null ||
        goals.isNotEmpty ||
        item == null) {
      return const SizedBox.shrink();
    }
    final type = item.type!;
    void dismiss() =>
        unawaited(ref.read(jsonPreferencesProvider).write(_dismissedKey, true));
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(AppIcons.goal, size: 20, color: c.brandPrimary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.habitHintTitle,
                    style: context.textStyles.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  icon: const Icon(AppIcons.close, size: 18),
                  visualDensity: VisualDensity.compact,
                  onPressed: dismiss,
                ),
              ],
            ),
            Text(
              l10n.habitHintBody(type.name),
              style: context.textStyles.bodyMedium?.copyWith(
                color: c.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                if (item.plan.seriesId == null)
                  TextButton.icon(
                    icon: const Icon(AppIcons.repeat, size: 18),
                    label: Text(l10n.habitHintRepeat),
                    onPressed: () =>
                        unawaited(PlanActions(context, ref).repeat(item)),
                  ),
                TextButton.icon(
                  icon: const Icon(AppIcons.goal, size: 18),
                  label: Text(l10n.habitHintGoal),
                  onPressed: () => unawaited(
                    showChallengeSheet(
                      context,
                      chooser: chooser,
                      activityId: type.id,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
