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
import '../../../../shared/widgets/activity_badge.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../../activity_types/domain/activity_ids.dart';
import '../../../activity_types/domain/activity_type.dart';
import '../../../activity_types/domain/activity_type_definition.dart';
import '../../../activity_types/domain/activity_type_use_cases.dart';
import '../../../activity_types/presentation/activity_type_providers.dart';
import '../../../activity_types/presentation/built_in_activities.dart';
import '../../../notifications/presentation/reminder_prompt.dart';
import '../../../notifications/domain/plan_reminder.dart';
import '../../domain/plan.dart';
import '../../domain/plan_series.dart';
import '../activity_chooser.dart';
import '../plan_date_notifier.dart';
import '../plan_providers.dart';
import 'plan_time_sheet.dart';
import 'repeat_sheet.dart';

/// The **+** sheet (ADR-046): adding to a day, with every activity right
/// here. Your activities come first, then the built-in ones by category,
/// all searchable; typing something new offers it as a new activity. Tick
/// one or several. With one, choose **When** (Anytime, Now for today, or a
/// time and length), **Repeat** and **Reminder** before adding; several
/// are added as Anytime and can share a repeat. [onStartNow] gets a thing
/// added with Now, to start it; [startNow] opens with Now chosen.
Future<void> showAddSheet(
  BuildContext context, {
  required LocalDate date,
  required String dayName,
  required ActivityChooser chooser,
  ValueChanged<PlanId>? onStartNow,
  bool startNow = false,
  ActivityType? initialType,
}) => showModalBottomSheet<void>(
  useRootNavigator: true,
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (sheetContext) {
    void close() => Navigator.of(sheetContext).pop();
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
      ),
      child: SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * 0.9,
        child: AddToDay(
          date: date,
          dayName: dayName,
          chooser: chooser,
          startNow: startNow && onStartNow != null,
          initialType: initialType,
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

/// Something ticked to add: one of your activities, a built-in one (saved
/// as yours when added), or a new name.
sealed class _Pick {
  const _Pick();

  String get key;
  String get name;
}

class _Yours extends _Pick {
  const _Yours(this.type);

  final ActivityType type;

  @override
  String get key => 'y:${type.id.value}';

  @override
  String get name => type.name;
}

class _BuiltIn extends _Pick {
  const _BuiltIn(this.definition);

  final ActivityTypeDefinition definition;

  @override
  String get key => 'b:${definition.name.toLowerCase()}';

  @override
  String get name => definition.name;
}

class _NewName extends _Pick {
  const _NewName(this.name);

  @override
  final String name;

  @override
  String get key => 'n:${name.toLowerCase()}';
}

/// The add sheet's content.
class AddToDay extends ConsumerStatefulWidget {
  const AddToDay({
    super.key,
    required this.date,
    required this.dayName,
    required this.chooser,
    required this.onAdded,
    this.onStartNow,
    this.startNow = false,
    this.initialType,
  });

  final LocalDate date;
  final String dayName;
  final ActivityChooser chooser;
  final ValueChanged<PlanId> onAdded;

  /// Offers **Now** (today): the thing is added and started.
  final ValueChanged<PlanId>? onStartNow;
  final bool startNow;

  /// Ticked up front ("Plan it" from Progress).
  final ActivityType? initialType;

  @override
  ConsumerState<AddToDay> createState() => _AddToDayState();
}

class _AddToDayState extends ConsumerState<AddToDay> {
  final _search = TextEditingController();

  /// What's ticked, in the order it was ticked.
  final _picked = <_Pick>[];

  late _When _when = widget.startNow ? _When.now : _When.anytime;
  LocalTime? _start;
  LocalTime? _end;
  RepeatRule? _repeat;

  /// The reminder chosen here (or the default once a time is set).
  PlanReminder? _reminder;
  bool _reminderTouched = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialType case final type?) _picked.add(_Yours(type));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String get _query => _search.text.trim();

  bool get _single => _picked.length == 1;

  bool _isPicked(_Pick pick) => _picked.any((p) => p.key == pick.key);

  void _toggle(_Pick pick) => setState(() {
    if (_isPicked(pick)) {
      _picked.removeWhere((p) => p.key == pick.key);
    } else {
      _picked.add(pick);
    }
    // A time, Now and a reminder are for one thing at a time.
    if (!_single) {
      if (_when != _When.anytime) _when = _When.anytime;
      _start = null;
      _end = null;
      _reminder = null;
      _reminderTouched = false;
    }
  });

  bool _matches(String name, Iterable<String> details, [String group = '']) {
    final query = _query.toLowerCase();
    if (query.isEmpty) return true;
    bool has(String text) => text.toLowerCase().contains(query);
    return has(name) || has(group) || details.any(has);
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

  /// The activity [pick] is added as; null for a new name (made one of
  /// yours from the plan, with nothing to set up).
  Future<ActivityTypeId?> _activityOf(_Pick pick) async => switch (pick) {
    _Yours(:final type) => type.id,
    _BuiltIn(:final definition) => ref.read(addBuiltInActivityProvider)(
      definition,
    ),
    _NewName() => null,
  };

  Future<void> _add() async {
    if (_picked.isEmpty || _busy) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final single = _single;
    final now = single && _when == _When.now;
    final timed = single && _when == _When.time && _start != null;
    setState(() => _busy = true);
    try {
      PlanId? last;
      for (final pick in List.of(_picked)) {
        final typeId = await _activityOf(pick);
        final id = await ref.read(createPlanProvider)(
          PlanDraft(
            planDate: widget.date,
            // With an activity, the plan takes its name.
            title: typeId == null ? pick.name : '',
            activityTypeId: typeId,
            plannedStartAt: now
                ? ref.read(clockProvider).nowUtc()
                : timed
                ? _instant(_start)
                : null,
            plannedEndAt: timed ? _instant(_end) : null,
          ),
        );
        if (typeId == null) await ref.read(ensureItemActivityProvider)(id);
        if (_repeat case final rule? when !now) {
          await ref.read(repeatPlanProvider)(id, rule);
        }
        if (single && !now) {
          if (_effectiveReminder(timed: timed) case final reminder?) {
            await setReminderFor(ref, id, reminder);
          }
        }
        last = id;
      }
      if (!mounted || last == null) return;
      if (now) {
        widget.onStartNow?.call(last);
      } else {
        if (!single) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(l10n.addedCount(_picked.length, widget.dayName)),
            ),
          );
        }
        widget.onAdded(last);
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
      // A time just set: start from the default reminder.
      if (!_reminderTouched) {
        _reminder = defaultReminderFor(ref, timed: choice.start != null);
      }
    });
  }

  /// The reminder to save: an offset only makes sense with a time.
  PlanReminder? _effectiveReminder({required bool timed}) =>
      _reminder is ReminderBefore && !timed ? null : _reminder;

  Future<void> _pickReminder() async {
    final timed = _when == _When.time && _start != null;
    final choice = await showReminderSheet(
      context,
      title:
          _picked.firstOrNull?.name ??
          AppLocalizations.of(context).reminderTitle,
      start: timed ? _instant(_start) : null,
      current: _effectiveReminder(timed: timed),
    );
    if (choice.cancelled || !mounted) return;
    setState(() {
      _reminderTouched = true;
      _reminder = choice.reminder;
    });
  }

  Future<void> _pickRepeat() async {
    final rule = await showRepeatSheet(
      context,
      date: widget.date,
      initial: _repeat,
    );
    if (rule == null || !mounted) return;
    setState(() => _repeat = rule);
  }

  /// Opens the builder for a new activity (named [name]); the one made is
  /// ticked.
  Future<void> _makeOwn(String name) async {
    final id = await widget.chooser.makeOwn(name);
    if (id == null || !mounted) return;
    final type = await readActivityType(ref, id);
    if (type == null || !mounted) return;
    _search.clear();
    _toggle(_Yours(type));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final yours = ref.watch(recentActivityTypesProvider);
    bool taken(ActivityTypeDefinition d) =>
        yours.any((a) => sameActivityName(a.name, d.name)) ||
        (ref.watch(activeActivityTypesProvider).value ?? const []).any(
          (a) => sameActivityName(a.name, d.name),
        );
    final shownYours = [
      for (final type in yours)
        if (_matches(type.name, type.activeFields.map((f) => f.name))) type,
    ];
    final categories = [
      for (final category in activityCategories(l10n))
        (
          category.name,
          [
            for (final d in category.activities)
              if (!taken(d) &&
                  _matches(d.name, d.fields.map((f) => f.name), category.name))
                d,
          ],
        ),
    ].where((c) => c.$2.isNotEmpty).toList();
    final query = _query;
    // Something typed that isn't an activity yet: offer it as one.
    final exact =
        yours.any((t) => sameActivityName(t.name, query)) ||
        builtInActivities(l10n).any((d) => sameActivityName(d.name, query));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.addSheetTitle(widget.dayName),
                style: context.textStyles.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _search,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: l10n.addSearchHint,
                  prefixIcon: const Icon(AppIcons.search),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: MaterialLocalizations.of(context)
                              .deleteButtonTooltip,
                          icon: const Icon(AppIcons.close),
                          onPressed: () => setState(_search.clear),
                        ),
                ),
                onChanged: (_) => setState(() {}),
                // Enter ticks what was typed: the activity with that name
                // (yours, then a built-in one), or it as a new one.
                onSubmitted: (_) {
                  if (query.isEmpty) return;
                  final l10n = AppLocalizations.of(context);
                  final mine = ref
                      .read(recentActivityTypesProvider)
                      .where((t) => sameActivityName(t.name, query))
                      .firstOrNull;
                  final builtIn = builtInActivities(l10n)
                      .where((d) => sameActivityName(d.name, query))
                      .firstOrNull;
                  final pick = mine != null
                      ? _Yours(mine)
                      : builtIn != null
                      ? _BuiltIn(builtIn)
                      : _NewName(query) as _Pick;
                  if (!_isPicked(pick)) _toggle(pick);
                  setState(_search.clear);
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            children: [
              if (query.isNotEmpty && !exact) ...[
                _PickRow(
                  leading: const _IconBadge(AppIcons.add),
                  name: l10n.addNewNamed(query),
                  details: l10n.addNewNamedHint,
                  picked: _isPicked(_NewName(query)),
                  onTap: () => _toggle(_NewName(query)),
                ),
                _PickRow(
                  leading: const _IconBadge(AppIcons.edit),
                  name: l10n.addSetUpNamed(query),
                  onTap: () => unawaited(_makeOwn(query)),
                ),
              ],
              // Ticked things that are new names stay visible.
              for (final pick in _picked.whereType<_NewName>())
                if (pick.name.toLowerCase() != query.toLowerCase())
                  _PickRow(
                    leading: const _IconBadge(AppIcons.add),
                    name: pick.name,
                    details: l10n.addNewNamedHint,
                    picked: true,
                    onTap: () => _toggle(pick),
                  ),
              if (shownYours.isNotEmpty) ...[
                SectionHeader(title: l10n.addYourActivities),
                for (final type in shownYours)
                  _PickRow(
                    leading: ActivityBadge(
                      iconId: type.iconId,
                      colorKey: type.colorKey,
                    ),
                    name: type.name,
                    details: type.activeFields.map((f) => f.name).join(' · '),
                    picked: _isPicked(_Yours(type)),
                    onTap: () => _toggle(_Yours(type)),
                  ),
              ],
              for (final (name, definitions) in categories) ...[
                SectionHeader(title: name),
                for (final d in definitions)
                  _PickRow(
                    leading: ActivityBadge(
                      iconId: d.iconId,
                      colorKey: d.colorKey,
                    ),
                    name: d.name,
                    details: d.fields.map((f) => f.name).join(' · '),
                    picked: _isPicked(_BuiltIn(d)),
                    onTap: () => _toggle(_BuiltIn(d)),
                  ),
              ],
              if (query.isEmpty)
                _PickRow(
                  leading: const _IconBadge(AppIcons.edit),
                  name: l10n.addSetUpOwn,
                  onTap: () => unawaited(_makeOwn('')),
                ),
            ],
          ),
        ),
        _Footer(
          picked: _picked,
          busy: _busy,
          when: _when,
          canStartNow: widget.onStartNow != null,
          timeLabel: switch ((_when, _start, _end)) {
            (_When.time, final s?, null) => formatLocalTime(context, s),
            (_When.time, final s?, final e?) => l10n.planTimeRange(
              formatLocalTime(context, s),
              formatLocalTime(context, e),
            ),
            _ => l10n.addTimeChoose,
          },
          repeatLabel: switch (_repeat) {
            final rule? => formatWeekdays(context, rule.weekdays),
            null => null,
          },
          reminder: _effectiveReminder(
            timed: _when == _When.time && _start != null,
          ),
          onAnytime: () => setState(() => _when = _When.anytime),
          onNow: () => setState(() => _when = _When.now),
          onTime: _pickTime,
          onRepeat: _pickRepeat,
          onReminder: _pickReminder,
          onRemove: _toggle,
          onAdd: _add,
          divider: c.borderSubtle,
        ),
      ],
    );
  }
}

