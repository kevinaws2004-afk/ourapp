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
  String get trackPlaceholder => 'The activities you track will appear here.';

  @override
  String get insightsPlaceholder => 'Your progress over time will appear here.';

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
      'Words, a short note or a long description, like what the doctor said';

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
  String get fieldTypeRepeatingGroup => 'List';

  @override
  String get fieldTypeRepeatingGroupDescription =>
      'Rows with their own details, like exercises → sets, medicines or people';

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
  String get durationLabel => 'Duration';

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
  String get validationDuplicateActivityName =>
      'You already have an activity with this name.';

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
  String get planPlannedEmpty => 'Nothing planned for this day.';

  @override
  String groupItemCount(String itemLabel, int count) {
    return '$itemLabel × $count';
  }

  @override
  String groupItemTitle(String itemLabel, int number) {
    return '$itemLabel $number';
  }

  @override
  String addGroupItem(String itemLabel) {
    return 'Add $itemLabel';
  }

  @override
  String removeGroupItem(String itemLabel) {
    return 'Remove $itemLabel';
  }

  @override
  String get itemLabelLabel => 'Item name';

  @override
  String get itemLabelHelper => 'Shown on the add button, like “Add Set”';

  @override
  String get subFieldsLabel => 'Fields in each item';

  @override
  String get subFieldsEmpty =>
      'Add the fields each item records, like weight and reps.';

  @override
  String get addSubField => 'Add field to item';

  @override
  String get suggestFromHistoryLabel => 'Suggest previous entries';

  @override
  String get suggestFromHistoryHint =>
      'Handy for names you repeat, like exercises';

  @override
  String get validationSubFieldsRequired =>
      'Add at least one field to each item.';

  @override
  String get validationNestingTooDeep =>
      'Groups can only be nested one level deep.';

  @override
  String get validationItemLabelRequired =>
      'Give each item a name, like “Set”.';

  @override
  String get templateGym => 'Gym';

  @override
  String get templateGymExercises => 'Exercises';

  @override
  String get templateGymExerciseItem => 'Exercise';

  @override
  String get templateGymExercise => 'Exercise';

  @override
  String get templateGymSets => 'Sets';

  @override
  String get templateGymSetItem => 'Set';

  @override
  String get templateGymWeight => 'Weight';

  @override
  String get templateGymReps => 'Reps';

  @override
  String get templateMeeting => 'Meeting';

  @override
  String get templateMeetingPeople => 'People';

  @override
  String get templateMeetingTopics => 'Topics';

  @override
  String get templateMeetingDecisions => 'Decisions';

  @override
  String get templateMeetingActionItems => 'Action items';

  @override
  String get templateMeetingActionItem => 'Action item';

  @override
  String get templateMeetingActionItemText => 'Item';

  @override
  String get templateMeetingActionItemDone => 'Done';

  @override
  String get templateCooking => 'Cooking';

  @override
  String get templateCookingRecipe => 'Recipe';

  @override
  String get templateCookingServings => 'Servings';

  @override
  String get templateCookingCalories => 'Calories';

  @override
  String get templateCookingRating => 'Rating';

  @override
  String get templateCookingIngredients => 'Ingredients';

  @override
  String get templateCookingIngredientItem => 'Ingredient';

  @override
  String get templateCookingIngredient => 'Ingredient';

  @override
  String get templateCookingHaveIt => 'Have it';

  @override
  String get planActivityLabel => 'Activity';

  @override
  String get planTaskChoice => 'Just a task';

  @override
  String get planAddAction => 'Add plan';

  @override
  String get planAddTime => 'Set a time';

  @override
  String get planQuickAddHint => 'Add something to this day';

  @override
  String get planAnyTime => 'Any time';

  @override
  String get planNoEnd => 'No end time';

  @override
  String get planStartLabel => 'Start';

  @override
  String get planEndLabel => 'End';

  @override
  String get planDurationLabel => 'How long';

  @override
  String get planNewTitle => 'New plan';

  @override
  String get planEditTitle => 'Plan';

  @override
  String get planTitleLabel => 'Title';

  @override
  String get planTitleHelper =>
      'Optional for an activity: it uses the activity\'s name';

  @override
  String get planCompleteTask => 'Mark as done';

  @override
  String get planReopenTask => 'Mark as not done';

  @override
  String get planSkip => 'Skip';

  @override
  String get planReopen => 'Reopen';

  @override
  String get planMoveToTomorrow => 'Move to tomorrow';

  @override
  String get planDelete => 'Delete';

  @override
  String get planDeletedMessage => 'Deleted';

  @override
  String get planMovedMessage => 'Moved to tomorrow';

  @override
  String get planSkippedMessage => 'Skipped';

  @override
  String get planTaskDoneMessage => 'Done';

  @override
  String get planReorderHandle => 'Reorder';

  @override
  String get planStatusDone => 'Done';

  @override
  String get planStatusRecorded => 'Done';

  @override
  String get planStatusSkipped => 'Skipped';

  @override
  String get planStatusCancelled => 'Cancelled';

  @override
  String get todayGreetingMorning => 'Good morning';

  @override
  String get todayGreetingAfternoon => 'Good afternoon';

  @override
  String get todayGreetingEvening => 'Good evening';

  @override
  String get validationPlannedDurationConflict =>
      'Use either an end time or a length, not both.';

  @override
  String get validationActivityNotPlannable =>
      'This activity can\'t be planned.';

  @override
  String get validationPlanActivityLocked =>
      'This plan already has a record, so its activity can\'t change.';

  @override
  String get validationPlanRecordMismatch =>
      'This plan is for a different activity.';

  @override
  String planRecordedDuration(String duration) {
    return '$duration';
  }

  @override
  String planRecordedOfPlanned(String actual, String planned) {
    return '$actual of $planned';
  }

  @override
  String planTimeRange(String start, String end) {
    return '$start–$end';
  }

  @override
  String get planOptions => 'Plan options';

  @override
  String get planOpenRecordHint => 'open it';

  @override
  String planRecordHint(String title) {
    return 'open $title to log it';
  }

  @override
  String get planPickStart => 'From';

  @override
  String get planPickEnd => 'To (optional)';

  @override
  String get templateGymFocus => 'Workout';

  @override
  String get templateGymPush => 'Push';

  @override
  String get templateGymPull => 'Pull';

  @override
  String get templateGymLegs => 'Legs';

  @override
  String get templateGymUpperBody => 'Upper body';

  @override
  String get templateGymLowerBody => 'Lower body';

  @override
  String get templateGymFullBody => 'Full body';

  @override
  String get templateGymCardio => 'Cardio';

  @override
  String get focusStart => 'Start focus';

  @override
  String get focusPause => 'Pause';

  @override
  String get focusResume => 'Resume';

  @override
  String get focusFinish => 'Finish';

  @override
  String get focusDiscard => 'Discard session';

  @override
  String get focusDiscardTitle => 'Discard this session?';

  @override
  String get focusDiscardMessage => 'The timed session won\'t be recorded.';

  @override
  String get focusPaused => 'Paused';

  @override
  String get focusRunning => 'Focusing';

  @override
  String get focusElapsedLabel => 'Focused time';

  @override
  String get focusReturn => 'Return';

  @override
  String get focusNoneTitle => 'No focus session';

  @override
  String get focusNoneMessage => 'Start one from a plan or an activity.';

  @override
  String get planStatusInProgress => 'In progress';

  @override
  String get validationFocusAlreadyActive =>
      'A focus session is already running.';

  @override
  String get validationActivityHasNoTimer =>
      'This activity doesn\'t use a timer.';

  @override
  String get validationFocusNotActive =>
      'This focus session has already ended.';

  @override
  String focusComplete(String activity, String duration) {
    return '$activity session complete · $duration';
  }

  @override
  String get dimensionPercentage => 'Percentage';

  @override
  String get insightActivitySection => 'Activities';

  @override
  String get insightAddChart => 'Add chart';

  @override
  String get insightEditChart => 'Edit chart';

  @override
  String get insightAggSum => 'total';

  @override
  String get insightAggAverage => 'average';

  @override
  String get insightAggMax => 'best';

  @override
  String get insightAggMin => 'lowest';

  @override
  String get insightAggCount => 'count';

  @override
  String get insightAggLatest => 'latest';

  @override
  String get insightAllActivities => 'All activities';

  @override
  String get insightBucketDay => 'Day';

  @override
  String get insightBucketWeek => 'Week';

  @override
  String get insightBucketMonth => 'Month';

  @override
  String get insightChartBar => 'Bars';

  @override
  String get insightChartLine => 'Line';

  @override
  String get insightChartDeleted => 'Chart deleted';

  @override
  String get insightChartOptions => 'Chart options';

  @override
  String get insightChartTypeLabel => 'Chart';

  @override
  String get insightChartsSection => 'Your own charts';

  @override
  String get insightChartsEmptyTitle => 'Build your first chart';

  @override
  String get insightChartsEmptyMessage =>
      'Chart anything you record: time, how often, any number (like the weight of your sets), volume, body measurements, or planned vs actual.';

  @override
  String get insightChooseActivity => 'Choose an activity';

  @override
  String get insightChooseField => 'Choose';

  @override
  String get insightDelete => 'Delete';

  @override
  String get insightEdit => 'Edit';

  @override
  String get insightFieldLabel => 'Field';

  @override
  String get insightFilterLabel => 'Only where';

  @override
  String get insightFilterValueHint => 'Value, e.g. Chest Press';

  @override
  String get insightGroupByLabel => 'Group by';

  @override
  String get insightGroupLabel => 'Group';

  @override
  String get insightHowLabel => 'Show';

  @override
  String get insightKindBody => 'Body measurement';

  @override
  String get insightKindCount => 'How often';

  @override
  String get insightKindField => 'A field';

  @override
  String get insightKindPlannedVsActual => 'Planned vs actual';

  @override
  String get insightKindTime => 'Time';

  @override
  String get insightKindVolume => 'Volume';

  @override
  String get insightNoActivity => 'Nothing recorded in this period.';

  @override
  String get insightNoData => 'No data in this period yet.';

  @override
  String get insightNoFilter => 'Everything';

  @override
  String get insightNoNumberFields => 'This activity has no number fields.';

  @override
  String get insightNoVolumeGroups =>
      'This activity has no group with two number fields (like weight and reps).';

  @override
  String get insightPlannedVsActualLegend => 'Grey: planned · Colour: recorded';

  @override
  String get insightRangeWeek => 'Week';

  @override
  String get insightRangeMonth => 'Month';

  @override
  String get insightRangeQuarter => '3 months';

  @override
  String get insightRangeYear => 'Year';

  @override
  String get insightTitleLabel => 'Title';

  @override
  String get insightWhatLabel => 'What to chart';

  @override
  String get meMeasurementsSubtitle =>
      'Weight, body fat and other measurements';

  @override
  String get measurementAdd => 'Add measurement';

  @override
  String get measurementDelete => 'Delete measurement';

  @override
  String get measurementDeleted => 'Measurement deleted';

  @override
  String get measurementHistory => 'History';

  @override
  String get measurementNone => 'Nothing recorded yet';

  @override
  String get measurementValue => 'Value';

  @override
  String get measurementsTitle => 'Body measurements';

  @override
  String get measurementsIntro =>
      'Track your body over time. Each one becomes a chart.';

  @override
  String get measurementWeight => 'Weight';

  @override
  String get measurementHeight => 'Height';

  @override
  String get measurementBodyFat => 'Body fat';

  @override
  String get measurementChest => 'Chest';

  @override
  String get measurementWaist => 'Waist';

  @override
  String get measurementArms => 'Arms';

  @override
  String get measurementLegs => 'Legs';

  @override
  String insightChange(String change) {
    return '$change vs previous period';
  }

  @override
  String insightPlannedVsActualSummary(String actual, String planned) {
    return 'Recorded $actual of $planned planned';
  }

  @override
  String insightTimesRecorded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: 'once',
    );
    return '$_temp0';
  }

  @override
  String insightTitleTime(String activity) {
    return '$activity · time';
  }

  @override
  String insightTitleCount(String activity) {
    return '$activity · how often';
  }

  @override
  String insightTitleVolume(String activity) {
    return '$activity · volume';
  }

  @override
  String insightVolumeFormula(String amount, String count) {
    return 'Volume = $amount × $count per item';
  }

  @override
  String get itemSaving => 'Saving…';

  @override
  String get itemSaved => 'Saved';

  @override
  String get itemSaveFailed => 'Not saved yet: check the highlighted fields';

  @override
  String get itemMarkDone => 'Mark done';

  @override
  String get itemDone => 'Done';

  @override
  String get itemStartTimer => 'Start timer';

  @override
  String get itemTimerFullScreen => 'Full screen timer';

  @override
  String get itemWhenSection => 'When';

  @override
  String get itemOptions => 'Item options';

  @override
  String get itemDeleted => 'Deleted';

  @override
  String get itemNothingToLogHint =>
      'Add what you want to log: a number, a list (like exercises → sets), yes/no, a rating… or just write notes.';

  @override
  String get itemTimerOtherRunning => 'Another timer is running';

  @override
  String todayDoneSummary(int count, String duration) {
    return '$count done · $duration';
  }

  @override
  String todayDoneCount(int count) {
    return '$count done';
  }

  @override
  String get todayEmptyMessageItems =>
      'Add what you\'re doing or planning. Open it later to log how it went.';

  @override
  String get itemAddToLog => 'Add to log';

  @override
  String get itemAddToLogTitle => 'What do you want to log?';

  @override
  String get itemAddReadyMade => 'Ready-made';

  @override
  String get itemAddOneThing => 'Or add one thing';

  @override
  String get shapeSetsReps => 'Sets & reps';

  @override
  String get shapeSetsRepsDescription =>
      'Exercises, each with sets of weight × reps';

  @override
  String get shapeChecklist => 'Checklist';

  @override
  String get shapeChecklistDescription =>
      'Items to tick off, like things to buy or do';

  @override
  String get shapeChecklistItem => 'Item';

  @override
  String get shapeChecklistDone => 'Done';

  @override
  String addGroupDetailTo(String item) {
    return 'Add a detail to each $item';
  }

  @override
  String groupListOptions(String item) {
    return '$item list options';
  }

  @override
  String get itemEditFields => 'Edit what\'s logged';

  @override
  String get validationInvalidRepeat =>
      'Choose at least one day, and an end date on or after this one.';

  @override
  String get planRepeat => 'Repeat…';

  @override
  String get planStopRepeating => 'Stop repeating after this';

  @override
  String get planRepeatTitle => 'Repeat';

  @override
  String get planRepeatEvery => 'Every';

  @override
  String planRepeatWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks',
      one: 'week',
    );
    return '$_temp0';
  }

  @override
  String get planRepeatUntil => 'Until';

  @override
  String get planRepeatForever => 'No end';

  @override
  String planRepeatSaved(String days) {
    return 'Repeats $days';
  }

  @override
  String get planRepeatStopped => 'Won\'t repeat after this';

  @override
  String get planRepeating => 'Repeats';

  @override
  String get planNextAction => 'Plan next…';

  @override
  String planNextPlanned(String date) {
    return 'Planned for $date';
  }

  @override
  String get actionOpen => 'Open';

  @override
  String get planViewWeek => 'Week';

  @override
  String get planViewMonth => 'Month';

  @override
  String get planWeekEmptyDay => 'Nothing planned';

  @override
  String get insightAutoTime => 'Time';

  @override
  String get insightAutoCount => 'Times done';

  @override
  String insightAutoBest(String field) {
    return 'Best $field';
  }

  @override
  String insightAutoRowBest(String field, String row) {
    return '$row · best $field';
  }

  @override
  String get insightAutoVolume => 'Volume';

  @override
  String insightAutoRowVolume(String row) {
    return '$row · volume';
  }

  @override
  String insightDaysDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get insightProgressSection => 'Progress';

  @override
  String insightActivityEmpty(String name) {
    return 'Log $name a few times and its progress shows here.';
  }

  @override
  String get insightOpenActivityHint => 'see its progress';

  @override
  String get actionDone => 'Done';

  @override
  String get planStartNow => 'Start now';

  @override
  String get planRecent => 'Recent';

  @override
  String get planSuggestionYours => 'Your activity';

  @override
  String planSuggestionReadyMade(String fields) {
    return 'Ready-made · $fields';
  }

  @override
  String get planTimeSheetTitle => 'When?';

  @override
  String get planTimeStarts => 'Starts';

  @override
  String get planTimeLength => 'How long';

  @override
  String get planTimeOther => 'Other time…';

  @override
  String get planTimeNoEnd => 'No end';

  @override
  String planTimeMinutes(int count) {
    return '$count min';
  }

  @override
  String planTimeHours(int count) {
    return '$count h';
  }

  @override
  String get planTimeUntil => 'Until…';

  @override
  String planTimeUntilTime(String time) {
    return 'Until $time';
  }

  @override
  String get planTimeRemove => 'No time';

  @override
  String get dayPreviousDay => 'Previous day';

  @override
  String get dayNextDay => 'Next day';

  @override
  String get meSectionSetup => 'Your setup';

  @override
  String get durationHoursLabel => 'Hours';

  @override
  String get durationMinutesLabel => 'Minutes';

  @override
  String get itemMarkDoneHint =>
      'Logged so far. Mark it done when you’ve finished.';

  @override
  String get planAnytime => 'Anytime';

  @override
  String get insightPeriodTotal => 'total this period';

  @override
  String get insightPeriodAverage => 'average this period';

  @override
  String get insightPeriodBest => 'best this period';

  @override
  String get insightPeriodLowest => 'lowest this period';

  @override
  String get insightPeriodCount => 'times this period';

  @override
  String insightAllTimeBest(String value, String date) {
    return 'All-time best $value · $date';
  }

  @override
  String insightBestDay(String value, String date) {
    return 'Best day $value · $date';
  }

  @override
  String insightBestItem(String item, String value, String date) {
    return 'Best $item $value · $date';
  }

  @override
  String insightPeriod(String from, String to) {
    return '$from – $to';
  }

  @override
  String get insightDuplicateName =>
      'Another activity has this name. Rename one in Me → Activities.';

  @override
  String get activityIconBarbell => 'Weights';

  @override
  String get activityIconBookOpen => 'Book';

  @override
  String get activityIconBriefcase => 'Briefcase';

  @override
  String get activityIconPersonSimpleWalk => 'Walking';

  @override
  String get activityIconPersonSimpleRun => 'Running';

  @override
  String get activityIconBicycle => 'Cycling';

  @override
  String get activityIconSwimmingPool => 'Swimming';

  @override
  String get activityIconFlowerLotus => 'Meditation';

  @override
  String get activityIconUsersThree => 'People';

  @override
  String get activityIconPencilSimple => 'Writing';

  @override
  String get activityIconCode => 'Coding';

  @override
  String get activityIconCookingPot => 'Cooking';

  @override
  String get activityIconTranslate => 'Languages';

  @override
  String get activityIconGraduationCap => 'Studying';

  @override
  String get activityIconBrain => 'Thinking';

  @override
  String get activityIconMusicNotes => 'Music';

  @override
  String get activityIconGuitar => 'Guitar';

  @override
  String get activityIconMicrophone => 'Microphone';

  @override
  String get activityIconPaintBrush => 'Painting';

  @override
  String get activityIconCamera => 'Photography';

  @override
  String get activityIconGameController => 'Games';

  @override
  String get activityIconMoon => 'Night';

  @override
  String get activityIconBed => 'Sleep';

  @override
  String get activityIconCoffee => 'Coffee';

  @override
  String get activityIconForkKnife => 'Meal';

  @override
  String get activityIconDrop => 'Water';

  @override
  String get activityIconPill => 'Medicine';

  @override
  String get activityIconFirstAid => 'First aid';

  @override
  String get activityIconTooth => 'Teeth';

  @override
  String get activityIconHeart => 'Heart';

  @override
  String get activityIconLeaf => 'Nature';

  @override
  String get activityIconPlant => 'Plants';

  @override
  String get activityIconDog => 'Pets';

  @override
  String get activityIconBaby => 'Baby';

  @override
  String get activityIconHouse => 'Home';

  @override
  String get activityIconBroom => 'Cleaning';

  @override
  String get activityIconWrench => 'Repairs';

  @override
  String get activityIconShoppingCart => 'Shopping';

  @override
  String get activityIconWallet => 'Money';

  @override
  String get activityIconEnvelope => 'Email';

  @override
  String get activityIconPhone => 'Phone call';

  @override
  String get activityIconChatCircle => 'Chat';

  @override
  String get activityIconLaptop => 'Computer';

  @override
  String get activityIconPresentationChart => 'Presentation';

  @override
  String get activityIconNotebook => 'Notebook';

  @override
  String get activityIconTarget => 'Goal';

  @override
  String get activityIconLightbulb => 'Idea';

  @override
  String get activityIconTimer => 'Timer';

  @override
  String get activityIconMountains => 'Hiking';

  @override
  String get activityIconBasketball => 'Basketball';

  @override
  String get activityIconSoccerBall => 'Football';

  @override
  String get activityIconTennisBall => 'Tennis';

  @override
  String get activityIconYinYang => 'Balance';

  @override
  String get activityIconGlobe => 'Travel';

  @override
  String get activityIconAirplane => 'Flight';

  @override
  String get activityIconCar => 'Driving';

  @override
  String get activityIconSparkle => 'Sparkle';

  @override
  String get activityIconStar => 'Star';

  @override
  String get activityColorSky => 'Sky';

  @override
  String get activityColorLilac => 'Lilac';

  @override
  String get activityColorRose => 'Rose';

  @override
  String get activityColorTeal => 'Teal';

  @override
  String get activityColorCoral => 'Coral';

  @override
  String get activityColorSlate => 'Slate';

  @override
  String get builderMoreIcons => 'More icons';

  @override
  String get builderFewerIcons => 'Fewer icons';
}
