import '../../../core/time/local_date.dart';

/// The app-wide streak: days in a row with at least one thing done. Kind
/// by design (what keeps people coming back without guilt):
/// - every [daysPerRestDay] days in a row earns a rest day, up to
///   [maxRestDays] saved;
/// - a missed day uses a saved rest day instead of breaking the streak;
/// - today never breaks it: it's still open until midnight.
///
/// Worked out from the days alone, so it can't go out of sync.
class DayStreak {
  const DayStreak({
    required this.current,
    required this.best,
    required this.restDays,
    required this.doneToday,
    required this.totalDays,
    required this.restedOn,
    required this.daysToRestDay,
  });

  static const daysPerRestDay = 7;
  static const maxRestDays = 2;

  static const empty = DayStreak(
    current: 0,
    best: 0,
    restDays: 0,
    doneToday: false,
    totalDays: 0,
    restedOn: {},
    daysToRestDay: daysPerRestDay,
  );

  /// Days in a row, today included once something is done.
  final int current;
  final int best;

  /// Rest days saved for a day off.
  final int restDays;
  final bool doneToday;

  /// Every day with something done, ever (the plant grows with these).
  final int totalDays;

  /// Missed days a rest day covered.
  final Set<LocalDate> restedOn;

  /// Days in a row still needed for the next rest day.
  final int daysToRestDay;

  /// Whether the streak needs today: there is one, and nothing's done yet.
  bool get atRisk => current > 0 && !doneToday;

  factory DayStreak.of(Set<LocalDate> days, LocalDate today) {
    final past = days.where((d) => d.compareTo(today) < 0).toList()..sort();
    if (past.isEmpty && !days.contains(today)) return empty;
    var streak = 0;
    var best = 0;
    var saved = 0;
    var sinceSaved = 0;
    final rested = <LocalDate>{};
    void count() {
      streak++;
      sinceSaved++;
      if (sinceSaved == daysPerRestDay) {
        sinceSaved = 0;
        if (saved < maxRestDays) saved++;
      }
      if (streak > best) best = streak;
    }

    if (past.isNotEmpty) {
      for (var d = past.first; d.compareTo(today) < 0; d = d.addDays(1)) {
        if (days.contains(d)) {
          count();
        } else if (streak > 0 && saved > 0) {
          saved--;
          rested.add(d);
        } else {
          streak = 0;
          sinceSaved = 0;
        }
      }
    }
    final doneToday = days.contains(today);
    if (doneToday) count();
    return DayStreak(
      current: streak,
      best: best,
      restDays: saved,
      doneToday: doneToday,
      totalDays: days.where((d) => d.compareTo(today) <= 0).length,
      restedOn: rested,
      daysToRestDay: daysPerRestDay - sinceSaved,
    );
  }
}

/// How grown the plant is, from the days something was done (it never
/// shrinks: a missed day doesn't undo growth).
enum PlantStage {
  seed(0),
  sprout(1),
  seedling(3),
  young(7),
  budding(14),
  blooming(30),
  tree(60),
  grandTree(100);

  const PlantStage(this.fromDays);

  /// Days done that reach this stage.
  final int fromDays;

  static PlantStage of(int totalDays) =>
      values.lastWhere((s) => totalDays >= s.fromDays);

  /// The stage after this one, or null at the top.
  PlantStage? get next => index + 1 < values.length ? values[index + 1] : null;
}
