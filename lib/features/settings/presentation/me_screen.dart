import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/tokens/typography.dart';
import '../../../core/design/window_size_class.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/settings_group.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../../challenges/presentation/challenge_providers.dart';
import '../../insights/presentation/insight_providers.dart';
import '../../measurements/domain/measurement.dart';
import '../../measurements/presentation/measurement_formatting.dart';
import '../../measurements/presentation/measurement_providers.dart';
import '../domain/preferences_snapshot.dart';
import 'app_lock.dart';
import 'appearance_screen.dart';
import 'backup_providers.dart';
import 'feedback_sheet.dart';
import 'preferences_providers.dart';
import 'review_prompt.dart';
import '../../../shared/widgets/text_input_dialog.dart';

/// The installed version ("1.2.0 (14)"), read from the app itself, so it
/// always matches pubspec.yaml.
final appVersionProvider = FutureProvider<String>((ref) async {
  try {
    final info = await PackageInfo.fromPlatform();
    return '${info.version} (${info.buildNumber})';
  } catch (_) {
    return '';
  }
});

/// Me: you (your name, what you've done so far), your setup (activities,
/// body, goals), your preferences (appearance), and your data (export,
/// privacy). Debug builds add a Developer group; release builds never show
/// it.
class MeScreen extends ConsumerWidget {
  const MeScreen({
    super.key,
    required this.onOpenActivities,
    required this.onOpenMeasurements,
    required this.onOpenAppearance,
    required this.onOpenGoals,
    required this.onOpenNotifications,
    required this.onOpenNotes,
    required this.onOpenBackup,
    required this.onOpenFocusSettings,
    this.onOpenTokenShowcase,
    this.onLoadDemoData,
    this.onLoadRecentDemoData,
  });

  final VoidCallback onOpenActivities;
  final VoidCallback onOpenMeasurements;

  /// Me → Appearance: theme and light/dark.
  final VoidCallback onOpenAppearance;

  /// Your goals (challenges).
  final VoidCallback onOpenGoals;

  /// Reminders and notifications.
  final VoidCallback onOpenNotifications;

  /// Your notes.
  final VoidCallback onOpenNotes;

  /// Backup & restore.
  final VoidCallback onOpenBackup;

  /// Focus: Pomodoro and Do Not Disturb.
  final VoidCallback onOpenFocusSettings;

  /// Debug-only entry point; ignored in release builds.
  final VoidCallback? onOpenTokenShowcase;

  /// Developer tools: demo data for six weeks up to today.
  final VoidCallback? onLoadDemoData;

