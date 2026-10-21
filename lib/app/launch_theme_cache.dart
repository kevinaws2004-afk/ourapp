import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../core/design/themes/app_theme_id.dart';
import '../features/settings/domain/preferences_snapshot.dart';

/// The look last used, kept in a tiny file so the loading screen (shown
/// before the database opens) is already in the user's theme.
class LaunchTheme {
  const LaunchTheme({
    this.theme = AppThemeId.fallback,
    this.appearance = AppearanceMode.fallback,
    this.trueBlack = false,
  });

  final AppThemeId theme;
  final AppearanceMode appearance;
  final bool trueBlack;

  static Future<File> _file() async => File(
    '${(await getApplicationSupportDirectory()).path}/launch_theme.json',
  );

  /// The saved look, or the default one; never throws.
  static Future<LaunchTheme> load() async {
    try {
      final file = await _file();
      if (!file.existsSync()) return const LaunchTheme();
      final json = jsonDecode(file.readAsStringSync());
      if (json is! Map) return const LaunchTheme();
      return LaunchTheme(
        theme: AppThemeId.fromName(json['theme'] as String?),
        appearance: AppearanceMode.fromName(json['appearance']),
        trueBlack: json['trueBlack'] == true,
      );
    } catch (_) {
      return const LaunchTheme();
    }
  }

  /// Saves this look for the next launch; failures are ignored.
  Future<void> save() async {
    try {
      final file = await _file();
      await file.parent.create(recursive: true);
      await file.writeAsString(
        jsonEncode({
          'theme': theme.name,
          'appearance': appearance.name,
          'trueBlack': trueBlack,
        }),
      );
    } catch (_) {}
  }

  @override
  bool operator ==(Object other) =>
      other is LaunchTheme &&
      other.theme == theme &&
      other.appearance == appearance &&
      other.trueBlack == trueBlack;

  @override
  int get hashCode => Object.hash(theme, appearance, trueBlack);
}
