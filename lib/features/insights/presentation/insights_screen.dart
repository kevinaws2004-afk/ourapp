import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/tab_placeholder.dart';

/// Insights tab. Placeholder until its feature is built (Phase 6).
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TabPlaceholder(
      title: l10n.navInsights,
      message: l10n.insightsPlaceholder,
    );
  }
}
