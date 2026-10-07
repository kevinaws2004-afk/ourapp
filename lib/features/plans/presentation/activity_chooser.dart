import '../../activity_types/domain/activity_ids.dart';

/// Where a new item on a day gets its activity when it isn't one of yours
/// yet: a ready-made template, or one the user makes their own (its name
/// and what to log). Every item added to a day comes from an activity.
///
/// Both open full screens, so the router supplies them. Each returns the
/// activity's ID, or null when the user backs out.
class ActivityChooser {
  const ActivityChooser({required this.pickTemplate, required this.makeOwn});

  /// Opens the template gallery.
  final Future<ActivityTypeId?> Function() pickTemplate;

  /// Opens the activity builder, named [name] up front.
  final Future<ActivityTypeId?> Function(String name) makeOwn;
}
