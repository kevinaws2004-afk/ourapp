import 'package:daylog/core/time/local_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round-trips YYYY-MM-DD and rejects invalid dates', () {
    expect(LocalDate.parse('2026-10-04').toIso(), '2026-10-04');
    expect(() => LocalDate.parse('2026-02-30'), throwsFormatException);
    expect(() => LocalDate.parse('2026-1-4'), throwsFormatException);
  });

  test(
    'the local day of an instant depends on the offset (midnight crossing)',
    () {
      final instant = DateTime.utc(2026, 10, 3, 22, 30);

      expect(
        LocalDate.ofInstant(instant, Duration.zero),
        LocalDate(2026, 10, 3),
      );
      expect(
        LocalDate.ofInstant(instant, const Duration(hours: 5, minutes: 30)),
        LocalDate(2026, 10, 4),
      );
      expect(
        LocalDate.ofInstant(instant, const Duration(hours: -8)),
        LocalDate(2026, 10, 3),
      );
    },
  );

  test('dates order chronologically', () {
    expect(
      LocalDate(2026, 9, 30).compareTo(LocalDate(2026, 10, 1)),
      lessThan(0),
    );
  });

  test('local times are minutes since midnight', () {
    expect(LocalTime.hm(21, 10).minuteOfDay, 1270);
    expect(LocalTime.isValidMinute(1440), isFalse);
    expect(LocalTime.hm(7, 5).toString(), '07:05');
  });

  test(
    'adds days across month and year boundaries; weekday is ISO (Mon = 1)',
    () {
      expect(LocalDate(2026, 12, 31).addDays(1), LocalDate(2027, 1, 1));
      expect(LocalDate(2026, 3, 1).addDays(-1), LocalDate(2026, 2, 28));
      expect(LocalDate(2026, 10, 4).addDays(7), LocalDate(2026, 10, 11));
      expect(LocalDate(2026, 10, 5).weekday, DateTime.monday);
      expect(LocalDate(2026, 10, 4).weekday, DateTime.sunday);
    },
  );
}
