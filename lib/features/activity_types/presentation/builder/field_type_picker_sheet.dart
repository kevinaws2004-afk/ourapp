import 'package:flutter/material.dart';

import '../../../../core/design/context_ext.dart';
import '../../../../core/design/tokens/spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/field_type.dart';
import '../field_type_copy.dart';

/// Lets the user pick a field type, each with a plain-language description.
Future<FieldType?> showFieldTypePicker(BuildContext context) =>
    showModalBottomSheet<FieldType>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.85,
            ),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Text(
                    l10n.fieldTypePickerTitle,
                    style: context.textStyles.titleLarge,
                  ),
                ),
                for (final type in FieldType.values)
                  ListTile(
                    enabled: type.isAvailable,
                    leading: Icon(type.icon),
                    title: Text(type.label(l10n)),
                    subtitle: Text(type.description(l10n)),
                    trailing: type.isAvailable
                        ? null
                        : Text(l10n.availableLater),
                    onTap: () => Navigator.of(context).pop(type),
                  ),
              ],
            ),
          ),
        );
      },
    );
