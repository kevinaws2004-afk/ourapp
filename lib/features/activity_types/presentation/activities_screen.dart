import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/activity_badge.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/state_views.dart';
import '../domain/activity_type.dart';
import 'activity_type_providers.dart';

/// Me → Activities (ui_guidelines.md §4.3, ADR-028): the reusable activity
/// types, with entry points to build one, start from a template, open one or
/// record it. Configuration lives here; daily recording happens elsewhere.
class ActivitiesScreen extends ConsumerWidget {
  const ActivitiesScreen({
    super.key,
    required this.onNewActivity,
    required this.onFromTemplate,
    required this.onOpenType,
    required this.onRecordType,
  });

  final VoidCallback onNewActivity;
  final VoidCallback onFromTemplate;
  final ValueChanged<ActivityType> onOpenType;
  final ValueChanged<ActivityType> onRecordType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final margin = WindowSizeClass.of(context).screenMargin;
    final types = ref.watch(activeActivityTypesProvider);
    return Scaffold(
      appBar: AppBar(),
      body: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppContentWidth.list),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              margin,
              AppSpacing.huge,
              margin,
              AppSpacing.xxxl,
            ),
            children: [
              Text(
                l10n.activitiesTitle,
                style: context.textStyles.displayMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.activitiesSubtitle,
                style: context.textStyles.bodyLarge?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              AsyncValueView(
                value: types,
                onRetry: () => ref.invalidate(activeActivityTypesProvider),
                data: (types) => types.isEmpty
                    ? AppEmptyState(
                        title: l10n.activitiesEmptyTitle,
                        message: l10n.activitiesEmptyMessage,
                        action: AppButton(
                          label: l10n.newActivity,
                          onPressed: onNewActivity,
                        ),
                        secondaryAction: AppButton(
                          label: l10n.fromTemplate,
                          variant: AppButtonVariant.tertiary,
                          onPressed: onFromTemplate,
                        ),
                      )
                    : _TypeList(
                        types: types,
                        onNewActivity: onNewActivity,
                        onFromTemplate: onFromTemplate,
                        onOpenType: onOpenType,
                        onRecordType: onRecordType,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeList extends StatelessWidget {
  const _TypeList({
    required this.types,
    required this.onNewActivity,
    required this.onFromTemplate,
    required this.onOpenType,
    required this.onRecordType,
  });

  final List<ActivityType> types;
  final VoidCallback onNewActivity;
  final VoidCallback onFromTemplate;
  final ValueChanged<ActivityType> onOpenType;
  final ValueChanged<ActivityType> onRecordType;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.xxl),
        for (final type in types)
          ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            leading: ActivityBadge(
              iconId: type.iconId,
              colorKey: type.colorKey,
            ),
            title: Text(type.name),
            subtitle: Text(l10n.activityFieldCount(type.activeFields.length)),
            trailing: AppButton(
              label: l10n.actionRecord,
              variant: AppButtonVariant.secondary,
              onPressed: () => onRecordType(type),
            ),
            onTap: () => onOpenType(type),
          ),
        const SizedBox(height: AppSpacing.xl),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            AppButton(
              label: l10n.newActivity,
              variant: AppButtonVariant.secondary,
              onPressed: onNewActivity,
            ),
            AppButton(
              label: l10n.fromTemplate,
              variant: AppButtonVariant.tertiary,
              onPressed: onFromTemplate,
            ),
          ],
        ),
      ],
    );
  }
}
