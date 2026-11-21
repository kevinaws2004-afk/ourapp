import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/json_preferences.dart';
import '../../../core/time/clock_provider.dart';
import '../../../core/time/local_date.dart';
import '../../insights/presentation/insight_providers.dart';
import '../../plans/domain/day_progress.dart';
import '../../plans/presentation/plan_date_notifier.dart';
import '../../plans/presentation/plan_providers.dart';
import '../domain/day_streak.dart';

/// The app-wide day streak (any activity done counts), or null while
/// loading. Today counts as soon as anything on it is done, ticked tasks
/// included.
final dayStreakProvider = Provider.autoDispose<DayStreak?>((ref) {
  final active = ref.watch(activeDaysProvider).value;
  if (active == null) return null;
  final today = currentLocalDate(ref.watch(clockProvider));
  final day = ref.watch(dayOverviewProvider(today)).value;
  final days = <LocalDate>{
    for (final set in active.values) ...set,
    if (day != null && DayProgress.of(day).done > 0) today,
  };
  return DayStreak.of(days, today);
});

const _plantNameKey = 'plantName';

/// What the plant is called (the person can rename it); null: not named.
final plantNameProvider = StreamProvider.autoDispose<String?>(
  (ref) => ref
      .watch(jsonPreferencesProvider)
      .watch(_plantNameKey)
      .map((v) => v is String && v.trim().isNotEmpty ? v.trim() : null),
);

Future<void> renamePlant(WidgetRef ref, String name) =>
    ref.read(jsonPreferencesProvider).write(_plantNameKey, name.trim());

/// One evening check-in: how the day felt (1 = rough … 5 = great) and a
/// line about it.
class DayCheckIn {
  const DayCheckIn({required this.mood, this.line = ''});

  final int mood;
  final String line;
}

const _checkInsKey = 'dayCheckIns';

/// Every check-in by day.
final checkInsProvider = StreamProvider.autoDispose<Map<LocalDate, DayCheckIn>>(
  (ref) => ref.watch(jsonPreferencesProvider).watch(_checkInsKey).map((json) {
    if (json is! Map) return const {};
    return {
      for (final MapEntry(:key, :value) in json.entries)
        if (key is String && value is Map && value['m'] is int)
          LocalDate.parse(key): DayCheckIn(
            mood: value['m'] as int,
            line: value['t'] is String ? value['t'] as String : '',
          ),
    };
  }),
);

/// Saves [date]'s check-in.
Future<void> saveCheckIn(WidgetRef ref, LocalDate date, DayCheckIn c) async {
  final prefs = ref.read(jsonPreferencesProvider);
  final json = await prefs.read(_checkInsKey);
  final all = json is Map
      ? Map<String, Object?>.from(json)
      : <String, Object?>{};
  all[date.toIso()] = {'m': c.mood, 't': c.line.trim()};
  await prefs.write(_checkInsKey, all);
}
