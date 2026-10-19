import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../shared/widgets/settings_group.dart';
import '../domain/notification_settings.dart';
import '../domain/plan_reminder.dart';
import 'notification_providers.dart';
import 'reminder_prompt.dart';

/// Me → Notifications: the master switch, how new items get reminders,
/// timer alerts, the morning plan and evening review (with their times),
/// and goal streak nudges.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with WidgetsBindingObserver {
  bool? _permitted;
  bool? _onTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_checkPermission());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Back from the system settings: look again.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_checkPermission());
  }

  Future<void> _checkPermission() async {
    final service = ref.read(notificationServiceProvider);
    if (!service.isEnabled) return;
    final ok = await service.isPermitted();
    final onTime = await service.canRemindOnTime();
    if (!mounted) return;
    // Just allowed in the system settings: schedule again, on time.
    if (onTime && _onTime == false) ref.invalidate(notificationSyncProvider);
    setState(() {
      _permitted = ok;
      _onTime = onTime;
    });
  }

  Future<void> _save(NotificationSettings next, {bool turnedOn = false}) async {
    await updateNotificationSettings(ref, next, askPermission: turnedOn);
    await _checkPermission();
  }

  Future<void> _pickTime(int minute, ValueChanged<int> onPicked) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minute ~/ 60, minute: minute % 60),
    );
    if (picked != null) onPicked(picked.hour * 60 + picked.minute);
  }

  /// Default reminder for new timed items: none, at start, or N before.
  Future<void> _pickNewItems(NotificationSettings s) async {
    final l10n = AppLocalizations.of(context);
    final choice = await showModalBottomSheet<({int? minutes})>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      builder: (context) {
        Widget tile(int? minutes) {
          final selected = s.defaultBefore == minutes;
          return ListTile(
            title: Text(
              reminderLabel(
                context,
                minutes == null ? null : ReminderBefore(minutes),
              ),
            ),
            trailing: selected
                ? Icon(AppIcons.check, color: context.colors.brandPrimary)
                : null,
            onTap: () => Navigator.of(context).pop((minutes: minutes)),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    AppSpacing.xxs,
                  ),
                  child: Text(
                    l10n.notificationsNewItems,
                    style: context.textStyles.headlineSmall,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    AppSpacing.sm,
                  ),
                  child: Text(
                    l10n.notificationsDefaultHint,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
                tile(null),
                for (final m in NotificationSettings.choices) tile(m),
              ],
            ),
          ),
        );
      },
    );
    if (choice == null) return;
    final minutes = choice.minutes;
    await _save(
      minutes == null
          ? s.copyWith(newItems: NewItemReminders.ask)
          : s.copyWith(
              newItems: NewItemReminders.always,
              defaultMinutes: minutes,
            ),
      turnedOn: minutes != null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final margin = WindowSizeClass.of(context).screenMargin;
    final s =
        ref.watch(notificationSettingsProvider).value ??
        NotificationSettings.defaults;
    final material = MaterialLocalizations.of(context);
    String timeOf(int minute) => material.formatTimeOfDay(
      TimeOfDay(hour: minute ~/ 60, minute: minute % 60),
    );
    final newItems = reminderLabel(context, switch (s.defaultBefore) {
      final m? => ReminderBefore(m),
      null => null,
    });

    Widget toggle(bool value, ValueChanged<bool> onChanged) => Switch(
      value: value && s.enabled,
      onChanged: s.enabled ? onChanged : null,
    );

    return Scaffold(
      appBar: AppBar(),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppContentWidth.reading),
          child: ListView(
            padding: EdgeInsets.fromLTRB(margin, 0, margin, AppSpacing.xxxl),
            children: [
              ScreenHeader(
                showMark: false,
                title: l10n.notificationsTitle,
                subtitle: l10n.notificationsSubtitle,
              ),
              if (_permitted == false && s.enabled)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: c.warningContainer,
                      borderRadius: AppRadius.mdAll,
                    ),
                    child: Row(
                      children: [
                        Icon(AppIcons.info, color: c.warning, size: 20),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            l10n.notificationsBlocked,
                            style: context.textStyles.bodySmall,
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await ref
                                .read(notificationServiceProvider)
                                .requestPermission();
                            await _checkPermission();
                          },
                          child: Text(l10n.notificationsAllow),
                        ),
                      ],
                    ),
                  ),
                ),
              SettingsGroup(
                children: [
                  SettingsTile(
                    icon: AppIcons.bell,
                    title: l10n.notificationsMaster,
                    subtitle: l10n.notificationsMasterHint,
                    trailing: Switch(
                      value: s.enabled,
                      onChanged: (v) =>
                          unawaited(_save(s.copyWith(enabled: v), turnedOn: v)),
                    ),
                  ),
                ],
              ),
              SettingsGroup(
                title: l10n.notificationsGroupReminders,
                children: [
                  SettingsTile(
                    icon: AppIcons.time,
                    iconColor: c.accent,
                    iconBackground: c.accentSoft,
                    title: l10n.notificationsNewItems,
                    value: newItems,
                    onTap: s.enabled ? () => unawaited(_pickNewItems(s)) : null,
                  ),
                  SettingsTile(
                    icon: AppIcons.bell,
                    iconColor: _onTime == false ? c.warning : c.success,
                    iconBackground: _onTime == false
                        ? c.warningContainer
                        : c.successContainer,
                    title: l10n.notificationsOnTime,
                    subtitle: _onTime == false
                        ? l10n.notificationsOnTimeOff
                        : l10n.notificationsOnTimeOn,
                    value: _onTime == false
                        ? l10n.notificationsOnTimeAllow
                        : null,
                    onTap: _onTime == false && s.enabled
                        ? () => unawaited(
                            ref
                                .read(notificationServiceProvider)
                                .requestOnTimeReminders(),
                          )
                        : null,
                  ),
                  SettingsTile(
                    icon: AppIcons.timer,
                    iconColor: c.action,
                    iconBackground: c.actionSoft,
                    title: l10n.notificationsTimer,
                    subtitle: l10n.notificationsTimerHint,
                    trailing: toggle(
                      s.timerAlerts,
                      (v) => unawaited(
                        _save(s.copyWith(timerAlerts: v), turnedOn: v),
                      ),
                    ),
                  ),
                ],
              ),
              SettingsGroup(
                title: l10n.notificationsGroupDaily,
                children: [
                  SettingsTile(
                    icon: AppIcons.lightMode,
                    iconColor: c.warning,
                    iconBackground: c.warningContainer,
                    title: l10n.notificationsMorning,
                    subtitle: l10n.notificationsAt(timeOf(s.morningMinute)),
                    onTap: s.enabled
                        ? () => unawaited(
                            _pickTime(
                              s.morningMinute,
                              (m) => unawaited(
                                _save(
                                  s.copyWith(
                                    morningMinute: m,
                                    morningPlan: true,
                                  ),
                                  turnedOn: true,
                                ),
                              ),
                            ),
                          )
                        : null,
                    trailing: toggle(
                      s.morningPlan,
                      (v) => unawaited(
                        _save(s.copyWith(morningPlan: v), turnedOn: v),
                      ),
                    ),
                  ),
                  SettingsTile(
                    icon: AppIcons.darkMode,
                    title: l10n.notificationsEvening,
                    subtitle: l10n.notificationsAt(timeOf(s.eveningMinute)),
                    onTap: s.enabled
                        ? () => unawaited(
                            _pickTime(
                              s.eveningMinute,
                              (m) => unawaited(
                                _save(
                                  s.copyWith(
                                    eveningMinute: m,
                                    eveningReview: true,
                                  ),
                                  turnedOn: true,
                                ),
                              ),
                            ),
                          )
                        : null,
                    trailing: toggle(
                      s.eveningReview,
                      (v) => unawaited(
                        _save(s.copyWith(eveningReview: v), turnedOn: v),
                      ),
                    ),
                  ),
                  SettingsTile(
                    icon: AppIcons.streak,
                    iconColor: c.warning,
                    iconBackground: c.warningContainer,
                    title: l10n.notificationsGoals,
                    subtitle: l10n.notificationsGoalsHint,
                    trailing: toggle(
                      s.goalStreaks,
                      (v) => unawaited(
                        _save(s.copyWith(goalStreaks: v), turnedOn: v),
                      ),
                    ),
                  ),
                  SettingsTile(
                    icon: AppIcons.recap,
                    iconColor: c.brandPrimary,
                    iconBackground: c.brandPrimarySoft,
                    title: l10n.notificationsRecap,
                    subtitle: l10n.notificationsRecapHint,
                    trailing: toggle(
                      s.weeklyRecap,
                      (v) => unawaited(
                        _save(s.copyWith(weeklyRecap: v), turnedOn: v),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
