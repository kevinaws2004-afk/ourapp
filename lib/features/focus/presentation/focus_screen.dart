import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/database/json_preferences.dart';
import '../../../core/platform/focus_mode.dart';
import '../../../core/platform/focus_sound.dart';
import '../../../core/design/tokens/sizes.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/tokens/typography.dart';
import '../../../core/design/window_size_class.dart';
import '../../../core/time/clock_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/errors/error_copy.dart';
import '../../../shared/widgets/activity_badge.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/progress_ring.dart';
import '../../../shared/widgets/state_views.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../domain/focus_session.dart';
import '../../activity_logs/presentation/value_formatting.dart';
import '../../plans/presentation/plan_actions.dart';
import '../../plans/presentation/plan_date_notifier.dart';
import '../../plans/presentation/plan_providers.dart';
import 'focus_providers.dart';
import 'focus_settings_screen.dart';
import 'pomodoro_line.dart';

/// `1:02:05` / `42:07`: hours only when needed, digits in DM Mono (ADR-032).
String formatTimer(int milliseconds) {
  final total = milliseconds ~/ 1000;
  final h = total ~/ 3600;
  final m = (total % 3600) ~/ 60;
  final s = total % 60;
  String two(int v) => v.toString().padLeft(2, '0');
  return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
}

/// A session's line on a row: "Running · 12:04", or "Paused · 15:00".
/// With [short] (next to a "Running" chip), a running session is just its
/// time.
String sessionLine(
  AppLocalizations l10n,
  FocusSession session,
  DateTime now, {
  bool short = false,
}) {
  final time = formatTimer(session.elapsedMs(now));
  // Short lines sit next to a Paused / In progress chip that says the rest.
  if (short) return time;
  if (session.state == FocusState.paused) return l10n.itemPausedLine(time);
  return l10n.itemRunning(time);
}

