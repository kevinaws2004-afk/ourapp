import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Temporary visible product name. The real name is undecided (ADR-010). Change together with Android strings.xml and iOS Info.plist.
  ///
  /// In en, this message translates to:
  /// **'OurApp'**
  String get appTitle;

  /// Primary navigation tab: today's plan and timeline.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// Primary navigation tab: planning for future days.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get navPlan;

  /// Primary navigation: Challenges tab (ADR-044).
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get navChallenges;

  /// Primary navigation tab: graphs and history.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navInsights;

  /// Primary navigation tab: body measurements, preferences, settings.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get navMe;

  /// Title of the first-run screen (placeholder for the full onboarding).
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get onboardingTitle;

  /// Short first-run explanation, based on the product definition and privacy promise.
  ///
  /// In en, this message translates to:
  /// **'Plan your day, record what you actually do, and see your progress over time. Your data stays on this device.'**
  String get onboardingBody;

  /// Button that finishes the first-run screen.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingStart;

  /// Title shown when the local database fails to open.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t open your data'**
  String get startupFailureTitle;

  /// Explanation shown when the local database fails to open.
  ///
  /// In en, this message translates to:
  /// **'Nothing has been changed or deleted. Please try again. If this keeps happening, restart the app.'**
  String get startupFailureBody;

  /// Button to retry opening the local database.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get startupFailureRetry;

  /// Button: save the current form.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// Snackbar action that reverses the last change.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get actionUndo;

  /// Button/tooltip: edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// Button/tooltip: delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// Button: remove the current value.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// Button: retry after an error.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionTryAgain;

  /// Button: discard unsaved changes.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get actionDiscard;

  /// Button: return to the form without discarding.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get actionKeepEditing;

  /// Dialog title when leaving a form with unsaved changes.
  ///
  /// In en, this message translates to:
  /// **'Discard your changes?'**
  String get discardChangesTitle;

  /// Dialog message when leaving a form with unsaved changes.
  ///
  /// In en, this message translates to:
  /// **'What you\'ve entered here hasn\'t been saved.'**
  String get discardChangesMessage;

  /// Shown when an optional value is empty.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// Button: create a new activity type.
  ///
  /// In en, this message translates to:
  /// **'New activity'**
  String get newActivity;

  /// Snackbar after deleting an activity type.
  ///
  /// In en, this message translates to:
  /// **'{name} deleted'**
  String activityArchived(String name);

  /// Section title for the latest logs of an activity.
  ///
  /// In en, this message translates to:
  /// **'Recent records'**
  String get recentEntries;

  /// Empty state for an activity with no logs.
  ///
  /// In en, this message translates to:
  /// **'Nothing recorded yet. Record it to start this history.'**
  String get noEntriesYet;

  /// Builder title when creating.
  ///
  /// In en, this message translates to:
  /// **'New activity'**
  String get builderNewTitle;

  /// Builder title when editing.
  ///
  /// In en, this message translates to:
  /// **'Edit activity'**
  String get builderEditTitle;

  /// Activity name field label.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get activityNameLabel;

  /// Activity name field hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Reading'**
  String get activityNameHint;

  /// Activity description field label.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get activityDescriptionLabel;

  /// Section label for the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get iconLabel;

  /// Section label for the color picker.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorLabel;

  /// Section title for the list of fields.
  ///
  /// In en, this message translates to:
  /// **'What do you want to record?'**
  String get fieldsSectionTitle;

  /// Explains the built-in properties of every log.
  ///
  /// In en, this message translates to:
  /// **'Every entry already records when it happened, how long it took, and notes.'**
  String get fieldsSectionHint;

  /// Button: add a field to the activity.
  ///
  /// In en, this message translates to:
  /// **'Add field'**
  String get addField;

  /// Section title for activity behavior toggles.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get optionsSectionTitle;

  /// Toggle: the activity supports a timer.
  ///
  /// In en, this message translates to:
  /// **'Can be timed'**
  String get supportsTimerLabel;

  /// Explanation for the timer toggle.
  ///
  /// In en, this message translates to:
  /// **'Use a timer to record how long it took.'**
  String get supportsTimerHint;

  /// Toggle: the activity can be added to plans.
  ///
  /// In en, this message translates to:
  /// **'Can be planned'**
  String get supportsPlanningLabel;

  /// Section title for the live form preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewSectionTitle;

  /// Badge on a required field.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredBadge;

  /// Shown when a field type is locked.
  ///
  /// In en, this message translates to:
  /// **'This field already has entries, so its type can\'t change.'**
  String get lockedFieldHint;

  /// Label of a field that was removed from the activity but has historical values.
  ///
  /// In en, this message translates to:
  /// **'{name} (removed)'**
  String fieldRemoved(String name);

  /// Title of the field type picker.
  ///
  /// In en, this message translates to:
  /// **'Choose a field type'**
  String get fieldTypePickerTitle;

  /// Field type name: Text.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get fieldTypeText;

  /// Field type description for Text.
  ///
  /// In en, this message translates to:
  /// **'Words, a short note or a long description, like what the doctor said'**
  String get fieldTypeTextDescription;

  /// Field type name: Number.
  ///
  /// In en, this message translates to:
  /// **'An amount'**
  String get fieldTypeNumber;

  /// Field type description for Number.
  ///
  /// In en, this message translates to:
  /// **'A number, optionally in a unit like kg, km or pages'**
  String get fieldTypeNumberDescription;

  /// Field type name: Yes / No.
  ///
  /// In en, this message translates to:
  /// **'Yes or no'**
  String get fieldTypeBoolean;

  /// Field type description for Yes / No.
  ///
  /// In en, this message translates to:
  /// **'Something that did or didn\'t happen'**
  String get fieldTypeBooleanDescription;

  /// Field type name: Single choice.
  ///
  /// In en, this message translates to:
  /// **'One choice'**
  String get fieldTypeSingleSelect;

  /// Field type description for Single choice.
  ///
  /// In en, this message translates to:
  /// **'Pick one option from your list'**
  String get fieldTypeSingleSelectDescription;

  /// Field type name: Multiple choice.
  ///
  /// In en, this message translates to:
  /// **'Several choices'**
  String get fieldTypeMultiSelect;

  /// Field type description for Multiple choice.
  ///
  /// In en, this message translates to:
  /// **'Pick any options from your list'**
  String get fieldTypeMultiSelectDescription;

  /// Field type name: Date.
  ///
  /// In en, this message translates to:
  /// **'A date'**
  String get fieldTypeDate;

  /// Field type description for Date.
  ///
  /// In en, this message translates to:
  /// **'A calendar date'**
  String get fieldTypeDateDescription;

  /// Field type name: Time.
  ///
  /// In en, this message translates to:
  /// **'A time of day'**
  String get fieldTypeTime;

  /// Field type description for Time.
  ///
  /// In en, this message translates to:
  /// **'A time of day'**
  String get fieldTypeTimeDescription;

  /// Field type name: Duration.
  ///
  /// In en, this message translates to:
  /// **'Time spent'**
  String get fieldTypeDuration;

  /// Field type description for Duration.
  ///
  /// In en, this message translates to:
  /// **'An amount of time, like rest or practice time'**
  String get fieldTypeDurationDescription;

  /// Field type name: Rating.
  ///
  /// In en, this message translates to:
  /// **'A rating'**
  String get fieldTypeRating;

  /// Field type description for Rating.
  ///
  /// In en, this message translates to:
  /// **'Stars on a scale you choose'**
  String get fieldTypeRatingDescription;

  /// Field type name: Repeating group.
  ///
  /// In en, this message translates to:
  /// **'A list'**
  String get fieldTypeRepeatingGroup;

  /// Field type description for Repeating group.
  ///
  /// In en, this message translates to:
  /// **'Rows with their own details, like exercises → sets, medicines or people'**
  String get fieldTypeRepeatingGroupDescription;

  /// Badge on a field type that is not available yet.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get availableLater;

  /// Field editor title when adding.
  ///
  /// In en, this message translates to:
  /// **'New field'**
  String get fieldEditorNewTitle;

  /// Field editor title when editing.
  ///
  /// In en, this message translates to:
  /// **'Edit field'**
  String get fieldEditorEditTitle;

  /// Field name input label.
  ///
  /// In en, this message translates to:
  /// **'Field name'**
  String get fieldNameLabel;

  /// Toggle: field must be filled in.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredLabel;

  /// Toggle: field values feed insights.
  ///
  /// In en, this message translates to:
  /// **'Show in insights'**
  String get measurableLabel;

  /// Toggle: text field allows several lines.
  ///
  /// In en, this message translates to:
  /// **'Multiple lines'**
  String get multilineLabel;

  /// Number field decimals setting.
  ///
  /// In en, this message translates to:
  /// **'Decimal places'**
  String get decimalsLabel;

  /// Number field minimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get minimumLabel;

  /// Number field maximum.
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get maximumLabel;

  /// Number field: what kind of unit it uses.
  ///
  /// In en, this message translates to:
  /// **'Measured in'**
  String get unitDimensionLabel;

  /// Number field without a unit.
  ///
  /// In en, this message translates to:
  /// **'No unit'**
  String get unitNone;

  /// Unit dimension name: Weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get dimensionMass;

  /// Unit dimension name: Distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get dimensionDistance;

  /// Unit dimension name: Volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get dimensionVolume;

  /// Unit dimension name: Temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get dimensionTemperature;

  /// Unit dimension name: Energy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get dimensionEnergy;

  /// Number field default unit.
  ///
  /// In en, this message translates to:
  /// **'Default unit'**
  String get defaultUnitLabel;

  /// Select field options list.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get optionsLabel;

  /// Button: add a select option.
  ///
  /// In en, this message translates to:
  /// **'Add option'**
  String get addOption;

  /// Hint for a select option input.
  ///
  /// In en, this message translates to:
  /// **'Option name'**
  String get optionHint;

  /// Rating field maximum stars.
  ///
  /// In en, this message translates to:
  /// **'Scale'**
  String get ratingScaleLabel;

  /// Button: remove the field from the activity.
  ///
  /// In en, this message translates to:
  /// **'Remove field'**
  String get removeField;

  /// Button: confirm and close a sheet.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneAction;

  /// Log duration label.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// Log notes label.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// Duration of at least an hour.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String durationHoursMinutes(int hours, int minutes);

  /// Duration under an hour.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String durationMinutes(int minutes);

  /// Boolean value true.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get booleanYes;

  /// Boolean value false.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get booleanNo;

  /// Activity list opened from a day: title.
  ///
  /// In en, this message translates to:
  /// **'Choose an activity'**
  String get activitiesBrowseTitle;

  /// Activity list: subtitle.
  ///
  /// In en, this message translates to:
  /// **'Use any of these as it is, change it later, or make your own.'**
  String get activitiesBrowseSubtitle;

  /// Activity list: hint in the search field (matches names, categories and what they log).
  ///
  /// In en, this message translates to:
  /// **'Search activities'**
  String get activitiesSearchHint;

  /// Activity list: shown when the search matches nothing.
  ///
  /// In en, this message translates to:
  /// **'No activity matches. Make your own instead.'**
  String get activitiesNoMatch;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get builtInReading;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get builtInReadingBook;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get builtInReadingPages;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get builtInReadingRating;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Focused work'**
  String get builtInFocusedWork;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get builtInFocusedWorkProject;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get builtInWalking;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get builtInWalkingDistance;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get builtInWalkingSteps;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get builtInWalkingCalories;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get builtInWalkingLocation;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Language learning'**
  String get builtInLanguage;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get builtInLanguageLanguage;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Words learned'**
  String get builtInLanguageWords;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get builtInLanguageLesson;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get builtInLanguageDifficulty;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get builtInLanguageSpanish;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get builtInLanguageFrench;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get builtInLanguageGerman;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get builtInLanguageJapanese;

  /// Generic error message.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// Storage error message.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your changes. Nothing was lost; please try again.'**
  String get errorStorage;

  /// Not-found error message.
  ///
  /// In en, this message translates to:
  /// **'This item no longer exists.'**
  String get errorNotFound;

  /// Unsupported-data error message.
  ///
  /// In en, this message translates to:
  /// **'This was created by a newer version of the app.'**
  String get errorUnsupported;

  /// Shown when a form has validation issues.
  ///
  /// In en, this message translates to:
  /// **'Some details need attention.'**
  String get errorValidation;

  /// Shown when a screen fails to load.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load this. Please try again.'**
  String get loadErrorMessage;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'This is required.'**
  String get validationRequired;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name.'**
  String get validationNameRequired;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'That name is too long.'**
  String get validationNameTooLong;

  /// Validation message when creating or renaming an activity to a name another activity already uses.
  ///
  /// In en, this message translates to:
  /// **'You already have an activity with this name.'**
  String get validationDuplicateActivityName;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'Another field already has this name.'**
  String get validationDuplicateFieldName;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'Please choose an icon.'**
  String get validationUnknownIcon;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'Please choose a color.'**
  String get validationUnknownColor;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'This is too long.'**
  String get validationTextTooLong;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'Please enter a number.'**
  String get validationNotANumber;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'This is below the minimum.'**
  String get validationBelowMinimum;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'This is above the maximum.'**
  String get validationAboveMaximum;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'Too many decimal places.'**
  String get validationTooManyDecimals;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'Please choose a unit.'**
  String get validationUnitRequired;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'This field doesn\'t use units.'**
  String get validationUnitNotAllowed;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'That option doesn\'t exist anymore.'**
  String get validationUnknownOption;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'That option has been retired.'**
  String get validationArchivedOption;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'Options need different names.'**
  String get validationDuplicateOption;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'Options need a name.'**
  String get validationOptionLabelRequired;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'Add at least one option.'**
  String get validationOptionsRequired;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'Choose a rating on the scale.'**
  String get validationRatingOutOfRange;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'The scale must be between 3 and 10.'**
  String get validationInvalidRatingScale;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'The minimum must not be more than the maximum.'**
  String get validationInvalidMinMax;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'Duration can\'t be negative.'**
  String get validationNegativeDuration;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'Duration can\'t be longer than the time between start and end.'**
  String get validationDurationExceedsElapsed;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'The end can\'t be before the start.'**
  String get validationEndBeforeStart;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'This field has entries, so its type can\'t change. Add a new field instead.'**
  String get validationFieldSemanticsLocked;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'This field type isn\'t available yet.'**
  String get validationFieldTypeNotSupportedYet;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'Please choose a valid date.'**
  String get validationInvalidDate;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'Please choose a valid time.'**
  String get validationInvalidTime;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'This field is no longer part of the activity.'**
  String get validationUnknownField;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'This value doesn\'t fit the field.'**
  String get validationValueTypeMismatch;

  /// User-facing action for recording what actually happened (ADR-028).
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get actionRecord;

  /// Title of the activity management screen under Me.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activitiesTitle;

  /// Subtitle of the Activities screen.
  ///
  /// In en, this message translates to:
  /// **'Everything you can plan and record. Use any of them as it is, change it, or make your own.'**
  String get activitiesSubtitle;

  /// Subtitle of the Activities entry on the Me tab.
  ///
  /// In en, this message translates to:
  /// **'Create and configure what you record'**
  String get meActivitiesSubtitle;

  /// Relative date label / button to jump to today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get planToday;

  /// Relative date label.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get planTomorrow;

  /// Relative date label.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get planYesterday;

  /// Tooltip for the previous-week button.
  ///
  /// In en, this message translates to:
  /// **'Previous week'**
  String get planPreviousWeek;

  /// Tooltip for the next-week button.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get planNextWeek;

  /// Shown when a date has no plans.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned for this day.'**
  String get planPlannedEmpty;

  /// Summary of a repeating group: its item label and number of items, e.g. 'Set × 3'.
  ///
  /// In en, this message translates to:
  /// **'{itemLabel} × {count}'**
  String groupItemCount(String itemLabel, int count);

  /// Title of one repeating-group item, e.g. 'Set 2'.
  ///
  /// In en, this message translates to:
  /// **'{itemLabel} {number}'**
  String groupItemTitle(String itemLabel, int number);

  /// Button adding an item to a repeating group, e.g. 'Add Set'.
  ///
  /// In en, this message translates to:
  /// **'Add {itemLabel}'**
  String addGroupItem(String itemLabel);

  /// Tooltip removing one repeating-group item.
  ///
  /// In en, this message translates to:
  /// **'Remove {itemLabel}'**
  String removeGroupItem(String itemLabel);

  /// Field editor: what one item of a repeating group is called.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get itemLabelLabel;

  /// Helper text for the repeating-group item name.
  ///
  /// In en, this message translates to:
  /// **'Shown on the add button, like “Add Set”'**
  String get itemLabelHelper;

  /// Field editor: heading for a repeating group's sub-fields.
  ///
  /// In en, this message translates to:
  /// **'Fields in each item'**
  String get subFieldsLabel;

  /// Field editor: shown when a repeating group has no sub-fields yet.
  ///
  /// In en, this message translates to:
  /// **'Add the fields each item records, like weight and reps.'**
  String get subFieldsEmpty;

  /// Field editor: adds a sub-field to a repeating group.
  ///
  /// In en, this message translates to:
  /// **'Add field to item'**
  String get addSubField;

  /// Text field setting: offer previously entered values while typing.
  ///
  /// In en, this message translates to:
  /// **'Suggest previous entries'**
  String get suggestFromHistoryLabel;

  /// Subtitle for the suggest-previous-entries setting.
  ///
  /// In en, this message translates to:
  /// **'Handy for names you repeat, like exercises'**
  String get suggestFromHistoryHint;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'Add at least one field to each item.'**
  String get validationSubFieldsRequired;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'Groups can only be nested one level deep.'**
  String get validationNestingTooDeep;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'Give each item a name, like “Set”.'**
  String get validationItemLabelRequired;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get builtInGym;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get builtInGymExercises;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get builtInGymExerciseItem;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get builtInGymExercise;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get builtInGymSets;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get builtInGymSetItem;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get builtInGymWeight;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get builtInGymReps;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Meeting'**
  String get builtInMeeting;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get builtInMeetingPeople;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get builtInMeetingTopics;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Decisions'**
  String get builtInMeetingDecisions;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Action items'**
  String get builtInMeetingActionItems;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Action item'**
  String get builtInMeetingActionItem;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get builtInMeetingActionItemText;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get builtInMeetingActionItemDone;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Cooking'**
  String get builtInCooking;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Recipe'**
  String get builtInCookingRecipe;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get builtInCookingServings;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get builtInCookingCalories;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get builtInCookingRating;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get builtInCookingIngredients;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Ingredient'**
  String get builtInCookingIngredientItem;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Ingredient'**
  String get builtInCookingIngredient;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Have it'**
  String get builtInCookingHaveIt;

  /// Plan sheet: which activity the plan is for (or a task).
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get planActivityLabel;

  /// Plan sheet chip: a plan without an activity (a Task).
  ///
  /// In en, this message translates to:
  /// **'Just a task'**
  String get planTaskChoice;

  /// Quick add / plan sheet: opens the list of activities to pick one.
  ///
  /// In en, this message translates to:
  /// **'Browse activities'**
  String get planBrowseActivities;

  /// Quick add / plan sheet: opens the builder to define a new activity (what to log) and plan it.
  ///
  /// In en, this message translates to:
  /// **'Make your own'**
  String get planMakeOwn;

  /// Quick add suggestion for a name no activity has yet.
  ///
  /// In en, this message translates to:
  /// **'Make “{name}” your own'**
  String planMakeOwnNamed(String name);

  /// Quick add suggestion subtitle under planMakeOwnNamed.
  ///
  /// In en, this message translates to:
  /// **'New activity · choose what to log'**
  String get planMakeOwnHint;

  /// Plan sheet: shown when the plan has no start time.
  ///
  /// In en, this message translates to:
  /// **'Any time'**
  String get planAnyTime;

  /// Plan sheet: shown when the plan has no end time.
  ///
  /// In en, this message translates to:
  /// **'No end time'**
  String get planNoEnd;

  /// Plan sheet: planned start time label.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get planStartLabel;

  /// Plan sheet: planned end time label.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get planEndLabel;

  /// Plan sheet: planned duration without fixed times, e.g. read for 45 minutes.
  ///
  /// In en, this message translates to:
  /// **'How long'**
  String get planDurationLabel;

  /// Plan sheet title when creating a plan; also the tooltip of the add button.
  ///
  /// In en, this message translates to:
  /// **'New plan'**
  String get planNewTitle;

  /// Plan sheet title when editing a plan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get planEditTitle;

  /// Plan sheet: title field.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get planTitleLabel;

  /// Plan sheet: helper under the title field.
  ///
  /// In en, this message translates to:
  /// **'Optional for an activity: it uses the activity\'s name'**
  String get planTitleHelper;

  /// Completes a task (no record is created).
  ///
  /// In en, this message translates to:
  /// **'Mark as done'**
  String get planCompleteTask;

  /// Reopens a completed task.
  ///
  /// In en, this message translates to:
  /// **'Mark as not done'**
  String get planReopenTask;

  /// Plan sheet action: skip this plan. Neutral, not a failure.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get planSkip;

  /// Plan sheet action: make a skipped, cancelled or done plan open again.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get planReopen;

  /// Plan sheet action: move the plan to the next day.
  ///
  /// In en, this message translates to:
  /// **'Move to tomorrow'**
  String get planMoveToTomorrow;

  /// Plan sheet action: delete the plan (with Undo).
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get planDelete;

  /// Snackbar after deleting a plan (with Undo).
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get planDeletedMessage;

  /// Snackbar after moving a plan (with Undo).
  ///
  /// In en, this message translates to:
  /// **'Moved to tomorrow'**
  String get planMovedMessage;

  /// Snackbar after skipping a plan (with Undo).
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get planSkippedMessage;

  /// Accessibility label of a plan's drag handle.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get planReorderHandle;

  /// Status of a completed task.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get planStatusDone;

  /// Status of a skipped plan. Neutral.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get planStatusSkipped;

  /// Status of a cancelled plan. Neutral.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get planStatusCancelled;

  /// Today greeting before noon.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get todayGreetingMorning;

  /// Today greeting from noon to 18:00.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get todayGreetingAfternoon;

  /// Today greeting in the evening and at night.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get todayGreetingEvening;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'Use either an end time or a length, not both.'**
  String get validationPlannedDurationConflict;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'This activity can\'t be planned.'**
  String get validationActivityNotPlannable;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'This plan already has a record, so its activity can\'t change.'**
  String get validationPlanActivityLocked;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'This plan is for a different activity.'**
  String get validationPlanRecordMismatch;

  /// Outcome of a recorded plan without a planned length.
  ///
  /// In en, this message translates to:
  /// **'{duration}'**
  String planRecordedDuration(String duration);

  /// Planned vs actual: actual duration of the planned duration.
  ///
  /// In en, this message translates to:
  /// **'{actual} of {planned}'**
  String planRecordedOfPlanned(String actual, String planned);

  /// A planned time range.
  ///
  /// In en, this message translates to:
  /// **'{start}–{end}'**
  String planTimeRange(String start, String end);

  /// Screen reader hint for tapping a recorded plan.
  ///
  /// In en, this message translates to:
  /// **'open it'**
  String get planOpenRecordHint;

  /// Screen reader hint for tapping a planned activity.
  ///
  /// In en, this message translates to:
  /// **'open {title} to log it'**
  String planRecordHint(String title);

  /// Time picker title: planned start time.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get planPickStart;

  /// Time picker title: planned end time; cancel for no end.
  ///
  /// In en, this message translates to:
  /// **'To (optional)'**
  String get planPickEnd;

  /// Built-in activity content (becomes the user's own editable activity once used). What a gym session trained, e.g. Chest.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get builtInGymFocus;

  /// Built-in Gym activity: an option of the Workout choice (becomes the user's own editable data once used).
  ///
  /// In en, this message translates to:
  /// **'Push'**
  String get builtInGymPush;

  /// Built-in Gym activity: an option of the Workout choice (becomes the user's own editable data once used).
  ///
  /// In en, this message translates to:
  /// **'Pull'**
  String get builtInGymPull;

  /// Built-in Gym activity: an option of the Workout choice (becomes the user's own editable data once used).
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get builtInGymLegs;

  /// Built-in Gym activity: an option of the Workout choice (becomes the user's own editable data once used).
  ///
  /// In en, this message translates to:
  /// **'Upper body'**
  String get builtInGymUpperBody;

  /// Built-in Gym activity: an option of the Workout choice (becomes the user's own editable data once used).
  ///
  /// In en, this message translates to:
  /// **'Lower body'**
  String get builtInGymLowerBody;

  /// Built-in Gym activity: an option of the Workout choice (becomes the user's own editable data once used).
  ///
  /// In en, this message translates to:
  /// **'Full body'**
  String get builtInGymFullBody;

  /// Built-in Gym activity: an option of the Workout choice (becomes the user's own editable data once used).
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get builtInGymCardio;

  /// Starts a focus timer for the activity.
  ///
  /// In en, this message translates to:
  /// **'Start focus'**
  String get focusStart;

  /// Focus timer: pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get focusPause;

  /// Focus timer: resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get focusResume;

  /// Focus timer: finish and record the session.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get focusFinish;

  /// Focus timer: end without recording.
  ///
  /// In en, this message translates to:
  /// **'Discard session'**
  String get focusDiscard;

  /// Confirmation title before discarding a focus session.
  ///
  /// In en, this message translates to:
  /// **'Discard this session?'**
  String get focusDiscardTitle;

  /// Confirmation message before discarding a focus session.
  ///
  /// In en, this message translates to:
  /// **'The timed session won\'t be recorded.'**
  String get focusDiscardMessage;

  /// Focus timer state.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get focusPaused;

  /// Focus timer state.
  ///
  /// In en, this message translates to:
  /// **'Focusing'**
  String get focusRunning;

  /// Screen reader label of the timer.
  ///
  /// In en, this message translates to:
  /// **'Focused time'**
  String get focusElapsedLabel;

  /// Today banner: go back to the running focus session.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get focusReturn;

  /// Focus screen when nothing is running.
  ///
  /// In en, this message translates to:
  /// **'No focus session'**
  String get focusNoneTitle;

  /// Focus screen when nothing is running.
  ///
  /// In en, this message translates to:
  /// **'Start one from a plan or an activity.'**
  String get focusNoneMessage;

  /// Plan status while a focus session runs on it.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get planStatusInProgress;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'A focus session is already running.'**
  String get validationFocusAlreadyActive;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'This activity doesn\'t use a timer.'**
  String get validationActivityHasNoTimer;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'This focus session has already ended.'**
  String get validationFocusNotActive;

  /// Unit dimension: a share, e.g. body fat %.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get dimensionPercentage;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get insightActivitySection;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Add chart'**
  String get insightAddChart;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Edit chart'**
  String get insightEditChart;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'total'**
  String get insightAggSum;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'average'**
  String get insightAggAverage;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'best'**
  String get insightAggMax;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'lowest'**
  String get insightAggMin;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'count'**
  String get insightAggCount;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'latest'**
  String get insightAggLatest;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'All activities'**
  String get insightAllActivities;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get insightBucketDay;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get insightBucketWeek;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get insightBucketMonth;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Bars'**
  String get insightChartBar;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Line'**
  String get insightChartLine;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Chart deleted'**
  String get insightChartDeleted;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Chart options'**
  String get insightChartOptions;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Chart'**
  String get insightChartTypeLabel;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Your own charts'**
  String get insightChartsSection;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Build your first chart'**
  String get insightChartsEmptyTitle;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Chart anything you record: time, how often, any number (like the weight of your sets), volume, body measurements, or planned vs actual.'**
  String get insightChartsEmptyMessage;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Choose an activity'**
  String get insightChooseActivity;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get insightChooseField;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get insightDelete;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get insightEdit;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Field'**
  String get insightFieldLabel;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Only where'**
  String get insightFilterLabel;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Value, e.g. Chest Press'**
  String get insightFilterValueHint;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Group by'**
  String get insightGroupByLabel;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get insightGroupLabel;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get insightHowLabel;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Body measurement'**
  String get insightKindBody;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'How often'**
  String get insightKindCount;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'A field'**
  String get insightKindField;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Planned vs actual'**
  String get insightKindPlannedVsActual;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get insightKindTime;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get insightKindVolume;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Nothing recorded in this period.'**
  String get insightNoActivity;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'No data in this period yet.'**
  String get insightNoData;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Everything'**
  String get insightNoFilter;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'This activity has no number fields.'**
  String get insightNoNumberFields;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'This activity has no group with two number fields (like weight and reps).'**
  String get insightNoVolumeGroups;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Grey: planned · Colour: recorded'**
  String get insightPlannedVsActualLegend;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get insightRangeWeek;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get insightRangeMonth;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'3 months'**
  String get insightRangeQuarter;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get insightRangeYear;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get insightTitleLabel;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'What to chart'**
  String get insightWhatLabel;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Weight, body fat and other measurements'**
  String get meMeasurementsSubtitle;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Add measurement'**
  String get measurementAdd;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Delete measurement'**
  String get measurementDelete;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Measurement deleted'**
  String get measurementDeleted;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get measurementHistory;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Nothing recorded yet'**
  String get measurementNone;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get measurementValue;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Body measurements'**
  String get measurementsTitle;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Track your body over time. Each one becomes a chart.'**
  String get measurementsIntro;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get measurementWeight;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get measurementHeight;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Body fat'**
  String get measurementBodyFat;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get measurementChest;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get measurementWaist;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Arms'**
  String get measurementArms;

  /// Insights / body measurements copy.
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get measurementLegs;

  /// Neutral comparison with the previous period.
  ///
  /// In en, this message translates to:
  /// **'{change} vs previous period'**
  String insightChange(String change);

  /// Planned vs actual totals.
  ///
  /// In en, this message translates to:
  /// **'Recorded {actual} of {planned} planned'**
  String insightPlannedVsActualSummary(String actual, String planned);

  /// How often an activity was recorded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{once} other{{count} times}}'**
  String insightTimesRecorded(int count);

  /// Default chart title.
  ///
  /// In en, this message translates to:
  /// **'{activity} · time'**
  String insightTitleTime(String activity);

  /// Default chart title.
  ///
  /// In en, this message translates to:
  /// **'{activity} · how often'**
  String insightTitleCount(String activity);

  /// Default chart title.
  ///
  /// In en, this message translates to:
  /// **'{activity} · volume'**
  String insightTitleVolume(String activity);

  /// Explains the volume metric.
  ///
  /// In en, this message translates to:
  /// **'Volume = {amount} × {count} per item'**
  String insightVolumeFormula(String amount, String count);

  /// Shown in an item while what the user logged is being saved.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get itemSaving;

  /// Shown in an item once everything logged is saved (it saves as you type).
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get itemSaved;

  /// Shown in an item when a value can't be saved.
  ///
  /// In en, this message translates to:
  /// **'Not saved yet: check the highlighted fields'**
  String get itemSaveFailed;

  /// Status of an item that has been done or logged.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get itemDone;

  /// Opens the running timer full screen.
  ///
  /// In en, this message translates to:
  /// **'Full screen timer'**
  String get itemTimerFullScreen;

  /// Section in an item with when it happened and how long.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get itemWhenSection;

  /// Tooltip of the item's options menu (edit, skip, move, delete).
  ///
  /// In en, this message translates to:
  /// **'Item options'**
  String get itemOptions;

  /// Snackbar after deleting an item.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get itemDeleted;

  /// Shown in an item whose activity has no fields yet.
  ///
  /// In en, this message translates to:
  /// **'What do you want to keep track of? Pick one, or just write notes.'**
  String get itemNothingToLogHint;

  /// Today's summary: how many items were done, and their total time.
  ///
  /// In en, this message translates to:
  /// **'{count} done · {duration}'**
  String todayDoneSummary(int count, String duration);

  /// Today's summary when nothing done has a duration.
  ///
  /// In en, this message translates to:
  /// **'{count} done'**
  String todayDoneCount(int count);

  /// Today empty state message.
  ///
  /// In en, this message translates to:
  /// **'Add what you\'re doing or planning. Open it later to log how it went.'**
  String get todayEmptyMessageItems;

  /// Button in an item: add something new to log (a number, a list, …).
  ///
  /// In en, this message translates to:
  /// **'Add to log'**
  String get itemAddToLog;

  /// Title of the sheet for adding something to log.
  ///
  /// In en, this message translates to:
  /// **'What do you want to log?'**
  String get itemAddToLogTitle;

  /// Ready-made: exercises, each with sets of weight × reps.
  ///
  /// In en, this message translates to:
  /// **'Sets & reps'**
  String get shapeSetsReps;

  /// Description of the Sets & reps ready-made.
  ///
  /// In en, this message translates to:
  /// **'Exercises, each with sets of weight × reps'**
  String get shapeSetsRepsDescription;

  /// Ready-made: items you can tick off.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get shapeChecklist;

  /// Description of the Checklist ready-made.
  ///
  /// In en, this message translates to:
  /// **'Items to tick off, like things to buy or do'**
  String get shapeChecklistDescription;

  /// A checklist row.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get shapeChecklistItem;

  /// A checklist row's tick.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get shapeChecklistDone;

  /// Menu item inside a list in an item: add another detail to every row (e.g. "Add a detail to each Set").
  ///
  /// In en, this message translates to:
  /// **'Add a detail to each {item}'**
  String addGroupDetailTo(String item);

  /// Tooltip of the menu on a list in an item.
  ///
  /// In en, this message translates to:
  /// **'{item} list options'**
  String groupListOptions(String item);

  /// Tooltip: rename, reorder or remove what this item logs.
  ///
  /// In en, this message translates to:
  /// **'Edit what\'s logged'**
  String get itemEditFields;

  /// Error: a repeat rule with no days or an end before the plan.
  ///
  /// In en, this message translates to:
  /// **'Choose at least one day, and an end date on or after this one.'**
  String get validationInvalidRepeat;

  /// Plan option: make it repeat on chosen days.
  ///
  /// In en, this message translates to:
  /// **'Repeat…'**
  String get planRepeat;

  /// Plan option on a repeating plan.
  ///
  /// In en, this message translates to:
  /// **'Stop repeating after this'**
  String get planStopRepeating;

  /// Title of the repeat sheet.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get planRepeatTitle;

  /// Label before the week interval in the repeat sheet.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get planRepeatEvery;

  /// Repeat interval option, e.g. 'Every 2 weeks'.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{week} other{{count} weeks}}'**
  String planRepeatWeeks(int count);

  /// Label for the repeat's optional end date.
  ///
  /// In en, this message translates to:
  /// **'Until'**
  String get planRepeatUntil;

  /// The repeat has no end date.
  ///
  /// In en, this message translates to:
  /// **'No end'**
  String get planRepeatForever;

  /// Snackbar after setting a repeat, e.g. 'Repeats Mon, Wed, Fri'.
  ///
  /// In en, this message translates to:
  /// **'Repeats {days}'**
  String planRepeatSaved(String days);

  /// Snackbar after stopping a repeat.
  ///
  /// In en, this message translates to:
  /// **'Won\'t repeat after this'**
  String get planRepeatStopped;

  /// Button in an item: plan the same thing on another date (next appointment, next session).
  ///
  /// In en, this message translates to:
  /// **'Plan next…'**
  String get planNextAction;

  /// Snackbar after Plan next.
  ///
  /// In en, this message translates to:
  /// **'Planned for {date}'**
  String planNextPlanned(String date);

  /// Action in a snackbar: open what was just created.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get actionOpen;

  /// Plan tab view switch.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get planViewWeek;

  /// Plan tab view switch.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get planViewMonth;

  /// Automatic chart: time spent per week.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get insightAutoTime;

  /// Automatic chart: how often per week.
  ///
  /// In en, this message translates to:
  /// **'Times done'**
  String get insightAutoCount;

  /// Automatic chart: best value of a field, e.g. 'Best Weight'.
  ///
  /// In en, this message translates to:
  /// **'Best {field}'**
  String insightAutoBest(String field);

  /// Automatic chart for one list row, e.g. 'Chest Press · best Weight'.
  ///
  /// In en, this message translates to:
  /// **'{row} · best {field}'**
  String insightAutoRowBest(String field, String row);

  /// Automatic chart: weight × reps summed.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get insightAutoVolume;

  /// Automatic chart: volume of one list row, e.g. 'Chest Press · volume'.
  ///
  /// In en, this message translates to:
  /// **'{row} · volume'**
  String insightAutoRowVolume(String row);

  /// How many days an activity was done in the period.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String insightDaysDone(int count);

  /// Section on an activity's insights page with its automatic charts.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get insightProgressSection;

  /// Activity progress page: nothing in the selected period (C4).
  ///
  /// In en, this message translates to:
  /// **'Nothing logged for {name} in this period. Pick a longer period above to see its progress.'**
  String insightActivityEmpty(String name);

  /// Generic confirm button that closes a sheet.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// Quick add: label above the most-used activities.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get planRecent;

  /// Title of the time sheet when planning.
  ///
  /// In en, this message translates to:
  /// **'When?'**
  String get planTimeSheetTitle;

  /// Time sheet: label above the start time choices.
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get planTimeStarts;

  /// Time sheet: label above the length choices.
  ///
  /// In en, this message translates to:
  /// **'How long'**
  String get planTimeLength;

  /// Time sheet: picks any start time.
  ///
  /// In en, this message translates to:
  /// **'Other time…'**
  String get planTimeOther;

  /// Time sheet: no end time.
  ///
  /// In en, this message translates to:
  /// **'No end'**
  String get planTimeNoEnd;

  /// Time sheet length chip in minutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String planTimeMinutes(int count);

  /// Time sheet length chip in hours.
  ///
  /// In en, this message translates to:
  /// **'{count} h'**
  String planTimeHours(int count);

  /// Time sheet: picks an end time.
  ///
  /// In en, this message translates to:
  /// **'Until…'**
  String get planTimeUntil;

  /// Time sheet: the chosen end time.
  ///
  /// In en, this message translates to:
  /// **'Until {time}'**
  String planTimeUntilTime(String time);

  /// Time sheet: removes the chosen time.
  ///
  /// In en, this message translates to:
  /// **'No time'**
  String get planTimeRemove;

  /// Me tab: section with Activities and Body measurements.
  ///
  /// In en, this message translates to:
  /// **'Your setup'**
  String get meSectionSetup;

  /// Label of the hours box in a duration input.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get durationHoursLabel;

  /// Label of the minutes box in a duration input.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get durationMinutesLabel;

  /// Heading above a day's items that have no time.
  ///
  /// In en, this message translates to:
  /// **'Anytime'**
  String get planAnytime;

  /// Chart headline label: the sum over the period shown.
  ///
  /// In en, this message translates to:
  /// **'total this period'**
  String get insightPeriodTotal;

  /// Chart headline label.
  ///
  /// In en, this message translates to:
  /// **'average this period'**
  String get insightPeriodAverage;

  /// Chart headline label: the highest value in the period shown.
  ///
  /// In en, this message translates to:
  /// **'best this period'**
  String get insightPeriodBest;

  /// Chart headline label.
  ///
  /// In en, this message translates to:
  /// **'lowest this period'**
  String get insightPeriodLowest;

  /// Chart headline label: how many in the period shown.
  ///
  /// In en, this message translates to:
  /// **'times this period'**
  String get insightPeriodCount;

  /// A chart's highest value ever, with its date.
  ///
  /// In en, this message translates to:
  /// **'All-time best {value} · {date}'**
  String insightAllTimeBest(String value, String date);

  /// A volume chart: the highest total on one day ever.
  ///
  /// In en, this message translates to:
  /// **'Best day {value} · {date}'**
  String insightBestDay(String value, String date);

  /// A volume chart: the highest single row ever (e.g. "Best Set 480 kg").
  ///
  /// In en, this message translates to:
  /// **'Best {item} {value} · {date}'**
  String insightBestItem(String item, String value, String date);

  /// The dates the Insights numbers cover.
  ///
  /// In en, this message translates to:
  /// **'{from} – {to}'**
  String insightPeriod(String from, String to);

  /// Insights: shown under an activity whose name another activity also uses.
  ///
  /// In en, this message translates to:
  /// **'Another activity has this name. Rename one in Me → Activities.'**
  String get insightDuplicateName;

  /// Screen-reader name of the "barbell" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Weights'**
  String get activityIconBarbell;

  /// Screen-reader name of the "book-open" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get activityIconBookOpen;

  /// Screen-reader name of the "briefcase" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Briefcase'**
  String get activityIconBriefcase;

  /// Screen-reader name of the "person-simple-walk" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get activityIconPersonSimpleWalk;

  /// Screen-reader name of the "person-simple-run" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get activityIconPersonSimpleRun;

  /// Screen-reader name of the "bicycle" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get activityIconBicycle;

  /// Screen-reader name of the "swimming-pool" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Swimming'**
  String get activityIconSwimmingPool;

  /// Screen-reader name of the "flower-lotus" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Meditation'**
  String get activityIconFlowerLotus;

  /// Screen-reader name of the "users-three" activity icon.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get activityIconUsersThree;

  /// Screen-reader name of the "pencil-simple" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Writing'**
  String get activityIconPencilSimple;

  /// Screen-reader name of the "code" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Coding'**
  String get activityIconCode;

  /// Screen-reader name of the "cooking-pot" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Cooking'**
  String get activityIconCookingPot;

  /// Screen-reader name of the "translate" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get activityIconTranslate;

  /// Screen-reader name of the "graduation-cap" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Studying'**
  String get activityIconGraduationCap;

  /// Screen-reader name of the "brain" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Thinking'**
  String get activityIconBrain;

  /// Screen-reader name of the "music-notes" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get activityIconMusicNotes;

  /// Screen-reader name of the "guitar" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Guitar'**
  String get activityIconGuitar;

  /// Screen-reader name of the "microphone" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get activityIconMicrophone;

  /// Screen-reader name of the "paint-brush" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Painting'**
  String get activityIconPaintBrush;

  /// Screen-reader name of the "camera" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Photography'**
  String get activityIconCamera;

  /// Screen-reader name of the "game-controller" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get activityIconGameController;

  /// Screen-reader name of the "moon" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get activityIconMoon;

  /// Screen-reader name of the "bed" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get activityIconBed;

  /// Screen-reader name of the "coffee" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get activityIconCoffee;

  /// Screen-reader name of the "fork-knife" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get activityIconForkKnife;

  /// Screen-reader name of the "drop" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get activityIconDrop;

  /// Screen-reader name of the "pill" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get activityIconPill;

  /// Screen-reader name of the "first-aid" activity icon.
  ///
  /// In en, this message translates to:
  /// **'First aid'**
  String get activityIconFirstAid;

  /// Screen-reader name of the "tooth" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Teeth'**
  String get activityIconTooth;

  /// Screen-reader name of the "heart" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Heart'**
  String get activityIconHeart;

  /// Screen-reader name of the "leaf" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get activityIconLeaf;

  /// Screen-reader name of the "plant" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Plants'**
  String get activityIconPlant;

  /// Screen-reader name of the "dog" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get activityIconDog;

  /// Screen-reader name of the "baby" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Baby'**
  String get activityIconBaby;

  /// Screen-reader name of the "house" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get activityIconHouse;

  /// Screen-reader name of the "broom" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get activityIconBroom;

  /// Screen-reader name of the "wrench" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Repairs'**
  String get activityIconWrench;

  /// Screen-reader name of the "shopping-cart" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get activityIconShoppingCart;

  /// Screen-reader name of the "wallet" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get activityIconWallet;

  /// Screen-reader name of the "envelope" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get activityIconEnvelope;

  /// Screen-reader name of the "phone" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Phone call'**
  String get activityIconPhone;

  /// Screen-reader name of the "chat-circle" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get activityIconChatCircle;

  /// Screen-reader name of the "laptop" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Computer'**
  String get activityIconLaptop;

  /// Screen-reader name of the "presentation-chart" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Presentation'**
  String get activityIconPresentationChart;

  /// Screen-reader name of the "notebook" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Notebook'**
  String get activityIconNotebook;

  /// Screen-reader name of the "target" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get activityIconTarget;

  /// Screen-reader name of the "lightbulb" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Idea'**
  String get activityIconLightbulb;

  /// Screen-reader name of the "timer" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get activityIconTimer;

  /// Screen-reader name of the "mountains" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Hiking'**
  String get activityIconMountains;

  /// Screen-reader name of the "basketball" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Basketball'**
  String get activityIconBasketball;

  /// Screen-reader name of the "soccer-ball" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Football'**
  String get activityIconSoccerBall;

  /// Screen-reader name of the "tennis-ball" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Tennis'**
  String get activityIconTennisBall;

  /// Screen-reader name of the "yin-yang" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get activityIconYinYang;

  /// Screen-reader name of the "globe" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get activityIconGlobe;

  /// Screen-reader name of the "airplane" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Flight'**
  String get activityIconAirplane;

  /// Screen-reader name of the "car" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Driving'**
  String get activityIconCar;

  /// Screen-reader name of the "sparkle" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Sparkle'**
  String get activityIconSparkle;

  /// Screen-reader name of the "star" activity icon.
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get activityIconStar;

  /// Screen-reader name of an activity color.
  ///
  /// In en, this message translates to:
  /// **'Sky'**
  String get activityColorSky;

  /// Screen-reader name of an activity color.
  ///
  /// In en, this message translates to:
  /// **'Lilac'**
  String get activityColorLilac;

  /// Screen-reader name of an activity color.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get activityColorRose;

  /// Screen-reader name of an activity color.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get activityColorTeal;

  /// Screen-reader name of an activity color.
  ///
  /// In en, this message translates to:
  /// **'Coral'**
  String get activityColorCoral;

  /// Screen-reader name of an activity color.
  ///
  /// In en, this message translates to:
  /// **'Slate'**
  String get activityColorSlate;

  /// Activity builder: shows every icon.
  ///
  /// In en, this message translates to:
  /// **'More icons'**
  String get builderMoreIcons;

  /// Activity builder: shows only the suggested icons.
  ///
  /// In en, this message translates to:
  /// **'Fewer icons'**
  String get builderFewerIcons;

  /// Item screen: heading of the card showing what was logged the previous time.
  ///
  /// In en, this message translates to:
  /// **'Last time · {date}'**
  String itemLastTime(String date);

  /// Item screen: copies what was logged last time into this item, ready to adjust.
  ///
  /// In en, this message translates to:
  /// **'Use last time'**
  String get itemUseLastTime;

  /// Under a list row: what was logged for a row with this name last time (e.g. "Last time: Bench press 60 kg × 8 (×2)").
  ///
  /// In en, this message translates to:
  /// **'Last time: {summary}'**
  String groupLastTime(String summary);

  /// Fills a list row with what was logged for it last time.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get groupUseLastTime;

  /// Button under a list of number rows (e.g. sets): starts a rest timer.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get restAction;

  /// Rest timer: time left.
  ///
  /// In en, this message translates to:
  /// **'Rest {time}'**
  String restLeft(String time);

  /// Rest timer: the rest has ended.
  ///
  /// In en, this message translates to:
  /// **'Rest over'**
  String get restOver;

  /// Rest timer: take 15 seconds off.
  ///
  /// In en, this message translates to:
  /// **'−15 s'**
  String get restLess;

  /// Rest timer: add 15 seconds.
  ///
  /// In en, this message translates to:
  /// **'+15 s'**
  String get restMore;

  /// Rest timer: stop it.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get restStop;

  /// Add to log sheet: heading of the one-tap choices.
  ///
  /// In en, this message translates to:
  /// **'Quick'**
  String get itemAddQuick;

  /// Add to log sheet: expands every kind of detail (advanced).
  ///
  /// In en, this message translates to:
  /// **'More kinds of detail'**
  String get itemAddMoreKinds;

  /// Quick thing to log: a 1–5 rating, also its default name.
  ///
  /// In en, this message translates to:
  /// **'How it went'**
  String get quickHowItWent;

  /// Description of the quick rating.
  ///
  /// In en, this message translates to:
  /// **'A rating from 1 to 5'**
  String get quickHowItWentDescription;

  /// Quick thing to log: a number you name (pages, km, glasses…).
  ///
  /// In en, this message translates to:
  /// **'An amount'**
  String get quickAmount;

  /// Description of the quick amount.
  ///
  /// In en, this message translates to:
  /// **'A number you name, like pages, km or glasses'**
  String get quickAmountDescription;

  /// Item with nothing to log yet: opens every choice.
  ///
  /// In en, this message translates to:
  /// **'More…'**
  String get itemQuickMore;

  /// Field sheet: expands the less common settings.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get fieldAdvanced;

  /// Plan quick action: copy the item on the same day.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get planDuplicate;

  /// Snackbar after duplicating an item.
  ///
  /// In en, this message translates to:
  /// **'Duplicated'**
  String get planDuplicatedMessage;

  /// Screen-reader hint for long-pressing a day row.
  ///
  /// In en, this message translates to:
  /// **'show quick actions'**
  String get planQuickActionsHint;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get builtInRunning;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get builtInRunningDistance;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get builtInRunningRoute;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'How it felt'**
  String get builtInRunningFelt;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get builtInStudy;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get builtInStudySubject;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'What I covered'**
  String get builtInStudyCovered;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get builtInStudyFocus;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Meditation'**
  String get builtInMeditation;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Kind'**
  String get builtInMeditationKind;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Breathing'**
  String get builtInMeditationBreathing;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Body scan'**
  String get builtInMeditationBodyScan;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Guided'**
  String get builtInMeditationGuided;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Silent'**
  String get builtInMeditationSilent;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Calm afterwards'**
  String get builtInMeditationCalm;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get builtInWater;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Glasses'**
  String get builtInWaterGlasses;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get builtInSleep;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get builtInSleepQuality;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Woke up in the night'**
  String get builtInSleepWokeUp;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get builtInMood;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get builtInMoodRating;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Feelings'**
  String get builtInMoodFeelings;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get builtInMoodCalm;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get builtInMoodHappy;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Energetic'**
  String get builtInMoodEnergetic;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Tired'**
  String get builtInMoodTired;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Stressed'**
  String get builtInMoodStressed;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Anxious'**
  String get builtInMoodAnxious;

  /// Built-in activity preview: uses it (it becomes one of the user's activities).
  ///
  /// In en, this message translates to:
  /// **'Use {name}'**
  String activityPreviewUse(String name);

  /// Activity preview: heading above the form preview.
  ///
  /// In en, this message translates to:
  /// **'What you\'ll log'**
  String get activityPreviewYoullLog;

  /// Activity list: a category heading for built-in activities.
  ///
  /// In en, this message translates to:
  /// **'Sleep & self-care'**
  String get builtInCategorySleepAndSelfCare;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Nap'**
  String get builtInNap;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Felt after'**
  String get builtInNapFeltAfter;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Morning routine'**
  String get builtInMorningRoutine;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Woke up at'**
  String get builtInMorningRoutineWokeUpAt;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get builtInMorningRoutineSteps;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get builtInMorningRoutineStepsItem;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get builtInMorningRoutineStepsStep;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get builtInMorningRoutineStepsDone;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get builtInMorningRoutineEnergy;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Evening routine'**
  String get builtInEveningRoutine;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Lights out at'**
  String get builtInEveningRoutineLightsOutAt;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get builtInEveningRoutineSteps;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get builtInEveningRoutineStepsItem;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get builtInEveningRoutineStepsStep;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get builtInEveningRoutineStepsDone;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Screens off an hour before'**
  String get builtInEveningRoutineScreensOffAnHourBefore;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Shower'**
  String get builtInShower;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Kind'**
  String get builtInShowerKind;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Shower'**
  String get builtInShowerKindShower;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Bath'**
  String get builtInShowerKindBath;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Cold shower'**
  String get builtInShowerKindColdShower;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Felt after'**
  String get builtInShowerFeltAfter;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Skincare'**
  String get builtInSkincare;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get builtInSkincareProducts;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Cleanser'**
  String get builtInSkincareProductsCleanser;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Toner'**
  String get builtInSkincareProductsToner;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Serum'**
  String get builtInSkincareProductsSerum;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Moisturizer'**
  String get builtInSkincareProductsMoisturizer;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Sunscreen'**
  String get builtInSkincareProductsSunscreen;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Mask'**
  String get builtInSkincareProductsMask;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Skin today'**
  String get builtInSkincareSkinToday;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Oral care'**
  String get builtInOralCare;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Brushed'**
  String get builtInOralCareBrushed;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Flossed'**
  String get builtInOralCareFlossed;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Mouthwash'**
  String get builtInOralCareMouthwash;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Grooming'**
  String get builtInGrooming;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'What'**
  String get builtInGroomingWhat;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Haircut'**
  String get builtInGroomingWhatHaircut;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Shave'**
  String get builtInGroomingWhatShave;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Beard trim'**
  String get builtInGroomingWhatBeardTrim;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Nails'**
  String get builtInGroomingWhatNails;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Hair wash'**
  String get builtInGroomingWhatHairWash;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get builtInGroomingCost;

  /// Activity list: a category heading for built-in activities.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get builtInCategoryHealth;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get builtInMedication;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get builtInMedicationMedicine;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Dose'**
  String get builtInMedicationDose;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get builtInMedicationTaken;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Side effects'**
  String get builtInMedicationSideEffects;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Vitamins & supplements'**
  String get builtInVitaminsAndSupplements;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Supplements'**
  String get builtInVitaminsAndSupplementsSupplements;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Supplement'**
  String get builtInVitaminsAndSupplementsSupplementsItem;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Supplement'**
  String get builtInVitaminsAndSupplementsSupplementsSupplement;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get builtInVitaminsAndSupplementsSupplementsTaken;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Doctor visit'**
  String get builtInDoctorVisit;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Doctor or clinic'**
  String get builtInDoctorVisitDoctorOrClinic;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get builtInDoctorVisitReason;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'What they said'**
  String get builtInDoctorVisitWhatTheySaid;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Next visit'**
  String get builtInDoctorVisitNextVisit;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get builtInSymptoms;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get builtInSymptomsSymptoms;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Headache'**
  String get builtInSymptomsSymptomsHeadache;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Fever'**
  String get builtInSymptomsSymptomsFever;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Cough'**
  String get builtInSymptomsSymptomsCough;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Sore throat'**
  String get builtInSymptomsSymptomsSoreThroat;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get builtInSymptomsSymptomsFatigue;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Nausea'**
  String get builtInSymptomsSymptomsNausea;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Pain'**
  String get builtInSymptomsSymptomsPain;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get builtInSymptomsSeverity;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get builtInSymptomsNotes;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Blood pressure'**
  String get builtInBloodPressure;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Systolic'**
  String get builtInBloodPressureSystolic;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Diastolic'**
  String get builtInBloodPressureDiastolic;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Pulse'**
  String get builtInBloodPressurePulse;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Blood sugar'**
  String get builtInBloodSugar;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get builtInBloodSugarReading;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get builtInBloodSugarWhen;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Fasting'**
  String get builtInBloodSugarWhenFasting;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Before a meal'**
  String get builtInBloodSugarWhenBeforeAMeal;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'After a meal'**
  String get builtInBloodSugarWhenAfterAMeal;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Bedtime'**
  String get builtInBloodSugarWhenBedtime;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Body temperature'**
  String get builtInBodyTemperature;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get builtInBodyTemperatureTemperature;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get builtInPeriod;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Flow'**
  String get builtInPeriodFlow;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Spotting'**
  String get builtInPeriodFlowSpotting;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get builtInPeriodFlowLight;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get builtInPeriodFlowMedium;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get builtInPeriodFlowHeavy;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get builtInPeriodSymptoms;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Cramps'**
  String get builtInPeriodSymptomsCramps;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Bloating'**
  String get builtInPeriodSymptomsBloating;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Headache'**
  String get builtInPeriodSymptomsHeadache;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Mood swings'**
  String get builtInPeriodSymptomsMoodSwings;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get builtInPeriodSymptomsFatigue;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Cravings'**
  String get builtInPeriodSymptomsCravings;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get builtInPeriodNotes;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Physiotherapy'**
  String get builtInPhysiotherapy;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get builtInPhysiotherapyExercises;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get builtInPhysiotherapyExercisesItem;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get builtInPhysiotherapyExercisesExercise;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get builtInPhysiotherapyExercisesDone;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Pain level'**
  String get builtInPhysiotherapyPainLevel;

  /// Activity list: a category heading for built-in activities.
  ///
  /// In en, this message translates to:
  /// **'Food & drink'**
  String get builtInCategoryFoodAndDrink;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get builtInMeal;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get builtInMealMeal;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get builtInMealMealBreakfast;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get builtInMealMealLunch;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get builtInMealMealDinner;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get builtInMealMealSnack;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'What I ate'**
  String get builtInMealWhatIAte;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get builtInMealCalories;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'How healthy'**
  String get builtInMealHowHealthy;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Ate out'**
  String get builtInMealAteOut;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Coffee & tea'**
  String get builtInCoffeeAndTea;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Drink'**
  String get builtInCoffeeAndTeaDrink;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get builtInCoffeeAndTeaDrinkCoffee;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Espresso'**
  String get builtInCoffeeAndTeaDrinkEspresso;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Tea'**
  String get builtInCoffeeAndTeaDrinkTea;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Green tea'**
  String get builtInCoffeeAndTeaDrinkGreenTea;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Herbal tea'**
  String get builtInCoffeeAndTeaDrinkHerbalTea;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Cups'**
  String get builtInCoffeeAndTeaCups;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Fasting'**
  String get builtInFasting;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get builtInFastingPlan;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'12:12'**
  String get builtInFastingPlan1212;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'16:8'**
  String get builtInFastingPlan168;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'18:6'**
  String get builtInFastingPlan186;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'20:4'**
  String get builtInFastingPlan204;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'24 hours'**
  String get builtInFastingPlan24Hours;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Broke the fast at'**
  String get builtInFastingBrokeTheFastAt;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'How it felt'**
  String get builtInFastingHowItFelt;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Alcohol'**
  String get builtInAlcohol;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Drinks'**
  String get builtInAlcoholDrinks;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Kind'**
  String get builtInAlcoholKind;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Beer'**
  String get builtInAlcoholKindBeer;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Wine'**
  String get builtInAlcoholKindWine;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Spirits'**
  String get builtInAlcoholKindSpirits;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Cocktail'**
  String get builtInAlcoholKindCocktail;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Cider'**
  String get builtInAlcoholKindCider;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Meal prep'**
  String get builtInMealPrep;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Dishes'**
  String get builtInMealPrepDishes;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Dish'**
  String get builtInMealPrepDishesItem;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Dish'**
  String get builtInMealPrepDishesDish;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Portions'**
  String get builtInMealPrepDishesPortions;

  /// Activity list: a category heading for built-in activities.
  ///
  /// In en, this message translates to:
  /// **'Home & chores'**
  String get builtInCategoryHomeAndChores;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get builtInCleaning;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get builtInCleaningRooms;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get builtInCleaningRoomsKitchen;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Bathroom'**
  String get builtInCleaningRoomsBathroom;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Bedroom'**
  String get builtInCleaningRoomsBedroom;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Living room'**
  String get builtInCleaningRoomsLivingRoom;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Whole home'**
  String get builtInCleaningRoomsWholeHome;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get builtInCleaningTasks;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get builtInCleaningTasksItem;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get builtInCleaningTasksTask;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get builtInCleaningTasksDone;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Laundry'**
  String get builtInLaundry;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Loads'**
  String get builtInLaundryLoads;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get builtInLaundrySteps;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Washed'**
  String get builtInLaundryStepsWashed;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Dried'**
  String get builtInLaundryStepsDried;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Folded'**
  String get builtInLaundryStepsFolded;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Ironed'**
  String get builtInLaundryStepsIroned;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Put away'**
  String get builtInLaundryStepsPutAway;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Dishes'**
  String get builtInDishes;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'How'**
  String get builtInDishesHow;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'By hand'**
  String get builtInDishesHowByHand;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Dishwasher'**
  String get builtInDishesHowDishwasher;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Kitchen wiped'**
  String get builtInDishesKitchenWiped;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get builtInGroceries;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get builtInGroceriesStore;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Shopping list'**
  String get builtInGroceriesShoppingList;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get builtInGroceriesShoppingListItem;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get builtInGroceriesShoppingListGotIt;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get builtInGroceriesSpent;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Gardening'**
  String get builtInGardening;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get builtInGardeningTasks;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Watering'**
  String get builtInGardeningTasksWatering;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Planting'**
  String get builtInGardeningTasksPlanting;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Weeding'**
  String get builtInGardeningTasksWeeding;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Pruning'**
  String get builtInGardeningTasksPruning;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Mowing'**
  String get builtInGardeningTasksMowing;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Harvesting'**
  String get builtInGardeningTasksHarvesting;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Plants'**
  String get builtInGardeningPlants;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Plant care'**
  String get builtInPlantCare;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Plants'**
  String get builtInPlantCarePlants;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Plant'**
  String get builtInPlantCarePlantsItem;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Plant'**
  String get builtInPlantCarePlantsPlant;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Watered'**
  String get builtInPlantCarePlantsWatered;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Fed'**
  String get builtInPlantCarePlantsFed;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Home repair'**
  String get builtInHomeRepair;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get builtInHomeRepairProject;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'What was done'**
  String get builtInHomeRepairWhatWasDone;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get builtInHomeRepairCost;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Declutter'**
  String get builtInDeclutter;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get builtInDeclutterArea;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Items removed'**
  String get builtInDeclutterItemsRemoved;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Where they went'**
  String get builtInDeclutterWhereTheyWent;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Donated'**
  String get builtInDeclutterWhereTheyWentDonated;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get builtInDeclutterWhereTheyWentSold;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Recycled'**
  String get builtInDeclutterWhereTheyWentRecycled;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Thrown away'**
  String get builtInDeclutterWhereTheyWentThrownAway;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get builtInBills;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get builtInBillsBills;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Bill'**
  String get builtInBillsBillsItem;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Bill'**
  String get builtInBillsBillsBill;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get builtInBillsBillsAmount;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get builtInBillsBillsPaid;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get builtInExpense;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get builtInExpenseAmount;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get builtInExpenseCategory;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get builtInExpenseCategoryFood;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get builtInExpenseCategoryTransport;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get builtInExpenseCategoryHome;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get builtInExpenseCategoryHealth;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Fun'**
  String get builtInExpenseCategoryFun;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get builtInExpenseCategoryShopping;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get builtInExpenseCategoryBills;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get builtInExpenseCategoryOther;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'What for'**
  String get builtInExpenseWhatFor;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Budget review'**
  String get builtInBudgetReview;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Spent this week'**
  String get builtInBudgetReviewSpentThisWeek;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get builtInBudgetReviewSaved;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'On track'**
  String get builtInBudgetReviewOnTrack;

  /// Activity list: a category heading for built-in activities.
  ///
  /// In en, this message translates to:
  /// **'Family & care'**
  String get builtInCategoryFamilyAndCare;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Childcare'**
  String get builtInChildcare;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get builtInChildcareChild;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'What we did'**
  String get builtInChildcareWhatWeDid;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get builtInChildcareWhatWeDidMeals;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'School run'**
  String get builtInChildcareWhatWeDidSchoolRun;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Homework'**
  String get builtInChildcareWhatWeDidHomework;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Playtime'**
  String get builtInChildcareWhatWeDidPlaytime;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Bath'**
  String get builtInChildcareWhatWeDidBath;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Bedtime'**
  String get builtInChildcareWhatWeDidBedtime;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get builtInChildcareNotes;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Baby feeding'**
  String get builtInBabyFeeding;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Kind'**
  String get builtInBabyFeedingKind;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Breast (left)'**
  String get builtInBabyFeedingKindBreastLeft;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Breast (right)'**
  String get builtInBabyFeedingKindBreastRight;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Bottle'**
  String get builtInBabyFeedingKindBottle;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Solids'**
  String get builtInBabyFeedingKindSolids;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get builtInBabyFeedingAmount;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get builtInBabyFeedingNotes;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Diaper change'**
  String get builtInDiaperChange;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Kind'**
  String get builtInDiaperChangeKind;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Wet'**
  String get builtInDiaperChangeKindWet;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Dirty'**
  String get builtInDiaperChangeKindDirty;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get builtInDiaperChangeKindBoth;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Pet care'**
  String get builtInPetCare;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Pet'**
  String get builtInPetCarePet;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Care'**
  String get builtInPetCareCare;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Fed'**
  String get builtInPetCareCareFed;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Walked'**
  String get builtInPetCareCareWalked;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Groomed'**
  String get builtInPetCareCareGroomed;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Played'**
  String get builtInPetCareCarePlayed;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get builtInPetCareCareMedicine;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Vet visit'**
  String get builtInPetCareCareVetVisit;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get builtInPetCareNotes;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Dog walk'**
  String get builtInDogWalk;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Dog'**
  String get builtInDogWalkDog;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get builtInDogWalkDistance;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Family time'**
  String get builtInFamilyTime;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Who'**
  String get builtInFamilyTimeWho;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'What we did'**
  String get builtInFamilyTimeWhatWeDid;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'How it felt'**
  String get builtInFamilyTimeHowItFelt;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Caring for someone'**
  String get builtInCaringForSomeone;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Who'**
  String get builtInCaringForSomeoneWho;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Help given'**
  String get builtInCaringForSomeoneHelpGiven;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get builtInCaringForSomeoneHelpGivenCompany;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get builtInCaringForSomeoneHelpGivenMeals;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Errands'**
  String get builtInCaringForSomeoneHelpGivenErrands;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get builtInCaringForSomeoneHelpGivenMedicine;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get builtInCaringForSomeoneHelpGivenAppointments;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get builtInCaringForSomeoneNotes;

  /// Activity list: a category heading for built-in activities.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get builtInCategoryWork;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Daily planning'**
  String get builtInDailyPlanning;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Top priorities'**
  String get builtInDailyPlanningTopPriorities;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get builtInDailyPlanningTopPrioritiesItem;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get builtInDailyPlanningTopPrioritiesPriority;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get builtInDailyPlanningTopPrioritiesDone;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get builtInDailyPlanningNotes;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Commute'**
  String get builtInCommute;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'How'**
  String get builtInCommuteHow;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get builtInCommuteHowCar;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get builtInCommuteHowBus;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get builtInCommuteHowTrain;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Bike'**
  String get builtInCommuteHowBike;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get builtInCommuteHowWalk;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get builtInCommuteHowOther;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get builtInCommuteDistance;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'How it went'**
  String get builtInCommuteHowItWent;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Email & admin'**
  String get builtInEmailAndAdmin;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Emails handled'**
  String get builtInEmailAndAdminEmailsHandled;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Inbox zero'**
  String get builtInEmailAndAdminInboxZero;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Coding'**
  String get builtInCoding;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get builtInCodingProject;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'What I built'**
  String get builtInCodingWhatIBuilt;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Commits'**
  String get builtInCodingCommits;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Side project'**
  String get builtInSideProject;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get builtInSideProjectProject;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get builtInSideProjectProgress;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Momentum'**
  String get builtInSideProjectMomentum;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Job search'**
  String get builtInJobSearch;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get builtInJobSearchCompany;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get builtInJobSearchRole;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Stage'**
  String get builtInJobSearchStage;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get builtInJobSearchStageApplied;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Interview'**
  String get builtInJobSearchStageInterview;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Offer'**
  String get builtInJobSearchStageOffer;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get builtInJobSearchStageRejected;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Following up'**
  String get builtInJobSearchStageFollowingUp;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get builtInJobSearchNotes;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Presentation'**
  String get builtInPresentation;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get builtInPresentationTopic;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Audience'**
  String get builtInPresentationAudience;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'How it went'**
  String get builtInPresentationHowItWent;

  /// Activity list: a category heading for built-in activities.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get builtInCategoryLearning;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get builtInClass;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Course'**
  String get builtInClassCourse;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get builtInClassTopic;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get builtInClassNotes;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get builtInClassUnderstood;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Homework'**
  String get builtInHomework;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get builtInHomeworkSubject;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get builtInHomeworkTask;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get builtInHomeworkFinished;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Online course'**
  String get builtInOnlineCourse;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Course'**
  String get builtInOnlineCourseCourse;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Lessons done'**
  String get builtInOnlineCourseLessonsDone;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Takeaways'**
  String get builtInOnlineCourseTakeaways;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Music practice'**
  String get builtInMusicPractice;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Instrument'**
  String get builtInMusicPracticeInstrument;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Guitar'**
  String get builtInMusicPracticeInstrumentGuitar;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Piano'**
  String get builtInMusicPracticeInstrumentPiano;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Drums'**
  String get builtInMusicPracticeInstrumentDrums;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Violin'**
  String get builtInMusicPracticeInstrumentViolin;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get builtInMusicPracticeInstrumentVoice;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get builtInMusicPracticeInstrumentOther;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Pieces'**
  String get builtInMusicPracticePieces;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Piece'**
  String get builtInMusicPracticePiecesItem;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Piece'**
  String get builtInMusicPracticePiecesPiece;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Tempo (bpm)'**
  String get builtInMusicPracticePiecesTempoBpm;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'How it went'**
  String get builtInMusicPracticeHowItWent;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Skill practice'**
  String get builtInSkillPractice;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Skill'**
  String get builtInSkillPracticeSkill;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'What I practised'**
  String get builtInSkillPracticeWhatIPractised;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get builtInSkillPracticeProgress;

  /// Activity list: a category heading for built-in activities.
  ///
  /// In en, this message translates to:
  /// **'Exercise & sport'**
  String get builtInCategoryExerciseAndSport;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get builtInCycling;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get builtInCyclingDistance;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get builtInCyclingRoute;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Felt'**
  String get builtInCyclingFelt;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Swimming'**
  String get builtInSwimming;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get builtInSwimmingDistance;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Laps'**
  String get builtInSwimmingLaps;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Strokes'**
  String get builtInSwimmingStrokes;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Freestyle'**
  String get builtInSwimmingStrokesFreestyle;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Breaststroke'**
  String get builtInSwimmingStrokesBreaststroke;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Backstroke'**
  String get builtInSwimmingStrokesBackstroke;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Butterfly'**
  String get builtInSwimmingStrokesButterfly;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get builtInYoga;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get builtInYogaStyle;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Hatha'**
  String get builtInYogaStyleHatha;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Vinyasa'**
  String get builtInYogaStyleVinyasa;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Yin'**
  String get builtInYogaStyleYin;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get builtInYogaStylePower;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Restorative'**
  String get builtInYogaStyleRestorative;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Felt after'**
  String get builtInYogaFeltAfter;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Stretching'**
  String get builtInStretching;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Areas'**
  String get builtInStretchingAreas;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Neck'**
  String get builtInStretchingAreasNeck;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get builtInStretchingAreasShoulders;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get builtInStretchingAreasBack;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Hips'**
  String get builtInStretchingAreasHips;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get builtInStretchingAreasLegs;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Full body'**
  String get builtInStretchingAreasFullBody;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Home workout'**
  String get builtInHomeWorkout;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get builtInHomeWorkoutExercises;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get builtInHomeWorkoutExercisesItem;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get builtInHomeWorkoutExercisesExercise;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get builtInHomeWorkoutExercisesReps;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get builtInHomeWorkoutExercisesRounds;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Effort'**
  String get builtInHomeWorkoutEffort;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Hiking'**
  String get builtInHiking;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Trail'**
  String get builtInHikingTrail;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get builtInHikingDistance;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Elevation gain'**
  String get builtInHikingElevationGain;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Felt'**
  String get builtInHikingFelt;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Team sport'**
  String get builtInTeamSport;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get builtInTeamSportSport;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Football'**
  String get builtInTeamSportSportFootball;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Basketball'**
  String get builtInTeamSportSportBasketball;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Cricket'**
  String get builtInTeamSportSportCricket;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Volleyball'**
  String get builtInTeamSportSportVolleyball;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Hockey'**
  String get builtInTeamSportSportHockey;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get builtInTeamSportSportOther;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get builtInTeamSportResult;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get builtInTeamSportResultWon;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get builtInTeamSportResultLost;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get builtInTeamSportResultDraw;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Just played'**
  String get builtInTeamSportResultJustPlayed;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'How I played'**
  String get builtInTeamSportHowIPlayed;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Racket sport'**
  String get builtInRacketSport;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get builtInRacketSportSport;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Tennis'**
  String get builtInRacketSportSportTennis;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Badminton'**
  String get builtInRacketSportSportBadminton;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Squash'**
  String get builtInRacketSportSportSquash;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Table tennis'**
  String get builtInRacketSportSportTableTennis;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Padel'**
  String get builtInRacketSportSportPadel;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Opponent'**
  String get builtInRacketSportOpponent;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get builtInRacketSportResult;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get builtInRacketSportResultWon;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get builtInRacketSportResultLost;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Just played'**
  String get builtInRacketSportResultJustPlayed;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Dance'**
  String get builtInDance;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get builtInDanceStyle;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Fun'**
  String get builtInDanceFun;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Daily steps'**
  String get builtInDailySteps;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get builtInDailyStepsSteps;

  /// Activity list: a category heading for built-in activities.
  ///
  /// In en, this message translates to:
  /// **'Mind & wellbeing'**
  String get builtInCategoryMindAndWellbeing;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get builtInJournal;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Entry'**
  String get builtInJournalEntry;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'How the day was'**
  String get builtInJournalHowTheDayWas;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Gratitude'**
  String get builtInGratitude;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Grateful for'**
  String get builtInGratitudeGratefulFor;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Thing'**
  String get builtInGratitudeGratefulForItem;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Thing'**
  String get builtInGratitudeGratefulForThing;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Breathing'**
  String get builtInBreathing;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Technique'**
  String get builtInBreathingTechnique;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Box breathing'**
  String get builtInBreathingTechniqueBoxBreathing;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'4-7-8'**
  String get builtInBreathingTechnique478;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Deep belly'**
  String get builtInBreathingTechniqueDeepBelly;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Alternate nostril'**
  String get builtInBreathingTechniqueAlternateNostril;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get builtInBreathingRounds;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Therapy session'**
  String get builtInTherapySession;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'With'**
  String get builtInTherapySessionWith;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Talked about'**
  String get builtInTherapySessionTalkedAbout;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Takeaways'**
  String get builtInTherapySessionTakeaways;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Felt after'**
  String get builtInTherapySessionFeltAfter;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Screen time'**
  String get builtInScreenTime;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get builtInScreenTimeTotal;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Pickups'**
  String get builtInScreenTimePickups;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Most used app'**
  String get builtInScreenTimeMostUsedApp;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Habit to break'**
  String get builtInHabitToBreak;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Habit'**
  String get builtInHabitToBreakHabit;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Kept clear today'**
  String get builtInHabitToBreakKeptClearToday;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Urges'**
  String get builtInHabitToBreakUrges;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get builtInHabitToBreakNotes;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Digital detox'**
  String get builtInDigitalDetox;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Phone away'**
  String get builtInDigitalDetoxPhoneAway;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'How it felt'**
  String get builtInDigitalDetoxHowItFelt;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Affirmations'**
  String get builtInAffirmations;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Today\'s affirmation'**
  String get builtInAffirmationsTodaySAffirmation;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Said out loud'**
  String get builtInAffirmationsSaidOutLoud;

  /// Activity list: a category heading for built-in activities.
  ///
  /// In en, this message translates to:
  /// **'Hobbies & fun'**
  String get builtInCategoryHobbiesAndFun;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'TV & movies'**
  String get builtInTVAndMovies;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get builtInTVAndMoviesTitle;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Kind'**
  String get builtInTVAndMoviesKind;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Movie'**
  String get builtInTVAndMoviesKindMovie;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get builtInTVAndMoviesKindSeries;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Documentary'**
  String get builtInTVAndMoviesKindDocumentary;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get builtInTVAndMoviesKindShow;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Episodes'**
  String get builtInTVAndMoviesEpisodes;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get builtInTVAndMoviesRating;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Gaming'**
  String get builtInGaming;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get builtInGamingGame;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get builtInGamingPlatform;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'PC'**
  String get builtInGamingPlatformPC;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Console'**
  String get builtInGamingPlatformConsole;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get builtInGamingPlatformMobile;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Board game'**
  String get builtInGamingPlatformBoardGame;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get builtInGamingPlatformCards;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Fun'**
  String get builtInGamingFun;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Podcast'**
  String get builtInPodcast;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get builtInPodcastShow;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Episode'**
  String get builtInPodcastEpisode;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Takeaways'**
  String get builtInPodcastTakeaways;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Drawing & painting'**
  String get builtInDrawingAndPainting;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get builtInDrawingAndPaintingMedium;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Pencil'**
  String get builtInDrawingAndPaintingMediumPencil;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Ink'**
  String get builtInDrawingAndPaintingMediumInk;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Watercolor'**
  String get builtInDrawingAndPaintingMediumWatercolor;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Acrylic'**
  String get builtInDrawingAndPaintingMediumAcrylic;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Oil'**
  String get builtInDrawingAndPaintingMediumOil;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Digital'**
  String get builtInDrawingAndPaintingMediumDigital;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Piece'**
  String get builtInDrawingAndPaintingPiece;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Happy with it'**
  String get builtInDrawingAndPaintingHappyWithIt;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Photography'**
  String get builtInPhotography;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get builtInPhotographySubject;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Photos taken'**
  String get builtInPhotographyPhotosTaken;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Keepers'**
  String get builtInPhotographyKeepers;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Writing'**
  String get builtInWriting;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get builtInWritingProject;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get builtInWritingWords;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get builtInWritingNotes;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Crafts'**
  String get builtInCrafts;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Craft'**
  String get builtInCraftsCraft;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Knitting'**
  String get builtInCraftsCraftKnitting;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Crochet'**
  String get builtInCraftsCraftCrochet;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Sewing'**
  String get builtInCraftsCraftSewing;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Woodwork'**
  String get builtInCraftsCraftWoodwork;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Pottery'**
  String get builtInCraftsCraftPottery;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get builtInCraftsCraftOther;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get builtInCraftsProject;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get builtInCraftsProgress;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Puzzles'**
  String get builtInPuzzles;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get builtInPuzzlesGame;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Sudoku'**
  String get builtInPuzzlesGameSudoku;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Crossword'**
  String get builtInPuzzlesGameCrossword;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Chess'**
  String get builtInPuzzlesGameChess;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Jigsaw'**
  String get builtInPuzzlesGameJigsaw;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Word game'**
  String get builtInPuzzlesGameWordGame;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get builtInPuzzlesGameOther;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Solved'**
  String get builtInPuzzlesSolved;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get builtInPuzzlesScore;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Listening to music'**
  String get builtInListeningToMusic;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Artist or album'**
  String get builtInListeningToMusicArtistOrAlbum;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Enjoyed'**
  String get builtInListeningToMusicEnjoyed;

  /// Activity list: a category heading for built-in activities.
  ///
  /// In en, this message translates to:
  /// **'Friends & community'**
  String get builtInCategoryFriendsAndCommunity;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Time with friends'**
  String get builtInTimeWithFriends;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Who'**
  String get builtInTimeWithFriendsWho;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'What we did'**
  String get builtInTimeWithFriendsWhatWeDid;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'How it felt'**
  String get builtInTimeWithFriendsHowItFelt;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Phone call'**
  String get builtInPhoneCall;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Who'**
  String get builtInPhoneCallWho;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Talked about'**
  String get builtInPhoneCallTalkedAbout;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Follow up needed'**
  String get builtInPhoneCallFollowUpNeeded;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Date night'**
  String get builtInDateNight;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get builtInDateNightWhere;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'What we did'**
  String get builtInDateNightWhatWeDid;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get builtInDateNightRating;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get builtInEvent;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get builtInEventEvent;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get builtInEventWhere;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'How it was'**
  String get builtInEventHowItWas;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Volunteering'**
  String get builtInVolunteering;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get builtInVolunteeringOrganization;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'What I did'**
  String get builtInVolunteeringWhatIDid;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'People helped'**
  String get builtInVolunteeringPeopleHelped;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Prayer & worship'**
  String get builtInPrayerAndWorship;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Practice or place'**
  String get builtInPrayerAndWorshipPracticeOrPlace;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Reflection'**
  String get builtInPrayerAndWorshipReflection;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Donation'**
  String get builtInDonation;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Cause'**
  String get builtInDonationCause;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get builtInDonationAmount;

  /// Activity list: a category heading for built-in activities.
  ///
  /// In en, this message translates to:
  /// **'Travel & errands'**
  String get builtInCategoryTravelAndErrands;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Errands'**
  String get builtInErrands;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Errands'**
  String get builtInErrandsErrands;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Errand'**
  String get builtInErrandsErrandsItem;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Errand'**
  String get builtInErrandsErrandsErrand;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get builtInErrandsErrandsDone;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Appointment'**
  String get builtInAppointment;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'With'**
  String get builtInAppointmentWith;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get builtInAppointmentPurpose;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Next appointment'**
  String get builtInAppointmentNextAppointment;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Driving'**
  String get builtInDriving;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get builtInDrivingDistance;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get builtInDrivingFuel;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get builtInDrivingPurpose;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Trip'**
  String get builtInTrip;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get builtInTripDestination;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Travel by'**
  String get builtInTripTravelBy;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Plane'**
  String get builtInTripTravelByPlane;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get builtInTripTravelByTrain;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get builtInTripTravelByCar;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get builtInTripTravelByBus;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Boat'**
  String get builtInTripTravelByBoat;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Highlights'**
  String get builtInTripHighlights;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Packing'**
  String get builtInPacking;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Packing list'**
  String get builtInPackingPackingList;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get builtInPackingPackingListItem;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get builtInPackingPackingListDone;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Ayurvedic morning'**
  String get builtInAyurvedicMorning;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Up before sunrise'**
  String get builtInAyurvedicMorningUpBeforeSunrise;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Practices'**
  String get builtInAyurvedicMorningPractices;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Tongue scraping'**
  String get builtInAyurvedicMorningPracticesTongueScraping;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Oil pulling'**
  String get builtInAyurvedicMorningPracticesOilPulling;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Abhyanga'**
  String get builtInAyurvedicMorningPracticesAbhyanga;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Warm water'**
  String get builtInAyurvedicMorningPracticesWarmWater;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Neti'**
  String get builtInAyurvedicMorningPracticesNeti;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Felt after'**
  String get builtInAyurvedicMorningFeltAfter;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Hair oiling'**
  String get builtInHairOiling;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Oil'**
  String get builtInHairOilingOil;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Left on overnight'**
  String get builtInHairOilingLeftOnOvernight;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Massage & spa'**
  String get builtInMassageAndSpa;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Kind'**
  String get builtInMassageAndSpaKind;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Massage'**
  String get builtInMassageAndSpaKindMassage;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Spa'**
  String get builtInMassageAndSpaKindSpa;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Facial'**
  String get builtInMassageAndSpaKindFacial;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Foot massage'**
  String get builtInMassageAndSpaKindFootMassage;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Self-massage'**
  String get builtInMassageAndSpaKindSelfMassage;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Felt after'**
  String get builtInMassageAndSpaFeltAfter;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get builtInMassageAndSpaCost;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Sauna & cold plunge'**
  String get builtInSaunaAndColdPlunge;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Kind'**
  String get builtInSaunaAndColdPlungeKind;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Sauna'**
  String get builtInSaunaAndColdPlungeKindSauna;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Cold plunge'**
  String get builtInSaunaAndColdPlungeKindColdPlunge;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Steam room'**
  String get builtInSaunaAndColdPlungeKindSteamRoom;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Contrast'**
  String get builtInSaunaAndColdPlungeKindContrast;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get builtInSaunaAndColdPlungeRounds;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get builtInSaunaAndColdPlungeTemperature;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Pain'**
  String get builtInPain;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get builtInPainWhere;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Head'**
  String get builtInPainWhereHead;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Neck'**
  String get builtInPainWhereNeck;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get builtInPainWhereBack;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Joints'**
  String get builtInPainWhereJoints;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Stomach'**
  String get builtInPainWhereStomach;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Muscles'**
  String get builtInPainWhereMuscles;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get builtInPainLevel;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Possible trigger'**
  String get builtInPainPossibleTrigger;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Digestion'**
  String get builtInDigestion;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get builtInDigestionType;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get builtInDigestionTypeHard;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get builtInDigestionTypeNormal;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Soft'**
  String get builtInDigestionTypeSoft;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Loose'**
  String get builtInDigestionTypeLoose;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Bloating'**
  String get builtInDigestionBloating;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get builtInDigestionNotes;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Energy check'**
  String get builtInEnergyCheck;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get builtInEnergyCheckEnergy;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get builtInEnergyCheckFocus;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get builtInProtein;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get builtInProteinProtein;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Fruit & veg'**
  String get builtInFruitAndVeg;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Portions'**
  String get builtInFruitAndVegPortions;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Colours eaten'**
  String get builtInFruitAndVegColoursEaten;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get builtInFruitAndVegColoursEatenGreen;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get builtInFruitAndVegColoursEatenRed;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get builtInFruitAndVegColoursEatenOrange;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get builtInFruitAndVegColoursEatenYellow;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get builtInFruitAndVegColoursEatenPurple;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get builtInFruitAndVegColoursEatenWhite;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Packed lunch'**
  String get builtInPackedLunch;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'For'**
  String get builtInPackedLunchFor;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'What went in'**
  String get builtInPackedLunchWhatWentIn;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Eaten'**
  String get builtInPackedLunchEaten;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'House help'**
  String get builtInHouseHelp;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Who'**
  String get builtInHouseHelpWho;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Came today'**
  String get builtInHouseHelpCameToday;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get builtInHouseHelpTasks;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Sweeping'**
  String get builtInHouseHelpTasksSweeping;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Mopping'**
  String get builtInHouseHelpTasksMopping;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Dishes'**
  String get builtInHouseHelpTasksDishes;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Laundry'**
  String get builtInHouseHelpTasksLaundry;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Cooking'**
  String get builtInHouseHelpTasksCooking;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Dusting'**
  String get builtInHouseHelpTasksDusting;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get builtInHouseHelpPaid;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Car care'**
  String get builtInCarCare;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'What'**
  String get builtInCarCareWhat;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get builtInCarCareWhatFuel;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Wash'**
  String get builtInCarCareWhatWash;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get builtInCarCareWhatService;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Tyres'**
  String get builtInCarCareWhatTyres;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Oil change'**
  String get builtInCarCareWhatOilChange;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Repair'**
  String get builtInCarCareWhatRepair;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Odometer'**
  String get builtInCarCareOdometer;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get builtInCarCareCost;

  /// Activity list: a category heading for built-in activities.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get builtInCategoryMoney;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Investing'**
  String get builtInInvesting;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Fund or asset'**
  String get builtInInvestingFundOrAsset;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Kind'**
  String get builtInInvestingKind;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get builtInInvestingKindBuy;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get builtInInvestingKindSell;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'SIP'**
  String get builtInInvestingKindSIP;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get builtInInvestingKindDeposit;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Dividend'**
  String get builtInInvestingKindDividend;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get builtInInvestingAmount;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get builtInSavings;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get builtInSavingsGoal;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get builtInSavingsAdded;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Total so far'**
  String get builtInSavingsTotalSoFar;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'School run'**
  String get builtInSchoolRun;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get builtInSchoolRunChild;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'How'**
  String get builtInSchoolRunHow;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get builtInSchoolRunHowCar;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get builtInSchoolRunHowWalk;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get builtInSchoolRunHowBus;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Bike'**
  String get builtInSchoolRunHowBike;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get builtInSchoolRunHowAuto;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'School van'**
  String get builtInSchoolRunHowSchoolVan;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'On time'**
  String get builtInSchoolRunOnTime;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Client work'**
  String get builtInClientWork;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get builtInClientWorkClient;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get builtInClientWorkTask;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Billable'**
  String get builtInClientWorkBillable;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get builtInShift;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get builtInShiftShift;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get builtInShiftShiftMorning;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get builtInShiftShiftDay;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get builtInShiftShiftEvening;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get builtInShiftShiftNight;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Split'**
  String get builtInShiftShiftSplit;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Took a break'**
  String get builtInShiftTookABreak;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get builtInShiftEarned;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Gig work'**
  String get builtInGigWork;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get builtInGigWorkPlatform;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Trips or orders'**
  String get builtInGigWorkTripsOrOrders;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get builtInGigWorkEarned;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get builtInGigWorkDistance;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Networking'**
  String get builtInNetworking;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get builtInNetworkingPerson;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Where we met'**
  String get builtInNetworkingWhereWeMet;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Follow up on'**
  String get builtInNetworkingFollowUpOn;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Weekly review'**
  String get builtInWeeklyReview;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get builtInWeeklyReviewWins;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get builtInWeeklyReviewLessons;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get builtInWeeklyReviewNextWeek;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get builtInWeeklyReviewNextWeekItem;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get builtInWeeklyReviewNextWeekPriority;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get builtInWeeklyReviewNextWeekDone;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Goal check-in'**
  String get builtInGoalCheckIn;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get builtInGoalCheckInGoal;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get builtInGoalCheckInProgress;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Next step'**
  String get builtInGoalCheckInNextStep;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Tuition'**
  String get builtInTuition;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get builtInTuitionSubject;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get builtInTuitionTopic;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Test score'**
  String get builtInTuitionTestScore;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Exam prep'**
  String get builtInExamPrep;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Exam'**
  String get builtInExamPrepExam;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Topics covered'**
  String get builtInExamPrepTopicsCovered;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Mock test score'**
  String get builtInExamPrepMockTestScore;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get builtInExamPrepConfidence;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get builtInFlashcards;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Deck'**
  String get builtInFlashcardsDeck;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Cards reviewed'**
  String get builtInFlashcardsCardsReviewed;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get builtInFlashcardsCorrect;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Teaching'**
  String get builtInTeaching;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get builtInTeachingTopic;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get builtInTeachingStudents;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'How it went'**
  String get builtInTeachingHowItWent;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Surya namaskar'**
  String get builtInSuryaNamaskar;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get builtInSuryaNamaskarRounds;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Felt after'**
  String get builtInSuryaNamaskarFeltAfter;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Pilates'**
  String get builtInPilates;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Kind'**
  String get builtInPilatesKind;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Mat'**
  String get builtInPilatesKindMat;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Reformer'**
  String get builtInPilatesKindReformer;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Felt after'**
  String get builtInPilatesFeltAfter;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Climbing'**
  String get builtInClimbing;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Kind'**
  String get builtInClimbingKind;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Bouldering'**
  String get builtInClimbingKindBouldering;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Top rope'**
  String get builtInClimbingKindTopRope;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Lead'**
  String get builtInClimbingKindLead;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Outdoor'**
  String get builtInClimbingKindOutdoor;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get builtInClimbingRoutes;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Hardest grade'**
  String get builtInClimbingHardestGrade;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Martial arts'**
  String get builtInMartialArts;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get builtInMartialArtsStyle;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Techniques'**
  String get builtInMartialArtsTechniques;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Sparring rounds'**
  String get builtInMartialArtsSparringRounds;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Golf'**
  String get builtInGolf;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Course'**
  String get builtInGolfCourse;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Holes'**
  String get builtInGolfHoles;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'9'**
  String get builtInGolfHoles9;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'18'**
  String get builtInGolfHoles18;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get builtInGolfScore;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Winter sports'**
  String get builtInWinterSports;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Kind'**
  String get builtInWinterSportsKind;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Skiing'**
  String get builtInWinterSportsKindSkiing;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Snowboarding'**
  String get builtInWinterSportsKindSnowboarding;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Ice skating'**
  String get builtInWinterSportsKindIceSkating;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Sledging'**
  String get builtInWinterSportsKindSledging;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Runs'**
  String get builtInWinterSportsRuns;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get builtInWinterSportsWhere;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Pranayama'**
  String get builtInPranayama;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Technique'**
  String get builtInPranayamaTechnique;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Anulom vilom'**
  String get builtInPranayamaTechniqueAnulomVilom;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Kapalbhati'**
  String get builtInPranayamaTechniqueKapalbhati;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Bhramari'**
  String get builtInPranayamaTechniqueBhramari;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Bhastrika'**
  String get builtInPranayamaTechniqueBhastrika;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Ujjayi'**
  String get builtInPranayamaTechniqueUjjayi;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get builtInPranayamaRounds;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Time outdoors'**
  String get builtInTimeOutdoors;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get builtInTimeOutdoorsWhere;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Morning sunlight'**
  String get builtInTimeOutdoorsMorningSunlight;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Felt after'**
  String get builtInTimeOutdoorsFeltAfter;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Social media'**
  String get builtInSocialMedia;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Apps'**
  String get builtInSocialMediaApps;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get builtInSocialMediaAppsInstagram;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get builtInSocialMediaAppsYouTube;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'TikTok'**
  String get builtInSocialMediaAppsTikTok;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get builtInSocialMediaAppsWhatsApp;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get builtInSocialMediaAppsFacebook;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'X'**
  String get builtInSocialMediaAppsX;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Reddit'**
  String get builtInSocialMediaAppsReddit;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Snapchat'**
  String get builtInSocialMediaAppsSnapchat;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Time spent'**
  String get builtInSocialMediaTimeSpent;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Felt after'**
  String get builtInSocialMediaFeltAfter;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get builtInNews;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get builtInNewsSource;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'What stood out'**
  String get builtInNewsWhatStoodOut;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Kind act'**
  String get builtInKindAct;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'What I did'**
  String get builtInKindActWhatIDid;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'For whom'**
  String get builtInKindActForWhom;

  /// Activity list: a category heading for built-in activities.
  ///
  /// In en, this message translates to:
  /// **'Faith & spirituality'**
  String get builtInCategoryFaithAndSpirituality;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Puja'**
  String get builtInPuja;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Deity or occasion'**
  String get builtInPujaDeityOrOccasion;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Offerings'**
  String get builtInPujaOfferings;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Flowers'**
  String get builtInPujaOfferingsFlowers;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Diya'**
  String get builtInPujaOfferingsDiya;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Incense'**
  String get builtInPujaOfferingsIncense;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Prasad'**
  String get builtInPujaOfferingsPrasad;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Aarti'**
  String get builtInPujaOfferingsAarti;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'With family'**
  String get builtInPujaWithFamily;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Salah'**
  String get builtInSalah;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Prayers'**
  String get builtInSalahPrayers;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get builtInSalahPrayersFajr;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get builtInSalahPrayersDhuhr;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get builtInSalahPrayersAsr;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get builtInSalahPrayersMaghrib;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get builtInSalahPrayersIsha;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'On time'**
  String get builtInSalahOnTime;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'At the mosque'**
  String get builtInSalahAtTheMosque;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Scripture reading'**
  String get builtInScriptureReading;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get builtInScriptureReadingText;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Passage'**
  String get builtInScriptureReadingPassage;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Reflection'**
  String get builtInScriptureReadingReflection;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Chanting'**
  String get builtInChanting;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Mantra'**
  String get builtInChantingMantra;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Malas'**
  String get builtInChantingMalas;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get builtInChantingCount;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Religious fast'**
  String get builtInReligiousFast;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Occasion'**
  String get builtInReligiousFastOccasion;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Kind'**
  String get builtInReligiousFastKind;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Sunrise to sunset'**
  String get builtInReligiousFastKindSunriseToSunset;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Water only'**
  String get builtInReligiousFastKindWaterOnly;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Fruit and milk'**
  String get builtInReligiousFastKindFruitAndMilk;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'One meal'**
  String get builtInReligiousFastKindOneMeal;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'No water'**
  String get builtInReligiousFastKindNoWater;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Broke the fast at'**
  String get builtInReligiousFastBrokeTheFastAt;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Watching sport'**
  String get builtInWatchingSport;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Match'**
  String get builtInWatchingSportMatch;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get builtInWatchingSportTeam;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get builtInWatchingSportResult;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get builtInWatchingSportResultWon;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get builtInWatchingSportResultLost;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get builtInWatchingSportResultDraw;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'No result'**
  String get builtInWatchingSportResultNoResult;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Fishing'**
  String get builtInFishing;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Spot'**
  String get builtInFishingSpot;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Catch'**
  String get builtInFishingCatch;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get builtInFishingCatchItem;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get builtInFishingCatchFish;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get builtInFishingCatchWeight;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Content creation'**
  String get builtInContentCreation;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get builtInContentCreationPlatform;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get builtInContentCreationPlatformYouTube;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get builtInContentCreationPlatformInstagram;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'TikTok'**
  String get builtInContentCreationPlatformTikTok;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Blog'**
  String get builtInContentCreationPlatformBlog;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Podcast'**
  String get builtInContentCreationPlatformPodcast;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get builtInContentCreationPlatformOther;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Piece'**
  String get builtInContentCreationPiece;

  /// Built-in activity content (becomes the user's own editable activity once used).
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get builtInContentCreationViews;

  /// Activity list: heading above the user's own activities (built-in ones follow under their categories).
  ///
  /// In en, this message translates to:
  /// **'Yours'**
  String get activitiesYours;

  /// Field sheet (Advanced): how a number is summed up over a period in Insights (ADR-043).
  ///
  /// In en, this message translates to:
  /// **'In insights, show it as'**
  String get numberSummaryLabel;

  /// Number summary: add the values up (pages, kilometres).
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get numberSummaryTotal;

  /// Number summary: average the values (blood pressure, score).
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get numberSummaryAverage;

  /// Number summary: the most recent value (odometer, balance).
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get numberSummaryLatest;

  /// Field sheet (Advanced): which way is better, for "best" in Insights (ADR-043).
  ///
  /// In en, this message translates to:
  /// **'Better is'**
  String get betterDirectionLabel;

  /// Better direction: higher values are better.
  ///
  /// In en, this message translates to:
  /// **'Higher'**
  String get betterHigher;

  /// Better direction: lower values are better (pace, blood pressure).
  ///
  /// In en, this message translates to:
  /// **'Lower'**
  String get betterLower;

  /// Better direction: no best is shown (money, temperature).
  ///
  /// In en, this message translates to:
  /// **'Neither'**
  String get betterNeither;

  /// Insights: a share in percent (yes/no fields, plans done).
  ///
  /// In en, this message translates to:
  /// **'{value} %'**
  String insightPercent(String value);

  /// Automatic chart: a list number per row, summed up its own way.
  ///
  /// In en, this message translates to:
  /// **'{row} · {field}'**
  String insightAutoRowValue(String row, String field);

  /// Automatic chart: estimated one-repetition maximum (weight × reps lists).
  ///
  /// In en, this message translates to:
  /// **'Estimated 1-rep max'**
  String get insightAutoEstimatedMax;

  /// Automatic chart: estimated one-repetition maximum of one row (e.g. an exercise).
  ///
  /// In en, this message translates to:
  /// **'{row} · estimated 1-rep max'**
  String insightAutoRowEstimatedMax(String row);

  /// Automatic chart: the second number of a weight × reps list added up (e.g. total reps).
  ///
  /// In en, this message translates to:
  /// **'{row} · total {field}'**
  String insightAutoRowTotal(String row, String field);

  /// Automatic chart: the second number of a weight × reps list added up, for a list without row names.
  ///
  /// In en, this message translates to:
  /// **'Total {field}'**
  String insightAutoTotal(String field);

  /// Automatic chart: share of "yes" for a yes/no field.
  ///
  /// In en, this message translates to:
  /// **'{field} · how often yes'**
  String insightAutoYesShare(String field);

  /// Insights: weeks in a row with something done, and the longest run (H4).
  ///
  /// In en, this message translates to:
  /// **'{current, plural, =1{1 week in a row} other{{current} weeks in a row}} · best {longest}'**
  String insightStreak(int current, int longest);

  /// Insights: no current run; the longest one (H4).
  ///
  /// In en, this message translates to:
  /// **'Best run {longest, plural, =1{1 week} other{{longest} weeks}}'**
  String insightStreakEnded(int longest);

  /// Insights: heading above the calendar of days something was done (H1).
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get insightConsistencySection;

  /// Insights calendar caption: days with something done out of the period (H1).
  ///
  /// In en, this message translates to:
  /// **'{days} of {total} days'**
  String insightDaysOfPeriod(int days, int total);

  /// Activity progress: heading above the part of day it is usually done.
  ///
  /// In en, this message translates to:
  /// **'When you do it'**
  String get insightWhenSection;

  /// Part of day: 5:00–12:00.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get insightMorning;

  /// Part of day: 12:00–17:00.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get insightAfternoon;

  /// Part of day: 17:00–22:00.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get insightEvening;

  /// Part of day: 22:00–5:00.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get insightNight;

  /// Activity progress: shows charts for every list row (e.g. exercise), not just the six most used (C3).
  ///
  /// In en, this message translates to:
  /// **'Show every row'**
  String get insightShowAllRows;

  /// Automatic breakdown subtitle for a choice field (B3).
  ///
  /// In en, this message translates to:
  /// **'How often each'**
  String get insightChoiceTimes;

  /// Insights home: heading of the period summary (H5).
  ///
  /// In en, this message translates to:
  /// **'At a glance'**
  String get insightSummarySection;

  /// Insights summary tile: days with something done.
  ///
  /// In en, this message translates to:
  /// **'Days active'**
  String get insightDaysActive;

  /// Insights summary tile: recorded time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get insightTimeRecorded;

  /// Insights summary tile: records done.
  ///
  /// In en, this message translates to:
  /// **'Things done'**
  String get insightThingsDone;

  /// Insights home: stacked bars of recorded time per activity (H2).
  ///
  /// In en, this message translates to:
  /// **'Where your time went'**
  String get insightTimeByActivitySection;

  /// Insights home: share of planned items done (H3).
  ///
  /// In en, this message translates to:
  /// **'Plan vs reality'**
  String get insightPlanSection;

  /// Insights home: plan vs reality headline.
  ///
  /// In en, this message translates to:
  /// **'{done} of {planned} planned items done'**
  String insightPlanDone(int done, int planned);

  /// Insights home: plan vs reality with no plans.
  ///
  /// In en, this message translates to:
  /// **'Nothing was planned in this period.'**
  String get insightPlanEmpty;

  /// Insights home: heading above activities with history but nothing in the period (B6).
  ///
  /// In en, this message translates to:
  /// **'Not done this period'**
  String get insightNotThisPeriod;

  /// Where your time went legend: activities beyond the ones named.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String insightActivityLegendMore(int count);

  /// Insights: a change of a share in percentage points (plan vs reality).
  ///
  /// In en, this message translates to:
  /// **'{change} pts'**
  String insightPoints(String change);

  /// Validation: a challenge lasts 1 to 1000 days.
  ///
  /// In en, this message translates to:
  /// **'Choose between 1 and 1000 days.'**
  String get validationInvalidChallengeTarget;

  /// Validation: a challenge's first day can't be after today.
  ///
  /// In en, this message translates to:
  /// **'A challenge can\'t start in the future.'**
  String get validationChallengeStartInFuture;

  /// Title of the challenges list under Me and the section on Today (ADR-044).
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get challengesTitle;

  /// Challenges screen subtitle.
  ///
  /// In en, this message translates to:
  /// **'Do an activity every day and keep your streak going.'**
  String get challengesSubtitle;

  /// Challenges empty state title.
  ///
  /// In en, this message translates to:
  /// **'No challenges yet'**
  String get challengesEmptyTitle;

  /// Challenges empty state message.
  ///
  /// In en, this message translates to:
  /// **'Pick an activity and a number of days, like 75 days of Meditation. Recording it each day keeps your streak going.'**
  String get challengesEmptyMessage;

  /// Button: start a new challenge.
  ///
  /// In en, this message translates to:
  /// **'New challenge'**
  String get newChallenge;

  /// Challenge sheet title when creating.
  ///
  /// In en, this message translates to:
  /// **'New challenge'**
  String get challengeNewTitle;

  /// Challenge sheet title when editing.
  ///
  /// In en, this message translates to:
  /// **'Edit challenge'**
  String get challengeEditTitle;

  /// Challenge sheet: the activity done every day.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get challengeActivityLabel;

  /// Challenge sheet: how a day counts.
  ///
  /// In en, this message translates to:
  /// **'Recording it each day counts the day.'**
  String get challengeActivityHelper;

  /// Challenge sheet: how many successful days complete it.
  ///
  /// In en, this message translates to:
  /// **'Number of days'**
  String get challengeDaysLabel;

  /// Challenge sheet: the rule of a daily challenge.
  ///
  /// In en, this message translates to:
  /// **'Complete the activity once every day.'**
  String get challengeDaysHelper;

  /// Challenge sheet: the first day that counts.
  ///
  /// In en, this message translates to:
  /// **'First day'**
  String get challengeStartLabel;

  /// Challenge sheet: the challenge name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get challengeNameLabel;

  /// Challenge sheet: create button.
  ///
  /// In en, this message translates to:
  /// **'Start challenge'**
  String get challengeStartAction;

  /// Default challenge name, e.g. "75 days of Meditation".
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day of {activity}} other{{days} days of {activity}}}'**
  String challengeAutoTitle(int days, String activity);

  /// Challenge progress: successful days out of the target.
  ///
  /// In en, this message translates to:
  /// **'{done} / {target} days'**
  String challengeProgressDays(int done, int target);

  /// Challenge card: the current streak.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1-day streak} other{{count}-day streak}}'**
  String challengeStreakDays(int count);

  /// Challenge state: today's activity is recorded.
  ///
  /// In en, this message translates to:
  /// **'Done today'**
  String get challengeTodayDone;

  /// Challenge state: a streak is running and today isn't recorded yet.
  ///
  /// In en, this message translates to:
  /// **'Not yet today — streak at risk'**
  String get challengeTodayAtRisk;

  /// Challenge state: nothing recorded today and no streak running.
  ///
  /// In en, this message translates to:
  /// **'Not yet today'**
  String get challengeTodayNotYet;

  /// Challenge state: the target is reached.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get challengeCompleted;

  /// Challenge detail: the day the target was reached.
  ///
  /// In en, this message translates to:
  /// **'Completed {date}'**
  String challengeCompletedOn(String date);

  /// Challenge detail stat.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get challengeCurrentStreak;

  /// Challenge detail stat.
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get challengeBestStreak;

  /// Challenge detail stat: total successful days.
  ///
  /// In en, this message translates to:
  /// **'Days done'**
  String get challengeDaysDone;

  /// Challenge detail stat: days to the target.
  ///
  /// In en, this message translates to:
  /// **'Days left'**
  String get challengeDaysLeft;

  /// Challenge detail: heading above the calendar of days done.
  ///
  /// In en, this message translates to:
  /// **'Your days'**
  String get challengeCalendarSection;

  /// Challenge detail: count again from today.
  ///
  /// In en, this message translates to:
  /// **'Restart from today'**
  String get challengeRestart;

  /// Snackbar after restarting a challenge.
  ///
  /// In en, this message translates to:
  /// **'Counting from today'**
  String get challengeRestarted;

  /// Challenge detail: end it (its records stay).
  ///
  /// In en, this message translates to:
  /// **'End challenge'**
  String get challengeEnd;

  /// Snackbar after ending a challenge.
  ///
  /// In en, this message translates to:
  /// **'Challenge ended'**
  String get challengeEnded;

  /// Challenge detail: the challenge no longer exists.
  ///
  /// In en, this message translates to:
  /// **'This challenge has ended.'**
  String get challengeNotFound;

  /// Challenge detail: the first day that counts.
  ///
  /// In en, this message translates to:
  /// **'Since {date}'**
  String challengeStartsOn(String date);

  /// Tooltip of the challenge screen's menu button.
  ///
  /// In en, this message translates to:
  /// **'Challenge options'**
  String get challengeOptions;

  /// Title of Me → Appearance and its row on Me.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// Intro on the Appearance screen.
  ///
  /// In en, this message translates to:
  /// **'Pick the look you like. It changes the whole app; your days stay the same.'**
  String get appearanceIntro;

  /// Chip on the theme that's currently applied.
  ///
  /// In en, this message translates to:
  /// **'In use'**
  String get appearanceInUse;

  /// Name of the rose theme.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get themeNameRose;

  /// Name of the lavender theme.
  ///
  /// In en, this message translates to:
  /// **'Lavender'**
  String get themeNameLavender;

  /// Name of the papaya theme.
  ///
  /// In en, this message translates to:
  /// **'Papaya'**
  String get themeNamePapaya;

  /// Description of the rose theme.
  ///
  /// In en, this message translates to:
  /// **'Soft blush and rose, with calm teal.'**
  String get themeDescriptionRose;

  /// Description of the lavender theme.
  ///
  /// In en, this message translates to:
  /// **'Porcelain and lavender, with fresh mint.'**
  String get themeDescriptionLavender;

  /// Description of the papaya theme.
  ///
  /// In en, this message translates to:
  /// **'Warm papaya, with aqua mint.'**
  String get themeDescriptionPapaya;

  /// Sample item title in a theme preview.
  ///
  /// In en, this message translates to:
  /// **'Morning walk'**
  String get appearancePreviewTitle;

  /// Sample item time in a theme preview.
  ///
  /// In en, this message translates to:
  /// **'7:30 · 30 min'**
  String get appearancePreviewDetail;

  /// Sample button in a theme preview.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get appearancePreviewAction;

  /// Status chip of an open plan.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get planStatusPlanned;

  /// Today's hero: how many of today's items are done.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String todayProgress(int done, int total);

  /// Small word under the count in Today's ring.
  ///
  /// In en, this message translates to:
  /// **'done'**
  String get todayRingCenter;

  /// How soon the next item starts, e.g. 'in 25 min'.
  ///
  /// In en, this message translates to:
  /// **'in {duration}'**
  String todayUpNextIn(String duration);

  /// Up next card: start recording the item.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get todayUpNextStart;

  /// Label of the time fact on the Up next card.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get todayFactTime;

  /// Label of the planned length fact on the Up next card.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get todayFactLength;

  /// Heading above today's items.
  ///
  /// In en, this message translates to:
  /// **'Your day'**
  String get todayYourDay;

  /// Title of Today's empty state.
  ///
  /// In en, this message translates to:
  /// **'Nothing on today yet'**
  String get todayEmptyTitle;

  /// Chip on an item whose timer is running.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get itemLive;

  /// Label above a running item's timer.
  ///
  /// In en, this message translates to:
  /// **'Time so far'**
  String get itemTimeSoFar;

  /// Card title for an item's notes, time and duration.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get itemDetailsSection;

  /// Chip on the list row being filled in.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get groupRowNow;

  /// Button lowering a number by one step.
  ///
  /// In en, this message translates to:
  /// **'Less {field}'**
  String stepperDecrease(String field);

  /// Button raising a number by one step.
  ///
  /// In en, this message translates to:
  /// **'More {field}'**
  String stepperIncrease(String field);

  /// Screen-reader label of the 🔥 badge.
  ///
  /// In en, this message translates to:
  /// **'{days}-day streak'**
  String streakBadgeLabel(int days);

  /// Sub-line of a thing whose timer runs.
  ///
  /// In en, this message translates to:
  /// **'Running · {time}'**
  String itemRunning(String time);

  /// Snackbar after finishing something.
  ///
  /// In en, this message translates to:
  /// **'{title} done'**
  String itemDoneMessage(String title);

  /// Snackbar after finishing something that keeps a streak.
  ///
  /// In en, this message translates to:
  /// **'{title} done · 🔥 {days}'**
  String itemDoneStreakMessage(String title, int days);

  /// Title of the sheet asking for details after finishing.
  ///
  /// In en, this message translates to:
  /// **'How did it go?'**
  String get howDidItGoTitle;

  /// Save button of How did it go?
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get howDidItGoSave;

  /// Skip button of How did it go?
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get howDidItGoSkip;

  /// Today's status line in the morning.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 thing today} other{{count} things today}} · first at {time}'**
  String todayStatusPlanned(int count, String time);

  /// Today's status line when nothing has a time.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 thing today} other{{count} things today}}'**
  String todayStatusPlannedAnytime(int count);

  /// Today's status line during the day.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String todayStatusProgress(int done, int total);

  /// Today's status line during the day with time recorded.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done · {duration} so far'**
  String todayStatusProgressTime(int done, int total, String duration);

  /// Today's status line while a timer runs.
  ///
  /// In en, this message translates to:
  /// **'{title} running · {done} of {total} done'**
  String todayStatusRunning(String title, int done, int total);

  /// Today's status line when everything is done.
  ///
  /// In en, this message translates to:
  /// **'All {total} done'**
  String todayStatusAllDone(int total);

  /// Today's status line when everything is done, with time.
  ///
  /// In en, this message translates to:
  /// **'All {total} done · {duration}'**
  String todayStatusAllDoneTime(int total, String duration);

  /// Today's status line on an empty day.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned yet'**
  String get todayStatusEmpty;

  /// Label of the Now/Next card while a timer runs.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get nowNextRunning;

  /// Label of the Now/Next card when a thing's time has come.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get nowNextNow;

  /// Label of the Now/Next card for a later thing.
  ///
  /// In en, this message translates to:
  /// **'Next · {time}'**
  String nowNextNext(String time);

  /// Label of the Now/Next card for a thing without a time.
  ///
  /// In en, this message translates to:
  /// **'Anytime'**
  String get nowNextAnytime;

  /// The line on Today's timeline at the current time.
  ///
  /// In en, this message translates to:
  /// **'Now · {time}'**
  String nowLine(String time);

  /// Dialog when starting something while another timer runs.
  ///
  /// In en, this message translates to:
  /// **'Finish {running} and start {next}?'**
  String oneTimerTitle(String running, String next);

  /// Confirm button of the one-timer dialog.
  ///
  /// In en, this message translates to:
  /// **'Finish and start'**
  String get oneTimerConfirm;

  /// Reopen a done thing.
  ///
  /// In en, this message translates to:
  /// **'Not done'**
  String get itemNotDone;

  /// Start another timed session on a done thing.
  ///
  /// In en, this message translates to:
  /// **'Time again'**
  String get itemTimeAgain;

  /// Streak line on a done thing.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day in a row} other{{days} days in a row}}'**
  String itemStreakLine(int days);

  /// Day progress line on a done thing.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done today'**
  String itemDayLine(int done, int total);

  /// Title of the add sheet.
  ///
  /// In en, this message translates to:
  /// **'Add to {day}'**
  String addSheetTitle(String day);

  /// Day name in the add sheet title for today.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get addToday;

  /// Quick action opening a thing's plan sheet.
  ///
  /// In en, this message translates to:
  /// **'Change time and details'**
  String get planEditAction;

  /// Tooltip of Today's + button.
  ///
  /// In en, this message translates to:
  /// **'Add to today'**
  String get todayAdd;

  /// Today, mornings: heading of yesterday's unfinished things (T2, ADR-046).
  ///
  /// In en, this message translates to:
  /// **'From yesterday'**
  String get fromYesterdayTitle;

  /// From yesterday: move this thing to today.
  ///
  /// In en, this message translates to:
  /// **'Do today'**
  String get fromYesterdayDoToday;

  /// From yesterday / evening review: mark this thing skipped, no judgment.
  ///
  /// In en, this message translates to:
  /// **'Let it go'**
  String get fromYesterdayLetGo;

  /// From yesterday: move all of them to today.
  ///
  /// In en, this message translates to:
  /// **'All today'**
  String get fromYesterdayAllToday;

  /// From yesterday: skip all of them.
  ///
  /// In en, this message translates to:
  /// **'Let all go'**
  String get fromYesterdayLetAllGo;

  /// Snackbar after Do today.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Moved to today} other{{count} moved to today}}'**
  String fromYesterdayMoved(int count);

  /// Snackbar after Let it go (the thing is skipped).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Let go} other{{count} let go}}'**
  String letGoMessage(int count);

  /// Evening review headline.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String eveningSummary(int done, int total);

  /// Evening review headline with time recorded today.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done · {duration}'**
  String eveningSummaryTime(int done, int total, String duration);

  /// Evening review headline when everything planned was done.
  ///
  /// In en, this message translates to:
  /// **'All {total} done today'**
  String eveningAllDone(int total);

  /// One streak kept today in the evening review, e.g. 'Meditation 13'.
  ///
  /// In en, this message translates to:
  /// **'{name} {days}'**
  String eveningStreakKept(String name, int days);

  /// Evening review: the streaks kept today, e.g. 'Meditation 13 · Reading 5 kept today'.
  ///
  /// In en, this message translates to:
  /// **'{streaks} kept today'**
  String eveningStreaksKept(String streaks);

  /// Evening review: a running challenge's activity isn't done today.
  ///
  /// In en, this message translates to:
  /// **'{name} streak at risk ({days, plural, =1{1 day} other{{days} days}})'**
  String eveningAtRisk(String name, int days);

  /// Evening review: open the at-risk activity to do it now.
  ///
  /// In en, this message translates to:
  /// **'Do it now'**
  String get eveningDoItNow;

  /// Evening review: heading of today's unfinished things.
  ///
  /// In en, this message translates to:
  /// **'Not done'**
  String get eveningNotDone;

  /// Evening review: move this thing to tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get eveningTomorrow;

  /// Evening review: open Plan on tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Plan tomorrow'**
  String get eveningPlanTomorrow;

  /// Evening review once nothing is left to decide (T8).
  ///
  /// In en, this message translates to:
  /// **'Day closed · {done} of {total} done'**
  String eveningClosed(int done, int total);

  /// Today, first use with no activities (T9).
  ///
  /// In en, this message translates to:
  /// **'Your day is empty.'**
  String get noPlanFirstTitle;

  /// Today, first use (T9).
  ///
  /// In en, this message translates to:
  /// **'Add the first thing you\'re doing today.'**
  String get noPlanFirstMessage;

  /// Today, nothing planned, returning user (T10).
  ///
  /// In en, this message translates to:
  /// **'Nothing planned today.'**
  String get noPlanReturningTitle;

  /// Today, nothing planned: what you usually do on this weekday (T10).
  ///
  /// In en, this message translates to:
  /// **'Your usual {weekday}'**
  String noPlanUsual(String weekday);

  /// Today, first use: common activities that add to today in one tap.
  ///
  /// In en, this message translates to:
  /// **'Or start with one of these'**
  String get noPlanTryOne;

  /// Today, nothing planned: open the add sheet set to Now.
  ///
  /// In en, this message translates to:
  /// **'Start something now'**
  String get noPlanStartNow;

  /// Snackbar after a usual or common activity chip adds it to today.
  ///
  /// In en, this message translates to:
  /// **'{title} added to today'**
  String addedToToday(String title);

  /// Add sheet: the name field (AD1, ADR-046).
  ///
  /// In en, this message translates to:
  /// **'What are you doing?'**
  String get addWhatHint;

  /// Add sheet: label of the time choices.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get addWhen;

  /// Add sheet: start it now (today only).
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get addNow;

  /// Add sheet: choose a time and length.
  ///
  /// In en, this message translates to:
  /// **'Time…'**
  String get addTimeChoose;

  /// Add sheet: make it repeat on chosen weekdays (AD5).
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get addRepeat;

  /// Add sheet: add the thing to the day.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addAction;

  /// Add sheet: with Now chosen, add it and start it.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get addStartAction;

  /// Add sheet: the full list of activities (AD6).
  ///
  /// In en, this message translates to:
  /// **'Browse all activities'**
  String get addBrowseAll;

  /// Add sheet: a new name becomes a new activity (AD3).
  ///
  /// In en, this message translates to:
  /// **'Make “{name}” yours'**
  String addMakeYoursNamed(String name);

  /// Add sheet: under Make it yours; details can be added later.
  ///
  /// In en, this message translates to:
  /// **'New activity · nothing to set up'**
  String get addMakeYoursHint;

  /// Add sheet, first use: common activities instead of Recent.
  ///
  /// In en, this message translates to:
  /// **'Common'**
  String get addCommon;

  /// A skipped thing (A9): put it back as planned.
  ///
  /// In en, this message translates to:
  /// **'Undo skip'**
  String get itemUndoSkip;

  /// Plan, an empty day (P4).
  ///
  /// In en, this message translates to:
  /// **'Nothing planned for {weekday}.'**
  String noPlanDayTitle(String weekday);

  /// Plan, an empty day: open the add sheet (P4).
  ///
  /// In en, this message translates to:
  /// **'Add something'**
  String get noPlanAddSomething;

  /// Snackbar after a usual activity chip adds it to a day other than today.
  ///
  /// In en, this message translates to:
  /// **'{title} added'**
  String addedToDay(String title);

  /// Plan week strip, screen reader label of a past day or today.
  ///
  /// In en, this message translates to:
  /// **'{date}: {done} of {total} done'**
  String weekStripDayDone(String date, int done, int total);

  /// Plan week strip, screen reader label of a future day.
  ///
  /// In en, this message translates to:
  /// **'{date}: {count, plural, =0{nothing planned} =1{1 planned} other{{count} planned}}'**
  String weekStripDayPlanned(String date, int count);

  /// Plan, the selected day's heading, e.g. 'Tomorrow · Friday, Oct 9'.
  ///
  /// In en, this message translates to:
  /// **'{relative} · {date}'**
  String planDayRelative(String relative, String date);

  /// Row options: move to another day (P7).
  ///
  /// In en, this message translates to:
  /// **'Move to…'**
  String get planMoveTo;

  /// Snackbar after Move to….
  ///
  /// In en, this message translates to:
  /// **'Moved to {date}'**
  String planMovedTo(String date);

  /// Plan: the + button, adds to the selected day.
  ///
  /// In en, this message translates to:
  /// **'Add to this day'**
  String get planAddToDay;

  /// Progress sentences: the week period.
  ///
  /// In en, this message translates to:
  /// **'this week'**
  String get progressThisWeek;

  /// Progress sentences: the month period.
  ///
  /// In en, this message translates to:
  /// **'this month'**
  String get progressThisMonth;

  /// Progress sentences: the 3-month period.
  ///
  /// In en, this message translates to:
  /// **'these 3 months'**
  String get progressThisQuarter;

  /// Progress sentences: the year period.
  ///
  /// In en, this message translates to:
  /// **'this year'**
  String get progressThisYear;

  /// Progress comparison: the week before.
  ///
  /// In en, this message translates to:
  /// **'last week'**
  String get progressLastWeek;

  /// Progress comparison: the month before.
  ///
  /// In en, this message translates to:
  /// **'last month'**
  String get progressLastMonth;

  /// Progress comparison: the 3 months before.
  ///
  /// In en, this message translates to:
  /// **'the 3 months before'**
  String get progressLastQuarter;

  /// Progress comparison: the year before.
  ///
  /// In en, this message translates to:
  /// **'last year'**
  String get progressLastYear;

  /// Progress headline (PR1).
  ///
  /// In en, this message translates to:
  /// **'You did {done} of {planned} planned things {period}.'**
  String progressDidPlanned(int done, int planned, String period);

  /// Progress headline with nothing planned (PR4).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing done {period} yet.} =1{You did 1 thing {period}.} other{You did {count} things {period}.}}'**
  String progressDidThings(int count, String period);

  /// Progress headline with nothing planned, with time.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{You did 1 thing {period} · {duration}.} other{You did {count} things {period} · {duration}.}}'**
  String progressDidThingsTime(int count, String period, String duration);

  /// Progress comparison.
  ///
  /// In en, this message translates to:
  /// **'{count} more than {period}'**
  String progressMoreThan(int count, String period);

  /// Progress comparison.
  ///
  /// In en, this message translates to:
  /// **'{count} fewer than {period}'**
  String progressFewerThan(int count, String period);

  /// Progress comparison.
  ///
  /// In en, this message translates to:
  /// **'The same as {period}'**
  String progressSameAs(String period);

  /// Progress: where the time went.
  ///
  /// In en, this message translates to:
  /// **'Most of your time went to {list}.'**
  String progressTimeWent(String list);

  /// One activity in 'where the time went'.
  ///
  /// In en, this message translates to:
  /// **'{name} ({duration})'**
  String progressTimeEntry(String name, String duration);

  /// Progress, fewer than three days with anything done (PR3).
  ///
  /// In en, this message translates to:
  /// **'Progress builds as you go.'**
  String get progressEarlyTitle;

  /// Progress, early (PR3).
  ///
  /// In en, this message translates to:
  /// **'After a few days you\'ll see how your week went here.'**
  String get progressEarlyMessage;

  /// Progress, early: what's true already.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 thing done so far.} other{{count} things done so far.}}'**
  String progressDoneSoFar(int count);

  /// Progress, an activity not done this period: add it to today.
  ///
  /// In en, this message translates to:
  /// **'Plan it'**
  String get progressPlanIt;

  /// Progress: activities with history but nothing this period.
  ///
  /// In en, this message translates to:
  /// **'Not done {period}'**
  String progressNotDoneThisPeriod(String period);

  /// An activity's progress page, first line (PR5).
  ///
  /// In en, this message translates to:
  /// **'{name}: {days, plural, =1{1 day} other{{days} days}} {period}, {count, plural, =1{1 time} other{{count} times}}.'**
  String progressActivitySentence(
    String name,
    int days,
    String period,
    int count,
  );

  /// An activity's progress page with nothing this period (PR5).
  ///
  /// In en, this message translates to:
  /// **'No {name} {period}.'**
  String progressActivityNone(String name, String period);

  /// Challenges: heading of completed challenges (C2).
  ///
  /// In en, this message translates to:
  /// **'Completed ({count})'**
  String challengesCompleted(int count);

  /// A challenge not yet done today: open today's thing for its activity (C3).
  ///
  /// In en, this message translates to:
  /// **'Do it today'**
  String get challengeDoItToday;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
