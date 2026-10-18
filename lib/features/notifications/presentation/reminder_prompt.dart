import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';
import '../../plans/domain/plan.dart';
import '../../plans/presentation/plan_providers.dart';
import '../domain/notification_settings.dart';
import '../domain/plan_reminder.dart';
import 'notification_providers.dart';

/// "10 min before", "At start time", "At 6:00 PM", "No reminder".
String reminderLabel(BuildContext context, PlanReminder? reminder) {
  final l10n = AppLocalizations.of(context);
  return switch (reminder) {
    null => l10n.reminderNone,
    ReminderBefore(minutes: 0) => l10n.reminderAtStart,
    ReminderBefore(:final minutes) when minutes >= 60 && minutes % 60 == 0 =>
      l10n.reminderHoursBefore(minutes ~/ 60),
    ReminderBefore(:final minutes) => l10n.reminderMinutesBefore(minutes),
    ReminderAt(:final hour, :final minute) => l10n.reminderAtTime(
      MaterialLocalizations.of(context)
          .formatTimeOfDay(TimeOfDay(hour: hour, minute: minute)),
    ),
  };
}

/// The reminder picker for [title]. With a [start] (UTC) it offers "at
/// start" and minutes before; always "at a set time" and "no reminder".
/// Returns the choice, or `cancelled` when dismissed.
Future<({bool cancelled, PlanReminder? reminder})> showReminderSheet(
  BuildContext context, {
  required String title,
  required DateTime? start,
  PlanReminder? current,
}) async {
  final result = await showModalBottomSheet<({PlanReminder? reminder})>(
    context: context,
    useRootNavigator: true,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) =>
        _ReminderSheet(title: title, start: start, current: current),
  );
  return (cancelled: result == null, reminder: result?.reminder);
}

class _ReminderSheet extends StatefulWidget {
  const _ReminderSheet({
    required this.title,
    required this.start,
    required this.current,
  });

  final String title;
  final DateTime? start;
  final PlanReminder? current;

  @override
  State<_ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends State<_ReminderSheet> {
  late PlanReminder? _choice =
      widget.current ??
      (widget.start == null ? null : const ReminderBefore(10));

  Future<void> _pickTime() async {
    final initial = switch (_choice) {
      ReminderAt(:final hour, :final minute) => TimeOfDay(
        hour: hour,
        minute: minute,
      ),
      _ => switch (widget.start) {
        final s? => TimeOfDay.fromDateTime(s.toLocal()),
        null => const TimeOfDay(hour: 9, minute: 0),
      },
    };
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null && mounted) {
      setState(() => _choice = ReminderAt(picked.hour * 60 + picked.minute));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final material = MaterialLocalizations.of(context);
    Widget option({
      required String label,
      required bool selected,
      required IconData icon,
      required VoidCallback onTap,
    }) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: selected ? c.brandPrimarySoft : c.surfaceSunken,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: BorderSide(
            color: selected ? c.brandPrimary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: () {
            unawaited(HapticFeedback.selectionClick());
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected ? c.brandPrimary : c.textSecondary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: context.textStyles.labelLarge?.copyWith(
                      color: selected ? c.onBrandPrimarySoft : c.textPrimary,
                    ),
                  ),
                ),
                if (selected)
                  Icon(AppIcons.check, size: 18, color: c.brandPrimary),
              ],
            ),
          ),
        ),
      ),
    );

    final atChoice = _choice is ReminderAt ? _choice : null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: c.brandPrimarySoft,
                    borderRadius: AppRadius.mdAll,
                  ),
                  alignment: Alignment.center,
                  child: Icon(AppIcons.bell, color: c.brandPrimary, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.reminderTitle,
                        style: context.textStyles.headlineSmall,
                      ),
                      Text(
                        widget.start == null
                            ? widget.title
                            : l10n.reminderSubtitle(
                                widget.title,
                                material.formatTimeOfDay(
                                  TimeOfDay.fromDateTime(
                                    widget.start!.toLocal(),
                                  ),
                                ),
                              ),
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            if (widget.start != null)
              for (final m in NotificationSettings.choices)
                option(
                  label: reminderLabel(context, ReminderBefore(m)),
                  selected: _choice == ReminderBefore(m),
                  icon: AppIcons.time,
                  onTap: () => setState(() => _choice = ReminderBefore(m)),
                ),
            option(
              label: atChoice == null
                  ? (widget.start == null
                        ? l10n.reminderPickTime
                        : l10n.reminderPickOtherTime)
                  : reminderLabel(context, atChoice),
              selected: atChoice != null,
              icon: AppIcons.bell,
              onTap: () => unawaited(_pickTime()),
            ),
            option(
              label: l10n.reminderNone,
              selected: _choice == null,
              icon: AppIcons.close,
              onTap: () => setState(() => _choice = null),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: _choice == null ? l10n.reminderSkip : l10n.reminderSet,
              icon: _choice == null ? null : AppIcons.bell,
              expand: true,
              onPressed: () => Navigator.of(context).pop((reminder: _choice)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Saves [reminder] as [planId]'s only reminder (or none).
Future<void> setReminderFor(
  WidgetRef ref,
  PlanId planId,
  PlanReminder? reminder,
) => setRemindersFor(ref, planId, [?reminder]);

/// Saves [reminders] as [planId]'s (and its repeats', if it repeats); asks
/// for notification permission when turning one on.
Future<void> setRemindersFor(
  WidgetRef ref,
  PlanId planId,
  List<PlanReminder> reminders,
) async {
  final store = ref.read(reminderStoreProvider);
  final unique = reminders.toSet().toList();
  await store.setPlanReminders(planId, unique);
  final plan = await ref.read(planRepositoryProvider).getPlan(planId);
  if (plan?.seriesId case final series?) {
    await store.setSeriesReminders(series, unique);
  }
  if (unique.isNotEmpty) {
    await ref.read(notificationServiceProvider).requestPermission();
  }
}

/// The reminder a new item starts with: the default (Me → Notifications)
/// for a timed item, none otherwise.
PlanReminder? defaultReminderFor(WidgetRef ref, {required bool timed}) {
  final settings =
      ref.read(notificationSettingsProvider).value ??
      NotificationSettings.defaults;
  if (!settings.enabled || !timed) return null;
  return switch (settings.defaultBefore) {
    final m? => ReminderBefore(m),
    null => null,
  };
}

/// Without asking (suggestions): the default reminder, if any.
Future<void> applyDefaultReminder(WidgetRef ref, PlanId planId) async {
  if (defaultReminderFor(ref, timed: true) case final reminder?) {
    await setReminderFor(ref, planId, reminder);
  }
}
