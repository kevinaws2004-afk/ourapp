import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/app_icons.dart';
import '../../../../core/design/context_ext.dart';
import '../../../../core/design/tokens/radius.dart';
import '../../../../core/design/tokens/spacing.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/ids/id_generator_provider.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/errors/error_copy.dart';
import '../../../activity_types/domain/activity_ids.dart';
import '../../../activity_types/domain/activity_type.dart';
import '../../../activity_types/domain/field_config.dart';
import '../../../activity_types/domain/field_type.dart';
import '../../domain/field_value.dart';
import '../../domain/log_validator.dart';
import 'activity_log_form.dart';
import 'text_number_editors.dart';

/// Edits a Repeating Group (ADR-027): an ordered list of items, each holding
/// the group's sub-field values. Generic: nothing here knows what an item
/// represents (an exercise, a set, an ingredient).
///
/// When every sub-field is a Number, items render as compact rows ("Set 1 ·
/// 50 kg · 12") and a new row starts from the previous row's values, so
/// repeating a set is one tap. Otherwise each item is a card with the full
/// form for its sub-fields.
class RepeatingGroupEditor extends ConsumerWidget {
  const RepeatingGroupEditor({
    super.key,
    required this.type,
    required this.field,
    required this.value,
    required this.issues,
    required this.onChanged,
  });

  final ActivityType type;
  final ActivityField field;
  final RepeatingGroupValue? value;
  final List<ValidationIssue> issues;
  final ValueChanged<FieldValue?> onChanged;

  List<GroupItem> get _items => value?.items ?? const [];

  String get _itemLabel =>
      (field.config as RepeatingGroupFieldConfig).itemLabel;

  /// Sub-fields in order, plus removed ones that still hold a value.
  List<ActivityField> _subFields() {
    final all = type.subFieldsOf(field.id, includeRemoved: true);
    return [
      ...all.where((f) => !f.isRemoved),
      ...all.where(
        (f) => f.isRemoved && _items.any((i) => i.values.containsKey(f.id)),
      ),
    ];
  }

  void _emit(List<GroupItem> items) =>
      onChanged(items.isEmpty ? null : RepeatingGroupValue(items));

  void _replace(int index, GroupItem item) =>
      _emit([..._items]..[index] = item);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final subFields = _subFields();
    final compact =
        subFields.isNotEmpty &&
        subFields.every((f) => f.type == FieldType.number);

    void add() {
      final id = GroupItemId(ref.read(idGeneratorProvider).newId());
      final previous = _items.lastOrNull;
      _emit([
        ..._items,
        GroupItem(
          id: id,
          values: compact && previous != null ? {...previous.values} : const {},
        ),
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, item) in _items.indexed)
          compact
              ? _CompactItemRow(
                  key: ValueKey(item.id),
                  title: l10n.groupItemTitle(_itemLabel, index + 1),
                  removeLabel: l10n.removeGroupItem(_itemLabel),
                  fields: subFields,
                  item: item,
                  issues: issues,
                  onChanged: (item) => _replace(index, item),
                  onRemove: () => _emit([..._items]..removeAt(index)),
                )
              : _ItemCard(
                  key: ValueKey(item.id),
                  title: l10n.groupItemTitle(_itemLabel, index + 1),
                  removeLabel: l10n.removeGroupItem(_itemLabel),
                  type: type,
                  fields: subFields,
                  item: item,
                  issues: issues,
                  onChanged: (item) => _replace(index, item),
                  onRemove: () => _emit([..._items]..removeAt(index)),
                ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(AppIcons.add),
            label: Text(l10n.addGroupItem(_itemLabel)),
            onPressed: add,
          ),
        ),
      ],
    );
  }
}

/// One item as a card holding the full form for its sub-fields.
class _ItemCard extends StatelessWidget {
  const _ItemCard({
    super.key,
    required this.title,
    required this.removeLabel,
    required this.type,
    required this.fields,
    required this.item,
    required this.issues,
    required this.onChanged,
    required this.onRemove,
  });

  final String title;
  final String removeLabel;
  final ActivityType type;
  final List<ActivityField> fields;
  final GroupItem item;
  final List<ValidationIssue> issues;
  final ValueChanged<GroupItem> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceBase,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: context.colors.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xs,
          AppSpacing.xs,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, style: context.textStyles.titleSmall),
                ),
                IconButton(
                  tooltip: removeLabel,
                  icon: const Icon(AppIcons.close),
                  onPressed: onRemove,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: ActivityLogFormFields(
                type: type,
                fields: fields,
                values: item.values,
                issues: issues,
                targetPrefix: '${item.id.value}/',
                onChanged: (fieldId, value) => onChanged(
                  item.withValues(_withValue(item.values, fieldId, value)),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// One all-number item as a single row of labelled number inputs.
class _CompactItemRow extends StatelessWidget {
  const _CompactItemRow({
    super.key,
    required this.title,
    required this.removeLabel,
    required this.fields,
    required this.item,
    required this.issues,
    required this.onChanged,
    required this.onRemove,
  });

  final String title;
  final String removeLabel;
  final List<ActivityField> fields;
  final GroupItem item;
  final List<ValidationIssue> issues;
  final ValueChanged<GroupItem> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.lg,
              right: AppSpacing.md,
            ),
            child: Text(
              title,
              style: context.textStyles.labelMedium?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),
          for (final sub in fields) ...[
            Expanded(
              child: NumberValueEditor(
                field: sub,
                value: item.values[sub.id] as NumberValue?,
                label: sub.required ? '${sub.name} *' : sub.name,
                errorText: firstIssueMessage(
                  l10n,
                  issues,
                  LogValidator.itemTarget(item.id, sub.id),
                ),
                onChanged: (value) => onChanged(
                  item.withValues(_withValue(item.values, sub.id, value)),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          IconButton(
            tooltip: removeLabel,
            icon: const Icon(AppIcons.close),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

Map<ActivityFieldId, FieldValue> _withValue(
  Map<ActivityFieldId, FieldValue> values,
  ActivityFieldId fieldId,
  FieldValue? value,
) {
  final next = Map.of(values);
  if (value == null) {
    next.remove(fieldId);
  } else {
    next[fieldId] = value;
  }
  return next;
}
