import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ids/id_generator_provider.dart';
import '../../core/time/clock.dart';
import '../../core/time/clock_provider.dart';
import '../../core/time/local_date.dart';
import '../../features/activity_logs/domain/activity_log.dart';
import '../../features/activity_logs/domain/field_value.dart';
import '../../features/activity_logs/presentation/activity_log_providers.dart';
import '../../features/activity_types/domain/activity_ids.dart';
import '../../features/activity_types/domain/activity_type.dart';
import '../../features/activity_types/presentation/activity_templates.dart';
import '../../features/activity_types/presentation/activity_type_providers.dart';
import '../../features/insights/domain/insight.dart';
import '../../features/insights/presentation/insight_providers.dart';
import '../../features/measurements/domain/measurement.dart';
import '../../features/measurements/presentation/measurement_providers.dart';
import '../../features/plans/domain/plan.dart';
import '../../features/plans/presentation/plan_providers.dart';
import '../../l10n/generated/app_localizations.dart';

/// Debug-only demo data: six weeks of Gym, Reading, Walking and Focused work
/// records, plans around today, body measurements and a few saved charts.
/// Everything goes through the normal use cases, so it is validated like user
/// input, alongside any existing data. Returns false (and writes nothing)
/// when the demo data is already there.
Future<bool> loadDemoData(
  ProviderContainer container,
  AppLocalizations l10n,
) async {
  final types = container.read(activityTypeRepositoryProvider);
  final charts = container.read(insightRepositoryProvider);
  if ((await charts.watchCharts().first).any((c) => c.title == _marker)) {
    return false;
  }

  final clock = container.read(clockProvider);
  final install = container.read(installActivityTemplateProvider);
  final logActivity = container.read(logActivityProvider);
  final createPlan = container.read(createPlanProvider);
  final setPlanStatus = container.read(setPlanStatusProvider);
  final recordMeasurement = container.read(recordMeasurementProvider);
  final saveChart = container.read(saveInsightChartProvider);
  final random = Random(42);

  final templates = {for (final t in activityTemplates(l10n)) t.name: t};
  Future<ActivityType> installNamed(String name) async =>
      (await types.getType(await install(templates[name]!)))!;
  final reading = await installNamed(l10n.templateReading);
  final work = await installNamed(l10n.templateFocusedWork);
  final walking = await installNamed(l10n.templateWalking);
  final gym = await installNamed(l10n.templateGym);

  final now = clock.nowUtc();
  final today = LocalDate.ofInstant(now, clock.offsetAt(now));
  DateTime at(LocalDate date, int hour, [int minute = 0]) =>
      _localToUtc(clock, date, hour, minute);
  int minutes(int m) => Duration(minutes: m).inMilliseconds;

  // Field IDs by position (templates are plain data; never match by name).
  final [readingBook, readingPages, readingRating] = _children(reading);
  final [workProject] = _children(work);
  final [walkDistance, walkSteps, _, walkLocation] = _children(walking);
  final [gymFocus, gymExercises] = _children(gym);
  final [gymExercise, gymSets] = _children(gym, gymExercises);
  final [gymWeight, gymReps] = _children(gym, gymSets);

  final ids = container.read(idGeneratorProvider);
  GroupItem item(Map<ActivityFieldId, FieldValue> values) =>
      GroupItem(id: GroupItemId(ids.newId()), values: values);

  const books = ['Atomic Habits', 'The Hobbit', 'Deep Work'];
  const projects = ['Website redesign', 'Quarterly report', 'App prototype'];
  const parks = ['Riverside park', 'Old town', 'Lake loop'];
  var gymSession = 0;

  // Six weeks of history, oldest first; today only gets what already ended.
  for (var back = 42; back >= 0; back--) {
    final date = today.addDays(-back);
    final weekday = DateTime.utc(date.year, date.month, date.day).weekday;
    bool ended(DateTime start, int durationMin) =>
        start.add(Duration(minutes: durationMin)).isBefore(now);

    // Focused work on weekdays, planned the evening before.
    if (weekday <= 5) {
      final start = at(date, 9, random.nextInt(20));
      final duration = 90 + random.nextInt(90);
      final planId = back <= 14
          ? await createPlan(
              PlanDraft(
                planDate: date,
                title: '',
                activityTypeId: work.id,
                plannedStartAt: at(date, 9),
                plannedDurationMs: minutes(120),
              ),
            )
          : null;
      if (ended(start, duration)) {
        await logActivity(
          work.id,
          ActivityLogDraft(
            startedAt: start,
            durationMs: minutes(duration),
            planId: planId,
            values: {workProject: TextValue(projects[(42 - back) ~/ 15 % 3])},
          ),
        );
      }
    }

    // Gym on Mon/Wed/Fri with steady progression.
    if (weekday == 1 || weekday == 3 || weekday == 5) {
      final start = at(date, 18, random.nextInt(15));
      final duration = 55 + random.nextInt(20);
      final planId = back <= 14
          ? await createPlan(
              PlanDraft(
                planDate: date,
                title: '',
                activityTypeId: gym.id,
                plannedStartAt: at(date, 18),
                plannedDurationMs: minutes(60),
              ),
            )
          : null;
      if (ended(start, duration)) {
        if (planId != null && back > 0 && random.nextInt(6) == 0) {
          await setPlanStatus(planId, PlanStatus.skipped);
        } else {
          final s = gymSession++;
          final legDay = weekday == 3;
          final exercises = legDay
              ? [('Squat', 60 + s * 1.25), ('Leg Press', 100 + s * 2.5)]
              : [
                  ('Chest Press', 40 + s * 1.25),
                  ('Lat Pulldown', 45 + s * 1.0),
                ];
          await logActivity(
            gym.id,
            ActivityLogDraft(
              startedAt: start,
              durationMs: minutes(duration),
              planId: planId,
              values: {
                gymFocus: TextValue(legDay ? 'Legs' : 'Chest / Back'),
                gymExercises: RepeatingGroupValue([
                  for (final (name, kg) in exercises)
                    item({
                      gymExercise: TextValue(name),
                      gymSets: RepeatingGroupValue([
                        for (final reps in const [10, 8, 8])
                          item({
                            gymWeight: NumberValue(kg, unitCode: 'kg'),
                            gymReps: NumberValue(reps.toDouble()),
                          }),
                      ]),
                    }),
                ]),
              },
            ),
          );
        }
      }
    }

    // Reading most evenings.
    if (random.nextInt(5) != 0) {
      final start = at(date, 21, 30);
      final duration = 20 + random.nextInt(30);
      if (ended(start, duration)) {
        await logActivity(
          reading.id,
          ActivityLogDraft(
            startedAt: start,
            durationMs: minutes(duration),
            values: {
              readingBook: TextValue(books[(42 - back) ~/ 15 % 3]),
              readingPages: NumberValue((12 + random.nextInt(30)).toDouble()),
              readingRating: RatingValue(3 + random.nextInt(3)),
            },
          ),
        );
      }
    }

    // A lunchtime walk on most days.
    if (random.nextInt(4) != 0) {
      final start = at(date, 12, 30);
      final duration = 20 + random.nextInt(25);
      if (ended(start, duration)) {
        final km = 1.5 + random.nextInt(25) / 10;
        await logActivity(
          walking.id,
          ActivityLogDraft(
            startedAt: start,
            durationMs: minutes(duration),
            values: {
              walkDistance: NumberValue(km, unitCode: 'km'),
              walkSteps: NumberValue((km * 1350).roundToDouble()),
              walkLocation: TextValue(parks[random.nextInt(3)]),
            },
          ),
        );
      }
    }

    // Weekly body measurements, trending down slowly.
    if (back % 7 == 0) {
      final week = (42 - back) ~/ 7;
      final recordedAt = at(date, 7, 30);
      if (recordedAt.isBefore(now)) {
        for (final (type, value, unit) in [
          (MeasurementType.weight, 79.4 - week * 0.45, 'kg'),
          (MeasurementType.bodyFat, 21.5 - week * 0.3, 'percent'),
          (MeasurementType.waist, 86.0 - week * 0.4, 'cm'),
        ]) {
          await recordMeasurement(
            MeasurementDraft(
              type: type,
              value: double.parse(value.toStringAsFixed(1)),
              unitCode: unit,
              recordedAt: recordedAt,
            ),
          );
        }
      }
    }
  }
  await recordMeasurement(
    MeasurementDraft(
      type: MeasurementType.height,
      value: 178,
      unitCode: 'cm',
      recordedAt: at(today.addDays(-42), 7, 30),
    ),
  );

  // Today and tomorrow: tasks and evening plans.
  await createPlan(
    PlanDraft(
      planDate: today,
      title: '',
      activityTypeId: reading.id,
      plannedStartAt: at(today, 21, 30),
      plannedDurationMs: minutes(30),
    ),
  );
  await createPlan(PlanDraft(planDate: today, title: 'Buy groceries'));
  final dentist = await createPlan(
    PlanDraft(planDate: today, title: 'Call the dentist'),
  );
  await setPlanStatus(dentist, PlanStatus.completed);
  final tomorrow = today.addDays(1);
  await createPlan(
    PlanDraft(
      planDate: tomorrow,
      title: 'Morning walk',
      activityTypeId: walking.id,
      plannedStartAt: at(tomorrow, 7),
      plannedDurationMs: minutes(30),
    ),
  );
  await createPlan(PlanDraft(planDate: tomorrow, title: 'Pay rent'));

  // Saved charts (ADR-034).
  final chestPressFilter = TextFilter(
    fieldId: gymExercise,
    value: 'Chest Press',
  );
  for (final (title, source, aggregation, bucket, kind) in [
    (
      _marker,
      VolumeSource(
        gym.id,
        groupFieldId: gymSets,
        amountFieldId: gymWeight,
        countFieldId: gymReps,
      ),
      Aggregation.sum,
      Bucket.week,
      ChartKind.bar,
    ),
    (
      'Chest Press',
      FieldValueSource(gym.id, gymWeight, filter: chestPressFilter),
      Aggregation.max,
      Bucket.week,
      ChartKind.line,
    ),
    (
      'Pages read',
      FieldValueSource(reading.id, readingPages),
      Aggregation.sum,
      Bucket.week,
      ChartKind.bar,
    ),
    (
      'Weight',
      const MeasurementSource(MeasurementType.weight),
      Aggregation.latest,
      Bucket.week,
      ChartKind.line,
    ),
  ]) {
    await saveChart(
      InsightChartConfig(
        id: const InsightChartId(''),
        title: title,
        source: source,
        aggregation: aggregation,
        bucket: bucket,
        kind: kind,
      ),
    );
  }
  return true;
}

/// Title of the first demo chart; its presence means the demo is loaded.
const _marker = 'Gym volume';

/// Live fields under [parent] (top level when null), in form order.
List<ActivityFieldId> _children(ActivityType type, [ActivityFieldId? parent]) =>
    ([
          for (final f in type.fields)
            if (f.parentId == parent && !f.isRemoved) f,
        ]..sort((a, b) => a.position.compareTo(b.position)))
        .map((f) => f.id)
        .toList();

/// [hour]:[minute] local wall-clock time on [date], as a UTC instant.
DateTime _localToUtc(Clock clock, LocalDate date, int hour, int minute) {
  final naive = DateTime.utc(date.year, date.month, date.day, hour, minute);
  return naive.subtract(clock.offsetAt(naive));
}
