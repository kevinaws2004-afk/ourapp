import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/activity_palette.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/tokens/typography.dart';
import '../../../core/time/clock_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/activity_badge.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../domain/focus_session.dart';
import 'focus_providers.dart';
import 'focus_screen.dart';

/// The live item for a running focus session (ui_guidelines.md §4.1:
/// "Reading · 23:14 · Return"). Hidden when nothing is running.
class FocusBanner extends ConsumerWidget {
  const FocusBanner({super.key, required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(activeFocusSessionProvider).value;
    if (session == null) return const SizedBox.shrink();
    ref.watch(focusTickProvider);
    final l10n = AppLocalizations.of(context);
    final now = ref.watch(clockProvider).nowUtc();
    final type = ref.watch(activityTypeProvider(session.activityTypeId)).value;
    if (type == null) return const SizedBox.shrink();
    final colors = context.tokens.activity(
      ActivityColorKey.fromName(type.colorKey) ?? ActivityColorKey.slate,
    );
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Material(
        color: colors.soft,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                ActivityBadge(iconId: type.iconId, colorKey: type.colorKey),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(type.name, style: context.textStyles.titleMedium),
                ),
                Text(
                  formatTimer(session.elapsedMs(now)),
                  style: AppTypography.numericMedium.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                TextButton(onPressed: onOpen, child: Text(l10n.focusReturn)),
                const Icon(AppIcons.chevron),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A slim bar above the tabs while a timer runs, so it stays in sight on
/// every tab: activity, time, pause / resume; tap to open it.
class RunningTimerBar extends ConsumerWidget {
  const RunningTimerBar({super.key, required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(activeFocusSessionProvider).value;
    if (session == null) return const SizedBox.shrink();
    ref.watch(focusTickProvider);
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final now = ref.watch(clockProvider).nowUtc();
    final type = ref.watch(activityTypeProvider(session.activityTypeId)).value;
    if (type == null) return const SizedBox.shrink();
    final colors = context.tokens.activity(
      ActivityColorKey.fromName(type.colorKey) ?? ActivityColorKey.slate,
    );
    final paused = session.state == FocusState.paused;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Material(
        color: colors.soft,
        borderRadius: AppRadius.pillAll,
        child: InkWell(
          borderRadius: AppRadius.pillAll,
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xs,
              AppSpacing.xs,
              AppSpacing.xs,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                ActivityBadge(
                  iconId: type.iconId,
                  colorKey: type.colorKey,
                  size: 32,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    paused ? '${type.name} · ${l10n.focusPaused}' : type.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.titleSmall?.copyWith(
                      color: c.textPrimary,
                    ),
                  ),
                ),
                Text(
                  formatTimer(session.elapsedMs(now)),
                  style: AppTypography.numericMedium.copyWith(
                    fontSize: 16,
                    color: c.textPrimary,
                  ),
                ),
                IconButton(
                  tooltip: paused ? l10n.focusResume : l10n.focusPause,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(paused ? AppIcons.start : AppIcons.pause),
                  color: colors.solid,
                  onPressed: () => paused
                      ? ref.read(resumeFocusSessionProvider)(session.id)
                      : ref.read(pauseFocusSessionProvider)(session.id),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