/// The full-screen focus timer (§16, §17; FR-FO-01…06). It reads the active
/// session from SQLite, so it shows the right time after the app was killed.
/// Finish records the session into its item (ADR-035), with the session
/// summary, then closes.
///
/// In **focus mode** ([focusMode]) the phone stays on this screen: the app
/// is pinned (Android's app pinning), the system bars are hidden, the
/// screen stays on, and Back asks first. **End focus mode** unpins (the
/// timer keeps running); Finish and Discard end it too.
class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key, this.focusMode = false});

  final bool focusMode;

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  static const _platform = FocusModePlatform();
  late bool _locked = widget.focusMode;

  /// Whether Android has really pinned the app. Asking isn't enough: the
  /// person confirms (or declines) Android's prompt, and can unpin any time.
  bool _pinned = false;
  Timer? _pinCheck;

  /// The last session shown: kept on screen while Finish or Discard
  /// completes (the session is gone by then), and to close afterwards.
  FocusSession? _last;

  /// Finish or Discard is running here; it closes the screen itself.
  bool _busy = false;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    if (_locked) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => unawaited(_headsUpThenLock()),
      );
    }
  }

  /// The first time: says what Android's pinning prompt is about, so its
  /// wording doesn't scare anyone off.
  Future<void> _headsUpThenLock() async {
    const key = 'focusPinHeadsUpSeen';
    final prefs = ref.read(jsonPreferencesProvider);
    if (await prefs.read(key) != true && mounted) {
      final l10n = AppLocalizations.of(context);
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: const Icon(AppIcons.lock),
          title: Text(l10n.focusPinHeadsUpTitle),
          content: Text(l10n.focusPinHeadsUpBody),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.focusPinHeadsUpGo),
            ),
          ],
        ),
      );
      await prefs.write(key, true);
    }
    if (mounted && _locked) await _lock();
  }

  Future<void> _lock() async {
    unawaited(
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky),
    );
    await _platform.start();
    _pinCheck = Timer.periodic(const Duration(seconds: 1), (_) async {
      final pinned = await _platform.isPinned();
      if (mounted && _locked && pinned != _pinned) {
        setState(() => _pinned = pinned);
      }
    });
  }

  Future<void> _unlock() async {
    if (!_locked) return;
    _locked = false;
    _pinCheck?.cancel();
    await _platform.stop();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (!mounted) return;
    setState(() => _pinned = false);
    // Let Back through (PopScope) before anything closes this screen.
    await WidgetsBinding.instance.endOfFrame;
  }

  /// The background sound playing now (null: none).
  FocusSound? _playing;

  /// Plays the chosen sound while the timer runs, silent when paused.
  void _syncSound(FocusSession? session) {
    final chosen = ref.watch(focusSoundProvider).value ?? FocusSound.off;
    final want = session != null && session.state == FocusState.running
        ? chosen
        : FocusSound.off;
    if (want == (_playing ?? FocusSound.off)) return;
    _playing = want == FocusSound.off ? null : want;
    unawaited(const FocusSoundPlayer().play(want));
  }

  @override
  void dispose() {
    if (_playing != null) unawaited(const FocusSoundPlayer().stop());
    _pinCheck?.cancel();
    if (_locked) {
      unawaited(_platform.stop());
      unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    }
    super.dispose();
  }

  /// Asks, then leaves focus mode (and this screen).
  Future<void> _end() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.focusModeEndTitle),
        content: Text(l10n.focusModeEndBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.focusModeEnd),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.focusModeKeepGoing),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await _unlock();
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(activeFocusSessionProvider);
    if (session.value case final current?) _last = current;
    _syncSound(session.value);
    // Finished or discarded somewhere else (the notification, Today):
    // unlock and close. Here, Finish and Discard close it themselves.
    if (session.hasValue &&
        session.value == null &&
        _last != null &&
        !_busy &&
        !_closing) {
      _closing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _unlock();
        if (context.mounted) Navigator.of(context).maybePop();
      });
    }
    return PopScope(
      canPop: !_locked,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_end());
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: !_locked,
          title: _locked
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppIcons.lock,
                      size: 18,
                      color: context.colors.brandPrimary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        _pinned
                            ? l10n.focusModeBadge
                            : l10n.focusModeBadgeUnpinned,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.labelLarge?.copyWith(
                          color: context.colors.brandPrimary,
                        ),
                      ),
                    ),
                  ],
                )
              : null,
          actions: [
            if (_locked)
              TextButton(onPressed: _end, child: Text(l10n.focusModeEnd)),
          ],
        ),
        body: AsyncValueView<FocusSession?>(
          value: session,
          onRetry: () => ref.invalidate(activeFocusSessionProvider),
          data: (session) => switch (session ?? _last) {
            null => AppEmptyState(
              icon: AppIcons.timer,
              title: l10n.focusNoneTitle,
              message: l10n.focusNoneMessage,
            ),
            final shown => _FocusBody(
              session: shown,
              onLeave: _unlock,
              onBusy: (busy) => _busy = busy,
            ),
          },
        ),
      ),
    );
  }
}

class _FocusBody extends ConsumerWidget {
  const _FocusBody({
    required this.session,
    required this.onLeave,
    required this.onBusy,
  });

  final FocusSession session;

  /// Finish or Discard started (true) or ended (false): the screen stays
  /// up for it, showing this session, and is closed by it.
  final ValueChanged<bool> onBusy;

