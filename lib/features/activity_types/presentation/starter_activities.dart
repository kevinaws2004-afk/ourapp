import '../../../core/units/unit_registry.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/activity_ids.dart';
import '../domain/activity_type_definition.dart';
import '../domain/field_config.dart';
import '../domain/field_type.dart';

/// The first built-in activities (data_architecture.md §9): plain data,
/// localized here because their names become the user's own editable content
/// once used. Option IDs are placeholders; using one assigns fresh UUIDv7
/// IDs. No code may treat one specially. The list of activities shows them
/// with the everyday ones, by category (`activityCategories`).
List<ActivityTypeDefinition> starterActivities(AppLocalizations l10n) => [
  ActivityTypeDefinition(
    name: l10n.builtInReading,
    iconId: 'book-open',
    colorKey: 'sky',
    supportsTimer: true,
    fields: [
      FieldDefinition(
        name: l10n.builtInReadingBook,
        type: FieldType.text,
        config: const TextFieldConfig(),
      ),
      FieldDefinition(
        name: l10n.builtInReadingPages,
        type: FieldType.number,
        config: const NumberFieldConfig(min: 0),
        measurable: true,
      ),
      FieldDefinition(
        name: l10n.builtInReadingRating,
        type: FieldType.rating,
        config: const RatingFieldConfig(),
        measurable: true,
      ),
    ],
  ),
  ActivityTypeDefinition(
    name: l10n.builtInFocusedWork,
    iconId: 'laptop',
    colorKey: 'lilac',
    supportsTimer: true,
    fields: [
      FieldDefinition(
        name: l10n.builtInFocusedWorkProject,
        type: FieldType.text,
        config: const TextFieldConfig(),
      ),
    ],
  ),
  ActivityTypeDefinition(
    name: l10n.builtInWalking,
    iconId: 'person-simple-walk',
    colorKey: 'teal',
    supportsTimer: true,
    fields: [
      FieldDefinition(
        name: l10n.builtInWalkingDistance,
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
        name: l10n.builtInWalkingSteps,
        type: FieldType.number,
        config: const NumberFieldConfig(min: 0),
        measurable: true,
      ),
      FieldDefinition(
        name: l10n.builtInWalkingCalories,
        type: FieldType.number,
        dimension: Dimension.energy,
        config: const NumberFieldConfig(min: 0, defaultUnitCode: 'kcal'),
        measurable: true,
      ),
      FieldDefinition(
        name: l10n.builtInWalkingLocation,
        type: FieldType.text,
        config: const TextFieldConfig(),
      ),
    ],
  ),
  ActivityTypeDefinition(
    name: l10n.builtInLanguage,
    iconId: 'translate',
    colorKey: 'coral',
    supportsTimer: true,
    fields: [
      FieldDefinition(
        name: l10n.builtInLanguageLanguage,
        type: FieldType.singleSelect,
        config: SelectFieldConfig(
          options: [
            for (final (i, label) in [
              l10n.builtInLanguageSpanish,
              l10n.builtInLanguageFrench,
              l10n.builtInLanguageGerman,
              l10n.builtInLanguageJapanese,
            ].indexed)
              SelectOption(id: SelectOptionId('option-$i'), label: label),
          ],
        ),
      ),
      FieldDefinition(
        name: l10n.builtInLanguageWords,
        type: FieldType.number,
        config: const NumberFieldConfig(min: 0),
        measurable: true,
      ),
      FieldDefinition(
        name: l10n.builtInLanguageLesson,
        type: FieldType.text,
        config: const TextFieldConfig(),
      ),
      FieldDefinition(
        name: l10n.builtInLanguageDifficulty,
        type: FieldType.rating,
        config: const RatingFieldConfig(),
        measurable: true,
      ),
    ],
  ),
  ActivityTypeDefinition(
    name: l10n.builtInGym,
    iconId: 'barbell',
    colorKey: 'coral',
    supportsTimer: true,
    fields: [
      // What the session trained, §18: a choice, not an empty text box (A12).
      FieldDefinition(
        name: l10n.builtInGymFocus,
        type: FieldType.singleSelect,
        config: SelectFieldConfig(
          options: [
            for (final (i, label) in [
              l10n.builtInGymPush,
              l10n.builtInGymPull,
              l10n.builtInGymLegs,
              l10n.builtInGymUpperBody,
              l10n.builtInGymLowerBody,
              l10n.builtInGymFullBody,
              l10n.builtInGymCardio,
            ].indexed)
              SelectOption(id: SelectOptionId('option-$i'), label: label),
          ],
        ),
      ),
      FieldDefinition(
        name: l10n.builtInGymExercises,
        type: FieldType.repeatingGroup,
        config: RepeatingGroupFieldConfig(
          itemLabel: l10n.builtInGymExerciseItem,
        ),
        subFields: [
          FieldDefinition(
            name: l10n.builtInGymExercise,
            type: FieldType.text,
            required: true,
            config: const TextFieldConfig(suggestFromHistory: true),
          ),
          FieldDefinition(
            name: l10n.builtInGymSets,
            type: FieldType.repeatingGroup,
            config: RepeatingGroupFieldConfig(
              itemLabel: l10n.builtInGymSetItem,
            ),
            subFields: [
              FieldDefinition(
                name: l10n.builtInGymWeight,
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
                name: l10n.builtInGymReps,
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
    name: l10n.builtInMeeting,
    iconId: 'users-three',
    colorKey: 'slate',
    supportsTimer: true,
    fields: [
      FieldDefinition(
        name: l10n.builtInMeetingPeople,
        type: FieldType.text,
        config: const TextFieldConfig(),
      ),
      FieldDefinition(
        name: l10n.builtInMeetingTopics,
        type: FieldType.text,
        config: const TextFieldConfig(multiline: true),
      ),
      FieldDefinition(
        name: l10n.builtInMeetingDecisions,
        type: FieldType.text,
        config: const TextFieldConfig(multiline: true),
      ),
      FieldDefinition(
        name: l10n.builtInMeetingActionItems,
        type: FieldType.repeatingGroup,
        config: RepeatingGroupFieldConfig(
          itemLabel: l10n.builtInMeetingActionItem,
        ),
        subFields: [
          FieldDefinition(
            name: l10n.builtInMeetingActionItemText,
            type: FieldType.text,
            required: true,
            config: const TextFieldConfig(),
          ),
          FieldDefinition(
            name: l10n.builtInMeetingActionItemDone,
            type: FieldType.boolean,
            config: const BooleanFieldConfig(),
          ),
        ],
      ),
    ],
  ),
  ActivityTypeDefinition(
    name: l10n.builtInCooking,
    iconId: 'cooking-pot',
    colorKey: 'rose',
    supportsTimer: true,
    fields: [
      FieldDefinition(
        name: l10n.builtInCookingRecipe,
        type: FieldType.text,
        config: const TextFieldConfig(suggestFromHistory: true),
      ),
      FieldDefinition(
        name: l10n.builtInCookingServings,
        type: FieldType.number,
        config: const NumberFieldConfig(min: 0),
      ),
      FieldDefinition(
        name: l10n.builtInCookingCalories,
        type: FieldType.number,
        dimension: Dimension.energy,
        config: const NumberFieldConfig(
          min: 0,
          defaultUnitCode: 'kcal',
          better: BetterDirection.neither,
        ),
        measurable: true,
      ),
      FieldDefinition(
        name: l10n.builtInCookingRating,
        type: FieldType.rating,
        config: const RatingFieldConfig(),
        measurable: true,
      ),
      FieldDefinition(
        name: l10n.builtInCookingIngredients,
        type: FieldType.repeatingGroup,
        config: RepeatingGroupFieldConfig(
          itemLabel: l10n.builtInCookingIngredientItem,
        ),
        subFields: [
          FieldDefinition(
            name: l10n.builtInCookingIngredient,
            type: FieldType.text,
            required: true,
            config: const TextFieldConfig(suggestFromHistory: true),
          ),
          FieldDefinition(
            name: l10n.builtInCookingHaveIt,
            type: FieldType.boolean,
            config: const BooleanFieldConfig(),
          ),
        ],
      ),
    ],
  ),
  // Phase B (B8) additions. Body weight lives in Me → Body measurements.
  ActivityTypeDefinition(
    name: l10n.builtInRunning,
    iconId: 'person-simple-run',
    colorKey: 'rose',
    supportsTimer: true,
    fields: [
      FieldDefinition(
        name: l10n.builtInRunningDistance,
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
        name: l10n.builtInRunningRoute,
        type: FieldType.text,
        config: const TextFieldConfig(suggestFromHistory: true),
      ),
      FieldDefinition(
        name: l10n.builtInRunningFelt,
        type: FieldType.rating,
        config: const RatingFieldConfig(),
        measurable: true,
      ),
    ],
  ),
  ActivityTypeDefinition(
    name: l10n.builtInStudy,
    iconId: 'graduation-cap',
    colorKey: 'lilac',
    supportsTimer: true,
    fields: [
      FieldDefinition(
        name: l10n.builtInStudySubject,
        type: FieldType.text,
        config: const TextFieldConfig(suggestFromHistory: true),
      ),
      FieldDefinition(
        name: l10n.builtInStudyCovered,
        type: FieldType.text,
        config: const TextFieldConfig(multiline: true),
      ),
      FieldDefinition(
        name: l10n.builtInStudyFocus,
        type: FieldType.rating,
        config: const RatingFieldConfig(),
        measurable: true,
      ),
    ],
  ),
  ActivityTypeDefinition(
    name: l10n.builtInMeditation,
    iconId: 'flower-lotus',
    colorKey: 'teal',
    supportsTimer: true,
    fields: [
      FieldDefinition(
        name: l10n.builtInMeditationKind,
        type: FieldType.singleSelect,
        config: SelectFieldConfig(
          options: [
            for (final (i, label) in [
              l10n.builtInMeditationBreathing,
              l10n.builtInMeditationBodyScan,
              l10n.builtInMeditationGuided,
              l10n.builtInMeditationSilent,
            ].indexed)
              SelectOption(id: SelectOptionId('option-$i'), label: label),
          ],
        ),
      ),
      FieldDefinition(
        name: l10n.builtInMeditationCalm,
        type: FieldType.rating,
        config: const RatingFieldConfig(),
        measurable: true,
      ),
    ],
  ),
  ActivityTypeDefinition(
    name: l10n.builtInWater,
    iconId: 'drop',
    colorKey: 'sky',
    fields: [
      FieldDefinition(
        name: l10n.builtInWaterGlasses,
        type: FieldType.number,
        config: const NumberFieldConfig(min: 0),
        measurable: true,
      ),
    ],
  ),
  ActivityTypeDefinition(
    name: l10n.builtInSleep,
    iconId: 'bed',
    colorKey: 'slate',
    supportsTimer: true,
    fields: [
      FieldDefinition(
        name: l10n.builtInSleepQuality,
        type: FieldType.rating,
        config: const RatingFieldConfig(),
        measurable: true,
      ),
      FieldDefinition(
        name: l10n.builtInSleepWokeUp,
        type: FieldType.boolean,
        config: const BooleanFieldConfig(),
      ),
    ],
  ),
  ActivityTypeDefinition(
    name: l10n.builtInMood,
    iconId: 'heart',
    colorKey: 'rose',
    fields: [
      FieldDefinition(
        name: l10n.builtInMoodRating,
        type: FieldType.rating,
        config: const RatingFieldConfig(),
        measurable: true,
      ),
      FieldDefinition(
        name: l10n.builtInMoodFeelings,
        type: FieldType.multiSelect,
        config: SelectFieldConfig(
          options: [
            for (final (i, label) in [
              l10n.builtInMoodCalm,
              l10n.builtInMoodHappy,
              l10n.builtInMoodEnergetic,
              l10n.builtInMoodTired,
              l10n.builtInMoodStressed,
              l10n.builtInMoodAnxious,
            ].indexed)
              SelectOption(id: SelectOptionId('option-$i'), label: label),
          ],
        ),
      ),
    ],
  ),
];
