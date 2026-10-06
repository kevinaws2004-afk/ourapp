import 'package:daylog/features/activity_types/domain/activity_type_validator.dart';
import 'package:daylog/features/activity_types/presentation/activity_templates.dart';
import 'package:daylog/l10n/generated/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every starter template (B8 gallery) is a valid activity with a unique
/// name, so installing any of them just works.
void main() {
  final templates = activityTemplates(AppLocalizationsEn());

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
}
