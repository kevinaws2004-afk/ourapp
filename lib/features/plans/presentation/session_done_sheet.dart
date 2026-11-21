import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/activity_palette.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/tokens/typography.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/activity_badge.dart';
import '../../../shared/widgets/progress_ring.dart';
import '../../activity_logs/presentation/value_formatting.dart';
import '../../activity_types/domain/activity_type.dart';

/// The end of a timed session (peak-end): the ring fills, "+45 min", the
/// day's total and the streak. Closes itself after a few seconds.
Future<void> showSessionDone(
  BuildContext context, {
  required String title,
  required ActivityType? type,
  required int sessionMs,
  required int todayMs,
  int? streakDays,
}) async {
  unawaited(HapticFeedback.mediumImpact());
  final navigator = Navigator.of(context, rootNavigator: true);
  // Shown from the app's own overlay a moment later: the screen it was
  // finished from (the focus timer) closes itself first.
  final host = navigator.overlay?.context;
  if (host == null) return;
  await Future<void>.delayed(const Duration(milliseconds: 450));
  if (!host.mounted) return;
  var open = true;
  final closed = showModalBottomSheet<void>(
    context: host,
    useRootNavigator: true,
    builder: (_) => _SessionDone(
      title: title,
      type: type,
      sessionMs: sessionMs,
      todayMs: todayMs,
      streakDays: streakDays,
    ),
  ).whenComplete(() => open = false);
  unawaited(
    Future<void>.delayed(const Duration(seconds: 5), () {
      if (open && navigator.mounted) navigator.pop();
    }),
  );
  return closed;
}

class _SessionDone extends StatelessWidget {
  const _SessionDone({
    required this.title,
    required this.type,
    required this.sessionMs,
    required this.todayMs,
    required this.streakDays,
  });

  final String title;
  final ActivityType? type;
  final int sessionMs;
  final int todayMs;
  final int? streakDays;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final type = this.type;
    final color = type == null
        ? c.action
        : context.tokens
              .activity(
                ActivityColorKey.fromName(type.colorKey) ??
                    ActivityColorKey.slate,
              )
              .solid;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.md,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1100),
              curve: Curves.easeOutCubic,
              builder: (context, t, _) => ProgressRing(
                fraction: t,
                size: 132,
                stroke: 10,
                color: color,
                semanticLabel: l10n.sessionDoneTitle(title),
                child: type == null
                    ? Icon(AppIcons.check, size: 40, color: color)
                    : ActivityBadge(
                        iconId: type.iconId,
                        colorKey: type.colorKey,
                        size: 56,
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.sessionDoneTitle(title),
              textAlign: TextAlign.center,
              style: context.textStyles.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.sessionDoneTime(formatDuration(l10n, sessionMs)),
              style: AppTypography.numericLarge.copyWith(color: color),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSpacing.md,
              children: [
                Text(
                  l10n.sessionDoneToday(formatDuration(l10n, todayMs)),
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: c.textSecondary,
                  ),
                ),
                if ((streakDays ?? 0) > 1)
                  Text(
                    '🔥 $streakDays',
                    style: context.textStyles.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.sessionDoneClose),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
