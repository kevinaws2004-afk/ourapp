import 'package:flutter/material.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/errors/error_copy.dart';
import '../../../activity_types/domain/activity_ids.dart';
import '../../../activity_types/domain/activity_type.dart';
import '../../../activity_types/domain/field_type.dart';
import '../../domain/field_value.dart';
import 'choice_editors.dart';
import 'date_time_editors.dart';
import 'field_editor_shell.dart';
import 'repeating_group_editor.dart';
import 'text_number_editors.dart';

/// The generic form renderer (application_architecture.md §4): renders any
/// activity's fields from their definitions. One renderer for new logs, edits
/// and the builder preview; no activity-specific code.
class ActivityLogFormFields extends StatelessWidget {
  const ActivityLogFormFields({
    super.key,
    required this.type,
    required this.fields,
    required this.values,
    required this.onChanged,
    this.issues = const [],
    this.targetPrefix = '',
    this.boxed = false,
  });

  /// The activity type [fields] belong to (Repeating Groups read their
  /// sub-fields from it).
  final ActivityType type;
  final List<ActivityField> fields;
  final Map<ActivityFieldId, FieldValue> values;
  final void Function(ActivityFieldId fieldId, FieldValue? value) onChanged;
  final List<ValidationIssue> issues;

  /// Prefix of issue targets in this scope: empty at the top level,
  /// `<itemId>/` inside a Repeating Group item (`LogValidator.itemTarget`).
  final String targetPrefix;

  /// Each field in its own card (logging into an item, ADR-045).
  final bool boxed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final field in fields)
          FieldEditorShell(
            key: ValueKey(field.id),
            boxed: boxed,
            label: field.isRemoved ? l10n.fieldRemoved(field.name) : field.name,
            required: field.required && !field.isRemoved,
            error: firstIssueMessage(
              l10n,
              issues,
              '$targetPrefix${field.id.value}',
            ),
            child: FieldEditorRegistry.editorFor(
              type,
              field,
              values[field.id],
              (value) => onChanged(field.id, value),
              issues: issues,
            ),
          ),
      ],
    );
  }
}

/// The only place that branches on field type, and it's exhaustive: a new
/// field type without an editor is a compile error.
abstract final class FieldEditorRegistry {
  static Widget editorFor(
    ActivityType type,
    ActivityField field,
    FieldValue? value,
    ValueChanged<FieldValue?> onChanged, {
    List<ValidationIssue> issues = const [],
  }) {
    return switch (field.type) {
      FieldType.text => TextValueEditor(
        field: field,
        value: value as TextValue?,
        onChanged: onChanged,
      ),
      FieldType.number => NumberValueEditor(
        field: field,
        value: value as NumberValue?,
        onChanged: onChanged,
      ),
      FieldType.boolean => BooleanValueEditor(
        value: value as BooleanValue?,
        onChanged: onChanged,
      ),
      FieldType.singleSelect => SingleSelectValueEditor(
        field: field,
        value: value as SingleSelectValue?,
        onChanged: onChanged,
      ),
      FieldType.multiSelect => MultiSelectValueEditor(
        field: field,
        value: value as MultiSelectValue?,
        onChanged: onChanged,
      ),
      FieldType.date => DateValueEditor(
        value: value as DateValue?,
        onChanged: onChanged,
      ),
      FieldType.time => TimeValueEditor(
        value: value as TimeValue?,
        onChanged: onChanged,
      ),
      FieldType.duration => DurationInput(
        milliseconds: (value as DurationValue?)?.milliseconds,
        onChanged: (ms) => onChanged(ms == null ? null : DurationValue(ms)),
      ),
      FieldType.rating => RatingValueEditor(
        field: field,
        value: value as RatingValue?,
        onChanged: onChanged,
      ),
      FieldType.repeatingGroup => RepeatingGroupEditor(
        type: type,
        field: field,
        value: value as RepeatingGroupValue?,
        issues: issues,
        onChanged: onChanged,
      ),
    };
  }
}
