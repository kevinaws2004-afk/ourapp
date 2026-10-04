/// The single application error model (ADR-025).
///
/// Raw database/platform errors are translated into these in the data layer;
/// presentation maps [category] to localized, human-readable copy. [debugContext]
/// is for logs only and must never be shown to users or contain user content.
sealed class AppException implements Exception {
  const AppException({this.debugContext, this.cause});

  /// Developer-facing detail (operation, IDs). Never user content.
  final String? debugContext;

  /// The underlying error, if any. Logged, never displayed.
  final Object? cause;

  AppErrorCategory get category;

  @override
  String toString() => '$runtimeType(${debugContext ?? ''})';
}

enum AppErrorCategory { validation, notFound, storage, migration, unsupported }

/// Input or state violates a domain rule. Carries the individual issues so
/// forms can show them next to the right field.
final class ValidationException extends AppException {
  const ValidationException(this.issues, {super.debugContext, super.cause});

  final List<ValidationIssue> issues;

  @override
  AppErrorCategory get category => AppErrorCategory.validation;
}

/// A referenced entity doesn't exist (or is deleted where that matters).
final class NotFoundException extends AppException {
  const NotFoundException({super.debugContext, super.cause});

  @override
  AppErrorCategory get category => AppErrorCategory.notFound;
}

/// Reading or writing local storage failed.
final class StorageException extends AppException {
  const StorageException({super.debugContext, super.cause});

  @override
  AppErrorCategory get category => AppErrorCategory.storage;
}

/// The database schema couldn't be opened or migrated.
final class MigrationException extends AppException {
  const MigrationException({super.debugContext, super.cause});

  @override
  AppErrorCategory get category => AppErrorCategory.migration;
}

/// The operation isn't supported (e.g. a value format from a newer version).
final class UnsupportedException extends AppException {
  const UnsupportedException({super.debugContext, super.cause});

  @override
  AppErrorCategory get category => AppErrorCategory.unsupported;
}

/// One broken rule. [code] is stable and maps to localized copy; [target] says
/// what it applies to (a field's public ID, or a form key such as `name`).
class ValidationIssue {
  const ValidationIssue(this.code, {this.target});

  final ValidationCode code;
  final String? target;

  @override
  bool operator ==(Object other) =>
      other is ValidationIssue && other.code == code && other.target == target;

  @override
  int get hashCode => Object.hash(code, target);

  @override
  String toString() => 'ValidationIssue($code, $target)';
}

/// Stable validation codes. Each has localized copy in presentation.
enum ValidationCode {
  required,
  nameRequired,
  nameTooLong,
  duplicateFieldName,
  unknownIcon,
  unknownColor,
  textTooLong,
  notANumber,
  belowMinimum,
  aboveMaximum,
  tooManyDecimals,
  unitRequired,
  unitNotAllowed,
  unknownOption,
  unknownField,
  valueTypeMismatch,
  archivedOption,
  duplicateOption,
  optionLabelRequired,
  optionsRequired,
  ratingOutOfRange,
  invalidRatingScale,
  invalidMinMax,
  negativeDuration,
  durationExceedsElapsed,
  endBeforeStart,
  fieldSemanticsLocked,
  fieldTypeNotSupportedYet,
  invalidDate,
  invalidTime,
  subFieldsRequired,
  nestingTooDeep,
  itemLabelRequired,
  plannedDurationConflict,
  activityNotPlannable,
  planActivityLocked,
  onlyTasksCanBeCompleted,
  planRecordMismatch,
  invalidRepeat,
  focusAlreadyActive,
  activityHasNoTimer,
  focusNotActive,
}

/// The result of pure domain validation: empty means valid.
class ValidationResult {
  const ValidationResult(this.issues);

  static const valid = ValidationResult([]);

  final List<ValidationIssue> issues;

  bool get isValid => issues.isEmpty;

  List<ValidationIssue> issuesFor(String target) =>
      issues.where((issue) => issue.target == target).toList();

  ValidationResult merge(ValidationResult other) =>
      ValidationResult([...issues, ...other.issues]);

  /// Throws [ValidationException] when invalid; used by use cases.
  void throwIfInvalid({String? debugContext}) {
    if (!isValid) throw ValidationException(issues, debugContext: debugContext);
  }
}
