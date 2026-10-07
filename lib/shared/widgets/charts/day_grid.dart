import 'package:flutter/material.dart';

import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/sizes.dart';
import '../../../core/time/local_date.dart';

/// The consistency calendar (H1): a square per day from [from] to [to], a
/// column per week (Monday on top), filled with [color] more strongly the
/// more was done that day; empty days are the sunken surface. Long ranges
/// scroll sideways and open on the latest weeks.
class DayGrid extends StatelessWidget {
  const DayGrid({
    super.key,
    required this.from,
    required this.to,
    required this.counts,
    required this.color,
    required this.semanticLabel,
  });

  final LocalDate from;
  final LocalDate to;
  final Map<LocalDate, int> counts;
  final Color color;

  /// What the grid says, for screen readers ("12 of 30 days").
  final String semanticLabel;

  /// Fill strength of a day with [count] done, out of the busiest [most].
  static double strength(int count, int most) {
    if (count <= 0 || most <= 0) return 0;
    final share = count / most;
    if (share > 0.75) return 1;
    if (share > 0.5) return 0.8;
    if (share > 0.25) return 0.6;
    return 0.4;
  }

  @override
  Widget build(BuildContext context) {
    final most = counts.values.fold<int>(0, (m, n) => n > m ? n : m);
    final firstMonday = from.addDays(-(from.weekday - 1));
    final columns = <Widget>[];
    for (var week = firstMonday; week.compareTo(to) <= 0;) {
      final days = <Widget>[];
      for (var i = 0; i < 7; i++) {
        final day = week.addDays(i);
        final inRange = day.compareTo(from) >= 0 && day.compareTo(to) <= 0;
        final fill = strength(counts[day] ?? 0, most);
        days.add(
          Container(
            width: AppSizes.dayGridCell,
            height: AppSizes.dayGridCell,
            margin: const EdgeInsets.all(AppSizes.dayGridGap / 2),
            decoration: BoxDecoration(
              borderRadius: AppRadius.xsAll,
              color: !inRange
                  ? null
                  : fill == 0
                  ? context.colors.surfaceSunken
                  : color.withValues(alpha: fill),
            ),
          ),
        );
      }
      columns.add(Column(mainAxisSize: MainAxisSize.min, children: days));
      week = week.addDays(7);
    }
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        child: Row(children: columns),
      ),
    );
  }
}
