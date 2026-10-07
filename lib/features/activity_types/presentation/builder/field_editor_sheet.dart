import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/app_icons.dart';
import '../../../../core/design/context_ext.dart';
import '../../../../core/design/tokens/spacing.dart';
import '../../../../core/ids/id_generator_provider.dart';
import '../../../../core/units/unit_registry.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/activity_ids.dart';
import '../../domain/activity_type_definition.dart';
import '../../domain/activity_type_validator.dart';
import '../../domain/field_config.dart';
import '../../domain/field_type.dart';
import '../field_type_copy.dart';
import 'field_type_picker_sheet.dart';
import '../../../../shared/widgets/discard_guard.dart';

/// Result of editing a field: the new definition, or a request to remove it.
sealed class FieldEditResult {
  const FieldEditResult();
}

final class FieldSaved extends FieldEditResult {
  const FieldSaved(this.definition);

  final FieldDefinition definition;
}

final class FieldRemoved extends FieldEditResult {
  const FieldRemoved();
}

/// Configures one field (ui_guidelines.md §4.5). Fields in [lockedFieldIds]
/// can't change their unit dimension because they already have entries.
/// [depth] is how many Repeating Groups contain the field (0 = top level); a
/// group's sub-fields are edited in a nested sheet (ADR-027).
Future<FieldEditResult?> showFieldEditor(
  BuildContext context, {
  required FieldDefinition initial,
  required bool isNew,
  Set<ActivityFieldId> lockedFieldIds = const {},
  int depth = 0,
}) => showModalBottomSheet<FieldEditResult>(
  context: context,
  isScrollControlled: true,
  builder: (_) => _FieldEditorSheet(
    initial: initial,
    isNew: isNew,
    lockedFieldIds: lockedFieldIds,
    depth: depth,
  ),
);

/// A new field of [type] with its default settings.
FieldDefinition newFieldDefinition(FieldType type) => FieldDefinition(
  name: '',
  type: type,
  config: FieldConfig.defaultFor(type),
  measurable: type.measurableByDefault,
);

class _FieldEditorSheet extends ConsumerStatefulWidget {
  const _FieldEditorSheet({
    required this.initial,
    required this.isNew,
    required this.lockedFieldIds,
    required this.depth,
  });

  final FieldDefinition initial;
  final bool isNew;
  final Set<ActivityFieldId> lockedFieldIds;
  final int depth;

  bool get locked => initial.id != null && lockedFieldIds.contains(initial.id);

  @override
  ConsumerState<_FieldEditorSheet> createState() => _FieldEditorSheetState();
}

class _FieldEditorSheetState extends ConsumerState<_FieldEditorSheet> {
  late final _name = TextEditingController(text: widget.initial.name);
  late bool _required = widget.initial.required;
  late bool _measurable = widget.initial.measurable;
  late Dimension? _dimension = widget.initial.dimension;
  late FieldConfig _config = widget.initial.config;
  late List<FieldDefinition> _subFields = widget.initial.subFields;

  FieldType get _type => widget.initial.type;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _done() => Navigator.of(context).pop(
    FieldSaved(
      FieldDefinition(
        id: widget.initial.id,
        name: _name.text,
        type: _type,
        dimension: _type == FieldType.number ? _dimension : null,
        required: _required,
        measurable: _type.canBeMeasurable && _measurable,
        config: _config,
        subFields: _type == FieldType.repeatingGroup ? _subFields : const [],
      ),
    ),
  );

  /// Something was changed (A15).
  bool get _dirty =>
      _name.text != widget.initial.name ||
      _required != widget.initial.required ||
      _measurable != widget.initial.measurable ||
      _dimension != widget.initial.dimension ||
      !identical(_config, widget.initial.config) ||
      !identical(_subFields, widget.initial.subFields);

  @override
  void initState() {
    super.initState();
    // Rebuild on typing so the discard guard knows about it (A15).
    _name.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) =>
      DiscardGuard(dirty: _dirty, child: _buildSheet(context));

