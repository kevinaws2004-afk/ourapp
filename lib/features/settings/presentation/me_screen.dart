import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/section_header.dart';
import 'appearance_screen.dart';
import 'preferences_providers.dart';

/// Me tab: your setup (reusable activities, ADR-028, and body measurements). Debug builds add a separate Developer section with the
/// token showcase and a demo data loader; release builds never show it.
class MeScreen extends ConsumerWidget {
  const MeScreen({
    super.key,
    required this.onOpenActivities,
    required this.onOpenMeasurements,
    required this.onOpenAppearance,
    this.onOpenTokenShowcase,
    this.onLoadDemoData,
    this.onLoadRecentDemoData,
  });

  final VoidCallback onOpenActivities;
  final VoidCallback onOpenMeasurements;

  /// Me → Appearance: the app's theme (ADR-045).
  final VoidCallback onOpenAppearance;

  /// Debug-only entry point; ignored in release builds.
  final VoidCallback? onOpenTokenShowcase;

  /// Developer tools: demo data for six weeks up to today.
  final VoidCallback? onLoadDemoData;

  /// Developer tools: demo data for the last 10 days, ending yesterday.
  final VoidCallback? onLoadRecentDemoData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              ListTile(
                leading: const Icon(AppIcons.appearance),
                title: Text(l10n.appearanceTitle),
                subtitle: Text(
                  themeName(l10n, ref.watch(effectiveThemeProvider)),
                ),
                trailing: const Icon(AppIcons.chevron),
                onTap: onOpenAppearance,
              ),
              // Plain release builds never show developer tools (A3).
              // Only when the router passes them (debug or DEV_TOOLS builds).
              if (onOpenTokenShowcase != null ||
                  onLoadDemoData != null ||
                  onLoadRecentDemoData != null) ...[
                // Developer tooling: intentionally not localized
                // (coding_standards.md §4).
                const SectionHeader(title: 'Developer'),
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
                    title: const Text('Load demo data (6 weeks)'),
                    onTap: onLoadDemoData,
                  ),
                if (onLoadRecentDemoData != null)
                  ListTile(
                    leading: const Icon(AppIcons.developer),
                    title: const Text('Load demo data (last 10 days)'),
                    onTap: onLoadRecentDemoData,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
