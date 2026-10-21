import 'package:daylog/features/plans/domain/drop_slot.dart';
import 'package:flutter_test/flutter_test.dart';

/// Dragging a plan between two timed things on a day.
void main() {
  final day = DateTime.utc(2026, 10, 20);
  DateTime at(int h, [int m = 0]) => DateTime.utc(2026, 10, 20, h, m);
  DropSlot slot({DateTime? after, DateTime? before, int minutes = 30}) =>
      DropSlot.between(
        previousEnd: after,
        nextStart: before,
        length: Duration(minutes: minutes),
        dayStart: day,
        dayEnd: day.add(const Duration(days: 1)),
      );

  test('it starts right after the one before when it fits the gap', () {
    final s = slot(after: at(9, 30), before: at(11), minutes: 45);
    expect(s.fits, isTrue);
    expect(s.start, at(9, 30));
    expect(s.free, const Duration(minutes: 90));
  });

  test('starts are rounded up to five minutes', () {
    expect(slot(after: at(9, 32)).start, at(9, 35));
  });

  test('too long for the gap: it doesn\'t fit', () {
    final s = slot(after: at(9, 30), before: at(9, 45), minutes: 45);
    expect(s.fits, isFalse);
    expect(s.free, const Duration(minutes: 15));
  });

  test('dropped first, it ends when the next one starts', () {
    final s = slot(before: at(7), minutes: 60);
    expect(s.fits, isTrue);
    expect(s.start, at(6));
  });

  test('dropped first before something at 0:15, an hour can\'t fit', () {
    expect(slot(before: at(0, 15), minutes: 60).fits, isFalse);
  });

  test('dropped last, it follows the last one', () {
    final s = slot(after: at(21));
    expect(s.fits, isTrue);
    expect(s.start, at(21));
  });
}
