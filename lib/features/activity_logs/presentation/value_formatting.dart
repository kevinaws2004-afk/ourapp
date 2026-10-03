import 'package:flutter/material.dart';

import '../../../core/time/local_date.dart';
import '../../../core/units/unit_registry.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../activity_types/domain/field_config.dart';
import '../domain/activity_log.dart';
import '../domain/field_value.dart';

/// Presentation-only formatting (ADR-021: durations are formatted here, never
/// stored as text).
String formatDuration(AppLocalizations l10n, int milliseconds) {
  final totalMinutes = (milliseconds / Duration.millisecondsPerMinute).round();
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  return hours == 0
      ? l10n.durationMinutes(minutes)
      : l10n.durationHoursMinutes(hours, minutes);
}

/// [value] with at most [decimals] places, trailing zeros removed.
String formatNumber(double value, int decimals) {
  final fixed = value.toStringAsFixed(decimals);
  if (!fixed.contains('.')) return fixed;
  return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
}

String formatDate(BuildContext context, LocalDate date) =>
    MaterialLocalizations.of(context)
        .formatMediumDate(DateTime(date.year, date.month, date.day));

String formatTime(BuildContext context, LocalTime time) =>
    MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay(hour: time.hour, minute: time.minute));

String formatFieldValue(
  BuildContext context,
  ActivityField field,
  FieldValue value,
) {
  final l10n = AppLocalizations.of(context);
  String optionLabel(SelectOptionId id) =>
      (field.config as SelectFieldConfig).optionById(id)?.label ?? '—';
  return switch (value) {
    TextValue(:final text) => text,
    NumberValue(:final value, :final unitCode) => [
      formatNumber(value, (field.config as NumberFieldConfig).decimals),
      if (unitCode != null) UnitRegistry.byCode(unitCode)?.symbol ?? unitCode,
    ].join(' '),
    BooleanValue(:final value) =>
      '${field.name}: ${value ? l10n.booleanYes : l10n.booleanNo}',
    SingleSelectValue(:final optionId) => optionLabel(optionId),
    MultiSelectValue(:final optionIds) => optionIds.map(optionLabel).join(', '),
    DateValue(:final date) => formatDate(context, date),
    TimeValue(:final time) => formatTime(context, time),
    DurationValue(:final milliseconds) => formatDuration(l10n, milliseconds),
    RatingValue(:final stars) =>
      '$stars/${(field.config as RatingFieldConfig).max}',
  };
}

/// A short line describing a log for lists: its first few values in field
/// order (data_architecture.md §4 `summarize`).
String summarizeLog(
  BuildContext context,
  ActivityType type,
  ActivityLog log, {
  int maxParts = 3,
}) {
  final parts = <String>[];
  for (final field in type.fields) {
    final value = log.values[field.id];
    if (value == null) continue;
    parts.add(formatFieldValue(context, field, value));
    if (parts.length == maxParts) break;
  }
  return parts.join(' · ');
}
