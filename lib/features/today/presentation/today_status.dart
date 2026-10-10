import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../activity_logs/presentation/value_formatting.dart';
import '../../plans/domain/day_progress.dart';
import '../../plans/domain/watch_day_overview.dart';

/// Today's status line (ADR-046), one sentence for the moment of the day:
/// "5 things today · first at 7:00", "2 of 5 done · 1h 15m so far",
/// "Meditation running · 2 of 5 done", "All 5 done · 3h 20m", "Nothing
/// planned yet".
String todayStatusLine(
  BuildContext context,
  DayProgress? progress,
  PlannedItem? running,
) {
  final l10n = AppLocalizations.of(context);
  if (progress == null) return '';
  final DayProgress(:done, :total, :recordedMs) = progress;
  if (running != null) {
    return l10n.todayStatusRunning(running.plan.title, done, total);
  }
  if (total == 0) return l10n.todayStatusEmpty;
  final time = recordedMs > 0 ? formatDuration(l10n, recordedMs) : null;
  if (progress.allDone) {
    return time == null
        ? l10n.todayStatusAllDone(total)
        : l10n.todayStatusAllDoneTime(total, time);
  }
  if (done == 0) {
    return switch (progress.firstStart) {
      final first? => l10n.todayStatusPlanned(
        total,
        MaterialLocalizations.of(context)
            .formatTimeOfDay(TimeOfDay.fromDateTime(first.toLocal())),
      ),
      null => l10n.todayStatusPlannedAnytime(total),
    };
  }
  return time == null
      ? l10n.todayStatusProgress(done, total)
      : l10n.todayStatusProgressTime(done, total, time);
}
