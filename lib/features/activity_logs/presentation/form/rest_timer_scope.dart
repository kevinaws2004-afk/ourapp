import 'package:flutter/widgets.dart';

/// Lets all-number lists (e.g. sets) offer **Rest** while logging into an
/// item (B5). Forms without it (the builder preview) don't.
class RestTimerScope extends InheritedWidget {
  const RestTimerScope({super.key, required this.onRest, required super.child});

  /// Starts the rest timer.
  final VoidCallback onRest;

  static RestTimerScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<RestTimerScope>();

  @override
  bool updateShouldNotify(RestTimerScope oldWidget) =>
      oldWidget.onRest != onRest;
}