  /// Developer tools: demo data for the last 10 days, ending yesterday.
  final VoidCallback? onLoadRecentDemoData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final margin = WindowSizeClass.of(context).screenMargin;
    final name = ref.watch(effectiveUserNameProvider);
    final types = ref.watch(activeActivityTypesProvider).value;
    final goals = ref.watch(challengesProvider).value;
    final activeDays = ref.watch(activeDaysProvider).value;
    final allDays = <LocalDate>{
      for (final set in activeDays?.values ?? const <Set<LocalDate>>[]) ...set,
    };
    final appearance = ref.watch(effectiveAppearanceProvider);
    final version = ref.watch(appVersionProvider).value ?? '';
    final lastBackup = ref
        .watch(backupSnapshotsProvider)
        .value
        ?.firstOrNull
        ?.madeAt;
    final dev =
        onOpenTokenShowcase != null ||
        onLoadDemoData != null ||
        onLoadRecentDemoData != null;

    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppContentWidth.reading),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              margin,
              AppSpacing.xl,
              margin,
              AppSpacing.huge,
            ),
            children: [
              // You.
              Center(
                child: UserAvatar(
                  name: name,
                  size: 88,
                  onTap: () => unawaited(editName(context, ref)),
                  tooltip: l10n.meEditName,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: InkWell(
                  borderRadius: AppRadius.mdAll,
                  onTap: () => unawaited(editName(context, ref)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name.isEmpty ? l10n.meAddName : name,
                          style: context.textStyles.headlineSmall?.copyWith(
                            color: name.isEmpty ? c.brandPrimary : null,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Icon(AppIcons.edit, size: 16, color: c.textTertiary),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Center(child: _PrivateBadge(label: l10n.mePrivateBadge)),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  _MeStat(value: '${allDays.length}', label: l10n.meStatDays),
                  const SizedBox(width: AppSpacing.md),
                  _MeStat(
                    value: '${types?.length ?? 0}',
                    label: l10n.meStatActivities,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _MeStat(
                    value:
                        '${goals?.where((g) => g.progress.isCompleted).length ?? 0}',
                    label: l10n.meStatGoals,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),

              SettingsGroup(
                title: l10n.meGroupSetup,
                children: [
                  SettingsTile(
                    icon: AppIcons.activities,
                    title: l10n.activitiesTitle,
                    subtitle: types == null
                        ? l10n.meActivitiesSubtitle
                        : l10n.meActivitiesCount(types.length),
                    onTap: onOpenActivities,
                  ),
                  SettingsTile(
                    icon: AppIcons.measurements,
                    iconColor: c.accent,
                    iconBackground: c.accentSoft,
                    title: l10n.measurementsTitle,
                    subtitle: switch (ref
                        .watch(latestMeasurementsProvider)
                        .value?[MeasurementType.weight]) {
                      final weight? => formatMeasurement(weight),
                      null => l10n.meMeasurementsSubtitle,
                    },
                    onTap: onOpenMeasurements,
                  ),
                  SettingsTile(
                    icon: AppIcons.notes.outline,
                    iconColor: c.accent,
                    iconBackground: c.accentSoft,
                    title: l10n.notesTitle,
                    subtitle: l10n.notesMeSubtitle,
                    onTap: onOpenNotes,
                  ),
                  SettingsTile(
                    icon: AppIcons.trophy,
                    iconColor: c.warning,
                    iconBackground: c.warningContainer,
                    title: l10n.navChallenges,
                    subtitle: l10n.meGoalsSubtitle,
                    onTap: onOpenGoals,
                  ),
                ],
              ),

              SettingsGroup(
                title: l10n.meGroupPreferences,
                children: [
                  SettingsTile(
                    icon: AppIcons.bell,
                    iconColor: c.warning,
                    iconBackground: c.warningContainer,
                    title: l10n.notificationsTitle,
                    subtitle: l10n.notificationsSubtitle,
                    onTap: onOpenNotifications,
                  ),
                  SettingsTile(
                    icon: AppIcons.timer,
                    iconColor: c.brandPrimary,
                    iconBackground: c.brandPrimarySoft,
                    title: l10n.focusSettingsTitle,
                    subtitle: l10n.focusSettingsSubtitle,
                    onTap: onOpenFocusSettings,
                  ),
                  SettingsTile(
                    icon: AppIcons.appearance,
                    title: l10n.appearanceTitle,
                    value: themeName(l10n, ref.watch(effectiveThemeProvider)),
                    onTap: onOpenAppearance,
                  ),
                  SettingsTile(
                    icon: switch (appearance) {
                      AppearanceMode.system => AppIcons.systemMode,
                      AppearanceMode.light => AppIcons.lightMode,
                      AppearanceMode.dark => AppIcons.darkMode,
                    },
                    iconColor: c.textPrimary,
                    iconBackground: c.surfaceSunken,
                    title: l10n.meDarkMode,
                    value: appearanceName(l10n, appearance),
                    onTap: () => unawaited(pickAppearance(context, ref)),
                  ),
                  SettingsTile(
                    icon: AppIcons.me.outline,
                    iconColor: c.action,
                    iconBackground: c.actionSoft,
                    title: l10n.meName,
                    value: name.isEmpty ? l10n.meNotSet : name,
                    onTap: () => unawaited(editName(context, ref)),
                  ),
                ],
              ),

              SettingsGroup(
                title: l10n.meGroupData,
                children: [
                  SettingsTile(
                    icon: AppIcons.backup,
                    iconColor: c.action,
                    iconBackground: c.actionSoft,
                    title: l10n.backupTitle,
                    subtitle: switch (lastBackup) {
                      final at? => l10n.backupLast(
                        MaterialLocalizations.of(context)
                            .formatMediumDate(at.toLocal()),
                      ),
                      null => l10n.backupMeSubtitle,
                    },
                    onTap: onOpenBackup,
                  ),
                  SettingsTile(
                    icon: AppIcons.appLock,
                    iconColor: c.accent,
                    iconBackground: c.accentSoft,
                    title: l10n.appLockTitle,
                    subtitle: l10n.appLockSubtitle,
                    trailing: Switch(
                      value: ref.watch(appLockEnabledProvider).value ?? false,
                      onChanged: (v) =>
                          unawaited(setAppLock(context, ref, enabled: v)),
                    ),
                  ),
                  SettingsTile(
                    icon: AppIcons.privacy,
                    iconColor: c.success,
                    iconBackground: c.successContainer,
                    title: l10n.mePrivacy,
                    subtitle: l10n.mePrivacySubtitle,
                    onTap: () => unawaited(_showPrivacy(context)),
                  ),
                ],
              ),

              SettingsGroup(
                title: l10n.meGroupAbout,
                children: [
                  SettingsTile(
                    icon: AppIcons.rate,
                    iconColor: c.warning,
                    iconBackground: c.warningContainer,
                    title: l10n.meRate,
                    subtitle: l10n.meRateSubtitle,
                    onTap: () => unawaited(openStoreListing()),
                  ),
                  SettingsTile(
                    icon: AppIcons.feedback,
                    iconColor: c.accent,
                    iconBackground: c.accentSoft,
                    title: l10n.meFeedback,
                    subtitle: l10n.meFeedbackSubtitle,
                    onTap: () => unawaited(showFeedbackSheet(context, ref)),
                  ),
                  SettingsTile(
                    icon: AppIcons.info,
                    iconColor: c.textSecondary,
                    iconBackground: c.surfaceSunken,
                    title: l10n.appTitle,
                    value: l10n.meVersion(version),
                    onTap: () => showAboutDialog(
                      context: context,
                      applicationName: l10n.appTitle,
                      applicationVersion: version,
                      applicationLegalese: l10n.meAboutLegal,
                    ),
                  ),
                ],
              ),

              // Plain release builds never show developer tools (A3).
              if (dev)
                // Developer tooling: intentionally not localized.
                SettingsGroup(
                  title: 'Developer',
                  children: [
                    if (onOpenTokenShowcase case final open?)
                      SettingsTile(
                        icon: AppIcons.developer,
                        title: 'Design tokens',
                        onTap: open,
                      ),
                    if (onLoadDemoData case final load?)
                      SettingsTile(
                        icon: AppIcons.developer,
                        title: 'Load demo data (6 weeks)',
                        onTap: load,
                      ),
                    if (onLoadRecentDemoData case final load?)
                      SettingsTile(
                        icon: AppIcons.developer,
                        title: 'Load demo data (last 10 days)',
                        onTap: load,
                      ),
                  ],
                ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: Text(
                  l10n.meFooter,
                  textAlign: TextAlign.center,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: c.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showPrivacy(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return showModalBottomSheet<void>(
      useRootNavigator: true,
      context: context,
      useSafeArea: true,
      builder: (context) {
        final c = context.colors;
        Widget point(IconData icon, String text) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: c.success),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(text, style: context.textStyles.bodyLarge)),
            ],
          ),
        );
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(AppIcons.privacy, size: 36, color: c.success),
              const SizedBox(height: AppSpacing.md),
              Text(l10n.privacyTitle, style: context.textStyles.headlineSmall),
              const SizedBox(height: AppSpacing.lg),
              point(AppIcons.device, l10n.privacyPointDevice),
              point(AppIcons.lock, l10n.privacyPointNoAccount),
              point(AppIcons.exportFile, l10n.privacyPointExport),
            ],
          ),
        );
      },
    );
  }
}

