import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/time/clock_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../plans/presentation/plan_date_notifier.dart';
import '../domain/insight.dart';
import 'insight_formatting.dart';
import 'insight_providers.dart';

/// Week | Month | 3 months | Year, and the exact dates they cover ("Sep 5 –
/// Oct 4"): one period for every number below it (A20).
class InsightRangePicker extends ConsumerWidget {
  const InsightRangePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final range = ref.watch(insightRangeProvider);
    final (from, to) = range.window(currentLocalDate(ref.watch(clockProvider)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final r in InsightRange.values)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ChoiceChip(
                    label: Text(rangeLabel(l10n, r)),
                    selected: r == range,
                    onSelected: (_) =>
                        ref.read(insightRangeProvider.notifier).select(r),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          formatPeriod(context, from, to),
          style: context.textStyles.bodyMedium?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
