import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/context_ext.dart';
import '../../../core/design/keys/activity_color_key.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/sizes.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/errors/app_exception.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/errors/error_copy.dart';
import '../../../shared/widgets/activity_badge.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/state_views.dart';
import '../../activity_logs/domain/field_value.dart';
import '../../activity_logs/presentation/form/activity_log_form.dart';
import '../domain/activity_ids.dart';
import '../domain/activity_type.dart';
import '../domain/activity_type_definition.dart';
import '../domain/activity_type_use_cases.dart';
import 'activity_type_providers.dart';
import 'built_in_activities.dart';
import 'preview_type.dart';

/// One list of activities (ADR-042: there is only one concept, the
/// activity). The user's own come first ("Yours"), then the built-in ones
/// by category, all in the same card and all searchable by name, category
/// or what they log. A built-in activity whose name one of yours already
/// has is left out, so every name appears once.
///
/// Tapping one of yours calls [onOpen]. Tapping a built-in one previews its
/// form with **Use {name}**, which saves it as one of the user's activities
/// and calls [onUseBuiltIn] with its ID.
class ActivityCatalog extends ConsumerStatefulWidget {
  const ActivityCatalog({
    super.key,
    required this.onOpen,
    required this.onUseBuiltIn,
    this.trailing,
  });

  final ValueChanged<ActivityType> onOpen;
  final ValueChanged<ActivityTypeId> onUseBuiltIn;

  /// An action at the end of each of the user's activities (e.g. Record).
  final Widget Function(ActivityType type)? trailing;

  @override
  ConsumerState<ActivityCatalog> createState() => _ActivityCatalogState();
}

class _ActivityCatalogState extends ConsumerState<ActivityCatalog> {
  String _query = '';

  bool _matches(String name, Iterable<String> details, [String group = '']) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return true;
    bool has(String text) => text.toLowerCase().contains(query);
    return has(name) || has(group) || details.any(has);
  }

  Future<void> _preview(ActivityTypeDefinition definition) async {
    final id = await showModalBottomSheet<ActivityTypeId>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _BuiltInPreview(definition: definition),
    );
    if (id != null && mounted) widget.onUseBuiltIn(id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final types = ref.watch(activeActivityTypesProvider);
    final yours = types.value ?? const <ActivityType>[];
    bool taken(ActivityTypeDefinition d) =>
        yours.any((a) => sameActivityName(a.name, d.name));
    final shownYours = [
      for (final type in yours)
        if (_matches(type.name, type.activeFields.map((f) => f.name))) type,
    ];
    final categories = [
      for (final category in activityCategories(l10n))
        (
          category.name,
          [
            for (final d in category.activities)
              if (!taken(d) &&
                  _matches(d.name, d.fields.map((f) => f.name), category.name))
                d,
          ],
        ),
    ].where((c) => c.$2.isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          decoration: InputDecoration(hintText: l10n.activitiesSearchHint),
          onChanged: (text) => setState(() => _query = text),
        ),
        if (types.hasError)
          AppErrorState(
            error: types.error!,
            onRetry: () => ref.invalidate(activeActivityTypesProvider),
          ),
        if (shownYours.isNotEmpty) ...[
          SectionHeader(title: l10n.activitiesYours),
          for (final type in shownYours)
            _ActivityCard(
              iconId: type.iconId,
              colorKey: type.colorKey,
              name: type.name,
              details: type.activeFields.map((f) => f.name),
              trailing: widget.trailing?.call(type),
              onTap: () => widget.onOpen(type),
            ),
        ],
        for (final (name, definitions) in categories) ...[
          SectionHeader(title: name),
          for (final definition in definitions)
            _ActivityCard(
              iconId: definition.iconId,
              colorKey: definition.colorKey,
              name: definition.name,
              details: definition.fields.map((f) => f.name),
              onTap: () => _preview(definition),
            ),
        ],
        if (shownYours.isEmpty && categories.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xl),
            child: Text(
              l10n.activitiesNoMatch,
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}

/// An activity in the list: badge, name and what it logs.
class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.iconId,
    required this.colorKey,
    required this.name,
    required this.details,
    required this.onTap,
    this.trailing,
  });

  final String iconId;
  final String colorKey;
  final String name;
  final Iterable<String> details;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.activity(
      ActivityColorKey.fromName(colorKey) ?? ActivityColorKey.slate,
    );
    final detailText = details.join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: colors.soft,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                ActivityBadge(
                  iconId: iconId,
                  colorKey: colorKey,
                  size: AppSizes.badgeLarge,
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: context.textStyles.titleMedium),
                      if (detailText.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          detailText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyles.bodyMedium?.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing case final trailing?) ...[
                  const SizedBox(width: AppSpacing.sm),
                  trailing,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A built-in activity's real form, to try before using it (B8). **Use**
/// saves it as one of the user's activities and pops with its ID.
class _BuiltInPreview extends ConsumerStatefulWidget {
  const _BuiltInPreview({required this.definition});

  final ActivityTypeDefinition definition;

  @override
  ConsumerState<_BuiltInPreview> createState() => _BuiltInPreviewState();
}

class _BuiltInPreviewState extends ConsumerState<_BuiltInPreview> {
  final _values = <ActivityFieldId, FieldValue>{};

  Future<void> _use() async {
    final l10n = AppLocalizations.of(context);
    try {
      final id = await ref.read(addBuiltInActivityProvider)(widget.definition);
      if (mounted) Navigator.of(context).pop(id);
    } on ValidationException catch (e) {
      // E.g. an activity with this name already exists (A8).
      if (mounted) {
        showMessageSnackBar(
          context,
          validationMessage(l10n, e.issues.first.code),
        );
      }
    } catch (error) {
      if (mounted) showMessageSnackBar(context, errorMessage(l10n, error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final definition = widget.definition;
    final type = previewOf(definition);
    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Row(
              children: [
                ActivityBadge(
                  iconId: definition.iconId,
                  colorKey: definition.colorKey,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    definition.name,
                    style: context.textStyles.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.activityPreviewYoullLog,
              style: context.textStyles.labelLarge?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ActivityLogFormFields(
              type: type,
              fields: type.activeFields,
              values: _values,
              onChanged: (id, value) => setState(
                () => value == null ? _values.remove(id) : _values[id] = value,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l10n.activityPreviewUse(definition.name),
              onPressed: _use,
            ),
          ],
        ),
      ),
    );
  }
}
