import 'package:daylog/core/design/tokens/activity_palette.dart';
import 'package:daylog/core/design/tokens/color_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// ADR-029/ADR-038: apart from neutrals (white and slate shades), every color
/// in the app is one of the six activity-palette colors.
void main() {
  for (final (name, c, brightness) in [
    ('light', AppColors.light, Brightness.light),
    ('dark', AppColors.dark, Brightness.dark),
  ]) {
    ActivityColors palette(ActivityColorKey key) =>
        ActivityPalette.resolve(key, brightness);

    test(
      '$name: brand is teal, accent coral, success teal, warning coral, danger rose',
      () {
        expect(c.brandPrimary, palette(ActivityColorKey.teal).solid);
        expect(c.brandPrimarySoft, palette(ActivityColorKey.teal).soft);
        expect(c.accentDawn, palette(ActivityColorKey.coral).solid);
        expect(c.success, palette(ActivityColorKey.teal).solid);
        expect(c.successContainer, palette(ActivityColorKey.teal).soft);
        expect(c.warning, palette(ActivityColorKey.coral).solid);
        expect(c.warningContainer, palette(ActivityColorKey.coral).soft);
        expect(c.danger, palette(ActivityColorKey.rose).solid);
        expect(c.dangerContainer, palette(ActivityColorKey.rose).soft);
      },
    );
  }

  test('sand is not part of the palette', () {
    expect(ActivityColorKey.values.map((k) => k.name), isNot(contains('sand')));
    expect(ActivityColorKey.values, hasLength(6));
  });

  test('removed keys resolve to their replacement', () {
    expect(ActivityColorKey.fromName('sage'), ActivityColorKey.teal);
    expect(ActivityColorKey.fromName('moss'), ActivityColorKey.teal);
    expect(ActivityColorKey.fromName('apricot'), ActivityColorKey.coral);
    expect(ActivityColorKey.fromName('sand'), isNull);
  });

  test('mist #DDF0EF is the light sunken surface and teal soft', () {
    expect(AppColors.light.surfaceSunken, const Color(0xFFDDF0EF));
    expect(
      ActivityPalette.resolve(ActivityColorKey.teal, Brightness.light).soft,
      const Color(0xFFDDF0EF),
    );
  });
}
