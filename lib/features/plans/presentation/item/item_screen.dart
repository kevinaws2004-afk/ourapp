import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/app_icons.dart';
import '../../../../core/design/context_ext.dart';
import '../../../../core/design/tokens/sizes.dart';
import '../../../../core/design/tokens/spacing.dart';
import '../../../../core/design/tokens/typography.dart';
import '../../../../core/design/window_size_class.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/time/clock_provider.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/errors/error_copy.dart';
import '../../../../shared/widgets/activity_badge.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../../shared/widgets/streak_badge.dart';
import '../../../activity_types/presentation/activity_type_providers.dart';
import '../../../challenges/presentation/challenge_providers.dart';
import '../../domain/day_progress.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../../activity_logs/presentation/activity_log_providers.dart';
import '../../../activity_logs/presentation/form/activity_log_form.dart';
import '../../../activity_logs/presentation/form/add_detail_scope.dart';
import '../../../activity_logs/presentation/form/rest_timer_scope.dart';
import '../../../activity_logs/presentation/form/row_memory_scope.dart';
import '../../../activity_logs/presentation/form/date_time_editors.dart';
import '../../../activity_logs/presentation/form/field_editor_shell.dart';
import '../../../activity_logs/presentation/value_formatting.dart';
import '../../../activity_types/domain/activity_ids.dart';
import '../../../activity_types/domain/activity_type.dart';
import '../../../focus/domain/focus_session.dart';
import '../../../focus/presentation/focus_providers.dart';
import '../../../focus/presentation/focus_screen.dart';
import '../../domain/plan.dart';
import '../../domain/watch_day_overview.dart';
import '../plan_actions.dart';
import '../plan_editor_sheet.dart';
import '../../../../core/time/local_date.dart';
import '../plan_date_notifier.dart';
import '../plan_formatting.dart';
import '../plan_providers.dart';
import 'add_to_log_sheet.dart';
import 'item_notifier.dart';
import 'last_time_card.dart';
import 'rest_timer.dart';

/// One item on your day (ADR-035): the place you log into. Planned, in
/// progress or done, it's the same screen; what you enter is saved as you
/// type. A timer can run while you log ([onOpenTimer] shows it full screen).
class ItemScreen extends ConsumerWidget {
  const ItemScreen({
    super.key,
    required this.args,
    required this.onOpenTimer,
    this.onEditFields,
    this.onOpenItem,
  });

  final ItemArgs args;
  final VoidCallback onOpenTimer;

  /// Opens another item (the one "Plan next" just created).
  final ValueChanged<PlanId>? onOpenItem;

