import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

import '../domain/measurement.dart';

/// What happened when importing from Health Connect.
enum HealthImportOutcome {
  /// Measurements were read (maybe none new).
  done,

  /// Health Connect isn't installed or needs an update.
  unavailable,

  /// The person didn't allow reading.
  denied,
}

/// One measurement read from Health Connect, before it's recorded.
class HealthReading {
  const HealthReading(this.type, this.value, this.unitCode, this.at);

  final MeasurementType type;
  final double value;
  final String unitCode;
  final DateTime at;
}

/// Reads weight, height and body fat from Android's Health Connect (only
/// with the person's permission, only when they ask). Daylog never writes
/// to Health Connect and nothing leaves the phone.
class HealthConnectImport {
  HealthConnectImport({Health? health}) : _health = health ?? Health();

  final Health _health;

  static const _types = [
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.BODY_FAT_PERCENTAGE,
  ];

  static bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<bool> isAvailable() async {
    if (!isSupported) return false;
    await _health.configure();
    return await _health.getHealthConnectSdkStatus() ==
        HealthConnectSdkStatus.sdkAvailable;
  }

  /// Opens the Play Store page to install Health Connect.
  Future<void> install() => _health.installHealthConnect();

  /// Asks for permission if needed, then reads the last [days] days.
  Future<(HealthImportOutcome, List<HealthReading>)> read({
    required DateTime nowUtc,
    int days = 365,
  }) async {
    if (!await isAvailable()) {
      return (HealthImportOutcome.unavailable, const <HealthReading>[]);
    }
    final access = [for (final _ in _types) HealthDataAccess.READ];
    final has = await _health.hasPermissions(_types, permissions: access);
    if (has != true &&
        !await _health.requestAuthorization(_types, permissions: access)) {
      return (HealthImportOutcome.denied, const <HealthReading>[]);
    }
    final points = await _health.getHealthDataFromTypes(
      types: _types,
      startTime: nowUtc.subtract(Duration(days: days)),
      endTime: nowUtc,
    );
    final readings = <HealthReading>[];
    for (final p in points) {
      final value = p.value;
      if (value is! NumericHealthValue) continue;
      final number = value.numericValue.toDouble();
      if (!number.isFinite || number <= 0) continue;
      final at = p.dateFrom.toUtc();
      switch (p.type) {
        case HealthDataType.WEIGHT:
          readings.add(HealthReading(MeasurementType.weight, number, 'kg', at));
        case HealthDataType.HEIGHT:
          // Meters in Health Connect; centimeters here.
          readings.add(
            HealthReading(MeasurementType.height, number * 100, 'cm', at),
          );
        case HealthDataType.BODY_FAT_PERCENTAGE:
          if (number <= 100) {
            readings.add(
              HealthReading(MeasurementType.bodyFat, number, 'percent', at),
            );
          }
        default:
          break;
      }
    }
    return (HealthImportOutcome.done, readings);
  }
}

/// [readings] not already recorded: the same type at the same minute, or
/// the same value on the same day, counts as already there (a second import
/// adds nothing).
List<HealthReading> newReadings(
  List<HealthReading> readings,
  Map<MeasurementType, List<Measurement>> existing,
) {
  bool known(HealthReading r) {
    for (final m in existing[r.type] ?? const <Measurement>[]) {
      final sameMinute = m.recordedAt.difference(r.at).inMinutes.abs() < 1;
      final sameDayValue =
          m.recordedAt.toLocal().day == r.at.toLocal().day &&
          m.recordedAt.difference(r.at).inHours.abs() < 24 &&
          (m.value - r.value).abs() < 0.05;
      if (sameMinute || sameDayValue) return true;
    }
    return false;
  }

  return [
    for (final r in readings)
      if (!known(r)) r,
  ];
}
