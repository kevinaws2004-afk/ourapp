import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/state_views.dart';
import '../../plans/presentation/activity_chooser.dart';
import '../domain/challenge.dart';
import 'challenge_card.dart';
import 'challenge_providers.dart';
import 'challenge_sheet.dart';

/// Me → Challenges (ADR-044): every challenge, running ones first, and
/// **New challenge**. Tapping one opens it ([onOpenChallenge]).
class ChallengesScreen extends ConsumerWidget {
  const ChallengesScreen({
    super.key,
    required this.onOpenChallenge,
    required this.chooser,
  });

  final ValueChanged<ChallengeId> onOpenChallenge;

  /// Picks or makes the activity of a new challenge.
  final ActivityChooser chooser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final margin = WindowSizeClass.of(context).screenMargin;
    return Scaffold(
      appBar: AppBar(),
      body: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppContentWidth.list),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              margin,
              AppSpacing.huge,
              margin,
              AppSpacing.xxxl,
            ),
            children: [
              Text(
                l10n.challengesTitle,
                style: context.textStyles.displayMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.challengesSubtitle,
                style: context.textStyles.bodyLarge?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Align(
                alignment: Alignment.centerLeft,
                child: AppButton(
                  label: l10n.newChallenge,
                  icon: AppIcons.add,
                  variant: AppButtonVariant.secondary,
                  onPressed: () =>
                      showChallengeSheet(context, chooser: chooser),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AsyncValueView(
                value: ref.watch(challengesProvider),
                onRetry: () => ref.invalidate(challengesProvider),
                data: (views) => views.isEmpty
                    ? AppEmptyState(
                        icon: AppIcons.challenge,
                        title: l10n.challengesEmptyTitle,
                        message: l10n.challengesEmptyMessage,
                      )
                    : Column(
                        children: [
                          for (final view in views)
                            ChallengeCard(
                              key: ValueKey(view.challenge.id),
                              view: view,
                              onTap: () => onOpenChallenge(view.challenge.id),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
