import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/context_ext.dart';
import '../../../core/design/keys/activity_color_key.dart';
import '../../../core/design/tokens/sizes.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/tokens/typography.dart';
import '../../../core/design/window_size_class.dart';
import '../../../core/design/app_icons.dart';
import '../../../core/time/clock_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/errors/error_copy.dart';
import '../../../shared/widgets/activity_badge.dart';
import '../../../shared/widgets/charts/day_grid.dart';
import '../../../shared/widgets/panel_card.dart';
import '../../../shared/widgets/progress_bar.dart';
import '../../../shared/widgets/stat_tile.dart';
import '../../../shared/widgets/state_views.dart';
import '../../activity_logs/presentation/value_formatting.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../../plans/presentation/plan_date_notifier.dart';
import '../domain/challenge.dart';
import '../domain/challenge_use_cases.dart';
import 'challenge_card.dart';
import 'challenge_providers.dart';
import 'challenge_sheet.dart';

enum _Menu { edit, restart, end }

/// One challenge (ADR-044): progress out of the target, the current and
/// best streak, how many days are left, today's state, and a calendar of the
/// days done. Edit its name or days, restart from today, or end it; ending
/// and restarting can be undone. Recording the activity is what counts a day.
class ChallengeScreen extends ConsumerWidget {
  const ChallengeScreen({super.key, required this.challengeId});

  final ChallengeId challengeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final view = ref.watch(challengeProvider(challengeId));
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (view.value case final v?)
            PopupMenuButton<_Menu>(
              tooltip: l10n.challengeOptions,
              icon: const Icon(AppIcons.more),
              onSelected: (action) => _run(context, ref, v.challenge, action),
              itemBuilder: (_) => [
                PopupMenuItem(value: _Menu.edit, child: Text(l10n.insightEdit)),
                PopupMenuItem(
                  value: _Menu.restart,
                  child: Text(l10n.challengeRestart),
                ),
                PopupMenuItem(value: _Menu.end, child: Text(l10n.challengeEnd)),
              ],
            ),
        ],
      ),
      body: AsyncValueView<ChallengeView?>(
        value: view,
        onRetry: () => ref.invalidate(challengeProvider(challengeId)),
        data: (view) => view == null
            ? Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(l10n.challengeNotFound),
              )
            : _Body(view: view),
      ),
    );
  }

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    Challenge challenge,
    _Menu action,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      switch (action) {
        case _Menu.edit:
          await showChallengeSheet(context, initial: challenge);
        case _Menu.restart:
          final previous = await ref.read(restartChallengeProvider)(
            challenge.id,
          );
          final setStart = ref.read(setChallengeStartProvider);
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(l10n.challengeRestarted),
                action: SnackBarAction(
                  label: l10n.actionUndo,
                  onPressed: () => setStart(challenge.id, previous),
                ),
              ),
            );
        case _Menu.end:
          // Read now: Undo runs after this screen has closed.
          final restore = ref.read(restoreChallengeProvider);
          await ref.read(endChallengeProvider)(challenge.id);
          navigator.pop();
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(l10n.challengeEnded),
                action: SnackBarAction(
                  label: l10n.actionUndo,
                  onPressed: () => restore(challenge.id),
                ),
              ),
            );
      }
    } catch (error) {
      if (context.mounted) {
        showMessageSnackBar(context, errorMessage(l10n, error));
      }
    }
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.view});

  final ChallengeView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final margin = WindowSizeClass.of(context).screenMargin;
    final challenge = view.challenge;
    final progress = view.progress;
    final type = ref
        .watch(activityTypeProvider(challenge.activityTypeId))
        .value;
    final key =
        ActivityColorKey.fromName(type?.colorKey ?? '') ??
        ActivityColorKey.slate;
    final accent = context.tokens.activity(key).solid;
    final today = currentLocalDate(ref.watch(clockProvider));
    final quiet = context.textStyles.bodyMedium?.copyWith(
      color: context.colors.textSecondary,
    );
    String days(int n) => l10n.insightDaysDone(n);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppContentWidth.chart),
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            margin,
            AppSpacing.sm,
            margin,
            AppSpacing.giant,
          ),
          children: [
            Row(
              children: [
                ActivityBadge(
                  iconId: type?.iconId ?? 'sparkle',
                  colorKey: type?.colorKey ?? key.name,
                  size: AppSizes.badgeLarge,
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: context.textStyles.headlineSmall,
                      ),
                      Text(
                        l10n.challengeStartsOn(
                          formatDate(context, challenge.startDate),
                        ),
                        style: quiet,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              '${progress.progress} / ${progress.targetDays}',
              style: AppTypography.numericHero.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppProgressBar(
              fraction: progress.fraction,
              color: accent,
              semanticLabel: l10n.challengeProgressDays(
                progress.progress,
                progress.targetDays,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ChallengeStateLine(state: progress.today),
            if (progress.completedOn case final on?)
              Text(
                l10n.challengeCompletedOn(formatDate(context, on)),
                style: quiet,
              ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: StatTile(
                    label: l10n.challengeCurrentStreak,
                    value: days(progress.currentStreak),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: StatTile(
                    label: l10n.challengeBestStreak,
                    value: days(progress.bestStreak),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: StatTile(
                    label: l10n.challengeDaysDone,
                    value: days(progress.daysDone),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: StatTile(
                    label: l10n.challengeDaysLeft,
                    value: days(progress.daysLeft),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            PanelCard(
              title: l10n.challengeCalendarSection,
              child: DayGrid(
                from: challenge.startDate,
                to: today,
                counts: {for (final d in progress.doneDays) d: 1},
                color: accent,
                semanticLabel: l10n.challengeProgressDays(
                  progress.daysDone,
                  progress.targetDays,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
