import 'package:flutter/widgets.dart';

import '../../../activity_types/domain/activity_type.dart';

/// Lets lists in a form offer "Add detail" (ADR-035): where a form is used
/// for logging into an item, each Repeating Group can grow a new sub-field
/// on the spot. Forms without this scope (e.g. the builder preview) don't
/// offer it.
class AddDetailScope extends InheritedWidget {
  const AddDetailScope({
    super.key,
    required this.onAddDetail,
    required super.child,
  });

  /// Adds a new detail (sub-field) to the list [group].
  final ValueChanged<ActivityField> onAddDetail;

  static AddDetailScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AddDetailScope>();

  @override
  bool updateShouldNotify(AddDetailScope oldWidget) =>
      oldWidget.onAddDetail != onAddDetail;
}
