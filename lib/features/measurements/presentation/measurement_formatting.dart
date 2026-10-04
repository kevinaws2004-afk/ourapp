import '../../../core/units/unit_registry.dart';
import '../../activity_logs/presentation/value_formatting.dart';
import '../domain/measurement.dart';

/// "84.2 kg", "18.5%" — as entered, in the unit the user chose.
String formatMeasurement(Measurement m) {
  final unit = UnitRegistry.byCode(m.unitCode);
  final number = formatNumber(m.value, unit?.displayDecimals ?? 1);
  final symbol = unit?.symbol ?? m.unitCode;
  return symbol == '%' ? '$number%' : '$number $symbol';
}
