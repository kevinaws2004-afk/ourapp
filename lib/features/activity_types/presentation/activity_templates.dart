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
    colorKey: 'teal',
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
    colorKey: 'coral',
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
  ActivityTypeDefinition(
    name: l10n.templateGym,
    iconId: 'barbell',
    colorKey: 'coral',
    supportsTimer: true,
    fields: [
      // What the session trained, §18: a choice, not an empty text box (A12).
      FieldDefinition(
        name: l10n.templateGymFocus,
        type: FieldType.singleSelect,
        config: SelectFieldConfig(
          options: [
            for (final (i, label) in [
              l10n.templateGymPush,
              l10n.templateGymPull,
              l10n.templateGymLegs,
              l10n.templateGymUpperBody,
              l10n.templateGymLowerBody,
              l10n.templateGymFullBody,
              l10n.templateGymCardio,
            ].indexed)
              SelectOption(
                id: SelectOptionId('template-option-$i'),
                label: label,
              ),
          ],
        ),
      ),
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
            required: true,
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
    ],
  ),
  ActivityTypeDefinition(
    name: l10n.templateMeeting,
    iconId: 'users-three',
    colorKey: 'slate',
    supportsTimer: true,
    fields: [
      FieldDefinition(
        name: l10n.templateMeetingPeople,
        type: FieldType.text,
        config: const TextFieldConfig(),
      ),
      FieldDefinition(
        name: l10n.templateMeetingTopics,
        type: FieldType.text,
        config: const TextFieldConfig(multiline: true),
      ),
      FieldDefinition(
        name: l10n.templateMeetingDecisions,
        type: FieldType.text,
        config: const TextFieldConfig(multiline: true),
      ),
      FieldDefinition(
        name: l10n.templateMeetingActionItems,
        type: FieldType.repeatingGroup,
        config: RepeatingGroupFieldConfig(
          itemLabel: l10n.templateMeetingActionItem,
        ),
        subFields: [
          FieldDefinition(
            name: l10n.templateMeetingActionItemText,
            type: FieldType.text,
            required: true,
            config: const TextFieldConfig(),
          ),
          FieldDefinition(
            name: l10n.templateMeetingActionItemDone,
            type: FieldType.boolean,
            config: const BooleanFieldConfig(),
          ),
        ],
      ),
    ],
  ),
  ActivityTypeDefinition(
    name: l10n.templateCooking,
    iconId: 'cooking-pot',
    colorKey: 'rose',
    supportsTimer: true,
    fields: [
      FieldDefinition(
        name: l10n.templateCookingRecipe,
        type: FieldType.text,
        config: const TextFieldConfig(suggestFromHistory: true),
      ),
      FieldDefinition(
        name: l10n.templateCookingServings,
        type: FieldType.number,
        config: const NumberFieldConfig(min: 0),
      ),
      FieldDefinition(
        name: l10n.templateCookingCalories,
        type: FieldType.number,
        dimension: Dimension.energy,
        config: const NumberFieldConfig(min: 0, defaultUnitCode: 'kcal'),
        measurable: true,
      ),
      FieldDefinition(
        name: l10n.templateCookingRating,
        type: FieldType.rating,
        config: const RatingFieldConfig(),
        measurable: true,
      ),
      FieldDefinition(
        name: l10n.templateCookingIngredients,
        type: FieldType.repeatingGroup,
        config: RepeatingGroupFieldConfig(
          itemLabel: l10n.templateCookingIngredientItem,
        ),
        subFields: [
          FieldDefinition(
            name: l10n.templateCookingIngredient,
            type: FieldType.text,
            required: true,
            config: const TextFieldConfig(suggestFromHistory: true),
          ),
          FieldDefinition(
            name: l10n.templateCookingHaveIt,
            type: FieldType.boolean,
            config: const BooleanFieldConfig(),
          ),
        ],
      ),
    ],
  ),
];
