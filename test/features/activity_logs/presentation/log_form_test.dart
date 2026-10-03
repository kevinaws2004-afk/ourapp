import 'package:daylog/core/design/app_theme.dart';
import 'package:daylog/core/units/unit_registry.dart';
import 'package:daylog/features/activity_logs/domain/field_value.dart';
import 'package:daylog/features/activity_logs/presentation/form/activity_log_form.dart';
import 'package:daylog/features/activity_logs/presentation/form/choice_editors.dart';
import 'package:daylog/features/activity_logs/presentation/form/date_time_editors.dart';
import 'package:daylog/features/activity_logs/presentation/form/text_number_editors.dart';
import 'package:daylog/features/activity_types/domain/activity_ids.dart';
import 'package:daylog/features/activity_types/domain/activity_type.dart';
import 'package:daylog/features/activity_types/domain/field_config.dart';
import 'package:daylog/features/activity_types/domain/field_type.dart';
import 'package:daylog/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

ActivityField field(
  String name,
  FieldType type, {
  FieldConfig? config,
  Dimension? dimension,
  bool required = false,
}) => ActivityField(
  id: ActivityFieldId(name),
  name: name,
  type: type,
  dimension: dimension,
  position: 0,
  required: required,
  measurable: false,
  config: config ?? FieldConfig.defaultFor(type),
);

Future<Map<ActivityFieldId, FieldValue?>> pumpForm(
  WidgetTester tester,
  List<ActivityField> fields,
) async {
  final changes = <ActivityFieldId, FieldValue?>{};
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setState) => ActivityLogFormFields(
              fields: fields,
              values: {
                for (final e in changes.entries)
                  if (e.value != null) e.key: e.value!,
              },
              onChanged: (id, value) => setState(() => changes[id] = value),
            ),
          ),
        ),
      ),
    ),
  );
  return changes;
}

void main() {
  final language = field(
    'Language',
    FieldType.singleSelect,
    config: const SelectFieldConfig(
      options: [
        SelectOption(id: SelectOptionId('es'), label: 'Spanish'),
        SelectOption(id: SelectOptionId('fr'), label: 'French'),
        SelectOption(id: SelectOptionId('old'), label: 'Latin', archived: true),
      ],
    ),
  );

  testWidgets('renders every field in order with the editor for its type', (
    tester,
  ) async {
    final fields = [
      field('Book', FieldType.text, required: true),
      field(
        'Distance',
        FieldType.number,
        dimension: Dimension.distance,
        config: const NumberFieldConfig(decimals: 2, defaultUnitCode: 'km'),
      ),
      field('Done', FieldType.boolean),
      language,
      field('Topics', FieldType.multiSelect, config: language.config),
      field('Day', FieldType.date),
      field('At', FieldType.time),
      field('Rest', FieldType.duration),
      field('Stars', FieldType.rating),
    ];
    await pumpForm(tester, fields);

    expect(
      find.text('Book *'),
      findsOneWidget,
      reason: 'required fields are marked',
    );
    expect(find.byType(TextValueEditor), findsOneWidget);
    expect(find.byType(NumberValueEditor), findsOneWidget);
    expect(
      find.text('km'),
      findsOneWidget,
      reason: 'unit picker for dimensioned numbers',
    );
    expect(find.byType(BooleanValueEditor), findsOneWidget);
    expect(find.byType(SingleSelectValueEditor), findsOneWidget);
    expect(find.byType(MultiSelectValueEditor), findsOneWidget);
    expect(find.byType(DateValueEditor), findsOneWidget);
    expect(find.byType(TimeValueEditor), findsOneWidget);
    expect(find.byType(DurationInput), findsOneWidget);
    expect(find.byType(RatingValueEditor), findsOneWidget);

    final labels = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .toList();
    expect(
      labels.indexOf('Book *'),
      lessThan(labels.indexOf('Stars')),
      reason: 'position order',
    );
  });

  testWidgets('archived options are hidden for new values', (tester) async {
    await pumpForm(tester, [language]);

    expect(find.text('Spanish'), findsOneWidget);
    expect(find.text('Latin'), findsNothing);
  });

  testWidgets('editors emit typed values, including units and clearing', (
    tester,
  ) async {
    final distance = field(
      'Distance',
      FieldType.number,
      dimension: Dimension.distance,
      config: const NumberFieldConfig(decimals: 2, defaultUnitCode: 'km'),
    );
    final stars = field('Stars', FieldType.rating);
    final changes = await pumpForm(tester, [distance, language, stars]);

    await tester.enterText(find.byType(TextField), '5,5');
    await tester.tap(find.text('French'));
    await tester.tap(find.byTooltip('4/5'));
    await tester.pump();
    expect(changes[distance.id], const NumberValue(5.5, unitCode: 'km'));
    expect(changes[language.id], const SingleSelectValue(SelectOptionId('fr')));
    expect(changes[stars.id], const RatingValue(4));

    await tester.tap(find.text('French'));
    await tester.tap(find.byTooltip('4/5'));
    await tester.enterText(find.byType(TextField), '');
    await tester.pump();
    expect(
      changes[language.id],
      isNull,
      reason: 'tapping the selection again clears it',
    );
    expect(changes[stars.id], isNull);
    expect(changes[distance.id], isNull);
  });

  testWidgets('unparsable numbers show an error and store nothing', (
    tester,
  ) async {
    final count = field('Count', FieldType.number);
    final changes = await pumpForm(tester, [count]);

    await tester.enterText(find.byType(TextField), 'abc');
    await tester.pump();

    expect(find.text('Please enter a number.'), findsOneWidget);
    expect(changes[count.id], isNull);
  });
}
