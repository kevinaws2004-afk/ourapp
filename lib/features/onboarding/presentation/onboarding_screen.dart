import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/centered_scroll_body.dart';
import '../../settings/presentation/preferences_providers.dart';

/// First-run screen. Phase 1 placeholder for the onboarding narrative
/// (user_flows.md F1, Phase 7): one statement and one action. Finishing it
/// sets the onboarding flag, and the router redirect moves to Today.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: CenteredScrollBody(
        children: [
          Text(l10n.onboardingTitle, style: context.textStyles.displayLarge),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.onboardingBody,
            style: context.textStyles.bodyLarge?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.huge),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: l10n.onboardingStart,
              onPressed: () => unawaited(
                ref
                    .read(preferencesNotifierProvider.notifier)
                    .completeOnboarding(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
