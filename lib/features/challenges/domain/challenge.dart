import '../../../core/time/local_date.dart';
import '../../activity_types/domain/activity_ids.dart';

/// Stable identity of a challenge (UUIDv7 `public_id`, ADR-017).
extension type const ChallengeId(String value) {}

/// "Complete this activity every day for [targetDays] days" (ADR-044).
///
/// A challenge only points at an Activity Type; recording that activity is
/// what counts a day. Nothing about the days is stored here: progress and
/// streaks are worked out from the activity's logs (see
/// `ChallengeProgress`), so they can't go out of sync.
class Challenge {
  const Challenge({
    required this.id,
    required this.activityTypeId,
    required this.title,
    required this.startDate,
    required this.targetDays,
    required this.createdAt,
    required this.updatedAt,
  });

  static const maxTitleLength = 60;

  /// A daily challenge lasts 1 to this many successful days.
  static const maxTargetDays = 1000;

  final ChallengeId id;
  final ActivityTypeId activityTypeId;
  final String title;

  /// The first day that counts; earlier records don't.
  final LocalDate startDate;

  /// How many successful days complete the challenge.
  final int targetDays;
  final DateTime createdAt;
  final DateTime updatedAt;

  Challenge copyWith({
    String? title,
    LocalDate? startDate,
    int? targetDays,
    DateTime? updatedAt,
  }) => Challenge(
    id: id,
    activityTypeId: activityTypeId,
    title: title ?? this.title,
    startDate: startDate ?? this.startDate,
    targetDays: targetDays ?? this.targetDays,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

/// What the user enters to start a challenge.
class ChallengeDraft {
  const ChallengeDraft({
    required this.activityTypeId,
    required this.title,
    required this.startDate,
    required this.targetDays,
  });

  final ActivityTypeId activityTypeId;
  final String title;
  final LocalDate startDate;
  final int targetDays;
}
