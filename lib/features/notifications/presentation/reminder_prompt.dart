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
import 'notification_providers.dart';

/// "Remind me" label for [minutes] before (0 = at start, null = none).
String reminderLabel(AppLocalizations l10n, int? minutes) => switch (minutes) {
  null => l10n.reminderNone,
  0 => l10n.reminderAtStart,
  final m when m >= 60 && m % 60 == 0 => l10n.reminderHoursBefore(m ~/ 60),
  final m => l10n.reminderMinutesBefore(m),
};

/// The reminder sheet: [title] at [startLabel], pick none, at start or a
/// number of minutes before. With [offerAlways], a "don't ask again"
/// checkbox. Returns the choice, or `(cancelled: true)` when dismissed.
Future<({bool cancelled, int? minutes, bool always})> showReminderSheet(
  BuildContext context, {
  required String title,
  required String startLabel,
  int? current,
  bool offerAlways = false,
}) async {
  final result = await showModalBottomSheet<({int? minutes, bool always})>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) => _ReminderSheet(
      title: title,
      startLabel: startLabel,
      current: current,
      offerAlways: offerAlways,
    ),
  );
  return (
    cancelled: result == null,
    minutes: result?.minutes,
    always: result?.always ?? false,
  );
}

class _ReminderSheet extends StatefulWidget {
  const _ReminderSheet({
    required this.title,
    required this.startLabel,
    required this.current,
    required this.offerAlways,
  });

  final String title;
  final String startLabel;
  final int? current;
  final bool offerAlways;

  @override
  State<_ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends State<_ReminderSheet> {
  late int? _choice = widget.current ?? 10;
  bool _always = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    Widget option(int? minutes) {
      final selected = _choice == minutes;
      return Padding(
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
              setState(() => _choice = minutes);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Icon(
                    minutes == null ? AppIcons.close : AppIcons.time,
                    size: 18,
                    color: selected ? c.brandPrimary : c.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      reminderLabel(l10n, minutes),
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
    }

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
                        l10n.reminderSubtitle(widget.title, widget.startLabel),
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
            for (final m in NotificationSettings.choices) option(m),
            option(null),
            if (widget.offerAlways)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _always,
                onChanged: (v) => setState(() => _always = v ?? false),
                title: Text(
                  l10n.reminderDontAsk,
                  style: context.textStyles.bodyMedium,
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: _choice == null ? l10n.reminderSkip : l10n.reminderSet,
              icon: _choice == null ? null : AppIcons.bell,
              expand: true,
              onPressed: () =>
                  Navigator.of(context)
                      .pop((minutes: _choice, always: _always)),
            ),
          ],
        ),
      ),
    );
  }
}

/// After adding a timed thing: asks "Want a reminder?" (or applies the
/// saved choice), saves it for [planId] — and its repeats, if any — and
/// asks for notification permission the first time one is set.
Future<void> askReminderFor(
  BuildContext context,
  WidgetRef ref,
  PlanId planId, {
  required String title,
  required DateTime startUtc,
}) async {
  final settings =
      ref.read(notificationSettingsProvider).value ??
      NotificationSettings.defaults;
  if (!settings.enabled) return;
  int? minutes;
  switch (settings.newItems) {
    case NewItemReminders.never:
      return;
    case NewItemReminders.always:
      minutes = settings.defaultMinutes;
    case NewItemReminders.ask:
      if (!context.mounted) return;
      final material = MaterialLocalizations.of(context);
      final choice = await showReminderSheet(
        context,
        title: title,
        startLabel: material.formatTimeOfDay(
          TimeOfDay.fromDateTime(startUtc.toLocal()),
        ),
        offerAlways: true,
      );
      if (choice.cancelled) return;
      minutes = choice.minutes;
      if (choice.always) {
        await ref
            .read(reminderStoreProvider)
            .setSettings(
              settings.copyWith(
                newItems: minutes == null
                    ? NewItemReminders.never
                    : NewItemReminders.always,
                defaultMinutes: minutes,
              ),
            );
      }
  }
  await setReminderFor(ref, planId, minutes);
}

/// Saves [minutes] as [planId]'s reminder (and its series', if it repeats);
/// asks for permission when turning one on.
Future<void> setReminderFor(WidgetRef ref, PlanId planId, int? minutes) async {
  final store = ref.read(reminderStoreProvider);
  await store.setPlanReminder(planId, minutes);
  final plan = await ref.read(planRepositoryProvider).getPlan(planId);
  if (plan?.seriesId case final series?) {
    await store.setSeriesReminder(series, minutes);
  }
  if (minutes != null) {
    await ref.read(notificationServiceProvider).requestPermission();
  }
}

/// Without asking (suggestions, "do it today"): only the saved "always".
Future<void> applyDefaultReminder(WidgetRef ref, PlanId planId) async {
  final settings =
      ref.read(notificationSettingsProvider).value ??
      NotificationSettings.defaults;
  if (!settings.enabled || settings.newItems != NewItemReminders.always) {
    return;
  }
  await setReminderFor(ref, planId, settings.defaultMinutes);
}
