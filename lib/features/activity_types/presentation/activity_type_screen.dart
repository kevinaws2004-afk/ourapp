import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/errors/error_copy.dart';
import '../../../shared/widgets/activity_badge.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/state_views.dart';
import '../../activity_logs/domain/activity_log.dart';
import '../../activity_logs/presentation/activity_log_providers.dart';
import '../../activity_logs/presentation/value_formatting.dart';
import '../domain/activity_ids.dart';
import '../domain/activity_type.dart';
import 'activity_type_providers.dart';

/// One activity: log it, edit or delete it, and see its recent history.
class ActivityTypeScreen extends ConsumerWidget {
  const ActivityTypeScreen({
    super.key,
    required this.typeId,
    required this.onLog,
    required this.onEdit,
    required this.onOpenLog,
  });

  final ActivityTypeId typeId;
  final VoidCallback onLog;
  final VoidCallback onEdit;
  final ValueChanged<ActivityLog> onOpenLog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final type = ref.watch(activityTypeProvider(typeId));
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: l10n.actionEdit,
            icon: const Icon(AppIcons.edit),
            onPressed: onEdit,
          ),
          IconButton(
            tooltip: l10n.actionDelete,
            icon: const Icon(AppIcons.delete),
            onPressed: () => _delete(context, ref, type.value),
          ),
        ],
      ),
      body: AsyncValueView(
        value: type,
        onRetry: () => ref.invalidate(activityTypeProvider(typeId)),
        data: (type) => type == null || type.isDeleted
            ? const AppErrorState(
                error: NotFoundException(debugContext: 'activity type'),
              )
            : _Body(type: type, onLog: onLog, onOpenLog: onOpenLog),
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    ActivityType? type,
  ) async {
    if (type == null) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final restore = ref.read(restoreActivityTypeProvider);
    try {
      await ref.read(deleteActivityTypeProvider)(type.id);
    } catch (error) {
      if (context.mounted) {
        showMessageSnackBar(context, errorMessage(l10n, error));
      }
      return;
    }
    if (!context.mounted) return;
    Navigator.of(context).pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.activityArchived(type.name)),
          action: SnackBarAction(
            label: l10n.actionUndo,
            onPressed: () => unawaited(restore(type.id)),
          ),
        ),
      );
  }
}

class _Body extends ConsumerWidget {
  const _Body({
    required this.type,
    required this.onLog,
    required this.onOpenLog,
  });

  final ActivityType type;
  final VoidCallback onLog;
  final ValueChanged<ActivityLog> onOpenLog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final margin = WindowSizeClass.of(context).screenMargin;
    final logs = ref.watch(logsForTypeProvider(type.id));
    final material = MaterialLocalizations.of(context);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppContentWidth.list),
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            margin,
            AppSpacing.sm,
            margin,
            AppSpacing.huge,
          ),
          children: [
            Row(
              children: [
                ActivityBadge(
                  iconId: type.iconId,
                  colorKey: type.colorKey,
                  size: 56,
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Text(
                    type.name,
                    style: context.textStyles.headlineLarge,
                  ),
                ),
              ],
            ),
            if (type.description != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                type.description!,
                style: context.textStyles.bodyLarge?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
            AppButton(label: l10n.actionRecord, onPressed: onLog),
            SectionHeader(title: l10n.recentEntries),
            AsyncValueView(
              value: logs,
              onRetry: () => ref.invalidate(logsForTypeProvider(type.id)),
              data: (logs) => logs.isEmpty
                  ? Text(
                      l10n.noEntriesYet,
                      style: context.textStyles.bodyLarge?.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    )
                  : Column(
                      children: [
                        for (final log in logs)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              [
                                material.formatMediumDate(
                                  log.startedAt.toLocal(),
                                ),
                                material.formatTimeOfDay(
                                  TimeOfDay.fromDateTime(
                                    log.startedAt.toLocal(),
                                  ),
                                ),
                                if (log.durationMs != null)
                                  formatDuration(l10n, log.durationMs!),
                              ].join(' · '),
                            ),
                            subtitle: Text(summarizeLog(context, type, log)),
                            trailing: const Icon(AppIcons.chevron),
                            onTap: () => onOpenLog(log),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