  /// Opens the item's activity in the builder (rename, reorder or remove
  /// what it logs); the item reloads afterwards.
  final Future<Object?> Function(ActivityTypeId typeId)? onEditFields;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(itemProvider(args));
    final state = item.value;
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) unawaited(ref.read(itemProvider(args).notifier).flush());
      },
      child: Scaffold(
        appBar: AppBar(
          title: state == null ? null : _ItemTitle(state: state),
          actions: [
            if (state != null) _SaveStatusLabel(status: state.saveStatus),
            if (state?.type case final type?
                when onEditFields != null && type.fields.isNotEmpty)
              IconButton(
                tooltip: AppLocalizations.of(context).itemEditFields,
                icon: const Icon(AppIcons.edit),
                onPressed: () async {
                  final notifier = ref.read(itemProvider(args).notifier);
                  await notifier.flush();
                  await onEditFields!(type.id);
                  await notifier.reload();
                },
              ),
            if (state?.plan != null)
              IconButton(
                tooltip: AppLocalizations.of(context).itemOptions,
                icon: const Icon(AppIcons.more),
                onPressed: () => _openOptions(context, ref, state!),
              )
            else if (state?.logId != null)
              IconButton(
                tooltip: AppLocalizations.of(context).actionDelete,
                icon: const Icon(AppIcons.delete),
                onPressed: () => _deleteLog(context, ref, state!),
              ),
          ],
        ),
        bottomNavigationBar: const RestTimerBar(),
        body: AsyncValueView(
          value: item,
          onRetry: () => ref.invalidate(itemProvider(args)),
          data: (state) => _ItemBody(
            args: args,
            state: state,
            onOpenTimer: onOpenTimer,
            onOpenItem: onOpenItem,
          ),
        ),
      ),
    );
  }

  /// The plan sheet: edit title/time/notes, skip, move, delete.
  Future<void> _openOptions(
    BuildContext context,
    WidgetRef ref,
    ItemState state,
  ) async {
    final notifier = ref.read(itemProvider(args).notifier);
    await notifier.flush();
    if (!context.mounted) return;
    final session = ref.read(activeFocusSessionProvider).value;
    final plan = state.plan!;
    final action = await PlanActions(context, ref).open(
      PlannedItem(
        plan: plan,
        type: state.type,
        records: const [],
        status: plan.effectiveStatus(
          hasRecord: state.hasLog,
          today: currentLocalDate(ref.read(clockProvider)),
          inFocus: session?.planId == plan.id,
        ),
      ),
    );
    if (!context.mounted) return;
    if (action == PlanSheetAction.delete) {
      Navigator.of(context).pop();
    } else {
      await notifier.reload();
    }
  }

  Future<void> _deleteLog(
    BuildContext context,
    WidgetRef ref,
    ItemState state,
  ) async {
    final l10n = AppLocalizations.of(context);
    final logId = state.logId!;
    final messenger = ScaffoldMessenger.of(context);
    final restore = ref.read(restoreActivityLogProvider);
    try {
      await ref.read(deleteActivityLogProvider)(logId);
    } catch (error) {
      if (context.mounted) {
        showMessageSnackBar(context, errorMessage(l10n, error));
      }
      return;
    }
    if (!context.mounted) return;
    Navigator.of(context).pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.itemDeleted),
          action: SnackBarAction(
            label: l10n.actionUndo,
            onPressed: () => unawaited(restore(logId)),
          ),
        ),
      );
  }
}

class _ItemTitle extends StatelessWidget {
  const _ItemTitle({required this.state});

  final ItemState state;

