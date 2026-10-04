import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/section_header.dart';

/// Me tab: your setup (reusable activities, ADR-028, and body
/// measurements). Debug builds add a separate Developer section with the
/// token showcase and a demo data loader; release builds never show it.
class MeScreen extends StatelessWidget {
  const MeScreen({
    super.key,
    required this.onOpenActivities,
    required this.onOpenMeasurements,
    this.onOpenTokenShowcase,
    this.onLoadDemoData,
  });

  final VoidCallback onOpenActivities;
  final VoidCallback onOpenMeasurements;

  /// Debug-only entry point; ignored in release builds.
  final VoidCallback? onOpenTokenShowcase;

  /// Debug-only demo data loader; ignored in release builds.
  final VoidCallback? onLoadDemoData;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final margin = WindowSizeClass.of(context).screenMargin;
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppContentWidth.reading),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              margin,
              AppSpacing.huge,
              margin,
              AppSpacing.xxxl,
            ),
            children: [
              Text(l10n.navMe, style: context.textStyles.displayMedium),
              SectionHeader(title: l10n.meSectionSetup),
              ListTile(
                leading: const Icon(AppIcons.activities),
                title: Text(l10n.activitiesTitle),
                subtitle: Text(l10n.meActivitiesSubtitle),
                trailing: const Icon(AppIcons.chevron),
                onTap: onOpenActivities,
              ),
              ListTile(
                leading: const Icon(AppIcons.measurements),
                title: Text(l10n.measurementsTitle),
                subtitle: Text(l10n.meMeasurementsSubtitle),
                trailing: const Icon(AppIcons.chevron),
                onTap: onOpenMeasurements,
              ),
              // Release builds never show developer tools (A3).
              if (kDebugMode &&
                  (onOpenTokenShowcase != null || onLoadDemoData != null)) ...[
                // Developer tooling: intentionally not localized
                // (coding_standards.md §4).
                const SectionHeader(title: 'Developer (debug builds only)'),
                if (onOpenTokenShowcase != null)
                  ListTile(
                    leading: const Icon(AppIcons.developer),
                    title: const Text('Design tokens'),
                    trailing: const Icon(AppIcons.chevron),
                    onTap: onOpenTokenShowcase,
                  ),
                if (onLoadDemoData != null)
                  ListTile(
                    leading: const Icon(AppIcons.developer),
                    title: const Text('Load demo data'),
                    onTap: onLoadDemoData,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
