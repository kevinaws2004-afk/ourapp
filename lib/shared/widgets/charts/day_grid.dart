import 'package:flutter/material.dart';

import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/sizes.dart';
import '../../../core/time/local_date.dart';

/// The consistency calendar (H1): a square per day from [from] to [to],
/// filled with [color] more strongly the more was done that day; empty days
/// are the sunken surface. Up to a quarter it's a calendar (weekday columns,
/// day numbers); a year is a heatmap that scrolls sideways and opens on the
/// latest weeks.
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

  /// Up to this many weeks show as a calendar; longer ranges as a heatmap.
  static const _calendarWeeks = 14;

  @override
  Widget build(BuildContext context) {
    final most = counts.values.fold<int>(0, (m, n) => n > m ? n : m);
    final firstMonday = from.addDays(-(from.weekday - 1));
    final weeks = <LocalDate>[
      for (var w = firstMonday; w.compareTo(to) <= 0; w = w.addDays(7)) w,
    ];
    Color? fillOf(LocalDate day) {
      final inRange = day.compareTo(from) >= 0 && day.compareTo(to) <= 0;
      if (!inRange) return null;
      final fill = strength(counts[day] ?? 0, most);
      return fill == 0
          ? context.colors.surfaceSunken
          : color.withValues(alpha: fill);
    }

    final grid = weeks.length <= _calendarWeeks
        ? _calendar(context, weeks, fillOf, most)
        : _heatmap(weeks, fillOf);
    return Semantics(label: semanticLabel, excludeSemantics: true, child: grid);
  }

  /// A month-style calendar: weekday columns, a row per week, the day
  /// number in each square.
  Widget _calendar(
    BuildContext context,
    List<LocalDate> weeks,
    Color? Function(LocalDate) fillOf,
    int most,
  ) {
    final c = context.colors;
    final locale = MaterialLocalizations.of(context);
    // Monday-first initials, from the device's language.
    final initials = [
      for (var i = 0; i < 7; i++) locale.narrowWeekdays[(i + 1) % 7],
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 6.0;
        final cell = ((constraints.maxWidth - gap * 6) / 7).clamp(16.0, 38.0);
        Widget row(List<Widget> cells) => Padding(
          padding: const EdgeInsets.only(bottom: gap),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: cells,
          ),
        );
        return Column(
          children: [
            row([
              for (final d in initials)
                SizedBox(
                  width: cell,
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: context.textStyles.labelSmall?.copyWith(
                      color: c.textTertiary,
                    ),
                  ),
                ),
            ]),
            for (final week in weeks)
              row([
                for (var i = 0; i < 7; i++)
                  _cell(context, week.addDays(i), fillOf, cell, most),
              ]),
          ],
        );
      },
    );
  }

  Widget _cell(
    BuildContext context,
    LocalDate day,
    Color? Function(LocalDate) fillOf,
    double size,
    int most,
  ) {
    final fill = fillOf(day);
    final strong = strength(counts[day] ?? 0, most) >= 0.6;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
        color: fill,
      ),
      alignment: Alignment.center,
      child: fill == null
          ? null
          : Text(
              '${day.day}',
              style: context.textStyles.labelSmall?.copyWith(
                fontSize: size > 32 ? 12 : 10,
                color: strong
                    ? context.colors.onBrandPrimary
                    : context.colors.textSecondary,
              ),
            ),
    );
  }

  /// A long range: a column per week, scrolling, latest weeks first.
  Widget _heatmap(List<LocalDate> weeks, Color? Function(LocalDate) fillOf) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        children: [
          for (final week in weeks)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 7; i++)
                  Container(
                    width: AppSizes.dayGridCell,
                    height: AppSizes.dayGridCell,
                    margin: const EdgeInsets.all(AppSizes.dayGridGap / 2),
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.xsAll,
                      color: fillOf(week.addDays(i)),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
