// Renders the app's main screens offscreen with demo data and writes PNGs to
// build/screens/. Not part of the normal test run:
//   flutter test tool/screens/capture_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:daylog/app/app.dart';
import 'package:daylog/app/dev/demo_data.dart';
import 'package:daylog/core/database/app_database.dart';
import 'package:daylog/core/database/database_provider.dart';
import 'package:daylog/core/design/themes/app_theme_id.dart';
import 'package:daylog/core/logging/app_logger.dart';
import 'package:daylog/core/time/clock_provider.dart';
import 'package:daylog/features/focus/presentation/focus_providers.dart';
import 'package:daylog/features/settings/data/db_app_preferences_repository.dart';
import 'package:daylog/features/settings/domain/preferences_snapshot.dart';
import 'package:daylog/features/settings/presentation/preferences_providers.dart';
import 'package:daylog/l10n/generated/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/support/fake_clock.dart';

final _boundary = GlobalKey();
const _out = 'build/screens';
const _size = Size(412, 915);

Future<void> _loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final f in files) {
    final bytes = File(f).readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

Future<void> _loadFonts() async {
  const jakarta = 'assets/fonts/plus_jakarta_sans/PlusJakartaSans-';
  await _loadFont('PlusJakartaSans', [
    for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold'])
      '$jakarta$w.ttf',
  ]);
  await _loadFont('Phosphor', ['assets/fonts/phosphor/Phosphor.ttf']);
  await _loadFont('PhosphorFill', ['assets/fonts/phosphor/Phosphor-Fill.ttf']);
  // Fallback for anything asking for Roboto.
  await _loadFont('Roboto', ['${jakarta}Regular.ttf']);
}

Future<void> _shot(WidgetTester tester, String name) async {
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    final boundary =
        _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$_out/$name.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(data!.buffer.asUint8List());
  });
}

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  required bool onboarded,
  bool demo = true,
  AppThemeId theme = AppThemeId.lavender,
  AppearanceMode appearance = AppearanceMode.light,
  bool trueBlack = false,
}) async {
  tester.view.physicalSize = _size;
  tester.view.devicePixelRatio = 1;
  final clock = FakeClock(DateTime.utc(2026, 10, 3, 11, 30));
  final db = AppDatabase(NativeDatabase.memory());
  final prefs = PreferencesSnapshot(
    theme: theme,
    onboardingCompleted: onboarded,
    appearance: appearance,
    name: onboarded ? 'Kevin' : '',
    trueBlack: trueBlack,
  );
  await tester.runAsync(() async {
    final repo = DbAppPreferencesRepository(db, clock, const AppLogger());
    await repo.setTheme(prefs.theme);
    await repo.setOnboardingCompleted(completed: prefs.onboardingCompleted);
    await repo.setAppearance(prefs.appearance);
    await repo.setName(prefs.name);
    await repo.setTrueBlack(value: trueBlack);
  });
  await tester.pumpWidget(
    RepaintBoundary(
      key: _boundary,
      child: ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(clock),
          initialPreferencesProvider.overrideWithValue(prefs),
          focusTickProvider.overrideWith((ref) => Stream.value(clock.nowUtc())),
        ],
        child: const App(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  final container = ProviderScope.containerOf(
    tester.element(find.byType(App)),
  );
  if (demo) {
    await tester.runAsync(() async {
      await loadDemoData(
        container,
        lookupAppLocalizations(const Locale('en')),
      );
    });
    await tester.pumpAndSettle();
  }
  return container;
}

Future<void> _tapTab(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

Future<void> _scrollShot(WidgetTester tester, String name) async {
  await _shot(tester, name);
  final scrollables = find.byType(Scrollable);
  if (scrollables.evaluate().isEmpty) return;
  await tester.drag(scrollables.first, const Offset(0, -700));
  await _shot(tester, '${name}_2');
  await tester.drag(scrollables.first, const Offset(0, -700));
  await _shot(tester, '${name}_3');
}

void main() {
  setUpAll(_loadFonts);
  _extra();

  testWidgets('onboarding', (tester) async {
    await _pump(tester, onboarded: false, demo: false);
    await _shot(tester, '00_onboarding');
    await tester.tap(find.text('Get started'));
    await _shot(tester, '00_onboarding_2');
    await tester.tap(find.text('Skip for now'));
    await _shot(tester, '00_onboarding_3');
  });

  testWidgets('empty today', (tester) async {
    await _pump(tester, onboarded: true, demo: false);
    await _shot(tester, '01_today_empty');
  });

  testWidgets('tabs with demo data', (tester) async {
    await _pump(tester, onboarded: true);
    await _scrollShot(tester, '02_today');
    await _tapTab(tester, 'Plan');
    await _scrollShot(tester, '03_plan');
    await _tapTab(tester, 'Progress');
    await _scrollShot(tester, '05_insights');
    await _tapTab(tester, 'Me');
    await _scrollShot(tester, '06_me');
  });
}

void _extra() {
  testWidgets('true black', (tester) async {
    await _pump(
      tester,
      onboarded: true,
      appearance: AppearanceMode.dark,
      trueBlack: true,
    );
    await _shot(tester, '23_true_black_today');
    await _tapTab(tester, 'Progress');
    await _shot(tester, '23_true_black_progress');
  });
  testWidgets('color picker', (tester) async {
    await _pump(tester, onboarded: true);
    await _tapTab(tester, 'Me');
    await tester.tap(find.text('4 activities'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('New activity'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
    await _shot(tester, '24_color_picker');
  });

  testWidgets('appearance', (tester) async {
    await _pump(tester, onboarded: true);
    await _tapTab(tester, 'Me');
    await tester.tap(find.text('Appearance'));
    await _shot(tester, '21_appearance');
  });
  for (final theme in [AppThemeId.ocean, AppThemeId.lilac, AppThemeId.honey]) {
    testWidgets('theme ${theme.name}', (tester) async {
      await _pump(tester, onboarded: true, theme: theme);
      await _shot(tester, '22_theme_${theme.name}');
    });
  }

  testWidgets('notifications', (tester) async {
    await _pump(tester, onboarded: true);
    // Long-press a timed item → Reminder → the reminder sheet.
    await tester.longPress(find.text('Reading').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reminder'));
    await _shot(tester, '19_reminder_sheet');
    await tester.tap(find.text('Remind me'));
    await tester.pumpAndSettle();
    await _shot(tester, '19_today_with_bell');
    await _tapTab(tester, 'Me');
    await tester.tap(find.text('Notifications'));
    await _shot(tester, '20_notifications_settings');
  });

  testWidgets('palettes', (tester) async {
    await _pump(tester, onboarded: true, theme: AppThemeId.rose);
    await _shot(tester, '09_pastel_today');
  });
  testWidgets('palettes papaya', (tester) async {
    await _pump(tester, onboarded: true, theme: AppThemeId.papaya);
    await _shot(tester, '09_papaya_today');
  });

  testWidgets('deep screens', (tester) async {
    await _pump(tester, onboarded: true);
    Future<void> back() async {
      await tester.pageBack();
      await tester.pumpAndSettle();
    }

    // The item screen of a planned activity.
    await tester.tap(find.text('Reading').last);
    await _scrollShot(tester, '10_item');
    await back();
    // Start it: the running item.
    await tester.tap(find.text('Start').first);
    await _scrollShot(tester, '11_item_running');
    await back();
    // Goals.
    await _tapTab(tester, 'Progress');
    await tester.tap(find.text('See all'));
    await _shot(tester, '12_goals');
    // Me deep screens.
    await _tapTab(tester, 'Me');
    await tester.tap(find.text('4 activities'));
    await _shot(tester, '13_activities');
    await tester.tap(find.text('Gym').first);
    await _scrollShot(tester, '14_activity');
    await back();
    await tester.tap(find.byTooltip('New activity'));
    await _scrollShot(tester, '18_builder');
    await back();
    await back();
    await tester.tap(find.text('Body measurements'));
    await _shot(tester, '15_measurements');
    await back();
    await tester.tap(find.text('Appearance'));
    await _scrollShot(tester, '16_appearance');
  });

  testWidgets('builder and add sheet', (tester) async {
    await _pump(tester, onboarded: true);
    await tester.tap(find.text('Add').first);
    await _shot(tester, '17_add_sheet');
  });

  testWidgets('quick start sheet', (tester) async {
    await _pump(tester, onboarded: true);
    await tester.tap(find.byTooltip('Quick start'));
    await _shot(tester, '07_quick_start');
  });

  testWidgets('dark mode', (tester) async {
    await _pump(tester, onboarded: true, appearance: AppearanceMode.dark);
    await _shot(tester, '08_dark_today');
    await _tapTab(tester, 'Progress');
    await _shot(tester, '08_dark_progress');
    await _tapTab(tester, 'Me');
    await _shot(tester, '08_dark_me');
  });
}
