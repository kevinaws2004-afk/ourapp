import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/activity_badge.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../plans/presentation/plan_providers.dart';

/// What the center **+** offers, from any tab (spec §37, fast logging):
/// start one of your activities right now in one tap, or plan something,
/// record a body measurement, or make a new activity.
class QuickStartActions {
  const QuickStartActions({
    required this.startActivity,
    required this.planSomething,
    required this.measure,
    required this.newActivity,
    required this.writeNote,
  });

  /// Starts [type] now (its timer, when it has one) and opens it.
  final void Function(BuildContext context, ActivityType type) startActivity;
  final void Function(BuildContext context) planSomething;
  final void Function(BuildContext context) measure;
  final void Function(BuildContext context) newActivity;
  final void Function(BuildContext context) writeNote;
}

Future<void> showQuickStartSheet(
  BuildContext context,
  QuickStartActions actions,
) {
  unawaited(HapticFeedback.selectionClick());
  return showModalBottomSheet<void>(
    useRootNavigator: true,
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => _QuickStart(
      actions: actions,
      // Every action runs from the page under the sheet once it's closed.
      close: () => Navigator.of(sheetContext).pop(),
      host: context,
    ),
  );
}

class _QuickStart extends ConsumerWidget {
  const _QuickStart({
    required this.actions,
    required this.close,
    required this.host,
  });

  final QuickStartActions actions;
  final VoidCallback close;
  final BuildContext host;

  static const _maxActivities = 8;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final types = ref
        .watch(recentActivityTypesProvider)
        .take(_maxActivities)
        .toList();
    void run(void Function() action) {
      close();
      action();
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
            Text(l10n.quickTitle, style: context.textStyles.headlineSmall),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              l10n.quickSubtitle,
              style: context.textStyles.bodyMedium?.copyWith(
                color: c.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (types.isNotEmpty) ...[
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 0.72,
                children: [
                  for (final type in types)
                    _ActivityTile(
                      type: type,
                      onTap: () => run(() => actions.startActivity(host, type)),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
            _ActionRow(
              icon: AppIcons.planNext,
              title: l10n.quickPlan,
              subtitle: l10n.quickPlanHint,
              onTap: () => run(() => actions.planSomething(host)),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ActionRow(
              icon: AppIcons.notes.outline,
              title: l10n.quickNote,
              subtitle: l10n.quickNoteHint,
              onTap: () => run(() => actions.writeNote(host)),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ActionRow(
              icon: AppIcons.measurements,
              title: l10n.quickMeasure,
              subtitle: l10n.quickMeasureHint,
              onTap: () => run(() => actions.measure(host)),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ActionRow(
              icon: AppIcons.addCircle,
              title: l10n.quickNewActivity,
              subtitle: l10n.quickNewActivityHint,
              onTap: () => run(() => actions.newActivity(host)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.type, required this.onTap});

  final ActivityType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.quickStartActivity(type.name),
      excludeSemantics: true,
      child: InkWell(
        borderRadius: AppRadius.lgAll,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ActivityBadge(
              iconId: type.iconId,
              colorKey: type.colorKey,
              size: 56,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              type.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.textStyles.labelMedium?.copyWith(height: 1.15),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.surfaceSunken,
      borderRadius: AppRadius.lgAll,
      child: InkWell(
        borderRadius: AppRadius.lgAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: c.surfaceBase,
                  borderRadius: AppRadius.smAll,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 20, color: c.brandPrimary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.textStyles.titleMedium),
                    Text(
                      subtitle,
                      style: context.textStyles.bodySmall?.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(AppIcons.chevron, size: 18, color: c.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
