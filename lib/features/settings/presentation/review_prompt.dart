import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';

import '../../../core/database/json_preferences.dart';
import '../../../core/time/clock_provider.dart';

const _key = 'review_prompt';

/// Streak lengths worth a "rate Daylog?" moment.
const reviewStreaks = {7, 14, 30, 60, 100};

/// Google Play's own rating sheet, at a good moment only (a streak
/// milestone, a goal completed), never after an error: not in the first
/// three days, at most once every 60 days and three times in all. Play
/// itself may still decide not to show it.
Future<void> maybeAskForReview(WidgetRef ref) =>
    _ask(ref.read(jsonPreferencesProvider), ref.read(clockProvider).nowUtc());

Future<void> _ask(JsonPreferences prefs, DateTime now) async {
  try {
    final state = await prefs.read(_key);
    final firstSeen = readJson<int?>(state, 'firstSeen', null);
    final asked = readJson<List<dynamic>>(state, 'asked', const []);
    if (firstSeen == null) {
      await prefs.write(_key, {
        'firstSeen': now.millisecondsSinceEpoch,
        'asked': asked,
      });
      return;
    }
    final since = now.difference(
      DateTime.fromMillisecondsSinceEpoch(firstSeen, isUtc: true),
    );
    if (since < const Duration(days: 3) || asked.length >= 3) return;
    final last = asked.whereType<int>().fold<int>(0, (a, b) => a > b ? a : b);
    if (last > 0 &&
        now.difference(DateTime.fromMillisecondsSinceEpoch(last, isUtc: true)) <
            const Duration(days: 60)) {
      return;
    }
    final review = InAppReview.instance;
    if (!await review.isAvailable()) return;
    await prefs.write(_key, {
      'firstSeen': firstSeen,
      'asked': [...asked, now.millisecondsSinceEpoch],
    });
    await review.requestReview();
  } catch (_) {
    // No Play Store (tests, emulators): nothing to ask.
  }
}

/// Notes the first launch, so the three-day wait starts then.
Future<void> noteFirstSeen(WidgetRef ref) async {
  try {
    final prefs = ref.read(jsonPreferencesProvider);
    final state = await prefs.read(_key);
    if (readJson<int?>(state, 'firstSeen', null) != null) return;
    await prefs.write(_key, {
      'firstSeen': ref.read(clockProvider).nowUtc().millisecondsSinceEpoch,
      'asked': const <int>[],
    });
  } catch (_) {
    // Asked again next launch.
  }
}

/// Opens Daylog's Play Store page (Me → Rate Daylog).
Future<void> openStoreListing() async {
  try {
    await InAppReview.instance.openStoreListing();
  } catch (_) {
    // No store on this device.
  }
}
