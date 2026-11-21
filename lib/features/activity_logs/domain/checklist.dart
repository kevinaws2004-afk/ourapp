import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../activity_types/domain/field_config.dart';
import '../../activity_types/domain/field_type.dart';
import '../../../core/ids/id_generator.dart';
import 'field_value.dart';

/// A list whose rows are a name and a tick ("Cleanser ✓", "Kitchen ✓"):
/// a routine's steps, a cleaning list, a packing list. Generic: any list
/// of exactly one text and one yes/no detail is one.
class Checklist {
  const Checklist({
    required this.group,
    required this.name,
    required this.done,
  });

  final ActivityFieldId group;
  final ActivityFieldId name;
  final ActivityFieldId done;

  /// The checklists of [type], in field order.
  static List<Checklist> of(ActivityType? type) {
    if (type == null) return const [];
    return [
      for (final field in type.activeFields)
        if (field.type == FieldType.repeatingGroup) ?_of(type, field.id),
    ];
  }

  static Checklist? _of(ActivityType type, ActivityFieldId group) {
    final subs = type.subFieldsOf(group);
    if (subs.length != 2) return null;
    final name = subs.where((f) => f.type == FieldType.text).firstOrNull;
    final done = subs.where((f) => f.type == FieldType.boolean).firstOrNull;
    if (name == null || done == null) return null;
    return Checklist(group: group, name: name.id, done: done.id);
  }

  /// Whether [field] (a list of [type]) is a checklist.
  static Checklist? forField(ActivityType type, ActivityFieldId field) =>
      _of(type, field);

  bool isTicked(GroupItem item) => switch (item.values[done]) {
    BooleanValue(:final value) => value,
    _ => false,
  };

  String nameOf(GroupItem item) => switch (item.values[name]) {
    TextValue(:final text) => text.trim(),
    _ => '',
  };

  /// [values]' rows of this list, unticked and with new IDs: the same steps
  /// for a new day.
  RepeatingGroupValue? fresh(
    Map<ActivityFieldId, FieldValue> values,
    IdGenerator ids,
  ) {
    final rows = switch (values[group]) {
      RepeatingGroupValue(:final items) => items,
      _ => const <GroupItem>[],
    };
    final named = [
      for (final row in rows)
        if (nameOf(row).isNotEmpty) nameOf(row),
    ];
    if (named.isEmpty) return null;
    return RepeatingGroupValue([
      for (final n in named)
        GroupItem(id: GroupItemId(ids.newId()), values: {name: TextValue(n)}),
    ]);
  }
}

/// How far [values] are through [type]'s checklists: (ticked, named rows),
/// or null when it has none with anything in it.
({int done, int total})? checklistProgress(
  ActivityType? type,
  Map<ActivityFieldId, FieldValue>? values,
) {
  if (values == null) return null;
  var done = 0;
  var total = 0;
  for (final list in Checklist.of(type)) {
    if (values[list.group] case RepeatingGroupValue(:final items)) {
      for (final item in items) {
        if (list.nameOf(item).isEmpty) continue;
        total++;
        if (list.isTicked(item)) done++;
      }
    }
  }
  return total == 0 ? null : (done: done, total: total);
}

/// The one number a counter activity counts (glasses of water, pushups): an
/// activity without a timer whose only detail is a whole number without a
/// unit. Null for anything else.
ActivityField? counterField(ActivityType? type) {
  if (type == null || type.supportsTimer) return null;
  final fields = type.activeFields;
  if (fields.length != 1) return null;
  final field = fields.single;
  if (field.type != FieldType.number) return null;
  return switch (field.config) {
    NumberFieldConfig(decimals: 0, defaultUnitCode: null) => field,
    _ => null,
  };
}

/// [values]' count for [field], 0 when nothing yet.
double counterValue(ActivityField field, Map<ActivityFieldId, FieldValue>? v) =>
    switch (v?[field.id]) {
      NumberValue(:final value) => value,
      _ => 0,
    };
