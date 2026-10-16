import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/app_icons.dart';
import '../../../../core/design/context_ext.dart';
import '../../../../core/design/tokens/spacing.dart';
import '../../../../core/time/clock_provider.dart';
import '../../../../core/time/local_date.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/errors/error_copy.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../../../shared/widgets/activity_badge.dart';
import '../../../activity_types/domain/activity_ids.dart';
import '../../../activity_types/presentation/activity_type_providers.dart';
import '../../../activity_logs/presentation/form/date_time_editors.dart';
import '../../../activity_logs/presentation/form/field_editor_shell.dart';
import '../../../focus/presentation/focus_providers.dart';
import '../../../notifications/data/reminder_store.dart';
import '../../../notifications/domain/plan_reminder.dart';
import '../../../notifications/presentation/notification_providers.dart';
import '../../../notifications/presentation/reminder_prompt.dart';
import '../../domain/plan.dart';
import '../../domain/watch_day_overview.dart';
import '../plan_actions.dart';
import '../plan_date_notifier.dart';
import '../plan_providers.dart';
import 'item_notifier.dart';

/// Everything about a planned item, edited right here (no separate edit
/// sheet): its date and time, how long, reminder, repeat, notes and the
/// time spent. Each change saves at once.
class PlanDetailsCard extends ConsumerStatefulWidget {
  const PlanDetailsCard({super.key, required this.args, required this.state});

  final ItemArgs args;
  final ItemState state;

  @override
  ConsumerState<PlanDetailsCard> createState() => _PlanDetailsCardState();
}

class _PlanDetailsCardState extends ConsumerState<PlanDetailsCard> {
  Timer? _lengthDebounce;
  Timer? _titleDebounce;

  Plan get _plan => widget.state.plan!;

  @override
  void dispose() {
    _lengthDebounce?.cancel();
    _titleDebounce?.cancel();
    super.dispose();
  }

  /// [plan]'s local time of day, or null.
  TimeOfDay? _timeOf(DateTime? utc) =>
      utc == null ? null : TimeOfDay.fromDateTime(utc.toLocal());

  DateTime _instant(LocalDate date, TimeOfDay t) =>
      DateTime(date.year, date.month, date.day, t.hour, t.minute).toUtc();

  /// Saves the plan with some of its values changed.
  Future<void> _save({
    String? title,
    ActivityTypeId? Function()? activity,
    LocalDate? date,
    DateTime? Function()? start,
    DateTime? Function()? end,
    int? Function()? duration,
  }) async {
    final l10n = AppLocalizations.of(context);
    final plan = _plan;
    final draft = PlanDraft(
      planDate: date ?? plan.planDate,
      title: title ?? plan.title,
      activityTypeId: activity != null ? activity() : plan.activityTypeId,
      notes: plan.notes,
      plannedStartAt: start != null ? start() : plan.plannedStartAt,
      plannedEndAt: end != null ? end() : plan.plannedEndAt,
      plannedDurationMs: duration != null ? duration() : plan.plannedDurationMs,
    );
    try {
      await ref.read(updatePlanProvider)(plan.id, draft);
      await ref.read(itemProvider(widget.args).notifier).reload();
    } catch (error) {
      if (mounted) showMessageSnackBar(context, errorMessage(l10n, error));
    }
  }

