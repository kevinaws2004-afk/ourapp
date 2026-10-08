import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/context_ext.dart';
import '../../../../core/design/tokens/spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../../activity_logs/presentation/form/activity_log_form.dart';
import '../../../activity_logs/presentation/form/row_memory_scope.dart';
import '../../../activity_logs/presentation/value_formatting.dart';
import 'item_notifier.dart';
import 'last_time_card.dart';

/// "How did it go?" (ADR-046, A6): after something with meaningful details
/// is done, its details in a sheet, prefilled with what's already in it,
/// with **Use last time** when it's empty. It's already done either way:
/// **Save** keeps what was entered (it saves as you type), **Skip** leaves it
/// without details.
Future<void> showHowDidItGo(BuildContext context, ItemArgs args) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _HowDidItGo(args: args),
    );

class _HowDidItGo extends ConsumerWidget {
  const _HowDidItGo({required this.args});

  final ItemArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final item = ref.watch(itemProvider(args));
    final notifier = ref.read(itemProvider(args).notifier);
    Future<void> close() async {
      await notifier.flush();
      if (context.mounted) Navigator.of(context).pop();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (context, scroll) => AsyncValueView<ItemState>(
          value: item,
          onRetry: () => ref.invalidate(itemProvider(args)),
          data: (state) {
            final type = state.type;
            final subtitle = [
              state.title,
              if (state.durationMs case final ms?) formatDuration(l10n, ms),
            ].join(' · ');
            return ListView(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.xxl,
              ),
              children: [
                Text(
                  l10n.howDidItGoTitle,
                  style: context.textStyles.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: context.textStyles.bodyLarge?.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                LastTimeCard(args: args, state: state),
                if (type != null)
                  RowMemoryScope(
                    except: state.logId,
                    child: ActivityLogFormFields(
                      boxed: true,
                      type: type,
                      fields: state.visibleFields,
                      values: state.values,
                      issues: state.issues,
                      onChanged: notifier.setValue,
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: l10n.howDidItGoSave,
                  variant: AppButtonVariant.action,
                  expand: true,
                  onPressed: () => unawaited(close()),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: l10n.howDidItGoSkip,
                  variant: AppButtonVariant.tertiary,
                  expand: true,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
