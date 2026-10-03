import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/activity_badge.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/state_views.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../activity_types/presentation/activity_type_providers.dart';

/// Quick Record (ADR-028, ui_guidelines.md §7.1): record an unplanned
/// activity from any tab in two taps. Pops with the chosen activity type, or
/// [QuickRecordSheet.newActivity] when the user wants to create one.
class QuickRecordSheet extends ConsumerWidget {
  const QuickRecordSheet({super.key});

  /// Result sentinel: the user chose to create a new activity.
  static const newActivity = Object();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final types = ref.watch(activeActivityTypesProvider);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          children: [
            Text(
              l10n.quickRecordTitle,
              style: context.textStyles.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            AsyncValueView<List<ActivityType>>(
              value: types,
              data: (types) => types.isEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.quickRecordEmpty,
                          style: context.textStyles.bodyLarge?.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppButton(
                          label: l10n.newActivity,
                          onPressed: () =>
                              Navigator.of(context)
                                  .pop(QuickRecordSheet.newActivity),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        for (final type in types)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: ActivityBadge(
                              iconId: type.iconId,
                              colorKey: type.colorKey,
                            ),
                            title: Text(type.name),
                            onTap: () => Navigator.of(context).pop(type),
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
