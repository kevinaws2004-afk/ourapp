import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/keys/activity_color_key.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/tokens/typography.dart';
import '../../../core/design/window_size_class.dart';
import '../../../core/time/clock_provider.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/errors/error_copy.dart';
import '../../../shared/widgets/activity_badge.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/progress_bar.dart';
import '../../../shared/widgets/progress_ring.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/state_views.dart';
import '../../activity_logs/presentation/value_formatting.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../../challenges/domain/challenge_progress.dart';
import '../../challenges/presentation/challenge_providers.dart';
import '../../challenges/presentation/goal_copy.dart';
import '../../plans/presentation/plan_date_notifier.dart';
import '../domain/week_recap.dart';
import 'insight_formatting.dart';
import 'personal_records.dart';
import 'recap_providers.dart';

/// The weekly recap (Monday to Sunday): planned vs recorded time in one
/// sentence, the week's numbers against the week before, where the time
/// went, the best day, personal bests and goals. The top card shares as an
/// image ("my week"). Arrows move between weeks.
class WeeklyRecapScreen extends ConsumerStatefulWidget {
  const WeeklyRecapScreen({super.key, this.weekStart});

  /// The Monday of the week; null for the latest one to recap.
  final LocalDate? weekStart;

  @override
  ConsumerState<WeeklyRecapScreen> createState() => _WeeklyRecapScreenState();
}

class _WeeklyRecapScreenState extends ConsumerState<WeeklyRecapScreen> {
  final _cardKey = GlobalKey();
  late LocalDate _week =
      widget.weekStart ??
      defaultRecapWeek(currentLocalDate(ref.read(clockProvider)));
  bool _sharing = false;

  Future<void> _share() async {
    if (_sharing) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _sharing = true);
    try {
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (bytes == null) return;
      final file = File(
        '${(await getTemporaryDirectory()).path}/daylog-week-${_week.toIso()}.png',
      );
      await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: l10n.recapShareText,
        ),
      );
    } catch (error) {
      if (mounted) showMessageSnackBar(context, errorMessage(l10n, error));
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final margin = WindowSizeClass.of(context).screenMargin;
    final today = currentLocalDate(ref.watch(clockProvider));
    final latest = weekStartOf(today);
    final recap = ref.watch(weekRecapProvider(_week));
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recapTitle),
        actions: [
          IconButton(
            tooltip: l10n.recapShare,
            icon: const Icon(AppIcons.share),
            onPressed: (recap.value?.isEmpty ?? true) || _sharing
                ? null
                : () => unawaited(_share()),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppContentWidth.chart),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              margin,
              AppSpacing.xs,
              margin,
              AppSpacing.giant,
            ),
            children: [
              _WeekSwitcher(
                week: _week,
                canGoNext: _week.compareTo(latest) < 0,
                onChange: (w) => setState(() => _week = w),
              ),
              const SizedBox(height: AppSpacing.md),
              AsyncValueView<WeekRecap>(
                value: recap,
                onRetry: () => ref.invalidate(weekRecapProvider(_week)),
                data: (recap) => recap.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xxl),
                        child: AppEmptyState(
                          icon: AppIcons.recap,
                          title: l10n.recapEmptyTitle,
                          message: l10n.recapEmptyMessage,
                        ),
                      )
                    : _RecapBody(recap: recap, cardKey: _cardKey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekSwitcher extends StatelessWidget {
  const _WeekSwitcher({
    required this.week,
    required this.canGoNext,
    required this.onChange,
  });

  final LocalDate week;
  final bool canGoNext;
  final ValueChanged<LocalDate> onChange;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        IconButton(
          tooltip: l10n.planPreviousWeek,
          icon: const Icon(AppIcons.previous),
          onPressed: () => onChange(week.addDays(-7)),
        ),
        Expanded(
          child: Text(
            formatPeriod(context, week, week.addDays(6)),
            textAlign: TextAlign.center,
            style: context.textStyles.titleMedium,
          ),
        ),
        IconButton(
          tooltip: l10n.planNextWeek,
          icon: const Icon(AppIcons.chevron),
          onPressed: canGoNext ? () => onChange(week.addDays(7)) : null,
        ),
      ],
    );
  }
}

class _RecapBody extends ConsumerWidget {
  const _RecapBody({required this.recap, required this.cardKey});