  @override
  Widget build(BuildContext context) {
    final type = state.type;
    return Row(
      children: [
        if (type != null) ...[
          ActivityBadge(
            iconId: type.iconId,
            colorKey: type.colorKey,
            size: AppSizes.badgeSmall,
          ),
          const SizedBox(width: AppSpacing.md),
        ],
        Flexible(child: Text(state.title, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

/// "Saving…" / "Saved": the item saves as you type, so say so.
class _SaveStatusLabel extends StatelessWidget {
  const _SaveStatusLabel({required this.status});

  final SaveStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = switch (status) {
      SaveStatus.idle => null,
      SaveStatus.saving => l10n.itemSaving,
      SaveStatus.saved => l10n.itemSaved,
      SaveStatus.failed => null,
    };
    if (text == null) return const SizedBox.shrink();
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: Text(
          text,
          style: context.textStyles.bodySmall?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ItemBody extends ConsumerWidget {
  const _ItemBody({
    required this.args,
    required this.state,
    required this.onOpenTimer,
    this.onOpenItem,
  });

  final ItemArgs args;
  final ItemState state;
  final VoidCallback onOpenTimer;
  final ValueChanged<PlanId>? onOpenItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(itemProvider(args).notifier);
    final margin = WindowSizeClass.of(context).screenMargin;
    final plan = state.plan;
    final type = state.type;
    final fields = state.visibleFields;
    final planTime = plan == null ? null : formatPlanTime(context, plan);
    final quiet = context.textStyles.bodyMedium?.copyWith(
      color: context.colors.textSecondary,
    );
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppContentWidth.reading),
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            margin,
            AppSpacing.md,
            margin,
            AppSpacing.huge,
          ),
          children: [
            _ItemActions(
              args: args,
              state: state,
              planTime: planTime,
              onOpenTimer: onOpenTimer,
            ),
            if (state.saveStatus == SaveStatus.failed) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.itemSaveFailed,
                style: context.textStyles.bodyMedium?.copyWith(
                  color: context.colors.danger,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            LastTimeCard(args: args, state: state),
            if (type != null && fields.isNotEmpty)
              AddDetailScope(
                onAddDetail: (group) =>
                    unawaited(_addToLog(context, ref, args, state, group)),
                child: RowMemoryScope(
                  except: state.logId,
                  child: RestTimerScope(
                    onRest: ref.read(restTimerProvider.notifier).start,
                    child: ActivityLogFormFields(
                      boxed: true,
                      type: type,
                      fields: fields,
                      values: state.values,
                      issues: state.issues,
                      onChanged: notifier.setValue,
                    ),
                  ),
                ),
              )
            else ...[
              // Nothing to log yet: the likely things, one tap each (B3).
              Text(l10n.itemNothingToLogHint, style: quiet),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final option in quickLogOptions(l10n).take(3))
                    ActionChip(
                      avatar: Icon(option.icon),
                      label: Text(option.label),
                      onPressed: () => unawaited(
                        _addToLog(
                          context,
                          ref,
                          args,
                          state,
                          null,
                          preset: option.choice,
                        ),
                      ),
                    ),
                  ActionChip(
                    label: Text(l10n.itemQuickMore),
                    onPressed: () =>
                        unawaited(_addToLog(context, ref, args, state, null)),
                  ),
                ],
              ),
            ],
            // Anything can be logged, added right here (ADR-035).
            if (type != null && fields.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: AppButton(
                  label: l10n.itemAddToLog,
                  icon: AppIcons.add,
                  variant: AppButtonVariant.secondary,
                  onPressed: () =>
                      unawaited(_addToLog(context, ref, args, state, null)),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            // Notes, when and how long: one card of details (ADR-045).
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.itemDetailsSection,
                    style: context.textStyles.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FieldEditorShell(
                    label: l10n.notesLabel,
                    error: firstIssueMessage(l10n, state.issues, 'notes'),
                    child: TextFormField(
                      initialValue: state.notes,
                      minLines: 3,
                      maxLines: 12,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: notifier.setNotes,
                    ),
                  ),
                  FieldEditorShell(
                    label: l10n.itemWhenSection,
                    child: _StartedAtPicker(
                      value: state.startedAt,
                      onChanged: notifier.setStartedAt,
                    ),
                  ),
                  FieldEditorShell(
                    label: l10n.durationLabel,
                    error: firstIssueMessage(l10n, state.issues, 'duration'),
                    child: DurationInput(
                      milliseconds: state.durationMs,
                      onChanged: notifier.setDuration,
                    ),
                  ),
                ],
              ),
            ),
            // Plan ahead from here: next appointment, next session (ADR-036).
            if (plan != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(AppIcons.planNext),
                  label: Text(l10n.planNextAction),
                  onPressed: () =>
                      unawaited(_planNext(context, ref, plan, onOpenItem)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The top of a thing (ADR-046): what state it's in and the one action that
/// moves it on.
/// - **Ready:** its time and "Planned"; **Start** (a timed activity) with
///   **Done** under it, or **Done** alone.
/// - **Running:** the live timer, Pause and **Finish**.
/// - **Done** (the inspect view, A7): the result, the streak it keeps, the
///   day's progress; **Not done** and **Time again**.
///
/// Finishing (Done or Finish) closes the thing and returns to where it was
/// opened, after "How did it go?" when the activity has meaningful details;
/// the row there shows the result.
class _ItemActions extends ConsumerWidget {
  const _ItemActions({
    required this.args,
    required this.state,
    required this.planTime,
    required this.onOpenTimer,
  });

  final ItemArgs args;
  final ItemState state;
  final String? planTime;
  final VoidCallback onOpenTimer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final plan = state.plan;
    final type = state.type;
    final session = ref.watch(activeFocusSessionProvider).value;
    final timerHere =
        session != null && plan != null && session.planId == plan.id;
    final canTime = plan != null && (type == null || type.supportsTimer);
    final today = currentLocalDate(ref.watch(clockProvider));
    final done = state.isDoneOn(today);

    if (timerHere) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Meta(
              chip: StatusChip(
                label: l10n.itemLive.toUpperCase(),
                tone: StatusTone.active,
                filled: true,
              ),
              planTime: planTime,
            ),
            const SizedBox(height: AppSpacing.lg),
            _ItemTimer(
              session: session,
              onFinish: () => _finish(context, ref, session),
              onOpenTimer: onOpenTimer,
            ),
          ],
        ),
      );
    }

    if (done) return _DoneHeader(args: args, state: state);

    final otherRunning = session != null && !timerHere;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Meta(
            chip: plan == null
                ? null
                : StatusChip(
                    label: l10n.planStatusPlanned,
                    tone: StatusTone.scheduled,
                  ),
            planTime: planTime,
          ),
          if (plan?.notes case final notes? when notes.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              notes.trim().split('\n').first,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodyLarge?.copyWith(
                color: c.textSecondary,
              ),
            ),
          ],
          if (plan != null) ...[
            const SizedBox(height: AppSpacing.lg),
            if (canTime) ...[
              AppButton(
                label: l10n.todayUpNextStart,
                icon: AppIcons.start,
                variant: AppButtonVariant.action,
                expand: true,
                onPressed: () => otherRunning
                    ? _startAfterOther(context, ref, plan, session)
                    : _startTimer(context, ref, plan),
              ),
              const SizedBox(height: AppSpacing.xs),
              AppButton(
                label: l10n.itemDone,
                icon: AppIcons.check,
                variant: AppButtonVariant.tertiary,
                expand: true,
                onPressed: () => _done(context, ref),
              ),
            ] else
              AppButton(
                label: l10n.itemDone,
                icon: AppIcons.check,
                variant: AppButtonVariant.action,
                expand: true,
                onPressed: () => _done(context, ref),
              ),
          ],
        ],
      ),
    );
  }

  /// Runs [action], then reloads the item; failures show safe copy.
  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() action,
  ) async {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(itemProvider(args).notifier);
    try {
      await notifier.flush();
      await action();
      await notifier.reload();
    } catch (error) {
      if (context.mounted) {
        showMessageSnackBar(context, errorMessage(l10n, error));
      }
    }
  }

  Future<void> _startTimer(BuildContext context, WidgetRef ref, Plan plan) =>
      _run(context, ref, () async {
        final typeId =
            state.type?.id ??
            await ref.read(ensureItemActivityProvider)(plan.id);
        await ref.read(startFocusSessionProvider)(typeId, planId: plan.id);
      });

  /// One timer at a time (R2): finish the other one first, then start.
  Future<void> _startAfterOther(
    BuildContext context,
    WidgetRef ref,
    Plan plan,
    FocusSession other,
  ) async {
    final l10n = AppLocalizations.of(context);
    final otherType = await ref.read(
      activityTypeProvider(other.activityTypeId).future,
    );
    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.oneTimerTitle(otherType?.name ?? '', state.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.oneTimerConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await PlanActions(
      context,
      ref,
    ).finish(other, title: otherType?.name ?? '', type: otherType);
    if (context.mounted) await _startTimer(context, ref, plan);
  }

  /// Done (ADR-046): marks it done ("How did it go?" first when it applies)
  /// and returns to where it was opened.
  Future<void> _done(BuildContext context, WidgetRef ref) async {
    final plan = state.plan!;
    final notifier = ref.read(itemProvider(args).notifier);
    await notifier.flush();
    if (!context.mounted) return;
    await PlanActions(context, ref).complete(
      PlannedItem(
        plan: plan,
        type: state.type,
        records: const [],
        status: EffectivePlanStatus.planned,
      ),
    );
    if (context.mounted) Navigator.of(context).maybePop();
  }

  /// Finish (ADR-046): stops the timer (done, with its time), "How did it
  /// go?" when it applies, then back to where it was opened.
  Future<void> _finish(
    BuildContext context,
    WidgetRef ref,
    FocusSession session,
  ) async {
    await ref.read(itemProvider(args).notifier).flush();
    if (!context.mounted) return;
    await PlanActions(
      context,
      ref,
    ).finish(session, title: state.title, type: state.type);
    if (context.mounted) Navigator.of(context).maybePop();
  }
}

