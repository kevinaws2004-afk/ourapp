import 'package:daylog/core/units/unit_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('converts to the canonical unit of each dimension', () {
    expect(
      UnitRegistry.byCode('lb')!.toCanonical(100),
      closeTo(45.359237, 1e-9),
    );
    expect(UnitRegistry.byCode('km')!.toCanonical(5), 5000);
    expect(UnitRegistry.byCode('mi')!.toCanonical(1), closeTo(1609.344, 1e-9));
    expect(UnitRegistry.byCode('l')!.toCanonical(1.5), 1500);
    expect(UnitRegistry.byCode('kj')!.toCanonical(418.4), closeTo(100, 1e-9));
  });

  test('temperature conversion is affine and reversible', () {
    final f = UnitRegistry.byCode('fahrenheit')!;
    expect(f.toCanonical(212), closeTo(100, 1e-9));
    expect(f.toCanonical(32), closeTo(0, 1e-9));
    expect(f.fromCanonical(37), closeTo(98.6, 1e-9));
  });

  test(
    'every dimension has its canonical unit with factor 1 and no offset',
    () {
      for (final dimension in Dimension.values) {
        final canonical = UnitRegistry.canonicalFor(dimension);
        expect(canonical.dimension, dimension);
        expect(canonical.factor, 1);
        expect(canonical.offset, 0);
      }
    },
  );

  test('unit codes are unique and dimension membership is checked', () {
    final codes = [
      for (final d in Dimension.values)
        ...UnitRegistry.forDimension(d).map((u) => u.code),
    ];
    expect(codes.toSet(), hasLength(codes.length));
    expect(UnitRegistry.belongsTo('kg', Dimension.mass), isTrue);
    expect(UnitRegistry.belongsTo('kg', Dimension.distance), isFalse);
    expect(UnitRegistry.belongsTo('furlong', Dimension.distance), isFalse);
  });

  test('duration is not offered as a Number dimension (ADR-020)', () {
    expect(Dimension.numberDimensions, isNot(contains(Dimension.duration)));
  });
}
