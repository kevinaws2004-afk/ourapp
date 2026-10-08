import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/app_icons.dart';
import '../../../../core/design/context_ext.dart';
import '../../../../core/design/tokens/spacing.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/time/clock_provider.dart';
import '../../../../core/time/local_date.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/errors/error_copy.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../../activity_types/domain/activity_ids.dart';
import '../../../activity_types/domain/activity_type.dart';
import '../../../activity_types/domain/activity_type_definition.dart';
import '../../../activity_types/presentation/activity_type_providers.dart';
import '../../../activity_types/presentation/built_in_activities.dart';
import '../../../activity_types/presentation/starter_activities.dart';
import '../../domain/plan.dart';
import '../../domain/plan_series.dart';
import '../../domain/plan_title_match.dart';
import '../activity_chooser.dart';
import '../plan_date_notifier.dart';
import '../plan_providers.dart';
import 'plan_quick_add.dart';
import 'plan_time_sheet.dart';
import 'repeat_sheet.dart';

/// The **+** sheet (ADR-046, AD1–AD6): adding to a day lives here, out of
/// the day's way. Type what it is (your activities, then built-in ones; a
/// new name becomes yours with nothing to set up), or tap a Recent one;
/// choose **When** (Anytime, Now for today, or a time and length) and
/// optionally **Repeat**; **Add** (or **Start**, with Now). It closes once
/// something is added. [onStartNow] gets a thing added with Now, to start
/// it; [startNow] opens with Now chosen.
Future<void> showAddSheet(
  BuildContext context, {
  required LocalDate date,
  required String dayName,
  required ActivityChooser chooser,
  ValueChanged<PlanId>? onStartNow,
  bool startNow = false,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (sheetContext) {
    void close() => Navigator.of(sheetContext).pop();
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        MediaQuery.viewInsetsOf(sheetContext).bottom + AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: AddToDay(
          date: date,
          dayName: dayName,
          chooser: chooser,
          startNow: startNow && onStartNow != null,
          onAdded: (_) => close(),
          onStartNow: onStartNow == null
              ? null
              : (id) {
                  close();
                  onStartNow(id);
                },
        ),
      ),
    );
  },
);

enum _When { anytime, now, time }

/// The add sheet's content (AD1–AD5).
class AddToDay extends ConsumerStatefulWidget {
  const AddToDay({
    super.key,
    required this.date,
    required this.dayName,
    required this.chooser,
    required this.onAdded,
    this.onStartNow,
    this.startNow = false,
  });

  /// Recent (or common) activities shown.
  static const maxChips = 8;

  /// Common activities offered on first use.
  static const maxCommon = 6;

  final LocalDate date;
  final String dayName;
  final ActivityChooser chooser;
  final ValueChanged<PlanId> onAdded;

  /// Offers **Now** (today): the thing is added and started.
  final ValueChanged<PlanId>? onStartNow;
  final bool startNow;

  @override
  ConsumerState<AddToDay> createState() => _AddToDayState();
}

class _AddToDayState extends ConsumerState<AddToDay> {
  final _title = TextEditingController();
  ActivityTypeId? _typeId;
  bool _matchedByName = false;

  /// A new name chosen to become an activity of yours (AD3).
  bool _makeYours = false;
  late _When _when = widget.startNow ? _When.now : _When.anytime;
  LocalTime? _start;
  LocalTime? _end;
  RepeatRule? _repeat;
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  bool get _hasInput => _title.text.trim().isNotEmpty || _typeId != null;

  void _onTitleChanged(String text) {
    _makeYours = false;
    if (_typeId != null && !_matchedByName) {
      setState(() {});
      return;
    }
    final match = matchByName(
      text,
      ref.read(recentActivityTypesProvider),
      (t) => t.name,
    );
    setState(() {
      _typeId = match?.id;
      _matchedByName = match != null;
    });
  }

  void _useName(String name) {
    _title.value = TextEditingValue(
      text: name,
      selection: TextSelection.collapsed(offset: name.length),
    );
    _typeId = null;
    _matchedByName = false;
    _onTitleChanged(name);
  }

  void _select(ActivityType type) {
    _title.value = TextEditingValue(
      text: type.name,
      selection: TextSelection.collapsed(offset: type.name.length),
    );
    setState(() {
      _typeId = type.id;
      _matchedByName = true;
      _makeYours = false;
    });
  }

