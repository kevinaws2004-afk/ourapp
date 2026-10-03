import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/app_icons.dart';
import '../../../../core/design/context_ext.dart';
import '../../../../core/design/icons/activity_icon_registry.dart';
import '../../../../core/design/keys/activity_icon_ids.dart';
import '../../../../core/design/tokens/activity_palette.dart';
import '../../../../core/design/tokens/radius.dart';
import '../../../../core/design/tokens/spacing.dart';
import '../../../../core/design/window_size_class.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/errors/error_copy.dart';
import '../../../../shared/widgets/activity_badge.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../../activity_logs/domain/field_value.dart';
import '../../../activity_logs/presentation/form/activity_log_form.dart';
import '../../domain/activity_ids.dart';
import '../../domain/activity_type.dart';
import '../../domain/activity_type_definition.dart';
import '../../domain/field_config.dart';
import '../field_type_copy.dart';
import 'activity_builder_notifier.dart';
import 'field_editor_sheet.dart';
import 'field_type_picker_sheet.dart';

/// Create or edit an Activity Type (user_flows.md F2, ui_guidelines.md §4.5).
/// Returns the saved type's ID when popped after saving.
class ActivityBuilderScreen extends ConsumerWidget {
  const ActivityBuilderScreen({super.key, this.typeId});

  final ActivityTypeId? typeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final builder = ref.watch(activityBuilderProvider(typeId));
    final dirty = builder.value?.isDirty ?? false;
    return PopScope(
      canPop: !dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard(context) && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            typeId == null ? l10n.builderNewTitle : l10n.builderEditTitle,
          ),
        ),
        body: AsyncValueView(
          value: builder,
          onRetry: () => ref.invalidate(activityBuilderProvider(typeId)),
          data: (state) => _BuilderBody(typeId: typeId, state: state),
        ),
      ),
    );
  }
}

Future<bool> _confirmDiscard(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.discardChangesTitle),
      content: Text(l10n.discardChangesMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.actionKeepEditing),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.actionDiscard),
        ),
      ],
    ),
  );
  return result ?? false;
}

class _BuilderBody extends ConsumerWidget {
  const _BuilderBody({required this.typeId, required this.state});

  final ActivityTypeId? typeId;
  final ActivityBuilderState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(activityBuilderProvider(typeId).notifier);
    final margin = WindowSizeClass.of(context).screenMargin;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppContentWidth.reading),
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            margin,
            AppSpacing.lg,
            margin,
            AppSpacing.huge,
          ),
          children: [
            Row(
              children: [
                ActivityBadge(
                  iconId: state.iconId,
                  colorKey: state.colorKey,
                  size: 56,
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: TextFormField(
                    initialValue: state.name,
                    autofocus: state.isNew,
                    textCapitalization: TextCapitalization.sentences,
                    style: context.textStyles.titleLarge,
                    decoration: InputDecoration(
                      labelText: l10n.activityNameLabel,
                      hintText: l10n.activityNameHint,
                      errorText: firstIssueMessage(l10n, state.issues, 'name'),
                    ),
                    onChanged: notifier.setName,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              initialValue: state.description,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.activityDescriptionLabel,
              ),
              onChanged: notifier.setDescription,
            ),
            SectionHeader(title: l10n.iconLabel),
            _IconPicker(
              selected: state.iconId,
              colorKey: state.colorKey,
              onSelected: notifier.setIcon,
            ),
            SectionHeader(title: l10n.colorLabel),
            _ColorPicker(
              selected: state.colorKey,
              onSelected: notifier.setColor,
            ),
            SectionHeader(
              title: l10n.fieldsSectionTitle,
              subtitle: l10n.fieldsSectionHint,
            ),
            _FieldList(typeId: typeId, state: state),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(AppIcons.add),
                label: Text(l10n.addField),
                onPressed: () => _addField(context, notifier),
              ),
            ),
            SectionHeader(title: l10n.optionsSectionTitle),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.supportsTimerLabel),
              subtitle: Text(l10n.supportsTimerHint),
              value: state.supportsTimer,
              onChanged: notifier.setSupportsTimer,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.supportsPlanningLabel),
              value: state.supportsPlanning,
              onChanged: notifier.setSupportsPlanning,
            ),
            if (state.fields.isNotEmpty) ...[
              SectionHeader(title: l10n.previewSectionTitle),
              _Preview(state: state),
            ],
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: l10n.actionSave,
              onPressed: state.isSaving ? null : () => _save(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addField(
    BuildContext context,
    ActivityBuilderNotifier notifier,
  ) async {
    final type = await showFieldTypePicker(context);
    if (type == null || !context.mounted) return;
    final result = await showFieldEditor(
      context,
      isNew: true,
      initial: FieldDefinition(
        name: '',
        type: type,
        config: FieldConfig.defaultFor(type),
        measurable: type.measurableByDefault,
      ),
    );
    if (result case FieldSaved(:final definition)) {
      notifier.addField(definition);
    }
  }

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final id = await ref
          .read(activityBuilderProvider(typeId).notifier)
          .save();
      if (!context.mounted) return;
      if (id == null) {
        showMessageSnackBar(context, l10n.errorValidation);
      } else {
        Navigator.of(context).pop(id);
      }
    } catch (error) {
      if (context.mounted) {
        showMessageSnackBar(context, errorMessage(l10n, error));
      }
    }
  }
}

