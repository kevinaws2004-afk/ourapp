import 'package:flutter/widgets.dart';

/// Corner radii (ADR-045), shared by every theme: soft cards, pill controls.
abstract final class AppRadius {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;

  /// Cards.
  static const double card = 28;
  static const double xl = 32;
  static const double pill = 999;

  static const BorderRadius xsAll = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius cardAll = BorderRadius.all(Radius.circular(card));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));

  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
}