  final WeekRecap recap;
  final GlobalKey cardKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final types = {
      for (final ActivityType t
          in ref.watch(activeActivityTypesProvider).value ?? const [])
        t.id: t,
    };
    final records =
        ref.watch(personalRecordsProvider(recap.weekStart)).value ?? const [];
    final weekRecords = records
        .where((r) => r.point.date.compareTo(recap.weekEnd) <= 0)
        .toList();
    final goals = ref.watch(challengesProvider).value ?? const [];
    final top = recap.activities.take(5).toList();
    final maxMs = top.isEmpty ? 0 : top.first.durationMs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RepaintBoundary(
          key: cardKey,
          child: _RecapCard(recap: recap),
        ),
        if (top.isNotEmpty) ...[
          SectionHeader(title: l10n.recapWhereTimeWent),
          AppCard(
            child: Column(
              children: [
                for (final a in top)
                  if (types[a.typeId] case final type?)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs,
                      ),
                      child: Row(
                        children: [
                          ActivityBadge(
                            iconId: type.iconId,
                            colorKey: type.colorKey,
                            size: 36,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        type.name,
                                        style: context.textStyles.titleSmall,
                                      ),
                                    ),
                                    Text(
                                      a.durationMs > 0
                                          ? formatDuration(l10n, a.durationMs)
                                          : l10n.insightTimesRecorded(a.count),
                                      style: context.textStyles.labelLarge,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xxs),
                                AppProgressBar(
                                  fraction: maxMs == 0
                                      ? 1
                                      : a.durationMs / maxMs,
                                  color: context.tokens
                                      .activity(
                                        ActivityColorKey.fromName(
                                              type.colorKey,
                                            ) ??
                                            ActivityColorKey.slate,
                                      )
                                      .solid,
                                  semanticLabel: type.name,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          ),
        ],
        if (recap.bestDay case final day?) ...[
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Row(
              children: [
                Icon(AppIcons.trophy, color: c.warning),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    l10n.recapBestDay(
                      _weekdayName(context, day),
                      formatDuration(l10n, recap.bestDayMs),
                    ),
                    style: context.textStyles.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (weekRecords.isNotEmpty) ...[
          SectionHeader(title: l10n.recapRecords),
          for (final r in weekRecords) PersonalRecordTile(record: r),
        ],
        if (goals.isNotEmpty) ...[
          SectionHeader(title: l10n.navChallenges),
          AppCard(
            child: Column(
              children: [
                for (final g in goals)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xs,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            g.challenge.title,
                            style: context.textStyles.bodyLarge,
                          ),
                        ),
                        Text(
                          goalProgressText(l10n, g.progress),
                          style: context.textStyles.labelLarge?.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// "Tuesday", in the app's language.
String _weekdayName(BuildContext context, LocalDate date) =>
    DateFormat.EEEE(Localizations.localeOf(context).toLanguageTag())
        .format(DateTime(date.year, date.month, date.day));

/// The shareable card: the headline sentence, planned vs recorded as a
/// ring, and four numbers against the week before. Drawn on its own
/// surface with the app's mark so the image stands alone.
class _RecapCard extends StatelessWidget {
  const _RecapCard({required this.recap});

  final WeekRecap recap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final share = recap.plannedShare;
    final headline = share == null
        ? l10n.recapHeadlineTracked(formatDuration(l10n, recap.trackedMs))
        : l10n.recapHeadlinePlanned(
            formatDuration(l10n, recap.plannedMs),
            formatDuration(l10n, recap.actualMs),
          );
    final change = recap.timeChange;
    Widget stat(String value, String label, {String? note}) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTypography.numericLarge.copyWith(
              color: c.textPrimary,
              fontSize: 22,
            ),
          ),
          Text(
            label,
            style: context.textStyles.labelMedium?.copyWith(
              color: c.textSecondary,
            ),
          ),
          if (note != null)
            Text(
              note,
              style: context.textStyles.labelSmall?.copyWith(
                color: c.textTertiary,
              ),
            ),
        ],
      ),
    );
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: c.surfaceBase,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: c.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n
                .recapOverline(
                  formatPeriod(context, recap.weekStart, recap.weekEnd),
                )
                .toUpperCase(),
            style: context.textStyles.labelSmall?.copyWith(
              color: c.brandPrimary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  headline,
                  style: context.textStyles.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (share != null) ...[
                const SizedBox(width: AppSpacing.md),
                ProgressRing(
                  fraction: share.clamp(0, 1).toDouble(),
                  semanticLabel: '${(share * 100).round()} %',
                  size: 72,
                  stroke: 7,
                  color: c.brandPrimary,
                  trackColor: c.brandPrimarySoft,
                  child: Text(
                    '${(share * 100).round()}%',
                    style: AppTypography.numericMedium.copyWith(
                      color: c.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              stat(
                formatDuration(l10n, recap.trackedMs),
                l10n.recapTimeTracked,
                note: change == null
                    ? null
                    : l10n.recapVsLastWeek(formatChange(change)),
              ),
              stat('${recap.done}', l10n.recapThingsDone),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              stat('${recap.activeDays}/7', l10n.recapActiveDays),
              stat(
                recap.plansCounted == 0
                    ? '—'
                    : '${recap.plansDone}/${recap.plansCounted}',
                l10n.recapPlansKept,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              const AppLogo(size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l10n.appTitle,
                style: context.textStyles.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
