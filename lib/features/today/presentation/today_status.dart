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
  if (progress.allDone && progress.letGo > 0) {
    return l10n.statusDoneLetGo(done, progress.letGo);
  }
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

/// The hero's line under "2 of 5 done": encouragement, not a repeat of the
/// count.
String heroLine(
  BuildContext context,
  DayProgress? progress,
  PlannedItem? running, {
  bool paused = false,
  int localHour = 12,
}) {
  final l10n = AppLocalizations.of(context);
  if (progress == null) return '';
  if (running != null) {
    return paused
        ? l10n.heroPaused(running.plan.title)
        : l10n.heroRunning(running.plan.title);
  }
  if (progress.total == 0) return l10n.heroEmpty;
  if (progress.allDone && progress.letGo > 0) {
    return l10n.heroDoneLetGo(progress.done, progress.letGo);
  }
  if (progress.allDone) return l10n.heroAllDone;
  final left = progress.total - progress.done;
  // Late at night, "keep it up" is the wrong tone.
  if (left > 0 && localHour >= 21) return l10n.heroWrapUp;
  if (progress.done == 0) {
    return switch (progress.firstStart) {
      final first? => l10n.heroFirstAt(
        MaterialLocalizations.of(context)
            .formatTimeOfDay(TimeOfDay.fromDateTime(first.toLocal())),
      ),
      null => l10n.heroLetsGo,
    };
  }
  return l10n.heroToGo(left);
}
