// The logo big and at home-screen size, in the default theme, into
// build/logo_preview.png. Not part of the normal test run:
//   flutter test tool/screens/logo_preview_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:daylog/core/design/themes/lavender_theme.dart';
import 'package:daylog/shared/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

final _key = GlobalKey();

void main() {
  testWidgets('logo preview', (tester) async {
    tester.view.physicalSize = const Size(760, 420);
    tester.view.devicePixelRatio = 1;
    final colors = LogoColors.from(lavenderTokens.colors);
    Widget logo(double size) => CustomPaint(
      size: Size.square(size),
      painter: LogoPainter(colors: colors),
    );
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(
          key: _key,
          child: ColoredBox(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [logo(380), logo(96), logo(48)],
            ),
          ),
        ),
      ),
    );
    await tester.runAsync(() async {
      final boundary =
          _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      File('build/logo_preview.png').writeAsBytesSync(data!.buffer.asUint8List());
    });
  });
}
