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
  String get fieldTypeText => 'Words';

  @override
  String get fieldTypeTextDescription =>
      'Words, a short note or a long description, like what the doctor said';

  @override
  String get fieldTypeNumber => 'An amount';

  @override
  String get fieldTypeNumberDescription =>
      'A number, optionally in a unit like kg, km or pages';

  @override
  String get fieldTypeBoolean => 'Yes or no';

  @override
  String get fieldTypeBooleanDescription =>
      'Something that did or didn\'t happen';

  @override
  String get fieldTypeSingleSelect => 'One choice';

  @override
  String get fieldTypeSingleSelectDescription =>
      'Pick one option from your list';

  @override
  String get fieldTypeMultiSelect => 'Several choices';

  @override
  String get fieldTypeMultiSelectDescription =>
      'Pick any options from your list';

  @override
  String get fieldTypeDate => 'A date';

  @override
  String get fieldTypeDateDescription => 'A calendar date';

  @override
  String get fieldTypeTime => 'A time of day';

  @override
  String get fieldTypeTimeDescription => 'A time of day';

  @override
  String get fieldTypeDuration => 'Time spent';

  @override
  String get fieldTypeDurationDescription =>
      'An amount of time, like rest or practice time';

  @override
  String get fieldTypeRating => 'A rating';

  @override
  String get fieldTypeRatingDescription => 'Stars on a scale you choose';

  @override
  String get fieldTypeRepeatingGroup => 'A list';

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
  String get templatesSearchHint => 'Search templates';

  @override
  String get templatesNoMatch =>
      'No template matches. Go back and make your own instead.';

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
  String get planQuickAddHint => 'Add an activity to this day';

  @override
  String get planBrowseTemplates => 'Templates';

  @override
  String get planMakeOwn => 'Make your own';

  @override
  String planMakeOwnNamed(String name) {
    return 'Make “$name” your own';
  }

  @override
  String get planMakeOwnHint => 'New activity · choose what to log';

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
      'What do you want to keep track of? Pick one, or just write notes.';

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

  @override
  String itemLastTime(String date) {
    return 'Last time · $date';
  }

  @override
  String get itemUseLastTime => 'Use last time';

  @override
  String groupLastTime(String summary) {
    return 'Last time: $summary';
  }

  @override
  String get groupUseLastTime => 'Use';

  @override
  String get restAction => 'Rest';

  @override
  String restLeft(String time) {
    return 'Rest $time';
  }

  @override
  String get restOver => 'Rest over';

  @override
  String get restLess => '−15 s';

  @override
  String get restMore => '+15 s';

  @override
  String get restStop => 'Stop';

  @override
  String get itemAddQuick => 'Quick';

  @override
  String get itemAddMoreKinds => 'More kinds of detail';

  @override
  String get quickHowItWent => 'How it went';

  @override
  String get quickHowItWentDescription => 'A rating from 1 to 5';

  @override
  String get quickAmount => 'An amount';

  @override
  String get quickAmountDescription =>
      'A number you name, like pages, km or glasses';

  @override
  String get itemQuickMore => 'More…';

  @override
  String get fieldAdvanced => 'Advanced';

  @override
  String get planDuplicate => 'Duplicate';

  @override
  String get planDuplicatedMessage => 'Duplicated';

  @override
  String get planQuickActionsHint => 'show quick actions';

  @override
  String get templateRunning => 'Running';

  @override
  String get templateRunningDistance => 'Distance';

  @override
  String get templateRunningRoute => 'Route';

  @override
  String get templateRunningFelt => 'How it felt';

  @override
  String get templateStudy => 'Study';

  @override
  String get templateStudySubject => 'Subject';

  @override
  String get templateStudyCovered => 'What I covered';

  @override
  String get templateStudyFocus => 'Focus';

  @override
  String get templateMeditation => 'Meditation';

  @override
  String get templateMeditationKind => 'Kind';

  @override
  String get templateMeditationBreathing => 'Breathing';

  @override
  String get templateMeditationBodyScan => 'Body scan';

  @override
  String get templateMeditationGuided => 'Guided';

  @override
  String get templateMeditationSilent => 'Silent';

  @override
  String get templateMeditationCalm => 'Calm afterwards';

  @override
  String get templateWater => 'Water';

  @override
  String get templateWaterGlasses => 'Glasses';

  @override
  String get templateSleep => 'Sleep';

  @override
  String get templateSleepQuality => 'Quality';

  @override
  String get templateSleepWokeUp => 'Woke up in the night';

  @override
  String get templateMood => 'Mood';

  @override
  String get templateMoodRating => 'Mood';

  @override
  String get templateMoodFeelings => 'Feelings';

  @override
  String get templateMoodCalm => 'Calm';

  @override
  String get templateMoodHappy => 'Happy';

  @override
  String get templateMoodEnergetic => 'Energetic';

  @override
  String get templateMoodTired => 'Tired';

  @override
  String get templateMoodStressed => 'Stressed';

  @override
  String get templateMoodAnxious => 'Anxious';

  @override
  String templatePreviewAdd(String name) {
    return 'Add $name';
  }

  @override
  String get templatesYoullLog => 'What you\'ll log';

  @override
  String get templatesAlreadyAdded => 'Already in your activities';

  @override
  String get templateCategorySleepAndSelfCare => 'Sleep & self-care';

  @override
  String get templateNap => 'Nap';

  @override
  String get templateNapFeltAfter => 'Felt after';

  @override
  String get templateMorningRoutine => 'Morning routine';

  @override
  String get templateMorningRoutineWokeUpAt => 'Woke up at';

  @override
  String get templateMorningRoutineSteps => 'Steps';

  @override
  String get templateMorningRoutineStepsItem => 'Step';

  @override
  String get templateMorningRoutineStepsStep => 'Step';

  @override
  String get templateMorningRoutineStepsDone => 'Done';

  @override
  String get templateMorningRoutineEnergy => 'Energy';

  @override
  String get templateEveningRoutine => 'Evening routine';

  @override
  String get templateEveningRoutineLightsOutAt => 'Lights out at';

  @override
  String get templateEveningRoutineSteps => 'Steps';

  @override
  String get templateEveningRoutineStepsItem => 'Step';

  @override
  String get templateEveningRoutineStepsStep => 'Step';

  @override
  String get templateEveningRoutineStepsDone => 'Done';

  @override
  String get templateEveningRoutineScreensOffAnHourBefore =>
      'Screens off an hour before';

  @override
  String get templateShower => 'Shower';

  @override
  String get templateShowerKind => 'Kind';

  @override
  String get templateShowerKindShower => 'Shower';

  @override
  String get templateShowerKindBath => 'Bath';

  @override
  String get templateShowerKindColdShower => 'Cold shower';

  @override
  String get templateShowerFeltAfter => 'Felt after';

  @override
  String get templateSkincare => 'Skincare';

  @override
  String get templateSkincareProducts => 'Products';

  @override
  String get templateSkincareProductsCleanser => 'Cleanser';

  @override
  String get templateSkincareProductsToner => 'Toner';

  @override
  String get templateSkincareProductsSerum => 'Serum';

  @override
  String get templateSkincareProductsMoisturizer => 'Moisturizer';

  @override
  String get templateSkincareProductsSunscreen => 'Sunscreen';

  @override
  String get templateSkincareProductsMask => 'Mask';

  @override
  String get templateSkincareSkinToday => 'Skin today';

  @override
  String get templateOralCare => 'Oral care';

  @override
  String get templateOralCareBrushed => 'Brushed';

  @override
  String get templateOralCareFlossed => 'Flossed';

  @override
  String get templateOralCareMouthwash => 'Mouthwash';

  @override
  String get templateGrooming => 'Grooming';

  @override
  String get templateGroomingWhat => 'What';

  @override
  String get templateGroomingWhatHaircut => 'Haircut';

  @override
  String get templateGroomingWhatShave => 'Shave';

  @override
  String get templateGroomingWhatBeardTrim => 'Beard trim';

  @override
  String get templateGroomingWhatNails => 'Nails';

  @override
  String get templateGroomingWhatHairWash => 'Hair wash';

  @override
  String get templateGroomingCost => 'Cost';

  @override
  String get templateCategoryHealth => 'Health';

  @override
  String get templateMedication => 'Medication';

  @override
  String get templateMedicationMedicine => 'Medicine';

  @override
  String get templateMedicationDose => 'Dose';

  @override
  String get templateMedicationTaken => 'Taken';

  @override
  String get templateMedicationSideEffects => 'Side effects';

  @override
  String get templateVitaminsAndSupplements => 'Vitamins & supplements';

  @override
  String get templateVitaminsAndSupplementsSupplements => 'Supplements';

  @override
  String get templateVitaminsAndSupplementsSupplementsItem => 'Supplement';

  @override
  String get templateVitaminsAndSupplementsSupplementsSupplement =>
      'Supplement';

  @override
  String get templateVitaminsAndSupplementsSupplementsTaken => 'Taken';

  @override
  String get templateDoctorVisit => 'Doctor visit';

  @override
  String get templateDoctorVisitDoctorOrClinic => 'Doctor or clinic';

  @override
  String get templateDoctorVisitReason => 'Reason';

  @override
  String get templateDoctorVisitWhatTheySaid => 'What they said';

  @override
  String get templateDoctorVisitNextVisit => 'Next visit';

  @override
  String get templateSymptoms => 'Symptoms';

  @override
  String get templateSymptomsSymptoms => 'Symptoms';

  @override
  String get templateSymptomsSymptomsHeadache => 'Headache';

  @override
  String get templateSymptomsSymptomsFever => 'Fever';

  @override
  String get templateSymptomsSymptomsCough => 'Cough';

  @override
  String get templateSymptomsSymptomsSoreThroat => 'Sore throat';

  @override
  String get templateSymptomsSymptomsFatigue => 'Fatigue';

  @override
  String get templateSymptomsSymptomsNausea => 'Nausea';

  @override
  String get templateSymptomsSymptomsPain => 'Pain';

  @override
  String get templateSymptomsSeverity => 'Severity';

  @override
  String get templateSymptomsNotes => 'Notes';

  @override
  String get templateBloodPressure => 'Blood pressure';

  @override
  String get templateBloodPressureSystolic => 'Systolic';

  @override
  String get templateBloodPressureDiastolic => 'Diastolic';

  @override
  String get templateBloodPressurePulse => 'Pulse';

  @override
  String get templateBloodSugar => 'Blood sugar';

  @override
  String get templateBloodSugarReading => 'Reading';

  @override
  String get templateBloodSugarWhen => 'When';

  @override
  String get templateBloodSugarWhenFasting => 'Fasting';

  @override
  String get templateBloodSugarWhenBeforeAMeal => 'Before a meal';

  @override
  String get templateBloodSugarWhenAfterAMeal => 'After a meal';

  @override
  String get templateBloodSugarWhenBedtime => 'Bedtime';

  @override
  String get templateBodyTemperature => 'Body temperature';

  @override
  String get templateBodyTemperatureTemperature => 'Temperature';

  @override
  String get templatePeriod => 'Period';

  @override
  String get templatePeriodFlow => 'Flow';

  @override
  String get templatePeriodFlowSpotting => 'Spotting';

  @override
  String get templatePeriodFlowLight => 'Light';

  @override
  String get templatePeriodFlowMedium => 'Medium';

  @override
  String get templatePeriodFlowHeavy => 'Heavy';

  @override
  String get templatePeriodSymptoms => 'Symptoms';

  @override
  String get templatePeriodSymptomsCramps => 'Cramps';

  @override
  String get templatePeriodSymptomsBloating => 'Bloating';

  @override
  String get templatePeriodSymptomsHeadache => 'Headache';

  @override
  String get templatePeriodSymptomsMoodSwings => 'Mood swings';

  @override
  String get templatePeriodSymptomsFatigue => 'Fatigue';

  @override
  String get templatePeriodSymptomsCravings => 'Cravings';

  @override
  String get templatePeriodNotes => 'Notes';

  @override
  String get templatePhysiotherapy => 'Physiotherapy';

  @override
  String get templatePhysiotherapyExercises => 'Exercises';

  @override
  String get templatePhysiotherapyExercisesItem => 'Exercise';

  @override
  String get templatePhysiotherapyExercisesExercise => 'Exercise';

  @override
  String get templatePhysiotherapyExercisesDone => 'Done';

  @override
  String get templatePhysiotherapyPainLevel => 'Pain level';

  @override
  String get templateCategoryFoodAndDrink => 'Food & drink';

  @override
  String get templateMeal => 'Meal';

  @override
  String get templateMealMeal => 'Meal';

  @override
  String get templateMealMealBreakfast => 'Breakfast';

  @override
  String get templateMealMealLunch => 'Lunch';

  @override
  String get templateMealMealDinner => 'Dinner';

  @override
  String get templateMealMealSnack => 'Snack';

  @override
  String get templateMealWhatIAte => 'What I ate';

  @override
  String get templateMealCalories => 'Calories';

  @override
  String get templateMealHowHealthy => 'How healthy';

  @override
  String get templateMealAteOut => 'Ate out';

  @override
  String get templateCoffeeAndTea => 'Coffee & tea';

  @override
  String get templateCoffeeAndTeaDrink => 'Drink';

  @override
  String get templateCoffeeAndTeaDrinkCoffee => 'Coffee';

  @override
  String get templateCoffeeAndTeaDrinkEspresso => 'Espresso';

  @override
  String get templateCoffeeAndTeaDrinkTea => 'Tea';

  @override
  String get templateCoffeeAndTeaDrinkGreenTea => 'Green tea';

  @override
  String get templateCoffeeAndTeaDrinkHerbalTea => 'Herbal tea';

  @override
  String get templateCoffeeAndTeaCups => 'Cups';

  @override
  String get templateFasting => 'Fasting';

  @override
  String get templateFastingPlan => 'Plan';

  @override
  String get templateFastingPlan1212 => '12:12';

  @override
  String get templateFastingPlan168 => '16:8';

  @override
  String get templateFastingPlan186 => '18:6';

  @override
  String get templateFastingPlan204 => '20:4';

  @override
  String get templateFastingPlan24Hours => '24 hours';

  @override
  String get templateFastingBrokeTheFastAt => 'Broke the fast at';

  @override
  String get templateFastingHowItFelt => 'How it felt';

  @override
  String get templateAlcohol => 'Alcohol';

  @override
  String get templateAlcoholDrinks => 'Drinks';

  @override
  String get templateAlcoholKind => 'Kind';

  @override
  String get templateAlcoholKindBeer => 'Beer';

  @override
  String get templateAlcoholKindWine => 'Wine';

  @override
  String get templateAlcoholKindSpirits => 'Spirits';

  @override
  String get templateAlcoholKindCocktail => 'Cocktail';

  @override
  String get templateAlcoholKindCider => 'Cider';

  @override
  String get templateMealPrep => 'Meal prep';

  @override
  String get templateMealPrepDishes => 'Dishes';

  @override
  String get templateMealPrepDishesItem => 'Dish';

  @override
  String get templateMealPrepDishesDish => 'Dish';

  @override
  String get templateMealPrepDishesPortions => 'Portions';

  @override
  String get templateCategoryHomeAndChores => 'Home & chores';

  @override
  String get templateCleaning => 'Cleaning';

  @override
  String get templateCleaningRooms => 'Rooms';

  @override
  String get templateCleaningRoomsKitchen => 'Kitchen';

  @override
  String get templateCleaningRoomsBathroom => 'Bathroom';

  @override
  String get templateCleaningRoomsBedroom => 'Bedroom';

  @override
  String get templateCleaningRoomsLivingRoom => 'Living room';

  @override
  String get templateCleaningRoomsWholeHome => 'Whole home';

  @override
  String get templateCleaningTasks => 'Tasks';

  @override
  String get templateCleaningTasksItem => 'Task';

  @override
  String get templateCleaningTasksTask => 'Task';

  @override
  String get templateCleaningTasksDone => 'Done';

  @override
  String get templateLaundry => 'Laundry';

  @override
  String get templateLaundryLoads => 'Loads';

  @override
  String get templateLaundrySteps => 'Steps';

  @override
  String get templateLaundryStepsWashed => 'Washed';

  @override
  String get templateLaundryStepsDried => 'Dried';

  @override
  String get templateLaundryStepsFolded => 'Folded';

  @override
  String get templateLaundryStepsIroned => 'Ironed';

  @override
  String get templateLaundryStepsPutAway => 'Put away';

  @override
  String get templateDishes => 'Dishes';

  @override
  String get templateDishesHow => 'How';

  @override
  String get templateDishesHowByHand => 'By hand';

  @override
  String get templateDishesHowDishwasher => 'Dishwasher';

  @override
  String get templateDishesKitchenWiped => 'Kitchen wiped';

  @override
  String get templateGroceries => 'Groceries';

  @override
  String get templateGroceriesStore => 'Store';

  @override
  String get templateGroceriesShoppingList => 'Shopping list';

  @override
  String get templateGroceriesShoppingListItem => 'Item';

  @override
  String get templateGroceriesShoppingListGotIt => 'Got it';

  @override
  String get templateGroceriesSpent => 'Spent';

  @override
  String get templateGardening => 'Gardening';

  @override
  String get templateGardeningTasks => 'Tasks';

  @override
  String get templateGardeningTasksWatering => 'Watering';

  @override
  String get templateGardeningTasksPlanting => 'Planting';

  @override
  String get templateGardeningTasksWeeding => 'Weeding';

  @override
  String get templateGardeningTasksPruning => 'Pruning';

  @override
  String get templateGardeningTasksMowing => 'Mowing';

  @override
  String get templateGardeningTasksHarvesting => 'Harvesting';

  @override
  String get templateGardeningPlants => 'Plants';

  @override
  String get templatePlantCare => 'Plant care';

  @override
  String get templatePlantCarePlants => 'Plants';

  @override
  String get templatePlantCarePlantsItem => 'Plant';

  @override
  String get templatePlantCarePlantsPlant => 'Plant';

  @override
  String get templatePlantCarePlantsWatered => 'Watered';

  @override
  String get templatePlantCarePlantsFed => 'Fed';

  @override
  String get templateHomeRepair => 'Home repair';

  @override
  String get templateHomeRepairProject => 'Project';

  @override
  String get templateHomeRepairWhatWasDone => 'What was done';

  @override
  String get templateHomeRepairCost => 'Cost';

  @override
  String get templateDeclutter => 'Declutter';

  @override
  String get templateDeclutterArea => 'Area';

  @override
  String get templateDeclutterItemsRemoved => 'Items removed';

  @override
  String get templateDeclutterWhereTheyWent => 'Where they went';

  @override
  String get templateDeclutterWhereTheyWentDonated => 'Donated';

  @override
  String get templateDeclutterWhereTheyWentSold => 'Sold';

  @override
  String get templateDeclutterWhereTheyWentRecycled => 'Recycled';

  @override
  String get templateDeclutterWhereTheyWentThrownAway => 'Thrown away';

  @override
  String get templateBills => 'Bills';

  @override
  String get templateBillsBills => 'Bills';

  @override
  String get templateBillsBillsItem => 'Bill';

  @override
  String get templateBillsBillsBill => 'Bill';

  @override
  String get templateBillsBillsAmount => 'Amount';

  @override
  String get templateBillsBillsPaid => 'Paid';

  @override
  String get templateExpense => 'Expense';

  @override
  String get templateExpenseAmount => 'Amount';

  @override
  String get templateExpenseCategory => 'Category';

  @override
  String get templateExpenseCategoryFood => 'Food';

  @override
  String get templateExpenseCategoryTransport => 'Transport';

  @override
  String get templateExpenseCategoryHome => 'Home';

  @override
  String get templateExpenseCategoryHealth => 'Health';

  @override
  String get templateExpenseCategoryFun => 'Fun';

  @override
  String get templateExpenseCategoryShopping => 'Shopping';

  @override
  String get templateExpenseCategoryBills => 'Bills';

  @override
  String get templateExpenseCategoryOther => 'Other';

  @override
  String get templateExpenseWhatFor => 'What for';

  @override
  String get templateBudgetReview => 'Budget review';

  @override
  String get templateBudgetReviewSpentThisWeek => 'Spent this week';

  @override
  String get templateBudgetReviewSaved => 'Saved';

  @override
  String get templateBudgetReviewOnTrack => 'On track';

  @override
  String get templateCategoryFamilyAndCare => 'Family & care';

  @override
  String get templateChildcare => 'Childcare';

  @override
  String get templateChildcareChild => 'Child';

  @override
  String get templateChildcareWhatWeDid => 'What we did';

  @override
  String get templateChildcareWhatWeDidMeals => 'Meals';

  @override
  String get templateChildcareWhatWeDidSchoolRun => 'School run';

  @override
  String get templateChildcareWhatWeDidHomework => 'Homework';

  @override
  String get templateChildcareWhatWeDidPlaytime => 'Playtime';

  @override
  String get templateChildcareWhatWeDidBath => 'Bath';

  @override
  String get templateChildcareWhatWeDidBedtime => 'Bedtime';

  @override
  String get templateChildcareNotes => 'Notes';

  @override
  String get templateBabyFeeding => 'Baby feeding';

  @override
  String get templateBabyFeedingKind => 'Kind';

  @override
  String get templateBabyFeedingKindBreastLeft => 'Breast (left)';

  @override
  String get templateBabyFeedingKindBreastRight => 'Breast (right)';

  @override
  String get templateBabyFeedingKindBottle => 'Bottle';

  @override
  String get templateBabyFeedingKindSolids => 'Solids';

  @override
  String get templateBabyFeedingAmount => 'Amount';

  @override
  String get templateBabyFeedingNotes => 'Notes';

  @override
  String get templateDiaperChange => 'Diaper change';

  @override
  String get templateDiaperChangeKind => 'Kind';

  @override
  String get templateDiaperChangeKindWet => 'Wet';

  @override
  String get templateDiaperChangeKindDirty => 'Dirty';

  @override
  String get templateDiaperChangeKindBoth => 'Both';

  @override
  String get templatePetCare => 'Pet care';

  @override
  String get templatePetCarePet => 'Pet';

  @override
  String get templatePetCareCare => 'Care';

  @override
  String get templatePetCareCareFed => 'Fed';

  @override
  String get templatePetCareCareWalked => 'Walked';

  @override
  String get templatePetCareCareGroomed => 'Groomed';

  @override
  String get templatePetCareCarePlayed => 'Played';

  @override
  String get templatePetCareCareMedicine => 'Medicine';

  @override
  String get templatePetCareCareVetVisit => 'Vet visit';

  @override
  String get templatePetCareNotes => 'Notes';

  @override
  String get templateDogWalk => 'Dog walk';

  @override
  String get templateDogWalkDog => 'Dog';

  @override
  String get templateDogWalkDistance => 'Distance';

  @override
  String get templateFamilyTime => 'Family time';

  @override
  String get templateFamilyTimeWho => 'Who';

  @override
  String get templateFamilyTimeWhatWeDid => 'What we did';

  @override
  String get templateFamilyTimeHowItFelt => 'How it felt';

  @override
  String get templateCaringForSomeone => 'Caring for someone';

  @override
  String get templateCaringForSomeoneWho => 'Who';

  @override
  String get templateCaringForSomeoneHelpGiven => 'Help given';

  @override
  String get templateCaringForSomeoneHelpGivenCompany => 'Company';

  @override
  String get templateCaringForSomeoneHelpGivenMeals => 'Meals';

  @override
  String get templateCaringForSomeoneHelpGivenErrands => 'Errands';

  @override
  String get templateCaringForSomeoneHelpGivenMedicine => 'Medicine';

  @override
  String get templateCaringForSomeoneHelpGivenAppointments => 'Appointments';

  @override
  String get templateCaringForSomeoneNotes => 'Notes';

  @override
  String get templateCategoryWork => 'Work';

  @override
  String get templateDailyPlanning => 'Daily planning';

  @override
  String get templateDailyPlanningTopPriorities => 'Top priorities';

  @override
  String get templateDailyPlanningTopPrioritiesItem => 'Priority';

  @override
  String get templateDailyPlanningTopPrioritiesPriority => 'Priority';

  @override
  String get templateDailyPlanningTopPrioritiesDone => 'Done';

  @override
  String get templateDailyPlanningNotes => 'Notes';

  @override
  String get templateCommute => 'Commute';

  @override
  String get templateCommuteHow => 'How';

  @override
  String get templateCommuteHowCar => 'Car';

  @override
  String get templateCommuteHowBus => 'Bus';

  @override
  String get templateCommuteHowTrain => 'Train';

  @override
  String get templateCommuteHowBike => 'Bike';

  @override
  String get templateCommuteHowWalk => 'Walk';

  @override
  String get templateCommuteHowOther => 'Other';

  @override
  String get templateCommuteDistance => 'Distance';

  @override
  String get templateCommuteHowItWent => 'How it went';

  @override
  String get templateEmailAndAdmin => 'Email & admin';

  @override
  String get templateEmailAndAdminEmailsHandled => 'Emails handled';

  @override
  String get templateEmailAndAdminInboxZero => 'Inbox zero';

  @override
  String get templateCoding => 'Coding';

  @override
  String get templateCodingProject => 'Project';

  @override
  String get templateCodingWhatIBuilt => 'What I built';

  @override
  String get templateCodingCommits => 'Commits';

  @override
  String get templateSideProject => 'Side project';

  @override
  String get templateSideProjectProject => 'Project';

  @override
  String get templateSideProjectProgress => 'Progress';

  @override
  String get templateSideProjectMomentum => 'Momentum';

  @override
  String get templateJobSearch => 'Job search';

  @override
  String get templateJobSearchCompany => 'Company';

  @override
  String get templateJobSearchRole => 'Role';

  @override
  String get templateJobSearchStage => 'Stage';

  @override
  String get templateJobSearchStageApplied => 'Applied';

  @override
  String get templateJobSearchStageInterview => 'Interview';

  @override
  String get templateJobSearchStageOffer => 'Offer';

  @override
  String get templateJobSearchStageRejected => 'Rejected';

  @override
  String get templateJobSearchStageFollowingUp => 'Following up';

  @override
  String get templateJobSearchNotes => 'Notes';

  @override
  String get templatePresentation => 'Presentation';

  @override
  String get templatePresentationTopic => 'Topic';

  @override
  String get templatePresentationAudience => 'Audience';

  @override
  String get templatePresentationHowItWent => 'How it went';

  @override
  String get templateCategoryLearning => 'Learning';

  @override
  String get templateClass => 'Class';

  @override
  String get templateClassCourse => 'Course';

  @override
  String get templateClassTopic => 'Topic';

  @override
  String get templateClassNotes => 'Notes';

  @override
  String get templateClassUnderstood => 'Understood';

  @override
  String get templateHomework => 'Homework';

  @override
  String get templateHomeworkSubject => 'Subject';

  @override
  String get templateHomeworkTask => 'Task';

  @override
  String get templateHomeworkFinished => 'Finished';

  @override
  String get templateOnlineCourse => 'Online course';

  @override
  String get templateOnlineCourseCourse => 'Course';

  @override
  String get templateOnlineCourseLessonsDone => 'Lessons done';

  @override
  String get templateOnlineCourseTakeaways => 'Takeaways';

  @override
  String get templateMusicPractice => 'Music practice';

  @override
  String get templateMusicPracticeInstrument => 'Instrument';

  @override
  String get templateMusicPracticeInstrumentGuitar => 'Guitar';

  @override
  String get templateMusicPracticeInstrumentPiano => 'Piano';

  @override
  String get templateMusicPracticeInstrumentDrums => 'Drums';

  @override
  String get templateMusicPracticeInstrumentViolin => 'Violin';

  @override
  String get templateMusicPracticeInstrumentVoice => 'Voice';

  @override
  String get templateMusicPracticeInstrumentOther => 'Other';

  @override
  String get templateMusicPracticePieces => 'Pieces';

  @override
  String get templateMusicPracticePiecesItem => 'Piece';

  @override
  String get templateMusicPracticePiecesPiece => 'Piece';

  @override
  String get templateMusicPracticePiecesTempoBpm => 'Tempo (bpm)';

  @override
  String get templateMusicPracticeHowItWent => 'How it went';

  @override
  String get templateSkillPractice => 'Skill practice';

  @override
  String get templateSkillPracticeSkill => 'Skill';

  @override
  String get templateSkillPracticeWhatIPractised => 'What I practised';

  @override
  String get templateSkillPracticeProgress => 'Progress';

  @override
  String get templateCategoryExerciseAndSport => 'Exercise & sport';

  @override
  String get templateCycling => 'Cycling';

  @override
  String get templateCyclingDistance => 'Distance';

  @override
  String get templateCyclingRoute => 'Route';

  @override
  String get templateCyclingFelt => 'Felt';

  @override
  String get templateSwimming => 'Swimming';

  @override
  String get templateSwimmingDistance => 'Distance';

  @override
  String get templateSwimmingLaps => 'Laps';

  @override
  String get templateSwimmingStrokes => 'Strokes';

  @override
  String get templateSwimmingStrokesFreestyle => 'Freestyle';

  @override
  String get templateSwimmingStrokesBreaststroke => 'Breaststroke';

  @override
  String get templateSwimmingStrokesBackstroke => 'Backstroke';

  @override
  String get templateSwimmingStrokesButterfly => 'Butterfly';

  @override
  String get templateYoga => 'Yoga';

  @override
  String get templateYogaStyle => 'Style';

  @override
  String get templateYogaStyleHatha => 'Hatha';

  @override
  String get templateYogaStyleVinyasa => 'Vinyasa';

  @override
  String get templateYogaStyleYin => 'Yin';

  @override
  String get templateYogaStylePower => 'Power';

  @override
  String get templateYogaStyleRestorative => 'Restorative';

  @override
  String get templateYogaFeltAfter => 'Felt after';

  @override
  String get templateStretching => 'Stretching';

  @override
  String get templateStretchingAreas => 'Areas';

  @override
  String get templateStretchingAreasNeck => 'Neck';

  @override
  String get templateStretchingAreasShoulders => 'Shoulders';

  @override
  String get templateStretchingAreasBack => 'Back';

  @override
  String get templateStretchingAreasHips => 'Hips';

  @override
  String get templateStretchingAreasLegs => 'Legs';

  @override
  String get templateStretchingAreasFullBody => 'Full body';

  @override
  String get templateHomeWorkout => 'Home workout';

  @override
  String get templateHomeWorkoutExercises => 'Exercises';

  @override
  String get templateHomeWorkoutExercisesItem => 'Exercise';

  @override
  String get templateHomeWorkoutExercisesExercise => 'Exercise';

  @override
  String get templateHomeWorkoutExercisesReps => 'Reps';

  @override
  String get templateHomeWorkoutExercisesRounds => 'Rounds';

  @override
  String get templateHomeWorkoutEffort => 'Effort';

  @override
  String get templateHiking => 'Hiking';

  @override
  String get templateHikingTrail => 'Trail';

  @override
  String get templateHikingDistance => 'Distance';

  @override
  String get templateHikingElevationGain => 'Elevation gain';

  @override
  String get templateHikingFelt => 'Felt';

  @override
  String get templateTeamSport => 'Team sport';

  @override
  String get templateTeamSportSport => 'Sport';

  @override
  String get templateTeamSportSportFootball => 'Football';

  @override
  String get templateTeamSportSportBasketball => 'Basketball';

  @override
  String get templateTeamSportSportCricket => 'Cricket';

  @override
  String get templateTeamSportSportVolleyball => 'Volleyball';

  @override
  String get templateTeamSportSportHockey => 'Hockey';

  @override
  String get templateTeamSportSportOther => 'Other';

  @override
  String get templateTeamSportResult => 'Result';

  @override
  String get templateTeamSportResultWon => 'Won';

  @override
  String get templateTeamSportResultLost => 'Lost';

  @override
  String get templateTeamSportResultDraw => 'Draw';

  @override
  String get templateTeamSportResultJustPlayed => 'Just played';

  @override
  String get templateTeamSportHowIPlayed => 'How I played';

  @override
  String get templateRacketSport => 'Racket sport';

  @override
  String get templateRacketSportSport => 'Sport';

  @override
  String get templateRacketSportSportTennis => 'Tennis';

  @override
  String get templateRacketSportSportBadminton => 'Badminton';

  @override
  String get templateRacketSportSportSquash => 'Squash';

  @override
  String get templateRacketSportSportTableTennis => 'Table tennis';

  @override
  String get templateRacketSportSportPadel => 'Padel';

  @override
  String get templateRacketSportOpponent => 'Opponent';

  @override
  String get templateRacketSportResult => 'Result';

  @override
  String get templateRacketSportResultWon => 'Won';

  @override
  String get templateRacketSportResultLost => 'Lost';

  @override
  String get templateRacketSportResultJustPlayed => 'Just played';

  @override
  String get templateDance => 'Dance';

  @override
  String get templateDanceStyle => 'Style';

  @override
  String get templateDanceFun => 'Fun';

  @override
  String get templateDailySteps => 'Daily steps';

  @override
  String get templateDailyStepsSteps => 'Steps';

  @override
  String get templateCategoryMindAndWellbeing => 'Mind & wellbeing';

  @override
  String get templateJournal => 'Journal';

  @override
  String get templateJournalEntry => 'Entry';

  @override
  String get templateJournalHowTheDayWas => 'How the day was';

  @override
  String get templateGratitude => 'Gratitude';

  @override
  String get templateGratitudeGratefulFor => 'Grateful for';

  @override
  String get templateGratitudeGratefulForItem => 'Thing';

  @override
  String get templateGratitudeGratefulForThing => 'Thing';

  @override
  String get templateBreathing => 'Breathing';

  @override
  String get templateBreathingTechnique => 'Technique';

  @override
  String get templateBreathingTechniqueBoxBreathing => 'Box breathing';

  @override
  String get templateBreathingTechnique478 => '4-7-8';

  @override
  String get templateBreathingTechniqueDeepBelly => 'Deep belly';

  @override
  String get templateBreathingTechniqueAlternateNostril => 'Alternate nostril';

  @override
  String get templateBreathingRounds => 'Rounds';

  @override
  String get templateTherapySession => 'Therapy session';

  @override
  String get templateTherapySessionWith => 'With';

  @override
  String get templateTherapySessionTalkedAbout => 'Talked about';

  @override
  String get templateTherapySessionTakeaways => 'Takeaways';

  @override
  String get templateTherapySessionFeltAfter => 'Felt after';

  @override
  String get templateScreenTime => 'Screen time';

  @override
  String get templateScreenTimeTotal => 'Total';

  @override
  String get templateScreenTimePickups => 'Pickups';

  @override
  String get templateScreenTimeMostUsedApp => 'Most used app';

  @override
  String get templateHabitToBreak => 'Habit to break';

  @override
  String get templateHabitToBreakHabit => 'Habit';

  @override
  String get templateHabitToBreakKeptClearToday => 'Kept clear today';

  @override
  String get templateHabitToBreakUrges => 'Urges';

  @override
  String get templateHabitToBreakNotes => 'Notes';

  @override
  String get templateDigitalDetox => 'Digital detox';

  @override
  String get templateDigitalDetoxPhoneAway => 'Phone away';

  @override
  String get templateDigitalDetoxHowItFelt => 'How it felt';

  @override
  String get templateAffirmations => 'Affirmations';

  @override
  String get templateAffirmationsTodaySAffirmation => 'Today\'s affirmation';

  @override
  String get templateAffirmationsSaidOutLoud => 'Said out loud';

  @override
  String get templateCategoryHobbiesAndFun => 'Hobbies & fun';

  @override
  String get templateTVAndMovies => 'TV & movies';

  @override
  String get templateTVAndMoviesTitle => 'Title';

  @override
  String get templateTVAndMoviesKind => 'Kind';

  @override
  String get templateTVAndMoviesKindMovie => 'Movie';

  @override
  String get templateTVAndMoviesKindSeries => 'Series';

  @override
  String get templateTVAndMoviesKindDocumentary => 'Documentary';

  @override
  String get templateTVAndMoviesKindShow => 'Show';

  @override
  String get templateTVAndMoviesEpisodes => 'Episodes';

  @override
  String get templateTVAndMoviesRating => 'Rating';

  @override
  String get templateGaming => 'Gaming';

  @override
  String get templateGamingGame => 'Game';

  @override
  String get templateGamingPlatform => 'Platform';

  @override
  String get templateGamingPlatformPC => 'PC';

  @override
  String get templateGamingPlatformConsole => 'Console';

  @override
  String get templateGamingPlatformMobile => 'Mobile';

  @override
  String get templateGamingPlatformBoardGame => 'Board game';

  @override
  String get templateGamingPlatformCards => 'Cards';

  @override
  String get templateGamingFun => 'Fun';

  @override
  String get templatePodcast => 'Podcast';

  @override
  String get templatePodcastShow => 'Show';

  @override
  String get templatePodcastEpisode => 'Episode';

  @override
  String get templatePodcastTakeaways => 'Takeaways';

  @override
  String get templateDrawingAndPainting => 'Drawing & painting';

  @override
  String get templateDrawingAndPaintingMedium => 'Medium';

  @override
  String get templateDrawingAndPaintingMediumPencil => 'Pencil';

  @override
  String get templateDrawingAndPaintingMediumInk => 'Ink';

  @override
  String get templateDrawingAndPaintingMediumWatercolor => 'Watercolor';

  @override
  String get templateDrawingAndPaintingMediumAcrylic => 'Acrylic';

  @override
  String get templateDrawingAndPaintingMediumOil => 'Oil';

  @override
  String get templateDrawingAndPaintingMediumDigital => 'Digital';

  @override
  String get templateDrawingAndPaintingPiece => 'Piece';

  @override
  String get templateDrawingAndPaintingHappyWithIt => 'Happy with it';

  @override
  String get templatePhotography => 'Photography';

  @override
  String get templatePhotographySubject => 'Subject';

  @override
  String get templatePhotographyPhotosTaken => 'Photos taken';

  @override
  String get templatePhotographyKeepers => 'Keepers';

  @override
  String get templateWriting => 'Writing';

  @override
  String get templateWritingProject => 'Project';

  @override
  String get templateWritingWords => 'Words';

  @override
  String get templateWritingNotes => 'Notes';

  @override
  String get templateCrafts => 'Crafts';

  @override
  String get templateCraftsCraft => 'Craft';

  @override
  String get templateCraftsCraftKnitting => 'Knitting';

  @override
  String get templateCraftsCraftCrochet => 'Crochet';

  @override
  String get templateCraftsCraftSewing => 'Sewing';

  @override
  String get templateCraftsCraftWoodwork => 'Woodwork';

  @override
  String get templateCraftsCraftPottery => 'Pottery';

  @override
  String get templateCraftsCraftOther => 'Other';

  @override
  String get templateCraftsProject => 'Project';

  @override
  String get templateCraftsProgress => 'Progress';

  @override
  String get templatePuzzles => 'Puzzles';

  @override
  String get templatePuzzlesGame => 'Game';

  @override
  String get templatePuzzlesGameSudoku => 'Sudoku';

  @override
  String get templatePuzzlesGameCrossword => 'Crossword';

  @override
  String get templatePuzzlesGameChess => 'Chess';

  @override
  String get templatePuzzlesGameJigsaw => 'Jigsaw';

  @override
  String get templatePuzzlesGameWordGame => 'Word game';

  @override
  String get templatePuzzlesGameOther => 'Other';

  @override
  String get templatePuzzlesSolved => 'Solved';

  @override
  String get templatePuzzlesScore => 'Score';

  @override
  String get templateListeningToMusic => 'Listening to music';

  @override
  String get templateListeningToMusicArtistOrAlbum => 'Artist or album';

  @override
  String get templateListeningToMusicEnjoyed => 'Enjoyed';

  @override
  String get templateCategoryFriendsAndCommunity => 'Friends & community';

  @override
  String get templateTimeWithFriends => 'Time with friends';

  @override
  String get templateTimeWithFriendsWho => 'Who';

  @override
  String get templateTimeWithFriendsWhatWeDid => 'What we did';

  @override
  String get templateTimeWithFriendsHowItFelt => 'How it felt';

  @override
  String get templatePhoneCall => 'Phone call';

  @override
  String get templatePhoneCallWho => 'Who';

  @override
  String get templatePhoneCallTalkedAbout => 'Talked about';

  @override
  String get templatePhoneCallFollowUpNeeded => 'Follow up needed';

  @override
  String get templateDateNight => 'Date night';

  @override
  String get templateDateNightWhere => 'Where';

  @override
  String get templateDateNightWhatWeDid => 'What we did';

  @override
  String get templateDateNightRating => 'Rating';

  @override
  String get templateEvent => 'Event';

  @override
  String get templateEventEvent => 'Event';

  @override
  String get templateEventWhere => 'Where';

  @override
  String get templateEventHowItWas => 'How it was';

  @override
  String get templateVolunteering => 'Volunteering';

  @override
  String get templateVolunteeringOrganization => 'Organization';

  @override
  String get templateVolunteeringWhatIDid => 'What I did';

  @override
  String get templateVolunteeringPeopleHelped => 'People helped';

  @override
  String get templatePrayerAndWorship => 'Prayer & worship';

  @override
  String get templatePrayerAndWorshipPracticeOrPlace => 'Practice or place';

  @override
  String get templatePrayerAndWorshipReflection => 'Reflection';

  @override
  String get templateDonation => 'Donation';

  @override
  String get templateDonationCause => 'Cause';

  @override
  String get templateDonationAmount => 'Amount';

  @override
  String get templateCategoryTravelAndErrands => 'Travel & errands';

  @override
  String get templateErrands => 'Errands';

  @override
  String get templateErrandsErrands => 'Errands';

  @override
  String get templateErrandsErrandsItem => 'Errand';

  @override
  String get templateErrandsErrandsErrand => 'Errand';

  @override
  String get templateErrandsErrandsDone => 'Done';

  @override
  String get templateAppointment => 'Appointment';

  @override
  String get templateAppointmentWith => 'With';

  @override
  String get templateAppointmentPurpose => 'Purpose';

  @override
  String get templateAppointmentNextAppointment => 'Next appointment';

  @override
  String get templateDriving => 'Driving';

  @override
  String get templateDrivingDistance => 'Distance';

  @override
  String get templateDrivingFuel => 'Fuel';

  @override
  String get templateDrivingPurpose => 'Purpose';

  @override
  String get templateTrip => 'Trip';

  @override
  String get templateTripDestination => 'Destination';

  @override
  String get templateTripTravelBy => 'Travel by';

  @override
  String get templateTripTravelByPlane => 'Plane';

  @override
  String get templateTripTravelByTrain => 'Train';

  @override
  String get templateTripTravelByCar => 'Car';

  @override
  String get templateTripTravelByBus => 'Bus';

  @override
  String get templateTripTravelByBoat => 'Boat';

  @override
  String get templateTripHighlights => 'Highlights';

  @override
  String get templatePacking => 'Packing';

  @override
  String get templatePackingPackingList => 'Packing list';

  @override
  String get templatePackingPackingListItem => 'Item';

  @override
  String get templatePackingPackingListDone => 'Done';

  @override
  String get templateAyurvedicMorning => 'Ayurvedic morning';

  @override
  String get templateAyurvedicMorningUpBeforeSunrise => 'Up before sunrise';

  @override
  String get templateAyurvedicMorningPractices => 'Practices';

  @override
  String get templateAyurvedicMorningPracticesTongueScraping =>
      'Tongue scraping';

  @override
  String get templateAyurvedicMorningPracticesOilPulling => 'Oil pulling';

  @override
  String get templateAyurvedicMorningPracticesAbhyanga => 'Abhyanga';

  @override
  String get templateAyurvedicMorningPracticesWarmWater => 'Warm water';

  @override
  String get templateAyurvedicMorningPracticesNeti => 'Neti';

  @override
  String get templateAyurvedicMorningFeltAfter => 'Felt after';

  @override
  String get templateHairOiling => 'Hair oiling';

  @override
  String get templateHairOilingOil => 'Oil';

  @override
  String get templateHairOilingLeftOnOvernight => 'Left on overnight';

  @override
  String get templateMassageAndSpa => 'Massage & spa';

  @override
  String get templateMassageAndSpaKind => 'Kind';

  @override
  String get templateMassageAndSpaKindMassage => 'Massage';

  @override
  String get templateMassageAndSpaKindSpa => 'Spa';

  @override
  String get templateMassageAndSpaKindFacial => 'Facial';

  @override
  String get templateMassageAndSpaKindFootMassage => 'Foot massage';

  @override
  String get templateMassageAndSpaKindSelfMassage => 'Self-massage';

  @override
  String get templateMassageAndSpaFeltAfter => 'Felt after';

  @override
  String get templateMassageAndSpaCost => 'Cost';

  @override
  String get templateSaunaAndColdPlunge => 'Sauna & cold plunge';

  @override
  String get templateSaunaAndColdPlungeKind => 'Kind';

  @override
  String get templateSaunaAndColdPlungeKindSauna => 'Sauna';

  @override
  String get templateSaunaAndColdPlungeKindColdPlunge => 'Cold plunge';

  @override
  String get templateSaunaAndColdPlungeKindSteamRoom => 'Steam room';

  @override
  String get templateSaunaAndColdPlungeKindContrast => 'Contrast';

  @override
  String get templateSaunaAndColdPlungeRounds => 'Rounds';

  @override
  String get templateSaunaAndColdPlungeTemperature => 'Temperature';

  @override
  String get templatePain => 'Pain';

  @override
  String get templatePainWhere => 'Where';

  @override
  String get templatePainWhereHead => 'Head';

  @override
  String get templatePainWhereNeck => 'Neck';

  @override
  String get templatePainWhereBack => 'Back';

  @override
  String get templatePainWhereJoints => 'Joints';

  @override
  String get templatePainWhereStomach => 'Stomach';

  @override
  String get templatePainWhereMuscles => 'Muscles';

  @override
  String get templatePainLevel => 'Level';

  @override
  String get templatePainPossibleTrigger => 'Possible trigger';

  @override
  String get templateDigestion => 'Digestion';

  @override
  String get templateDigestionType => 'Type';

  @override
  String get templateDigestionTypeHard => 'Hard';

  @override
  String get templateDigestionTypeNormal => 'Normal';

  @override
  String get templateDigestionTypeSoft => 'Soft';

  @override
  String get templateDigestionTypeLoose => 'Loose';

  @override
  String get templateDigestionBloating => 'Bloating';

  @override
  String get templateDigestionNotes => 'Notes';

  @override
  String get templateEnergyCheck => 'Energy check';

  @override
  String get templateEnergyCheckEnergy => 'Energy';

  @override
  String get templateEnergyCheckFocus => 'Focus';

  @override
  String get templateProtein => 'Protein';

  @override
  String get templateProteinProtein => 'Protein';

  @override
  String get templateFruitAndVeg => 'Fruit & veg';

  @override
  String get templateFruitAndVegPortions => 'Portions';

  @override
  String get templateFruitAndVegColoursEaten => 'Colours eaten';

  @override
  String get templateFruitAndVegColoursEatenGreen => 'Green';

  @override
  String get templateFruitAndVegColoursEatenRed => 'Red';

  @override
  String get templateFruitAndVegColoursEatenOrange => 'Orange';

  @override
  String get templateFruitAndVegColoursEatenYellow => 'Yellow';

  @override
  String get templateFruitAndVegColoursEatenPurple => 'Purple';

  @override
  String get templateFruitAndVegColoursEatenWhite => 'White';

  @override
  String get templatePackedLunch => 'Packed lunch';

  @override
  String get templatePackedLunchFor => 'For';

  @override
  String get templatePackedLunchWhatWentIn => 'What went in';

  @override
  String get templatePackedLunchEaten => 'Eaten';

  @override
  String get templateHouseHelp => 'House help';

  @override
  String get templateHouseHelpWho => 'Who';

  @override
  String get templateHouseHelpCameToday => 'Came today';

  @override
  String get templateHouseHelpTasks => 'Tasks';

  @override
  String get templateHouseHelpTasksSweeping => 'Sweeping';

  @override
  String get templateHouseHelpTasksMopping => 'Mopping';

  @override
  String get templateHouseHelpTasksDishes => 'Dishes';

  @override
  String get templateHouseHelpTasksLaundry => 'Laundry';

  @override
  String get templateHouseHelpTasksCooking => 'Cooking';

  @override
  String get templateHouseHelpTasksDusting => 'Dusting';

  @override
  String get templateHouseHelpPaid => 'Paid';

  @override
  String get templateCarCare => 'Car care';

  @override
  String get templateCarCareWhat => 'What';

  @override
  String get templateCarCareWhatFuel => 'Fuel';

  @override
  String get templateCarCareWhatWash => 'Wash';

  @override
  String get templateCarCareWhatService => 'Service';

  @override
  String get templateCarCareWhatTyres => 'Tyres';

  @override
  String get templateCarCareWhatOilChange => 'Oil change';

  @override
  String get templateCarCareWhatRepair => 'Repair';

  @override
  String get templateCarCareOdometer => 'Odometer';

  @override
  String get templateCarCareCost => 'Cost';

  @override
  String get templateCategoryMoney => 'Money';

  @override
  String get templateInvesting => 'Investing';

  @override
  String get templateInvestingFundOrAsset => 'Fund or asset';

  @override
  String get templateInvestingKind => 'Kind';

  @override
  String get templateInvestingKindBuy => 'Buy';

  @override
  String get templateInvestingKindSell => 'Sell';

  @override
  String get templateInvestingKindSIP => 'SIP';

  @override
  String get templateInvestingKindDeposit => 'Deposit';

  @override
  String get templateInvestingKindDividend => 'Dividend';

  @override
  String get templateInvestingAmount => 'Amount';

  @override
  String get templateSavings => 'Savings';

  @override
  String get templateSavingsGoal => 'Goal';

  @override
  String get templateSavingsAdded => 'Added';

  @override
  String get templateSavingsTotalSoFar => 'Total so far';

  @override
  String get templateSchoolRun => 'School run';

  @override
  String get templateSchoolRunChild => 'Child';

  @override
  String get templateSchoolRunHow => 'How';

  @override
  String get templateSchoolRunHowCar => 'Car';

  @override
  String get templateSchoolRunHowWalk => 'Walk';

  @override
  String get templateSchoolRunHowBus => 'Bus';

  @override
  String get templateSchoolRunHowBike => 'Bike';

  @override
  String get templateSchoolRunHowAuto => 'Auto';

  @override
  String get templateSchoolRunHowSchoolVan => 'School van';

  @override
  String get templateSchoolRunOnTime => 'On time';

  @override
  String get templateClientWork => 'Client work';

  @override
  String get templateClientWorkClient => 'Client';

  @override
  String get templateClientWorkTask => 'Task';

  @override
  String get templateClientWorkBillable => 'Billable';

  @override
  String get templateShift => 'Shift';

  @override
  String get templateShiftShift => 'Shift';

  @override
  String get templateShiftShiftMorning => 'Morning';

  @override
  String get templateShiftShiftDay => 'Day';

  @override
  String get templateShiftShiftEvening => 'Evening';

  @override
  String get templateShiftShiftNight => 'Night';

  @override
  String get templateShiftShiftSplit => 'Split';

  @override
  String get templateShiftTookABreak => 'Took a break';

  @override
  String get templateShiftEarned => 'Earned';

  @override
  String get templateGigWork => 'Gig work';

  @override
  String get templateGigWorkPlatform => 'Platform';

  @override
  String get templateGigWorkTripsOrOrders => 'Trips or orders';

  @override
  String get templateGigWorkEarned => 'Earned';

  @override
  String get templateGigWorkDistance => 'Distance';

  @override
  String get templateNetworking => 'Networking';

  @override
  String get templateNetworkingPerson => 'Person';

  @override
  String get templateNetworkingWhereWeMet => 'Where we met';

  @override
  String get templateNetworkingFollowUpOn => 'Follow up on';

  @override
  String get templateWeeklyReview => 'Weekly review';

  @override
  String get templateWeeklyReviewWins => 'Wins';

  @override
  String get templateWeeklyReviewLessons => 'Lessons';

  @override
  String get templateWeeklyReviewNextWeek => 'Next week';

  @override
  String get templateWeeklyReviewNextWeekItem => 'Priority';

  @override
  String get templateWeeklyReviewNextWeekPriority => 'Priority';

  @override
  String get templateWeeklyReviewNextWeekDone => 'Done';

  @override
  String get templateGoalCheckIn => 'Goal check-in';

  @override
  String get templateGoalCheckInGoal => 'Goal';

  @override
  String get templateGoalCheckInProgress => 'Progress';

  @override
  String get templateGoalCheckInNextStep => 'Next step';

  @override
  String get templateTuition => 'Tuition';

  @override
  String get templateTuitionSubject => 'Subject';

  @override
  String get templateTuitionTopic => 'Topic';

  @override
  String get templateTuitionTestScore => 'Test score';

  @override
  String get templateExamPrep => 'Exam prep';

  @override
  String get templateExamPrepExam => 'Exam';

  @override
  String get templateExamPrepTopicsCovered => 'Topics covered';

  @override
  String get templateExamPrepMockTestScore => 'Mock test score';

  @override
  String get templateExamPrepConfidence => 'Confidence';

  @override
  String get templateFlashcards => 'Flashcards';

  @override
  String get templateFlashcardsDeck => 'Deck';

  @override
  String get templateFlashcardsCardsReviewed => 'Cards reviewed';

  @override
  String get templateFlashcardsCorrect => 'Correct';

  @override
  String get templateTeaching => 'Teaching';

  @override
  String get templateTeachingTopic => 'Topic';

  @override
  String get templateTeachingStudents => 'Students';

  @override
  String get templateTeachingHowItWent => 'How it went';

  @override
  String get templateSuryaNamaskar => 'Surya namaskar';

  @override
  String get templateSuryaNamaskarRounds => 'Rounds';

  @override
  String get templateSuryaNamaskarFeltAfter => 'Felt after';

  @override
  String get templatePilates => 'Pilates';

  @override
  String get templatePilatesKind => 'Kind';

  @override
  String get templatePilatesKindMat => 'Mat';

  @override
  String get templatePilatesKindReformer => 'Reformer';

  @override
  String get templatePilatesFeltAfter => 'Felt after';

  @override
  String get templateClimbing => 'Climbing';

  @override
  String get templateClimbingKind => 'Kind';

  @override
  String get templateClimbingKindBouldering => 'Bouldering';

  @override
  String get templateClimbingKindTopRope => 'Top rope';

  @override
  String get templateClimbingKindLead => 'Lead';

  @override
  String get templateClimbingKindOutdoor => 'Outdoor';

  @override
  String get templateClimbingRoutes => 'Routes';

  @override
  String get templateClimbingHardestGrade => 'Hardest grade';

  @override
  String get templateMartialArts => 'Martial arts';

  @override
  String get templateMartialArtsStyle => 'Style';

  @override
  String get templateMartialArtsTechniques => 'Techniques';

  @override
  String get templateMartialArtsSparringRounds => 'Sparring rounds';

  @override
  String get templateGolf => 'Golf';

  @override
  String get templateGolfCourse => 'Course';

  @override
  String get templateGolfHoles => 'Holes';

  @override
  String get templateGolfHoles9 => '9';

  @override
  String get templateGolfHoles18 => '18';

  @override
  String get templateGolfScore => 'Score';

  @override
  String get templateWinterSports => 'Winter sports';

  @override
  String get templateWinterSportsKind => 'Kind';

  @override
  String get templateWinterSportsKindSkiing => 'Skiing';

  @override
  String get templateWinterSportsKindSnowboarding => 'Snowboarding';

  @override
  String get templateWinterSportsKindIceSkating => 'Ice skating';

  @override
  String get templateWinterSportsKindSledging => 'Sledging';

  @override
  String get templateWinterSportsRuns => 'Runs';

  @override
  String get templateWinterSportsWhere => 'Where';

  @override
  String get templatePranayama => 'Pranayama';

  @override
  String get templatePranayamaTechnique => 'Technique';

  @override
  String get templatePranayamaTechniqueAnulomVilom => 'Anulom vilom';

  @override
  String get templatePranayamaTechniqueKapalbhati => 'Kapalbhati';

  @override
  String get templatePranayamaTechniqueBhramari => 'Bhramari';

  @override
  String get templatePranayamaTechniqueBhastrika => 'Bhastrika';

  @override
  String get templatePranayamaTechniqueUjjayi => 'Ujjayi';

  @override
  String get templatePranayamaRounds => 'Rounds';

  @override
  String get templateTimeOutdoors => 'Time outdoors';

  @override
  String get templateTimeOutdoorsWhere => 'Where';

  @override
  String get templateTimeOutdoorsMorningSunlight => 'Morning sunlight';

  @override
  String get templateTimeOutdoorsFeltAfter => 'Felt after';

  @override
  String get templateSocialMedia => 'Social media';

  @override
  String get templateSocialMediaApps => 'Apps';

  @override
  String get templateSocialMediaAppsInstagram => 'Instagram';

  @override
  String get templateSocialMediaAppsYouTube => 'YouTube';

  @override
  String get templateSocialMediaAppsTikTok => 'TikTok';

  @override
  String get templateSocialMediaAppsWhatsApp => 'WhatsApp';

  @override
  String get templateSocialMediaAppsFacebook => 'Facebook';

  @override
  String get templateSocialMediaAppsX => 'X';

  @override
  String get templateSocialMediaAppsReddit => 'Reddit';

  @override
  String get templateSocialMediaAppsSnapchat => 'Snapchat';

  @override
  String get templateSocialMediaTimeSpent => 'Time spent';

  @override
  String get templateSocialMediaFeltAfter => 'Felt after';

  @override
  String get templateNews => 'News';

  @override
  String get templateNewsSource => 'Source';

  @override
  String get templateNewsWhatStoodOut => 'What stood out';

  @override
  String get templateKindAct => 'Kind act';

  @override
  String get templateKindActWhatIDid => 'What I did';

  @override
  String get templateKindActForWhom => 'For whom';

  @override
  String get templateCategoryFaithAndSpirituality => 'Faith & spirituality';

  @override
  String get templatePuja => 'Puja';

  @override
  String get templatePujaDeityOrOccasion => 'Deity or occasion';

  @override
  String get templatePujaOfferings => 'Offerings';

  @override
  String get templatePujaOfferingsFlowers => 'Flowers';

  @override
  String get templatePujaOfferingsDiya => 'Diya';

  @override
  String get templatePujaOfferingsIncense => 'Incense';

  @override
  String get templatePujaOfferingsPrasad => 'Prasad';

  @override
  String get templatePujaOfferingsAarti => 'Aarti';

  @override
  String get templatePujaWithFamily => 'With family';

  @override
  String get templateSalah => 'Salah';

  @override
  String get templateSalahPrayers => 'Prayers';

  @override
  String get templateSalahPrayersFajr => 'Fajr';

  @override
  String get templateSalahPrayersDhuhr => 'Dhuhr';

  @override
  String get templateSalahPrayersAsr => 'Asr';

  @override
  String get templateSalahPrayersMaghrib => 'Maghrib';

  @override
  String get templateSalahPrayersIsha => 'Isha';

  @override
  String get templateSalahOnTime => 'On time';

  @override
  String get templateSalahAtTheMosque => 'At the mosque';

  @override
  String get templateScriptureReading => 'Scripture reading';

  @override
  String get templateScriptureReadingText => 'Text';

  @override
  String get templateScriptureReadingPassage => 'Passage';

  @override
  String get templateScriptureReadingReflection => 'Reflection';

  @override
  String get templateChanting => 'Chanting';

  @override
  String get templateChantingMantra => 'Mantra';

  @override
  String get templateChantingMalas => 'Malas';

  @override
  String get templateChantingCount => 'Count';

  @override
  String get templateReligiousFast => 'Religious fast';

  @override
  String get templateReligiousFastOccasion => 'Occasion';

  @override
  String get templateReligiousFastKind => 'Kind';

  @override
  String get templateReligiousFastKindSunriseToSunset => 'Sunrise to sunset';

  @override
  String get templateReligiousFastKindWaterOnly => 'Water only';

  @override
  String get templateReligiousFastKindFruitAndMilk => 'Fruit and milk';

  @override
  String get templateReligiousFastKindOneMeal => 'One meal';

  @override
  String get templateReligiousFastKindNoWater => 'No water';

  @override
  String get templateReligiousFastBrokeTheFastAt => 'Broke the fast at';

  @override
  String get templateWatchingSport => 'Watching sport';

  @override
  String get templateWatchingSportMatch => 'Match';

  @override
  String get templateWatchingSportTeam => 'Team';

  @override
  String get templateWatchingSportResult => 'Result';

  @override
  String get templateWatchingSportResultWon => 'Won';

  @override
  String get templateWatchingSportResultLost => 'Lost';

  @override
  String get templateWatchingSportResultDraw => 'Draw';

  @override
  String get templateWatchingSportResultNoResult => 'No result';

  @override
  String get templateFishing => 'Fishing';

  @override
  String get templateFishingSpot => 'Spot';

  @override
  String get templateFishingCatch => 'Catch';

  @override
  String get templateFishingCatchItem => 'Fish';

  @override
  String get templateFishingCatchFish => 'Fish';

  @override
  String get templateFishingCatchWeight => 'Weight';

  @override
  String get templateContentCreation => 'Content creation';

  @override
  String get templateContentCreationPlatform => 'Platform';

  @override
  String get templateContentCreationPlatformYouTube => 'YouTube';

  @override
  String get templateContentCreationPlatformInstagram => 'Instagram';

  @override
  String get templateContentCreationPlatformTikTok => 'TikTok';

  @override
  String get templateContentCreationPlatformBlog => 'Blog';

  @override
  String get templateContentCreationPlatformPodcast => 'Podcast';

  @override
  String get templateContentCreationPlatformOther => 'Other';

  @override
  String get templateContentCreationPiece => 'Piece';

  @override
  String get templateContentCreationViews => 'Views';
}