class _FieldList extends ConsumerWidget {
  const _FieldList({required this.typeId, required this.state});

  final ActivityTypeId? typeId;
  final ActivityBuilderState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(activityBuilderProvider(typeId).notifier);
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      onReorderItem: notifier.reorderField,
      children: [
        for (final (index, field) in state.fields.indexed)
          ListTile(
            key: ValueKey(field.key),
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              field.definition.type.icon,
              color: context.colors.textSecondary,
            ),
            title: Text(field.definition.name),
            subtitle: Text(
              [
                field.definition.type.label(l10n),
                if (field.definition.required) l10n.requiredBadge,
                ...state
                    .issuesForField(index)
                    .map((i) => validationMessage(l10n, i.code)),
              ].join(' · '),
              style: state.issuesForField(index).isEmpty
                  ? null
                  : context.textStyles.bodyMedium?.copyWith(
                      color: context.colors.danger,
                    ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (field.locked)
                  Icon(
                    AppIcons.locked,
                    size: 18,
                    color: context.colors.textTertiary,
                  ),
                ReorderableDragStartListener(
                  index: index,
                  child: const Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Icon(AppIcons.dragHandle),
                  ),
                ),
              ],
            ),
            onTap: () async {
              final result = await showFieldEditor(
                context,
                initial: field.definition,
                isNew: false,
                locked: field.locked,
              );
              switch (result) {
                case FieldSaved(:final definition):
                  notifier.replaceField(field.key, definition);
                case FieldRemoved():
                  notifier.removeField(field.key);
                case null:
                  break;
              }
            },
          ),
      ],
    );
  }
}

class _IconPicker extends StatelessWidget {
  const _IconPicker({
    required this.selected,
    required this.colorKey,
    required this.onSelected,
  });

  final String selected;
  final String colorKey;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.activity(
      ActivityColorKey.fromName(colorKey) ?? ActivityColorKey.slate,
    );
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final id in ActivityIconIds.all)
          InkWell(
            borderRadius: AppRadius.mdAll,
            onTap: () => onSelected(id),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: id == selected ? colors.soft : null,
                borderRadius: AppRadius.mdAll,
                border: id == selected
                    ? Border.all(color: colors.solid, width: 2)
                    : null,
              ),
              child: Icon(
                ActivityIconRegistry.resolve(id),
                semanticLabel: id,
                color: id == selected
                    ? colors.solid
                    : context.colors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final key in ActivityColorKey.values)
          Semantics(
            label: key.name,
            selected: key.name == selected,
            button: true,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => onSelected(key.name),
              child: Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: key.name == selected
                      ? Border.all(color: context.colors.textPrimary, width: 2)
                      : null,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.tokens.activity(key).solid,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Live preview using the real form renderer with a throwaway draft.
class _Preview extends StatefulWidget {
  const _Preview({required this.state});

  final ActivityBuilderState state;

  @override
  State<_Preview> createState() => _PreviewState();
}

class _PreviewState extends State<_Preview> {
  final _values = <ActivityFieldId, FieldValue>{};

  @override
  Widget build(BuildContext context) {
    final fields = [
      for (final (index, f) in widget.state.fields.indexed)
        ActivityField(
          id: f.definition.id ?? ActivityFieldId('preview:${f.key}'),
          name: f.definition.name.isEmpty ? '—' : f.definition.name,
          type: f.definition.type,
          dimension: f.definition.dimension,
          position: index,
          required: f.definition.required,
          measurable: f.definition.measurable,
          config: f.definition.config,
        ),
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceBase,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: context.colors.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ActivityLogFormFields(
          fields: fields,
          values: _values,
          onChanged: (id, value) => setState(
            () => value == null ? _values.remove(id) : _values[id] = value,
          ),
        ),
      ),
    );
  }
}
