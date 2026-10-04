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

  /// Primary navigation tab: graphs and history.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get navInsights;

  /// Primary navigation tab: body measurements, preferences, settings.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get navMe;

  /// Placeholder message on the Track tab until the feature is built.
  ///
  /// In en, this message translates to:
  /// **'The activities you track will appear here.'**
  String get trackPlaceholder;

  /// Placeholder message on the Insights tab until the feature is built.
  ///
  /// In en, this message translates to:
  /// **'Your progress over time will appear here.'**
  String get insightsPlaceholder;

  /// Placeholder message on the Me tab until the feature is built.
  ///
  /// In en, this message translates to:
  /// **'Body measurements and preferences will appear here.'**
  String get mePlaceholder;

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

  /// Button: cancel and close.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

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

  /// Button: create an activity type from a starter template.
  ///
  /// In en, this message translates to:
  /// **'Start from a template'**
  String get fromTemplate;

  /// Number of fields on an activity type.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No extra fields} =1{1 field} other{{count} fields}}'**
  String activityFieldCount(int count);

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
  /// **'Text'**
  String get fieldTypeText;

  /// Field type description for Text.
  ///
  /// In en, this message translates to:
  /// **'Words, a short note or a long description, like what the doctor said'**
  String get fieldTypeTextDescription;

  /// Field type name: Number.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get fieldTypeNumber;

  /// Field type description for Number.
  ///
  /// In en, this message translates to:
  /// **'Counts or amounts, optionally with a unit like kg or km'**
  String get fieldTypeNumberDescription;

  /// Field type name: Yes / No.
  ///
  /// In en, this message translates to:
  /// **'Yes / No'**
  String get fieldTypeBoolean;

  /// Field type description for Yes / No.
  ///
  /// In en, this message translates to:
  /// **'Something that did or didn\'t happen'**
  String get fieldTypeBooleanDescription;

  /// Field type name: Single choice.
  ///
  /// In en, this message translates to:
  /// **'Single choice'**
  String get fieldTypeSingleSelect;

  /// Field type description for Single choice.
  ///
  /// In en, this message translates to:
  /// **'Pick one option from your list'**
  String get fieldTypeSingleSelectDescription;

  /// Field type name: Multiple choice.
  ///
  /// In en, this message translates to:
  /// **'Multiple choice'**
  String get fieldTypeMultiSelect;

  /// Field type description for Multiple choice.
  ///
  /// In en, this message translates to:
  /// **'Pick any options from your list'**
  String get fieldTypeMultiSelectDescription;

  /// Field type name: Date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get fieldTypeDate;

  /// Field type description for Date.
  ///
  /// In en, this message translates to:
  /// **'A calendar date'**
  String get fieldTypeDateDescription;

  /// Field type name: Time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get fieldTypeTime;

  /// Field type description for Time.
  ///
  /// In en, this message translates to:
  /// **'A time of day'**
  String get fieldTypeTimeDescription;

  /// Field type name: Duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get fieldTypeDuration;

  /// Field type description for Duration.
  ///
  /// In en, this message translates to:
  /// **'An amount of time, like rest or practice time'**
  String get fieldTypeDurationDescription;

  /// Field type name: Rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get fieldTypeRating;

  /// Field type description for Rating.
  ///
  /// In en, this message translates to:
  /// **'Stars on a scale you choose'**
  String get fieldTypeRatingDescription;

  /// Field type name: Repeating group.
  ///
  /// In en, this message translates to:
  /// **'List'**
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

  /// Abbreviation for hours in duration inputs.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get hoursShort;

  /// Abbreviation for minutes in duration inputs.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutesShort;

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

  /// Template picker title.
  ///
  /// In en, this message translates to:
  /// **'Start from a template'**
  String get templatesTitle;

  /// Template picker subtitle.
  ///
  /// In en, this message translates to:
  /// **'Templates are just a starting point. You can change everything afterwards.'**
  String get templatesSubtitle;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get templateReading;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get templateReadingBook;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get templateReadingPages;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get templateReadingRating;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Focused work'**
  String get templateFocusedWork;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get templateFocusedWorkProject;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get templateWalking;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get templateWalkingDistance;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get templateWalkingSteps;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get templateWalkingCalories;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get templateWalkingLocation;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Language learning'**
  String get templateLanguage;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get templateLanguageLanguage;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Words learned'**
  String get templateLanguageWords;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get templateLanguageLesson;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get templateLanguageDifficulty;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get templateLanguageSpanish;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get templateLanguageFrench;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get templateLanguageGerman;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get templateLanguageJapanese;

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
  /// **'The reusable activities you plan and record.'**
  String get activitiesSubtitle;

  /// Empty state title on the Activities screen.
  ///
  /// In en, this message translates to:
  /// **'No activities yet'**
  String get activitiesEmptyTitle;

  /// Empty state message on the Activities screen.
  ///
  /// In en, this message translates to:
  /// **'Build an activity that records exactly what matters to you, or start from a template.'**
  String get activitiesEmptyMessage;

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

  /// Tooltip for the calendar button on the Plan tab.
  ///
  /// In en, this message translates to:
  /// **'Choose a date'**
  String get planChooseDate;

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

  /// Section title for a date's plans.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get planPlannedSection;

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

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get templateGym;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get templateGymExercises;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get templateGymExerciseItem;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get templateGymExercise;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get templateGymSets;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get templateGymSetItem;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get templateGymWeight;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get templateGymReps;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Meeting'**
  String get templateMeeting;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get templateMeetingPeople;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get templateMeetingTopics;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Decisions'**
  String get templateMeetingDecisions;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Action items'**
  String get templateMeetingActionItems;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Action item'**
  String get templateMeetingActionItem;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get templateMeetingActionItemText;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get templateMeetingActionItemDone;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Cooking'**
  String get templateCooking;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Recipe'**
  String get templateCookingRecipe;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get templateCookingServings;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get templateCookingCalories;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get templateCookingRating;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get templateCookingIngredients;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Ingredient'**
  String get templateCookingIngredientItem;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Ingredient'**
  String get templateCookingIngredient;

  /// Starter template content (becomes editable user data once added).
  ///
  /// In en, this message translates to:
  /// **'Have it'**
  String get templateCookingHaveIt;

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

  /// Plan tab quick add: button adding the typed plan.
  ///
  /// In en, this message translates to:
  /// **'Add plan'**
  String get planAddAction;

  /// Plan tab quick add: button choosing an optional time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get planAddTime;

  /// Plan tab quick add: hint in the title field.
  ///
  /// In en, this message translates to:
  /// **'Add something to this day'**
  String get planQuickAddHint;

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

  /// Snackbar after completing a task (with Undo).
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get planTaskDoneMessage;

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

  /// Status of an activity plan with a record but no duration.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get planStatusRecorded;

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
  /// **'Record this activity to complete the plan.'**
  String get validationOnlyTasksCanBeCompleted;

  /// Validation message.
  ///
  /// In en, this message translates to:
  /// **'This plan is for a different activity.'**
  String get validationPlanRecordMismatch;

  /// Outcome of a recorded plan without a planned length.
  ///
  /// In en, this message translates to:
  /// **'Done · {duration}'**
  String planRecordedDuration(String duration);

  /// Planned vs actual: actual duration of the planned duration.
  ///
  /// In en, this message translates to:
  /// **'Done · {actual} of {planned}'**
  String planRecordedOfPlanned(String actual, String planned);

  /// A planned time range.
  ///
  /// In en, this message translates to:
  /// **'{start}–{end}'**
  String planTimeRange(String start, String end);

  /// Tooltip of a plan's More button: edit, skip, move, delete.
  ///
  /// In en, this message translates to:
  /// **'Plan options'**
  String get planOptions;

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

  /// Snackbar when quick add installed a starter template matching the typed name.
  ///
  /// In en, this message translates to:
  /// **'Added the {name} activity, so you can record it from the plan'**
  String planActivityAdded(String name);

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

  /// Starter template content (becomes editable user data once added). What a gym session trained, e.g. Chest.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get templateGymFocus;

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

  /// Feedback after finishing a focus session (FR-FO-05).
  ///
  /// In en, this message translates to:
  /// **'{activity} session complete · {duration}'**
  String focusComplete(String activity, String duration);

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
  /// **'Your charts'**
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

  /// All-time best value and its date.
  ///
  /// In en, this message translates to:
  /// **'Personal best {value} · {date}'**
  String insightPersonalBest(String value, String date);

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

  /// Button in an item: done, without logging details.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get itemMarkDone;

  /// Status of an item that has been done or logged.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get itemDone;

  /// Button in an item: time the activity while logging it.
  ///
  /// In en, this message translates to:
  /// **'Start timer'**
  String get itemStartTimer;

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
  /// **'Add what you want to log: a number, a list (like exercises → sets), yes/no, a rating… or just write notes.'**
  String get itemNothingToLogHint;

  /// Shown in an item when a timer runs for a different item.
  ///
  /// In en, this message translates to:
  /// **'Another timer is running'**
  String get itemTimerOtherRunning;

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

  /// Chip in quick add: it's happening now; opens the item to log it.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get planNow;

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

  /// Section of ready-made things to log (sets & reps, checklist).
  ///
  /// In en, this message translates to:
  /// **'Ready-made'**
  String get itemAddReadyMade;

  /// Section of single things to log (number, text, list…).
  ///
  /// In en, this message translates to:
  /// **'Or add one thing'**
  String get itemAddOneThing;

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

  /// Button inside a list in an item: add another detail to each row.
  ///
  /// In en, this message translates to:
  /// **'Add detail'**
  String get addGroupDetail;

  /// Tooltip: rename, reorder or remove what this item logs.
  ///
  /// In en, this message translates to:
  /// **'Edit what\'s logged'**
  String get itemEditFields;
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
