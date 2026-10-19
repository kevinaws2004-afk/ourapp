import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/empty_state_card.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../shared/widgets/state_views.dart';
import '../../plans/presentation/activity_chooser.dart';
import '../../plans/presentation/plan_providers.dart';
import '../../../shared/errors/error_copy.dart';
import '../../../shared/widgets/section_header.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../../activity_types/presentation/built_in_activities.dart';
import '../domain/challenge.dart';
import '../domain/challenge_use_cases.dart';
import 'challenge_card.dart';
import 'challenge_providers.dart';
import 'challenge_sheet.dart';

/// The Challenges tab (ADR-044): every challenge, running ones first, and
/// **New challenge**. Tapping one opens it ([onOpenChallenge]).
class ChallengesScreen extends ConsumerWidget {
  /// Examples offered when there are none yet (C1): your most used
  /// activities, or common ones before you have any.
  static List<(String, int)> _examples(
    AppLocalizations l10n,
    List<ActivityType> yours,
  ) {
    const days = [21, 30, 30];
    if (yours.isNotEmpty) {
      return [
        for (final (i, type) in yours.take(days.length).indexed)
          (type.name, days[i]),
      ];
    }
    return [
      (l10n.builtInMeditation, 21),
      (l10n.builtInReading, 30),
      (l10n.builtInStudy, 30),
    ];
  }

  /// An example: its activity (yours, or the built-in one saved as yours)
  /// and days, prefilled in the new challenge sheet.
  Future<void> _startExample(
    BuildContext context,
    WidgetRef ref,
    String name,
    int days,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final active = await ref.read(activeActivityTypesProvider.future);
      ActivityTypeId? id = matchByName(active, name);
      if (id == null) {
        final definition = builtInActivities(l10n)
            .where((d) => d.name == name)
            .firstOrNull;
        if (definition == null) return;
        id = await ref.read(addBuiltInActivityProvider)(definition);
      }
      if (!context.mounted) return;
      await showChallengeSheet(
        context,
        chooser: chooser,
        activityId: id,
        days: days,
      );
    } catch (error) {
      if (context.mounted) {
        showMessageSnackBar(context, errorMessage(l10n, error));
      }
    }
  }

  const ChallengesScreen({
    super.key,
    required this.onOpenChallenge,
    required this.chooser,
    this.onBack,
  });

  /// Back to Progress (Goals live inside it).
  final VoidCallback? onBack;

  final ValueChanged<ChallengeId> onOpenChallenge;

  /// Picks or makes the activity of a new challenge.
  final ActivityChooser chooser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final margin = WindowSizeClass.of(context).screenMargin;
    return SafeArea(
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
                leading: switch (onBack) {
                  final back? => HeaderIconButton(
                    icon: AppIcons.previous,
                    tooltip: MaterialLocalizations.of(context)
                        .backButtonTooltip,
                    onPressed: back,
                  ),
                  null => null,
                },
                title: l10n.challengesTitle,
                subtitle: l10n.challengesSubtitle,
                actions: [
                  HeaderIconButton(
                    icon: AppIcons.add,
                    tooltip: l10n.newChallenge,
                    label: l10n.todayAddShort,
                    onPressed: () =>
                        showChallengeSheet(context, chooser: chooser),
                  ),
                ],
              ),
              AsyncValueView(
                value: ref.watch(challengesProvider),
                onRetry: () => ref.invalidate(challengesProvider),
                data: (views) {
                  if (views.isEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        EmptyStateCard(
                          icon: AppIcons.trophy,
                          title: l10n.challengesEmptyTitle,
                          message: l10n.challengesEmptyMessage,
                          actions: [
                            AppButton(
                              label: l10n.newChallenge,
                              icon: AppIcons.add,
                              onPressed: () =>
                                  showChallengeSheet(context, chooser: chooser),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          l10n.goalsIdeas,
                          style: context.textStyles.labelSmall?.copyWith(
                            color: context.colors.textTertiary,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            for (final (name, days) in _examples(
                              l10n,
                              ref.watch(recentActivityTypesProvider),
                            ))
                              ActionChip(
                                avatar: const Icon(AppIcons.goal, size: 16),
                                label: Text(
                                  l10n.challengeAutoTitle(days, name),
                                ),
                                onPressed: () => unawaited(
                                  _startExample(context, ref, name, days),
                                ),
                              ),
                          ],
                        ),
                      ],
                    );
                  }
                  final running = [
                    for (final v in views)
                      if (v.progress.completedOn == null) v,
                  ];
                  final completed = [
                    for (final v in views)
                      if (v.progress.completedOn != null) v,
                  ];
                  ChallengeCard card(ChallengeView view) => ChallengeCard(
                    key: ValueKey(view.challenge.id),
                    view: view,
                    onTap: () => onOpenChallenge(view.challenge.id),
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final view in running) card(view),
                      if (completed.isNotEmpty) ...[
                        SectionHeader(
                          title: l10n.challengesCompleted(completed.length),
                        ),
                        for (final view in completed) card(view),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Your activity named [name] (any case), if there is one.
ActivityTypeId? matchByName(List<ActivityType> types, String name) => types
    .where((t) => t.name.trim().toLowerCase() == name.trim().toLowerCase())
    .firstOrNull
    ?.id;
