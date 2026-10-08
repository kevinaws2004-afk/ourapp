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
  String get navChallenges => 'Challenges';

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
  String get activitiesBrowseTitle => 'Choose an activity';

  @override
  String get activitiesBrowseSubtitle =>
      'Use any of these as it is, change it later, or make your own.';

  @override
  String get activitiesSearchHint => 'Search activities';

  @override
  String get activitiesNoMatch => 'No activity matches. Make your own instead.';

  @override
  String get builtInReading => 'Reading';

  @override
  String get builtInReadingBook => 'Book';

  @override
  String get builtInReadingPages => 'Pages';

  @override
  String get builtInReadingRating => 'Rating';

  @override
  String get builtInFocusedWork => 'Focused work';

  @override
  String get builtInFocusedWorkProject => 'Project';

  @override
  String get builtInWalking => 'Walking';

  @override
  String get builtInWalkingDistance => 'Distance';

  @override
  String get builtInWalkingSteps => 'Steps';

  @override
  String get builtInWalkingCalories => 'Calories';

  @override
  String get builtInWalkingLocation => 'Location';

  @override
  String get builtInLanguage => 'Language learning';

  @override
  String get builtInLanguageLanguage => 'Language';

  @override
  String get builtInLanguageWords => 'Words learned';

  @override
  String get builtInLanguageLesson => 'Lesson';

  @override
  String get builtInLanguageDifficulty => 'Difficulty';

  @override
  String get builtInLanguageSpanish => 'Spanish';

  @override
  String get builtInLanguageFrench => 'French';

  @override
  String get builtInLanguageGerman => 'German';

  @override
  String get builtInLanguageJapanese => 'Japanese';

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
      'Everything you can plan and record. Use any of them as it is, change it, or make your own.';

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
  String get builtInGym => 'Gym';

  @override
  String get builtInGymExercises => 'Exercises';

  @override
  String get builtInGymExerciseItem => 'Exercise';

  @override
  String get builtInGymExercise => 'Exercise';

  @override
  String get builtInGymSets => 'Sets';

  @override
  String get builtInGymSetItem => 'Set';

  @override
  String get builtInGymWeight => 'Weight';

  @override
  String get builtInGymReps => 'Reps';

  @override
  String get builtInMeeting => 'Meeting';

  @override
  String get builtInMeetingPeople => 'People';

  @override
  String get builtInMeetingTopics => 'Topics';

  @override
  String get builtInMeetingDecisions => 'Decisions';

  @override
  String get builtInMeetingActionItems => 'Action items';

  @override
  String get builtInMeetingActionItem => 'Action item';

  @override
  String get builtInMeetingActionItemText => 'Item';

  @override
  String get builtInMeetingActionItemDone => 'Done';

  @override
  String get builtInCooking => 'Cooking';

  @override
  String get builtInCookingRecipe => 'Recipe';

  @override
  String get builtInCookingServings => 'Servings';

  @override
  String get builtInCookingCalories => 'Calories';

  @override
  String get builtInCookingRating => 'Rating';

  @override
  String get builtInCookingIngredients => 'Ingredients';

  @override
  String get builtInCookingIngredientItem => 'Ingredient';

  @override
  String get builtInCookingIngredient => 'Ingredient';

  @override
  String get builtInCookingHaveIt => 'Have it';

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
  String get planBrowseActivities => 'Browse activities';

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
  String get builtInGymFocus => 'Workout';

  @override
  String get builtInGymPush => 'Push';

  @override
  String get builtInGymPull => 'Pull';

  @override
  String get builtInGymLegs => 'Legs';

  @override
  String get builtInGymUpperBody => 'Upper body';

  @override
  String get builtInGymLowerBody => 'Lower body';

  @override
  String get builtInGymFullBody => 'Full body';

  @override
  String get builtInGymCardio => 'Cardio';

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
    return 'Nothing logged for $name in this period. Pick a longer period above to see its progress.';
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
  String get builtInRunning => 'Running';

  @override
  String get builtInRunningDistance => 'Distance';

  @override
  String get builtInRunningRoute => 'Route';

  @override
  String get builtInRunningFelt => 'How it felt';

  @override
  String get builtInStudy => 'Study';

  @override
  String get builtInStudySubject => 'Subject';

  @override
  String get builtInStudyCovered => 'What I covered';

  @override
  String get builtInStudyFocus => 'Focus';

  @override
  String get builtInMeditation => 'Meditation';

  @override
  String get builtInMeditationKind => 'Kind';

  @override
  String get builtInMeditationBreathing => 'Breathing';

  @override
  String get builtInMeditationBodyScan => 'Body scan';

  @override
  String get builtInMeditationGuided => 'Guided';

  @override
  String get builtInMeditationSilent => 'Silent';

  @override
  String get builtInMeditationCalm => 'Calm afterwards';

  @override
  String get builtInWater => 'Water';

  @override
  String get builtInWaterGlasses => 'Glasses';

  @override
  String get builtInSleep => 'Sleep';

  @override
  String get builtInSleepQuality => 'Quality';

  @override
  String get builtInSleepWokeUp => 'Woke up in the night';

  @override
  String get builtInMood => 'Mood';

  @override
  String get builtInMoodRating => 'Mood';

  @override
  String get builtInMoodFeelings => 'Feelings';

  @override
  String get builtInMoodCalm => 'Calm';

  @override
  String get builtInMoodHappy => 'Happy';

  @override
  String get builtInMoodEnergetic => 'Energetic';

  @override
  String get builtInMoodTired => 'Tired';

  @override
  String get builtInMoodStressed => 'Stressed';

  @override
  String get builtInMoodAnxious => 'Anxious';

  @override
  String activityPreviewUse(String name) {
    return 'Use $name';
  }

  @override
  String get activityPreviewYoullLog => 'What you\'ll log';

  @override
  String get builtInCategorySleepAndSelfCare => 'Sleep & self-care';

  @override
  String get builtInNap => 'Nap';

  @override
  String get builtInNapFeltAfter => 'Felt after';

  @override
  String get builtInMorningRoutine => 'Morning routine';

  @override
  String get builtInMorningRoutineWokeUpAt => 'Woke up at';

  @override
  String get builtInMorningRoutineSteps => 'Steps';

  @override
  String get builtInMorningRoutineStepsItem => 'Step';

  @override
  String get builtInMorningRoutineStepsStep => 'Step';

  @override
  String get builtInMorningRoutineStepsDone => 'Done';

  @override
  String get builtInMorningRoutineEnergy => 'Energy';

  @override
  String get builtInEveningRoutine => 'Evening routine';

  @override
  String get builtInEveningRoutineLightsOutAt => 'Lights out at';

  @override
  String get builtInEveningRoutineSteps => 'Steps';

  @override
  String get builtInEveningRoutineStepsItem => 'Step';

  @override
  String get builtInEveningRoutineStepsStep => 'Step';

  @override
  String get builtInEveningRoutineStepsDone => 'Done';

  @override
  String get builtInEveningRoutineScreensOffAnHourBefore =>
      'Screens off an hour before';

  @override
  String get builtInShower => 'Shower';

  @override
  String get builtInShowerKind => 'Kind';

  @override
  String get builtInShowerKindShower => 'Shower';

  @override
  String get builtInShowerKindBath => 'Bath';

  @override
  String get builtInShowerKindColdShower => 'Cold shower';

  @override
  String get builtInShowerFeltAfter => 'Felt after';

  @override
  String get builtInSkincare => 'Skincare';

  @override
  String get builtInSkincareProducts => 'Products';

  @override
  String get builtInSkincareProductsCleanser => 'Cleanser';

  @override
  String get builtInSkincareProductsToner => 'Toner';

  @override
  String get builtInSkincareProductsSerum => 'Serum';

  @override
  String get builtInSkincareProductsMoisturizer => 'Moisturizer';

  @override
  String get builtInSkincareProductsSunscreen => 'Sunscreen';

  @override
  String get builtInSkincareProductsMask => 'Mask';

  @override
  String get builtInSkincareSkinToday => 'Skin today';

  @override
  String get builtInOralCare => 'Oral care';

  @override
  String get builtInOralCareBrushed => 'Brushed';

  @override
  String get builtInOralCareFlossed => 'Flossed';

  @override
  String get builtInOralCareMouthwash => 'Mouthwash';

  @override
  String get builtInGrooming => 'Grooming';

  @override
  String get builtInGroomingWhat => 'What';

  @override
  String get builtInGroomingWhatHaircut => 'Haircut';

  @override
  String get builtInGroomingWhatShave => 'Shave';

  @override
  String get builtInGroomingWhatBeardTrim => 'Beard trim';

  @override
  String get builtInGroomingWhatNails => 'Nails';

  @override
  String get builtInGroomingWhatHairWash => 'Hair wash';

  @override
  String get builtInGroomingCost => 'Cost';

  @override
  String get builtInCategoryHealth => 'Health';

  @override
  String get builtInMedication => 'Medication';

  @override
  String get builtInMedicationMedicine => 'Medicine';

  @override
  String get builtInMedicationDose => 'Dose';

  @override
  String get builtInMedicationTaken => 'Taken';

  @override
  String get builtInMedicationSideEffects => 'Side effects';

  @override
  String get builtInVitaminsAndSupplements => 'Vitamins & supplements';

  @override
  String get builtInVitaminsAndSupplementsSupplements => 'Supplements';

  @override
  String get builtInVitaminsAndSupplementsSupplementsItem => 'Supplement';

  @override
  String get builtInVitaminsAndSupplementsSupplementsSupplement => 'Supplement';

  @override
  String get builtInVitaminsAndSupplementsSupplementsTaken => 'Taken';

  @override
  String get builtInDoctorVisit => 'Doctor visit';

  @override
  String get builtInDoctorVisitDoctorOrClinic => 'Doctor or clinic';

  @override
  String get builtInDoctorVisitReason => 'Reason';

  @override
  String get builtInDoctorVisitWhatTheySaid => 'What they said';

  @override
  String get builtInDoctorVisitNextVisit => 'Next visit';

  @override
  String get builtInSymptoms => 'Symptoms';

  @override
  String get builtInSymptomsSymptoms => 'Symptoms';

  @override
  String get builtInSymptomsSymptomsHeadache => 'Headache';

  @override
  String get builtInSymptomsSymptomsFever => 'Fever';

  @override
  String get builtInSymptomsSymptomsCough => 'Cough';

  @override
  String get builtInSymptomsSymptomsSoreThroat => 'Sore throat';

  @override
  String get builtInSymptomsSymptomsFatigue => 'Fatigue';

  @override
  String get builtInSymptomsSymptomsNausea => 'Nausea';

  @override
  String get builtInSymptomsSymptomsPain => 'Pain';

  @override
  String get builtInSymptomsSeverity => 'Severity';

  @override
  String get builtInSymptomsNotes => 'Notes';

  @override
  String get builtInBloodPressure => 'Blood pressure';

  @override
  String get builtInBloodPressureSystolic => 'Systolic';

  @override
  String get builtInBloodPressureDiastolic => 'Diastolic';

  @override
  String get builtInBloodPressurePulse => 'Pulse';

  @override
  String get builtInBloodSugar => 'Blood sugar';

  @override
  String get builtInBloodSugarReading => 'Reading';

  @override
  String get builtInBloodSugarWhen => 'When';

  @override
  String get builtInBloodSugarWhenFasting => 'Fasting';

  @override
  String get builtInBloodSugarWhenBeforeAMeal => 'Before a meal';

  @override
  String get builtInBloodSugarWhenAfterAMeal => 'After a meal';

  @override
  String get builtInBloodSugarWhenBedtime => 'Bedtime';

  @override
  String get builtInBodyTemperature => 'Body temperature';

  @override
  String get builtInBodyTemperatureTemperature => 'Temperature';

  @override
  String get builtInPeriod => 'Period';

  @override
  String get builtInPeriodFlow => 'Flow';

  @override
  String get builtInPeriodFlowSpotting => 'Spotting';

  @override
  String get builtInPeriodFlowLight => 'Light';

  @override
  String get builtInPeriodFlowMedium => 'Medium';

  @override
  String get builtInPeriodFlowHeavy => 'Heavy';

  @override
  String get builtInPeriodSymptoms => 'Symptoms';

  @override
  String get builtInPeriodSymptomsCramps => 'Cramps';

  @override
  String get builtInPeriodSymptomsBloating => 'Bloating';

  @override
  String get builtInPeriodSymptomsHeadache => 'Headache';

  @override
  String get builtInPeriodSymptomsMoodSwings => 'Mood swings';

  @override
  String get builtInPeriodSymptomsFatigue => 'Fatigue';

  @override
  String get builtInPeriodSymptomsCravings => 'Cravings';

  @override
  String get builtInPeriodNotes => 'Notes';

  @override
  String get builtInPhysiotherapy => 'Physiotherapy';

  @override
  String get builtInPhysiotherapyExercises => 'Exercises';

  @override
  String get builtInPhysiotherapyExercisesItem => 'Exercise';

  @override
  String get builtInPhysiotherapyExercisesExercise => 'Exercise';

  @override
  String get builtInPhysiotherapyExercisesDone => 'Done';

  @override
  String get builtInPhysiotherapyPainLevel => 'Pain level';

  @override
  String get builtInCategoryFoodAndDrink => 'Food & drink';

  @override
  String get builtInMeal => 'Meal';

  @override
  String get builtInMealMeal => 'Meal';

  @override
  String get builtInMealMealBreakfast => 'Breakfast';

  @override
  String get builtInMealMealLunch => 'Lunch';

  @override
  String get builtInMealMealDinner => 'Dinner';

  @override
  String get builtInMealMealSnack => 'Snack';

  @override
  String get builtInMealWhatIAte => 'What I ate';

  @override
  String get builtInMealCalories => 'Calories';

  @override
  String get builtInMealHowHealthy => 'How healthy';

  @override
  String get builtInMealAteOut => 'Ate out';

  @override
  String get builtInCoffeeAndTea => 'Coffee & tea';

  @override
  String get builtInCoffeeAndTeaDrink => 'Drink';

  @override
  String get builtInCoffeeAndTeaDrinkCoffee => 'Coffee';

  @override
  String get builtInCoffeeAndTeaDrinkEspresso => 'Espresso';

  @override
  String get builtInCoffeeAndTeaDrinkTea => 'Tea';

  @override
  String get builtInCoffeeAndTeaDrinkGreenTea => 'Green tea';

  @override
  String get builtInCoffeeAndTeaDrinkHerbalTea => 'Herbal tea';

  @override
  String get builtInCoffeeAndTeaCups => 'Cups';

  @override
  String get builtInFasting => 'Fasting';

  @override
  String get builtInFastingPlan => 'Plan';

  @override
  String get builtInFastingPlan1212 => '12:12';

  @override
  String get builtInFastingPlan168 => '16:8';

  @override
  String get builtInFastingPlan186 => '18:6';

  @override
  String get builtInFastingPlan204 => '20:4';

  @override
  String get builtInFastingPlan24Hours => '24 hours';

  @override
  String get builtInFastingBrokeTheFastAt => 'Broke the fast at';

  @override
  String get builtInFastingHowItFelt => 'How it felt';

  @override
  String get builtInAlcohol => 'Alcohol';

  @override
  String get builtInAlcoholDrinks => 'Drinks';

  @override
  String get builtInAlcoholKind => 'Kind';

  @override
  String get builtInAlcoholKindBeer => 'Beer';

  @override
  String get builtInAlcoholKindWine => 'Wine';

  @override
  String get builtInAlcoholKindSpirits => 'Spirits';

  @override
  String get builtInAlcoholKindCocktail => 'Cocktail';

  @override
  String get builtInAlcoholKindCider => 'Cider';

  @override
  String get builtInMealPrep => 'Meal prep';

  @override
  String get builtInMealPrepDishes => 'Dishes';

  @override
  String get builtInMealPrepDishesItem => 'Dish';

  @override
  String get builtInMealPrepDishesDish => 'Dish';

  @override
  String get builtInMealPrepDishesPortions => 'Portions';

  @override
  String get builtInCategoryHomeAndChores => 'Home & chores';

  @override
  String get builtInCleaning => 'Cleaning';

  @override
  String get builtInCleaningRooms => 'Rooms';

  @override
  String get builtInCleaningRoomsKitchen => 'Kitchen';

  @override
  String get builtInCleaningRoomsBathroom => 'Bathroom';

  @override
  String get builtInCleaningRoomsBedroom => 'Bedroom';

  @override
  String get builtInCleaningRoomsLivingRoom => 'Living room';

  @override
  String get builtInCleaningRoomsWholeHome => 'Whole home';

  @override
  String get builtInCleaningTasks => 'Tasks';

  @override
  String get builtInCleaningTasksItem => 'Task';

  @override
  String get builtInCleaningTasksTask => 'Task';

  @override
  String get builtInCleaningTasksDone => 'Done';

  @override
  String get builtInLaundry => 'Laundry';

  @override
  String get builtInLaundryLoads => 'Loads';

  @override
  String get builtInLaundrySteps => 'Steps';

  @override
  String get builtInLaundryStepsWashed => 'Washed';

  @override
  String get builtInLaundryStepsDried => 'Dried';

  @override
  String get builtInLaundryStepsFolded => 'Folded';

  @override
  String get builtInLaundryStepsIroned => 'Ironed';

  @override
  String get builtInLaundryStepsPutAway => 'Put away';

  @override
  String get builtInDishes => 'Dishes';

  @override
  String get builtInDishesHow => 'How';

  @override
  String get builtInDishesHowByHand => 'By hand';

  @override
  String get builtInDishesHowDishwasher => 'Dishwasher';

  @override
  String get builtInDishesKitchenWiped => 'Kitchen wiped';

  @override
  String get builtInGroceries => 'Groceries';

  @override
  String get builtInGroceriesStore => 'Store';

  @override
  String get builtInGroceriesShoppingList => 'Shopping list';

  @override
  String get builtInGroceriesShoppingListItem => 'Item';

  @override
  String get builtInGroceriesShoppingListGotIt => 'Got it';

  @override
  String get builtInGroceriesSpent => 'Spent';

  @override
  String get builtInGardening => 'Gardening';

  @override
  String get builtInGardeningTasks => 'Tasks';

  @override
  String get builtInGardeningTasksWatering => 'Watering';

  @override
  String get builtInGardeningTasksPlanting => 'Planting';

  @override
  String get builtInGardeningTasksWeeding => 'Weeding';

  @override
  String get builtInGardeningTasksPruning => 'Pruning';

  @override
  String get builtInGardeningTasksMowing => 'Mowing';

  @override
  String get builtInGardeningTasksHarvesting => 'Harvesting';

  @override
  String get builtInGardeningPlants => 'Plants';

  @override
  String get builtInPlantCare => 'Plant care';

  @override
  String get builtInPlantCarePlants => 'Plants';

  @override
  String get builtInPlantCarePlantsItem => 'Plant';

  @override
  String get builtInPlantCarePlantsPlant => 'Plant';

  @override
  String get builtInPlantCarePlantsWatered => 'Watered';

  @override
  String get builtInPlantCarePlantsFed => 'Fed';

  @override
  String get builtInHomeRepair => 'Home repair';

  @override
  String get builtInHomeRepairProject => 'Project';

  @override
  String get builtInHomeRepairWhatWasDone => 'What was done';

  @override
  String get builtInHomeRepairCost => 'Cost';

  @override
  String get builtInDeclutter => 'Declutter';

  @override
  String get builtInDeclutterArea => 'Area';

  @override
  String get builtInDeclutterItemsRemoved => 'Items removed';

  @override
  String get builtInDeclutterWhereTheyWent => 'Where they went';

  @override
  String get builtInDeclutterWhereTheyWentDonated => 'Donated';

  @override
  String get builtInDeclutterWhereTheyWentSold => 'Sold';

  @override
  String get builtInDeclutterWhereTheyWentRecycled => 'Recycled';

  @override
  String get builtInDeclutterWhereTheyWentThrownAway => 'Thrown away';

  @override
  String get builtInBills => 'Bills';

  @override
  String get builtInBillsBills => 'Bills';

  @override
  String get builtInBillsBillsItem => 'Bill';

  @override
  String get builtInBillsBillsBill => 'Bill';

  @override
  String get builtInBillsBillsAmount => 'Amount';

  @override
  String get builtInBillsBillsPaid => 'Paid';

  @override
  String get builtInExpense => 'Expense';

  @override
  String get builtInExpenseAmount => 'Amount';

  @override
  String get builtInExpenseCategory => 'Category';

  @override
  String get builtInExpenseCategoryFood => 'Food';

  @override
  String get builtInExpenseCategoryTransport => 'Transport';

  @override
  String get builtInExpenseCategoryHome => 'Home';

  @override
  String get builtInExpenseCategoryHealth => 'Health';

  @override
  String get builtInExpenseCategoryFun => 'Fun';

  @override
  String get builtInExpenseCategoryShopping => 'Shopping';

  @override
  String get builtInExpenseCategoryBills => 'Bills';

  @override
  String get builtInExpenseCategoryOther => 'Other';

  @override
  String get builtInExpenseWhatFor => 'What for';

  @override
  String get builtInBudgetReview => 'Budget review';

  @override
  String get builtInBudgetReviewSpentThisWeek => 'Spent this week';

  @override
  String get builtInBudgetReviewSaved => 'Saved';

  @override
  String get builtInBudgetReviewOnTrack => 'On track';

  @override
  String get builtInCategoryFamilyAndCare => 'Family & care';

  @override
  String get builtInChildcare => 'Childcare';

  @override
  String get builtInChildcareChild => 'Child';

  @override
  String get builtInChildcareWhatWeDid => 'What we did';

  @override
  String get builtInChildcareWhatWeDidMeals => 'Meals';

  @override
  String get builtInChildcareWhatWeDidSchoolRun => 'School run';

  @override
  String get builtInChildcareWhatWeDidHomework => 'Homework';

  @override
  String get builtInChildcareWhatWeDidPlaytime => 'Playtime';

  @override
  String get builtInChildcareWhatWeDidBath => 'Bath';

  @override
  String get builtInChildcareWhatWeDidBedtime => 'Bedtime';

  @override
  String get builtInChildcareNotes => 'Notes';

  @override
  String get builtInBabyFeeding => 'Baby feeding';

  @override
  String get builtInBabyFeedingKind => 'Kind';

  @override
  String get builtInBabyFeedingKindBreastLeft => 'Breast (left)';

  @override
  String get builtInBabyFeedingKindBreastRight => 'Breast (right)';

  @override
  String get builtInBabyFeedingKindBottle => 'Bottle';

  @override
  String get builtInBabyFeedingKindSolids => 'Solids';

  @override
  String get builtInBabyFeedingAmount => 'Amount';

  @override
  String get builtInBabyFeedingNotes => 'Notes';

  @override
  String get builtInDiaperChange => 'Diaper change';

  @override
  String get builtInDiaperChangeKind => 'Kind';

  @override
  String get builtInDiaperChangeKindWet => 'Wet';

  @override
  String get builtInDiaperChangeKindDirty => 'Dirty';

  @override
  String get builtInDiaperChangeKindBoth => 'Both';

  @override
  String get builtInPetCare => 'Pet care';

  @override
  String get builtInPetCarePet => 'Pet';

  @override
  String get builtInPetCareCare => 'Care';

  @override
  String get builtInPetCareCareFed => 'Fed';

  @override
  String get builtInPetCareCareWalked => 'Walked';

  @override
  String get builtInPetCareCareGroomed => 'Groomed';

  @override
  String get builtInPetCareCarePlayed => 'Played';

  @override
  String get builtInPetCareCareMedicine => 'Medicine';

  @override
  String get builtInPetCareCareVetVisit => 'Vet visit';

  @override
  String get builtInPetCareNotes => 'Notes';

  @override
  String get builtInDogWalk => 'Dog walk';

  @override
  String get builtInDogWalkDog => 'Dog';

  @override
  String get builtInDogWalkDistance => 'Distance';

  @override
  String get builtInFamilyTime => 'Family time';

  @override
  String get builtInFamilyTimeWho => 'Who';

  @override
  String get builtInFamilyTimeWhatWeDid => 'What we did';

  @override
  String get builtInFamilyTimeHowItFelt => 'How it felt';

  @override
  String get builtInCaringForSomeone => 'Caring for someone';

  @override
  String get builtInCaringForSomeoneWho => 'Who';

  @override
  String get builtInCaringForSomeoneHelpGiven => 'Help given';

  @override
  String get builtInCaringForSomeoneHelpGivenCompany => 'Company';

  @override
  String get builtInCaringForSomeoneHelpGivenMeals => 'Meals';

  @override
  String get builtInCaringForSomeoneHelpGivenErrands => 'Errands';

  @override
  String get builtInCaringForSomeoneHelpGivenMedicine => 'Medicine';

  @override
  String get builtInCaringForSomeoneHelpGivenAppointments => 'Appointments';

  @override
  String get builtInCaringForSomeoneNotes => 'Notes';

  @override
  String get builtInCategoryWork => 'Work';

  @override
  String get builtInDailyPlanning => 'Daily planning';

  @override
  String get builtInDailyPlanningTopPriorities => 'Top priorities';

  @override
  String get builtInDailyPlanningTopPrioritiesItem => 'Priority';

  @override
  String get builtInDailyPlanningTopPrioritiesPriority => 'Priority';

  @override
  String get builtInDailyPlanningTopPrioritiesDone => 'Done';

  @override
  String get builtInDailyPlanningNotes => 'Notes';

  @override
  String get builtInCommute => 'Commute';

  @override
  String get builtInCommuteHow => 'How';

  @override
  String get builtInCommuteHowCar => 'Car';

  @override
  String get builtInCommuteHowBus => 'Bus';

  @override
  String get builtInCommuteHowTrain => 'Train';

  @override
  String get builtInCommuteHowBike => 'Bike';

  @override
  String get builtInCommuteHowWalk => 'Walk';

  @override
  String get builtInCommuteHowOther => 'Other';

  @override
  String get builtInCommuteDistance => 'Distance';

  @override
  String get builtInCommuteHowItWent => 'How it went';

  @override
  String get builtInEmailAndAdmin => 'Email & admin';

  @override
  String get builtInEmailAndAdminEmailsHandled => 'Emails handled';

  @override
  String get builtInEmailAndAdminInboxZero => 'Inbox zero';

  @override
  String get builtInCoding => 'Coding';

  @override
  String get builtInCodingProject => 'Project';

  @override
  String get builtInCodingWhatIBuilt => 'What I built';

  @override
  String get builtInCodingCommits => 'Commits';

  @override
  String get builtInSideProject => 'Side project';

  @override
  String get builtInSideProjectProject => 'Project';

  @override
  String get builtInSideProjectProgress => 'Progress';

  @override
  String get builtInSideProjectMomentum => 'Momentum';

  @override
  String get builtInJobSearch => 'Job search';

  @override
  String get builtInJobSearchCompany => 'Company';

  @override
  String get builtInJobSearchRole => 'Role';

  @override
  String get builtInJobSearchStage => 'Stage';

  @override
  String get builtInJobSearchStageApplied => 'Applied';

  @override
  String get builtInJobSearchStageInterview => 'Interview';

  @override
  String get builtInJobSearchStageOffer => 'Offer';

  @override
  String get builtInJobSearchStageRejected => 'Rejected';

  @override
  String get builtInJobSearchStageFollowingUp => 'Following up';

  @override
  String get builtInJobSearchNotes => 'Notes';

  @override
  String get builtInPresentation => 'Presentation';

  @override
  String get builtInPresentationTopic => 'Topic';

  @override
  String get builtInPresentationAudience => 'Audience';

  @override
  String get builtInPresentationHowItWent => 'How it went';

  @override
  String get builtInCategoryLearning => 'Learning';

  @override
  String get builtInClass => 'Class';

  @override
  String get builtInClassCourse => 'Course';

  @override
  String get builtInClassTopic => 'Topic';

  @override
  String get builtInClassNotes => 'Notes';

  @override
  String get builtInClassUnderstood => 'Understood';

  @override
  String get builtInHomework => 'Homework';

  @override
  String get builtInHomeworkSubject => 'Subject';

  @override
  String get builtInHomeworkTask => 'Task';

  @override
  String get builtInHomeworkFinished => 'Finished';

  @override
  String get builtInOnlineCourse => 'Online course';

  @override
  String get builtInOnlineCourseCourse => 'Course';

  @override
  String get builtInOnlineCourseLessonsDone => 'Lessons done';

  @override
  String get builtInOnlineCourseTakeaways => 'Takeaways';

  @override
  String get builtInMusicPractice => 'Music practice';

  @override
  String get builtInMusicPracticeInstrument => 'Instrument';

  @override
  String get builtInMusicPracticeInstrumentGuitar => 'Guitar';

  @override
  String get builtInMusicPracticeInstrumentPiano => 'Piano';

  @override
  String get builtInMusicPracticeInstrumentDrums => 'Drums';

  @override
  String get builtInMusicPracticeInstrumentViolin => 'Violin';

  @override
  String get builtInMusicPracticeInstrumentVoice => 'Voice';

  @override
  String get builtInMusicPracticeInstrumentOther => 'Other';

  @override
  String get builtInMusicPracticePieces => 'Pieces';

  @override
  String get builtInMusicPracticePiecesItem => 'Piece';

  @override
  String get builtInMusicPracticePiecesPiece => 'Piece';

  @override
  String get builtInMusicPracticePiecesTempoBpm => 'Tempo (bpm)';

  @override
  String get builtInMusicPracticeHowItWent => 'How it went';

  @override
  String get builtInSkillPractice => 'Skill practice';

  @override
  String get builtInSkillPracticeSkill => 'Skill';

  @override
  String get builtInSkillPracticeWhatIPractised => 'What I practised';

  @override
  String get builtInSkillPracticeProgress => 'Progress';

  @override
  String get builtInCategoryExerciseAndSport => 'Exercise & sport';

  @override
  String get builtInCycling => 'Cycling';

  @override
  String get builtInCyclingDistance => 'Distance';

  @override
  String get builtInCyclingRoute => 'Route';

  @override
  String get builtInCyclingFelt => 'Felt';

  @override
  String get builtInSwimming => 'Swimming';

  @override
  String get builtInSwimmingDistance => 'Distance';

  @override
  String get builtInSwimmingLaps => 'Laps';

  @override
  String get builtInSwimmingStrokes => 'Strokes';

  @override
  String get builtInSwimmingStrokesFreestyle => 'Freestyle';

  @override
  String get builtInSwimmingStrokesBreaststroke => 'Breaststroke';

  @override
  String get builtInSwimmingStrokesBackstroke => 'Backstroke';

  @override
  String get builtInSwimmingStrokesButterfly => 'Butterfly';

  @override
  String get builtInYoga => 'Yoga';

  @override
  String get builtInYogaStyle => 'Style';

  @override
  String get builtInYogaStyleHatha => 'Hatha';

  @override
  String get builtInYogaStyleVinyasa => 'Vinyasa';

  @override
  String get builtInYogaStyleYin => 'Yin';

  @override
  String get builtInYogaStylePower => 'Power';

  @override
  String get builtInYogaStyleRestorative => 'Restorative';

  @override
  String get builtInYogaFeltAfter => 'Felt after';

  @override
  String get builtInStretching => 'Stretching';

  @override
  String get builtInStretchingAreas => 'Areas';

  @override
  String get builtInStretchingAreasNeck => 'Neck';

  @override
  String get builtInStretchingAreasShoulders => 'Shoulders';

  @override
  String get builtInStretchingAreasBack => 'Back';

  @override
  String get builtInStretchingAreasHips => 'Hips';

  @override
  String get builtInStretchingAreasLegs => 'Legs';

  @override
  String get builtInStretchingAreasFullBody => 'Full body';

  @override
  String get builtInHomeWorkout => 'Home workout';

  @override
  String get builtInHomeWorkoutExercises => 'Exercises';

  @override
  String get builtInHomeWorkoutExercisesItem => 'Exercise';

  @override
  String get builtInHomeWorkoutExercisesExercise => 'Exercise';

  @override
  String get builtInHomeWorkoutExercisesReps => 'Reps';

  @override
  String get builtInHomeWorkoutExercisesRounds => 'Rounds';

  @override
  String get builtInHomeWorkoutEffort => 'Effort';

  @override
  String get builtInHiking => 'Hiking';

  @override
  String get builtInHikingTrail => 'Trail';

  @override
  String get builtInHikingDistance => 'Distance';

  @override
  String get builtInHikingElevationGain => 'Elevation gain';

  @override
  String get builtInHikingFelt => 'Felt';

  @override
  String get builtInTeamSport => 'Team sport';

  @override
  String get builtInTeamSportSport => 'Sport';

  @override
  String get builtInTeamSportSportFootball => 'Football';

  @override
  String get builtInTeamSportSportBasketball => 'Basketball';

  @override
  String get builtInTeamSportSportCricket => 'Cricket';

  @override
  String get builtInTeamSportSportVolleyball => 'Volleyball';

  @override
  String get builtInTeamSportSportHockey => 'Hockey';

  @override
  String get builtInTeamSportSportOther => 'Other';

  @override
  String get builtInTeamSportResult => 'Result';

  @override
  String get builtInTeamSportResultWon => 'Won';

  @override
  String get builtInTeamSportResultLost => 'Lost';

  @override
  String get builtInTeamSportResultDraw => 'Draw';

  @override
  String get builtInTeamSportResultJustPlayed => 'Just played';

  @override
  String get builtInTeamSportHowIPlayed => 'How I played';

  @override
  String get builtInRacketSport => 'Racket sport';

  @override
  String get builtInRacketSportSport => 'Sport';

  @override
  String get builtInRacketSportSportTennis => 'Tennis';

  @override
  String get builtInRacketSportSportBadminton => 'Badminton';

  @override
  String get builtInRacketSportSportSquash => 'Squash';

  @override
  String get builtInRacketSportSportTableTennis => 'Table tennis';

  @override
  String get builtInRacketSportSportPadel => 'Padel';

  @override
  String get builtInRacketSportOpponent => 'Opponent';

  @override
  String get builtInRacketSportResult => 'Result';

  @override
  String get builtInRacketSportResultWon => 'Won';

  @override
  String get builtInRacketSportResultLost => 'Lost';

  @override
  String get builtInRacketSportResultJustPlayed => 'Just played';

  @override
  String get builtInDance => 'Dance';

  @override
  String get builtInDanceStyle => 'Style';

  @override
  String get builtInDanceFun => 'Fun';

  @override
  String get builtInDailySteps => 'Daily steps';

  @override
  String get builtInDailyStepsSteps => 'Steps';

  @override
  String get builtInCategoryMindAndWellbeing => 'Mind & wellbeing';

  @override
  String get builtInJournal => 'Journal';

  @override
  String get builtInJournalEntry => 'Entry';

  @override
  String get builtInJournalHowTheDayWas => 'How the day was';

  @override
  String get builtInGratitude => 'Gratitude';

  @override
  String get builtInGratitudeGratefulFor => 'Grateful for';

  @override
  String get builtInGratitudeGratefulForItem => 'Thing';

  @override
  String get builtInGratitudeGratefulForThing => 'Thing';

  @override
  String get builtInBreathing => 'Breathing';

  @override
  String get builtInBreathingTechnique => 'Technique';

  @override
  String get builtInBreathingTechniqueBoxBreathing => 'Box breathing';

  @override
  String get builtInBreathingTechnique478 => '4-7-8';

  @override
  String get builtInBreathingTechniqueDeepBelly => 'Deep belly';

  @override
  String get builtInBreathingTechniqueAlternateNostril => 'Alternate nostril';

  @override
  String get builtInBreathingRounds => 'Rounds';

  @override
  String get builtInTherapySession => 'Therapy session';

  @override
  String get builtInTherapySessionWith => 'With';

  @override
  String get builtInTherapySessionTalkedAbout => 'Talked about';

  @override
  String get builtInTherapySessionTakeaways => 'Takeaways';

  @override
  String get builtInTherapySessionFeltAfter => 'Felt after';

  @override
  String get builtInScreenTime => 'Screen time';

  @override
  String get builtInScreenTimeTotal => 'Total';

  @override
  String get builtInScreenTimePickups => 'Pickups';

  @override
  String get builtInScreenTimeMostUsedApp => 'Most used app';

  @override
  String get builtInHabitToBreak => 'Habit to break';

  @override
  String get builtInHabitToBreakHabit => 'Habit';

  @override
  String get builtInHabitToBreakKeptClearToday => 'Kept clear today';

  @override
  String get builtInHabitToBreakUrges => 'Urges';

  @override
  String get builtInHabitToBreakNotes => 'Notes';

  @override
  String get builtInDigitalDetox => 'Digital detox';

  @override
  String get builtInDigitalDetoxPhoneAway => 'Phone away';

  @override
  String get builtInDigitalDetoxHowItFelt => 'How it felt';

  @override
  String get builtInAffirmations => 'Affirmations';

  @override
  String get builtInAffirmationsTodaySAffirmation => 'Today\'s affirmation';

  @override
  String get builtInAffirmationsSaidOutLoud => 'Said out loud';

  @override
  String get builtInCategoryHobbiesAndFun => 'Hobbies & fun';

  @override
  String get builtInTVAndMovies => 'TV & movies';

  @override
  String get builtInTVAndMoviesTitle => 'Title';

  @override
  String get builtInTVAndMoviesKind => 'Kind';

  @override
  String get builtInTVAndMoviesKindMovie => 'Movie';

  @override
  String get builtInTVAndMoviesKindSeries => 'Series';

  @override
  String get builtInTVAndMoviesKindDocumentary => 'Documentary';

  @override
  String get builtInTVAndMoviesKindShow => 'Show';

  @override
  String get builtInTVAndMoviesEpisodes => 'Episodes';

  @override
  String get builtInTVAndMoviesRating => 'Rating';

  @override
  String get builtInGaming => 'Gaming';

  @override
  String get builtInGamingGame => 'Game';

  @override
  String get builtInGamingPlatform => 'Platform';

  @override
  String get builtInGamingPlatformPC => 'PC';

  @override
  String get builtInGamingPlatformConsole => 'Console';

  @override
  String get builtInGamingPlatformMobile => 'Mobile';

  @override
  String get builtInGamingPlatformBoardGame => 'Board game';

  @override
  String get builtInGamingPlatformCards => 'Cards';

  @override
  String get builtInGamingFun => 'Fun';

  @override
  String get builtInPodcast => 'Podcast';

  @override
  String get builtInPodcastShow => 'Show';

  @override
  String get builtInPodcastEpisode => 'Episode';

  @override
  String get builtInPodcastTakeaways => 'Takeaways';

  @override
  String get builtInDrawingAndPainting => 'Drawing & painting';

  @override
  String get builtInDrawingAndPaintingMedium => 'Medium';

  @override
  String get builtInDrawingAndPaintingMediumPencil => 'Pencil';

  @override
  String get builtInDrawingAndPaintingMediumInk => 'Ink';

  @override
  String get builtInDrawingAndPaintingMediumWatercolor => 'Watercolor';

  @override
  String get builtInDrawingAndPaintingMediumAcrylic => 'Acrylic';

  @override
  String get builtInDrawingAndPaintingMediumOil => 'Oil';

  @override
  String get builtInDrawingAndPaintingMediumDigital => 'Digital';

  @override
  String get builtInDrawingAndPaintingPiece => 'Piece';

  @override
  String get builtInDrawingAndPaintingHappyWithIt => 'Happy with it';

  @override
  String get builtInPhotography => 'Photography';

  @override
  String get builtInPhotographySubject => 'Subject';

  @override
  String get builtInPhotographyPhotosTaken => 'Photos taken';

  @override
  String get builtInPhotographyKeepers => 'Keepers';

  @override
  String get builtInWriting => 'Writing';

  @override
  String get builtInWritingProject => 'Project';

  @override
  String get builtInWritingWords => 'Words';

  @override
  String get builtInWritingNotes => 'Notes';

  @override
  String get builtInCrafts => 'Crafts';

  @override
  String get builtInCraftsCraft => 'Craft';

  @override
  String get builtInCraftsCraftKnitting => 'Knitting';

  @override
  String get builtInCraftsCraftCrochet => 'Crochet';

  @override
  String get builtInCraftsCraftSewing => 'Sewing';

  @override
  String get builtInCraftsCraftWoodwork => 'Woodwork';

  @override
  String get builtInCraftsCraftPottery => 'Pottery';

  @override
  String get builtInCraftsCraftOther => 'Other';

  @override
  String get builtInCraftsProject => 'Project';

  @override
  String get builtInCraftsProgress => 'Progress';

  @override
  String get builtInPuzzles => 'Puzzles';

  @override
  String get builtInPuzzlesGame => 'Game';

  @override
  String get builtInPuzzlesGameSudoku => 'Sudoku';

  @override
  String get builtInPuzzlesGameCrossword => 'Crossword';

  @override
  String get builtInPuzzlesGameChess => 'Chess';

  @override
  String get builtInPuzzlesGameJigsaw => 'Jigsaw';

  @override
  String get builtInPuzzlesGameWordGame => 'Word game';

  @override
  String get builtInPuzzlesGameOther => 'Other';

  @override
  String get builtInPuzzlesSolved => 'Solved';

  @override
  String get builtInPuzzlesScore => 'Score';

  @override
  String get builtInListeningToMusic => 'Listening to music';

  @override
  String get builtInListeningToMusicArtistOrAlbum => 'Artist or album';

  @override
  String get builtInListeningToMusicEnjoyed => 'Enjoyed';

  @override
  String get builtInCategoryFriendsAndCommunity => 'Friends & community';

  @override
  String get builtInTimeWithFriends => 'Time with friends';

  @override
  String get builtInTimeWithFriendsWho => 'Who';

  @override
  String get builtInTimeWithFriendsWhatWeDid => 'What we did';

  @override
  String get builtInTimeWithFriendsHowItFelt => 'How it felt';

  @override
  String get builtInPhoneCall => 'Phone call';

  @override
  String get builtInPhoneCallWho => 'Who';

  @override
  String get builtInPhoneCallTalkedAbout => 'Talked about';

  @override
  String get builtInPhoneCallFollowUpNeeded => 'Follow up needed';

  @override
  String get builtInDateNight => 'Date night';

  @override
  String get builtInDateNightWhere => 'Where';

  @override
  String get builtInDateNightWhatWeDid => 'What we did';

  @override
  String get builtInDateNightRating => 'Rating';

  @override
  String get builtInEvent => 'Event';

  @override
  String get builtInEventEvent => 'Event';

  @override
  String get builtInEventWhere => 'Where';

  @override
  String get builtInEventHowItWas => 'How it was';

  @override
  String get builtInVolunteering => 'Volunteering';

  @override
  String get builtInVolunteeringOrganization => 'Organization';

  @override
  String get builtInVolunteeringWhatIDid => 'What I did';

  @override
  String get builtInVolunteeringPeopleHelped => 'People helped';

  @override
  String get builtInPrayerAndWorship => 'Prayer & worship';

  @override
  String get builtInPrayerAndWorshipPracticeOrPlace => 'Practice or place';

  @override
  String get builtInPrayerAndWorshipReflection => 'Reflection';

  @override
  String get builtInDonation => 'Donation';

  @override
  String get builtInDonationCause => 'Cause';

  @override
  String get builtInDonationAmount => 'Amount';

  @override
  String get builtInCategoryTravelAndErrands => 'Travel & errands';

  @override
  String get builtInErrands => 'Errands';

  @override
  String get builtInErrandsErrands => 'Errands';

  @override
  String get builtInErrandsErrandsItem => 'Errand';

  @override
  String get builtInErrandsErrandsErrand => 'Errand';

  @override
  String get builtInErrandsErrandsDone => 'Done';

  @override
  String get builtInAppointment => 'Appointment';

  @override
  String get builtInAppointmentWith => 'With';

  @override
  String get builtInAppointmentPurpose => 'Purpose';

  @override
  String get builtInAppointmentNextAppointment => 'Next appointment';

  @override
  String get builtInDriving => 'Driving';

  @override
  String get builtInDrivingDistance => 'Distance';

  @override
  String get builtInDrivingFuel => 'Fuel';

  @override
  String get builtInDrivingPurpose => 'Purpose';

  @override
  String get builtInTrip => 'Trip';

  @override
  String get builtInTripDestination => 'Destination';

  @override
  String get builtInTripTravelBy => 'Travel by';

  @override
  String get builtInTripTravelByPlane => 'Plane';

  @override
  String get builtInTripTravelByTrain => 'Train';

  @override
  String get builtInTripTravelByCar => 'Car';

  @override
  String get builtInTripTravelByBus => 'Bus';

  @override
  String get builtInTripTravelByBoat => 'Boat';

  @override
  String get builtInTripHighlights => 'Highlights';

  @override
  String get builtInPacking => 'Packing';

  @override
  String get builtInPackingPackingList => 'Packing list';

  @override
  String get builtInPackingPackingListItem => 'Item';

  @override
  String get builtInPackingPackingListDone => 'Done';

  @override
  String get builtInAyurvedicMorning => 'Ayurvedic morning';

  @override
  String get builtInAyurvedicMorningUpBeforeSunrise => 'Up before sunrise';

  @override
  String get builtInAyurvedicMorningPractices => 'Practices';

  @override
  String get builtInAyurvedicMorningPracticesTongueScraping =>
      'Tongue scraping';

  @override
  String get builtInAyurvedicMorningPracticesOilPulling => 'Oil pulling';

  @override
  String get builtInAyurvedicMorningPracticesAbhyanga => 'Abhyanga';

  @override
  String get builtInAyurvedicMorningPracticesWarmWater => 'Warm water';

  @override
  String get builtInAyurvedicMorningPracticesNeti => 'Neti';

  @override
  String get builtInAyurvedicMorningFeltAfter => 'Felt after';

  @override
  String get builtInHairOiling => 'Hair oiling';

  @override
  String get builtInHairOilingOil => 'Oil';

  @override
  String get builtInHairOilingLeftOnOvernight => 'Left on overnight';

  @override
  String get builtInMassageAndSpa => 'Massage & spa';

  @override
  String get builtInMassageAndSpaKind => 'Kind';

  @override
  String get builtInMassageAndSpaKindMassage => 'Massage';

  @override
  String get builtInMassageAndSpaKindSpa => 'Spa';

  @override
  String get builtInMassageAndSpaKindFacial => 'Facial';

  @override
  String get builtInMassageAndSpaKindFootMassage => 'Foot massage';

  @override
  String get builtInMassageAndSpaKindSelfMassage => 'Self-massage';

  @override
  String get builtInMassageAndSpaFeltAfter => 'Felt after';

  @override
  String get builtInMassageAndSpaCost => 'Cost';

  @override
  String get builtInSaunaAndColdPlunge => 'Sauna & cold plunge';

  @override
  String get builtInSaunaAndColdPlungeKind => 'Kind';

  @override
  String get builtInSaunaAndColdPlungeKindSauna => 'Sauna';

  @override
  String get builtInSaunaAndColdPlungeKindColdPlunge => 'Cold plunge';

  @override
  String get builtInSaunaAndColdPlungeKindSteamRoom => 'Steam room';

  @override
  String get builtInSaunaAndColdPlungeKindContrast => 'Contrast';

  @override
  String get builtInSaunaAndColdPlungeRounds => 'Rounds';

  @override
  String get builtInSaunaAndColdPlungeTemperature => 'Temperature';

  @override
  String get builtInPain => 'Pain';

  @override
  String get builtInPainWhere => 'Where';

  @override
  String get builtInPainWhereHead => 'Head';

  @override
  String get builtInPainWhereNeck => 'Neck';

  @override
  String get builtInPainWhereBack => 'Back';

  @override
  String get builtInPainWhereJoints => 'Joints';

  @override
  String get builtInPainWhereStomach => 'Stomach';

  @override
  String get builtInPainWhereMuscles => 'Muscles';

  @override
  String get builtInPainLevel => 'Level';

  @override
  String get builtInPainPossibleTrigger => 'Possible trigger';

  @override
  String get builtInDigestion => 'Digestion';

  @override
  String get builtInDigestionType => 'Type';

  @override
  String get builtInDigestionTypeHard => 'Hard';

  @override
  String get builtInDigestionTypeNormal => 'Normal';

  @override
  String get builtInDigestionTypeSoft => 'Soft';

  @override
  String get builtInDigestionTypeLoose => 'Loose';

  @override
  String get builtInDigestionBloating => 'Bloating';

  @override
  String get builtInDigestionNotes => 'Notes';

  @override
  String get builtInEnergyCheck => 'Energy check';

  @override
  String get builtInEnergyCheckEnergy => 'Energy';

  @override
  String get builtInEnergyCheckFocus => 'Focus';

  @override
  String get builtInProtein => 'Protein';

  @override
  String get builtInProteinProtein => 'Protein';

  @override
  String get builtInFruitAndVeg => 'Fruit & veg';

  @override
  String get builtInFruitAndVegPortions => 'Portions';

  @override
  String get builtInFruitAndVegColoursEaten => 'Colours eaten';

  @override
  String get builtInFruitAndVegColoursEatenGreen => 'Green';

  @override
  String get builtInFruitAndVegColoursEatenRed => 'Red';

  @override
  String get builtInFruitAndVegColoursEatenOrange => 'Orange';

  @override
  String get builtInFruitAndVegColoursEatenYellow => 'Yellow';

  @override
  String get builtInFruitAndVegColoursEatenPurple => 'Purple';

  @override
  String get builtInFruitAndVegColoursEatenWhite => 'White';

  @override
  String get builtInPackedLunch => 'Packed lunch';

  @override
  String get builtInPackedLunchFor => 'For';

  @override
  String get builtInPackedLunchWhatWentIn => 'What went in';

  @override
  String get builtInPackedLunchEaten => 'Eaten';

  @override
  String get builtInHouseHelp => 'House help';

  @override
  String get builtInHouseHelpWho => 'Who';

  @override
  String get builtInHouseHelpCameToday => 'Came today';

  @override
  String get builtInHouseHelpTasks => 'Tasks';

  @override
  String get builtInHouseHelpTasksSweeping => 'Sweeping';

  @override
  String get builtInHouseHelpTasksMopping => 'Mopping';

  @override
  String get builtInHouseHelpTasksDishes => 'Dishes';

  @override
  String get builtInHouseHelpTasksLaundry => 'Laundry';

  @override
  String get builtInHouseHelpTasksCooking => 'Cooking';

  @override
  String get builtInHouseHelpTasksDusting => 'Dusting';

  @override
  String get builtInHouseHelpPaid => 'Paid';

  @override
  String get builtInCarCare => 'Car care';

  @override
  String get builtInCarCareWhat => 'What';

  @override
  String get builtInCarCareWhatFuel => 'Fuel';

  @override
  String get builtInCarCareWhatWash => 'Wash';

  @override
  String get builtInCarCareWhatService => 'Service';

  @override
  String get builtInCarCareWhatTyres => 'Tyres';

  @override
  String get builtInCarCareWhatOilChange => 'Oil change';

  @override
  String get builtInCarCareWhatRepair => 'Repair';

  @override
  String get builtInCarCareOdometer => 'Odometer';

  @override
  String get builtInCarCareCost => 'Cost';

  @override
  String get builtInCategoryMoney => 'Money';

  @override
  String get builtInInvesting => 'Investing';

  @override
  String get builtInInvestingFundOrAsset => 'Fund or asset';

  @override
  String get builtInInvestingKind => 'Kind';

  @override
  String get builtInInvestingKindBuy => 'Buy';

  @override
  String get builtInInvestingKindSell => 'Sell';

  @override
  String get builtInInvestingKindSIP => 'SIP';

  @override
  String get builtInInvestingKindDeposit => 'Deposit';

  @override
  String get builtInInvestingKindDividend => 'Dividend';

  @override
  String get builtInInvestingAmount => 'Amount';

  @override
  String get builtInSavings => 'Savings';

  @override
  String get builtInSavingsGoal => 'Goal';

  @override
  String get builtInSavingsAdded => 'Added';

  @override
  String get builtInSavingsTotalSoFar => 'Total so far';

  @override
  String get builtInSchoolRun => 'School run';

  @override
  String get builtInSchoolRunChild => 'Child';

  @override
  String get builtInSchoolRunHow => 'How';

  @override
  String get builtInSchoolRunHowCar => 'Car';

  @override
  String get builtInSchoolRunHowWalk => 'Walk';

  @override
  String get builtInSchoolRunHowBus => 'Bus';

  @override
  String get builtInSchoolRunHowBike => 'Bike';

  @override
  String get builtInSchoolRunHowAuto => 'Auto';

  @override
  String get builtInSchoolRunHowSchoolVan => 'School van';

  @override
  String get builtInSchoolRunOnTime => 'On time';

  @override
  String get builtInClientWork => 'Client work';

  @override
  String get builtInClientWorkClient => 'Client';

  @override
  String get builtInClientWorkTask => 'Task';

  @override
  String get builtInClientWorkBillable => 'Billable';

  @override
  String get builtInShift => 'Shift';

  @override
  String get builtInShiftShift => 'Shift';

  @override
  String get builtInShiftShiftMorning => 'Morning';

  @override
  String get builtInShiftShiftDay => 'Day';

  @override
  String get builtInShiftShiftEvening => 'Evening';

  @override
  String get builtInShiftShiftNight => 'Night';

  @override
  String get builtInShiftShiftSplit => 'Split';

  @override
  String get builtInShiftTookABreak => 'Took a break';

  @override
  String get builtInShiftEarned => 'Earned';

  @override
  String get builtInGigWork => 'Gig work';

  @override
  String get builtInGigWorkPlatform => 'Platform';

  @override
  String get builtInGigWorkTripsOrOrders => 'Trips or orders';

  @override
  String get builtInGigWorkEarned => 'Earned';

  @override
  String get builtInGigWorkDistance => 'Distance';

  @override
  String get builtInNetworking => 'Networking';

  @override
  String get builtInNetworkingPerson => 'Person';

  @override
  String get builtInNetworkingWhereWeMet => 'Where we met';

  @override
  String get builtInNetworkingFollowUpOn => 'Follow up on';

  @override
  String get builtInWeeklyReview => 'Weekly review';

  @override
  String get builtInWeeklyReviewWins => 'Wins';

  @override
  String get builtInWeeklyReviewLessons => 'Lessons';

  @override
  String get builtInWeeklyReviewNextWeek => 'Next week';

  @override
  String get builtInWeeklyReviewNextWeekItem => 'Priority';

  @override
  String get builtInWeeklyReviewNextWeekPriority => 'Priority';

  @override
  String get builtInWeeklyReviewNextWeekDone => 'Done';

  @override
  String get builtInGoalCheckIn => 'Goal check-in';

  @override
  String get builtInGoalCheckInGoal => 'Goal';

  @override
  String get builtInGoalCheckInProgress => 'Progress';

  @override
  String get builtInGoalCheckInNextStep => 'Next step';

  @override
  String get builtInTuition => 'Tuition';

  @override
  String get builtInTuitionSubject => 'Subject';

  @override
  String get builtInTuitionTopic => 'Topic';

  @override
  String get builtInTuitionTestScore => 'Test score';

  @override
  String get builtInExamPrep => 'Exam prep';

  @override
  String get builtInExamPrepExam => 'Exam';

  @override
  String get builtInExamPrepTopicsCovered => 'Topics covered';

  @override
  String get builtInExamPrepMockTestScore => 'Mock test score';

  @override
  String get builtInExamPrepConfidence => 'Confidence';

  @override
  String get builtInFlashcards => 'Flashcards';

  @override
  String get builtInFlashcardsDeck => 'Deck';

  @override
  String get builtInFlashcardsCardsReviewed => 'Cards reviewed';

  @override
  String get builtInFlashcardsCorrect => 'Correct';

  @override
  String get builtInTeaching => 'Teaching';

  @override
  String get builtInTeachingTopic => 'Topic';

  @override
  String get builtInTeachingStudents => 'Students';

  @override
  String get builtInTeachingHowItWent => 'How it went';

  @override
  String get builtInSuryaNamaskar => 'Surya namaskar';

  @override
  String get builtInSuryaNamaskarRounds => 'Rounds';

  @override
  String get builtInSuryaNamaskarFeltAfter => 'Felt after';

  @override
  String get builtInPilates => 'Pilates';

  @override
  String get builtInPilatesKind => 'Kind';

  @override
  String get builtInPilatesKindMat => 'Mat';

  @override
  String get builtInPilatesKindReformer => 'Reformer';

  @override
  String get builtInPilatesFeltAfter => 'Felt after';

  @override
  String get builtInClimbing => 'Climbing';

  @override
  String get builtInClimbingKind => 'Kind';

  @override
  String get builtInClimbingKindBouldering => 'Bouldering';

  @override
  String get builtInClimbingKindTopRope => 'Top rope';

  @override
  String get builtInClimbingKindLead => 'Lead';

  @override
  String get builtInClimbingKindOutdoor => 'Outdoor';

  @override
  String get builtInClimbingRoutes => 'Routes';

  @override
  String get builtInClimbingHardestGrade => 'Hardest grade';

  @override
  String get builtInMartialArts => 'Martial arts';

  @override
  String get builtInMartialArtsStyle => 'Style';

  @override
  String get builtInMartialArtsTechniques => 'Techniques';

  @override
  String get builtInMartialArtsSparringRounds => 'Sparring rounds';

  @override
  String get builtInGolf => 'Golf';

  @override
  String get builtInGolfCourse => 'Course';

  @override
  String get builtInGolfHoles => 'Holes';

  @override
  String get builtInGolfHoles9 => '9';

  @override
  String get builtInGolfHoles18 => '18';

  @override
  String get builtInGolfScore => 'Score';

  @override
  String get builtInWinterSports => 'Winter sports';

  @override
  String get builtInWinterSportsKind => 'Kind';

  @override
  String get builtInWinterSportsKindSkiing => 'Skiing';

  @override
  String get builtInWinterSportsKindSnowboarding => 'Snowboarding';

  @override
  String get builtInWinterSportsKindIceSkating => 'Ice skating';

  @override
  String get builtInWinterSportsKindSledging => 'Sledging';

  @override
  String get builtInWinterSportsRuns => 'Runs';

  @override
  String get builtInWinterSportsWhere => 'Where';

  @override
  String get builtInPranayama => 'Pranayama';

  @override
  String get builtInPranayamaTechnique => 'Technique';

  @override
  String get builtInPranayamaTechniqueAnulomVilom => 'Anulom vilom';

  @override
  String get builtInPranayamaTechniqueKapalbhati => 'Kapalbhati';

  @override
  String get builtInPranayamaTechniqueBhramari => 'Bhramari';

  @override
  String get builtInPranayamaTechniqueBhastrika => 'Bhastrika';

  @override
  String get builtInPranayamaTechniqueUjjayi => 'Ujjayi';

  @override
  String get builtInPranayamaRounds => 'Rounds';

  @override
  String get builtInTimeOutdoors => 'Time outdoors';

  @override
  String get builtInTimeOutdoorsWhere => 'Where';

  @override
  String get builtInTimeOutdoorsMorningSunlight => 'Morning sunlight';

  @override
  String get builtInTimeOutdoorsFeltAfter => 'Felt after';

  @override
  String get builtInSocialMedia => 'Social media';

  @override
  String get builtInSocialMediaApps => 'Apps';

  @override
  String get builtInSocialMediaAppsInstagram => 'Instagram';

  @override
  String get builtInSocialMediaAppsYouTube => 'YouTube';

  @override
  String get builtInSocialMediaAppsTikTok => 'TikTok';

  @override
  String get builtInSocialMediaAppsWhatsApp => 'WhatsApp';

  @override
  String get builtInSocialMediaAppsFacebook => 'Facebook';

  @override
  String get builtInSocialMediaAppsX => 'X';

  @override
  String get builtInSocialMediaAppsReddit => 'Reddit';

  @override
  String get builtInSocialMediaAppsSnapchat => 'Snapchat';

  @override
  String get builtInSocialMediaTimeSpent => 'Time spent';

  @override
  String get builtInSocialMediaFeltAfter => 'Felt after';

  @override
  String get builtInNews => 'News';

  @override
  String get builtInNewsSource => 'Source';

  @override
  String get builtInNewsWhatStoodOut => 'What stood out';

  @override
  String get builtInKindAct => 'Kind act';

  @override
  String get builtInKindActWhatIDid => 'What I did';

  @override
  String get builtInKindActForWhom => 'For whom';

  @override
  String get builtInCategoryFaithAndSpirituality => 'Faith & spirituality';

  @override
  String get builtInPuja => 'Puja';

  @override
  String get builtInPujaDeityOrOccasion => 'Deity or occasion';

  @override
  String get builtInPujaOfferings => 'Offerings';

  @override
  String get builtInPujaOfferingsFlowers => 'Flowers';

  @override
  String get builtInPujaOfferingsDiya => 'Diya';

  @override
  String get builtInPujaOfferingsIncense => 'Incense';

  @override
  String get builtInPujaOfferingsPrasad => 'Prasad';

  @override
  String get builtInPujaOfferingsAarti => 'Aarti';

  @override
  String get builtInPujaWithFamily => 'With family';

  @override
  String get builtInSalah => 'Salah';

  @override
  String get builtInSalahPrayers => 'Prayers';

  @override
  String get builtInSalahPrayersFajr => 'Fajr';

  @override
  String get builtInSalahPrayersDhuhr => 'Dhuhr';

  @override
  String get builtInSalahPrayersAsr => 'Asr';

  @override
  String get builtInSalahPrayersMaghrib => 'Maghrib';

  @override
  String get builtInSalahPrayersIsha => 'Isha';

  @override
  String get builtInSalahOnTime => 'On time';

  @override
  String get builtInSalahAtTheMosque => 'At the mosque';

  @override
  String get builtInScriptureReading => 'Scripture reading';

  @override
  String get builtInScriptureReadingText => 'Text';

  @override
  String get builtInScriptureReadingPassage => 'Passage';

  @override
  String get builtInScriptureReadingReflection => 'Reflection';

  @override
  String get builtInChanting => 'Chanting';

  @override
  String get builtInChantingMantra => 'Mantra';

  @override
  String get builtInChantingMalas => 'Malas';

  @override
  String get builtInChantingCount => 'Count';

  @override
  String get builtInReligiousFast => 'Religious fast';

  @override
  String get builtInReligiousFastOccasion => 'Occasion';

  @override
  String get builtInReligiousFastKind => 'Kind';

  @override
  String get builtInReligiousFastKindSunriseToSunset => 'Sunrise to sunset';

  @override
  String get builtInReligiousFastKindWaterOnly => 'Water only';

  @override
  String get builtInReligiousFastKindFruitAndMilk => 'Fruit and milk';

  @override
  String get builtInReligiousFastKindOneMeal => 'One meal';

  @override
  String get builtInReligiousFastKindNoWater => 'No water';

  @override
  String get builtInReligiousFastBrokeTheFastAt => 'Broke the fast at';

  @override
  String get builtInWatchingSport => 'Watching sport';

  @override
  String get builtInWatchingSportMatch => 'Match';

  @override
  String get builtInWatchingSportTeam => 'Team';

  @override
  String get builtInWatchingSportResult => 'Result';

  @override
  String get builtInWatchingSportResultWon => 'Won';

  @override
  String get builtInWatchingSportResultLost => 'Lost';

  @override
  String get builtInWatchingSportResultDraw => 'Draw';

  @override
  String get builtInWatchingSportResultNoResult => 'No result';

  @override
  String get builtInFishing => 'Fishing';

  @override
  String get builtInFishingSpot => 'Spot';

  @override
  String get builtInFishingCatch => 'Catch';

  @override
  String get builtInFishingCatchItem => 'Fish';

  @override
  String get builtInFishingCatchFish => 'Fish';

  @override
  String get builtInFishingCatchWeight => 'Weight';

  @override
  String get builtInContentCreation => 'Content creation';

  @override
  String get builtInContentCreationPlatform => 'Platform';

  @override
  String get builtInContentCreationPlatformYouTube => 'YouTube';

  @override
  String get builtInContentCreationPlatformInstagram => 'Instagram';

  @override
  String get builtInContentCreationPlatformTikTok => 'TikTok';

  @override
  String get builtInContentCreationPlatformBlog => 'Blog';

  @override
  String get builtInContentCreationPlatformPodcast => 'Podcast';

  @override
  String get builtInContentCreationPlatformOther => 'Other';

  @override
  String get builtInContentCreationPiece => 'Piece';

  @override
  String get builtInContentCreationViews => 'Views';

  @override
  String get activitiesYours => 'Yours';

  @override
  String get numberSummaryLabel => 'In insights, show it as';

  @override
  String get numberSummaryTotal => 'Total';

  @override
  String get numberSummaryAverage => 'Average';

  @override
  String get numberSummaryLatest => 'Latest';

  @override
  String get betterDirectionLabel => 'Better is';

  @override
  String get betterHigher => 'Higher';

  @override
  String get betterLower => 'Lower';

  @override
  String get betterNeither => 'Neither';

  @override
  String insightPercent(String value) {
    return '$value %';
  }

  @override
  String insightAutoRowValue(String row, String field) {
    return '$row · $field';
  }

  @override
  String get insightAutoEstimatedMax => 'Estimated 1-rep max';

  @override
  String insightAutoRowEstimatedMax(String row) {
    return '$row · estimated 1-rep max';
  }

  @override
  String insightAutoRowTotal(String row, String field) {
    return '$row · total $field';
  }

  @override
  String insightAutoTotal(String field) {
    return 'Total $field';
  }

  @override
  String insightAutoYesShare(String field) {
    return '$field · how often yes';
  }

  @override
  String insightStreak(int current, int longest) {
    String _temp0 = intl.Intl.pluralLogic(
      current,
      locale: localeName,
      other: '$current weeks in a row',
      one: '1 week in a row',
    );
    return '$_temp0 · best $longest';
  }

  @override
  String insightStreakEnded(int longest) {
    String _temp0 = intl.Intl.pluralLogic(
      longest,
      locale: localeName,
      other: '$longest weeks',
      one: '1 week',
    );
    return 'Best run $_temp0';
  }

  @override
  String get insightConsistencySection => 'Consistency';

  @override
  String insightDaysOfPeriod(int days, int total) {
    return '$days of $total days';
  }

  @override
  String get insightWhenSection => 'When you do it';

  @override
  String get insightMorning => 'Morning';

  @override
  String get insightAfternoon => 'Afternoon';

  @override
  String get insightEvening => 'Evening';

  @override
  String get insightNight => 'Night';

  @override
  String get insightShowAllRows => 'Show every row';

  @override
  String get insightChoiceTimes => 'How often each';

  @override
  String get insightSummarySection => 'At a glance';

  @override
  String get insightDaysActive => 'Days active';

  @override
  String get insightTimeRecorded => 'Time';

  @override
  String get insightThingsDone => 'Things done';

  @override
  String get insightTimeByActivitySection => 'Where your time went';

  @override
  String get insightPlanSection => 'Plan vs reality';

  @override
  String insightPlanDone(int done, int planned) {
    return '$done of $planned planned items done';
  }

  @override
  String get insightPlanEmpty => 'Nothing was planned in this period.';

  @override
  String get insightNotThisPeriod => 'Not done this period';

  @override
  String insightActivityLegendMore(int count) {
    return '+$count more';
  }

  @override
  String insightPoints(String change) {
    return '$change pts';
  }

  @override
  String get validationInvalidChallengeTarget =>
      'Choose between 1 and 1000 days.';

  @override
  String get validationChallengeStartInFuture =>
      'A challenge can\'t start in the future.';

  @override
  String get challengesTitle => 'Challenges';

  @override
  String get challengesSubtitle =>
      'Do an activity every day and keep your streak going.';

  @override
  String get challengesEmptyTitle => 'No challenges yet';

  @override
  String get challengesEmptyMessage =>
      'Pick an activity and a number of days, like 75 days of Meditation. Recording it each day keeps your streak going.';

  @override
  String get newChallenge => 'New challenge';

  @override
  String get challengeNewTitle => 'New challenge';

  @override
  String get challengeEditTitle => 'Edit challenge';

  @override
  String get challengeActivityLabel => 'Activity';

  @override
  String get challengeActivityHelper => 'Recording it each day counts the day.';

  @override
  String get challengeDaysLabel => 'Number of days';

  @override
  String get challengeDaysHelper => 'Complete the activity once every day.';

  @override
  String get challengeStartLabel => 'First day';

  @override
  String get challengeNameLabel => 'Name';

  @override
  String get challengeStartAction => 'Start challenge';

  @override
  String challengeAutoTitle(int days, String activity) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days of $activity',
      one: '1 day of $activity',
    );
    return '$_temp0';
  }

  @override
  String challengeProgressDays(int done, int target) {
    return '$done / $target days';
  }

  @override
  String challengeStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-day streak',
      one: '1-day streak',
    );
    return '$_temp0';
  }

  @override
  String get challengeTodayDone => 'Done today';

  @override
  String get challengeTodayAtRisk => 'Not yet today — streak at risk';

  @override
  String get challengeTodayNotYet => 'Not yet today';

  @override
  String get challengeCompleted => 'Completed';

  @override
  String challengeCompletedOn(String date) {
    return 'Completed $date';
  }

  @override
  String get challengeCurrentStreak => 'Current streak';

  @override
  String get challengeBestStreak => 'Best streak';

  @override
  String get challengeDaysDone => 'Days done';

  @override
  String get challengeDaysLeft => 'Days left';

  @override
  String get challengeCalendarSection => 'Your days';

  @override
  String get challengeRestart => 'Restart from today';

  @override
  String get challengeRestarted => 'Counting from today';

  @override
  String get challengeEnd => 'End challenge';

  @override
  String get challengeEnded => 'Challenge ended';

  @override
  String get challengeNotFound => 'This challenge has ended.';

  @override
  String challengeStartsOn(String date) {
    return 'Since $date';
  }

  @override
  String get challengeOptions => 'Challenge options';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get appearanceIntro =>
      'Pick the look you like. It changes the whole app; your days stay the same.';

  @override
  String get appearanceInUse => 'In use';

  @override
  String get themeNameRose => 'Rose';

  @override
  String get themeNameLavender => 'Lavender';

  @override
  String get themeNamePapaya => 'Papaya';

  @override
  String get themeDescriptionRose => 'Soft blush and rose, with calm teal.';

  @override
  String get themeDescriptionLavender =>
      'Porcelain and lavender, with fresh mint.';

  @override
  String get themeDescriptionPapaya => 'Warm papaya, with aqua mint.';

  @override
  String get appearancePreviewTitle => 'Morning walk';

  @override
  String get appearancePreviewDetail => '7:30 · 30 min';

  @override
  String get appearancePreviewAction => 'Start';

  @override
  String get planStatusPlanned => 'Planned';

  @override
  String todayProgress(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get todayRingCenter => 'done';

  @override
  String get todayHeroEmpty => 'A fresh day. Add what you\'d like to do.';

  @override
  String get todayHeroAllDone => 'Everything\'s done. Nicely done.';

  @override
  String get todayUpNext => 'Up next';

  @override
  String get todayDoingNow => 'Now';

  @override
  String todayUpNextIn(String duration) {
    return 'in $duration';
  }

  @override
  String get todayUpNextAnytime => 'Anytime today';

  @override
  String get todayUpNextStart => 'Start';

  @override
  String get todayUpNextContinue => 'Continue';

  @override
  String get todayFactTime => 'Time';

  @override
  String get todayFactLength => 'Planned';

  @override
  String get todayYourDay => 'Your day';

  @override
  String get todayEmptyTitle => 'Nothing on today yet';

  @override
  String get itemLive => 'Live';

  @override
  String get itemTimeSoFar => 'Time so far';

  @override
  String get itemDetailsSection => 'Details';

  @override
  String get groupRowNow => 'Now';

  @override
  String stepperDecrease(String field) {
    return 'Less $field';
  }

  @override
  String stepperIncrease(String field) {
    return 'More $field';
  }
}
