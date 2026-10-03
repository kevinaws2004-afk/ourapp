import 'preferences_snapshot.dart';
import 'theme_preference.dart';

/// App-wide preferences. A missing value means "use the default".
abstract interface class AppPreferencesRepository {
  Future<PreferencesSnapshot> load();

  Stream<ThemePreference> watchThemePreference();

  Future<void> setThemePreference(ThemePreference value);

  Stream<bool> watchOnboardingCompleted();

  Future<void> setOnboardingCompleted({required bool completed});
}
