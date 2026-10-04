/// The code-defined unit registry (ADR-020).
///
/// Values keep the unit they were entered in (`unitCode`) plus a
/// write-time `normalizedValue` in the dimension's canonical unit, so history
/// is comparable without converting on every read.
///
/// Unit codes are **permanent**: never rename or remove one (stored data
/// references them). Adding a unit is a code change only.
library;

/// A physical quantity. Stored as [code] on `activity_fields.dimension`.
enum Dimension {
  mass('mass'),
  distance('distance'),
  volume('volume'),
  temperature('temperature'),
  energy('energy'),

  /// A share of a whole, e.g. body fat (Phase 6).
  percentage('percentage'),

  /// Conversion/formatting only. Durations are stored with the Duration field
  /// type (`duration_ms`), so this isn't offered as a Number dimension.
  duration('duration');

  const Dimension(this.code);

  final String code;

  /// Dimensions a Number field may declare.
  static const numberDimensions = [
    mass,
    distance,
    volume,
    temperature,
    energy,
    percentage,
  ];

  static Dimension? fromCode(String? code) {
    for (final d in values) {
      if (d.code == code) return d;
    }
    return null;
  }
}

/// One unit: `canonical = value × factor + offset`.
class Unit {
  const Unit({
    required this.code,
    required this.dimension,
    required this.symbol,
    required this.factor,
    this.offset = 0,
    this.displayDecimals = 1,
  });

  /// Stable identifier stored in the database.
  final String code;
  final Dimension dimension;

  /// Short display symbol (not localized; units are international symbols).
  final String symbol;
  final double factor;
  final double offset;
  final int displayDecimals;

  double toCanonical(double value) => value * factor + offset;

  double fromCanonical(double canonical) => (canonical - offset) / factor;
}

abstract final class UnitRegistry {
  static const _units = <Unit>[
    // Mass. Canonical: kg.
    Unit(code: 'kg', dimension: Dimension.mass, symbol: 'kg', factor: 1),
    Unit(
      code: 'g',
      dimension: Dimension.mass,
      symbol: 'g',
      factor: 0.001,
      displayDecimals: 0,
    ),
    Unit(
      code: 'lb',
      dimension: Dimension.mass,
      symbol: 'lb',
      factor: 0.45359237,
    ),
    Unit(
      code: 'oz',
      dimension: Dimension.mass,
      symbol: 'oz',
      factor: 0.028349523125,
    ),
    // Distance. Canonical: m.
    Unit(
      code: 'm',
      dimension: Dimension.distance,
      symbol: 'm',
      factor: 1,
      displayDecimals: 0,
    ),
    Unit(
      code: 'km',
      dimension: Dimension.distance,
      symbol: 'km',
      factor: 1000,
      displayDecimals: 2,
    ),
    // Body lengths (Phase 6 measurements).
    Unit(code: 'cm', dimension: Dimension.distance, symbol: 'cm', factor: 0.01),
    Unit(
      code: 'in',
      dimension: Dimension.distance,
      symbol: 'in',
      factor: 0.0254,
    ),
    Unit(
      code: 'mi',
      dimension: Dimension.distance,
      symbol: 'mi',
      factor: 1609.344,
      displayDecimals: 2,
    ),
    Unit(
      code: 'ft',
      dimension: Dimension.distance,
      symbol: 'ft',
      factor: 0.3048,
      displayDecimals: 0,
    ),
    Unit(
      code: 'yd',
      dimension: Dimension.distance,
      symbol: 'yd',
      factor: 0.9144,
      displayDecimals: 0,
    ),
    // Volume. Canonical: ml.
    Unit(
      code: 'ml',
      dimension: Dimension.volume,
      symbol: 'ml',
      factor: 1,
      displayDecimals: 0,
    ),
    Unit(
      code: 'l',
      dimension: Dimension.volume,
      symbol: 'L',
      factor: 1000,
      displayDecimals: 2,
    ),
    Unit(
      code: 'fl_oz_us',
      dimension: Dimension.volume,
      symbol: 'fl oz',
      factor: 29.5735295625,
    ),
    Unit(
      code: 'cup_us',
      dimension: Dimension.volume,
      symbol: 'cup',
      factor: 236.5882365,
      displayDecimals: 2,
    ),
    // Temperature. Canonical: °C (affine).
    Unit(
      code: 'celsius',
      dimension: Dimension.temperature,
      symbol: '°C',
      factor: 1,
    ),
    Unit(
      code: 'fahrenheit',
      dimension: Dimension.temperature,
      symbol: '°F',
      factor: 5 / 9,
      offset: -160 / 9,
    ),
    // Energy. Canonical: kcal.
    Unit(
      code: 'kcal',
      dimension: Dimension.energy,
      symbol: 'kcal',
      factor: 1,
      displayDecimals: 0,
    ),
    Unit(
      code: 'kj',
      dimension: Dimension.energy,
      symbol: 'kJ',
      factor: 1 / 4.184,
      displayDecimals: 0,
    ),
    // Duration. Canonical: ms (formatting/conversion only).
    Unit(
      code: 'ms',
      dimension: Dimension.duration,
      symbol: 'ms',
      factor: 1,
      displayDecimals: 0,
    ),
    Unit(
      code: 's',
      dimension: Dimension.duration,
      symbol: 's',
      factor: 1000,
      displayDecimals: 0,
    ),
    Unit(
      code: 'min',
      dimension: Dimension.duration,
      symbol: 'min',
      factor: 60000,
      displayDecimals: 0,
    ),
    Unit(
      code: 'h',
      dimension: Dimension.duration,
      symbol: 'h',
      factor: 3600000,
    ),
  ];

  static const _percent = Unit(
    code: 'percent',
    dimension: Dimension.percentage,
    symbol: '%',
    factor: 1,
  );

  static final Map<String, Unit> _byCode = {
    for (final u in [..._units, _percent]) u.code: u,
  };

  static const Map<Dimension, String> canonicalCodes = {
    Dimension.mass: 'kg',
    Dimension.distance: 'm',
    Dimension.volume: 'ml',
    Dimension.temperature: 'celsius',
    Dimension.energy: 'kcal',
    Dimension.percentage: 'percent',
    Dimension.duration: 'ms',
  };

  static Unit? byCode(String code) => _byCode[code];

  static List<Unit> forDimension(Dimension dimension) => [
    ..._units,
    _percent,
  ].where((u) => u.dimension == dimension).toList(growable: false);

  static Unit canonicalFor(Dimension dimension) =>
      _byCode[canonicalCodes[dimension]]!;

  static bool belongsTo(String unitCode, Dimension dimension) =>
      _byCode[unitCode]?.dimension == dimension;
}