  Widget _buildSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.9,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              0,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            children: [
              Row(
                children: [
                  Icon(_type.icon, color: context.colors.textSecondary),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      widget.isNew
                          ? l10n.fieldEditorNewTitle
                          : l10n.fieldEditorEditTitle,
                      style: context.textStyles.titleLarge,
                    ),
                  ),
                  Text(
                    _type.label(l10n),
                    style: context.textStyles.labelMedium,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _name,
                autofocus: widget.isNew,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: l10n.fieldNameLabel),
              ),
              ..._typeSpecific(l10n),
              // Settings most people never need (B4).
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                title: Text(l10n.fieldAdvanced),
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.requiredLabel),
                    value: _required,
                    onChanged: (v) => setState(() => _required = v),
                  ),
                  if (_type.canBeMeasurable)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.measurableLabel),
                      value: _measurable,
                      onChanged: (v) => setState(() => _measurable = v),
                    ),
                  ..._advancedTypeSpecific(l10n),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  if (!widget.isNew)
                    TextButton.icon(
                      icon: Icon(AppIcons.delete, color: context.colors.danger),
                      label: Text(
                        l10n.removeField,
                        style: TextStyle(color: context.colors.danger),
                      ),
                      onPressed: () =>
                          Navigator.of(context).pop(const FieldRemoved()),
                    ),
                  const Spacer(),
                  FilledButton(onPressed: _done, child: Text(l10n.doneAction)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The less common settings of the field's type, under Advanced (B4).
  List<Widget> _advancedTypeSpecific(AppLocalizations l10n) =>
      switch (_config) {
        final TextFieldConfig config => [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.multilineLabel),
            value: config.multiline,
            onChanged: (v) => setState(
              () => _config = TextFieldConfig(
                multiline: v,
                suggestFromHistory: config.suggestFromHistory,
              ),
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.suggestFromHistoryLabel),
            subtitle: Text(l10n.suggestFromHistoryHint),
            value: config.suggestFromHistory,
            onChanged: (v) => setState(
              () => _config = TextFieldConfig(
                multiline: config.multiline,
                suggestFromHistory: v,
              ),
            ),
          ),
        ],
        final NumberFieldConfig config => _numberAdvanced(l10n, config),
        SelectFieldConfig() ||
        RatingFieldConfig() ||
        RepeatingGroupFieldConfig() ||
        BooleanFieldConfig() ||
        DateFieldConfig() ||
        TimeFieldConfig() ||
        DurationFieldConfig() => const [],
      };

  List<Widget> _typeSpecific(AppLocalizations l10n) => switch (_config) {
    TextFieldConfig() => const [],
    final NumberFieldConfig config => _numberSettings(l10n, config),
    final SelectFieldConfig config => [
      _OptionsEditor(
        config: config,
        savedOptionIds: switch (widget.initial.config) {
          SelectFieldConfig(:final options) when !widget.isNew => {
            for (final o in options) o.id,
          },
          _ => const {},
        },
        onChanged: (c) => setState(() => _config = c),
      ),
    ],
    RatingFieldConfig(:final max) => [
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(l10n.ratingScaleLabel),
        trailing: DropdownButton<int>(
          value: max,
          items: [
            for (
              var i = RatingFieldConfig.minScale;
              i <= RatingFieldConfig.maxScale;
              i++
            )
              DropdownMenuItem(value: i, child: Text('$i')),
          ],
          onChanged: (v) =>
              setState(() => _config = RatingFieldConfig(max: v ?? max)),
        ),
      ),
    ],
    RepeatingGroupFieldConfig(:final itemLabel) => [
      TextFormField(
        initialValue: itemLabel,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: l10n.itemLabelLabel,
          helperText: l10n.itemLabelHelper,
        ),
        onChanged: (v) =>
            setState(() => _config = RepeatingGroupFieldConfig(itemLabel: v)),
      ),
      _SubFieldsEditor(
        subFields: _subFields,
        lockedFieldIds: widget.lockedFieldIds,
        depth: widget.depth + 1,
        onChanged: (fields) => setState(() => _subFields = fields),
      ),
    ],
    BooleanFieldConfig() ||
    DateFieldConfig() ||
    TimeFieldConfig() ||
    DurationFieldConfig() => const [],
  };

  List<Widget> _numberSettings(
    AppLocalizations l10n,
    NumberFieldConfig config,
  ) {
    final dimension = _dimension;
    return [
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(l10n.unitDimensionLabel),
        subtitle: widget.locked ? Text(l10n.lockedFieldHint) : null,
        trailing: DropdownButton<Dimension?>(
          value: dimension,
          items: [
            DropdownMenuItem(child: Text(l10n.unitNone)),
            for (final d in Dimension.numberDimensions)
              DropdownMenuItem(value: d, child: Text(d.label(l10n))),
          ],
          onChanged: widget.locked
              ? null
              : (d) => setState(() {
                  _dimension = d;
                  _config = config.copyWith(
                    defaultUnitCode: () =>
                        d == null ? null : UnitRegistry.canonicalFor(d).code,
                  );
                }),
        ),
      ),
      if (dimension != null)
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.defaultUnitLabel),
          trailing: DropdownButton<String>(
            value: config.defaultUnitCode,
            items: [
              for (final unit in UnitRegistry.forDimension(dimension))
                DropdownMenuItem(value: unit.code, child: Text(unit.symbol)),
            ],
            onChanged: (code) => setState(
              () => _config = config.copyWith(defaultUnitCode: () => code),
            ),
          ),
        ),
    ];
  }

  List<Widget> _numberAdvanced(
    AppLocalizations l10n,
    NumberFieldConfig config,
  ) => [
    // How Insights sums it up and what "best" means (ADR-043).
    ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(l10n.numberSummaryLabel),
      trailing: DropdownButton<NumberSummary>(
        value: config.summary,
        items: [
          for (final s in NumberSummary.values)
            DropdownMenuItem(
              value: s,
              child: Text(numberSummaryLabel(l10n, s)),
            ),
        ],
        onChanged: (v) => setState(
          () => _config = (_config as NumberFieldConfig).copyWith(summary: v),
        ),
      ),
    ),
    ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(l10n.betterDirectionLabel),
      trailing: DropdownButton<BetterDirection>(
        value: config.better,
        items: [
          for (final b in BetterDirection.values)
            DropdownMenuItem(
              value: b,
              child: Text(betterDirectionLabel(l10n, b)),
            ),
        ],
        onChanged: (v) => setState(
          () => _config = (_config as NumberFieldConfig).copyWith(better: v),
        ),
      ),
    ),
    ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(l10n.decimalsLabel),
      trailing: DropdownButton<int>(
        value: config.decimals,
        items: [
          for (var i = 0; i <= NumberFieldConfig.maxDecimals; i++)
            DropdownMenuItem(value: i, child: Text('$i')),
        ],
        onChanged: (v) =>
            setState(() => _config = config.copyWith(decimals: v)),
      ),
    ),
    Row(
      children: [
        Expanded(
          child: _NumberInput(
            label: l10n.minimumLabel,
            value: config.min,
            onChanged: (v) => setState(
              () => _config = (_config as NumberFieldConfig).copyWith(
                min: () => v,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _NumberInput(
            label: l10n.maximumLabel,
            value: config.max,
            onChanged: (v) => setState(
              () => _config = (_config as NumberFieldConfig).copyWith(
                max: () => v,
              ),
            ),
          ),
        ),
      ],
    ),
  ];
}

class _NumberInput extends StatelessWidget {
  const _NumberInput({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double? value;
  final ValueChanged<double?> onChanged;

  @override
  Widget build(BuildContext context) => TextFormField(
    initialValue: value == null ? '' : '$value',
    keyboardType: const TextInputType.numberWithOptions(
      decimal: true,
      signed: true,
    ),
    decoration: InputDecoration(labelText: label),
    onChanged: (text) =>
        onChanged(double.tryParse(text.trim().replaceAll(',', '.'))),
  );
}

/// Edits select options. Options keep stable IDs; removing one that exists in
/// a saved field archives it so history still renders (data_architecture §3.2).
class _OptionsEditor extends ConsumerWidget {
  const _OptionsEditor({
    required this.config,
    required this.savedOptionIds,
    required this.onChanged,
  });

  final SelectFieldConfig config;

  /// Options already stored with the field; only these are archived on removal.
  final Set<SelectOptionId> savedOptionIds;
  final ValueChanged<SelectFieldConfig> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final options = config.options;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.md,
            bottom: AppSpacing.sm,
          ),
          child: Text(l10n.optionsLabel, style: context.textStyles.labelMedium),
        ),
        for (final (index, option) in options.indexed)
          if (!option.archived)
            Row(
              key: ValueKey(option.id),
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: option.label,
                    decoration: InputDecoration(hintText: l10n.optionHint),
                    onChanged: (label) => onChanged(
                      SelectFieldConfig(
                        options: [...options]
                          ..[index] = option.copyWith(label: label),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.actionDelete,
                  icon: const Icon(AppIcons.close),
                  onPressed: () => onChanged(
                    SelectFieldConfig(
                      options: savedOptionIds.contains(option.id)
                          ? ([...options]
                              ..[index] = option.copyWith(archived: true))
                          : ([...options]..removeAt(index)),
                    ),
                  ),
                ),
              ],
            ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(AppIcons.add),
            label: Text(l10n.addOption),
            onPressed: () => onChanged(
              SelectFieldConfig(
                options: [
                  ...options,
                  SelectOption(
                    id: SelectOptionId(ref.read(idGeneratorProvider).newId()),
                    label: '',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The sub-fields of a Repeating Group: tap to edit (in a nested sheet), drag
/// to reorder, add with the type picker. A nested group is offered only while
/// below the nesting limit (ADR-027).
class _SubFieldsEditor extends StatelessWidget {
  const _SubFieldsEditor({
    required this.subFields,
    required this.lockedFieldIds,
    required this.depth,
    required this.onChanged,
  });

  final List<FieldDefinition> subFields;
  final Set<ActivityFieldId> lockedFieldIds;

  /// Depth of the sub-fields themselves (1 = inside a top-level group).
  final int depth;
  final ValueChanged<List<FieldDefinition>> onChanged;

  bool get _allowGroup => depth < ActivityTypeValidator.maxGroupDepth;

  Future<void> _add(BuildContext context) async {
    final type = await showFieldTypePicker(context, allowGroup: _allowGroup);
    if (type == null || !context.mounted) return;
    final result = await showFieldEditor(
      context,
      initial: newFieldDefinition(type),
      isNew: true,
      lockedFieldIds: lockedFieldIds,
      depth: depth,
    );
    if (result case FieldSaved(:final definition)) {
      onChanged([...subFields, definition]);
    }
  }

  Future<void> _edit(BuildContext context, int index) async {
    final result = await showFieldEditor(
      context,
      initial: subFields[index],
      isNew: false,
      lockedFieldIds: lockedFieldIds,
      depth: depth,
    );
    switch (result) {
      case FieldSaved(:final definition):
        onChanged([...subFields]..[index] = definition);
      case FieldRemoved():
        onChanged([...subFields]..removeAt(index));
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.lg,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            l10n.subFieldsLabel,
            style: context.textStyles.labelMedium,
          ),
        ),
        if (subFields.isEmpty)
          Text(
            l10n.subFieldsEmpty,
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorderItem: (oldIndex, newIndex) {
            final fields = [...subFields];
            fields.insert(newIndex, fields.removeAt(oldIndex));
            onChanged(fields);
          },
          children: [
            for (final (index, field) in subFields.indexed)
              ListTile(
                key: ObjectKey(field),
                contentPadding: EdgeInsets.zero,
                leading: Icon(field.type.icon),
                title: Text(field.name),
                subtitle: Text(
                  [
                    field.type.label(l10n),
                    if (field.required) l10n.requiredBadge,
                  ].join(' · '),
                ),
                trailing: ReorderableDragStartListener(
                  index: index,
                  child: const Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Icon(AppIcons.dragHandle),
                  ),
                ),
                onTap: () => _edit(context, index),
              ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(AppIcons.add),
            label: Text(l10n.addSubField),
            onPressed: () => _add(context),
          ),
        ),
      ],
    );
  }
}