  Future<void> _pickDate() async {
    final plan = _plan;
    final d = plan.planDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(d.year, d.month, d.day),
      firstDate: DateTime(d.year - 1),
      lastDate: DateTime(d.year + 3),
    );
    if (picked == null || !mounted) return;
    final date = LocalDate(picked.year, picked.month, picked.day);
    // Keep the same time of day on the new date.
    final start = _timeOf(plan.plannedStartAt);
    final end = _timeOf(plan.plannedEndAt);
    await _save(
      date: date,
      start: () => start == null ? null : _instant(date, start),
      end: () => end == null ? null : _instant(date, end),
    );
  }

  Future<void> _pickStart() async {
    final plan = _plan;
    final current = _timeOf(plan.plannedStartAt);
    final picked = await showTimePicker(
      context: context,
      initialTime: current ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked == null || !mounted) return;
    final start = _instant(plan.planDate, picked);
    // An end time moves with the start, keeping the length.
    final length = plan.plannedEndAt?.difference(plan.plannedStartAt!);
    await _save(
      start: () => start,
      end: () => length == null ? null : start.add(length),
    );
  }

  Future<void> _pickEnd() async {
    final plan = _plan;
    final start = plan.plannedStartAt!;
    final current = _timeOf(plan.plannedEndAt);
    final picked = await showTimePicker(
      context: context,
      initialTime:
          current ??
          TimeOfDay.fromDateTime(
            start
                .add(Duration(milliseconds: plan.plannedLengthMs ?? 3600000))
                .toLocal(),
          ),
    );
    if (picked == null || !mounted) return;
    final end = _instant(plan.planDate, picked);
    if (end.isBefore(start)) {
      showMessageSnackBar(
        context,
        AppLocalizations.of(context).validationEndBeforeStart,
      );
      return;
    }
    await _save(end: () => end, duration: () => null);
  }

  /// Keeps the length as a duration when the end time is removed.
  Future<void> _clearEnd() =>
      _save(end: () => null, duration: () => _plan.plannedLengthMs);

  Future<void> _pickActivity() async {
    final l10n = AppLocalizations.of(context);
    final plan = _plan;
    final current = widget.state.type;
    final types = [
      ...?ref
          .read(activeActivityTypesProvider)
          .value
          ?.where((t) => t.supportsPlanning),
    ];
    if (current != null && !types.any((t) => t.id == current.id)) {
      types.insert(0, current);
    }
    final picked = await showModalBottomSheet<({ActivityTypeId? id})>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.sm,
              ),
              child: Text(
                l10n.planActivityLabel,
                style: context.textStyles.headlineSmall,
              ),
            ),
            ListTile(
              leading: const Icon(AppIcons.taskDone),
              title: Text(l10n.planTaskChoice),
              trailing: current == null
                  ? Icon(AppIcons.check, color: context.colors.brandPrimary)
                  : null,
              onTap: () => Navigator.of(context).pop((id: null)),
            ),
            for (final t in types)
              ListTile(
                leading: ActivityBadge(iconId: t.iconId, colorKey: t.colorKey),
                title: Text(t.name),
                trailing: t.id == current?.id
                    ? Icon(AppIcons.check, color: context.colors.brandPrimary)
                    : null,
                onTap: () => Navigator.of(context).pop((id: t.id)),
              ),
          ],
        ),
      ),
    );
    if (picked == null || picked.id == current?.id || !mounted) return;
    // A name that was just the old activity's follows the new one.
    final ownName = current == null || plan.title != current.name;
    final title = ownName ? plan.title : '';
    if (picked.id == null && title.isEmpty) {
      await _save(title: current?.name ?? '', activity: () => null);
    } else {
      await _save(title: title, activity: () => picked.id);
    }
  }

  Future<void> _clearStart() => _save(
    start: () => null,
    end: () => null,
    duration: () => _plan.plannedLengthMs,
  );

  void _lengthChanged(int? ms) {
    _lengthDebounce?.cancel();
    _lengthDebounce = Timer(const Duration(milliseconds: 600), () {
      unawaited(_save(end: () => null, duration: () => ms));
    });
  }

  /// An item can have its own name ("Meeting with Sam"); emptied, it
  /// takes its activity's again.
  void _titleChanged(String text) {
    _titleDebounce?.cancel();
    _titleDebounce = Timer(const Duration(milliseconds: 600), () {
      final title = text.trim();
      if (title.isEmpty && widget.state.type == null) return;
      unawaited(_save(title: title));
    });
  }

  /// Changes reminder [index] of [reminders], or adds one at the end.
  Future<void> _editReminder(List<PlanReminder> reminders, int index) async {
    final plan = _plan;
    final choice = await showReminderSheet(
      context,
      title: plan.title,
      start: plan.plannedStartAt,
      current: index < reminders.length ? reminders[index] : null,
    );
    if (choice.cancelled || !mounted) return;
    final next = [...reminders];
    if (index < next.length) next.removeAt(index);
    if (choice.reminder case final r?) next.insert(index, r);
    await setRemindersFor(ref, plan.id, next);
  }

  PlannedItem _item() {
    final plan = _plan;
    final session = ref.read(activeFocusSessionProvider).value;
    return PlannedItem(
      plan: plan,
      type: widget.state.type,
      records: const [],
      status: plan.effectiveStatus(
        hasRecord: widget.state.hasLog,
        today: currentLocalDate(ref.read(clockProvider)),
        inFocus: session?.planId == plan.id,
      ),
    );
  }

  Future<void> _repeat() async {
    final actions = PlanActions(context, ref);
    if (_plan.isRepeating) {
      await actions.stopRepeating(_item());
    } else {
      await actions.repeat(_item());
    }
    await ref.read(itemProvider(widget.args).notifier).reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    final notifier = ref.read(itemProvider(widget.args).notifier);
    final state = widget.state;
    final plan = _plan;
    final start = _timeOf(plan.plannedStartAt);
    final reminders = remindersFor(
      plan,
      ref.watch(remindersProvider).value ?? const {},
    );
    final d = plan.planDate;

    Widget pill({
      required IconData icon,
      required String label,
      required VoidCallback onPressed,
    }) => OutlinedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.itemDetailsSection, style: context.textStyles.titleMedium),
          const SizedBox(height: AppSpacing.lg),
          FieldEditorShell(
            label: l10n.planTitleLabel,
            child: TextFormField(
              initialValue: plan.title,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(hintText: state.type?.name),
              onChanged: _titleChanged,
            ),
          ),
          FieldEditorShell(
            label: l10n.planActivityLabel,
            error: firstIssueMessage(l10n, state.issues, 'activity'),
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                icon: state.type == null
                    ? const Icon(AppIcons.taskDone, size: 18)
                    : ActivityBadge(
                        iconId: state.type!.iconId,
                        colorKey: state.type!.colorKey,
                        size: 22,
                      ),
                label: Text(state.type?.name ?? l10n.planTaskChoice),
                // Once something is recorded the activity is fixed.
                onPressed: state.hasLog
                    ? null
                    : () => unawaited(_pickActivity()),
              ),
            ),
          ),
          FieldEditorShell(
            label: l10n.itemWhenSectionPlan,
            onClear: start == null ? null : () => unawaited(_clearStart()),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                pill(
                  icon: AppIcons.date,
                  label: material.formatMediumDate(
                    DateTime(d.year, d.month, d.day),
                  ),
                  onPressed: () => unawaited(_pickDate()),
                ),
                pill(
                  icon: AppIcons.time,
                  label: start == null
                      ? l10n.planAnyTime
                      : material.formatTimeOfDay(start),
                  onPressed: () => unawaited(_pickStart()),
                ),
                if (start != null)
                  if (_timeOf(plan.plannedEndAt) case final end?)
                    InputChip(
                      avatar: const Icon(AppIcons.chevron, size: 18),
                      label: Text(
                        l10n.planEndsAt(material.formatTimeOfDay(end)),
                      ),
                      onPressed: () => unawaited(_pickEnd()),
                      onDeleted: () => unawaited(_clearEnd()),
                      deleteButtonTooltipMessage: l10n.planNoEnd,
                    )
                  else
                    pill(
                      icon: AppIcons.add,
                      label: l10n.planAddEnd,
                      onPressed: () => unawaited(_pickEnd()),
                    ),
              ],
            ),
          ),
          FieldEditorShell(
            label: l10n.planDurationLabel,
            child: DurationInput(
              milliseconds: plan.plannedLengthMs,
              onChanged: _lengthChanged,
            ),
          ),
          FieldEditorShell(
            label: l10n.reminderLabel,
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final (i, r) in reminders.indexed)
                  InputChip(
                    avatar: const Icon(AppIcons.bellOn, size: 18),
                    label: Text(reminderLabel(context, r)),
                    onPressed: () => unawaited(_editReminder(reminders, i)),
                    onDeleted: () => unawaited(
                      setRemindersFor(
                        ref,
                        plan.id,
                        [...reminders]..removeAt(i),
                      ),
                    ),
                  ),
                pill(
                  icon: AppIcons.add,
                  label: reminders.isEmpty
                      ? l10n.reminderAdd
                      : l10n.reminderAddAnother,
                  onPressed: () =>
                      unawaited(_editReminder(reminders, reminders.length)),
                ),
              ],
            ),
          ),
          FieldEditorShell(
            label: l10n.planRepeatLabel,
            onClear: plan.isRepeating ? () => unawaited(_repeat()) : null,
            child: Align(
              alignment: Alignment.centerLeft,
              child: pill(
                icon: AppIcons.repeat,
                label: plan.isRepeating
                    ? l10n.planRepeatsOn
                    : l10n.planRepeatOff,
                onPressed: () => unawaited(_repeat()),
              ),
            ),
          ),
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
            label: l10n.itemTimeSpent,
            error: firstIssueMessage(l10n, state.issues, 'duration'),
            child: DurationInput(
              milliseconds: state.durationMs,
              onChanged: notifier.setDuration,
            ),
          ),
        ],
      ),
    );
  }
}

