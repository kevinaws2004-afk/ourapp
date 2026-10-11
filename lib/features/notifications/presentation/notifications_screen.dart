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
    if (mounted) setState(() => _permitted = ok);
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

  Future<void> _pickNewItems(NotificationSettings s) async {
    final l10n = AppLocalizations.of(context);
    final choice = await showModalBottomSheet<(NewItemReminders, int)>(
      context: context,
      useSafeArea: true,
      builder: (context) {
        Widget tile(String label, NewItemReminders mode, int minutes) {
          final selected =
              s.newItems == mode &&
              (mode != NewItemReminders.always || s.defaultMinutes == minutes);
          return ListTile(
            title: Text(label),
            trailing: selected
                ? Icon(AppIcons.check, color: context.colors.brandPrimary)
                : null,
            onTap: () => Navigator.of(context).pop((mode, minutes)),
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
                    AppSpacing.sm,
                  ),
                  child: Text(
                    l10n.notificationsNewItems,
                    style: context.textStyles.headlineSmall,
                  ),
                ),
                tile(
                  l10n.notificationsAsk,
                  NewItemReminders.ask,
                  s.defaultMinutes,
                ),
                for (final m in NotificationSettings.choices)
                  tile(
                    l10n.notificationsAlways(reminderLabel(l10n, m)),
                    NewItemReminders.always,
                    m,
                  ),
                tile(
                  l10n.notificationsNever,
                  NewItemReminders.never,
                  s.defaultMinutes,
                ),
              ],
            ),
          ),
        );
      },
    );
    if (choice == null) return;
    await _save(
      s.copyWith(newItems: choice.$1, defaultMinutes: choice.$2),
      turnedOn: choice.$1 == NewItemReminders.always,
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
    final newItems = switch (s.newItems) {
      NewItemReminders.ask => l10n.notificationsAsk,
      NewItemReminders.always => reminderLabel(l10n, s.defaultMinutes),
      NewItemReminders.never => l10n.notificationsNever,
    };

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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
