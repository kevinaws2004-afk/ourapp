import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../shared/widgets/settings_group.dart';
import '../domain/pomodoro.dart';
import 'focus_controller.dart';

/// Me → Focus: Pomodoro (work in rounds with breaks: lengths and how
/// often the long break comes) and Do Not Disturb while a timer runs.
class FocusSettingsScreen extends ConsumerStatefulWidget {
  const FocusSettingsScreen({super.key});

  @override
  ConsumerState<FocusSettingsScreen> createState() =>
      _FocusSettingsScreenState();
}

class _FocusSettingsScreenState extends ConsumerState<FocusSettingsScreen> {
  bool? _dndAccess;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Back from the system's Do Not Disturb access screen: look again.
    _lifecycle = AppLifecycleListener(onResume: _checkAccess);
    _checkAccess();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  void _checkAccess() => unawaited(
    ref.read(doNotDisturbProvider).hasAccess().then((ok) {
      if (mounted) setState(() => _dndAccess = ok);
    }),
  );

  Future<void> _pickMinutes(
    String title,
    List<int> choices,
    int current,
    ValueChanged<int> onPicked, {
    String Function(int)? label,
  }) async {
    final l10n = AppLocalizations.of(context);
    final picked = await showModalBottomSheet<int>(
      useRootNavigator: true,
      context: context,
      useSafeArea: true,
      builder: (context) => SingleChildScrollView(
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
                child: Text(title, style: context.textStyles.headlineSmall),
              ),
              for (final n in choices)
                ListTile(
                  title: Text(label?.call(n) ?? l10n.planTimeMinutes(n)),
                  trailing: n == current
                      ? Icon(AppIcons.check, color: context.colors.brandPrimary)
                      : null,
                  onTap: () => Navigator.of(context).pop(n),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final margin = WindowSizeClass.of(context).screenMargin;
    final s = ref.watch(focusSettingsProvider).value ?? FocusSettings.defaults;
    void save(FocusSettings next) => unawaited(saveFocusSettings(ref, next));
    final rounds = s.pomodoro;
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
                title: l10n.focusSettingsTitle,
                subtitle: l10n.focusSettingsSubtitle,
              ),
              SettingsGroup(
                title: l10n.pomodoroTitle,
                children: [
                  SettingsTile(
                    icon: AppIcons.timer,
                    title: l10n.pomodoroSwitch,
                    subtitle: l10n.pomodoroSwitchHint(
                      s.workMinutes,
                      s.shortBreakMinutes,
                    ),
                    trailing: Switch(
                      value: rounds,
                      onChanged: (v) => save(s.copyWith(pomodoro: v)),
                    ),
                  ),
                  SettingsTile(
                    icon: AppIcons.time,
                    iconColor: c.accent,
                    iconBackground: c.accentSoft,
                    title: l10n.pomodoroWork,
                    enabled: rounds,
                    value: l10n.planTimeMinutes(s.workMinutes),
                    onTap: rounds
                        ? () => _pickMinutes(
                            l10n.pomodoroWork,
                            FocusSettings.choicesFor(
                              FocusSettings.workChoices,
                              debug: kDebugMode,
                            ),
                            s.workMinutes,
                            (m) => save(s.copyWith(workMinutes: m)),
                          )
                        : null,
                  ),
                  SettingsTile(
                    icon: AppIcons.breakTime,
                    iconColor: c.success,
                    iconBackground: c.successContainer,
                    title: l10n.pomodoroShortBreak,
                    enabled: rounds,
                    value: l10n.planTimeMinutes(s.shortBreakMinutes),
                    onTap: rounds
                        ? () => _pickMinutes(
                            l10n.pomodoroShortBreak,
                            FocusSettings.choicesFor(
                              FocusSettings.shortBreakChoices,
                              debug: kDebugMode,
                            ),
                            s.shortBreakMinutes,
                            (m) => save(s.copyWith(shortBreakMinutes: m)),
                          )
                        : null,
                  ),
                  SettingsTile(
                    icon: AppIcons.breakTime,
                    iconColor: c.success,
                    iconBackground: c.successContainer,
                    title: l10n.pomodoroLongBreak,
                    enabled: rounds,
                    value: l10n.planTimeMinutes(s.longBreakMinutes),
                    onTap: rounds
                        ? () => _pickMinutes(
                            l10n.pomodoroLongBreak,
                            FocusSettings.choicesFor(
                              FocusSettings.longBreakChoices,
                              debug: kDebugMode,
                            ),
                            s.longBreakMinutes,
                            (m) => save(s.copyWith(longBreakMinutes: m)),
                          )
                        : null,
                  ),
                  SettingsTile(
                    icon: AppIcons.repeat,
                    iconColor: c.textSecondary,
                    iconBackground: c.surfaceSunken,
                    title: l10n.pomodoroLongEvery,
                    enabled: rounds,
                    value: l10n.pomodoroRounds(s.longBreakEvery),
                    onTap: rounds
                        ? () => _pickMinutes(
                            l10n.pomodoroLongEvery,
                            FocusSettings.longEveryChoices,
                            s.longBreakEvery,
                            (m) => save(s.copyWith(longBreakEvery: m)),
                            label: l10n.pomodoroRounds,
                          )
                        : null,
                  ),
                ],
              ),
              SettingsGroup(
                title: l10n.dndTitle,
                children: [
                  SettingsTile(
                    icon: AppIcons.doNotDisturb,
                    iconColor: c.warning,
                    iconBackground: c.warningContainer,
                    title: l10n.dndSwitch,
                    subtitle: _dndAccess == false && s.doNotDisturb
                        ? l10n.dndNeedsAccess
                        : l10n.dndSwitchHint,
                    trailing: Switch(
                      value: s.doNotDisturb,
                      onChanged: (v) async {
                        save(s.copyWith(doNotDisturb: v));
                        if (v && _dndAccess != true) {
                          await ref.read(doNotDisturbProvider).requestAccess();
                        }
                      },
                    ),
                    onTap: _dndAccess == false && s.doNotDisturb
                        ? () => unawaited(
                            ref.read(doNotDisturbProvider).requestAccess(),
                          )
                        : null,
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

/// Pomodoro and Do Not Disturb as two chips on the full-screen timer, for
/// switching them without leaving it.
class FocusQuickToggles extends ConsumerWidget {
  const FocusQuickToggles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final s = ref.watch(focusSettingsProvider).value ?? FocusSettings.defaults;
    return Wrap(
      spacing: AppSpacing.sm,
      alignment: WrapAlignment.center,
      children: [
        FilterChip(
          avatar: const Icon(AppIcons.timer, size: 18),
          label: Text(l10n.pomodoroChip(s.workMinutes)),
          selected: s.pomodoro,
          onSelected: (v) =>
              unawaited(saveFocusSettings(ref, s.copyWith(pomodoro: v))),
        ),
        FilterChip(
          avatar: const Icon(AppIcons.doNotDisturb, size: 18),
          label: Text(l10n.dndChip),
          selected: s.doNotDisturb,
          onSelected: (v) async {
            await saveFocusSettings(ref, s.copyWith(doNotDisturb: v));
            final dnd = ref.read(doNotDisturbProvider);
            if (v && !await dnd.hasAccess()) await dnd.requestAccess();
          },
        ),
      ],
    );
  }
}
