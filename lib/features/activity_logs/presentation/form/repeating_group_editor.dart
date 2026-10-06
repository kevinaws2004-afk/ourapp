import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/app_icons.dart';
import '../../../../core/design/context_ext.dart';
import '../../../../core/design/tokens/motion.dart';
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
import '../../domain/log_memory.dart';
import '../../domain/log_validator.dart';
import '../activity_log_providers.dart';
import '../value_formatting.dart';
import 'activity_log_form.dart';
import 'add_detail_scope.dart';
import 'rest_timer_scope.dart';
import 'row_memory_scope.dart';
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

    void add(BuildContext actionsContext) {
      final id = GroupItemId(ref.read(idGeneratorProvider).newId());
      final previous = _items.lastOrNull;
      _emit([
        ..._items,
        GroupItem(
          id: id,
          values: compact && previous != null ? {...previous.values} : const {},
        ),
      ]);
      // Keep the new row in view above the keyboard (A14): the actions sit
      // right below it.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!actionsContext.mounted) return;
        Scrollable.ensureVisible(
          actionsContext,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : AppMotion.standard,
        );
      });
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
                  group: field,
                  title: l10n.groupItemTitle(_itemLabel, index + 1),
                  removeLabel: l10n.removeGroupItem(_itemLabel),
                  type: type,
                  fields: subFields,
                  item: item,
                  issues: issues,
                  onChanged: (item) => _replace(index, item),
                  onRemove: () => _emit([..._items]..removeAt(index)),
                ),
        Builder(
          builder: (actionsContext) => Row(
            children: [
              TextButton.icon(
                icon: const Icon(AppIcons.add),
                label: Text(l10n.addGroupItem(_itemLabel)),
                onPressed: () => add(actionsContext),
              ),
              // Rows of numbers (e.g. sets) can have a rest between them (B5).
              if (compact && _items.isNotEmpty)
                if (RestTimerScope.maybeOf(context) case final rest?)
                  TextButton.icon(
                    icon: const Icon(AppIcons.timer),
                    label: Text(l10n.restAction),
                    onPressed: rest.onRest,
                  ),
              const Spacer(),
              // Logging into an item: the list can grow a new detail, kept in
              // a menu so it doesn't compete with adding a row (A13).
              if (AddDetailScope.maybeOf(context) case final scope?)
                PopupMenuButton<void>(
                  tooltip: l10n.groupListOptions(_itemLabel),
                  icon: const Icon(AppIcons.more),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      onTap: () => scope.onAddDetail(field),
                      child: Text(l10n.addGroupDetailTo(_itemLabel)),
                    ),
                  ],
                ),
            ],
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
    required this.group,
    required this.title,
    required this.removeLabel,
    required this.type,
    required this.fields,
    required this.item,
    required this.issues,
    required this.onChanged,
    required this.onRemove,
  });

  final ActivityField group;
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
            _LastRowHint(
              type: type,
              group: group,
              fields: fields,
              item: item,
              onUse: onChanged,
            ),
          ],
        ),
      ),
    ),
  );
}

/// "Last time: Bench press 60 kg × 8 (×2)" under a named row with nothing
/// else filled in yet, and **Use** to start from it (B2, ADR-041). Only while
/// logging into an item ([RowMemoryScope]).
class _LastRowHint extends ConsumerWidget {
  const _LastRowHint({
    required this.type,
    required this.group,
    required this.fields,
    required this.item,
    required this.onUse,
  });

  final ActivityType type;
  final ActivityField group;
  final List<ActivityField> fields;
  final GroupItem item;
  final ValueChanged<GroupItem> onUse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scope = RowMemoryScope.maybeOf(context);
    final nameField = fields
        .where((f) => f.type == FieldType.text && !f.isRemoved)
        .firstOrNull;
    final name = switch (nameField == null ? null : item.values[nameField.id]) {
      TextValue(:final text) => text.trim(),
      _ => '',
    };
    // Only for a row that has its name and nothing else yet.
    if (scope == null ||
        nameField == null ||
        name.isEmpty ||
        item.values.length > 1) {
      return const SizedBox.shrink();
    }
    final last = ref
        .watch(
          lastRowProvider((
            typeId: type.id,
            groupFieldId: group.id,
            nameFieldId: nameField.id,
            name: name.toLowerCase(),
            except: scope.except,
          )),
        )
        .value;
    if (last == null || last.values.length < 2) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final summary = formatGroupSummary(
      context,
      type,
      group,
      RepeatingGroupValue([last]),
    );
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.groupLastTime(summary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final copy = copyRow(last, ref.read(idGeneratorProvider));
              onUse(
                item.withValues({
                  ...copy.values,
                  nameField.id: item.values[nameField.id]!,
                }),
              );
            },
            child: Text(l10n.groupUseLastTime),
          ),
        ],
      ),
    );
  }
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
