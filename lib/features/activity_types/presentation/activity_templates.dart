import '../../../core/units/unit_registry.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/activity_ids.dart';
import '../domain/activity_type_definition.dart';
import '../domain/field_config.dart';
import '../domain/field_type.dart';

/// Starter templates (data_architecture.md §9): plain data, localized here
/// because their names become the user's own editable content once added.
/// Option IDs are placeholders; installing assigns fresh UUIDv7 IDs. No code
/// may treat a template-derived type specially.
List<ActivityTypeDefinition> activityTemplates(AppLocalizations l10n) => [
  ActivityTypeDefinition(
    name: l10n.templateReading,
    iconId: 'book-open',
    colorKey: 'sky',
    supportsTimer: true,
    fields: [
      FieldDefinition(
        name: l10n.templateReadingBook,
        type: FieldType.text,
        config: const TextFieldConfig(),
      ),
      FieldDefinition(
        name: l10n.templateReadingPages,
        type: FieldType.number,
        config: const NumberFieldConfig(min: 0),
        measurable: true,
      ),
      FieldDefinition(
        name: l10n.templateReadingRating,
        type: FieldType.rating,
        config: const RatingFieldConfig(),
        measurable: true,
      ),
    ],
  ),
  ActivityTypeDefinition(
    name: l10n.templateFocusedWork,
    iconId: 'laptop',
    colorKey: 'lilac',
    supportsTimer: true,
    fields: [
      FieldDefinition(
        name: l10n.templateFocusedWorkProject,
        type: FieldType.text,
        config: const TextFieldConfig(),
      ),
    ],
  ),
  ActivityTypeDefinition(
    name: l10n.templateWalking,
    iconId: 'person-simple-walk',
    colorKey: 'sage',
    supportsTimer: true,
    fields: [
      FieldDefinition(
        name: l10n.templateWalkingDistance,
        type: FieldType.number,
        dimension: Dimension.distance,
        config: const NumberFieldConfig(
          decimals: 2,
          min: 0,
          defaultUnitCode: 'km',
        ),
        measurable: true,
      ),
      FieldDefinition(
        name: l10n.templateWalkingSteps,
        type: FieldType.number,
        config: const NumberFieldConfig(min: 0),
        measurable: true,
      ),
      FieldDefinition(
        name: l10n.templateWalkingCalories,
        type: FieldType.number,
        dimension: Dimension.energy,
        config: const NumberFieldConfig(min: 0, defaultUnitCode: 'kcal'),
        measurable: true,
      ),
      FieldDefinition(
        name: l10n.templateWalkingLocation,
        type: FieldType.text,
        config: const TextFieldConfig(),
      ),
    ],
  ),
  ActivityTypeDefinition(
    name: l10n.templateLanguage,
    iconId: 'translate',
    colorKey: 'apricot',
    supportsTimer: true,
    fields: [
      FieldDefinition(
        name: l10n.templateLanguageLanguage,
        type: FieldType.singleSelect,
        config: SelectFieldConfig(
          options: [
            for (final (i, label) in [
              l10n.templateLanguageSpanish,
              l10n.templateLanguageFrench,
              l10n.templateLanguageGerman,
              l10n.templateLanguageJapanese,
            ].indexed)
              SelectOption(
                id: SelectOptionId('template-option-$i'),
                label: label,
              ),
          ],
        ),
      ),
      FieldDefinition(
        name: l10n.templateLanguageWords,
        type: FieldType.number,
        config: const NumberFieldConfig(min: 0),
        measurable: true,
      ),
      FieldDefinition(
        name: l10n.templateLanguageLesson,
        type: FieldType.text,
        config: const TextFieldConfig(),
      ),
      FieldDefinition(
        name: l10n.templateLanguageDifficulty,
        type: FieldType.rating,
        config: const RatingFieldConfig(),
        measurable: true,
      ),
    ],
  ),
];
