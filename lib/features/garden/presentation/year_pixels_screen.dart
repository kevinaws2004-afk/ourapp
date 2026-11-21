import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/time/clock_provider.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_card.dart';
import '../../insights/presentation/insight_providers.dart';
import '../../plans/presentation/plan_date_notifier.dart';
import 'check_in_card.dart';
import 'garden_providers.dart';

/// Year in pixels: every day of this year as a square, one column per
/// month. A check-in colors it by mood; otherwise green when something got
/// done, ice blue for a rest day, empty for nothing. Tap a month's square
/// to see the day.
class YearPixelsScreen extends ConsumerWidget {
  const YearPixelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final today = currentLocalDate(ref.watch(clockProvider));
    final active = {
      for (final set
          in ref.watch(activeDaysProvider).value?.values ??
              const <Set<LocalDate>>[])
        ...set,
    };
    final checkIns = ref.watch(checkInsProvider).value ?? const {};
    final rested = ref.watch(dayStreakProvider)?.restedOn ?? const {};
    final year = today.year;
    final done = active.where((d) => d.year == year).length;
    final checked = checkIns.keys.where((d) => d.year == year).length;

    Color? colorOf(LocalDate d) {
      if (d.compareTo(today) > 0) return null;
      if (checkIns[d] case final ci?) return moodColor(ci.mood);
      if (active.contains(d)) return c.action;
      if (rested.contains(d)) return const Color(0xFF9CCFE8);
      return c.surfaceSunken;
    }

    return Scaffold(
      appBar: AppBar(title: Text('${l10n.yearTitle} · $year')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            l10n.yearSubtitle,
            style: context.textStyles.bodyMedium?.copyWith(
              color: c.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.yearDays(done, checked),
            style: context.textStyles.titleSmall,
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 12 month columns plus the day numbers.
                final cell = ((constraints.maxWidth - 20) / 12 - 3).clamp(
                  8.0,
                  22.0,
                );
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20,
                      child: Column(
                        children: [
                          SizedBox(height: cell + 4),
                          for (var day = 1; day <= 31; day++)
                            SizedBox(
                              height: cell + 3,
                              child: day % 5 == 0 || day == 1
                                  ? Text(
                                      '$day',
                                      style: context.textStyles.labelSmall
                                          ?.copyWith(
                                            color: c.textTertiary,
                                            fontSize: 9,
                                          ),
                                    )
                                  : null,
                            ),
                        ],
                      ),
                    ),
                    for (var month = 1; month <= 12; month++)
                      Expanded(
                        child: Column(
                          children: [
                            SizedBox(
                              height: cell + 4,
                              child: Text(
                                _monthLetter(context, month),
                                style: context.textStyles.labelSmall?.copyWith(
                                  color: c.textSecondary,
                                ),
                              ),
                            ),
                            for (var day = 1; day <= 31; day++)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: _valid(year, month, day)
                                    ? _Pixel(
                                        size: cell,
                                        color: colorOf(
                                          LocalDate(year, month, day),
                                        ),
                                        today:
                                            today ==
                                            LocalDate(year, month, day),
                                        border: c.textPrimary,
                                      )
                                    // No such day (Feb 30).
                                    : SizedBox.square(dimension: cell),
                              ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              for (var m = 5; m >= 1; m--)
                _Legend(color: moodColor(m), label: moodFaces[m - 1]),
              _Legend(color: c.action, label: l10n.yearLegendDone),
              _Legend(
                color: const Color(0xFF9CCFE8),
                label: l10n.yearLegendRest,
              ),
              _Legend(color: c.surfaceSunken, label: l10n.yearLegendNone),
            ],
          ),
          // Month by month, newest first: days done and the usual mood.
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.yearMonths, style: context.textStyles.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          for (var month = today.month; month >= 1; month--)
            Builder(
              builder: (context) {
                final days = active
                    .where((d) => d.year == year && d.month == month)
                    .length;
                final moods = [
                  for (final MapEntry(:key, :value) in checkIns.entries)
                    if (key.year == year && key.month == month) value.mood,
                ];
                int? usual;
                if (moods.isNotEmpty) {
                  final counts = <int, int>{};
                  for (final m in moods) {
                    counts[m] = (counts[m] ?? 0) + 1;
                  }
                  usual = counts.entries
                      .reduce((a, b) => b.value > a.value ? b : a)
                      .key;
                }
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Text(
                    usual == null ? '📅' : moodFaces[usual - 1],
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    MaterialLocalizations.of(context)
                        .formatMonthYear(DateTime(year, month)),
                  ),
                  subtitle: Text(
                    l10n.yearMonthLine(
                      days,
                      usual == null
                          ? ''
                          : l10n.yearMonthMood(moodWord(l10n, usual)),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  static bool _valid(int year, int month, int day) =>
      DateTime(year, month, day).month == month;

  static String _monthLetter(BuildContext context, int month) {
    final name = MaterialLocalizations.of(context)
        .formatMonthYear(DateTime(2000, month));
    return name.substring(0, 1);
  }
}

class _Pixel extends StatelessWidget {
  const _Pixel({
    required this.size,
    required this.color,
    required this.today,
    required this.border,
  });

  final double size;
  final Color? color;
  final bool today;
  final Color border;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color ?? context.colors.surfaceSunken.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(size * 0.25),
      border: today ? Border.all(color: border, width: 1.5) : null,
    ),
  );
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 4),
      Text(label, style: context.textStyles.labelMedium),
    ],
  );
}
