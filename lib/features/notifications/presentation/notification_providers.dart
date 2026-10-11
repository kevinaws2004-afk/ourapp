import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/time/clock_provider.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../../challenges/presentation/challenge_providers.dart';
import '../../focus/domain/focus_session.dart';
import '../../focus/presentation/focus_providers.dart';
import '../../plans/domain/plan.dart';
import '../../plans/presentation/plan_date_notifier.dart';
import '../../plans/presentation/plan_providers.dart';
import '../../challenges/domain/challenge_use_cases.dart';
import '../data/reminder_store.dart';
import '../domain/notification_settings.dart';

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
  final l10n = lookupAppLocalizations(const Locale('en'));
  final reminders = ref.watch(remindersProvider).value ?? const {};
  final plans =
      ref
          .watch(plansInRangeProvider((today, today.addDays(_horizonDays))))
          .value ??
      const <Plan>[];
  String time(DateTime utc) => DateFormat.jm().format(
    utc.add(clock.offsetAt(utc)).copyWith(isUtc: false),
  );
  DateTime at(LocalDate date, int minute) => DateTime.utc(
    date.year,
    date.month,
    date.day,
    minute ~/ 60,
    minute % 60,
  ).subtract(clock.offsetAt(nowUtc));

  final notes = <ScheduledNote>[];

  // 1. Item reminders.
  for (final plan in plans) {
    final start = plan.plannedStartAt;
    if (start == null || plan.status != PlanStatus.planned) continue;
    final minutes = reminderFor(plan, reminders);
    if (minutes == null) continue;
    notes.add(
      ScheduledNote(
        key: 'plan:${plan.id.value}',
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
    );
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
  final l10n = lookupAppLocalizations(const Locale('en'));
  void timer() {
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
    unawaited(
      service.showOngoingTimer(
        title: type?.name ?? l10n.notifyTimerFallback,
        body: session.state == FocusState.paused
            ? l10n.notifyTimerPaused
            : l10n.notifyTimerRunning,
        startedAt: clock.nowUtc().subtract(
          Duration(milliseconds: session.elapsedMs(clock.nowUtc())),
        ),
      ),
    );
  }

  ref.listen(activeFocusSessionProvider, (_, _) => timer());
  ref.listen(notificationSettingsProvider, (_, _) => timer());
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
