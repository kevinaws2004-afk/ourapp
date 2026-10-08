import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/context_ext.dart';
import '../../core/design/tokens/spacing.dart';
import '../../core/design/window_size_class.dart';
import '../../core/design/themes/app_theme_id.dart';
import '../../features/settings/presentation/preferences_providers.dart';
import 'showcase_sections.dart';

/// Debug-only screen for reviewing the design tokens on a device
/// (ADR-016). Registered only when `kDebugMode` is true.
///
/// Developer tooling: labels are intentionally not localized
/// (coding_standards.md §4).
class TokenShowcaseScreen extends ConsumerWidget {
  const TokenShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final margin = WindowSizeClass.of(context).screenMargin;
    final preferences = ref.read(preferencesNotifierProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Design tokens')),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppContentWidth.list),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                margin,
                AppSpacing.lg,
                margin,
                AppSpacing.huge,
              ),
              children: [
                ShowcaseSection(
                  title: 'Theme',
                  child: SegmentedButton<AppThemeId>(
                    segments: [
                      for (final id in AppThemeId.values)
                        ButtonSegment(value: id, label: Text(id.name)),
                    ],
                    selected: {ref.watch(effectiveThemeProvider)},
                    onSelectionChanged: (selection) =>
                        unawaited(preferences.setTheme(selection.single)),
                  ),
                ),
                const ShowcaseSection(
                  title: 'Surfaces & text',
                  child: SurfaceSwatches(),
                ),
                const ShowcaseSection(
                  title: 'Brand & status',
                  child: BrandSwatches(),
                ),
                const ShowcaseSection(
                  title: 'Activity palette',
                  child: ActivityPaletteGrid(),
                ),
                const ShowcaseSection(
                  title: 'Typography',
                  child: TypographySamples(),
                ),
                const ShowcaseSection(title: 'Spacing', child: SpacingScale()),
                const ShowcaseSection(
                  title: 'Radius & elevation',
                  child: RadiusAndElevation(),
                ),
                const ShowcaseSection(title: 'Buttons', child: ButtonSamples()),
                ShowcaseSection(
                  title: 'Debug actions',
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => unawaited(preferences.resetOnboarding()),
                      child: Text(
                        'Show onboarding again',
                        style: TextStyle(color: context.colors.danger),
                      ),
                    ),
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
