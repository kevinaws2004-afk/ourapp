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
import '../../../core/platform/app_blocker.dart';
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
  bool? _blockerOn;
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

  void _checkAccess() {
    unawaited(
      ref.read(doNotDisturbProvider).hasAccess().then((ok) {
        if (mounted) setState(() => _dndAccess = ok);
      }),
    );
    unawaited(
      ref.read(appBlockerProvider).isEnabled().then((on) {
        if (!mounted) return;
        final justTurnedOn = on && _blockerOn == false;
        setState(() => _blockerOn = on);
        // Back from Accessibility settings with it on: choose the apps.
        final s = ref.read(focusSettingsProvider).value;
        if (justTurnedOn && s != null && s.blockApps && s.blockedApps.isEmpty) {
          unawaited(_pickApps(s));
        }
      }),
    );
  }

  /// Turning blocking on: the Accessibility service needs the person's
  /// informed consent first (prominent disclosure), then the system switch.
  Future<void> _turnBlockingOn(FocusSettings s) async {
    final l10n = AppLocalizations.of(context);
    if (_blockerOn != true) {
      final agreed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.blockDisclosureTitle),
          content: SingleChildScrollView(child: Text(l10n.blockDisclosureBody)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.blockDisclosureCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.blockDisclosureAgree),
            ),
          ],
        ),
      );
      if (agreed != true || !mounted) return;
      await ref.read(appBlockerProvider).openSettings();
    }
    await saveFocusSettings(ref, s.copyWith(blockApps: true));
    if (s.blockedApps.isEmpty && mounted && _blockerOn == true) {
      await _pickApps(s.copyWith(blockApps: true));
    }
  }

  Future<void> _pickApps(FocusSettings s) async {
    final apps = await ref.read(appBlockerProvider).apps();
    if (!mounted) return;
    final chosen = await showModalBottomSheet<List<String>>(
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (context) =>
          _AppPicker(apps: apps, initial: s.blockedApps.toSet()),
    );
    if (chosen == null) return;
    await saveFocusSettings(ref, s.copyWith(blockedApps: chosen));
  }

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
                title: l10n.blockTitle,
                children: [
                  SettingsTile(
                    icon: AppIcons.locked,
                    iconColor: c.danger,
                    iconBackground: c.dangerContainer,
                    title: l10n.blockSwitch,
                    subtitle: s.blockApps && _blockerOn == false
                        ? l10n.blockNeedsService
                        : l10n.blockSwitchHint,
                    trailing: Switch(
                      value: s.blockApps,
                      onChanged: (v) => v
                          ? unawaited(_turnBlockingOn(s))
                          : save(s.copyWith(blockApps: false)),
                    ),
                    onTap: s.blockApps && _blockerOn == false
                        ? () => unawaited(
                            ref.read(appBlockerProvider).openSettings(),
                          )
                        : null,
                  ),
                  SettingsTile(
                    icon: AppIcons.activities,
                    iconColor: c.textSecondary,
                    iconBackground: c.surfaceSunken,
                    title: l10n.blockApps,
                    enabled: s.blockApps,
                    value: s.blockedApps.isEmpty
                        ? l10n.blockAppsNone
                        : l10n.blockAppsCount(s.blockedApps.length),
                    onTap: s.blockApps ? () => unawaited(_pickApps(s)) : null,
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

/// Choosing the apps to block: every app with an icon, searchable.
class _AppPicker extends StatefulWidget {
  const _AppPicker({required this.apps, required this.initial});

  final List<LaunchableApp> apps;
  final Set<String> initial;

  @override
  State<_AppPicker> createState() => _AppPickerState();
}

class _AppPickerState extends State<_AppPicker> {
  late final Set<String> _chosen = {...widget.initial};
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final q = _query.trim().toLowerCase();
    final shown =
        [
          for (final a in widget.apps)
            if (q.isEmpty || a.label.toLowerCase().contains(q)) a,
        ]..sort((a, b) {
          // Chosen first, so they're easy to review.
          final ca = _chosen.contains(a.package) ? 0 : 1;
          final cb = _chosen.contains(b.package) ? 0 : 1;
          return ca != cb ? ca - cb : a.label.compareTo(b.label);
        });
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.85,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.blockApps,
                    style: context.textStyles.headlineSmall,
                  ),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, _chosen.toList()),
                  child: Text(l10n.blockAppsDone),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.blockAppsSearch,
                prefixIcon: const Icon(AppIcons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: ListView(
              children: [
                for (final a in shown)
                  CheckboxListTile(
                    value: _chosen.contains(a.package),
                    title: Text(a.label),
                    onChanged: (v) => setState(
                      () => v == true
                          ? _chosen.add(a.package)
                          : _chosen.remove(a.package),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
