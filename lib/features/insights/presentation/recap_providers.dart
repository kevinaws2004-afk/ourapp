import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/async/combine_latest.dart';
import '../../../core/time/clock_provider.dart';
import '../../../core/time/local_date.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../activity_types/domain/field_type.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../../challenges/domain/challenge_progress.dart';
import '../../plans/presentation/plan_date_notifier.dart';
import '../../plans/presentation/plan_providers.dart';
import '../domain/auto_insights.dart';
import '../domain/insight.dart';
import '../domain/week_recap.dart';
import 'insight_providers.dart';

/// The Monday of the week to recap by default: the current one (so far).
/// The arrows go back to earlier weeks.
LocalDate defaultRecapWeek(LocalDate today) => weekStartOf(today);

/// The week starting [weekStart] (a Monday), with the week before.
final weekRecapProvider = StreamProvider.autoDispose
    .family<WeekRecap, LocalDate>((ref, weekStart) async* {
      final repo = ref.watch(insightRepositoryProvider);
      final today = currentLocalDate(ref.watch(clockProvider));
      final weekEnd = weekStart.addDays(6);
      final until = weekEnd.compareTo(today) < 0 ? weekEnd : today;
      final previous = weekStart.addDays(-7);
      // Repeating plans need their occurrences for planned vs actual (A5).
      await ref.read(ensureSeriesOccurrencesProvider)(weekStart, until);
      yield* combineLatest2(
        combineLatest2(
          repo.watchPlannedVsActual(null, from: weekStart, today: until),
          repo.watchPlanAdherence(weekStart, until),
          (pva, adherence) => (pva, adherence),
        ),
        combineLatest2(
          combineLatest2(
            repo.watchActivityTotals(weekStart, weekEnd),
            repo.watchActivityTotals(previous, previous.addDays(6)),
            (now, before) => (now, before),
          ),
          combineLatest2(
            repo.watchDayCounts(null, weekStart, weekEnd),
            repo.watchTimeByActivity(weekStart, weekEnd),
            (counts, times) => (counts, times),
          ),
          (totals, days) => (totals, days),
        ),
        (plans, rest) => WeekRecap.of(
          weekStart: weekStart,
          planned: plans.$1.$1,
          actual: plans.$1.$2,
          adherence: plans.$2,
          totals: rest.$1.$1,
          previousTotals: rest.$1.$2,
          dayCounts: rest.$2.$1,
          timeByDay: rest.$2.$2,
        ),
      );
    });

/// A personal best: the activity, what it's a best of ("Pages", "Chest
/// Press · best Weight"), its value and the day.
class PersonalRecord {
  const PersonalRecord({
    required this.type,
    required this.chart,
    required this.point,
  });

  final ActivityType type;
  final AutoChart chart;
  final DataPoint point;
}

/// Personal bests set on or after [since], newest first: each activity's
/// "best" charts (a top-level number, a list row's heaviest weight…) whose
/// all-time best falls in the window and beat an earlier day (FR-AN-08).
final personalRecordsProvider = StreamProvider.autoDispose
    .family<List<PersonalRecord>, LocalDate>((ref, since) async* {
      final repo = ref.watch(insightRepositoryProvider);
      final types = await ref.watch(activeActivityTypesProvider.future);
      final today = currentLocalDate(ref.watch(clockProvider));
      final streams = <Stream<PersonalRecord?>>[];
      for (final type in types) {
        // Row names used lately (exercises…), for per-row bests.
        final names = await repo
            .watchRowNames(type.id, today.addDays(-90), today)
            .first;
        for (final chart in autoChartsFor(type, names, maxRows: 6)) {
          final source = chart.config.source;
          if (source is! FieldValueSource) continue;
          if (chart.kind != AutoChartKind.best &&
              chart.kind != AutoChartKind.value) {
            continue;
          }
          if (chart.bestIs == BestIs.none) continue;
          // Numbers and durations: a rating's best is just full marks.
          final field = type.fieldById(source.fieldId);
          if (field == null ||
              field.type != FieldType.number &&
                  field.type != FieldType.duration) {
            continue;
          }
          // A best only counts when it beats something from an earlier
          // day: the very first value isn't a record.
          streams.add(
            combineLatest2(
              repo.watchBest(source, chart.bestIs),
              repo.watchPoints(source),
              (best, points) =>
                  best == null ||
                      best.date.compareTo(since) < 0 ||
                      !points.any((p) => p.date.compareTo(best.date) < 0)
                  ? null
                  : PersonalRecord(type: type, chart: chart, point: best),
            ),
          );
        }
      }
      if (streams.isEmpty) {
        yield const [];
        return;
      }
      yield* _combineAll(streams).map(
        (records) => [for (final r in records) ?r]
          ..sort((a, b) {
            final byDate = b.point.date.compareTo(a.point.date);
            return byDate != 0 ? byDate : a.type.name.compareTo(b.type.name);
          }),
      );
    });

/// The latest of every stream, once each has emitted.
Stream<List<T>> _combineAll<T>(List<Stream<T>> streams) {
  if (streams.length == 1) return streams.first.map((v) => [v]);
  final half = streams.length ~/ 2;
  return combineLatest2(
    _combineAll(streams.sublist(0, half)),
    _combineAll(streams.sublist(half)),
    (a, b) => [...a, ...b],
  );
}
