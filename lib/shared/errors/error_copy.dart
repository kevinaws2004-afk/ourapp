import '../../core/errors/app_exception.dart';
import '../../l10n/generated/app_localizations.dart';

/// Maps the application error model (ADR-025) to safe, localized copy. Raw
/// errors and debug context are never shown.
String errorMessage(AppLocalizations l10n, Object error) => switch (error) {
  ValidationException() => l10n.errorValidation,
  NotFoundException() => l10n.errorNotFound,
  StorageException() || MigrationException() => l10n.errorStorage,
  UnsupportedException() => l10n.errorUnsupported,
  _ => l10n.errorGeneric,
};

String validationMessage(AppLocalizations l10n, ValidationCode code) =>
    switch (code) {
      ValidationCode.required => l10n.validationRequired,
      ValidationCode.nameRequired => l10n.validationNameRequired,
      ValidationCode.nameTooLong => l10n.validationNameTooLong,
      ValidationCode.duplicateFieldName => l10n.validationDuplicateFieldName,
      ValidationCode.unknownIcon => l10n.validationUnknownIcon,
      ValidationCode.unknownColor => l10n.validationUnknownColor,
      ValidationCode.textTooLong => l10n.validationTextTooLong,
      ValidationCode.notANumber => l10n.validationNotANumber,
      ValidationCode.belowMinimum => l10n.validationBelowMinimum,
      ValidationCode.aboveMaximum => l10n.validationAboveMaximum,
      ValidationCode.tooManyDecimals => l10n.validationTooManyDecimals,
      ValidationCode.unitRequired => l10n.validationUnitRequired,
      ValidationCode.unitNotAllowed => l10n.validationUnitNotAllowed,
      ValidationCode.unknownOption => l10n.validationUnknownOption,
      ValidationCode.unknownField => l10n.validationUnknownField,
      ValidationCode.valueTypeMismatch => l10n.validationValueTypeMismatch,
      ValidationCode.archivedOption => l10n.validationArchivedOption,
      ValidationCode.duplicateOption => l10n.validationDuplicateOption,
      ValidationCode.optionLabelRequired => l10n.validationOptionLabelRequired,
      ValidationCode.optionsRequired => l10n.validationOptionsRequired,
      ValidationCode.ratingOutOfRange => l10n.validationRatingOutOfRange,
      ValidationCode.invalidRatingScale => l10n.validationInvalidRatingScale,
      ValidationCode.invalidMinMax => l10n.validationInvalidMinMax,
      ValidationCode.negativeDuration => l10n.validationNegativeDuration,
      ValidationCode.durationExceedsElapsed =>
        l10n.validationDurationExceedsElapsed,
      ValidationCode.endBeforeStart => l10n.validationEndBeforeStart,
      ValidationCode.fieldSemanticsLocked =>
        l10n.validationFieldSemanticsLocked,
      ValidationCode.fieldTypeNotSupportedYet =>
        l10n.validationFieldTypeNotSupportedYet,
      ValidationCode.invalidDate => l10n.validationInvalidDate,
      ValidationCode.invalidTime => l10n.validationInvalidTime,
    };

/// The first message for [target] in [issues], if any.
String? firstIssueMessage(
  AppLocalizations l10n,
  List<ValidationIssue> issues,
  String target,
) {
  for (final issue in issues) {
    if (issue.target == target) return validationMessage(l10n, issue.code);
  }
  return null;
}
