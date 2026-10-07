import '../../activity_types/domain/activity_ids.dart';

/// Where a new item on a day gets its activity when it isn't typed or a
/// chip: the list of activities (yours and built-in ones), or one the user
/// makes their own (its name and what to log). Every item added to a day
/// comes from an activity (ADR-042).
///
/// Both open full screens, so the router supplies them. Each returns the
/// activity's ID, or null when the user backs out.
class ActivityChooser {
  const ActivityChooser({required this.browse, required this.makeOwn});

  /// Opens the list of activities.
  final Future<ActivityTypeId?> Function() browse;

  /// Opens the activity builder, named [name] up front.
  final Future<ActivityTypeId?> Function(String name) makeOwn;
}
