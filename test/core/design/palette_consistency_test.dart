import 'package:daylog/core/design/tokens/activity_palette.dart';
import 'package:daylog/core/design/tokens/color_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// ADR-029: apart from neutrals (surfaces, text, borders, scrims), every color
/// in the app is one of the nine activity-palette colors.
void main() {
  for (final (name, c, brightness) in [
    ('light', AppColors.light, Brightness.light),
    ('dark', AppColors.dark, Brightness.dark),
  ]) {
    ActivityColors palette(ActivityColorKey key) =>
        ActivityPalette.resolve(key, brightness);

    test(
      '$name: brand is teal, accent apricot, success moss, warning apricot, danger rose',
      () {
        expect(c.brandPrimary, palette(ActivityColorKey.teal).solid);
        expect(c.brandPrimarySoft, palette(ActivityColorKey.teal).soft);
        expect(c.accentDawn, palette(ActivityColorKey.apricot).solid);
        expect(c.success, palette(ActivityColorKey.moss).solid);
        expect(c.successContainer, palette(ActivityColorKey.moss).soft);
        expect(c.warning, palette(ActivityColorKey.apricot).solid);
        expect(c.warningContainer, palette(ActivityColorKey.apricot).soft);
        expect(c.danger, palette(ActivityColorKey.rose).solid);
        expect(c.dangerContainer, palette(ActivityColorKey.rose).soft);
      },
    );
  }

  test('sand is not part of the palette', () {
    expect(ActivityColorKey.values.map((k) => k.name), isNot(contains('sand')));
    expect(ActivityColorKey.values, hasLength(9));
  });
}
