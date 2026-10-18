import 'package:daylog/core/design/app_tokens.dart';
import 'package:daylog/core/design/themes/app_theme_id.dart';
import 'package:daylog/core/design/tokens/activity_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// ADR-045: the color themes (each with a dark version built from it);
/// stored activity color keys stay stable and resolve in each.
void main() {
  test('the fifteen themes, and unknown names fall back', () {
    expect(AppThemeId.values.map((t) => t.name), [
      'lavender',
      'rose',
      'papaya',
      'ocean',
      'matcha',
      'lilac',
      'sky',
      'honey',
      'slate',
      'mint',
      'cherry',
      'forest',
      'midnight',
      'mocha',
      'roseGold',
    ]);
    expect(AppThemeId.fallback, AppThemeId.lavender);
    expect(AppThemeId.fromName('dark'), AppThemeId.fallback);
    expect(AppThemeId.fromName(null), AppThemeId.fallback);
    for (final id in AppThemeId.values) {
      expect(AppThemeId.fromName(id.name), id);
      expect(AppTokens.of(id).id, id);
    }
  });

  test('the themes are meaningfully different, not one accent swapped', () {
    final themes = AppThemeId.values.map(AppTokens.of).toList();
    Set<Object> distinct(Object Function(AppTokens t) of) =>
        themes.map(of).toSet();
    // Every theme has its own signature color and canvas.
    expect(distinct((t) => t.colors.brandPrimary), hasLength(themes.length));
    expect(distinct((t) => t.colors.surfaceCanvas), hasLength(themes.length));
  });

  test('success, warning and danger containers are soft (light) tints', () {
    for (final id in AppThemeId.values) {
      final c = AppTokens.of(id).colors;
      for (final soft in [
        c.successContainer,
        c.warningContainer,
        c.dangerContainer,
        c.brandPrimarySoft,
      ]) {
        expect(soft.computeLuminance(), greaterThan(0.7));
      }
    }
  });

  test('there are sixteen activity colors, all different in every theme', () {
    expect(ActivityColorKey.values, hasLength(16));
    expect(ActivityColorKey.values.map((k) => k.name), isNot(contains('sand')));
    for (final id in AppThemeId.values) {
      final tokens = AppTokens.of(id);
      final solids = {
        for (final k in ActivityColorKey.values) tokens.activity(k).solid,
      };
      expect(solids, hasLength(16), reason: id.name);
    }
  });

  test('removed keys resolve to their replacement', () {
    expect(ActivityColorKey.fromName('sage'), ActivityColorKey.teal);
    expect(ActivityColorKey.fromName('moss'), ActivityColorKey.teal);
    expect(ActivityColorKey.fromName('apricot'), ActivityColorKey.coral);
    expect(ActivityColorKey.fromName('sand'), isNull);
  });

  test('the light canvas is never pure white, so white cards stand out', () {
    for (final id in AppThemeId.values) {
      final c = AppTokens.of(id).colors;
      expect(c.surfaceCanvas, isNot(const Color(0xFFFFFFFF)));
      expect(c.surfaceBase, const Color(0xFFFFFFFF));
    }
  });
}
