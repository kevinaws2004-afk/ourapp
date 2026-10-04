import 'package:flutter/material.dart';

import '../../../../core/design/app_icons.dart';
import '../../../../core/design/context_ext.dart';
import '../../../../core/design/tokens/spacing.dart';
import '../../../../core/units/unit_registry.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../activity_types/domain/activity_type_definition.dart';
import '../../../activity_types/domain/activity_type_validator.dart';
import '../../../activity_types/domain/field_config.dart';
import '../../../activity_types/domain/field_type.dart';
import '../../../activity_types/presentation/builder/field_editor_sheet.dart';
import '../../../activity_types/presentation/field_type_copy.dart';

/// "What do you want to log?" (ADR-035): ready-made shapes in one tap, or one
/// thing of any kind, named and configured in the field sheet. [depth] is how
/// many lists the new thing sits inside (0 = top level); lists can't nest
/// deeper than the activity validator allows. Returns the new field, or null.
Future<FieldDefinition?> showAddToLogSheet(
  BuildContext context, {
  int depth = 0,
}) async {
  final choice = await showModalBottomSheet<Object>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _AddToLogSheet(depth: depth),
  );
  if (choice is FieldDefinition || choice == null || !context.mounted) {
    return choice as FieldDefinition?;
  }
  final result = await showFieldEditor(
    context,
    initial: newFieldDefinition(choice as FieldType),
    isNew: true,
    depth: depth,
  );
  return result is FieldSaved ? result.definition : null;
}

bool _canNestList(int depth) => depth < ActivityTypeValidator.maxGroupDepth;

/// Ready-made shapes: plain data, like the starter templates. Nothing about
/// them is special once added.
List<(String, String, IconData, FieldDefinition)> _readyMade(
  AppLocalizations l10n,
  int depth,
) => [
  if (depth + 1 < ActivityTypeValidator.maxGroupDepth)
    (
      l10n.shapeSetsReps,
      l10n.shapeSetsRepsDescription,
      AppIcons.fieldRepeatingGroup,
      FieldDefinition(
        name: l10n.templateGymExercises,
        type: FieldType.repeatingGroup,
        config: RepeatingGroupFieldConfig(
          itemLabel: l10n.templateGymExerciseItem,
        ),
        subFields: [
          FieldDefinition(
            name: l10n.templateGymExercise,
            type: FieldType.text,
            config: const TextFieldConfig(suggestFromHistory: true),
          ),
          FieldDefinition(
            name: l10n.templateGymSets,
            type: FieldType.repeatingGroup,
            config: RepeatingGroupFieldConfig(
              itemLabel: l10n.templateGymSetItem,
            ),
            subFields: [
              FieldDefinition(
                name: l10n.templateGymWeight,
                type: FieldType.number,
                dimension: Dimension.mass,
                config: const NumberFieldConfig(
                  decimals: 2,
                  min: 0,
                  defaultUnitCode: 'kg',
                ),
                measurable: true,
              ),
              FieldDefinition(
                name: l10n.templateGymReps,
                type: FieldType.number,
                config: const NumberFieldConfig(min: 0),
                measurable: true,
              ),
            ],
          ),
        ],
      ),
    ),
  if (_canNestList(depth))
    (
      l10n.shapeChecklist,
      l10n.shapeChecklistDescription,
      AppIcons.template,
      FieldDefinition(
        name: l10n.shapeChecklist,
        type: FieldType.repeatingGroup,
        config: RepeatingGroupFieldConfig(itemLabel: l10n.shapeChecklistItem),
        subFields: [
          FieldDefinition(
            name: l10n.shapeChecklistItem,
            type: FieldType.text,
            config: const TextFieldConfig(),
          ),
          FieldDefinition(
            name: l10n.shapeChecklistDone,
            type: FieldType.boolean,
            config: const BooleanFieldConfig(),
          ),
        ],
      ),
    ),
];

class _AddToLogSheet extends StatelessWidget {
  const _AddToLogSheet({required this.depth});

  final int depth;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final readyMade = _readyMade(l10n, depth);
    final types = [
      for (final type in FieldType.values)
        if (type != FieldType.repeatingGroup || _canNestList(depth)) type,
    ];
    final heading = context.textStyles.labelLarge?.copyWith(
      color: context.colors.textSecondary,
    );
    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(l10n.itemAddToLogTitle, style: context.textStyles.titleLarge),
            if (readyMade.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.itemAddReadyMade, style: heading),
              for (final (title, description, icon, field) in readyMade)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(icon),
                  title: Text(title),
                  subtitle: Text(description),
                  onTap: () => Navigator.of(context).pop(field),
                ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.itemAddOneThing, style: heading),
            for (final type in types)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(type.icon),
                title: Text(type.label(l10n)),
                subtitle: Text(type.description(l10n)),
                onTap: () => Navigator.of(context).pop(type),
              ),
          ],
        ),
      ),
    );
  }
}
