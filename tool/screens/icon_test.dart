// Renders DayCraft's launcher icons and store artwork from the app's own
// logo painter, in the default (lavender) theme. Not part of the normal
// test run:
//   flutter test tool/screens/icon_test.dart
// Writes Android mipmaps into android/app/src/main/res and store artwork
// into store/.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:daylog/core/design/keys/activity_color_key.dart';
import 'package:daylog/core/design/themes/lavender_theme.dart';
import 'package:daylog/shared/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

final _colors = LogoColors.from(
  lavenderTokens.colors,
  teal: lavenderTokens.activity(ActivityColorKey.teal).solid,
  coral: lavenderTokens.activity(ActivityColorKey.coral).solid,
  rose: lavenderTokens.activity(ActivityColorKey.rose).solid,
);

/// Every part in one flat color (monochrome and notification icons).
LogoColors _flat(Color c) => LogoColors(
  flow: [c, c, c],
  glow: [c, c, c],
  pulse: [c, c],
  tile: [c, c],
  ring: c.withValues(alpha: 0),
  node: c.withValues(alpha: 0),
  edge: c.withValues(alpha: 0),
);

/// The adaptive icon's background (also the Android 12 splash icon's).
const _iconBackground = Color(0xFFF4F0FF);

final _key = GlobalKey();

Future<void> _font(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final p in paths) {
    loader.addFont(
      Future.value(ByteData.view(File(p).readAsBytesSync().buffer)),
    );
  }
  await loader.load();
}

/// [size] logical pixels rendered to [path].
Future<void> _render(
  WidgetTester tester,
  Widget child,
  Size size,
  String path,
) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: RepaintBoundary(
          key: _key,
          child: SizedBox.fromSize(size: size, child: child),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    final boundary =
        _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(data!.buffer.asUint8List());
  });
}

Widget _logo(double size, {bool tile = true, LogoColors? colors}) => CustomPaint(
  size: Size.square(size),
  painter: LogoPainter(colors: colors ?? _colors, tile: tile),
);

/// The mark alone, inside the adaptive icon's 66/108 safe zone.
Widget _foreground(double s, {LogoColors? colors}) =>
    Center(child: _logo(s * 0.86, tile: false, colors: colors));

void main() {
  setUpAll(() async {
    const jakarta = 'assets/fonts/plus_jakarta_sans/PlusJakartaSans-';
    await _font('PlusJakartaSans', [
      for (final w in ['Regular', 'Bold', 'ExtraBold']) '$jakarta$w.ttf',
    ]);
  });

  const res = 'android/app/src/main/res';
  const densities = {
    'mdpi': 1.0,
    'hdpi': 1.5,
    'xhdpi': 2.0,
    'xxhdpi': 3.0,
    'xxxhdpi': 4.0,
  };

  testWidgets('launcher icons', (tester) async {
    for (final MapEntry(key: d, value: scale) in densities.entries) {
      final legacy = 48 * scale;
      await _render(
        tester,
        // The tile fills the square (its artwork has a margin).
        OverflowBox(
          maxWidth: legacy * 512 / 448,
          maxHeight: legacy * 512 / 448,
          child: _logo(legacy * 512 / 448),
        ),
        Size.square(legacy),
        '$res/mipmap-$d/ic_launcher.png',
      );
      final adaptive = 108 * scale;
      await _render(
        tester,
        _foreground(adaptive),
        Size.square(adaptive),
        '$res/mipmap-$d/ic_launcher_foreground.png',
      );
      await _render(
        tester,
        _foreground(adaptive, colors: _flat(Colors.black)),
        Size.square(adaptive),
        '$res/mipmap-$d/ic_launcher_monochrome.png',
      );
    }
    addTearDown(tester.view.reset);
  });

  testWidgets('notification icons', (tester) async {
    // Status bar icon: white mark on transparent, 24dp.
    for (final MapEntry(key: d, value: scale) in densities.entries) {
      final size = 24 * scale;
      await _render(
        tester,
        Center(
          child: _logo(size * 1.4, tile: false, colors: _flat(Colors.white)),
        ),
        Size.square(size),
        '$res/drawable-$d/ic_notification.png',
      );
    }
    addTearDown(tester.view.reset);
  });

  testWidgets('store artwork', (tester) async {
    // Play Store icon: 512×512, full bleed (Play applies the mask).
    await _render(
      tester,
      Container(
        color: _iconBackground,
        alignment: Alignment.center,
        child: _logo(512 * 1.08, tile: false),
      ),
      const Size.square(512),
      'store/icon-512.png',
    );
    // Feature graphic: 1024×500.
    await _render(
      tester,
      Container(
        color: lavenderTokens.colors.surfaceCanvas,
        padding: const EdgeInsets.symmetric(horizontal: 64),
        child: Row(
          children: [
            _logo(300),
            const SizedBox(width: 36),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appBrandName,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w800,
                      fontSize: 88,
                      height: 1,
                      letterSpacing: -2.5,
                      color: lavenderTokens.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Plan your day. Do it. See it add up.',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w400,
                      fontSize: 30,
                      color: lavenderTokens.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const Size(1024, 500),
      'store/feature-graphic-1024x500.png',
    );
    addTearDown(tester.view.reset);
  });
}
