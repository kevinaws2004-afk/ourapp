import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/app_theme.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/themes/app_theme_id.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/sizes.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/activity_badge.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_chip.dart';
import 'preferences_providers.dart';

/// Me → Appearance (ADR-045): the three themes, each previewed in its own
/// look. Tapping one applies it to the whole app straight away and saves it.
class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final margin = WindowSizeClass.of(context).screenMargin;
    final current = ref.watch(effectiveThemeProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appearanceTitle)),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppContentWidth.reading),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              margin,
              AppSpacing.sm,
              margin,
              AppSpacing.huge,
            ),
            children: [
              Text(
                l10n.appearanceIntro,
                style: context.textStyles.bodyLarge?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              for (final id in AppThemeId.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: _ThemeOption(
                    id: id,
                    selected: id == current,
                    onSelect: () => unawaited(
                      ref
                          .read(preferencesNotifierProvider.notifier)
                          .setTheme(id),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The shown name of a theme.
String themeName(AppLocalizations l10n, AppThemeId id) => switch (id) {
  AppThemeId.rose => l10n.themeNameRose,
  AppThemeId.lavender => l10n.themeNameLavender,
  AppThemeId.papaya => l10n.themeNamePapaya,
};

String _themeDescription(AppLocalizations l10n, AppThemeId id) => switch (id) {
  AppThemeId.rose => l10n.themeDescriptionRose,
  AppThemeId.lavender => l10n.themeDescriptionLavender,
  AppThemeId.papaya => l10n.themeDescriptionPapaya,
};

/// One theme: a small piece of the app drawn in that theme, its name and
/// description, and a ring when it's the one in use.
class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.id,
    required this.selected,
    required this.onSelect,
  });

  final AppThemeId id;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ring = context.colors.brandPrimary;
    return Semantics(
      button: true,
      selected: selected,
      label: '${themeName(l10n, id)}. ${_themeDescription(l10n, id)}',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onSelect,
        child: AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(AppRadius.card + AppSpacing.xs),
            ),
            border: Border.all(
              color: selected ? ring : Colors.transparent,
              width: AppSizes.selectionRing,
            ),
          ),
          // The preview is drawn with the theme it shows, and is only a
          // picture: taps select the theme.
          child: IgnorePointer(
            child: Theme(
              data: AppTheme.of(id),
              child: _ThemePreview(
                name: themeName(l10n, id),
                description: _themeDescription(l10n, id),
                selected: selected,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemePreview extends StatelessWidget {
  const _ThemePreview({
    required this.name,
    required this.description,
    required this.selected,
  });

  final String name;
  final String description;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surfaceCanvas,
        borderRadius: AppRadius.cardAll,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(name, style: context.textStyles.titleLarge),
                ),
                if (selected)
                  StatusChip(
                    label: l10n.appearanceInUse,
                    tone: StatusTone.active,
                    icon: AppIcons.check,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              description,
              style: context.textStyles.bodyMedium?.copyWith(
                color: c.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  const ActivityBadge(
                    iconId: 'person-simple-walk',
                    colorKey: 'teal',
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.appearancePreviewTitle,
                          style: context.textStyles.titleMedium,
                        ),
                        Text(
                          l10n.appearancePreviewDetail,
                          style: context.textStyles.bodySmall?.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusChip(
                    label: l10n.planStatusPlanned,
                    tone: StatusTone.scheduled,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: l10n.appearancePreviewAction,
              icon: AppIcons.start,
              variant: AppButtonVariant.action,
              expand: true,
              // A picture of a button; the whole preview ignores taps.
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
