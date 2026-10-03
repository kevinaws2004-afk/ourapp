import 'package:daylog/core/design/icons/activity_icon_registry.dart';
import 'package:daylog/core/design/keys/activity_icon_ids.dart';
import 'package:daylog/core/design/tokens/activity_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every activity icon ID resolves to a Phosphor glyph', () {
    for (final id in ActivityIconIds.all) {
      expect(ActivityIconRegistry.hasGlyph(id), isTrue, reason: id);
      expect(ActivityIconRegistry.resolve(id).fontFamily, 'Phosphor');
    }
    expect(ActivityIconIds.all.toSet(), hasLength(ActivityIconIds.all.length));
  });

  test('unknown or legacy icon IDs fall back to a neutral glyph', () {
    expect(
      ActivityIconRegistry.resolve('no-such-icon'),
      ActivityIconRegistry.resolve(ActivityIconIds.fallback),
    );
  });

  test('every color key resolves in both themes', () {
    for (final key in ActivityColorKey.values) {
      for (final brightness in Brightness.values) {
        expect(() => ActivityPalette.resolve(key, brightness), returnsNormally);
      }
      expect(ActivityColorKey.fromName(key.name), key);
    }
  });
}
