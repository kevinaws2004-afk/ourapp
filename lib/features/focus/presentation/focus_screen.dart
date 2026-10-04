import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
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
import '../../../shared/widgets/state_views.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../domain/focus_session.dart';
import 'focus_providers.dart';

/// `1:02:05` / `42:07`: hours only when needed, digits in DM Mono (ADR-032).
String formatTimer(int milliseconds) {
  final total = milliseconds ~/ 1000;
  final h = total ~/ 3600;
  final m = (total % 3600) ~/ 60;
  final s = total % 60;
  String two(int v) => v.toString().padLeft(2, '0');
  return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
}

/// The full-screen focus timer (§16, §17; FR-FO-01…06). It reads the active
/// session from SQLite, so it shows the right time after the app was killed.
/// [onFinish] opens the record form that finishes the session.
class FocusScreen extends ConsumerWidget {
  const FocusScreen({super.key, required this.onFinish});

  final Future<void> Function(FocusSession session) onFinish;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: AsyncValueView<FocusSession?>(
        value: ref.watch(activeFocusSessionProvider),
        onRetry: () => ref.invalidate(activeFocusSessionProvider),
        data: (session) => session == null
            ? AppEmptyState(
                icon: AppIcons.timer,
                title: l10n.focusNoneTitle,
                message: l10n.focusNoneMessage,
              )
            : _FocusBody(session: session, onFinish: onFinish),
      ),
    );
  }
}

class _FocusBody extends ConsumerWidget {
  const _FocusBody({required this.session, required this.onFinish});

  final FocusSession session;
  final Future<void> Function(FocusSession session) onFinish;

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
    await _run(
      context,
      () => ref.read(discardFocusSessionProvider)(session.id),
    );
    if (context.mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final margin = WindowSizeClass.of(context).screenMargin;
    ref.watch(focusTickProvider); // repaint every second
    final now = ref.watch(clockProvider).nowUtc();
    final type = ref.watch(activityTypeProvider(session.activityTypeId)).value;
    final paused = session.state == FocusState.paused;
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
            Semantics(
              liveRegion: false,
              label: l10n.focusElapsedLabel,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  formatTimer(session.elapsedMs(now)),
                  textAlign: TextAlign.center,
                  style: AppTypography.numericHero.copyWith(
                    color: paused
                        ? context.colors.textSecondary
                        : context.colors.textPrimary,
                  ),
                ),
              ),
            ),
            Text(
              paused ? l10n.focusPaused : l10n.focusRunning,
              textAlign: TextAlign.center,
              style: context.textStyles.labelMedium?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const Spacer(),
            AppButton(
              label: paused ? l10n.focusResume : l10n.focusPause,
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
                // Freeze the time while the user fills in the record.
                await ref.read(pauseFocusSessionProvider)(session.id);
                await onFinish(session);
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
