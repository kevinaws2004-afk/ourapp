import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/errors/error_copy.dart';
import '../../../shared/widgets/state_views.dart';
import '../../activity_logs/presentation/form/date_time_editors.dart';
import '../../activity_logs/presentation/form/field_editor_shell.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../domain/plan.dart';
import '../domain/watch_day_overview.dart';
import 'plan_providers.dart';
import '../../../shared/widgets/discard_guard.dart';

/// An action chosen in the plan sheet, run by the screen that opened it
/// (the sheet's own state is gone once it closes).
enum PlanSheetAction {
  toggleDone,
  repeat,
  stopRepeating,
  skip,
  reopen,
  moveToTomorrow,
  delete,
}

/// Creates a plan for [date] ([item] null) or edits [item] and offers its
/// actions: complete a task, repeat (or stop), skip, reopen, move to tomorrow,
/// delete (FR-PL-01…07, F5, F10, F11). Saving happens in the sheet; an
/// action is returned to the caller.
Future<PlanSheetAction?> showPlanEditor(
  BuildContext context, {
  required LocalDate date,
  PlannedItem? item,
}) => showModalBottomSheet<PlanSheetAction>(
  context: context,
  isScrollControlled: true,
  builder: (_) => _PlanEditorSheet(date: date, item: item),
);

class _PlanEditorSheet extends ConsumerStatefulWidget {
  const _PlanEditorSheet({required this.date, this.item});

  final LocalDate date;
  final PlannedItem? item;

  @override
  ConsumerState<_PlanEditorSheet> createState() => _PlanEditorSheetState();
}

class _PlanEditorSheetState extends ConsumerState<_PlanEditorSheet> {
  Plan? get _plan => widget.item?.plan;

  late final _title = TextEditingController(text: _plan?.title ?? '');
  late final _notes = TextEditingController(text: _plan?.notes ?? '');
  late ActivityTypeId? _typeId = _plan?.activityTypeId;
  late TimeOfDay? _start = _timeOf(_plan?.plannedStartAt);
  late TimeOfDay? _end = _timeOf(_plan?.plannedEndAt);
  late int? _durationMs = _plan?.plannedDurationMs;
  List<ValidationIssue> _issues = const [];
  bool _saving = false;

  static TimeOfDay? _timeOf(DateTime? instant) =>
      instant == null ? null : TimeOfDay.fromDateTime(instant.toLocal());

  LocalDate get _date => _plan?.planDate ?? widget.date;

