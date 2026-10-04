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
import '../../../../shared/widgets/state_views.dart';
import '../../../activity_logs/presentation/activity_log_providers.dart';
import '../../../activity_logs/presentation/form/activity_log_form.dart';
import '../../../activity_logs/presentation/form/add_detail_scope.dart';
import '../../../activity_logs/presentation/form/date_time_editors.dart';
import '../../../activity_logs/presentation/form/field_editor_shell.dart';
import '../../../activity_logs/presentation/value_formatting.dart';
import '../../../activity_types/domain/activity_ids.dart';
import '../../../activity_types/domain/activity_type.dart';
import '../../../focus/domain/focus_session.dart';
import '../../../focus/domain/focus_use_cases.dart';
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
            if (planTime != null) Text(planTime, style: quiet),
            if (state.saveStatus == SaveStatus.failed) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.itemSaveFailed,
                style: context.textStyles.bodyMedium?.copyWith(
                  color: context.colors.danger,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            _ItemActions(args: args, state: state, onOpenTimer: onOpenTimer),
            const SizedBox(height: AppSpacing.lg),
            if (type != null && fields.isNotEmpty)
              AddDetailScope(
                onAddDetail: (group) =>
                    unawaited(_addToLog(context, ref, args, state, group)),
                child: ActivityLogFormFields(
                  type: type,
                  fields: fields,
                  values: state.values,
                  issues: state.issues,
                  onChanged: notifier.setValue,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Text(l10n.itemNothingToLogHint, style: quiet),
              ),
            // Anything can be logged, added right here (ADR-035).
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
            if (plan != null) _MarkDone(args: args, state: state),
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

/// Done / timer controls at the top of an item.
class _ItemActions extends ConsumerWidget {
  const _ItemActions({
    required this.args,
    required this.state,
    required this.onOpenTimer,
  });

  final ItemArgs args;
  final ItemState state;
  final VoidCallback onOpenTimer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final plan = state.plan;
    final session = ref.watch(activeFocusSessionProvider).value;
    final timerHere =
        session != null && plan != null && session.planId == plan.id;
    final canTime =
        plan != null && (state.type == null || state.type!.supportsTimer);

    final done = state.isDoneOn(currentLocalDate(ref.watch(clockProvider)));
    // "Mark done" sits at the bottom of the item (A10): logging doesn't
    // finish it.
    final children = <Widget>[
      if (done && !timerHere) _DoneChip(label: l10n.itemDone),
      // Anything marked done can be reopened (ADR-040).
      if (plan != null && plan.status == PlanStatus.completed && !timerHere)
        TextButton(
          onPressed: () => _run(context, ref, () async {
            await ref.read(setPlanStatusProvider)(plan.id, PlanStatus.planned);
          }),
          child: Text(l10n.planReopenTask),
        ),
      if (canTime && session == null)
        AppButton(
          label: l10n.itemStartTimer,
          icon: AppIcons.start,
          variant: AppButtonVariant.secondary,
          onPressed: () => _startTimer(context, ref, plan),
        ),
      if (canTime && session != null && !timerHere)
        Text(
          l10n.itemTimerOtherRunning,
          style: context.textStyles.bodyMedium?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (timerHere)
          _ItemTimer(
            session: session,
            onFinish: () => _finishTimer(context, ref, session),
            onOpenTimer: onOpenTimer,
          ),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: children,
        ),
      ],
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

  Future<void> _finishTimer(
    BuildContext context,
    WidgetRef ref,
    FocusSession session,
  ) async {
    final l10n = AppLocalizations.of(context);
    final (_, elapsed) = FinishFocusSession.endOf(
      session,
      ref.read(clockProvider).nowUtc(),
    );
    await _run(context, ref, () async {
      await ref.read(finishFocusSessionProvider)(session.id);
    });
    if (context.mounted) {
      showMessageSnackBar(
        context,
        l10n.focusComplete(state.title, formatDuration(l10n, elapsed)),
      );
    }
  }
}

/// "Mark done" at the end of an item (A10, ADR-040): logging into an item
/// doesn't finish it; this does. Hidden once done or while its timer runs
/// (finishing the timer finishes the item).
class _MarkDone extends ConsumerWidget {
  const _MarkDone({required this.args, required this.state});

  final ItemArgs args;
  final ItemState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final plan = state.plan!;
    final session = ref.watch(activeFocusSessionProvider).value;
    final today = currentLocalDate(ref.watch(clockProvider));
    if (state.isDoneOn(today) || session?.planId == plan.id) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.hasLog) ...[
            Text(
              l10n.itemMarkDoneHint,
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          AppButton(
            label: l10n.itemMarkDone,
            icon: AppIcons.taskDone,
            onPressed: () async {
              final notifier = ref.read(itemProvider(args).notifier);
              try {
                await notifier.flush();
                await ref.read(markItemDoneProvider)(plan.id);
                await notifier.reload();
              } catch (error) {
                if (context.mounted) {
                  showMessageSnackBar(context, errorMessage(l10n, error));
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _DoneChip extends StatelessWidget {
  const _DoneChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(AppIcons.taskDone, color: context.colors.success),
      const SizedBox(width: AppSpacing.xs),
      Text(label, style: context.textStyles.titleMedium),
    ],
  );
}

/// The running timer inside its item: you keep logging while it runs.
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
    final now = ref.watch(clockProvider).nowUtc();
    final paused = session.state == FocusState.paused;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              label: paused ? l10n.focusPaused : l10n.focusRunning,
              child: Text(
                formatTimer(session.elapsedMs(now)),
                style: AppTypography.numericMedium.copyWith(
                  color: paused
                      ? context.colors.textSecondary
                      : context.colors.textPrimary,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: paused ? l10n.focusResume : l10n.focusPause,
            icon: Icon(paused ? AppIcons.start : AppIcons.pause),
            onPressed: () => unawaited(
              paused
                  ? ref.read(resumeFocusSessionProvider)(session.id)
                  : ref.read(pauseFocusSessionProvider)(session.id),
            ),
          ),
          TextButton(onPressed: onFinish, child: Text(l10n.focusFinish)),
          IconButton(
            tooltip: l10n.itemTimerFullScreen,
            icon: const Icon(AppIcons.timer),
            onPressed: onOpenTimer,
          ),
        ],
      ),
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
/// then reloads it with what's been entered kept (ADR-035).
Future<void> _addToLog(
  BuildContext context,
  WidgetRef ref,
  ItemArgs args,
  ItemState state,
  ActivityField? parent,
) async {
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
  final field = await showAddToLogSheet(context, depth: depth);
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
