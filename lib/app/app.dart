import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/design/app_theme.dart';
import '../features/settings/domain/preferences_snapshot.dart';
import '../features/settings/presentation/preferences_providers.dart';
import '../l10n/generated/app_localizations.dart';
import '../features/focus/presentation/focus_providers.dart';
import '../features/notifications/presentation/notification_providers.dart';
import '../features/plans/domain/plan.dart';
import 'router.dart';

/// The app: one of three themes, each light or dark, chosen in Me →
/// Appearance. Changing either cross-fades the whole app.
class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  StreamSubscription<String>? _taps;

  @override
  void initState() {
    super.initState();
    final service = ref.read(notificationServiceProvider);
    _taps = service.taps.listen(_open);
    // Launched by tapping a notification.
    if (service.takeLaunchPayload() case final payload?) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _open(payload));
    }
  }

  @override
  void dispose() {
    unawaited(_taps?.cancel());
    super.dispose();
  }

  /// Opens what a tapped notification is about.
  void _open(String payload) {
    final router = ref.read(routerProvider);
    if (payload.startsWith('plan:')) {
      unawaited(router.push(AppRoutes.item(PlanId(payload.substring(5)))));
    } else if (payload == 'focus') {
      final planId = ref.read(activeFocusSessionProvider).value?.planId;
      unawaited(
        router.push(planId == null ? AppRoutes.focus : AppRoutes.item(planId)),
      );
    } else {
      router.go(AppRoutes.today);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keeps scheduled notifications in step with plans and settings.
    ref.watch(notificationSyncProvider);
    final theme = ref.watch(effectiveThemeProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.of(theme),
      darkTheme: AppTheme.of(theme, brightness: Brightness.dark),
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
          child: child!,
        );
      },
    );
  }
}
