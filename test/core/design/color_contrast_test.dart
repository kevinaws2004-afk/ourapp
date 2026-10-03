import 'package:daylog/core/design/tokens/activity_palette.dart';
import 'package:daylog/core/design/tokens/color_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the WCAG contrast promises in design_system.md §2 and §14.
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  for (final (name, c, brightness) in [
    ('light', AppColors.light, Brightness.light),
    ('dark', AppColors.dark, Brightness.dark),
  ]) {
    group('$name theme', () {
      test('text roles meet 4.5:1 on the canvas', () {
        expect(
          contrast(c.textPrimary, c.surfaceCanvas),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrast(c.textSecondary, c.surfaceCanvas),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrast(c.textSecondary, c.surfaceSunken),
          greaterThanOrEqualTo(4.5),
        );
      });

      test('brand colors meet 4.5:1 where they carry text', () {
        expect(
          contrast(c.onBrandPrimary, c.brandPrimary),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrast(c.onBrandPrimarySoft, c.brandPrimarySoft),
          greaterThanOrEqualTo(4.5),
        );
      });

      test(
        'brand, accent and status colors meet 3:1 as graphics on the canvas',
        () {
          for (final color in [
            c.brandPrimary,
            c.accentDawn,
            c.success,
            c.warning,
            c.danger,
          ]) {
            expect(contrast(color, c.surfaceCanvas), greaterThanOrEqualTo(3));
          }
        },
      );

      test(
        'danger (rose) may be used as text: 4.5:1 on canvas and base surfaces',
        () {
          expect(
            contrast(c.danger, c.surfaceCanvas),
            greaterThanOrEqualTo(4.5),
          );
          expect(contrast(c.danger, c.surfaceBase), greaterThanOrEqualTo(4.5));
        },
      );

      test('text stays readable on status containers', () {
        for (final container in [
          c.successContainer,
          c.warningContainer,
          c.dangerContainer,
        ]) {
          expect(contrast(c.textPrimary, container), greaterThanOrEqualTo(4.5));
        }
      });

      test('strong borders meet 3:1 on the canvas', () {
        expect(
          contrast(c.borderStrong, c.surfaceCanvas),
          greaterThanOrEqualTo(3),
        );
      });

      test('activity solids meet 3:1 as graphics on the canvas and their soft tint', () {
        for (final key in ActivityColorKey.values) {
          final colors = ActivityPalette.resolve(key, brightness);
          expect(
            contrast(colors.solid, c.surfaceCanvas),
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
