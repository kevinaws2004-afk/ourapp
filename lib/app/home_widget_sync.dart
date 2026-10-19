import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

import '../core/time/clock_provider.dart';
import '../features/activity_logs/presentation/value_formatting.dart';
import '../features/challenges/presentation/challenge_providers.dart';
import '../features/focus/domain/focus_session.dart';
import '../features/focus/presentation/focus_providers.dart';
import '../features/plans/domain/day_progress.dart';
import '../features/plans/presentation/plan_date_notifier.dart';
import '../features/plans/presentation/plan_providers.dart';
import '../l10n/device_localizations.dart';

/// The Android widget's provider class (`TodayWidgetProvider.kt`).
const _androidWidget = 'com.ourapp.daylog.TodayWidgetProvider';

/// Asks the shell to open Quick start (from the widget's button or the
/// Quick Settings tile). It stays pending until the shell takes it, so a
/// request made while the app is still starting isn't lost.
final quickStartRequestProvider = NotifierProvider<QuickStartRequest, bool>(
  QuickStartRequest.new,
);

class QuickStartRequest extends Notifier<bool> {
  @override
  bool build() => false;

  void request() => state = true;

  /// True once: the caller opens Quick start.
  bool take() {
    if (!state) return false;
    state = false;
    return true;
  }
}

/// Keeps the Today widget's text in step with today: progress, time and
/// streak, what's next (or running), written for the widget to draw while
/// the app is closed. Watched once by the app; Android only.
final homeWidgetSyncProvider = Provider<void>((ref) {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
  if (Platform.environment.containsKey('FLUTTER_TEST')) return;
  final clock = ref.read(clockProvider);
  final today = currentLocalDate(clock);
  Timer? debounce;
  ref.onDispose(() => debounce?.cancel());

  Future<void> push() async {
    final overview = ref.read(dayOverviewProvider(today)).value;
    if (overview == null) return;
    final l10n = deviceLocalizations();
    final locale = l10n.localeName;
    final now = clock.nowUtc();
    final progress = DayProgress.of(overview);
    final session = ref.read(activeFocusSessionProvider).value;
    final streaks = ref.read(activityStreaksProvider).values;
    final best = streaks.isEmpty
        ? 0
        : streaks.map((s) => s.days).reduce((a, b) => a > b ? a : b);
    String time(DateTime utc) =>
        DateFormat.jm(locale)
            .format(utc.add(clock.offsetAt(utc)).copyWith(isUtc: false));

    final String headline;
    if (progress.total == 0) {
      headline = l10n.widgetNothingPlanned;
    } else if (progress.allDone) {
      headline = l10n.todayStatusAllDone(progress.total);
    } else {
      headline = l10n.heroDoneOf(progress.done, progress.total);
    }
    final detail = [
      if (progress.recordedMs > 0)
        l10n.heroTrackedValue(formatDuration(l10n, progress.recordedMs)),
      if (best > 0) l10n.widgetStreak(best),
    ].join(' · ');

    String? next;
    if (session != null && session.state.isActive) {
      final running = overview.planned
          .where((i) => i.plan.id == session.planId)
          .firstOrNull;
      next = session.state == FocusState.paused
          ? l10n.widgetPaused(running?.plan.title ?? '')
          : l10n.widgetRunning(
              running?.plan.title ?? '',
              formatDuration(l10n, session.elapsedMs(now)),
            );
    } else if (upNext(overview, now) case final item?) {
      next = switch (item.plan.plannedStartAt) {
        final start? => l10n.widgetNextAt(item.plan.title, time(start)),
        null => l10n.widgetNext(item.plan.title),
      };
    }

    try {
      await HomeWidget.saveWidgetData<String>(
        'title',
        l10n.widgetTitle(
          DateFormat.MMMEd(locale)
              .format(DateTime(today.year, today.month, today.day)),
        ),
      );
      // The day this is about: the widget shows a fresh day after midnight
      // even before the app runs again.
      await HomeWidget.saveWidgetData<String>('day', today.toIso());
      await HomeWidget.saveWidgetData<String>('progress', headline);
      await HomeWidget.saveWidgetData<String>('detail', detail);
      await HomeWidget.saveWidgetData<String>('next', next);
      await HomeWidget.saveWidgetData<String>(
        'button',
        l10n.widgetStartSomething,
      );
      await HomeWidget.updateWidget(qualifiedAndroidName: _androidWidget);
    } catch (_) {
      // No widget placed, or the launcher is busy: next change retries.
    }
  }

  void schedule() {
    debounce?.cancel();
    debounce = Timer(
      const Duration(milliseconds: 500),
      () => unawaited(push()),
    );
  }

  ref.listen(dayOverviewProvider(today), (_, _) => schedule());
  ref.listen(activeFocusSessionProvider, (_, _) => schedule());
  ref.listen(activityStreaksProvider, (_, _) => schedule());
  schedule();
});

/// Where a tap on the widget or the tile should go: `today`, `quickstart`.
String? homeWidgetTarget(Uri? uri) => switch (uri?.host) {
  final host? when host.isNotEmpty => host,
  _ => null,
};
