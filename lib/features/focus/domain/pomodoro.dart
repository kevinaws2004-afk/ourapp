/// Focus settings (Me → Focus): Pomodoro rounds and Do Not Disturb while a
/// timer runs. Stored as JSON in `app_preferences`.
class FocusSettings {
  const FocusSettings({
    this.pomodoro = false,
    this.workMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.longBreakEvery = 4,
    this.doNotDisturb = false,
    this.roundsByActivity = const {},
    this.blockApps = false,
    this.blockedApps = const [],
  });

  static const defaults = FocusSettings();

  static const workChoices = [15, 20, 25, 30, 45, 50, 60, 90];

  /// Debug builds also offer 1-minute rounds and breaks, to try Pomodoro
  /// without waiting.
  static List<int> choicesFor(List<int> choices, {required bool debug}) =>
      debug ? [1, ...choices] : choices;
  static const shortBreakChoices = [3, 5, 10, 15];
  static const longBreakChoices = [10, 15, 20, 30];
  static const longEveryChoices = [2, 3, 4, 5, 6];

  /// Work in rounds with breaks between them.
  final bool pomodoro;
  final int workMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;

  /// Every this many rounds, the break is the long one.
  final int longBreakEvery;

  /// Silence the phone (Do Not Disturb, priority only) while a timer runs.
  final bool doNotDisturb;

  /// Block [blockedApps] (package names) while a session runs.
  final bool blockApps;
  final List<String> blockedApps;

  /// Rounds turned on or off for an activity (by its id), over the default
  /// ([focusIcons]).
  final Map<String, bool> roundsByActivity;

  /// Activities that are focus work by default (study, work, reading,
  /// languages, writing, code): rounds suit them. A workout or a walk isn't
  /// cut into focus rounds unless asked.
  static const focusIcons = {
    'graduation-cap',
    'laptop',
    'book-open',
    'translate',
    'code',
    'pencil-simple',
    'briefcase',
    'brain',
    'notebook',
  };

  /// Whether rounds apply to an activity with [activityId] and [iconId]
  /// (when Pomodoro is on).
  bool roundsFor(String activityId, String? iconId) =>
      roundsByActivity[activityId] ?? focusIcons.contains(iconId);

  FocusSettings withRoundsFor(String activityId, {required bool on}) =>
      copyWith(roundsByActivity: {...roundsByActivity, activityId: on});

  int get workMs => workMinutes * Duration.millisecondsPerMinute;

  /// The break after round [round] (1-based).
  Duration breakAfter(int round) => Duration(
    minutes: round % longBreakEvery == 0 ? longBreakMinutes : shortBreakMinutes,
  );

  FocusSettings copyWith({
    bool? pomodoro,
    int? workMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? longBreakEvery,
    bool? doNotDisturb,
    Map<String, bool>? roundsByActivity,
    bool? blockApps,
    List<String>? blockedApps,
  }) => FocusSettings(
    pomodoro: pomodoro ?? this.pomodoro,
    workMinutes: workMinutes ?? this.workMinutes,
    shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
    longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
    longBreakEvery: longBreakEvery ?? this.longBreakEvery,
    doNotDisturb: doNotDisturb ?? this.doNotDisturb,
    roundsByActivity: roundsByActivity ?? this.roundsByActivity,
    blockApps: blockApps ?? this.blockApps,
    blockedApps: blockedApps ?? this.blockedApps,
  );

  Map<String, Object> toJson() => {
    'pomodoro': pomodoro,
    'workMinutes': workMinutes,
    'shortBreakMinutes': shortBreakMinutes,
    'longBreakMinutes': longBreakMinutes,
    'longBreakEvery': longBreakEvery,
    'doNotDisturb': doNotDisturb,
    'roundsByActivity': roundsByActivity,
    'blockApps': blockApps,
    'blockedApps': blockedApps,
  };

  factory FocusSettings.fromJson(Object? json) {
    if (json is! Map) return defaults;
    int minutes(String key, int fallback) => switch (json[key]) {
      final int v when v > 0 && v <= 240 => v,
      _ => fallback,
    };
    const d = defaults;
    return FocusSettings(
      pomodoro: json['pomodoro'] == true,
      workMinutes: minutes('workMinutes', d.workMinutes),
      shortBreakMinutes: minutes('shortBreakMinutes', d.shortBreakMinutes),
      longBreakMinutes: minutes('longBreakMinutes', d.longBreakMinutes),
      longBreakEvery: minutes('longBreakEvery', d.longBreakEvery),
      doNotDisturb: json['doNotDisturb'] == true,
      roundsByActivity: switch (json['roundsByActivity']) {
        final Map<Object?, Object?> m => {
          for (final MapEntry(:key, :value) in m.entries)
            if (key is String && value is bool) key: value,
        },
        _ => const {},
      },
      blockApps: json['blockApps'] == true,
      blockedApps: switch (json['blockedApps']) {
        final List<Object?> l => [
          for (final p in l)
            if (p is String) p,
        ],
        _ => const [],
      },
    );
  }
}

/// Pomodoro bookkeeping for the active session: the rounds already ended
/// with a break, and the break running now, if any. Breaks pause the
/// session, so they never count as focused time.
class PomodoroState {
  const PomodoroState({
    required this.sessionId,
    required this.roundsDone,
    required this.roundStartMs,
    this.breakEndsAt,
  });

  final String sessionId;

  /// Rounds ended with a break.
  final int roundsDone;

  /// The focused time (ms) when the current round started. It ends one
  /// round length later, with the length as set now.
  final int roundStartMs;

  /// When the current break ends; null while working.
  final DateTime? breakEndsAt;

  Map<String, Object?> toJson() => {
    'session': sessionId,
    'roundsDone': roundsDone,
    'roundStartMs': roundStartMs,
    'breakEndsAt': breakEndsAt?.millisecondsSinceEpoch,
  };

  static PomodoroState? fromJson(Object? json) {
    if (json is! Map) return null;
    final session = json['session'];
    final rounds = json['roundsDone'];
    final ends = json['breakEndsAt'];
    final roundStart = json['roundStartMs'];
    if (session is! String || rounds is! int || roundStart is! int) {
      return null;
    }
    return PomodoroState(
      sessionId: session,
      roundsDone: rounds,
      roundStartMs: roundStart,
      breakEndsAt: ends is int
          ? DateTime.fromMillisecondsSinceEpoch(ends, isUtc: true)
          : null,
    );
  }
}

/// Where a running session is in its rounds: which round, and how long
/// until its break.
class PomodoroPosition {
  const PomodoroPosition({required this.round, required this.leftMs});

  /// Worked out from the focused time: round 1 for the first [workMs], …
  factory PomodoroPosition.at(int elapsedMs, int workMs) {
    final done = elapsedMs ~/ workMs;
    return PomodoroPosition(
      round: done + 1,
      leftMs: (done + 1) * workMs - elapsedMs,
    );
  }

  final int round;
  final int leftMs;
}