  /// Ends focus mode before the screen closes (Finish, Discard).
  final Future<void> Function() onLeave;

  Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      await action();
    } catch (error) {
      if (context.mounted) {
        showMessageSnackBar(context, errorMessage(l10n, error));
      }
    }
  }

  Future<void> _discard(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    // Discarding throws the timed session away: confirm (irreversible).
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.focusDiscardTitle),
        content: Text(l10n.focusDiscardMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionKeepEditing),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.actionDiscard),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    onBusy(true);
    try {
      await _run(
        context,
        () => ref.read(discardFocusSessionProvider)(session.id),
      );
      await onLeave();
      if (context.mounted) Navigator.of(context).maybePop();
    } finally {
      onBusy(false);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final margin = WindowSizeClass.of(context).screenMargin;
    ref.watch(focusTickProvider); // repaint every second
    final now = ref.watch(clockProvider).nowUtc();
    final type = ref.watch(activityTypeProvider(session.activityTypeId)).value;
    final paused = session.state == FocusState.paused;
    // Its plan's length, for the ring and the time left.
    final plannedMs = ref
        .watch(dayOverviewProvider(currentLocalDate(ref.watch(clockProvider))))
        .value
        ?.planned
        .where((i) => i.plan.id == session.planId)
        .firstOrNull
        ?.plan
        .plannedLengthMs;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: margin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            if (type != null)
              Center(
                child: ActivityBadge(
                  iconId: type.iconId,
                  colorKey: type.colorKey,
                  size: AppSizes.badgeHero,
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              type?.name ?? '',
              textAlign: TextAlign.center,
              style: context.textStyles.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xl),
            _TimerWithRing(
              elapsedMs: session.elapsedMs(now),
              plannedMs: plannedMs,
              paused: paused,
            ),
            Text(
              paused ? l10n.focusPaused : l10n.focusRunning,
              textAlign: TextAlign.center,
              style: context.textStyles.labelMedium?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            PomodoroLine(session: session, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            const Center(child: FocusQuickToggles()),
            const Spacer(),
            AppButton(
              label: paused
                  ? resumeLabel(l10n, currentPomodoroView(ref, session))
                  : l10n.focusPause,
              icon: paused ? AppIcons.start : AppIcons.pause,
              onPressed: () => _run(
                context,
                () => paused
                    ? ref.read(resumeFocusSessionProvider)(session.id)
                    : ref.read(pauseFocusSessionProvider)(session.id),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: l10n.focusFinish,
              variant: AppButtonVariant.secondary,
              icon: AppIcons.check,
              onPressed: () => _run(context, () async {
                onBusy(true);
                try {
                  // Freeze the time while the user fills in the record.
                  await ref.read(pauseFocusSessionProvider)(session.id);
                  if (!context.mounted) return;
                  await onLeave();
                  if (!context.mounted) return;
                  await PlanActions(
                    context,
                    ref,
                  ).finish(session, title: type?.name ?? '', type: type);
                  if (context.mounted) Navigator.of(context).maybePop();
                } finally {
                  onBusy(false);
                }
              }),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.focusDiscard,
              variant: AppButtonVariant.tertiary,
              onPressed: () => _discard(context, ref),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

/// The big timer. With a planned length: inside a ring that fills up, with
/// the time left under it.
class _TimerWithRing extends StatelessWidget {
  const _TimerWithRing({
    required this.elapsedMs,
    required this.plannedMs,
    required this.paused,
  });

  final int elapsedMs;
  final int? plannedMs;
  final bool paused;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final time = Text(
      formatTimer(elapsedMs),
      textAlign: TextAlign.center,
      style: AppTypography.numericHero.copyWith(
        color: paused ? c.textSecondary : c.textPrimary,
      ),
    );
    final planned = plannedMs;
    if (planned == null || planned <= 0) {
      return Semantics(
        label: l10n.focusElapsedLabel,
        child: FittedBox(fit: BoxFit.scaleDown, child: time),
      );
    }
    final reached = elapsedMs >= planned;
    final left = planned - elapsedMs;
    final size = math.min(MediaQuery.sizeOf(context).width * 0.7, 280.0);
    return Column(
      children: [
        Center(
          child: ProgressRing(
            fraction: elapsedMs / planned,
            size: size,
            stroke: 12,
            color: reached ? c.action : null,
            semanticLabel: l10n.focusElapsedLabel,
            child: time,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          reached
              ? l10n.focusPlannedReached(formatDuration(l10n, planned))
              : l10n.focusTimeLeft(
                  // Rounded up: "1 min left" until it's really over.
                  formatDuration(l10n, ((left + 59999) ~/ 60000) * 60000),
                  formatDuration(l10n, planned),
                ),
          textAlign: TextAlign.center,
          style: context.textStyles.titleSmall?.copyWith(
            color: reached ? c.action : c.textSecondary,
          ),
        ),
      ],
    );
  }
}