/// The status chip and planned time at the top of a thing.
class _Meta extends StatelessWidget {
  const _Meta({required this.chip, required this.planTime});

  final Widget? chip;
  final String? planTime;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.sm,
    runSpacing: AppSpacing.xs,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      ?chip,
      if (planTime case final time?)
        Text(
          time,
          style: context.textStyles.labelMedium?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
    ],
  );
}

/// A done thing's header (A7, ADR-046): "Done ✓", its result big, the streak
/// it kept and the day's progress, with **Not done** and **Time again**.
class _DoneHeader extends ConsumerWidget {
  const _DoneHeader({required this.args, required this.state});

  final ItemArgs args;
  final ItemState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final plan = state.plan;
    final type = state.type;
    final today = currentLocalDate(ref.watch(clockProvider));
    final overview = plan == null
        ? null
        : ref.watch(dayOverviewProvider(plan.planDate)).value;
    final item = overview?.planned
        .where((i) => i.plan.id == plan!.id)
        .firstOrNull;
    final result = item == null
        ? (state.durationMs == null
              ? l10n.planStatusDone
              : formatDuration(l10n, state.durationMs!))
        : formatItemResult(context, item);
    final streak = type == null
        ? null
        : ref.watch(activityStreaksProvider)[type.id];
    final progress = overview != null && plan!.planDate == today
        ? DayProgress.of(overview)
        : null;
    final session = ref.watch(activeFocusSessionProvider).value;
    final canTime =
        plan != null && session == null && (type == null || type.supportsTimer);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              StatusChip(
                label: l10n.itemDone,
                tone: StatusTone.done,
                icon: AppIcons.check,
              ),
              const Spacer(),
              // Anything marked done can be reopened (ADR-040).
              if (plan != null && plan.status == PlanStatus.completed)
                TextButton(
                  onPressed: () => _reopen(context, ref, plan),
                  child: Text(l10n.itemNotDone),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(result, style: context.textStyles.headlineSmall),
          if (streak != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                StreakBadge(days: streak.days),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.itemStreakLine(streak.days),
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          if (progress != null && !progress.isEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.itemDayLine(progress.done, progress.total),
              style: context.textStyles.bodyMedium?.copyWith(
                color: c.textSecondary,
              ),
            ),
          ],
          if (canTime) ...[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: AppButton(
                label: l10n.itemTimeAgain,
                icon: AppIcons.start,
                variant: AppButtonVariant.secondary,
                onPressed: () => _timeAgain(context, ref, plan),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _reopen(BuildContext context, WidgetRef ref, Plan plan) async {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(itemProvider(args).notifier);
    try {
      await notifier.flush();
      await ref.read(setPlanStatusProvider)(plan.id, PlanStatus.planned);
      await notifier.reload();
    } catch (error) {
      if (context.mounted) {
        showMessageSnackBar(context, errorMessage(l10n, error));
      }
    }
  }

  Future<void> _timeAgain(
    BuildContext context,
    WidgetRef ref,
    Plan plan,
  ) async {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(itemProvider(args).notifier);
    try {
      await notifier.flush();
      final typeId =
          state.type?.id ?? await ref.read(ensureItemActivityProvider)(plan.id);
      await ref.read(startFocusSessionProvider)(typeId, planId: plan.id);
      await notifier.reload();
    } catch (error) {
      if (context.mounted) {
        showMessageSnackBar(context, errorMessage(l10n, error));
      }
    }
  }
}

/// The running timer inside its item: you keep logging while it runs. Big
/// time, then Pause or Resume, Finish, and full screen.
class _ItemTimer extends ConsumerWidget {
  const _ItemTimer({
    required this.session,
    required this.onFinish,
    required this.onOpenTimer,
  });

  final FocusSession session;
  final VoidCallback onFinish;
  final VoidCallback onOpenTimer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(focusTickProvider);
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final now = ref.watch(clockProvider).nowUtc();
    final paused = session.state == FocusState.paused;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          (paused ? l10n.focusPaused : l10n.itemTimeSoFar).toUpperCase(),
          style: context.textStyles.labelSmall?.copyWith(
            color: c.textSecondary,
          ),
        ),
        Semantics(
          label: paused ? l10n.focusPaused : l10n.focusRunning,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatTimer(session.elapsedMs(now)),
              style: AppTypography.numericHero.copyWith(
                color: paused ? c.textSecondary : c.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            IconButton.filledTonal(
              style: IconButton.styleFrom(
                backgroundColor: c.brandPrimarySoft,
                foregroundColor: c.onBrandPrimarySoft,
              ),
              tooltip: paused ? l10n.focusResume : l10n.focusPause,
              icon: Icon(paused ? AppIcons.start : AppIcons.pause),
              onPressed: () => unawaited(
                paused
                    ? ref.read(resumeFocusSessionProvider)(session.id)
                    : ref.read(pauseFocusSessionProvider)(session.id),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: c.textPrimary,
                  foregroundColor: c.surfaceBase,
                ),
                icon: const Icon(AppIcons.check),
                label: Text(l10n.focusFinish),
                onPressed: onFinish,
              ),
            ),
            IconButton(
              tooltip: l10n.itemTimerFullScreen,
              icon: const Icon(AppIcons.timer),
              onPressed: onOpenTimer,
            ),
          ],
        ),
      ],
    );
  }
}

