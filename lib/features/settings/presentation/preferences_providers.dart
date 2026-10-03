import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/logging/logger_provider.dart';
import '../../../core/time/clock_provider.dart';
import '../data/db_app_preferences_repository.dart';
import '../domain/app_preferences_repository.dart';
import '../domain/preferences_snapshot.dart';
import '../domain/theme_preference.dart';

final appPreferencesRepositoryProvider = Provider<AppPreferencesRepository>(
  (ref) => DbAppPreferencesRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(clockProvider),
    ref.watch(loggerProvider),
  ),
);

/// Preferences read during bootstrap, so the first frame needs no loading
/// state. Overridden by `bootstrap()`; tests may override it too.
final initialPreferencesProvider = Provider<PreferencesSnapshot>(
  (ref) => PreferencesSnapshot.defaults,
);

final themePreferenceProvider = StreamProvider<ThemePreference>(
  (ref) => ref.watch(appPreferencesRepositoryProvider).watchThemePreference(),
);

final onboardingCompletedProvider = StreamProvider<bool>(
  (ref) =>
      ref.watch(appPreferencesRepositoryProvider).watchOnboardingCompleted(),
);

/// Current theme preference, falling back to the startup snapshot while the
/// stream hasn't emitted yet.
final effectiveThemePreferenceProvider = Provider<ThemePreference>(
  (ref) =>
      ref.watch(themePreferenceProvider).value ??
      ref.watch(initialPreferencesProvider).themePreference,
);

final preferencesNotifierProvider = NotifierProvider<PreferencesNotifier, void>(
  PreferencesNotifier.new,
);

/// Intents that change preferences. Widgets call these instead of the
/// repository.
class PreferencesNotifier extends Notifier<void> {
  @override
  void build() {}

  AppPreferencesRepository get _repository =>
      ref.read(appPreferencesRepositoryProvider);

  Future<void> setThemePreference(ThemePreference value) =>
      _repository.setThemePreference(value);

  Future<void> completeOnboarding() =>
      _repository.setOnboardingCompleted(completed: true);

  /// Debug tooling only (token showcase): shows onboarding again.
  Future<void> resetOnboarding() =>
      _repository.setOnboardingCompleted(completed: false);
}
