import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/database/json_preferences.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/time/clock_provider.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/device_localizations.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../../challenges/presentation/challenge_providers.dart';
import '../../focus/domain/focus_session.dart';
import '../../focus/presentation/focus_controller.dart';
import '../../focus/presentation/focus_providers.dart';
import '../../plans/domain/plan.dart';
import '../../plans/presentation/plan_date_notifier.dart';
import '../../plans/presentation/plan_providers.dart';
import '../../challenges/domain/challenge.dart';
import '../../challenges/domain/challenge_use_cases.dart';
import '../data/reminder_store.dart';
import '../domain/notification_settings.dart';
import '../domain/plan_reminder.dart';

/// The started notification service; `bootstrap()` overrides it. Disabled
/// by default (tests, previews).
final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService.disabled(),
);

final reminderStoreProvider = Provider<ReminderStore>(
  (ref) =>
      ReminderStore(ref.watch(appDatabaseProvider), ref.watch(clockProvider)),
);

final remindersProvider = StreamProvider<Map<String, int>>(
  (ref) => ref.watch(reminderStoreProvider).watchReminders(),
);

final notificationSettingsProvider = StreamProvider<NotificationSettings>(
  (ref) => ref.watch(reminderStoreProvider).watchSettings(),
);

NotificationSettings _settings(Ref ref) =>
    ref.watch(notificationSettingsProvider).value ??
    NotificationSettings.defaults;

/// Days ahead whose reminders are scheduled (re-synced every launch and
/// on every change, so later days get theirs in time).
const _horizonDays = 7;

