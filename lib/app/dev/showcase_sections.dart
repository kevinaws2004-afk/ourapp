import 'package:flutter/material.dart';

import '../../core/design/context_ext.dart';
import '../../core/design/tokens/activity_palette.dart';
import '../../core/design/tokens/radius.dart';
import '../../core/design/tokens/spacing.dart';
import '../../core/design/tokens/typography.dart';
import '../../shared/widgets/app_button.dart';

// Sections of the debug-only token showcase. Developer tooling: labels are
// intentionally not localized (coding_standards.md §4).

class ShowcaseSection extends StatelessWidget {
  const ShowcaseSection({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: context.textStyles.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.name, required this.color, this.foreground});

  final String name;
  final Color color;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final hex =
        '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
    return Container(
      width: 152,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: context.colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: context.textStyles.labelMedium?.copyWith(color: foreground),
          ),
          Text(
            hex,
            style: context.textStyles.labelSmall?.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}

class SurfaceSwatches extends StatelessWidget {
  const SurfaceSwatches({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _Swatch(
          name: 'surfaceCanvas',
          color: c.surfaceCanvas,
          foreground: c.textPrimary,
        ),
        _Swatch(
          name: 'surfaceBase',
          color: c.surfaceBase,
          foreground: c.textPrimary,
        ),
        _Swatch(
          name: 'surfaceRaised',
          color: c.surfaceRaised,
          foreground: c.textPrimary,
        ),
        _Swatch(
          name: 'surfaceSunken',
          color: c.surfaceSunken,
          foreground: c.textSecondary,
        ),
        _Swatch(
          name: 'borderSubtle',
          color: c.borderSubtle,
          foreground: c.textPrimary,
        ),
        _Swatch(
          name: 'borderStrong',
          color: c.borderStrong,
          foreground: c.surfaceBase,
        ),
        _Swatch(
          name: 'textPrimary',
          color: c.textPrimary,
          foreground: c.surfaceBase,
        ),
        _Swatch(
          name: 'textSecondary',
          color: c.textSecondary,
          foreground: c.surfaceBase,
        ),
        _Swatch(
          name: 'textTertiary',
          color: c.textTertiary,
          foreground: c.surfaceBase,
        ),
      ],
    );
  }
}

class BrandSwatches extends StatelessWidget {
  const BrandSwatches({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _Swatch(
          name: 'brandPrimary (teal)',
          color: c.brandPrimary,
          foreground: c.onBrandPrimary,
        ),
        _Swatch(
          name: 'brandPrimarySoft',
          color: c.brandPrimarySoft,
          foreground: c.onBrandPrimarySoft,
        ),
        _Swatch(
          name: 'accent (coral)',
          color: c.accentDawn,
          // Decorative color, never a text background; dark ink keeps the
          // label readable in both themes.
          foreground: c.textPrimary,
        ),
        _Swatch(
          name: 'success (teal)',
          color: c.success,
          foreground: c.onBrandPrimary,
        ),
        _Swatch(
          name: 'warning (coral)',
          color: c.warning,
          foreground: c.onBrandPrimary,
        ),
        _Swatch(
          name: 'danger (rose)',
          color: c.danger,
          foreground: c.onBrandPrimary,
        ),
      ],
    );
  }
}

class ActivityPaletteGrid extends StatelessWidget {
  const ActivityPaletteGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final key in ActivityColorKey.values)
          _ActivityChip(name: key.name, colors: context.tokens.activity(key)),
      ],
    );
  }
}

class _ActivityChip extends StatelessWidget {
  const _ActivityChip({required this.name, required this.colors});

  final String name;
  final ActivityColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 152,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.soft,
        borderRadius: AppRadius.mdAll,
      ),
      child: Row(
        children: [
          Container(
            width: AppSpacing.xxl,
            height: AppSpacing.xxl,
            decoration: BoxDecoration(
              color: colors.solid,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(name, style: context.textStyles.labelMedium),
        ],
      ),
    );
  }
}

class TypographySamples extends StatelessWidget {
  const TypographySamples({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.textStyles;
    final numeric = TextStyle(color: context.colors.textPrimary);
    final samples = <(String, TextStyle?)>[
      ('displayLarge', t.displayLarge),
      ('displayMedium', t.displayMedium),
      ('headlineLarge', t.headlineLarge),
      ('headlineSmall', t.headlineSmall),
      ('titleLarge', t.titleLarge),
      ('titleMedium', t.titleMedium),
      ('bodyLarge', t.bodyLarge),
      ('bodyMedium', t.bodyMedium),
      ('labelLarge', t.labelLarge),
      ('labelMedium', t.labelMedium),
      ('labelSmall', t.labelSmall),
      ('numericLarge 4h 32m', AppTypography.numericLarge.merge(numeric)),
      ('numericMedium 1:04:07', AppTypography.numericMedium.merge(numeric)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (name, style) in samples)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(name, style: style),
          ),
        Text('42:17', style: AppTypography.numericHero.merge(numeric)),
      ],
    );
  }
}

class SpacingScale extends StatelessWidget {
  const SpacingScale({super.key});

  static const _values = <(String, double)>[
    ('xxs', AppSpacing.xxs),
    ('xs', AppSpacing.xs),
    ('sm', AppSpacing.sm),
    ('md', AppSpacing.md),
    ('lg', AppSpacing.lg),
    ('xl', AppSpacing.xl),
    ('xxl', AppSpacing.xxl),
    ('xxxl', AppSpacing.xxxl),
    ('huge', AppSpacing.huge),
    ('giant', AppSpacing.giant),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (name, value) in _values)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              children: [
                SizedBox(
                  width: 72,
                  child: Text(
                    '$name ${value.toInt()}',
                    style: context.textStyles.labelSmall,
                  ),
                ),
                Container(
                  width: value,
                  height: AppSpacing.md,
                  color: context.colors.brandPrimary,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class RadiusAndElevation extends StatelessWidget {
  const RadiusAndElevation({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final shadows = context.tokens.shadows;
    Widget box(String label, BorderRadius radius, List<BoxShadow> shadow) =>
        Container(
          width: 96,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: c.surfaceRaised,
            borderRadius: radius,
            border: Border.all(color: c.borderSubtle),
            boxShadow: shadow,
          ),
          child: Text(label, style: context.textStyles.labelSmall),
        );
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        box('xs 8', AppRadius.xsAll, const []),
        box('sm 12', AppRadius.smAll, const []),
        box('md 16', AppRadius.mdAll, const []),
        box('lg 24', AppRadius.lgAll, const []),
        box('card 28', AppRadius.cardAll, const []),
        box('card', AppRadius.cardAll, shadows.card),
        box('floating', AppRadius.cardAll, shadows.floating),
      ],
    );
  }
}

class ButtonSamples extends StatelessWidget {
  const ButtonSamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        AppButton(label: 'Primary', onPressed: () {}),
        AppButton(
          label: 'Secondary',
          variant: AppButtonVariant.secondary,
          onPressed: () {},
        ),
        AppButton(
          label: 'Tertiary',
          variant: AppButtonVariant.tertiary,
          onPressed: () {},
        ),
        AppButton(
          label: 'Destructive',
          variant: AppButtonVariant.destructive,
          onPressed: () {},
        ),
        const AppButton(label: 'Disabled', onPressed: null),
      ],
    );
  }
}
