import 'package:daylog/core/design/app_tokens.dart';
import 'package:daylog/core/design/themes/app_theme_id.dart';
import 'package:daylog/core/design/tokens/activity_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the WCAG contrast promises in design_system.md §2 and §14 for
/// every theme (ADR-045).
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  for (final id in AppThemeId.values) {
    final tokens = AppTokens.of(id);
    final c = tokens.colors;
    group('${id.name} theme', () {
      test('text roles meet 4.5:1 on every surface and soft container', () {
        for (final surface in [
          c.surfaceCanvas,
          c.surfaceBase,
          c.surfaceSunken,
          c.brandPrimarySoft,
          c.actionSoft,
          c.accentSoft,
          c.successContainer,
          c.warningContainer,
          c.dangerContainer,
        ]) {
          for (final text in [c.textPrimary, c.textSecondary]) {
            expect(
              contrast(text, surface),
              greaterThanOrEqualTo(4.5),
              reason: '$text on $surface',
            );
          }
        }
      });

      test('every filled role carries its text at 4.5:1', () {
        for (final (on, fill) in [
          (c.onBrandPrimary, c.brandPrimary),
          (c.onBrandPrimarySoft, c.brandPrimarySoft),
          (c.onAction, c.action),
          (c.onActionSoft, c.actionSoft),
          (c.onAccentSoft, c.accentSoft),
          // Snack bars: inverse.
          (c.surfaceBase, c.textPrimary),
          (c.brandPrimarySoft, c.textPrimary),
        ]) {
          expect(contrast(on, fill), greaterThanOrEqualTo(4.5));
        }
      });

      test('graphic roles meet 3:1 on the canvas and on cards', () {
        for (final color in [
          c.brandPrimary,
          c.accent,
          c.success,
          c.warning,
          c.danger,
          c.borderStrong,
        ]) {
          expect(contrast(color, c.surfaceCanvas), greaterThanOrEqualTo(3));
          expect(contrast(color, c.surfaceBase), greaterThanOrEqualTo(3));
        }
      });

      test('brand and danger may be used as text on canvas and cards', () {
        for (final color in [c.brandPrimary, c.danger]) {
          expect(contrast(color, c.surfaceCanvas), greaterThanOrEqualTo(4.5));
          expect(contrast(color, c.surfaceBase), greaterThanOrEqualTo(4.5));
        }
      });

      test('activity solids meet 3:1 on cards and their soft tint; text on '
          'the tint 4.5:1', () {
        for (final key in ActivityColorKey.values) {
          final colors = tokens.activity(key);
          expect(
            contrast(colors.solid, c.surfaceBase),
            greaterThanOrEqualTo(3),
            reason: key.name,
          );
          expect(
            contrast(colors.solid, colors.soft),
            greaterThanOrEqualTo(3),
            reason: key.name,
          );
          expect(
            contrast(c.textPrimary, colors.soft),
            greaterThanOrEqualTo(4.5),
            reason: key.name,
          );
        }
      });
    });
  }
}
