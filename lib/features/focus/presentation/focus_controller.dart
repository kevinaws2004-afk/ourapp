import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/json_preferences.dart';
import '../../../core/platform/app_blocker.dart';
import '../../../core/platform/do_not_disturb.dart';
import '../../../core/time/clock_provider.dart';
import '../domain/focus_session.dart';
import '../domain/pomodoro.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../../notifications/presentation/reminder_prompt.dart';
import 'focus_providers.dart';
import '../../../core/logging/logger_provider.dart';

const focusSettingsKey = 'focus_settings';
const pomodoroStateKey = 'pomodoro_state';

/// Me → Focus: Pomodoro and Do Not Disturb.
final focusSettingsProvider = StreamProvider<FocusSettings>(
  (ref) => ref
      .watch(jsonPreferencesProvider)
      .watch(focusSettingsKey)
      .map(FocusSettings.fromJson),
);

/// The active session's Pomodoro rounds and break, if Pomodoro is on.
final pomodoroStateProvider = StreamProvider<PomodoroState?>(
  (ref) => ref
      .watch(jsonPreferencesProvider)
      .watch(pomodoroStateKey)
      .map(PomodoroState.fromJson),
);

final appBlockerProvider = Provider<AppBlocker>((ref) => const AppBlocker());

final doNotDisturbProvider = Provider<DoNotDisturb>(
  (ref) => const DoNotDisturb(),
);

Future<void> saveFocusSettings(WidgetRef ref, FocusSettings settings) async {
  await ref
      .read(jsonPreferencesProvider)
      .write(focusSettingsKey, settings.toJson());
  // Break alerts need to come on time.
  if (settings.pomodoro) await askOnceForOnTimeReminders(ref);
  await ref.read(appBlockerProvider).setBlocked(settings.blockedApps);
}

/// What a timer screen shows under the time when Pomodoro is on.
sealed class PomodoroView {
  const PomodoroView();
}

/// Working: round [round], [leftMs] until the break.
final class PomodoroWorking extends PomodoroView {
  const PomodoroWorking(this.round, this.leftMs);

  final int round;
  final int leftMs;
}

/// On a break after round [round]: [leftMs] left (≤ 0 once it's over).
final class PomodoroOnBreak extends PomodoroView {
  const PomodoroOnBreak(this.round, this.leftMs);

  final int round;
  final int leftMs;

  bool get isOver => leftMs <= 0;
}

/// [session]'s Pomodoro state at [now], or null when Pomodoro is off or the
/// session is paused by hand.
PomodoroView? pomodoroViewOf(
  FocusSession session,
  FocusSettings settings,
  PomodoroState? state,
  DateTime now, {
  bool usesRounds = true,
}) {
  if (!settings.pomodoro || !usesRounds) return null;
  final mine = state?.sessionId == session.id.value ? state : null;
  if (session.state == FocusState.paused) {
    final ends = mine?.breakEndsAt;
    if (mine == null || ends == null) return null;
    return PomodoroOnBreak(
      mine.roundsDone,
      ends.difference(now).inMilliseconds,
    );
  }
  final elapsed = session.elapsedMs(now);
  final done = mine?.roundsDone ?? 0;
  final left = (mine?.roundStartMs ?? 0) + settings.workMs - elapsed;
  return PomodoroWorking(done + 1, left < 0 ? 0 : left);
}

/// The longest a timer runs without a break before it pauses itself.
const maxRunning = Duration(hours: 12);