/// The quiet actions at the bottom of an item: skip, move to tomorrow,
/// delete (marking done is the big button at the top).
class ItemFooterActions extends ConsumerWidget {
  const ItemFooterActions({super.key, required this.args, required this.state});

  final ItemArgs args;
  final ItemState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final plan = state.plan!;
    PlannedItem item() {
      final session = ref.read(activeFocusSessionProvider).value;
      return PlannedItem(
        plan: plan,
        type: state.type,
        records: const [],
        status: plan.effectiveStatus(
          hasRecord: state.hasLog,
          today: currentLocalDate(ref.read(clockProvider)),
          inFocus: session?.planId == plan.id,
        ),
      );
    }

    final open = item().isOpen;
    Future<void> run(Future<void> Function(PlanActions a) action) async {
      await action(PlanActions(context, ref));
      if (context.mounted) {
        await ref.read(itemProvider(args).notifier).reload();
      }
    }

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        if (open)
          TextButton.icon(
            icon: const Icon(AppIcons.skip, size: 18),
            label: Text(l10n.planSkip),
            onPressed: () => unawaited(run((a) => a.skip(item()))),
          ),
        if (open)
          TextButton.icon(
            icon: const Icon(AppIcons.moveToTomorrow, size: 18),
            label: Text(l10n.planMoveToTomorrow),
            onPressed: () => unawaited(run((a) => a.moveToTomorrow(item()))),
          ),
        if (!open && item().status != EffectivePlanStatus.completed)
          TextButton.icon(
            icon: const Icon(AppIcons.repeat, size: 18),
            label: Text(l10n.planReopen),
            onPressed: () => unawaited(run((a) => a.reopen(item()))),
          ),
        TextButton.icon(
          icon: const Icon(AppIcons.duplicate, size: 18),
          label: Text(l10n.planDuplicate),
          onPressed: () => unawaited(run((a) => a.duplicate(item()))),
        ),
        TextButton.icon(
          style: TextButton.styleFrom(foregroundColor: c.danger),
          icon: const Icon(AppIcons.delete, size: 18),
          label: Text(l10n.planDelete),
          onPressed: () async {
            await PlanActions(context, ref).delete(item());
            if (context.mounted) Navigator.of(context).maybePop();
          },
        ),
      ],
    );
  }
}
