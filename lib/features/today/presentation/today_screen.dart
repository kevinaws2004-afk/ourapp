import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/tab_placeholder.dart';

/// Today tab. Placeholder until its feature is built (Phase 4).
class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TabPlaceholder(title: l10n.navToday, message: l10n.todayPlaceholder);
  }
}
