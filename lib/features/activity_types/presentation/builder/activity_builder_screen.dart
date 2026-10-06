import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/app_icons.dart';
import '../../../../core/design/tokens/sizes.dart';
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
import '../../../../shared/widgets/discard_guard.dart';
import '../../../activity_logs/domain/field_value.dart';
import '../../../activity_logs/presentation/form/activity_log_form.dart';
import '../../domain/activity_ids.dart';
import '../../domain/activity_type.dart';
import '../field_type_copy.dart';
import '../activity_appearance_copy.dart';
import '../preview_type.dart';
import 'activity_builder_notifier.dart';
import 'field_editor_sheet.dart';
import 'field_type_picker_sheet.dart';

/// Create or edit an Activity Type (user_flows.md F2, ui_guidelines.md §4.5).
/// Returns the saved type's ID when popped after saving.
class ActivityBuilderScreen extends ConsumerWidget {
  const ActivityBuilderScreen({super.key, this.typeId, this.initialName = ''});

  final ActivityTypeId? typeId;

  /// A new activity's name, prefilled (e.g. from a plan's title).
  final String initialName;

  ActivityBuilderArgs get _args =>
      ActivityBuilderArgs(typeId: typeId, initialName: initialName);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final builder = ref.watch(activityBuilderProvider(_args));
    final dirty = builder.value?.isDirty ?? false;
    return PopScope(
      canPop: !dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await confirmDiscard(context) && context.mounted) {
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
          onRetry: () => ref.invalidate(activityBuilderProvider(_args)),
          data: (state) => _BuilderBody(args: _args, state: state),
        ),
      ),
    );
  }
}

class _BuilderBody extends ConsumerWidget {
  const _BuilderBody({required this.args, required this.state});

  final ActivityBuilderArgs args;
  final ActivityBuilderState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(activityBuilderProvider(args).notifier);
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
                  size: AppSizes.badgeLarge,
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
            // What you record comes first; how it looks after (A27).
            SectionHeader(
              title: l10n.fieldsSectionTitle,
              subtitle: l10n.fieldsSectionHint,
            ),
            _FieldList(args: args, state: state),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(AppIcons.add),
                label: Text(l10n.addField),
                onPressed: () => _addField(context, notifier),
              ),
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
      initial: newFieldDefinition(type),
    );
    if (result case FieldSaved(:final definition)) {
      notifier.addField(definition);
    }
  }

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final id = await ref.read(activityBuilderProvider(args).notifier).save();
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
  const _FieldList({required this.args, required this.state});

  final ActivityBuilderArgs args;
  final ActivityBuilderState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(activityBuilderProvider(args).notifier);
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
                    size: AppSizes.iconSmall,
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
                lockedFieldIds: state.lockedFieldIds,
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

/// A dozen suggested icons, plus the chosen one, with "More icons" for the
/// rest (A27). Each reads its name to a screen reader (A25).
class _IconPicker extends StatefulWidget {
  const _IconPicker({
    required this.selected,
    required this.colorKey,
    required this.onSelected,
  });

  /// How many icons show before "More icons".
  static const suggested = 12;

  final String selected;
  final String colorKey;
  final ValueChanged<String> onSelected;

  @override
  State<_IconPicker> createState() => _IconPickerState();
}

class _IconPickerState extends State<_IconPicker> {
  bool _all = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.tokens.activity(
      ActivityColorKey.fromName(widget.colorKey) ?? ActivityColorKey.slate,
    );
    final first = ActivityIconIds.all.take(_IconPicker.suggested).toList();
    final shown = _all
        ? ActivityIconIds.all
        : [...first, if (!first.contains(widget.selected)) widget.selected];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final id in shown)
              Semantics(
                label: activityIconLabel(l10n, id),
                selected: id == widget.selected,
                button: true,
                excludeSemantics: true,
                child: InkWell(
                  borderRadius: AppRadius.mdAll,
                  onTap: () => widget.onSelected(id),
                  child: Container(
                    width: AppSizes.touchTarget,
                    height: AppSizes.touchTarget,
                    decoration: BoxDecoration(
                      color: id == widget.selected ? colors.soft : null,
                      borderRadius: AppRadius.mdAll,
                      border: id == widget.selected
                          ? Border.all(
                              color: colors.solid,
                              width: AppSizes.selectionRing,
                            )
                          : null,
                    ),
                    child: Icon(
                      ActivityIconRegistry.resolve(id),
                      color: id == widget.selected
                          ? colors.solid
                          : context.colors.textSecondary,
                    ),
                  ),
                ),
              ),
          ],
        ),
        TextButton(
          onPressed: () => setState(() => _all = !_all),
          child: Text(_all ? l10n.builderFewerIcons : l10n.builderMoreIcons),
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
            label: activityColorLabel(AppLocalizations.of(context), key),
            selected: key.name == selected,
            button: true,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => onSelected(key.name),
              child: Container(
                width: AppSizes.touchTarget,
                height: AppSizes.touchTarget,
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: key.name == selected
                      ? Border.all(
                          color: context.colors.textPrimary,
                          width: AppSizes.selectionRing,
                        )
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
    final type = _previewType(widget.state);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceBase,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: context.colors.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ActivityLogFormFields(
          type: type,
          fields: type.activeFields,
          values: _values,
          onChanged: (id, value) => setState(
            () => value == null ? _values.remove(id) : _values[id] = value,
          ),
        ),
      ),
    );
  }
}

/// A throwaway type for the preview: draft fields (and sub-fields) with
/// placeholder IDs until they are saved.
ActivityType _previewType(ActivityBuilderState state) => previewType(
  name: state.name,
  iconId: state.iconId,
  colorKey: state.colorKey,
  supportsTimer: state.supportsTimer,
  supportsPlanning: state.supportsPlanning,
  fields: [for (final f in state.fields) (f.definition, f.key)],
);
