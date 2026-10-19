import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/design/context_ext.dart';
import '../../../../core/design/tokens/spacing.dart';
import '../../../../core/time/local_date.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/plan_series.dart';

/// Chooses how a plan repeats (ADR-036): which weekdays, every how many
/// weeks, and an optional last date. Starts on [date]'s weekday. Returns the
/// rule, or null if dismissed.
Future<RepeatRule?> showRepeatSheet(
  BuildContext context, {
  required LocalDate date,
  RepeatRule? initial,
}) => showModalBottomSheet<RepeatRule>(
  useRootNavigator: true,
  useSafeArea: true,
  context: context,
  isScrollControlled: true,
  builder: (_) => _RepeatSheet(date: date, initial: initial),
);

/// Short weekday names ("Mon" …), Monday first, in the user's locale.
List<String> weekdayNames(BuildContext context) {
  final format = DateFormat.E(Localizations.localeOf(context).toString());
  // 2024-01-01 was a Monday.
  return [for (var d = 0; d < 7; d++) format.format(DateTime(2024, 1, 1 + d))];
}

const _everyDay = {1, 2, 3, 4, 5, 6, 7};
const _weekdaysOnly = {1, 2, 3, 4, 5};
const _weekendsOnly = {6, 7};

bool _same(Set<int> a, Set<int> b) => a.length == b.length && a.containsAll(b);

/// "Every day", "Weekdays", "Weekends", or "Mon, Wed, Fri", Monday first.
String formatWeekdays(BuildContext context, Set<int> weekdays) {
  final l10n = AppLocalizations.of(context);
  if (_same(weekdays, _everyDay)) return l10n.repeatEveryDay;
  if (_same(weekdays, _weekdaysOnly)) return l10n.repeatWeekdays;
  if (_same(weekdays, _weekendsOnly)) return l10n.repeatWeekends;
  final names = weekdayNames(context);
  return [
    for (var d = 1; d <= 7; d++)
      if (weekdays.contains(d)) names[d - 1],
  ].join(', ');
}

class _RepeatSheet extends StatefulWidget {
  const _RepeatSheet({required this.date, this.initial});

  final LocalDate date;

  /// Editing an existing repeat: its days, interval and end.
  final RepeatRule? initial;

  @override
  State<_RepeatSheet> createState() => _RepeatSheetState();
}

class _RepeatSheetState extends State<_RepeatSheet> {
  late final Set<int> _weekdays = {
    ...(widget.initial?.weekdays ?? {widget.date.weekday}),
  };
  late int _interval = widget.initial?.intervalWeeks ?? 1;
  late LocalDate? _endDate = widget.initial?.endDate;

  void _use(Set<int> days) => setState(() {
    _weekdays
      ..clear()
      ..addAll(days);
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    final names = weekdayNames(context);
    final end = _endDate;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.planRepeatTitle, style: context.textStyles.titleLarge),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                for (final (label, days) in [
                  (l10n.repeatEveryDay, _everyDay),
                  (l10n.repeatWeekdays, _weekdaysOnly),
                  (l10n.repeatWeekends, _weekendsOnly),
                ])
                  ChoiceChip(
                    label: Text(label),
                    selected: _same(_weekdays, days),
                    onSelected: (_) => _use(days),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (var day = 1; day <= 7; day++)
                  FilterChip(
                    label: Text(names[day - 1]),
                    selected: _weekdays.contains(day),
                    onSelected: (on) => setState(() {
                      on ? _weekdays.add(day) : _weekdays.remove(day);
                    }),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Text(l10n.planRepeatEvery),
                const SizedBox(width: AppSpacing.md),
                DropdownButton<int>(
                  value: _interval,
                  items: [
                    for (final n in const [1, 2, 3, 4])
                      DropdownMenuItem(
                        value: n,
                        child: Text(l10n.planRepeatWeeks(n)),
                      ),
                  ],
                  onChanged: (n) => setState(() => _interval = n ?? 1),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Text(l10n.planRepeatUntil),
                const SizedBox(width: AppSpacing.md),
                OutlinedButton(
                  onPressed: () async {
                    final start = widget.date;
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(
                        start.year,
                        start.month + 1,
                        start.day,
                      ),
                      firstDate: DateTime(start.year, start.month, start.day),
                      lastDate: DateTime(start.year + 5),
                    );
                    if (picked != null) {
                      setState(
                        () => _endDate = LocalDate(
                          picked.year,
                          picked.month,
                          picked.day,
                        ),
                      );
                    }
                  },
                  child: Text(
                    end == null
                        ? l10n.planRepeatForever
                        : material.formatMediumDate(
                            DateTime(end.year, end.month, end.day),
                          ),
                  ),
                ),
                if (end != null)
                  TextButton(
                    onPressed: () => setState(() => _endDate = null),
                    child: Text(l10n.actionClear),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l10n.actionSave,
              onPressed: _weekdays.isEmpty
                  ? null
                  : () => Navigator.of(context).pop(
                      RepeatRule(
                        weekdays: {..._weekdays},
                        intervalWeeks: _interval,
                        endDate: _endDate,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
