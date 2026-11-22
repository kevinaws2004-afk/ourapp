import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/json_preferences.dart';
import '../../../core/time/clock_provider.dart';
import '../../../core/time/local_date.dart';
import '../../plans/presentation/plan_date_notifier.dart';
import '../domain/my_words.dart';

const _wordsKey = 'myWords';
const _onOpenKey = 'myWordsOnOpen';
const _shownOnKey = 'myWordsShownOn';

/// Every saved words, newest first.
final myWordsProvider = StreamProvider.autoDispose<List<MyWords>>(
  (ref) => ref
      .watch(jsonPreferencesProvider)
      .watch(_wordsKey)
      .map(
        (json) => json is List
            ? [for (final w in json.map(MyWords.fromJson)) ?w]
            : const [],
      ),
);

/// Whether today's words show when the app opens (once a day). On unless
/// turned off.
final wordsOnOpenProvider = StreamProvider.autoDispose<bool>(
  (ref) => ref
      .watch(jsonPreferencesProvider)
      .watch(_onOpenKey)
      .map((v) => v is! bool || v),
);

final _shownOnProvider = StreamProvider.autoDispose<String?>(
  (ref) => ref
      .watch(jsonPreferencesProvider)
      .watch(_shownOnKey)
      .map((v) => v is String ? v : null),
);

/// Today's words (empty: none saved). Follows the day.
final todaysWordsProvider = Provider.autoDispose<List<MyWords>>((ref) {
  ref.watch(minuteTickProvider);
  final words = ref.watch(myWordsProvider).value ?? const [];
  return wordsForDay(words, currentLocalDate(ref.watch(clockProvider)));
});

/// Today's words to show on opening the app, or null: none saved, turned
/// off, or already shown today.
final wordsDueProvider = Provider.autoDispose<List<MyWords>?>((ref) {
  final on = ref.watch(wordsOnOpenProvider).value;
  final shown = ref.watch(_shownOnProvider);
  final words = ref.watch(todaysWordsProvider);
  if (on != true || !shown.hasValue || words.isEmpty) return null;
  final today = currentLocalDate(ref.watch(clockProvider));
  return shown.value == today.toIso() ? null : words;
});

/// Saves [words]: replaces the one with its id, or adds it first.
Future<void> saveWords(WidgetRef ref, MyWords words) async {
  final all = [...await _read(ref)];
  final at = all.indexWhere((w) => w.id == words.id);
  if (at < 0) {
    all.insert(0, words);
  } else {
    all[at] = words;
  }
  await _write(ref, all);
}

/// Deletes the words [id]; returns them (for Undo) with where they were.
Future<(MyWords, int)?> deleteWords(WidgetRef ref, String id) async {
  final all = [...await _read(ref)];
  final at = all.indexWhere((w) => w.id == id);
  if (at < 0) return null;
  final removed = all.removeAt(at);
  await _write(ref, all);
  return (removed, at);
}

/// Puts deleted [words] back at [index].
Future<void> restoreWords(WidgetRef ref, MyWords words, int index) async {
  final all = [...await _read(ref)];
  all.insert(index.clamp(0, all.length), words);
  await _write(ref, all);
}

Future<void> setWordsOnOpen(WidgetRef ref, {required bool on}) =>
    ref.read(jsonPreferencesProvider).write(_onOpenKey, on);

/// Today's words have been shown (so not again until tomorrow).
Future<void> markWordsShown(WidgetRef ref, LocalDate day) =>
    ref.read(jsonPreferencesProvider).write(_shownOnKey, day.toIso());

Future<List<MyWords>> _read(WidgetRef ref) async {
  final json = await ref.read(jsonPreferencesProvider).read(_wordsKey);
  return json is List
      ? [for (final w in json.map(MyWords.fromJson)) ?w]
      : const [];
}

Future<void> _write(WidgetRef ref, List<MyWords> all) => ref
    .read(jsonPreferencesProvider)
    .write(_wordsKey, [for (final w in all) w.toJson()]);