/// Everything that should be scheduled right now, worked out from plans,
/// reminders, goals, the running timer and the settings.
final scheduledNotesProvider = Provider.autoDispose<List<ScheduledNote>>((ref) {
  final settings = _settings(ref);
  if (!settings.enabled) return const [];
  final clock = ref.watch(clockProvider);
  final nowUtc = clock.nowUtc();
  final today = currentLocalDate(clock);
  final l10n = deviceLocalizations();
  final reminders = ref.watch(remindersProvider).value ?? const {};
  final plans =
      ref
          .watch(plansInRangeProvider((today, today.addDays(_horizonDays))))
          .value ??
      const <Plan>[];
  String time(DateTime utc) =>
      DateFormat.jm(l10n.localeName)
          .format(utc.add(clock.offsetAt(utc)).copyWith(isUtc: false));
  DateTime at(LocalDate date, int minute) => DateTime.utc(
    date.year,
    date.month,
    date.day,
    minute ~/ 60,
    minute % 60,
  ).subtract(clock.offsetAt(nowUtc));

  final notes = <ScheduledNote>[];

  // 1. Item reminders: before the start, or at a time on the item's day.
  for (final plan in plans) {
    if (plan.status != PlanStatus.planned) continue;
    final start = plan.plannedStartAt;
    for (final (i, reminder) in remindersFor(plan, reminders).indexed) {
      final key = i == 0 ? 'plan:${plan.id.value}' : 'plan:${plan.id.value}#$i';
      final ScheduledNote? note = switch (reminder) {
        ReminderBefore(:final minutes) when start != null => ScheduledNote(
          key: key,
          at: start.subtract(Duration(minutes: minutes)),
          title: minutes == 0
              ? l10n.notifyStartsNow(plan.title)
              : l10n.notifyStartsIn(plan.title, minutes),
          body: switch (plan.plannedLengthMs) {
            final ms? => l10n.notifyAtFor(
              time(start),
              Duration(milliseconds: ms).inMinutes,
            ),
            null => l10n.notifyAt(time(start)),
          },
          channel: NotificationChannel.reminders,
          payload: 'plan:${plan.id.value}',
        ),
        ReminderAt(:final minuteOfDay) => ScheduledNote(
          key: key,
          at: at(plan.planDate, minuteOfDay),
          title: plan.title,
          body: start == null
              ? l10n.notifyReminderAnytime
              : l10n.notifyAt(time(start)),
          channel: NotificationChannel.reminders,
          payload: 'plan:${plan.id.value}',
        ),
        _ => null,
      };
      if (note != null) notes.add(note);
    }
  }

  // 2. The running timer reaching its planned length.
  final session = ref.watch(activeFocusSessionProvider).value;
  if (settings.timerAlerts &&
      session != null &&
      session.state == FocusState.running) {
    final plan = plans.where((p) => p.id == session.planId).firstOrNull;
    final length = plan?.plannedLengthMs;
    if (length != null) {
      final left = length - session.elapsedMs(nowUtc);
      if (left > 0) {
        notes.add(
          ScheduledNote(
            key: 'timer:${session.id.value}',
            at: nowUtc.add(Duration(milliseconds: left)),
            title: l10n.notifyTimerDone(plan!.title),
            body: l10n.notifyTimerDoneBody(
              Duration(milliseconds: length).inMinutes,
            ),
            channel: NotificationChannel.timer,
            payload: 'plan:${plan.id.value}',
          ),
        );
      }
    }
  }

  // 2b. Pomodoro: the end of the round, or of the break.
  final focus = ref.watch(focusSettingsProvider).value;
  if (settings.timerAlerts &&
      session != null &&
      focus != null &&
      focus.pomodoro) {
    final view = pomodoroViewOf(
      session,
      focus,
      ref.watch(pomodoroStateProvider).value,
      nowUtc,
    );
    switch (view) {
      case PomodoroWorking(:final round, :final leftMs) when leftMs > 0:
        notes.add(
          ScheduledNote(
            key: 'pomodoro:${session.id.value}:$round',
            at: nowUtc.add(Duration(milliseconds: leftMs)),
            title: l10n.notifyPomodoroRoundDone(round),
            body: l10n.notifyPomodoroRoundDoneBody(
              focus.breakAfter(round).inMinutes,
            ),
            channel: NotificationChannel.timer,
            payload: 'focus',
          ),
        );
      case PomodoroOnBreak(:final round, :final leftMs) when leftMs > 0:
        notes.add(
          ScheduledNote(
            key: 'pomodoro-break:${session.id.value}:$round',
            at: nowUtc.add(Duration(milliseconds: leftMs)),
            title: l10n.notifyPomodoroBreakOver,
            body: l10n.notifyPomodoroBreakOverBody(round + 1),
            channel: NotificationChannel.timer,
            payload: 'focus',
          ),
        );
      default:
        break;
    }
  }

  // 3. Morning plan, for today (if still ahead) and tomorrow.
  if (settings.morningPlan) {
    for (final date in [today, today.addDays(1)]) {
      final day = plans
          .where((p) => p.planDate == date && p.status == PlanStatus.planned)
          .toList();
      final timed = day.where((p) => p.plannedStartAt != null).toList()
        ..sort((a, b) => a.plannedStartAt!.compareTo(b.plannedStartAt!));
      notes.add(
        ScheduledNote(
          key: 'morning:$date',
          at: at(date, settings.morningMinute),
          title: day.isEmpty
              ? l10n.notifyMorningEmpty
              : l10n.notifyMorning(day.length),
          body: timed.isEmpty
              ? l10n.notifyMorningBodyAnytime
              : l10n.notifyMorningBody(
                  timed.first.title,
                  time(timed.first.plannedStartAt!),
                ),
          channel: NotificationChannel.daily,
          payload: 'today',
        ),
      );
    }
  }

  // 4. Evening review.
  if (settings.eveningReview) {
    for (final date in [today, today.addDays(1)]) {
      notes.add(
        ScheduledNote(
          key: 'evening:$date',
          at: at(date, settings.eveningMinute),
          title: l10n.notifyEvening,
          body: l10n.notifyEveningBody,
          channel: NotificationChannel.daily,
          payload: 'today',
        ),
      );
    }
  }

  // 4b. The weekly recap, the next Sunday evening.
  if (settings.weeklyRecap) {
    final sunday = today.addDays((DateTime.sunday - today.weekday) % 7);
    for (final date in [sunday, sunday.addDays(7)]) {
      notes.add(
        ScheduledNote(
          key: 'recap:$date',
          at: at(date, NotificationSettings.weeklyRecapMinute),
          title: l10n.notifyRecap,
          body: l10n.notifyRecapBody,
          channel: NotificationChannel.daily,
          payload: 'recap',
        ),
      );
    }
  }

  // 5. Goal streaks not done yet today, at 20:00.
  if (settings.goalStreaks) {
    final types = {
      for (final t
          in ref.watch(activeActivityTypesProvider).value ??
              const <ActivityType>[])
        t.id: t,
    };
    for (final view
        in ref.watch(challengesProvider).value ?? const <ChallengeView>[]) {
      final p = view.progress;
      if (view.challenge.kind != GoalKind.daily) continue;
      if (p.isCompleted || p.doneToday || p.currentStreak == 0) continue;
      final name =
          types[view.challenge.activityTypeId]?.name ?? view.challenge.title;
      notes.add(
        ScheduledNote(
          key: 'goal:${view.challenge.id.value}:$today',
          at: at(today, 20 * 60),
          title: l10n.notifyStreak(p.currentStreak, name),
          body: l10n.notifyStreakBody,
          channel: NotificationChannel.goals,
          payload: 'today',
        ),
      );
    }
  }
  return notes;
});

