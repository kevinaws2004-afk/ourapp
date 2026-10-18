// Renders the app's logo in every theme, light and dark, on each theme's
// own canvas, into build/logo_themes.png: a quick check that the mark
// follows the theme. Not part of the normal test run:
//   flutter test tool/screens/logo_themes_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:daylog/core/design/app_tokens.dart';
import 'package:daylog/core/design/themes/app_theme_id.dart';
import 'package:daylog/shared/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('logo in every theme', (tester) async {
    const cell = 120.0;
    const themes = AppThemeId.values;
    final size = Size(cell * 2, cell * themes.length);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final key = GlobalKey();

    Widget logo(AppThemeId id, Brightness brightness) {
      final c = AppTokens.of(id, brightness: brightness).colors;
      return Container(
        width: cell,
        height: cell,
        color: c.surfaceCanvas,
        alignment: Alignment.center,
        child: CustomPaint(
          size: const Size.square(88),
          painter: LogoPainter(
            colors: LogoColors.from(c, dark: brightness == Brightness.dark),
            tile: true,
          ),
        ),
      );
    }

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(
          key: key,
          child: Column(
            children: [
              for (final id in themes)
                Row(
                  children: [
                    logo(id, Brightness.light),
                    logo(id, Brightness.dark),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      File('build/logo_themes.png')
        ..createSync(recursive: true)
        ..writeAsBytesSync(data!.buffer.asUint8List());
    });
  });
}
