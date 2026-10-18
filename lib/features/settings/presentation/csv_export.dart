import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../activity_logs/domain/field_value.dart';
import '../../activity_logs/presentation/activity_log_providers.dart';
import '../../activity_logs/presentation/value_formatting.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../activity_types/domain/field_type.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../../measurements/domain/measurement.dart';
import '../../measurements/presentation/measurement_copy.dart';
import '../../measurements/presentation/measurement_providers.dart';

/// Spreadsheet export: one CSV per activity (a row per record: date,
/// times, duration, notes, then each field as people read it; lists like
/// sets in one cell) and one for body measurements, shared together.
/// Returns how many files were made (0: nothing recorded yet).
Future<int> shareCsvExport(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final material = MaterialLocalizations.of(context);
  final types = await ref.read(activeActivityTypesProvider.future);
  final logs = ref.read(activityLogRepositoryProvider);
  final dir = Directory('${(await getTemporaryDirectory()).path}/csv');
  if (dir.existsSync()) dir.deleteSync(recursive: true);
  await dir.create(recursive: true);
  final files = <XFile>[];
  final usedNames = <String>{};

  String fileName(String name) {
    var base = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    if (base.isEmpty) base = 'activity';
    var candidate = base;
    for (var i = 2; !usedNames.add(candidate); i++) {
      candidate = '$base-$i';
    }
    return '$candidate.csv';
  }

  String time(DateTime? utc) => utc == null
      ? ''
      : material.formatTimeOfDay(
          TimeOfDay.fromDateTime(utc.toLocal()),
          alwaysUse24HourFormat: true,
        );

  for (final type in types) {
    if (!context.mounted) return 0;
    final records = await logs.recentLogsForType(type.id, limit: 1 << 30);
    if (records.isEmpty) continue;
    final fields = type.activeFields;
    final rows = <List<String>>[
      [
        l10n.csvDate,
        l10n.csvStart,
        l10n.csvEnd,
        l10n.csvMinutes,
        l10n.csvNotes,
        for (final f in fields) f.name,
      ],
      for (final log in records.reversed)
        [
          log.localDate.toIso(),
          time(log.startedAt),
          time(log.endedAt),
          log.durationMs == null
              ? ''
              : formatNumber(log.durationMs! / 60000, 1),
          log.notes ?? '',
          for (final f in fields)
            if (!context.mounted)
              ''
            else
              _cell(context, type, f, log.values[f.id]),
        ],
    ];
    final file = File('${dir.path}/${fileName(type.name)}');
    await file.writeAsString(_csv(rows), flush: true);
    files.add(XFile(file.path, mimeType: 'text/csv'));
  }

  // Body measurements, all types in one sheet.
  final measurementRows = <List<String>>[
    [l10n.csvDate, l10n.csvMeasurement, l10n.csvValue, l10n.csvUnit],
  ];
  final repo = ref.read(measurementRepositoryProvider);
  for (final type in MeasurementType.values) {
    final history = await repo.watchForType(type).first;
    for (final m in history.reversed) {
      measurementRows.add([
        m.localDate.toIso(),
        measurementTypeLabel(l10n, type),
        formatNumber(m.value, 2),
        m.unitCode,
      ]);
    }
  }
  if (measurementRows.length > 1) {
    final file = File('${dir.path}/${fileName(l10n.measurementsTitle)}');
    await file.writeAsString(_csv(measurementRows), flush: true);
    files.add(XFile(file.path, mimeType: 'text/csv'));
  }

  if (files.isEmpty) return 0;
  await SharePlus.instance.share(
    ShareParams(files: files, subject: l10n.csvShareSubject),
  );
  return files.length;
}

String _cell(
  BuildContext context,
  ActivityType type,
  ActivityField field,
  FieldValue? value,
) => switch (value) {
  null => '',
  RepeatingGroupValue() when field.type == FieldType.repeatingGroup =>
    formatGroupSummary(context, type, field, value),
  BooleanValue(:final value) =>
    value
        ? AppLocalizations.of(context).booleanYes
        : AppLocalizations.of(context).booleanNo,
  final v => formatFieldValue(context, field, v),
};

/// RFC 4180: fields with commas, quotes or line breaks are quoted. A BOM
/// first so spreadsheet apps read it as UTF-8.
String _csv(List<List<String>> rows) {
  String field(String value) => value.contains(RegExp('[",\r\n]'))
      ? '"${value.replaceAll('"', '""')}"'
      : value;
  return '﻿${rows.map((r) => r.map(field).join(',')).join('\r\n')}\r\n';
}
