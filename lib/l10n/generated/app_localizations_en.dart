// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OurApp';

  @override
  String get navToday => 'Today';

  @override
  String get navPlan => 'Plan';

  @override
  String get navInsights => 'Insights';

  @override
  String get navMe => 'Me';

  @override
  String get todayPlaceholder =>
      'Your plan for today and what actually happened will appear here.';

  @override
  String get trackPlaceholder => 'The activities you track will appear here.';

  @override
  String get insightsPlaceholder => 'Your progress over time will appear here.';

  @override
  String get mePlaceholder =>
      'Body measurements and preferences will appear here.';

  @override
  String get onboardingTitle => 'Welcome';

  @override
  String get onboardingBody =>
      'Plan your day, record what you actually do, and see your progress over time. Your data stays on this device.';

  @override
  String get onboardingStart => 'Get started';

  @override
  String get startupFailureTitle => 'We couldn\'t open your data';

  @override
  String get startupFailureBody =>
      'Nothing has been changed or deleted. Please try again. If this keeps happening, restart the app.';

  @override
  String get startupFailureRetry => 'Try again';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionUndo => 'Undo';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionClear => 'Clear';

  @override
  String get actionTryAgain => 'Try again';

  @override
  String get actionDiscard => 'Discard';

  @override
  String get actionKeepEditing => 'Keep editing';

  @override
  String get discardChangesTitle => 'Discard your changes?';

  @override
  String get discardChangesMessage =>
      'What you\'ve entered here hasn\'t been saved.';

  @override
  String get notSet => 'Not set';

  @override
  String get newActivity => 'New activity';

  @override
  String get fromTemplate => 'Start from a template';

  @override
  String activityFieldCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fields',
      one: '1 field',
      zero: 'No extra fields',
    );
    return '$_temp0';
  }

  @override
  String activityArchived(String name) {
    return '$name deleted';
  }

  @override
  String get recentEntries => 'Recent records';

  @override
  String get noEntriesYet =>
      'Nothing recorded yet. Record it to start this history.';

  @override
  String get builderNewTitle => 'New activity';

  @override
  String get builderEditTitle => 'Edit activity';

  @override
  String get activityNameLabel => 'Name';

  @override
  String get activityNameHint => 'e.g. Reading';

  @override
  String get activityDescriptionLabel => 'Description (optional)';

  @override
  String get iconLabel => 'Icon';

  @override
  String get colorLabel => 'Color';

  @override
  String get fieldsSectionTitle => 'What do you want to record?';

  @override
  String get fieldsSectionHint =>
      'Every entry already records when it happened, how long it took, and notes.';

  @override
  String get addField => 'Add field';

  @override
  String get optionsSectionTitle => 'Options';

  @override
  String get supportsTimerLabel => 'Can be timed';

  @override
  String get supportsTimerHint => 'Use a timer to record how long it took.';

  @override
  String get supportsPlanningLabel => 'Can be planned';

  @override
  String get previewSectionTitle => 'Preview';

  @override
  String get requiredBadge => 'Required';

  @override
  String get lockedFieldHint =>
      'This field already has entries, so its type can\'t change.';

  @override
  String fieldRemoved(String name) {
    return '$name (removed)';
  }

  @override
  String get fieldTypePickerTitle => 'Choose a field type';

  @override
  String get fieldTypeText => 'Text';

  @override
  String get fieldTypeTextDescription =>
      'Words, a short note or a long description';

  @override
  String get fieldTypeNumber => 'Number';

  @override
  String get fieldTypeNumberDescription =>
      'Counts or amounts, optionally with a unit like kg or km';

  @override
  String get fieldTypeBoolean => 'Yes / No';

  @override
  String get fieldTypeBooleanDescription =>
      'Something that did or didn\'t happen';

  @override
  String get fieldTypeSingleSelect => 'Single choice';

  @override
  String get fieldTypeSingleSelectDescription =>
      'Pick one option from your list';

  @override
  String get fieldTypeMultiSelect => 'Multiple choice';

  @override
  String get fieldTypeMultiSelectDescription =>
      'Pick any options from your list';

  @override
  String get fieldTypeDate => 'Date';

  @override
  String get fieldTypeDateDescription => 'A calendar date';

  @override
  String get fieldTypeTime => 'Time';

  @override
  String get fieldTypeTimeDescription => 'A time of day';

  @override
  String get fieldTypeDuration => 'Duration';

  @override
  String get fieldTypeDurationDescription =>
      'An amount of time, like rest or practice time';

  @override
  String get fieldTypeRating => 'Rating';

  @override
  String get fieldTypeRatingDescription => 'Stars on a scale you choose';

  @override
  String get fieldTypeRepeatingGroup => 'Repeating group';

  @override
  String get fieldTypeRepeatingGroupDescription =>
      'A list of items, like exercises or sets';

  @override
  String get availableLater => 'Coming soon';

  @override
  String get fieldEditorNewTitle => 'New field';

  @override
  String get fieldEditorEditTitle => 'Edit field';

  @override
  String get fieldNameLabel => 'Field name';

  @override
  String get requiredLabel => 'Required';

  @override
  String get measurableLabel => 'Show in insights';

  @override
  String get multilineLabel => 'Multiple lines';

  @override
  String get decimalsLabel => 'Decimal places';

  @override
  String get minimumLabel => 'Minimum';

  @override
  String get maximumLabel => 'Maximum';

  @override
  String get unitDimensionLabel => 'Measured in';

  @override
  String get unitNone => 'No unit';

  @override
  String get dimensionMass => 'Weight';

  @override
  String get dimensionDistance => 'Distance';

  @override
  String get dimensionVolume => 'Volume';

  @override
  String get dimensionTemperature => 'Temperature';

  @override
  String get dimensionEnergy => 'Energy';

  @override
  String get defaultUnitLabel => 'Default unit';

  @override
  String get optionsLabel => 'Options';

  @override
  String get addOption => 'Add option';

  @override
  String get optionHint => 'Option name';

  @override
  String get ratingScaleLabel => 'Scale';

  @override
  String get removeField => 'Remove field';

  @override
  String get doneAction => 'Done';

  @override
  String get whenLabel => 'When';

  @override
  String get durationLabel => 'Duration';

  @override
  String get hoursShort => 'h';

  @override
  String get minutesShort => 'min';

  @override
  String get notesLabel => 'Notes';

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get booleanYes => 'Yes';

  @override
  String get booleanNo => 'No';

  @override
  String get repeatingGroupUnavailable =>
      'Repeating groups arrive in a later update.';

  @override
  String get templatesTitle => 'Start from a template';

  @override
  String get templatesSubtitle =>
      'Templates are just a starting point. You can change everything afterwards.';

  @override
  String get templateReading => 'Reading';

  @override
  String get templateReadingBook => 'Book';

  @override
  String get templateReadingPages => 'Pages';

  @override
  String get templateReadingRating => 'Rating';

  @override
  String get templateFocusedWork => 'Focused work';

  @override
  String get templateFocusedWorkProject => 'Project';

  @override
  String get templateWalking => 'Walking';

  @override
  String get templateWalkingDistance => 'Distance';

  @override
  String get templateWalkingSteps => 'Steps';

  @override
  String get templateWalkingCalories => 'Calories';

  @override
  String get templateWalkingLocation => 'Location';

  @override
  String get templateLanguage => 'Language learning';

  @override
  String get templateLanguageLanguage => 'Language';

  @override
  String get templateLanguageWords => 'Words learned';

  @override
  String get templateLanguageLesson => 'Lesson';

  @override
  String get templateLanguageDifficulty => 'Difficulty';

  @override
  String get templateLanguageSpanish => 'Spanish';

  @override
  String get templateLanguageFrench => 'French';

  @override
  String get templateLanguageGerman => 'German';

  @override
  String get templateLanguageJapanese => 'Japanese';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorStorage =>
      'Couldn\'t save your changes. Nothing was lost; please try again.';

  @override
  String get errorNotFound => 'This item no longer exists.';

  @override
  String get errorUnsupported =>
      'This was created by a newer version of the app.';

  @override
  String get errorValidation => 'Some details need attention.';

  @override
  String get loadErrorMessage => 'We couldn\'t load this. Please try again.';

  @override
  String get validationRequired => 'This is required.';

  @override
  String get validationNameRequired => 'Please enter a name.';

  @override
  String get validationNameTooLong => 'That name is too long.';

  @override
  String get validationDuplicateFieldName =>
      'Another field already has this name.';

  @override
  String get validationUnknownIcon => 'Please choose an icon.';

  @override
  String get validationUnknownColor => 'Please choose a color.';

  @override
  String get validationTextTooLong => 'This is too long.';

  @override
  String get validationNotANumber => 'Please enter a number.';

  @override
  String get validationBelowMinimum => 'This is below the minimum.';

  @override
  String get validationAboveMaximum => 'This is above the maximum.';

  @override
  String get validationTooManyDecimals => 'Too many decimal places.';

  @override
  String get validationUnitRequired => 'Please choose a unit.';

  @override
  String get validationUnitNotAllowed => 'This field doesn\'t use units.';

  @override
  String get validationUnknownOption => 'That option doesn\'t exist anymore.';

  @override
  String get validationArchivedOption => 'That option has been retired.';

  @override
  String get validationDuplicateOption => 'Options need different names.';

  @override
  String get validationOptionLabelRequired => 'Options need a name.';

  @override
  String get validationOptionsRequired => 'Add at least one option.';

  @override
  String get validationRatingOutOfRange => 'Choose a rating on the scale.';

  @override
  String get validationInvalidRatingScale =>
      'The scale must be between 3 and 10.';

  @override
  String get validationInvalidMinMax =>
      'The minimum must not be more than the maximum.';

  @override
  String get validationNegativeDuration => 'Duration can\'t be negative.';

  @override
  String get validationDurationExceedsElapsed =>
      'Duration can\'t be longer than the time between start and end.';

  @override
  String get validationEndBeforeStart => 'The end can\'t be before the start.';

  @override
  String get validationFieldSemanticsLocked =>
      'This field has entries, so its type can\'t change. Add a new field instead.';

  @override
  String get validationFieldTypeNotSupportedYet =>
      'This field type isn\'t available yet.';

  @override
  String get validationInvalidDate => 'Please choose a valid date.';

  @override
  String get validationInvalidTime => 'Please choose a valid time.';

  @override
  String get validationUnknownField =>
      'This field is no longer part of the activity.';

  @override
  String get validationValueTypeMismatch =>
      'This value doesn\'t fit the field.';

  @override
  String get actionRecord => 'Record';

  @override
  String recordNewTitle(String name) {
    return 'Record $name';
  }

  @override
  String get recordEditTitle => 'Edit record';

  @override
  String get recordSaved => 'Saved';

  @override
  String get recordDeleted => 'Record deleted';

  @override
  String get activitiesTitle => 'Activities';

  @override
  String get activitiesSubtitle =>
      'The reusable activities you plan and record.';

  @override
  String get activitiesEmptyTitle => 'No activities yet';

  @override
  String get activitiesEmptyMessage =>
      'Build an activity that records exactly what matters to you, or start from a template.';

  @override
  String get meActivitiesSubtitle => 'Create and configure what you record';

  @override
  String get quickRecordTitle => 'What did you do?';

  @override
  String get quickRecordEmpty =>
      'Create an activity first, then record it here.';

  @override
  String get planToday => 'Today';

  @override
  String get planTomorrow => 'Tomorrow';

  @override
  String get planYesterday => 'Yesterday';

  @override
  String get planChooseDate => 'Choose a date';

  @override
  String get planPreviousWeek => 'Previous week';

  @override
  String get planNextWeek => 'Next week';

  @override
  String get planPlannedSection => 'Planned';

  @override
  String get planPlannedEmpty => 'Nothing planned for this day.';

  @override
  String get planRecordedSection => 'Recorded';

  @override
  String get planRecordedEmpty => 'Nothing recorded on this day.';
}
