import '../../../core/errors/app_exception.dart';
import '../../../core/time/local_date.dart';
import 'challenge.dart';

/// Pure validation of a challenge's fields. Issue targets: `title`,
/// `target`, `start`.
abstract final class ChallengeValidator {
  static ValidationResult validate({
    required String title,
    required int targetDays,
    required LocalDate startDate,
    required LocalDate today,
  }) {
    final issues = <ValidationIssue>[];
    final name = title.trim();
    if (name.isEmpty) {
      issues.add(
        const ValidationIssue(ValidationCode.nameRequired, target: 'title'),
      );
    } else if (name.length > Challenge.maxTitleLength) {
      issues.add(
        const ValidationIssue(ValidationCode.nameTooLong, target: 'title'),
      );
    }
    if (targetDays < 1 || targetDays > Challenge.maxTargetDays) {
      issues.add(
        const ValidationIssue(
          ValidationCode.invalidChallengeTarget,
          target: 'target',
        ),
      );
    }
    if (startDate.compareTo(today) > 0) {
      issues.add(
        const ValidationIssue(
          ValidationCode.challengeStartInFuture,
          target: 'start',
        ),
      );
    }
    return ValidationResult(issues);
  }
}
