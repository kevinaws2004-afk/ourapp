import 'package:flutter/material.dart';

import '../../../../core/design/app_icons.dart';
import '../../../../core/design/context_ext.dart';
import '../../../../core/design/tokens/spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../activity_types/domain/activity_ids.dart';
import '../../../activity_types/domain/activity_type.dart';
import '../../../activity_types/domain/field_config.dart';
import '../../domain/field_value.dart';

/// Yes/No editor. Tapping the selected answer again clears it.
class BooleanValueEditor extends StatelessWidget {
  const BooleanValueEditor({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final BooleanValue? value;
  final ValueChanged<FieldValue?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        for (final (answer, label) in [
          (true, l10n.booleanYes),
          (false, l10n.booleanNo),
        ])
          ChoiceChip(
            label: Text(label),
            selected: value?.value == answer,
            onSelected: (_) =>
                onChanged(value?.value == answer ? null : BooleanValue(answer)),
          ),
      ],
    );
  }
}

/// Single choice: archived options appear only if already selected.
class SingleSelectValueEditor extends StatelessWidget {
  const SingleSelectValueEditor({
    super.key,
    required this.field,
    required this.value,
    required this.onChanged,
  });

  final ActivityField field;
  final SingleSelectValue? value;
  final ValueChanged<FieldValue?> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = (field.config as SelectFieldConfig).options;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final option in options)
          if (!option.archived || value?.optionId == option.id)
            ChoiceChip(
              label: Text(option.label),
              selected: value?.optionId == option.id,
              onSelected: (_) => onChanged(
                value?.optionId == option.id
                    ? null
                    : SingleSelectValue(option.id),
              ),
            ),
      ],
    );
  }
}

class MultiSelectValueEditor extends StatelessWidget {
  const MultiSelectValueEditor({
    super.key,
    required this.field,
    required this.value,
    required this.onChanged,
  });

  final ActivityField field;
  final MultiSelectValue? value;
  final ValueChanged<FieldValue?> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = (field.config as SelectFieldConfig).options;
    final selected = value?.optionIds ?? const <SelectOptionId>[];
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final option in options)
          if (!option.archived || selected.contains(option.id))
            FilterChip(
              label: Text(option.label),
              selected: selected.contains(option.id),
              onSelected: (isSelected) {
                final next = isSelected
                    ? [...selected, option.id]
                    : selected.where((id) => id != option.id).toList();
                onChanged(next.isEmpty ? null : MultiSelectValue(next));
              },
            ),
      ],
    );
  }
}

/// Stars on the field's scale; tapping the current rating clears it.
class RatingValueEditor extends StatelessWidget {
  const RatingValueEditor({
    super.key,
    required this.field,
    required this.value,
    required this.onChanged,
  });

  final ActivityField field;
  final RatingValue? value;
  final ValueChanged<FieldValue?> onChanged;

  @override
  Widget build(BuildContext context) {
    final max = (field.config as RatingFieldConfig).max;
    final stars = value?.stars ?? 0;
    return Wrap(
      children: [
        for (var i = 1; i <= max; i++)
          IconButton(
            tooltip: '$i/$max',
            icon: Icon(
              i <= stars ? AppIcons.ratingFull : AppIcons.ratingEmpty,
              color: i <= stars
                  ? context.colors.accentDawn
                  : context.colors.textTertiary,
            ),
            onPressed: () => onChanged(i == stars ? null : RatingValue(i)),
          ),
      ],
    );
  }
}
