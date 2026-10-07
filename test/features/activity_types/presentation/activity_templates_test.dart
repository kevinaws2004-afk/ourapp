import 'package:daylog/features/activity_types/domain/activity_type_validator.dart';
import 'package:daylog/features/activity_types/presentation/activity_templates.dart';
import 'package:daylog/features/activity_types/presentation/everyday_templates.dart';
import 'package:daylog/l10n/generated/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every starter template (B8 gallery) is a valid activity with a unique
/// name, so installing any of them just works.
void main() {
  final l10n = AppLocalizationsEn();
  final templates = activityTemplates(l10n);

  test('every template passes the activity validator', () {
    for (final template in templates) {
      expect(
        ActivityTypeValidator.validate(template).issues,
        isEmpty,
        reason: template.name,
      );
    }
  });

  test('template names are unique', () {
    final names = templates.map((t) => t.name.toLowerCase()).toList();
    expect(names.toSet(), hasLength(names.length));
  });

  test('the gallery has the everyday templates', () {
    expect(
      templates.map((t) => t.name),
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

  test('every starter template sits in exactly one gallery category', () {
    final names = [
      for (final c in templateCategories(l10n))
        for (final t in c.templates) t.name,
    ];
    for (final starter in starterTemplates(l10n)) {
      expect(
        names.where((n) => n == starter.name),
        hasLength(1),
        reason: starter.name,
      );
    }
  });

  test('the gallery covers everyday life, every category filled', () {
    final categories = templateCategories(l10n);
    expect(categories.map((c) => c.name), [
      'Sleep & self-care',
      'Health',
      'Food & drink',
      'Home & chores',
      'Family & care',
      'Work',
      'Learning',
      'Exercise & sport',
      'Mind & wellbeing',
      'Hobbies & fun',
      'Friends & community',
      'Travel & errands',
    ]);
    for (final category in categories) {
      expect(category.templates, isNotEmpty, reason: category.name);
    }
    expect(templates.length, greaterThanOrEqualTo(90));
    expect(
      templates.map((t) => t.name),
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
      ]),
    );
  });
}
