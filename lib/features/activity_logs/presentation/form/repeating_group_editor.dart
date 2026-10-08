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
import '../../../../shared/widgets/status_chip.dart';
import 'add_detail_scope.dart';
import 'rest_timer_scope.dart';
import 'row_memory_scope.dart';
import 'text_number_editors.dart';

/// Edits a Repeating Group (ADR-027): an ordered list of items, each holding
/// the group's sub-field values. Generic: nothing here knows what an item
/// represents (an exercise, a set, an ingredient).
///
/// When every sub-field is a Number, the row being filled in is a card with
/// a − / + stepper per number, earlier rows fold into one line ("2 · 60 kg ×
/// 8"; tap to change one), and a new row starts from the previous row's
/// values, so repeating a set is one tap (ADR-045). Otherwise each item is a
/// card with the full form for its sub-fields.
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
        if (compact)
          _CompactRows(
            type: type,
            group: field,
            itemLabel: _itemLabel,
            fields: subFields,
            items: _items,
            issues: issues,
            onReplace: _replace,
            onRemove: (index) => _emit([..._items]..removeAt(index)),
          )
        else
          for (final (index, item) in _items.indexed)
            _ItemCard(
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
              // The actions wrap on a narrow screen.
              Expanded(
                child: Wrap(
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
                  ],
                ),
              ),
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

/// The rows of an all-number list (ADR-045): the active row (the newest, or
/// the one tapped) as a card with a stepper per number; every other row
/// folded into one line. A row with a problem stays open so it can be fixed.
class _CompactRows extends StatefulWidget {
  const _CompactRows({
    required this.type,
    required this.group,
    required this.itemLabel,
    required this.fields,
    required this.items,
    required this.issues,
    required this.onReplace,
    required this.onRemove,
  });

  final ActivityType type;
  final ActivityField group;
  final String itemLabel;
  final List<ActivityField> fields;
  final List<GroupItem> items;
  final List<ValidationIssue> issues;
  final void Function(int index, GroupItem item) onReplace;
  final ValueChanged<int> onRemove;

  @override
  State<_CompactRows> createState() => _CompactRowsState();
}

class _CompactRowsState extends State<_CompactRows> {
  GroupItemId? _active;

  @override
  void didUpdateWidget(_CompactRows old) {
    super.didUpdateWidget(old);
    // A new row is the one to fill in.
    if (widget.items.length > old.items.length) _active = null;
  }

  bool _hasIssue(GroupItem item) => widget.issues.any(
    (i) => i.target?.startsWith('${item.id.value}/') ?? false,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = widget.items;
    final active = items.any((i) => i.id == _active)
        ? _active
        : items.lastOrNull?.id;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, item) in items.indexed)
          if (item.id == active || _hasIssue(item))
            _ActiveRow(
              key: ValueKey(item.id),
              title: l10n.groupItemTitle(widget.itemLabel, index + 1),
              removeLabel: l10n.removeGroupItem(widget.itemLabel),
              fields: widget.fields,
              item: item,
              issues: widget.issues,
              onChanged: (item) => widget.onReplace(index, item),
              onRemove: () => widget.onRemove(index),
            )
          else
            _FoldedRow(
              key: ValueKey(item.id),
              number: index + 1,
              title: l10n.groupItemTitle(widget.itemLabel, index + 1),
              summary: formatGroupSummary(
                context,
                widget.type,
                widget.group,
                RepeatingGroupValue([item]),
              ),
              onTap: () => setState(() => _active = item.id),
            ),
      ],
    );
  }
}

/// A finished row in one line: its number, what's in it, and a check.
class _FoldedRow extends StatelessWidget {
  const _FoldedRow({
    super.key,
    required this.number,
    required this.title,
    required this.summary,
    required this.onTap,
  });

  final int number;
  final String title;
  final String summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Semantics(
        button: true,
        label: '$title: $summary',
        excludeSemantics: true,
        child: Material(
          color: c.surfaceSunken,
          borderRadius: AppRadius.pillAll,
          child: InkWell(
            borderRadius: AppRadius.pillAll,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: c.surfaceBase,
                    child: Text(
                      '$number',
                      style: context.textStyles.labelMedium,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      summary,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.titleMedium,
                    ),
                  ),
                  Icon(AppIcons.check, color: c.success, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The row being filled in: its title, "Now", a stepper per number, and
/// remove.
class _ActiveRow extends StatelessWidget {
  const _ActiveRow({
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
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.brandPrimarySoft.withValues(alpha: 0.5),
          borderRadius: AppRadius.lgAll,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.xs,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(title, style: context.textStyles.titleMedium),
                  const SizedBox(width: AppSpacing.sm),
                  StatusChip(label: l10n.groupRowNow, tone: StatusTone.active),
                  const Spacer(),
                  IconButton(
                    tooltip: removeLabel,
                    icon: const Icon(AppIcons.close),
                    onPressed: onRemove,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                // Side by side when every stepper has room; stacked on a
                // narrow screen.
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    Widget editor(ActivityField sub) => NumberValueEditor(
                      field: sub,
                      value: item.values[sub.id] as NumberValue?,
                      label: sub.required ? '${sub.name} *' : sub.name,
                      stepper: true,
                      errorText: firstIssueMessage(
                        l10n,
                        issues,
                        LogValidator.itemTarget(item.id, sub.id),
                      ),
                      onChanged: (value) => onChanged(
                        item.withValues(_withValue(item.values, sub.id, value)),
                      ),
                    );
                    final roomy =
                        constraints.maxWidth / fields.length >= _stepperWidth;
                    return Flex(
                      direction: roomy ? Axis.horizontal : Axis.vertical,
                      crossAxisAlignment: roomy
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.stretch,
                      children: [
                        for (final (i, sub) in fields.indexed) ...[
                          if (i > 0)
                            const SizedBox.square(dimension: AppSpacing.sm),
                          if (roomy)
                            Expanded(child: editor(sub))
                          else
                            editor(sub),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The narrowest a stepper is laid out beside another.
  static const double _stepperWidth = 150;
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
