import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/streak_badge.dart';
import '../../challenges/presentation/challenge_providers.dart';

import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../core/design/app_icons.dart';
import '../../../shared/widgets/screen_header.dart';
import '../domain/activity_ids.dart';
import '../domain/activity_type.dart';
import 'activity_catalog.dart';

/// Me → Activities (ui_guidelines.md §4.3, ADR-028, ADR-042): every activity
/// in one list ([ActivityCatalog]): the user's own, with **Record**, then the
/// built-in ones, plus **New activity** to make one's own. Configuration
/// lives here; daily recording happens on the day.
class ActivitiesScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final margin = WindowSizeClass.of(context).screenMargin;
    final streaks = ref.watch(activityStreaksProvider);
    return Scaffold(
      appBar: AppBar(),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppContentWidth.list),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              margin,
              0,
              margin,
              AppSpacing.xxxl,
            ),
            children: [
              ScreenHeader(
                showMark: false,
                title: l10n.activitiesTitle,
                subtitle: l10n.activitiesSubtitle,
                actions: [
                  HeaderIconButton(
                    icon: AppIcons.add,
                    tooltip: l10n.newActivity,
                    onPressed: onNewActivity,
                  ),
                ],
              ),
              ActivityCatalog(
                onOpen: (type) => onOpenActivity(type.id),
                onUseBuiltIn: onOpenActivity,
                trailing: (type) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // In a running challenge (M2).
                    if (streaks[type.id] case final streak?) ...[
                      StreakBadge(days: streak.days),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    IconButton.filledTonal(
                      tooltip: l10n.actionRecord,
                      style: IconButton.styleFrom(
                        backgroundColor: context.colors.actionSoft,
                        foregroundColor: context.colors.onActionSoft,
                      ),
                      icon: Icon(
                        type.supportsTimer ? AppIcons.start : AppIcons.add,
                        size: 18,
                      ),
                      onPressed: () => onRecordType(type),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
