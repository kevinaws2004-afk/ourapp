import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/app_card.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../../measurements/domain/measurement.dart';
import '../../measurements/presentation/measurement_formatting.dart';
import '../../measurements/presentation/measurement_providers.dart';
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
              const SizedBox(height: AppSpacing.xl),
              _MeCard(
                icon: AppIcons.activities,
                title: l10n.activitiesTitle,
                value: switch (ref.watch(activeActivityTypesProvider).value) {
                  final types? => l10n.meActivitiesCount(types.length),
                  null => l10n.meActivitiesSubtitle,
                },
                onTap: onOpenActivities,
              ),
              _MeCard(
                icon: AppIcons.measurements,
                title: l10n.measurementsTitle,
                value: switch (ref
                    .watch(latestMeasurementsProvider)
                    .value?[MeasurementType.weight]) {
                  final weight? => formatMeasurement(weight),
                  null => l10n.meMeasurementsSubtitle,
                },
                onTap: onOpenMeasurements,
              ),
              _MeCard(
                icon: AppIcons.appearance,
                title: l10n.appearanceTitle,
                value: themeName(l10n, ref.watch(effectiveThemeProvider)),
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

/// One part of your setup as a card: what it is and its value right now
/// ("12 activities", "84.2 kg", "Lavender").
class _MeCard extends StatelessWidget {
  const _MeCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Semantics(
        button: true,
        child: AppCard(
          onTap: onTap,
          child: Row(
            children: [
              Icon(icon, color: c.brandPrimary),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.textStyles.titleMedium),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      value,
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(AppIcons.chevron, color: c.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