const _askedForTimerKey = 'asked_notifications_for_timer';

/// Keeps the system's notifications in step with [scheduledNotesProvider]
/// and the running timer. Watched once by the app.
final notificationSyncProvider = Provider<void>((ref) {
  final service = ref.watch(notificationServiceProvider);
  if (!service.isEnabled) return;
  final clock = ref.read(clockProvider);
  var started = false;
  Future<void> sync(List<ScheduledNote> notes) async {
    if (!started) {
      started = true;
      await service.resetScheduled();
    }
    await service.apply(notes, nowUtc: clock.nowUtc());
  }

  ref.listen(
    scheduledNotesProvider,
    (_, notes) => unawaited(sync(notes)),
    fireImmediately: true,
  );

  // The ongoing "timer running" notification.
  final l10n = deviceLocalizations();
  late void Function() timer;

  // The first timer asks for permission to notify (once), so its live
  // notification and the round and break alerts can show.
  Future<void> askOnceForTimer() async {
    final prefs = ref.read(jsonPreferencesProvider);
    if (await prefs.read(_askedForTimerKey) == true) return;
    await prefs.write(_askedForTimerKey, true);
    if (!await service.isPermitted() && await service.requestPermission()) {
      // Allowed now: show the timer that's already running.
      timer();
    }
  }

  timer = () {
    final settings =
        ref.read(notificationSettingsProvider).value ??
        NotificationSettings.defaults;
    final session = ref.read(activeFocusSessionProvider).value;
    final running =
        settings.enabled &&
        settings.timerAlerts &&
        session != null &&
        session.state != FocusState.finished &&
        session.state != FocusState.discarded;
    if (running) unawaited(askOnceForTimer());
    if (!running) {
      unawaited(
        service.showOngoingTimer(
          title: null,
          body: '',
          startedAt: clock.nowUtc(),
        ),
      );
      return;
    }
    final type = ref
        .read(activeActivityTypesProvider)
        .value
        ?.where((t) => t.id == session.activityTypeId)
        .firstOrNull;
    final paused = session.state == FocusState.paused;
    final focus = ref.read(focusSettingsProvider).value;
    final onBreak =
        focus != null &&
        pomodoroViewOf(
          session,
          focus,
          ref.read(pomodoroStateProvider).value,
          clock.nowUtc(),
        ) is PomodoroOnBreak;
    unawaited(
      service.showOngoingTimer(
        title: type?.name ?? l10n.notifyTimerFallback,
        body: onBreak
            ? l10n.notifyTimerOnBreak
            : paused
            ? l10n.notifyTimerPaused
            : l10n.notifyTimerRunning,
        startedAt: clock.nowUtc().subtract(
          Duration(milliseconds: session.elapsedMs(clock.nowUtc())),
        ),
        paused: paused,
        pauseLabel: paused ? l10n.focusResume : l10n.focusPause,
        finishLabel: l10n.focusFinish,
      ),
    );
  };

  ref.listen(activeFocusSessionProvider, (_, _) => timer());
  ref.listen(notificationSettingsProvider, (_, _) => timer());
  ref.listen(pomodoroStateProvider, (_, _) => timer());
  timer();
});

/// Changes notification settings; turning something on asks for the
/// system permission.
Future<void> updateNotificationSettings(
  WidgetRef ref,
  NotificationSettings settings, {
  bool askPermission = false,
}) async {
  if (askPermission) {
    await ref.read(notificationServiceProvider).requestPermission();
  }
  await ref.read(reminderStoreProvider).setSettings(settings);
}
