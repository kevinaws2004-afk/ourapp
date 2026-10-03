import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/design/app_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/tab_placeholder.dart';

/// Me tab: Activities (reusable activity setup, ADR-028) today; body
/// measurements and preferences later. In debug builds it also links to the
/// developer token showcase.
class MeScreen extends StatelessWidget {
  const MeScreen({
    super.key,
    required this.onOpenActivities,
    this.onOpenTokenShowcase,
  });

  final VoidCallback onOpenActivities;

  /// Debug-only entry point; ignored in release builds.
  final VoidCallback? onOpenTokenShowcase;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TabPlaceholder(
      title: l10n.navMe,
      message: l10n.mePlaceholder,
      footer: Column(
        children: [
          ListTile(
            leading: const Icon(AppIcons.activities),
            title: Text(l10n.activitiesTitle),
            subtitle: Text(l10n.meActivitiesSubtitle),
            trailing: const Icon(AppIcons.chevron),
            onTap: onOpenActivities,
          ),
          if (kDebugMode && onOpenTokenShowcase != null)
            ListTile(
              leading: const Icon(AppIcons.developer),
              // Developer tooling: intentionally not localized (coding_standards.md §4).
              title: const Text('Design tokens (debug)'),
              trailing: const Icon(AppIcons.chevron),
              onTap: onOpenTokenShowcase,
            ),
        ],
      ),
    );
  }
}
