import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/time/clock_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../domain/focus_session.dart';
import '../domain/pomodoro.dart';
import 'focus_controller.dart';
import 'focus_providers.dart';
import 'focus_screen.dart';

/// Under a running timer with Pomodoro on: "Round 2 · 12:34 to a break",
/// "Break · 03:12 left", or "Break's over — ready for round 3?". Nothing
/// when Pomodoro is off.
class PomodoroLine extends ConsumerWidget {
  const PomodoroLine({
    super.key,
    required this.session,
    this.textAlign = TextAlign.start,
    this.showToggle = true,
  });

  final FocusSession session;
  final TextAlign textAlign;

  /// The "rounds on/off for this activity" switch (not on Today's card).
  final bool showToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(focusTickProvider);
    final settings =
        ref.watch(focusSettingsProvider).value ?? FocusSettings.defaults;
    if (!settings.pomodoro) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final activity =
        ref
            .watch(activeActivityTypesProvider)
            .value
            ?.where((t) => t.id == session.activityTypeId)
            .firstOrNull
            ?.name ??
        '';
    // Rounds on or off for this activity (remembered for it).
    Widget toggle({required bool on}) => Align(
      alignment: textAlign == TextAlign.center
          ? Alignment.center
          : Alignment.centerLeft,
      child: TextButton(
        style: TextButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          foregroundColor: c.textSecondary,
          textStyle: context.textStyles.labelMedium,
        ),
        onPressed: () => unawaited(
          saveFocusSettings(
            ref,
            settings.withRoundsFor(session.activityTypeId.value, on: on),
          ),
        ),
        child: Text(
          on
              ? l10n.pomodoroRoundsOnFor(settings.workMinutes, activity)
              : l10n.pomodoroRoundsOffFor(activity),
        ),
      ),
    );
    final view = currentPomodoroView(ref, session);
    if (view == null) {
      return showToggle &&
              session.state == FocusState.running &&
              !sessionUsesRounds(ref, session)
          ? toggle(on: true)
          : const SizedBox.shrink();
    }
    final (icon, color, text) = switch (view) {
      PomodoroWorking(:final round, :final leftMs) => (
        AppIcons.timer,
        c.brandPrimary,
        l10n.pomodoroRound(round, formatTimer(leftMs)),
      ),
      PomodoroOnBreak(:final round, isOver: true) => (
        AppIcons.start,
        c.success,
        l10n.pomodoroBreakOver(round + 1),
      ),
      PomodoroOnBreak(:final leftMs) => (
        AppIcons.breakTime,
        c.success,
        l10n.pomodoroBreak(formatTimer(leftMs)),
      ),
    };
    final line = Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: textAlign == TextAlign.center
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              text,
              textAlign: textAlign,
              style: context.textStyles.labelLarge?.copyWith(
                color: c.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
    if (view is! PomodoroWorking || !showToggle) return line;
    return Column(
      crossAxisAlignment: textAlign == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [line, toggle(on: false)],
    );
  }
}

/// Whether Pomodoro rounds apply to [session]'s activity now.
bool sessionUsesRounds(WidgetRef ref, FocusSession session) {
  final settings =
      ref.watch(focusSettingsProvider).value ?? FocusSettings.defaults;
  final type = ref
      .watch(activeActivityTypesProvider)
      .value
      ?.where((t) => t.id == session.activityTypeId)
      .firstOrNull;
  return settings.roundsFor(session.activityTypeId.value, type?.iconId);
}

/// [session]'s Pomodoro state now, or null.
PomodoroView? currentPomodoroView(WidgetRef ref, FocusSession session) =>
    pomodoroViewOf(
      session,
      ref.watch(focusSettingsProvider).value ?? FocusSettings.defaults,
      ref.watch(pomodoroStateProvider).value,
      ref.watch(clockProvider).nowUtc(),
      usesRounds: sessionUsesRounds(ref, session),
    );

/// The resume button's words: "Start round 3" after a break, else Resume.
String resumeLabel(AppLocalizations l10n, PomodoroView? view) => switch (view) {
  PomodoroOnBreak(:final round, isOver: true) => l10n.pomodoroStartRound(
    round + 1,
  ),
  PomodoroOnBreak() => l10n.pomodoroSkipBreak,
  _ => l10n.focusResume,
};
