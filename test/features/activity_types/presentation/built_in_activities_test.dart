import 'package:daylog/features/activity_types/domain/activity_type_validator.dart';
import 'package:daylog/features/activity_types/presentation/starter_activities.dart';
import 'package:daylog/features/activity_types/presentation/built_in_activities.dart';
import 'package:daylog/l10n/generated/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every built-in activity (B8, ADR-042) is valid with a unique
/// name, so installing any of them just works.
void main() {
  final l10n = AppLocalizationsEn();
  final builtIns = builtInActivities(l10n);

  test('every built-in activity passes the activity validator', () {
    for (final activity in builtIns) {
      expect(
        ActivityTypeValidator.validate(activity).issues,
        isEmpty,
        reason: activity.name,
      );
    }
  });

  test('built-in activity names are unique', () {
    final names = builtIns.map((t) => t.name.toLowerCase()).toList();
    expect(names.toSet(), hasLength(names.length));
  });

  test('the everyday built-in activities are there', () {
    expect(
      builtIns.map((t) => t.name),
      containsAll([
        'Gym',
        'Running',
        'Reading',
        'Study',
        'Meditation',
        'Water',
        'Sleep',
        'Mood',
        'Language learning',
        'Focused work',
      ]),
    );
  });

  test('every starter activity sits in exactly one category', () {
    final names = [
      for (final c in activityCategories(l10n))
        for (final t in c.activities) t.name,
    ];
    for (final starter in starterActivities(l10n)) {
      expect(
        names.where((n) => n == starter.name),
        hasLength(1),
        reason: starter.name,
      );
    }
  });

  test(
    'the built-in activities cover everyday life, every category filled',
    () {
      final categories = activityCategories(l10n);
      expect(categories.map((c) => c.name), [
        'Sleep & self-care',
        'Health',
        'Food & drink',
        'Home & chores',
        'Money',
        'Family & care',
        'Work',
        'Learning',
        'Exercise & sport',
        'Mind & wellbeing',
        'Faith & spirituality',
        'Hobbies & fun',
        'Friends & community',
        'Travel & errands',
      ]);
      for (final category in categories) {
        expect(category.activities, isNotEmpty, reason: category.name);
      }
      expect(builtIns.length, greaterThanOrEqualTo(140));
      expect(
        builtIns.map((t) => t.name),
        containsAll([
          'Meal',
          'Medication',
          'Cleaning',
          'Groceries',
          'Pet care',
          'Commute',
          'Journal',
          'Screen time',
          'Expense',
          'Puja',
          'Salah',
          'Pranayama',
          'Tuition',
          'House help',
          'Gig work',
          'Social media',
        ]),
      );
    },
  );
}
