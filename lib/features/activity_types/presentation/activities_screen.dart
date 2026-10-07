import 'package:flutter/material.dart';

import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';
import '../domain/activity_ids.dart';
import '../domain/activity_type.dart';
import 'activity_catalog.dart';

/// Me → Activities (ui_guidelines.md §4.3, ADR-028, ADR-042): every activity
/// in one list ([ActivityCatalog]): the user's own, with **Record**, then the
/// built-in ones, plus **New activity** to make one's own. Configuration
/// lives here; daily recording happens on the day.
class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({
    super.key,
    required this.onNewActivity,
    required this.onOpenActivity,
    required this.onRecordType,
  });

  final VoidCallback onNewActivity;

  /// Opens an activity's page (one of yours, or a built-in one just used).
  final ValueChanged<ActivityTypeId> onOpenActivity;
  final ValueChanged<ActivityType> onRecordType;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final margin = WindowSizeClass.of(context).screenMargin;
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
              const SizedBox(height: AppSpacing.lg),
              Align(
                alignment: Alignment.centerLeft,
                child: AppButton(
                  label: l10n.newActivity,
                  variant: AppButtonVariant.secondary,
                  onPressed: onNewActivity,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ActivityCatalog(
                onOpen: (type) => onOpenActivity(type.id),
                onUseBuiltIn: onOpenActivity,
                trailing: (type) => AppButton(
                  label: l10n.actionRecord,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => onRecordType(type),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
