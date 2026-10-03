import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/time/clock.dart';
import '../../../core/time/clock_provider.dart';
import '../../../core/time/local_date.dart';

/// The device's current local date (from the injected Clock).
LocalDate currentLocalDate(Clock clock) {
  final now = clock.nowUtc();
  return LocalDate.ofInstant(now, clock.offsetAt(now));
}

/// The date selected on the Plan tab (ADR-028). Kept while the app runs so
/// switching tabs doesn't lose it; starts on today.
final planSelectedDateProvider = NotifierProvider<PlanDateNotifier, LocalDate>(
  PlanDateNotifier.new,
);

class PlanDateNotifier extends Notifier<LocalDate> {
  @override
  LocalDate build() => currentLocalDate(ref.read(clockProvider));

  void select(LocalDate date) => state = date;

  void goToToday() => state = currentLocalDate(ref.read(clockProvider));

  void shiftDays(int days) => state = state.addDays(days);
}
