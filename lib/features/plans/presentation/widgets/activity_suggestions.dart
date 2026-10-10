import 'package:flutter/material.dart';

import '../../../../core/design/app_icons.dart';
import '../../../../core/design/context_ext.dart';
import '../../../../core/design/tokens/sizes.dart';
import '../../../../core/design/tokens/spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/activity_badge.dart';
import '../../../activity_types/domain/activity_type.dart';
import '../../../activity_types/domain/activity_type_definition.dart';
import '../../domain/plan_title_match.dart';

/// Activities matching what's being typed (A6, AD2): yours, then built-in ones,
/// each with what it logs and nothing marking which is which (ADR-042).
class ActivitySuggestions extends StatelessWidget {
  const ActivitySuggestions({
    super.key,
    required this.text,
    required this.types,
    required this.builtIns,
    required this.onType,
    required this.onBuiltIn,
    required this.onMakeOwn,
    this.makeOwnLabel,
    this.makeOwnHint,
  });

  static const _limit = 4;

  /// "Make “Pottery” yours" and its hint (the add sheet, AD3); defaults to
  /// the quick add's wording.
  final String Function(String name)? makeOwnLabel;
  final String? makeOwnHint;

  final String text;
  final List<ActivityType> types;

  /// Built-in activities none of yours has the name of.
  final List<ActivityTypeDefinition> builtIns;
  final ValueChanged<ActivityType> onType;
  final ValueChanged<ActivityTypeDefinition> onBuiltIn;

  /// Makes the typed name a new activity of your own.
  final VoidCallback onMakeOwn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final matchingTypes = suggestByName(
      text,
      types,
      (t) => t.name,
      limit: _limit,
    );
    final matchingBuiltIns = suggestByName(
      text,
      builtIns,
      (t) => t.name,
      limit: _limit - matchingTypes.length,
    );
    final exact = matchByName(text, matchingBuiltIns, (t) => t.name);
    // Offer to make it your own unless the name is already taken (A8).
    final name = text.trim();
    final isNew =
        name.isNotEmpty &&
        exact == null &&
        matchByName(text, types, (t) => t.name) == null;
    if (matchingTypes.isEmpty && matchingBuiltIns.isEmpty && !isNew) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final type in matchingTypes)
            _SuggestionTile(
              iconId: type.iconId,
              colorKey: type.colorKey,
              title: type.name,
              subtitle: type.activeFields.map((f) => f.name).join(' · '),
              onTap: () => onType(type),
            ),
          for (final definition in matchingBuiltIns)
            _SuggestionTile(
              iconId: definition.iconId,
              colorKey: definition.colorKey,
              title: definition.name,
              subtitle: definition.fields.map((f) => f.name).join(' · '),
              selected: identical(definition, exact),
              onTap: () => onBuiltIn(definition),
            ),
          if (isNew)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(AppIcons.add),
              title: Text(
                makeOwnLabel?.call(name) ?? l10n.planMakeOwnNamed(name),
              ),
              subtitle: Text(makeOwnHint ?? l10n.planMakeOwnHint),
              onTap: onMakeOwn,
            ),
        ],
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.iconId,
    required this.colorKey,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.selected = false,
  });

  final String iconId;
  final String colorKey;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: ActivityBadge(
      iconId: iconId,
      colorKey: colorKey,
      size: AppSizes.badgeSmall,
    ),
    title: Text(title),
    subtitle: subtitle.isEmpty
        ? null
        : Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
    trailing: selected
        ? Icon(AppIcons.check, color: context.colors.brandPrimary)
        : null,
    selected: selected,
    onTap: onTap,
  );
}
