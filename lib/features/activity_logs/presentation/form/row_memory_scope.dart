import 'package:flutter/widgets.dart';

import '../../domain/activity_log.dart';

/// Turns on "Last time" hints in list rows (B2) while logging into an item,
/// not in the builder's preview. [except] is the item's own log, left out
/// of the lookup.
class RowMemoryScope extends InheritedWidget {
  const RowMemoryScope({super.key, this.except, required super.child});

  final ActivityLogId? except;

  static RowMemoryScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<RowMemoryScope>();

  @override
  bool updateShouldNotify(RowMemoryScope oldWidget) =>
      oldWidget.except != except;
}
