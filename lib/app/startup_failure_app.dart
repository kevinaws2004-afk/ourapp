import 'package:flutter/material.dart';

import '../core/design/app_theme.dart';
import '../core/design/themes/app_theme_id.dart';
import '../core/design/context_ext.dart';
import '../core/design/tokens/spacing.dart';
import '../l10n/generated/app_localizations.dart';
import '../shared/widgets/app_button.dart';
import '../shared/widgets/centered_scroll_body.dart';

/// Shown when the database can't be opened or migrated
/// (error_handling.md §4). It never deletes or recreates the database.
class StartupFailureApp extends StatelessWidget {
  const StartupFailureApp({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.of(AppThemeId.fallback),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: _StartupFailureScreen(onRetry: onRetry),
    );
  }
}

class _StartupFailureScreen extends StatelessWidget {
  const _StartupFailureScreen({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: CenteredScrollBody(
        children: [
          Text(
            l10n.startupFailureTitle,
            style: context.textStyles.headlineLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.startupFailureBody,
            style: context.textStyles.bodyLarge?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          AppButton(label: l10n.startupFailureRetry, onPressed: onRetry),
        ],
      ),
    );
  }
}
