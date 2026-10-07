import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/context_ext.dart';
import '../../../core/design/keys/activity_color_key.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/sizes.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
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
import '../domain/activity_type_definition.dart';
import '../domain/activity_type_use_cases.dart';
import 'everyday_templates.dart';
import 'activity_type_providers.dart';
import 'preview_type.dart';

/// The template gallery (B8): every starter template as a card; tapping one
/// previews the real form it gives, with **Add**. Installing creates an
/// ordinary, editable activity. Pops with the new activity's ID.
class TemplatePickerScreen extends ConsumerStatefulWidget {
  const TemplatePickerScreen({super.key});

  @override
  ConsumerState<TemplatePickerScreen> createState() =>
      _TemplatePickerScreenState();
}

class _TemplatePickerScreenState extends ConsumerState<TemplatePickerScreen> {
  String _query = '';

  /// Matches a template by its name, its category or what it logs.
  bool _matches(TemplateCategory category, ActivityTypeDefinition template) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return true;
    bool has(String text) => text.toLowerCase().contains(query);
    return has(template.name) ||
        has(category.name) ||
        template.fields.any((f) => has(f.name));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final margin = WindowSizeClass.of(context).screenMargin;
    final active = ref.watch(activeActivityTypesProvider).value ?? const [];
    bool taken(ActivityTypeDefinition t) =>
        active.any((a) => sameActivityName(a.name, t.name));
    final categories = [
      for (final category in templateCategories(l10n))
        (
          category.name,
          [
            for (final t in category.templates)
              if (_matches(category, t)) t,
          ],
        ),
    ].where((c) => c.$2.isNotEmpty).toList();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.templatesTitle)),
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
                l10n.templatesSubtitle,
                style: context.textStyles.bodyLarge?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                decoration: InputDecoration(hintText: l10n.templatesSearchHint),
                onChanged: (text) => setState(() => _query = text),
              ),
              if (categories.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xl),
                  child: Text(
                    l10n.templatesNoMatch,
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
              for (final (name, templates) in categories) ...[
                SectionHeader(title: name),
                for (final template in templates)
                  _TemplateCard(
                    template: template,
                    taken: taken(template),
                    onTap: () async {
                      final id = await _showPreview(context, template);
                      if (id != null && context.mounted) {
                        // Opening the new activity is the confirmation.
                        Navigator.of(context).pop(id);
                      }
                    },
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<ActivityTypeId?> _showPreview(
    BuildContext context,
    ActivityTypeDefinition template,
  ) => showModalBottomSheet<ActivityTypeId>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _TemplatePreview(template: template),
  );
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.template,
    required this.taken,
    required this.onTap,
  });

  final ActivityTypeDefinition template;

  /// An activity already has this name; it can still be previewed.
  final bool taken;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.tokens.activity(
      ActivityColorKey.fromName(template.colorKey) ?? ActivityColorKey.slate,
    );
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
                  iconId: template.iconId,
                  colorKey: template.colorKey,
                  size: AppSizes.badgeLarge,
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name,
                        style: context.textStyles.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        taken
                            ? l10n.templatesAlreadyAdded
                            : template.fields.map((f) => f.name).join(' · '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A template's real form, to try before adding it (B8).
class _TemplatePreview extends ConsumerStatefulWidget {
  const _TemplatePreview({required this.template});

  final ActivityTypeDefinition template;

  @override
  ConsumerState<_TemplatePreview> createState() => _TemplatePreviewState();
}

class _TemplatePreviewState extends ConsumerState<_TemplatePreview> {
  final _values = <ActivityFieldId, FieldValue>{};

  Future<void> _add() async {
    final l10n = AppLocalizations.of(context);
    try {
      final id = await ref.read(installActivityTemplateProvider)(
        widget.template,
      );
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
    final template = widget.template;
    final type = previewOf(template);
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
                  iconId: template.iconId,
                  colorKey: template.colorKey,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    template.name,
                    style: context.textStyles.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.templatesYoullLog,
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
              label: l10n.templatePreviewAdd(template.name),
              onPressed: _add,
            ),
          ],
        ),
      ),
    );
  }
}
