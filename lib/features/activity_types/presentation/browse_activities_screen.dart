import 'package:flutter/material.dart';

import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/activity_ids.dart';
import 'activity_catalog.dart';

/// Choosing an activity for a day ("Browse activities" in quick add and the
/// plan sheet, ADR-042): the one [ActivityCatalog]. Pops with the chosen
/// activity's ID (a built-in one is saved as the user's first).
class BrowseActivitiesScreen extends StatelessWidget {
  const BrowseActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final margin = WindowSizeClass.of(context).screenMargin;
    void choose(ActivityTypeId id) => Navigator.of(context).pop(id);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.activitiesBrowseTitle)),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppContentWidth.reading),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              margin,
              AppSpacing.sm,
              margin,
              AppSpacing.huge,
            ),
            children: [
              Text(
                l10n.activitiesBrowseSubtitle,
                style: context.textStyles.bodyLarge?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ActivityCatalog(
                onOpen: (type) => choose(type.id),
                onUseBuiltIn: choose,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