/// The bottom of the sheet: what's ticked, its settings and **Add**.
class _Footer extends StatelessWidget {
  const _Footer({
    required this.picked,
    required this.busy,
    required this.when,
    required this.canStartNow,
    required this.timeLabel,
    required this.repeatLabel,
    required this.reminder,
    required this.onAnytime,
    required this.onNow,
    required this.onTime,
    required this.onRepeat,
    required this.onReminder,
    required this.onRemove,
    required this.onAdd,
    required this.divider,
  });

  final List<_Pick> picked;
  final bool busy;
  final _When when;
  final bool canStartNow;
  final String timeLabel;
  final String? repeatLabel;
  final PlanReminder? reminder;
  final VoidCallback onAnytime;
  final VoidCallback onNow;
  final VoidCallback onTime;
  final VoidCallback onRepeat;
  final VoidCallback onReminder;
  final ValueChanged<_Pick> onRemove;
  final VoidCallback onAdd;
  final Color divider;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final single = picked.length == 1;
    final now = single && when == _When.now;
    final label = context.textStyles.labelMedium?.copyWith(
      color: c.textSecondary,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surfaceBase,
        border: Border(top: BorderSide(color: divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (picked.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Text(l10n.addPickHint, style: label),
                )
              else ...[
                // What's ticked, each removable.
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final pick in picked)
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.xs),
                          child: InputChip(
                            label: Text(pick.name),
                            visualDensity: VisualDensity.compact,
                            deleteButtonTooltipMessage: l10n.addSelectedRemove(
                              pick.name,
                            ),
                            onDeleted: () => onRemove(pick),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    if (single) ...[
                      ChoiceChip(
                        label: Text(l10n.planAnytime),
                        selected: when == _When.anytime,
                        onSelected: (_) => onAnytime(),
                      ),
                      if (canStartNow)
                        ChoiceChip(
                          label: Text(l10n.addNow),
                          selected: when == _When.now,
                          onSelected: (_) => onNow(),
                        ),
                      ChoiceChip(
                        showCheckmark: false,
                        avatar: const Icon(AppIcons.time, size: 18),
                        label: Text(timeLabel),
                        selected: when == _When.time,
                        onSelected: (_) => onTime(),
                      ),
                    ],
                    if (!now)
                      ChoiceChip(
                        showCheckmark: false,
                        avatar: const Icon(AppIcons.repeat, size: 18),
                        label: Text(repeatLabel ?? l10n.addRepeat),
                        selected: repeatLabel != null,
                        onSelected: (_) => onRepeat(),
                      ),
                    if (single && !now)
                      ChoiceChip(
                        showCheckmark: false,
                        avatar: Icon(
                          reminder == null ? AppIcons.bell : AppIcons.bellOn,
                          size: 18,
                        ),
                        label: Text(switch (reminder) {
                          null => l10n.reminderLabel,
                          final r => reminderLabel(context, r),
                        }),
                        selected: reminder != null,
                        onSelected: (_) => onReminder(),
                      ),
                  ],
                ),
                if (!single) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(l10n.addManyNote, style: label),
                ],
                const SizedBox(height: AppSpacing.md),
              ],
              AppButton(
                label: now
                    ? l10n.addStartAction
                    : l10n.addCountAction(picked.length),
                icon: now ? AppIcons.start : AppIcons.add,
                variant: AppButtonVariant.action,
                expand: true,
                onPressed: picked.isNotEmpty && !busy ? onAdd : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One activity in the list: badge, name, what it logs, and a tick.
class _PickRow extends StatelessWidget {
  const _PickRow({
    required this.leading,
    required this.name,
    required this.onTap,
    this.details = '',
    this.picked,
  });

  final Widget leading;
  final String name;
  final String details;

  /// Null for an action row (no tick).
  final bool? picked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final on = picked ?? false;
    return Semantics(
      selected: picked == null ? null : on,
      button: true,
      child: Material(
        color: on ? c.brandPrimarySoft : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.md),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                leading,
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: context.textStyles.titleMedium),
                      if (details.isNotEmpty)
                        Text(
                          details,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyles.bodySmall?.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                if (picked != null)
                  Icon(
                    on ? AppIcons.taskDone : AppIcons.taskOpen,
                    color: on ? c.brandPrimary : c.borderStrong,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A plain icon in a badge's place (new name, make your own).
class _IconBadge extends StatelessWidget {
  const _IconBadge(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 40,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceSunken,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: context.colors.textSecondary),
    ),
  );
}
