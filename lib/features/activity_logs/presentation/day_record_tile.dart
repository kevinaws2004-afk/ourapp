import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/context_ext.dart';
import '../../../core/design/keys/activity_color_key.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/activity_badge.dart';
import '../../../shared/widgets/done_check.dart';
import '../../../shared/widgets/item_card.dart';
import '../../challenges/presentation/challenge_providers.dart';
import '../domain/watch_records_for_day.dart';
import 'value_formatting.dart';

/// A thing done without a plan (ADR-035) as a timeline row (ADR-046): its
/// start time, the result ("32 pages", "45 min"), a 🔥 when its activity is
/// in a running challenge, and the filled circle.
class DayRecordTile extends ConsumerWidget {
  const DayRecordTile({super.key, required this.record, required this.onTap});

  final DayRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    final DayRecord(:log, :type) = record;
    final activity = context.tokens.activity(
      ActivityColorKey.fromName(type.colorKey) ?? ActivityColorKey.slate,
    );
    final logged = summarizeLog(context, type, log);
    final result = logged.isNotEmpty
        ? logged
        : log.durationMs != null
        ? formatDuration(l10n, log.durationMs!)
        : l10n.planStatusDone;
    return ItemCard(
      title: type.name,
      startTime: material.formatTimeOfDay(
        TimeOfDay.fromDateTime(log.startedAt.toLocal()),
      ),
      subline: result,
      streak: ref.watch(activityStreaksProvider)[type.id]?.days,
      onTap: onTap,
      leading: ActivityBadge(iconId: type.iconId, colorKey: type.colorKey),
      // Done by definition: the circle shows it, like every row (A17),
      // without toggling.
      trailing: [
        DoneCheck(done: true, color: activity.solid),
        const SizedBox(width: AppSpacing.xs),
      ],
    );
  }
}