/// Keeps Pomodoro rounds and Do Not Disturb in step with the active
/// session. Watched once by the app.
///
/// - When a round's time is up, the session pauses at that moment (even if
///   the app was closed then) and a break starts; resuming ends it.
/// - Do Not Disturb is on while a session runs, if asked for and allowed.
final focusControllerProvider = Provider<void>((ref) {
  Timer? timer;
  bool? dndOn;
  bool? blocking;
  var queue = Future<void>.value();
  var disposed = false;
  ref.onDispose(() {
    disposed = true;
    timer?.cancel();
  });

  late void Function() schedule;

  Future<void> evaluate() async {
    timer?.cancel();
    if (disposed) return;
    final settings = FocusSettings.fromJson(
      await ref.read(jsonPreferencesProvider).read(focusSettingsKey),
    );
    // Read straight from the database: the streams can lag a moment behind
    // a write made here, and acting on a stale "running" would undo a
    // break that just started.
    final session = await ref.read(focusSessionRepositoryProvider).getActive();
    final prefs = ref.read(jsonPreferencesProvider);
    final state = PomodoroState.fromJson(await prefs.read(pomodoroStateKey));
    final now = ref.read(clockProvider).nowUtc();

    final wantDnd =
        settings.doNotDisturb &&
        session != null &&
        session.state == FocusState.running;
    // The first "off" also puts back a Do Not Disturb left on by a session
    // the app was closed during (the native side only restores what it
    // changed).
    // Chosen apps are blocked only while focusing (not on a break).
    final wantBlock =
        settings.blockApps &&
        settings.blockedApps.isNotEmpty &&
        session != null &&
        session.state == FocusState.running;
    if (wantBlock != blocking) {
      blocking = wantBlock;
      unawaited(ref.read(appBlockerProvider).setActive(active: wantBlock));
    }
    if (wantDnd != dndOn) {
      dndOn = wantDnd;
      unawaited(ref.read(doNotDisturbProvider).set(on: wantDnd));
    }

    if (session == null) {
      if (state != null) await prefs.write(pomodoroStateKey, null);
      return;
    }
    // A timer left running (forgotten overnight, for days) stops counting
    // at [maxRunning]: paused then, so it can't add hours nobody worked.
    if (session.state == FocusState.running) {
      final over = session.elapsedMs(now) - maxRunning.inMilliseconds;
      if (over > 0) {
        await ref.read(pauseFocusSessionProvider)(
          session.id,
          at: now.subtract(Duration(milliseconds: over)),
        );
        return;
      }
      timer = Timer(Duration(milliseconds: 1 - over + 250), schedule);
    }
    if (!settings.pomodoro) return;
    // Rounds are for focus work: not a workout, unless turned on for it.
    final type = await ref
        .read(activityTypeRepositoryProvider)
        .getType(session.activityTypeId);
    if (!settings.roundsFor(session.activityTypeId.value, type?.iconId)) {
      return;
    }
    final elapsed = session.elapsedMs(now);
    if (state == null || state.sessionId != session.id.value) {
      // First seen (or Pomodoro just turned on): a round starts from the
      // time already worked, so nothing is cut short.
      await prefs.write(
        pomodoroStateKey,
        PomodoroState(
          sessionId: session.id.value,
          roundsDone: 0,
          roundStartMs: elapsed,
        ).toJson(),
      );
      return;
    }
    if (session.state != FocusState.running) return;
    if (state.breakEndsAt != null) {
      // Resumed: the break is over and the next round starts now.
      await prefs.write(
        pomodoroStateKey,
        PomodoroState(
          sessionId: state.sessionId,
          roundsDone: state.roundsDone,
          roundStartMs: elapsed,
        ).toJson(),
      );
      return;
    }
    final left = state.roundStartMs + settings.workMs - elapsed;
    if (left > 0) {
      // A little after the end, so the round is surely over when it fires.
      timer = Timer(Duration(milliseconds: left + 250), schedule);
      return;
    }
    // The round is up: pause when it ended, and start the break.
    final endedAt = now.add(Duration(milliseconds: left));
    final round = state.roundsDone + 1;
    await prefs.write(
      pomodoroStateKey,
      PomodoroState(
        sessionId: session.id.value,
        roundsDone: round,
        roundStartMs: state.roundStartMs,
        breakEndsAt: endedAt.add(settings.breakAfter(round)),
      ).toJson(),
    );
    await ref.read(pauseFocusSessionProvider)(session.id, at: endedAt);
    unawaited(HapticFeedback.heavyImpact());
  }

  schedule = () {
    if (disposed) return;
    queue = queue.then((_) => evaluate()).catchError((
      Object error,
      StackTrace stack,
    ) {
      // Logged (and kept for problem reports); the next change tries again.
      ref
          .read(loggerProvider)
          .error('Pomodoro step failed', error: error, stackTrace: stack);
    });
  };

  // Back in the app: a round may have ended while it was away (timers
  // don't run while Android has the app paused).
  final lifecycle = AppLifecycleListener(onResume: () => schedule());
  ref.onDispose(lifecycle.dispose);

  ref.listen(activeFocusSessionProvider, (_, _) => schedule());
  ref.listen(pomodoroStateProvider, (_, _) => schedule());
  ref.listen(
    focusSettingsProvider,
    (_, _) => schedule(),
    fireImmediately: true,
  );
});
