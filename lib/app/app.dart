import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/platform/app_icon.dart';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../core/design/app_theme.dart';
import '../core/time/clock_provider.dart';
import '../core/time/local_date.dart';
import '../features/settings/domain/preferences_snapshot.dart';
import '../features/settings/presentation/app_lock.dart';
import '../features/settings/presentation/backup_providers.dart';
import '../features/settings/presentation/review_prompt.dart';
import '../features/settings/presentation/preferences_providers.dart';
import '../l10n/generated/app_localizations.dart';
import '../features/focus/presentation/focus_controller.dart';
import '../features/focus/presentation/focus_providers.dart';
import '../features/notifications/presentation/notification_providers.dart';
import '../core/notifications/notification_service.dart';
import '../features/focus/domain/focus_session.dart';
import '../features/plans/domain/plan.dart';
import '../features/plans/presentation/plan_providers.dart';
import 'home_widget_sync.dart';
import 'launch_theme_cache.dart';
import 'router.dart';

/// The app: one of three themes, each light or dark, chosen in Me →
/// Appearance. Changing either cross-fades the whole app.
class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  LaunchTheme? _savedLook;

  StreamSubscription<String>? _taps;
  StreamSubscription<Uri?>? _widgetTaps;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onHide: () {
        _leftAt = ref.read(clockProvider).nowUtc();
        // The home-screen icon takes the theme's colors once you leave, not
        // on every tap while trying themes (the launcher redraws on a change).
        unawaited(
          const AppIconSwitcher().set(ref.read(effectiveThemeProvider)),
        );
      },
      onResume: () {
        _backToTodayAfterAWhile();
        _runDailyTasks();
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _runDailyTasks());
    final service = ref.read(notificationServiceProvider);
    _taps = service.taps.listen(_open);
    // Launched by tapping a notification.
    if (service.takeLaunchPayload() case final payload?) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _open(payload));
    }
    // The home-screen widget and the Quick Settings tile (Android; not in
    // tests, which have no platform side).
    if (defaultTargetPlatform == TargetPlatform.android &&
        !kIsWeb &&
        !Platform.environment.containsKey('FLUTTER_TEST')) {
      _widgetTaps = HomeWidget.widgetClicked.listen(_openFromWidget);
      unawaited(
        HomeWidget.initiallyLaunchedFromHomeWidget().then(
          (uri) => WidgetsBinding.instance.addPostFrameCallback(
            (_) => _openFromWidget(uri),
          ),
          onError: (_) {},
        ),
      );
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    unawaited(_widgetTaps?.cancel());
    unawaited(_taps?.cancel());
    super.dispose();
  }

  DateTime? _leftAt;

  /// Back after a while (a new day, or hours away): start on Today, not on
  /// whatever screen was left open last night. A notification or widget tap
  /// opens its own place afterwards.
  void _backToTodayAfterAWhile() {
    final left = _leftAt;
    _leftAt = null;
    if (left == null) return;
    final clock = ref.read(clockProvider);
    final now = clock.nowUtc();
    final newDay =
        LocalDate.ofInstant(left, clock.offsetAt(left)) !=
        LocalDate.ofInstant(now, clock.offsetAt(now));
    if (newDay || now.difference(left) > const Duration(hours: 4)) {
      ref.read(routerProvider).go(AppRoutes.today);
    }
  }

  /// Work that runs when the app opens or comes back: the daily backup,
  /// and the widget catching up (it may be a new day).
  void _runDailyTasks() {
    unawaited(
      ref.read(autoBackupProvider).runIfDue(ref.read(clockProvider).nowUtc()),
    );
    ref.invalidate(homeWidgetSyncProvider);
    unawaited(noteFirstSeen(ref));
  }

  /// Opens what the widget or the tile was tapped for.
  void _openFromWidget(Uri? uri) {
    switch (homeWidgetTarget(uri)) {
      case 'quickstart':
        ref.read(routerProvider).go(AppRoutes.today);
        // After the move to Today is drawn: a sheet opened before it would
        // go with the page it was opened over (a cold start's first page).
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => ref.read(quickStartRequestProvider.notifier).request(),
        );
      case 'today':
        ref.read(routerProvider).go(AppRoutes.today);
    }
  }

  /// Opens what a tapped notification is about.
  void _open(String payload) {
    final router = ref.read(routerProvider);
    if (payload.startsWith('action:remind_')) {
      unawaited(_reminderAction(payload.substring(7)));
      return;
    }
    if (payload.startsWith('action:')) {
      unawaited(_timerAction(payload.substring(7)));
      return;
    }
    if (payload.startsWith('plan:')) {
      // Over Today, so finishing it lands there, not on whatever tab was
      // left open.
      router.go(AppRoutes.today);
      unawaited(router.push(AppRoutes.item(PlanId(payload.substring(5)))));
    } else if (payload == 'recap') {
      unawaited(router.push(AppRoutes.recap()));
    } else if (payload == 'focus') {
      final planId = ref.read(activeFocusSessionProvider).value?.planId;
      unawaited(
        router.push(planId == null ? AppRoutes.focus : AppRoutes.item(planId)),
      );
    } else {
      router.go(AppRoutes.today);
    }
  }

  /// A reminder's buttons: Start (its timer, opening it), Snooze 10 min,
  /// or Skip. [action] is `remind_x|plan:ID`.
  Future<void> _reminderAction(String action) async {
    final [name, payload] = action.split('|');
    if (!payload.startsWith('plan:')) return;
    final id = PlanId(payload.substring(5));
    final plan = await ref.read(planRepositoryProvider).getPlan(id);
    if (plan == null) return;
    final router = ref.read(routerProvider);
    try {
      switch (name) {
        case NotificationService.actionRemindStart:
          if (plan.activityTypeId case final type?) {
            await ref.read(startFocusSessionProvider)(type, planId: id);
          }
          router.go(AppRoutes.today);
          unawaited(router.push(AppRoutes.item(id)));
        case NotificationService.actionRemindSnooze:
          final l10n = lookupAppLocalizations(const Locale('en'));
          await ref
              .read(notificationServiceProvider)
              .remindAgain(
                title: l10n.notifyStartsNow(plan.title),
                body: l10n.reminderSnoozed,
                payload: payload,
                at: ref
                    .read(clockProvider)
                    .nowUtc()
                    .add(const Duration(minutes: 10)),
              );
          // Out of the way again: back to the home screen.
          await SystemNavigator.pop();
        case NotificationService.actionRemindSkip:
          await ref.read(setPlanStatusProvider)(id, PlanStatus.skipped);
          router.go(AppRoutes.today);
      }
    } catch (_) {
      // Gone or already started: nothing to do.
    }
  }

  /// The running timer's notification buttons: Pause/Resume, or Finish
  /// (which records the time and opens what it was for).
  Future<void> _timerAction(String action) async {
    final session = ref.read(activeFocusSessionProvider).value;
    if (session == null) return;
    try {
      switch (action) {
        case NotificationService.actionPauseResume:
          await (session.state == FocusState.paused
              ? ref.read(resumeFocusSessionProvider)(session.id)
              : ref.read(pauseFocusSessionProvider)(session.id));
        case NotificationService.actionFinish:
          await ref.read(finishFocusSessionProvider)(session.id);
          if (session.planId case final planId?) {
            unawaited(ref.read(routerProvider).push(AppRoutes.item(planId)));
          }
      }
    } catch (_) {
      // Already finished elsewhere: nothing to do.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keeps scheduled notifications in step with plans and settings.
    ref.watch(notificationSyncProvider);
    // Pomodoro rounds and Do Not Disturb follow the running timer.
    ref.watch(focusControllerProvider);
    // The Today widget follows today.
    ref.watch(homeWidgetSyncProvider);
    final theme = ref.watch(effectiveThemeProvider);
    // The next launch's loading screen opens in this look.
    final look = LaunchTheme(
      theme: theme,
      appearance: ref.watch(effectiveAppearanceProvider),
      trueBlack: ref.watch(effectiveTrueBlackProvider),
    );
    if (look != _savedLook) {
      _savedLook = look;
      unawaited(look.save());
    }
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.of(theme),
      darkTheme: AppTheme.of(
        theme,
        brightness: Brightness.dark,
        trueBlack: ref.watch(effectiveTrueBlackProvider),
      ),
      themeMode: switch (ref.watch(effectiveAppearanceProvider)) {
        AppearanceMode.system => ThemeMode.system,
        AppearanceMode.light => ThemeMode.light,
        AppearanceMode.dark => ThemeMode.dark,
      },
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: ref.watch(routerProvider),
      // Status and navigation bars follow light/dark, see-through.
      builder: (context, child) {
        final dark = Theme.of(context).brightness == Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
              .copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: Colors.transparent,
                systemNavigationBarContrastEnforced: false,
              ),
          child: AppLockGate(child: child!),
        );
      },
    );
  }
}
