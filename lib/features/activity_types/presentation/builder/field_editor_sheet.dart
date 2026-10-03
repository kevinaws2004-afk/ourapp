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
import '../../domain/field_config.dart';
import '../../domain/field_type.dart';
import '../field_type_copy.dart';

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

/// Configures one field (ui_guidelines.md §4.5). [locked] fields can't change
/// their unit dimension because they already have entries.
Future<FieldEditResult?> showFieldEditor(
  BuildContext context, {
  required FieldDefinition initial,
  required bool isNew,
  bool locked = false,
}) => showModalBottomSheet<FieldEditResult>(
  context: context,
  isScrollControlled: true,
  builder: (_) =>
      _FieldEditorSheet(initial: initial, isNew: isNew, locked: locked),
);

class _FieldEditorSheet extends ConsumerStatefulWidget {
  const _FieldEditorSheet({
    required this.initial,
    required this.isNew,
    required this.locked,
  });

  final FieldDefinition initial;
  final bool isNew;
  final bool locked;

  @override
  ConsumerState<_FieldEditorSheet> createState() => _FieldEditorSheetState();
}

class _FieldEditorSheetState extends ConsumerState<_FieldEditorSheet> {
  late final _name = TextEditingController(text: widget.initial.name);
  late bool _required = widget.initial.required;
  late bool _measurable = widget.initial.measurable;
  late Dimension? _dimension = widget.initial.dimension;
  late FieldConfig _config = widget.initial.config;

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
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
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
              ..._typeSpecific(l10n),
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

  List<Widget> _typeSpecific(AppLocalizations l10n) => switch (_config) {
    TextFieldConfig(:final multiline) => [
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(l10n.multilineLabel),
        value: multiline,
        onChanged: (v) =>
            setState(() => _config = TextFieldConfig(multiline: v)),
      ),
    ],
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
    BooleanFieldConfig() ||
    DateFieldConfig() ||
    TimeFieldConfig() ||
    DurationFieldConfig() ||
    RepeatingGroupFieldConfig() => const [],
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