class _StartedAtPicker extends StatelessWidget {
  const _StartedAtPicker({required this.value, required this.onChanged});

  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final material = MaterialLocalizations.of(context);
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        OutlinedButton.icon(
          icon: const Icon(AppIcons.date),
          label: Text(material.formatMediumDate(value)),
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: value,
              firstDate: DateTime(1900),
              lastDate: DateTime(2200),
            );
            if (date != null) {
              onChanged(
                DateTime(
                  date.year,
                  date.month,
                  date.day,
                  value.hour,
                  value.minute,
                ),
              );
            }
          },
        ),
        OutlinedButton.icon(
          icon: const Icon(AppIcons.time),
          label: Text(material.formatTimeOfDay(TimeOfDay.fromDateTime(value))),
          onPressed: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(value),
            );
            if (time != null) {
              onChanged(
                DateTime(
                  value.year,
                  value.month,
                  value.day,
                  time.hour,
                  time.minute,
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

/// Adds something new to log to the item (or a detail to the list [parent]),
/// then reloads it with what's been entered kept (ADR-035). A [preset] (a
/// quick choice, B3) skips the "What do you want to log?" sheet.
Future<void> _addToLog(
  BuildContext context,
  WidgetRef ref,
  ItemArgs args,
  ItemState state,
  ActivityField? parent, {
  Object? preset,
}) async {
  final l10n = AppLocalizations.of(context);
  final type = state.type;
  var depth = 0;
  if (parent != null && type != null) {
    // The new detail sits inside [parent] and every list containing it.
    ActivityFieldId? id = parent.id;
    while (id != null) {
      depth++;
      id = type.fieldById(id)?.parentId;
    }
  }
  final field = preset == null
      ? await showAddToLogSheet(context, depth: depth)
      : await configureChoice(context, preset, depth: depth);
  if (field == null || !context.mounted) return;
  final notifier = ref.read(itemProvider(args).notifier);
  try {
    await notifier.flush();
    await ref.read(addItemFieldProvider)(
      field,
      planId: state.plan?.id,
      typeId: type?.id,
      parentId: parent?.id,
    );
    await notifier.reload();
  } on ValidationException catch (e) {
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
}

/// "Plan next…": pick a date (and, for a timed plan, a time) for the same
/// thing again (ADR-036).
Future<void> _planNext(
  BuildContext context,
  WidgetRef ref,
  Plan plan,
  ValueChanged<PlanId>? onOpenItem,
) async {
  final l10n = AppLocalizations.of(context);
  final material = MaterialLocalizations.of(context);
  final today = currentLocalDate(ref.read(clockProvider));
  final suggested = plan.planDate.addDays(7);
  final initial = suggested.compareTo(today) < 0 ? today : suggested;
  final picked = await showDatePicker(
    context: context,
    initialDate: DateTime(initial.year, initial.month, initial.day),
    firstDate: DateTime(today.year, today.month, today.day),
    lastDate: DateTime(today.year + 5),
  );
  if (picked == null || !context.mounted) return;
  DateTime? startAt;
  if (plan.plannedStartAt case final start?) {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(start.toLocal()),
    );
    if (!context.mounted) return;
    if (time != null) {
      startAt = DateTime(
        picked.year,
        picked.month,
        picked.day,
        time.hour,
        time.minute,
      ).toUtc();
    }
  }
  try {
    final id = await ref.read(planNextProvider)(
      plan.id,
      LocalDate(picked.year, picked.month, picked.day),
      startAt: startAt,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            l10n.planNextPlanned(material.formatMediumDate(picked)),
          ),
          action: onOpenItem == null
              ? null
              : SnackBarAction(
                  label: l10n.actionOpen,
                  onPressed: () => onOpenItem(id),
                ),
        ),
      );
  } catch (error) {
    if (context.mounted) {
      showMessageSnackBar(context, errorMessage(l10n, error));
    }
  }
}
