import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/time/local_date.dart';
import '../../plans/domain/day_progress.dart';
import '../../plans/presentation/plan_providers.dart';
import '../../plans/presentation/plan_views.dart';

/// This week as seven pills on Today: today filled in the signature color,
/// a dot under days that have something, a check under days fully done.
/// Tapping another day opens it in Plan.
class WeekStrip extends StatelessWidget {
  const WeekStrip({super.key, required this.today, required this.onOpenDay});

  final LocalDate today;
  final ValueChanged<LocalDate> onOpenDay;

  @override
  Widget build(BuildContext context) {
    final start = weekStartOf(context, today);
    return Row(
      children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: _Day(
              date: start.addDays(i),
              isToday: start.addDays(i) == today,
              past: start.addDays(i).compareTo(today) < 0,
              onTap: () => onOpenDay(start.addDays(i)),
            ),
          ),
      ],
    );
  }
}

class _Day extends ConsumerWidget {
  const _Day({
    required this.date,
    required this.isToday,
    required this.past,
    required this.onTap,
  });

  final LocalDate date;
  final bool isToday;
  final bool past;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final day = DateTime(date.year, date.month, date.day);
    final overview = ref.watch(dayOverviewProvider(date)).value;
    final progress = overview == null ? null : DayProgress.of(overview);
    final has = progress != null && !progress.isEmpty;
    final fg = isToday ? c.onBrandPrimary : c.textPrimary;
    final Color? mark = !has
        ? null
        : isToday
        ? c.onBrandPrimary
        : progress.allDone
        ? c.success
        : past
        ? c.textTertiary
        : c.brandPrimary;
    return Semantics(
      button: true,
      selected: isToday,
      label: MaterialLocalizations.of(context).formatFullDate(day),
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Material(
          color: isToday ? c.brandPrimary : c.surfaceBase,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdAll,
            side: isToday ? BorderSide.none : BorderSide(color: c.borderSubtle),
          ),
          child: InkWell(
            borderRadius: AppRadius.mdAll,
            onTap: isToday ? null : onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Column(
                children: [
                  Text(
                    DateFormat.E(locale).format(day).toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: context.textStyles.labelSmall?.copyWith(
                      fontSize: 9.5,
                      color: isToday
                          ? c.onBrandPrimary.withValues(alpha: 0.85)
                          : c.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${date.day}',
                    style: context.textStyles.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: past && !isToday ? c.textSecondary : fg,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: mark,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
