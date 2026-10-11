// Renders Daylog's launcher icons and store artwork with the app's own
// fonts and colors. Not part of the normal test run:
//   flutter test tool/screens/icon_test.dart
// Writes Android mipmaps into android/app/src/main/res and store artwork
// into store/.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _brand = Color(0xFF6847F0);

/// The mark: a filled calendar with a check, Phosphor fill glyph.
const _glyph = IconData(0xe712, fontFamily: 'PhosphorFill');

final _key = GlobalKey();

Future<void> _font(String family, String path) async {
  final loader = FontLoader(family)
    ..addFont(
      Future.value(ByteData.view(File(path).readAsBytesSync().buffer)),
    );
  await loader.load();
}

/// One flat signature color (no gradients, like the app).
const _gradient = LinearGradient(colors: [_brand, _brand]);

/// [size] logical pixels rendered at [scale] to [path].
Future<void> _render(
  WidgetTester tester,
  Widget child,
  Size size,
  String path, {
  double scale = 1,
}) async {
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
    final image = await boundary.toImage(pixelRatio: scale);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(data!.buffer.asUint8List());
  });
}

/// Legacy square icon: gradient tile with the white mark.
Widget _legacy(double s) => Container(
  decoration: BoxDecoration(
    gradient: _gradient,
    borderRadius: BorderRadius.circular(s * 0.22),
  ),
  alignment: Alignment.center,
  child: Icon(_glyph, size: s * 0.56, color: Colors.white),
);

/// Adaptive foreground: the mark inside the 66/108 safe zone.
Widget _foreground(double s, {Color color = Colors.white}) => Center(
  child: Icon(_glyph, size: s * 0.40, color: color),
);

Widget _fullBleed(double s) => Container(
  decoration: const BoxDecoration(gradient: _gradient),
  alignment: Alignment.center,
  child: Icon(_glyph, size: s * 0.52, color: Colors.white),
);

void main() {
  setUpAll(() async {
    await _font('PhosphorFill', 'assets/fonts/phosphor/Phosphor-Fill.ttf');
    const jakarta = 'assets/fonts/plus_jakarta_sans/PlusJakartaSans-';
    final loader = FontLoader('PlusJakartaSans');
    for (final w in ['Regular', 'Bold', 'ExtraBold']) {
      loader.addFont(
        Future.value(
          ByteData.view(File('$jakarta$w.ttf').readAsBytesSync().buffer),
        ),
      );
    }
    await loader.load();
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
        _legacy(legacy),
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
        _foreground(adaptive, color: Colors.black),
        Size.square(adaptive),
        '$res/mipmap-$d/ic_launcher_monochrome.png',
      );
    }
    addTearDown(tester.view.reset);
  });

  testWidgets('store artwork', (tester) async {
    // Play Store icon: 512×512, full bleed (Play applies the mask).
    await _render(
      tester,
      _fullBleed(512),
      const Size.square(512),
      'store/icon-512.png',
    );
    // Feature graphic: 1024×500.
    await _render(
      tester,
      Container(
        decoration: const BoxDecoration(gradient: _gradient),
        padding: const EdgeInsets.symmetric(horizontal: 72),
        child: Row(
          children: [
            Container(
              width: 168,
              height: 168,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(44),
              ),
              alignment: Alignment.center,
              child: const Icon(_glyph, size: 96, color: Colors.white),
            ),
            const SizedBox(width: 48),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daylog',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w800,
                      fontSize: 84,
                      height: 1,
                      letterSpacing: -2.5,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Plan your day. Do it. See it add up.',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w400,
                      fontSize: 30,
                      color: Color(0xE6FFFFFF),
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