  DateTime? _instant(TimeOfDay? time) => time == null
      ? null
      : DateTime(
          _date.year,
          _date.month,
          _date.day,
          time.hour,
          time.minute,
        ).toUtc();

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final draft = PlanDraft(
      planDate: _date,
      title: _title.text,
      activityTypeId: _typeId,
      notes: _notes.text,
      plannedStartAt: _instant(_start),
      plannedEndAt: _start == null ? null : _instant(_end),
      plannedDurationMs: _end == null ? _durationMs : null,
    );
    setState(() {
      _saving = true;
      _issues = const [];
    });
    try {
      if (_plan case final plan?) {
        await ref.read(updatePlanProvider)(plan.id, draft);
      } else {
        await ref.read(createPlanProvider)(draft);
      }
      if (mounted) Navigator.of(context).pop();
    } on ValidationException catch (e) {
      setState(() => _issues = e.issues);
    } catch (error) {
      if (mounted) showMessageSnackBar(context, errorMessage(l10n, error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickTime({required bool end}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          (end ? _end : _start) ??
          _start ??
          const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked == null) return;
    setState(() {
      if (end) {
        _end = picked;
        _durationMs = null;
      } else {
        _start = picked;
      }
    });
  }

  /// Something was changed (A15).
  bool get _dirty =>
      !_saving &&
      (_title.text != (_plan?.title ?? '') ||
          _notes.text != (_plan?.notes ?? '') ||
          _typeId != _plan?.activityTypeId ||
          _start != _timeOf(_plan?.plannedStartAt) ||
          _end != _timeOf(_plan?.plannedEndAt) ||
          _durationMs != _plan?.plannedDurationMs);

  @override
  void initState() {
    super.initState();
    // Rebuild on typing so the discard guard knows about it (A15).
    _title.addListener(() => setState(() {}));
    _notes.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) =>
      DiscardGuard(dirty: _dirty, child: _buildSheet(context));

  Widget _buildSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    final item = widget.item;
    final plannable = [
      ...?ref
          .watch(activeActivityTypesProvider)
          .value
          ?.where((t) => t.supportsPlanning),
    ];
    // Keep an existing plan's activity selectable even if archived since.
    final current = item?.type;
    final choices = <ActivityType>[
      ...plannable,
      if (current != null && !plannable.any((t) => t.id == current.id)) current,
    ];
    String? issue(String target) => firstIssueMessage(l10n, _issues, target);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.9,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              0,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            children: [
              Text(
                item == null ? l10n.planNewTitle : l10n.planEditTitle,
                style: context.textStyles.titleLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _title,
                autofocus: item == null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.planTitleLabel,
                  helperText: l10n.planTitleHelper,
                  errorText: issue('title'),
                ),
              ),
              FieldEditorShell(
                label: l10n.planActivityLabel,
                error: issue('activity'),
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    ChoiceChip(
                      label: Text(l10n.planTaskChoice),
                      selected: _typeId == null,
                      onSelected: (_) => setState(() => _typeId = null),
                    ),
                    for (final type in choices)
                      ChoiceChip(
                        label: Text(type.name),
                        selected: _typeId == type.id,
                        onSelected: (_) => setState(() => _typeId = type.id),
                      ),
                  ],
                ),
              ),
              FieldEditorShell(
                label: l10n.planStartLabel,
                error: issue('start'),
                onClear: _start == null
                    ? null
                    : () => setState(() {
                        _start = null;
                        _end = null;
                      }),
                child: OutlinedButton.icon(
                  icon: const Icon(AppIcons.time),
                  label: Text(
                    _start == null
                        ? l10n.planAnyTime
                        : material.formatTimeOfDay(_start!),
                  ),
                  onPressed: () => _pickTime(end: false),
                ),
              ),
              if (_start != null)
                FieldEditorShell(
                  label: l10n.planEndLabel,
                  error: issue('end'),
                  onClear: _end == null
                      ? null
                      : () => setState(() => _end = null),
                  child: OutlinedButton.icon(
                    icon: const Icon(AppIcons.time),
                    label: Text(
                      _end == null
                          ? l10n.planNoEnd
                          : material.formatTimeOfDay(_end!),
                    ),
                    onPressed: () => _pickTime(end: true),
                  ),
                ),
              if (_end == null)
                FieldEditorShell(
                  label: l10n.planDurationLabel,
                  error: issue('duration'),
                  child: DurationInput(
                    milliseconds: _durationMs,
                    onChanged: (ms) => _durationMs = ms,
                  ),
                ),
              FieldEditorShell(
                label: l10n.notesLabel,
                error: issue('notes'),
                child: TextField(
                  controller: _notes,
                  minLines: 2,
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(l10n.actionSave),
              ),
              if (item != null) ..._actions(l10n, item),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _actions(AppLocalizations l10n, PlannedItem item) {
    final open = item.isOpen;
    final plan = item.plan;
    ListTile action(IconData icon, String label, PlanSheetAction result) =>
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon),
          title: Text(label),
          onTap: () => Navigator.of(context).pop(result),
        );
    return [
      const SizedBox(height: AppSpacing.lg),
      // Any item can be marked done (ADR-040).
      if (open)
        action(
          AppIcons.taskDone,
          l10n.planCompleteTask,
          PlanSheetAction.toggleDone,
        ),
      if (open) action(AppIcons.skip, l10n.planSkip, PlanSheetAction.skip),
      // Stored statuses reopen; something logged on a past day is done by
      // itself (ADR-040).
      if (!open &&
          (item.records.isEmpty || plan.status == PlanStatus.completed))
        action(AppIcons.undo, l10n.planReopen, PlanSheetAction.reopen),
      if (open)
        action(
          AppIcons.moveToTomorrow,
          l10n.planMoveToTomorrow,
          PlanSheetAction.moveToTomorrow,
        ),
      action(AppIcons.repeat, l10n.planRepeat, PlanSheetAction.repeat),
      if (plan.isRepeating)
        action(
          AppIcons.repeat,
          l10n.planStopRepeating,
          PlanSheetAction.stopRepeating,
        ),
      action(AppIcons.delete, l10n.planDelete, PlanSheetAction.delete),
    ];
  }
}
