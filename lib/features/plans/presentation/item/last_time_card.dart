import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/context_ext.dart';
import '../../../../core/design/tokens/radius.dart';
import '../../../../core/design/tokens/spacing.dart';
import '../../../../core/ids/id_generator_provider.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../activity_logs/domain/activity_log.dart';
import '../../../activity_logs/domain/log_memory.dart';
import '../../../activity_logs/presentation/activity_log_providers.dart';
import '../../../activity_logs/presentation/value_formatting.dart';
import '../../../activity_types/domain/activity_ids.dart';
import '../../../activity_types/domain/activity_type.dart';
import 'item_notifier.dart';

/// The activity's most recent log with something in it, other than this
/// item's own (B1).
final lastLogProvider = FutureProvider.autoDispose
    .family<ActivityLog?, (ActivityTypeId, ActivityLogId?)>(
      (ref, key) => ref.watch(lastLogOfTypeProvider)(key.$1, except: key.$2),
    );

/// "Last time · Tue, Sep 30: Bench press 60 kg × 8 (×2)" with **Use last
/// time** (B1, ADR-041): an empty item starts from what was logged before,
/// ready to adjust. Nothing is copied until it's tapped.
class LastTimeCard extends ConsumerWidget {
  const LastTimeCard({super.key, required this.args, required this.state});

  final ItemArgs args;
  final ItemState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = state.type;
    if (type == null || type.activeFields.isEmpty || state.values.isNotEmpty) {
      return const SizedBox.shrink();
    }
    final last = ref.watch(lastLogProvider((type.id, state.logId))).value;
    if (last == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    final summary = summarizeLog(context, type, last);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.brandPrimarySoft,
          borderRadius: AppRadius.mdAll,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.itemLastTime(
                  material.formatMediumDate(last.startedAt.toLocal()),
                ),
                style: context.textStyles.titleSmall,
              ),
              if (summary.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  summary,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: l10n.itemUseLastTime,
                variant: AppButtonVariant.primary,
                onPressed: () => _use(ref, type, last),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _use(WidgetRef ref, ActivityType type, ActivityLog last) {
    final notifier = ref.read(itemProvider(args).notifier);
    final values = copyValues(last.values, ref.read(idGeneratorProvider));
    for (final field in type.activeFields) {
      if (values[field.id] case final value?) {
        notifier.setValue(field.id, value);
      }
    }
  }
}
