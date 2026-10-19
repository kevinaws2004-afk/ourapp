import 'package:daylog/features/focus/domain/pomodoro.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pomodoro rounds are for focus work: on for study-like activities by
/// default, off for a workout or a walk, and each can be switched.
void main() {
  const settings = FocusSettings(pomodoro: true);

  test('focus work uses rounds by default; a workout does not', () {
    expect(settings.roundsFor('study', 'graduation-cap'), isTrue);
    expect(settings.roundsFor('work', 'laptop'), isTrue);
    expect(settings.roundsFor('gym', 'barbell'), isFalse);
    expect(settings.roundsFor('run', 'person-simple-run'), isFalse);
  });

  test('a choice for one activity wins and is kept in JSON', () {
    final changed = settings
        .withRoundsFor('gym', on: true)
        .withRoundsFor('study', on: false);
    final back = FocusSettings.fromJson(changed.toJson());

    expect(back.roundsFor('gym', 'barbell'), isTrue);
    expect(back.roundsFor('study', 'graduation-cap'), isFalse);
    expect(back.roundsFor('work', 'laptop'), isTrue);
  });
}
