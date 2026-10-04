import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../activity_logs/presentation/value_formatting.dart';
import '../domain/plan.dart';
import '../domain/watch_day_overview.dart';

/// "09:00–10:00", "09:00 · 45 min", "45 min", or null for an untimed plan
/// without a length.
String? formatPlanTime(BuildContext context, Plan plan) {
  final l10n = AppLocalizations.of(context);
  final material = MaterialLocalizations.of(context);
  String time(DateTime instant) =>
      material.formatTimeOfDay(TimeOfDay.fromDateTime(instant.toLocal()));
  final start = plan.plannedStartAt;
  final end = plan.plannedEndAt;
  final duration = plan.plannedDurationMs;
  if (start != null && end != null) {
    return l10n.planTimeRange(time(start), time(end));
  }
  return [
    if (start != null) time(start),
    if (duration != null) formatDuration(l10n, duration),
  ].join(' · ').emptyToNull;
}

/// The reality half of Plan vs Reality: "45 min of 1 h" once done, "In
/// progress", or skipped / cancelled; null while open. "Done" itself isn't
/// spelled out: the ✓ and the filled row say it (A18).
String? formatPlanOutcome(BuildContext context, PlannedItem item) {
  final l10n = AppLocalizations.of(context);
  final actual = item.actualDurationMs;
  final planned = item.plan.plannedLengthMs;
  return switch (item.status) {
    EffectivePlanStatus.planned => null,
    EffectivePlanStatus.inProgress => l10n.planStatusInProgress,
    EffectivePlanStatus.completed => switch ((actual, planned)) {
      (final a?, final p?) => l10n.planRecordedOfPlanned(
        formatDuration(l10n, a),
        formatDuration(l10n, p),
      ),
      (final a?, null) => l10n.planRecordedDuration(formatDuration(l10n, a)),
      _ => null,
    },
    EffectivePlanStatus.skipped => l10n.planStatusSkipped,
    EffectivePlanStatus.cancelled => l10n.planStatusCancelled,
  };
}

extension on String {
  String? get emptyToNull => isEmpty ? null : this;
}
