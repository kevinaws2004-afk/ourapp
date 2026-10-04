import 'package:flutter/material.dart';

import '../../../../core/design/context_ext.dart';
import '../../../../core/design/tokens/spacing.dart';
import '../../../../core/time/local_date.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/plan_time_suggestions.dart';

/// The time chosen in [showPlanTimeSheet]. A null [start] means "no time".
@immutable
class PlanTimeChoice {
  const PlanTimeChoice(this.start, this.end);

  final LocalTime? start;
  final LocalTime? end;
}

/// One sheet for when something happens (A5): a start time from a few
/// suggestions (or any other time), then how long. Returns the choice, or
/// null if dismissed.
Future<PlanTimeChoice?> showPlanTimeSheet(
  BuildContext context, {
  required bool isToday,
  required LocalTime now,
  LocalTime? start,
  LocalTime? end,
}) => showModalBottomSheet<PlanTimeChoice>(
  context: context,
  isScrollControlled: true,
  builder: (_) =>
      _PlanTimeSheet(isToday: isToday, now: now, start: start, end: end),
);

/// "9:30 PM" in the user's locale.
String formatLocalTime(BuildContext context, LocalTime time) =>
    MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay(hour: time.hour, minute: time.minute));

class _PlanTimeSheet extends StatefulWidget {
  const _PlanTimeSheet({
    required this.isToday,
    required this.now,
    required this.start,
    required this.end,
  });

  final bool isToday;
  final LocalTime now;
  final LocalTime? start;
  final LocalTime? end;

  @override
  State<_PlanTimeSheet> createState() => _PlanTimeSheetState();
}

class _PlanTimeSheetState extends State<_PlanTimeSheet> {
  late final List<LocalTime> _suggested = PlanTimeSuggestions.starts(
    isToday: widget.isToday,
    now: widget.now,
  );
  late LocalTime? _start =
      widget.start ?? (_suggested.isEmpty ? null : _suggested.first);
  late LocalTime? _end = widget.end;

  int? get _lengthMinutes => switch ((_start, _end)) {
    (final s?, final e?) => e.minuteOfDay - s.minuteOfDay,
    _ => null,
  };

  void _setStart(LocalTime start) => setState(() {
    final length = _lengthMinutes;
    _start = start;
    _end = length == null ? null : PlanTimeSuggestions.endAfter(start, length);
  });

  Future<LocalTime?> _pick(LocalTime initial, String help) async {
    final picked = await showTimePicker(
      context: context,
      helpText: help,
      initialTime: TimeOfDay(hour: initial.hour, minute: initial.minute),
    );
    return picked == null ? null : LocalTime.hm(picked.hour, picked.minute);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final start = _start;
    final length = _lengthMinutes;
    final starts = [
      ..._suggested,
      if (start != null && !_suggested.contains(start)) start,
    ];
    final customLength =
        length != null && !PlanTimeSuggestions.durations.contains(length);
    final label = context.textStyles.titleSmall?.copyWith(
      color: context.colors.textSecondary,
    );
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.planTimeSheetTitle, style: context.textStyles.titleLarge),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.planTimeStarts, style: label),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final time in starts)
                  ChoiceChip(
                    label: Text(formatLocalTime(context, time)),
                    selected: time == start,
                    onSelected: (_) => _setStart(time),
                  ),
                ActionChip(
                  label: Text(l10n.planTimeOther),
                  onPressed: () async {
                    final picked = await _pick(
                      start ?? widget.now,
                      l10n.planPickStart,
                    );
                    if (picked != null) _setStart(picked);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.planTimeLength, style: label),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                ChoiceChip(
                  label: Text(l10n.planTimeNoEnd),
                  selected: length == null,
                  onSelected: (_) => setState(() => _end = null),
                ),
                for (final minutes in PlanTimeSuggestions.durations)
                  ChoiceChip(
                    label: Text(
                      minutes < 60
                          ? l10n.planTimeMinutes(minutes)
                          : l10n.planTimeHours(minutes ~/ 60),
                    ),
                    selected: length == minutes,
                    onSelected:
                        start == null ||
                            PlanTimeSuggestions.endAfter(start, minutes) == null
                        ? null
                        // Reads the current start, not the one at build.
                        : (_) => setState(
                            () => _end = PlanTimeSuggestions.endAfter(
                              _start!,
                              minutes,
                            ),
                          ),
                  ),
                ChoiceChip(
                  label: Text(
                    customLength
                        ? l10n.planTimeUntilTime(
                            formatLocalTime(context, _end!),
                          )
                        : l10n.planTimeUntil,
                  ),
                  selected: customLength,
                  onSelected: start == null
                      ? null
                      : (_) async {
                          final picked = await _pick(
                            _end ??
                                PlanTimeSuggestions.endAfter(start, 60) ??
                                start,
                            l10n.planPickEnd,
                          );
                          if (picked != null &&
                              picked.minuteOfDay > start.minuteOfDay) {
                            setState(() => _end = picked);
                          }
                        },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                if (widget.start != null)
                  AppButton(
                    label: l10n.planTimeRemove,
                    variant: AppButtonVariant.tertiary,
                    onPressed: () =>
                        Navigator.of(context)
                            .pop(const PlanTimeChoice(null, null)),
                  ),
                const Spacer(),
                AppButton(
                  label: l10n.actionDone,
                  onPressed: start == null
                      ? null
                      : () =>
                            Navigator.of(context)
                                .pop(PlanTimeChoice(start, _end)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
