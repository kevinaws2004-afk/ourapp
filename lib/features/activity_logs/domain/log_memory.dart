import '../../../core/ids/id_generator.dart';
import '../../activity_types/domain/activity_ids.dart';
import 'activity_log.dart';
import 'activity_log_repository.dart';
import 'field_value.dart';

// Logging from memory (Phase B, ADR-041): what was logged last time, to
// start from instead of a blank item. Generic: nothing here knows what an
// activity or a list row is.

/// [values] for a new log: the same values, with fresh IDs for every list
/// row (rows have their own identity, ADR-027).
Map<ActivityFieldId, FieldValue> copyValues(
  Map<ActivityFieldId, FieldValue> values,
  IdGenerator ids,
) => {
  for (final MapEntry(key: field, :value) in values.entries)
    field: switch (value) {
      RepeatingGroupValue(:final items) => RepeatingGroupValue([
        for (final item in items) copyRow(item, ids),
      ]),
      final other => other,
    },
};

/// [item] as a new row, its nested rows new too.
GroupItem copyRow(GroupItem item, IdGenerator ids) => GroupItem(
  id: GroupItemId(ids.newId()),
  values: copyValues(item.values, ids),
);

/// The newest row of list [groupFieldId] whose [nameFieldId] is [name]
/// (trimmed, case-insensitive), at any depth, in [logsNewestFirst].
GroupItem? findLastRow(
  Iterable<ActivityLog> logsNewestFirst, {
  required ActivityFieldId groupFieldId,
  required ActivityFieldId nameFieldId,
  required String name,
}) {
  final wanted = name.trim().toLowerCase();
  if (wanted.isEmpty) return null;
  GroupItem? search(Map<ActivityFieldId, FieldValue> values) {
    for (final MapEntry(key: field, :value) in values.entries) {
      if (value is! RepeatingGroupValue) continue;
      for (final item in value.items) {
        final named = switch (item.values[nameFieldId]) {
          TextValue(:final text) => text.trim().toLowerCase() == wanted,
          _ => false,
        };
        if (field == groupFieldId && named) return item;
        if (search(item.values) case final found?) return found;
      }
    }
    return null;
  }

  for (final log in logsNewestFirst) {
    if (search(log.values) case final found?) return found;
  }
  return null;
}

/// The most recent log of an activity with something in it, other than
/// [except] (B1: "Use last time").
class LastLogOfType {
  const LastLogOfType(this._logs);

  final ActivityLogRepository _logs;

  static const _lookBack = 10;

  Future<ActivityLog?> call(
    ActivityTypeId typeId, {
    ActivityLogId? except,
  }) async {
    final logs = await _logs.recentLogsForType(typeId, limit: _lookBack);
    return logs.where((l) => l.id != except && l.values.isNotEmpty).firstOrNull;
  }
}

/// The last time a list row with this name was logged (B2: "Last time:
/// 60 kg × 8"), other than in [except].
class LastRowNamed {
  const LastRowNamed(this._logs);

  final ActivityLogRepository _logs;

  static const _lookBack = 30;

  Future<GroupItem?> call(
    ActivityTypeId typeId, {
    required ActivityFieldId groupFieldId,
    required ActivityFieldId nameFieldId,
    required String name,
    ActivityLogId? except,
  }) async {
    final logs = await _logs.recentLogsForType(typeId, limit: _lookBack);
    return findLastRow(
      logs.where((l) => l.id != except),
      groupFieldId: groupFieldId,
      nameFieldId: nameFieldId,
      name: name,
    );
  }
}
