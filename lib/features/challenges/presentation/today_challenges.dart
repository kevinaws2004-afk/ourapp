import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/section_header.dart';
import '../domain/challenge.dart';
import '../domain/challenge_use_cases.dart';
import 'challenge_card.dart';
import 'challenge_providers.dart';

/// The challenges still running, below Today's items (ADR-044): progress,
/// streak, and whether today is done or the streak is at risk. Nothing is
/// shown without a running challenge. Completed challenges live under
/// Me → Challenges.
class TodayChallenges extends ConsumerWidget {
  const TodayChallenges({super.key, required this.onOpenChallenge});

  final ValueChanged<ChallengeId> onOpenChallenge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final running = [
      for (final view
          in ref.watch(challengesProvider).value ?? const <ChallengeView>[])
        if (!view.progress.isCompleted) view,
    ];
    if (running.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.challengesTitle),
        for (final view in running)
          ChallengeCard(
            key: ValueKey(view.challenge.id),
            view: view,
            onTap: () => onOpenChallenge(view.challenge.id),
          ),
      ],
    );
  }
}
