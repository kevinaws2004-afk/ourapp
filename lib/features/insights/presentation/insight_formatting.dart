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
/// (ADR-020) and formatted by what they are. Durations are stored in ms and
/// shown as time; yes/no as the share of "yes"; times of day as clock
/// times; ratings on their own scale (D5).
class InsightDisplay {
  const InsightDisplay._(
    this._convert,
    this._format, {
    this.isDuration = false,
    this.wholeNumbers = false,
    this.fixedMax,
  });

  final double Function(double canonical) _convert;
  final String Function(double display) _format;
  final bool isDuration;

  /// Shown without decimals (counts, minutes, whole units): chart axes use
  /// whole steps so labels never repeat (A22).
  final bool wholeNumbers;

  /// A fixed top for the chart's axis (a rating's scale, 100 %).
  final double? fixedMax;

  double convert(double canonical) => _convert(canonical);

  String format(double canonical) => _format(_convert(canonical));

  /// Compact axis label for a converted value.
  String axis(double display) => _format(display);

  static InsightDisplay of(
    AppLocalizations l10n,
    InsightSource source,
    ActivityType? type, {
    MaterialLocalizations? material,
  }) {
    InsightDisplay unit(String? code, {int decimals = 1, double? fixedMax}) {
      final u = code == null ? null : UnitRegistry.byCode(code);
      return InsightDisplay._(
        (v) => u?.fromCanonical(v) ?? v,
        (v) => [
          formatNumber(v, decimals),
          if (u != null) u.symbol,
        ].join(u?.symbol == '%' ? '' : ' '),
        wholeNumbers: decimals == 0,
        fixedMax: fixedMax,
      );
    }

    final time = InsightDisplay._(
      (ms) => ms / Duration.millisecondsPerMinute,
      (minutes) => formatDuration(
        l10n,
        (minutes * Duration.millisecondsPerMinute).round(),
      ),
      isDuration: true,
      wholeNumbers: true,
    );

    InsightDisplay field(ActivityFieldId id) {
      final field = type?.fieldById(id);
      return switch (field?.config) {
        NumberFieldConfig(:final defaultUnitCode) => unit(defaultUnitCode),
        RatingFieldConfig(:final max) => unit(null, fixedMax: max.toDouble()),
        DurationFieldConfig() => time,
        BooleanFieldConfig() => InsightDisplay._(
          (share) => share * 100,
          (percent) => l10n.insightPercent(formatNumber(percent, 0)),
          wholeNumbers: true,
          fixedMax: 100,
        ),
        TimeFieldConfig() => InsightDisplay._((minutes) => minutes, (minutes) {
          final m = minutes.round() % (24 * 60);
          final timeOfDay = TimeOfDay(hour: m ~/ 60, minute: m % 60);
          return material?.formatTimeOfDay(timeOfDay) ??
              '${timeOfDay.hour}:${'${timeOfDay.minute}'.padLeft(2, '0')}';
        }, wholeNumbers: true),
        _ => unit(null),
      };
    }

    return switch (source) {
      ActivityDurationSource() || PlannedVsActualSource() => time,
      ActivityCountSource() => InsightDisplay._(
        (v) => v,
        (v) => formatNumber(v, 0),
        wholeNumbers: true,
      ),
      FieldValueSource(:final fieldId) => field(fieldId),
      VolumeSource(:final amountFieldId, :final formula) => unit(switch (type
          ?.fieldById(amountFieldId)
          ?.config) {
        NumberFieldConfig(:final defaultUnitCode) => defaultUnitCode,
        _ => null,
      }, decimals: formula == VolumeFormula.product ? 0 : 1),
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

/// What a chart's headline number is, for the period shown (A21): "total
/// this period", "best this period", …
String periodValueLabel(AppLocalizations l10n, Aggregation a) => switch (a) {
  Aggregation.sum => l10n.insightPeriodTotal,
  Aggregation.average => l10n.insightPeriodAverage,
  Aggregation.max => l10n.insightPeriodBest,
  Aggregation.min => l10n.insightPeriodLowest,
  Aggregation.count => l10n.insightPeriodCount,
  Aggregation.latest => l10n.insightAggLatest,
};

/// "Sep 5 – Oct 4": the period every number on the screen covers (A20).
String formatPeriod(BuildContext context, LocalDate from, LocalDate to) {
  final material = MaterialLocalizations.of(context);
  String d(LocalDate x) =>
      material.formatShortMonthDay(DateTime(x.year, x.month, x.day));
  return AppLocalizations.of(context).insightPeriod(d(from), d(to));
}

String bucketName(AppLocalizations l10n, Bucket b) => switch (b) {
  Bucket.day => l10n.insightBucketDay,
  Bucket.week => l10n.insightBucketWeek,
  Bucket.month => l10n.insightBucketMonth,
};

/// "+5" / "−3" (neutral; no judgement).
String formatSignedNumber(int value) => value >= 0 ? '+$value' : '−${-value}';

/// "+12 %" / "−8 %" (neutral; no judgement).
String formatChange(double change) {
  final percent = (change * 100).round();
  return percent >= 0 ? '+$percent %' : '−${-percent} %';
}

String measurementName(AppLocalizations l10n, MeasurementType type) =>
    measurementTypeLabel(l10n, type);
