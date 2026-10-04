import 'package:flutter/material.dart';

import '../../../core/time/local_date.dart';
import '../../../core/units/unit_registry.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../activity_logs/presentation/value_formatting.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../activity_types/domain/field_config.dart';
import '../../measurements/domain/measurement.dart';
import '../../measurements/presentation/measurement_copy.dart';
import '../domain/insight.dart';

/// How a source's canonical values are shown: converted to the user's unit
/// (ADR-020) and formatted. Durations are stored in ms and shown as time.
class InsightDisplay {
  const InsightDisplay._(
    this._convert,
    this._format, {
    this.isDuration = false,
  });

  final double Function(double canonical) _convert;
  final String Function(double display) _format;
  final bool isDuration;

  double convert(double canonical) => _convert(canonical);

  String format(double canonical) => _format(_convert(canonical));

  /// Compact axis label for a converted value.
  String axis(double display) => _format(display);

  static InsightDisplay of(
    AppLocalizations l10n,
    InsightSource source,
    ActivityType? type,
  ) {
    InsightDisplay unit(String? code, {int decimals = 1}) {
      final u = code == null ? null : UnitRegistry.byCode(code);
      return InsightDisplay._(
        (v) => u?.fromCanonical(v) ?? v,
        (v) => [
          formatNumber(v, decimals),
          if (u != null) u.symbol,
        ].join(u?.symbol == '%' ? '' : ' '),
      );
    }

    String? fieldUnit(ActivityFieldId id) => switch (type?.fieldById(id)) {
      ActivityField(config: NumberFieldConfig(:final defaultUnitCode)) =>
        defaultUnitCode,
      _ => null,
    };

    return switch (source) {
      ActivityDurationSource() || PlannedVsActualSource() => InsightDisplay._(
        (ms) => ms / Duration.millisecondsPerMinute,
        (minutes) => formatDuration(
          l10n,
          (minutes * Duration.millisecondsPerMinute).round(),
        ),
        isDuration: true,
      ),
      ActivityCountSource() => InsightDisplay._(
        (v) => v,
        (v) => formatNumber(v, 0),
      ),
      FieldValueSource(:final fieldId) => unit(fieldUnit(fieldId)),
      VolumeSource(:final amountFieldId) => unit(
        fieldUnit(amountFieldId),
        decimals: 0,
      ),
      MeasurementSource(:final type) => unit(type.defaultUnitCode),
    };
  }
}

/// Short label for a bucket starting on [start].
String bucketLabel(BuildContext context, LocalDate start, Bucket bucket) {
  final material = MaterialLocalizations.of(context);
  final date = DateTime(start.year, start.month, start.day);
  return switch (bucket) {
    Bucket.day || Bucket.week => material.formatShortMonthDay(date),
    Bucket.month => material.formatMonthYear(date).split(' ').first,
  };
}

String rangeLabel(AppLocalizations l10n, InsightRange range) => switch (range) {
  InsightRange.week => l10n.insightRangeWeek,
  InsightRange.month => l10n.insightRangeMonth,
  InsightRange.quarter => l10n.insightRangeQuarter,
  InsightRange.year => l10n.insightRangeYear,
};

String aggregationLabel(AppLocalizations l10n, Aggregation a) => switch (a) {
  Aggregation.sum => l10n.insightAggSum,
  Aggregation.average => l10n.insightAggAverage,
  Aggregation.max => l10n.insightAggMax,
  Aggregation.min => l10n.insightAggMin,
  Aggregation.count => l10n.insightAggCount,
  Aggregation.latest => l10n.insightAggLatest,
};

String bucketName(AppLocalizations l10n, Bucket b) => switch (b) {
  Bucket.day => l10n.insightBucketDay,
  Bucket.week => l10n.insightBucketWeek,
  Bucket.month => l10n.insightBucketMonth,
};

/// "+12 %" / "−8 %" (neutral; no judgement).
String formatChange(double change) {
  final percent = (change * 100).round();
  return percent >= 0 ? '+$percent %' : '−${-percent} %';
}

String measurementName(AppLocalizations l10n, MeasurementType type) =>
    measurementTypeLabel(l10n, type);
