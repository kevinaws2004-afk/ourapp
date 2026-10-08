import 'package:daylog/core/design/app_tokens.dart';
import 'package:daylog/core/design/themes/app_theme_id.dart';
import 'package:daylog/core/design/tokens/activity_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// ADR-045: three light themes; stored activity color keys stay the same six
/// and resolve in each.
void main() {
  test('there are three themes and unknown names fall back', () {
    expect(AppThemeId.values.map((t) => t.name), [
      'rose',
      'lavender',
      'papaya',
    ]);
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
    expect(distinct((t) => t.colors.surfaceCanvas), hasLength(3));
    expect(distinct((t) => t.colors.brandPrimary), hasLength(3));
    expect(distinct((t) => t.colors.action), hasLength(3));
    expect(distinct((t) => t.treatments.cardEdge), hasLength(3));
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

  test('there are six activity colors', () {
    expect(ActivityColorKey.values, hasLength(6));
    expect(ActivityColorKey.values.map((k) => k.name), isNot(contains('sand')));
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
