import 'package:flutter/material.dart';

import '../../../core/time/local_date.dart';
import '../../../core/units/unit_registry.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../activity_types/domain/field_config.dart';
import '../../activity_types/domain/field_type.dart';
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
    RepeatingGroupValue(:final items) => l10n.groupItemCount(
      (field.config as RepeatingGroupFieldConfig).itemLabel,
      items.length,
    ),
  };
}

/// A group in a summary (A18): each item as its name followed by its values,
/// nested lists included, with repeated rows folded: "Bench press 60 kg × 8
/// (×2), 65 kg × 6; Squat 80 kg × 5". Generic: names are the first text
/// sub-field, all-number rows read "60 kg × 8". Falls back to the item count
/// when nothing is filled in.
String formatGroupSummary(
  BuildContext context,
  ActivityType type,
  ActivityField field,
  RepeatingGroupValue value,
) {
  final nested = type
      .subFieldsOf(field.id, includeRemoved: true)
      .any((f) => f.type == FieldType.repeatingGroup);
  final lines = _groupLines(context, type, field, value);
  return lines.isEmpty
      ? formatFieldValue(context, field, value)
      : lines.join(nested ? '; ' : ', ');
}

/// One line per item of [value], consecutive repeats folded ("… (×2)").
List<String> _groupLines(
  BuildContext context,
  ActivityType type,
  ActivityField field,
  RepeatingGroupValue value,
) {
  final subs = type.subFieldsOf(field.id, includeRemoved: true);
  final name = subs.where((f) => f.type == FieldType.text).firstOrNull;
  final others = [
    for (final sub in subs)
      if (sub.id != name?.id) sub,
  ];
  final allNumbers =
      others.isNotEmpty && others.every((f) => f.type == FieldType.number);
  String line(GroupItem item) {
    final label = switch (name == null ? null : item.values[name.id]) {
      TextValue(:final text) => text,
      _ => null,
    };
    final parts = [
      for (final sub in others)
        if (item.values[sub.id] case final v?)
          v is RepeatingGroupValue
              ? _groupLines(context, type, sub, v).join(', ')
              : formatFieldValue(context, sub, v),
    ].where((p) => p.isNotEmpty);
    return [
      ?label,
      if (parts.isNotEmpty) parts.join(allNumbers ? ' × ' : ' · '),
    ].join(' ');
  }

  final folded = <String>[];
  String? previous;
  var count = 0;
  void flush() {
    if (previous case final p? when p.isNotEmpty) {
      folded.add(count > 1 ? '$p (×$count)' : p);
    }
  }

  for (final item in value.items) {
    final current = line(item);
    if (current == previous) {
      count++;
    } else {
      flush();
      previous = current;
      count = 1;
    }
  }
  flush();
  return folded;
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
  for (final field in type.fields.where((f) => f.parentId == null)) {
    final value = log.values[field.id];
    if (value == null) continue;
    parts.add(
      value is RepeatingGroupValue
          ? formatGroupSummary(context, type, field, value)
          : formatFieldValue(context, field, value),
    );
    if (parts.length == maxParts) break;
  }
  return parts.join(' · ');
}