  DateTime? _instant(LocalTime? time) {
    final date = widget.date;
    return time == null
        ? null
        : DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          ).toUtc();
  }

  /// The chosen activity, one of yours with the typed name, or a built-in
  /// one with it (saved as yours now). Null for a new name.
  Future<ActivityTypeId?> _resolveActivity(AppLocalizations l10n) async {
    if (_typeId case final id?) return id;
    final active = ref.read(activeActivityTypesProvider).value ?? const [];
    if (matchByName(_title.text, active, (t) => t.name) case final type?) {
      return type.id;
    }
    final builtIn = matchByName<ActivityTypeDefinition>(
      _title.text,
      builtInActivities(l10n),
      (t) => t.name,
    );
    if (builtIn == null) return null;
    return ref.read(addBuiltInActivityProvider)(builtIn);
  }

  Future<void> _add() async {
    if (!_hasInput || _busy) return;
    final l10n = AppLocalizations.of(context);
    final now = _when == _When.now;
    setState(() => _busy = true);
    try {
      final typeId = await _resolveActivity(l10n);
      final timed = _when == _When.time && _start != null;
      final id = await ref.read(createPlanProvider)(
        PlanDraft(
          planDate: widget.date,
          // With an activity, the plan takes its name.
          title: typeId == null ? _title.text.trim() : '',
          activityTypeId: typeId,
          plannedStartAt: now
              ? ref.read(clockProvider).nowUtc()
              : timed
              ? _instant(_start)
              : null,
          plannedEndAt: timed ? _instant(_end) : null,
        ),
      );
      // A new name becomes an activity of yours, with nothing to set up
      // (AD3); what it records can be added later.
      if (typeId == null) await ref.read(ensureItemActivityProvider)(id);
      if (_repeat case final rule? when !now) {
        await ref.read(repeatPlanProvider)(id, rule);
      }
      if (!mounted) return;
      if (now) {
        widget.onStartNow?.call(id);
      } else {
        widget.onAdded(id);
      }
    } on ValidationException catch (e) {
      if (mounted) {
        showMessageSnackBar(
          context,
          validationMessage(l10n, e.issues.first.code),
        );
      }
    } catch (error) {
      if (mounted) showMessageSnackBar(context, errorMessage(l10n, error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickTime() async {
    final clock = ref.read(clockProvider);
    final nowUtc = clock.nowUtc();
    final local = nowUtc.add(clock.offsetAt(nowUtc));
    final choice = await showPlanTimeSheet(
      context,
      isToday: widget.date == currentLocalDate(clock),
      now: LocalTime.hm(local.hour, local.minute),
      start: _start,
      end: _end,
    );
    if (choice == null || !mounted) return;
    setState(() {
      _start = choice.start;
      _end = choice.end;
      _when = choice.start == null ? _When.anytime : _When.time;
    });
  }

  Future<void> _pickRepeat() async {
    final rule = await showRepeatSheet(context, date: widget.date);
    if (rule == null || !mounted) return;
    setState(() => _repeat = rule);
  }

  Future<void> _browse() async {
    final id = await widget.chooser.browse();
    if (id == null || !mounted) return;
    final types = await ref.read(activeActivityTypesProvider.future);
    final type = types.where((t) => t.id == id).firstOrNull;
    if (type != null && mounted) _select(type);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final recent = ref.watch(recentActivityTypesProvider);
    final active =
        ref.watch(activeActivityTypesProvider).value ?? const <ActivityType>[];
    final start = _start;
    final end = _end;
    final timeLabel = switch ((_when, start, end)) {
      (_When.time, final s?, null) => formatLocalTime(context, s),
      (_When.time, final s?, final e?) => l10n.planTimeRange(
        formatLocalTime(context, s),
        formatLocalTime(context, e),
      ),
      _ => l10n.addTimeChoose,
    };
    final common = recent.isEmpty
        ? [
            for (final d in starterActivities(l10n))
              if (matchByName(d.name, active, (a) => a.name) == null) d,
          ].take(AddToDay.maxCommon).toList()
        : const <ActivityTypeDefinition>[];
    final label = TextStyle(color: c.textSecondary);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.addSheetTitle(widget.dayName),
          style: context.textStyles.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: _title,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(hintText: l10n.addWhatHint),
          onChanged: _onTitleChanged,
          onSubmitted: (_) => _add(),
        ),
        if (_typeId == null && !_makeYours)
          ActivitySuggestions(
            text: _title.text,
            types: recent,
            builtIns: [
              for (final d in builtInActivities(l10n))
                if (matchByName(d.name, active, (a) => a.name) == null) d,
            ],
            onType: _select,
            onBuiltIn: (definition) => _useName(definition.name),
            onMakeOwn: () => setState(() => _makeYours = true),
            makeOwnLabel: l10n.addMakeYoursNamed,
            makeOwnHint: l10n.addMakeYoursHint,
          ),
        if (_makeYours)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(l10n.addMakeYoursHint, style: label),
          ),
        if (recent.isNotEmpty || common.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            recent.isNotEmpty ? l10n.planRecent : l10n.addCommon,
            style: context.textStyles.labelMedium?.copyWith(
              color: c.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              for (final type in recent.take(AddToDay.maxChips))
                ChoiceChip(
                  label: Text(type.name),
                  selected: _typeId == type.id,
                  onSelected: (_) {
                    _select(type);
                    // One tap adds it (AD1), as chosen in When.
                    if (_when != _When.now) unawaited(_add());
                  },
                ),
              for (final definition in common)
                ChoiceChip(
                  label: Text(definition.name),
                  selected: false,
                  onSelected: (_) => _useName(definition.name),
                ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text(l10n.addWhen, style: context.textStyles.labelMedium?.merge(label)),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            ChoiceChip(
              label: Text(l10n.planAnytime),
              selected: _when == _When.anytime,
              onSelected: (_) => setState(() => _when = _When.anytime),
            ),
            if (widget.onStartNow != null)
              ChoiceChip(
                label: Text(l10n.addNow),
                selected: _when == _When.now,
                onSelected: (_) => setState(() => _when = _When.now),
              ),
            ChoiceChip(
              avatar: const Icon(AppIcons.time, size: 18),
              label: Text(timeLabel),
              selected: _when == _When.time,
              onSelected: (_) => _pickTime(),
            ),
            if (_when != _When.now)
              ChoiceChip(
                avatar: const Icon(AppIcons.repeat, size: 18),
                label: Text(
                  _repeat == null
                      ? l10n.addRepeat
                      : formatWeekdays(context, _repeat!.weekdays),
                ),
                selected: _repeat != null,
                onSelected: (_) => _pickRepeat(),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: _when == _When.now ? l10n.addStartAction : l10n.addAction,
          icon: _when == _When.now ? AppIcons.start : AppIcons.add,
          variant: AppButtonVariant.action,
          expand: true,
          onPressed: _hasInput && !_busy ? _add : null,
        ),
        const SizedBox(height: AppSpacing.xs),
        Center(
          child: TextButton(onPressed: _browse, child: Text(l10n.addBrowseAll)),
        ),
      ],
    );
  }
}
