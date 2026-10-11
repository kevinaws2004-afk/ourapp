import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/app_tokens.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/themes/app_theme_id.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/preferences_snapshot.dart';
import 'preferences_providers.dart';

/// Me → Appearance: light, dark or system, and the color theme as a grid of
/// swatches. Tapping one applies it to the whole app straight away.
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
              Text(l10n.meDarkMode, style: context.textStyles.titleLarge),
              const SizedBox(height: AppSpacing.md),
              const AppearanceModePicker(),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                l10n.appearanceThemeTitle,
                style: context.textStyles.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                l10n.appearanceIntro,
                style: context.textStyles.bodyMedium?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              LayoutBuilder(
                builder: (context, constraints) {
                  const gap = AppSpacing.md;
                  final columns = constraints.maxWidth > 460 ? 4 : 3;
                  final width =
                      (constraints.maxWidth - gap * (columns - 1)) / columns;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (final id in AppThemeId.values)
                        SizedBox(
                          width: width,
                          child: _ThemeSwatch(
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
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// System · Light · Dark as three tiles, each with its icon.
class AppearanceModePicker extends ConsumerWidget {
  const AppearanceModePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final current = ref.watch(effectiveAppearanceProvider);
    Widget tile(AppearanceMode mode, IconData icon, String label) {
      final selected = mode == current;
      return Expanded(
        child: Semantics(
          selected: selected,
          button: true,
          label: label,
          excludeSemantics: true,
          child: Material(
            color: selected ? c.brandPrimarySoft : c.surfaceBase,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.lgAll,
              side: BorderSide(
                color: selected ? c.brandPrimary : c.borderSubtle,
                width: selected ? 2 : 1,
              ),
            ),
            child: InkWell(
              borderRadius: AppRadius.lgAll,
              onTap: () => unawaited(
                ref
                    .read(preferencesNotifierProvider.notifier)
                    .setAppearance(mode),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Column(
                  children: [
                    Icon(
                      icon,
                      color: selected ? c.brandPrimary : c.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      label,
                      style: context.textStyles.labelLarge?.copyWith(
                        color: selected ? c.onBrandPrimarySoft : c.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        tile(AppearanceMode.system, AppIcons.systemMode, l10n.appearanceSystem),
        const SizedBox(width: AppSpacing.sm),
        tile(AppearanceMode.light, AppIcons.lightMode, l10n.appearanceLight),
        const SizedBox(width: AppSpacing.sm),
        tile(AppearanceMode.dark, AppIcons.darkMode, l10n.appearanceDark),
      ],
    );
  }
}

/// The shown name of a theme.
String themeName(AppLocalizations l10n, AppThemeId id) => switch (id) {
  AppThemeId.lavender => l10n.themeNameLavender,
  AppThemeId.rose => l10n.themeNameRose,
  AppThemeId.papaya => l10n.themeNamePapaya,
  AppThemeId.ocean => l10n.themeNameOcean,
  AppThemeId.matcha => l10n.themeNameMatcha,
  AppThemeId.lilac => l10n.themeNameLilac,
  AppThemeId.sky => l10n.themeNameSky,
  AppThemeId.honey => l10n.themeNameHoney,
  AppThemeId.slate => l10n.themeNameSlate,
};

/// One theme as a swatch: its signature color as a big circle with its
/// action and accent colors tucked in, on its own canvas, and its name.
/// A check and an outline mark the one in use.
class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({
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
    final brightness = Theme.of(context).brightness;
    final t = AppTokens.of(id, brightness: brightness).colors;
    final c = context.colors;
    Widget dot(Color color, double size) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: t.surfaceBase, width: 2.5),
      ),
    );
    return Semantics(
      button: true,
      selected: selected,
      label: themeName(l10n, id),
      excludeSemantics: true,
      child: Material(
        color: t.surfaceCanvas,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: BorderSide(
            color: selected ? t.brandPrimary : c.borderSubtle,
            width: selected ? 2.5 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: AppRadius.lgAll,
          onTap: onSelect,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.md,
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 64,
                  height: 56,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: t.brandPrimary,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: selected
                              ? Icon(
                                  AppIcons.check,
                                  color: t.onBrandPrimary,
                                  size: 22,
                                )
                              : null,
                        ),
                      ),
                      Positioned(right: 0, top: 4, child: dot(t.action, 22)),
                      Positioned(right: 4, bottom: 0, child: dot(t.accent, 18)),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  themeName(l10n, id),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: context.textStyles.labelMedium?.copyWith(
                    color: t.textPrimary,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
