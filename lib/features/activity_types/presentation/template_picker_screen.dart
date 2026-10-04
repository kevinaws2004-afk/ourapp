import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/context_ext.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/errors/error_copy.dart';
import '../../../shared/widgets/activity_badge.dart';
import '../../../shared/widgets/state_views.dart';
import '../domain/activity_ids.dart';
import 'activity_templates.dart';
import 'activity_type_providers.dart';

/// Pick a starter template; installing creates an ordinary, editable type.
/// Pops with the new type's ID.
class TemplatePickerScreen extends ConsumerWidget {
  const TemplatePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final margin = WindowSizeClass.of(context).screenMargin;
    final templates = activityTemplates(l10n);
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
              for (final template in templates)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.xs,
                  ),
                  leading: ActivityBadge(
                    iconId: template.iconId,
                    colorKey: template.colorKey,
                  ),
                  title: Text(template.name),
                  subtitle: Text(
                    template.fields.map((f) => f.name).join(' · '),
                  ),
                  onTap: () async {
                    try {
                      final ActivityTypeId id = await ref.read(
                        installActivityTemplateProvider,
                      )(template);
                      if (!context.mounted) return;
                      // Opening the new activity is the confirmation; a
                      // snackbar here would cover the next screen's actions.
                      Navigator.of(context).pop(id);
                    } on ValidationException catch (e) {
                      // E.g. an activity with this name already exists.
                      if (context.mounted) {
                        showMessageSnackBar(
                          context,
                          validationMessage(l10n, e.issues.first.code),
                        );
                      }
                    } catch (error) {
                      if (context.mounted) {
                        showMessageSnackBar(context, errorMessage(l10n, error));
                      }
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