/// Edits the name the app calls you.
Future<void> editName(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final result = await showTextInputDialog(
    context,
    title: l10n.meNameTitle,
    initial: ref.read(effectiveUserNameProvider),
    hint: l10n.meNameHint,
    maxLength: 40,
    capitalization: TextCapitalization.words,
  );
  if (result == null) return;
  await ref.read(preferencesNotifierProvider.notifier).setName(result);
}

String appearanceName(AppLocalizations l10n, AppearanceMode mode) =>
    switch (mode) {
      AppearanceMode.system => l10n.appearanceSystem,
      AppearanceMode.light => l10n.appearanceLight,
      AppearanceMode.dark => l10n.appearanceDark,
    };

/// System, light or dark, as a small sheet.
Future<void> pickAppearance(BuildContext context, WidgetRef ref) {
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet<void>(
    useRootNavigator: true,
    context: context,
    useSafeArea: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.meDarkMode, style: context.textStyles.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          const AppearanceModePicker(),
        ],
      ),
    ),
  );
}

class _MeStat extends StatelessWidget {
  const _MeStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg,
          horizontal: AppSpacing.sm,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTypography.numericLarge.copyWith(
                color: c.textPrimary,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodySmall?.copyWith(
                color: c.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivateBadge extends StatelessWidget {
  const _PrivateBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: c.successContainer,
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.lock, size: 14, color: c.success),
          const SizedBox(width: AppSpacing.xs),
          // A long label wraps rather than running off a narrow screen.
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: context.textStyles.labelSmall?.copyWith(
                color: c.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
