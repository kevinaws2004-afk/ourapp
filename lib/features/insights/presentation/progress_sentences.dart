import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/time/clock_provider.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_card.dart';
import '../../activity_logs/presentation/value_formatting.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../../plans/presentation/plan_date_notifier.dart';
import '../domain/insight.dart';
import 'insight_providers.dart';

/// Progress needs a few days before it says much (PR3, ADR-046).
const _earlyDays = 3;

/// Fewer than three days with anything done, ever: Progress is early.
final progressIsEarlyProvider = Provider.autoDispose<bool?>((ref) {
  final days = ref.watch(activeDaysProvider).value;
  if (days == null) return null;
  final all = <LocalDate>{for (final set in days.values) ...set};
  return all.length < _earlyDays;
});

/// "this week" / "this month" … for the selected range.
String progressPeriod(AppLocalizations l10n, InsightRange range) =>
    switch (range) {
      InsightRange.week => l10n.progressThisWeek,
      InsightRange.month => l10n.progressThisMonth,
      InsightRange.quarter => l10n.progressThisQuarter,
      InsightRange.year => l10n.progressThisYear,
    };

String _lastPeriod(AppLocalizations l10n, InsightRange range) =>
    switch (range) {
      InsightRange.week => l10n.progressLastWeek,
      InsightRange.month => l10n.progressLastMonth,
      InsightRange.quarter => l10n.progressLastQuarter,
      InsightRange.year => l10n.progressLastYear,
    };

/// A plain sentence in a card, the first thing Progress says (ADR-046).
class SentenceCard extends StatelessWidget {
  const SentenceCard({super.key, required this.sentence, this.detail});

  final String sentence;
  final String? detail;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(sentence, style: context.textStyles.titleLarge),
          if (detail case final d?) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              d,
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

/// Early on (PR3): what's true already, and that the rest comes.
class ProgressEarlyCard extends ConsumerWidget {
  const ProgressEarlyCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final summary = ref.watch(insightSummaryProvider).value;
    final count = summary?.count ?? 0;
    return SentenceCard(
      sentence: l10n.progressEarlyTitle,
      detail: [
        l10n.progressEarlyMessage,
        if (count > 0) l10n.progressDoneSoFar(count),
      ].join('\n'),
    );
  }
}

/// "You did 17 of 20 planned things this week." + against last week (PR1),
/// or, with nothing planned, "You did 12 things this week · 8 h" (PR4).
class ProgressHeadline extends ConsumerWidget {
  const ProgressHeadline({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final range = ref.watch(insightRangeProvider);
    final today = currentLocalDate(ref.watch(clockProvider));
    final (from, to) = range.window(today);
    final (prevFrom, prevTo) = range.previous(today);
    final days = ref.watch(planAdherenceProvider).value;
    final summary = ref.watch(insightSummaryProvider).value;
    if (days == null || summary == null) return const SizedBox.shrink();
    ({int planned, int done}) sum(LocalDate a, LocalDate b) {
      var planned = 0;
      var done = 0;
      for (final d in days) {
        if (d.date.compareTo(a) < 0 || d.date.compareTo(b) > 0) continue;
        planned += d.planned;
        done += d.done;
      }
      return (planned: planned, done: done);
    }

    final now = sum(from, to);
    final before = sum(prevFrom, prevTo);
    final period = progressPeriod(l10n, range);
    if (now.planned == 0) {
      return SentenceCard(
        sentence: summary.durationMs > 0
            ? l10n.progressDidThingsTime(
                summary.count,
                period,
                formatDuration(l10n, summary.durationMs),
              )
            : l10n.progressDidThings(summary.count, period),
      );
    }
    final diff = now.done - before.done;
    final last = _lastPeriod(l10n, range);
    return SentenceCard(
      sentence: l10n.progressDidPlanned(now.done, now.planned, period),
      detail: before.planned == 0
          ? null
          : diff > 0
          ? l10n.progressMoreThan(diff, last)
          : diff < 0
          ? l10n.progressFewerThan(-diff, last)
          : l10n.progressSameAs(last),
    );
  }
}

/// "Most of your time went to Deep work (9 h), Gym (3 h), Reading (2 h)."
class ProgressTimeSentence extends ConsumerWidget {
  const ProgressTimeSentence({super.key});

  /// Activities named.
  static const _named = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final rows = ref.watch(timeByActivityProvider).value;
    if (rows == null || rows.isEmpty) return const SizedBox.shrink();
    final types = <ActivityTypeId, ActivityType>{
      for (final ActivityType t
          in ref.watch(activeActivityTypesProvider).value ?? const [])
        t.id: t,
    };
    final totals = <ActivityTypeId, int>{};
    for (final r in rows) {
      totals[r.typeId] = (totals[r.typeId] ?? 0) + r.durationMs;
    }
    final order = [
      for (final id in totals.keys)
        if (types[id] != null && totals[id]! > 0) id,
    ]..sort((a, b) => totals[b]!.compareTo(totals[a]!));
    if (order.isEmpty) return const SizedBox.shrink();
    final named = [
      for (final id in order.take(_named))
        l10n.progressTimeEntry(
          types[id]!.name,
          formatDuration(l10n, totals[id]!),
        ),
    ].join(', ');
    return SentenceCard(sentence: l10n.progressTimeWent(named));
  }
}
