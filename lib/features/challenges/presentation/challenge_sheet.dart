import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/time/clock_provider.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/errors/error_copy.dart';
import '../../../shared/widgets/activity_badge.dart';
import '../../../shared/widgets/discard_guard.dart';
import '../../../shared/widgets/segmented_tabs.dart';
import '../../../shared/widgets/state_views.dart';
import '../../activity_logs/presentation/form/field_editor_shell.dart';
import '../../activity_logs/presentation/value_formatting.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../activity_types/domain/field_type.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../../plans/presentation/activity_chooser.dart';
import '../../plans/presentation/plan_date_notifier.dart';
import '../domain/challenge.dart';
import 'challenge_providers.dart';
import 'goal_copy.dart';
import '../../activity_logs/domain/field_value.dart';
import '../../plans/presentation/item/last_time_card.dart';

/// The numbers of days offered as quick picks.
const _dayPresets = [7, 21, 30, 75, 100];

/// The numbers of weeks offered as quick picks.
const _weekPresets = [4, 8, 12, 26, 52];

/// Starts a goal ([initial] null; [chooser] picks its activity) or edits
/// one's name and target ([initial]); ADR-044, ADR-047. A goal is done
/// every day, a number of times a week, or an amount (time or a number
/// field) a day or a week. Everything else is worked out: recording the
/// activity is what counts.
Future<void> showChallengeSheet(
  BuildContext context, {
  Challenge? initial,
  ActivityChooser? chooser,
  ActivityTypeId? activityId,
  int? days,
}) => showModalBottomSheet<void>(
  useRootNavigator: true,
  useSafeArea: true,
  context: context,
  isScrollControlled: true,
  builder: (_) => _ChallengeSheet(
    initial: initial,
    chooser: chooser,
    presetActivity: activityId,
    presetDays: days,
  ),
);

class _ChallengeSheet extends ConsumerStatefulWidget {
  const _ChallengeSheet({
    this.initial,
    this.chooser,
    this.presetActivity,
    this.presetDays,
  });

  final Challenge? initial;
  final ActivityChooser? chooser;

  /// Prefilled from an example ("21 days of Meditation", C1).
  final ActivityTypeId? presetActivity;
  final int? presetDays;

  @override
  ConsumerState<_ChallengeSheet> createState() => _ChallengeSheetState();
}

class _ChallengeSheetState extends ConsumerState<_ChallengeSheet> {
  late final _title = TextEditingController(text: widget.initial?.title ?? '');
  late final _target = TextEditingController(
    text: switch (widget.initial) {
      // A target goal's time is entered in weeks.
      final c? when c.kind == GoalKind.target =>
        '${(c.targetDays / 7).round().clamp(1, 143)}',
      final c? => '${c.targetDays}',
      null => '${widget.presetDays ?? 30}',
    },
  );
  final _amount = TextEditingController();

  /// Target goals: where it starts.
  final _now = TextEditingController();
  bool _nowPrefilled = false;
  late ActivityTypeId? _activityId =
      widget.initial?.activityTypeId ?? widget.presetActivity;
  late GoalKind _kind = widget.initial?.kind ?? GoalKind.daily;
  late int _timesPerWeek = widget.initial?.timesPerWeek ?? 3;
  late int _restDays = widget.initial?.restDays ?? 0;
  late GoalPeriod _amountPeriod =
      widget.initial?.amountPeriod ?? GoalPeriod.day;

  /// The field an amount goal sums; null for recorded time.
  late ActivityFieldId? _amountField = widget.initial?.amountFieldId;
  bool _amountPrefilled = false;
  LocalDate? _start;
  List<ValidationIssue> _issues = const [];
  bool _saving = false;

  bool get _editing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    // Rebuild on typing so the hint and the discard guard follow it.
    _title.addListener(() => setState(() {}));
    _target.addListener(() => setState(() {}));
    _amount.addListener(() => setState(() {}));
    _now.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    _target.dispose();
    _amount.dispose();
    _now.dispose();
    super.dispose();
  }

  int get _targetCount => int.tryParse(_target.text.trim()) ?? 0;

  LocalDate get _today => currentLocalDate(ref.read(clockProvider));

  GoalPeriod get _period => switch (_kind) {
    GoalKind.daily => GoalPeriod.day,
    GoalKind.weekly => GoalPeriod.week,
    GoalKind.amount => _amountPeriod,
    GoalKind.target => GoalPeriod.day,
  };

  /// What's stored as the goal's length: days, or weeks × 7 for a target.
  int get _storedTarget => _kind == GoalKind.target
      ? (_targetCount * 7).clamp(0, Challenge.maxTargetDays)
      : _targetCount;

  bool get _dirty {
    if (_saving) return false;
    final initial = widget.initial;
    if (initial == null) {
      return _activityId != null ||
          _title.text.isNotEmpty ||
          _start != null ||
          _amount.text.isNotEmpty;
    }
    return _title.text != initial.title ||
        _storedTarget != initial.targetDays ||
        _timesPerWeek != (initial.timesPerWeek ?? 3) ||
        _restDays != initial.restDays;
  }

  /// The amount typed, in what's stored: ms for time and duration fields,
  /// else the field's canonical unit.
  double? _storedAmount(ActivityType? type) => _stored(_amount.text, type);

  /// [text] typed in the goal's unit, in what's stored.
  double? _stored(String text, ActivityType? type) {
    final typed = double.tryParse(text.trim().replaceAll(',', '.'));
    if (typed == null) return null;
    final field = _amountField == null ? null : type?.fieldById(_amountField!);
    if (field == null || field.type == FieldType.duration) {
      return typed * Duration.millisecondsPerMinute;
    }
    return goalFieldUnit(field)?.toCanonical(typed) ?? typed;
  }

  /// A target goal's start: an edited goal's, or the latest value logged.
  void _prefillNow(ActivityType type) {
    if (_kind != GoalKind.target || _amountField == null || _nowPrefilled) {
      return;
    }
    final field = type.fieldById(_amountField!);
    if (field == null) return;
    double? canonical = widget.initial?.startValue;
    if (canonical == null) {
      final last = ref.watch(lastLogProvider((type.id, null)));
      if (last.isLoading) return;
      if (last.value?.values[field.id] case final NumberValue v) {
        canonical = v.normalized;
      }
    }
    _nowPrefilled = true;
    if (canonical == null) return;
    final shown = goalFieldUnit(field)?.fromCanonical(canonical) ?? canonical;
    _now.text = formatNumber(shown, 2);
  }

  /// Picks the field a target goal follows when there's an obvious one.
  void _pickTargetField(ActivityType? type) {
    if (type == null) return;
    final fields = goalTargetFields(type);
    if (fields.any((f) => f.id == _amountField)) return;
    _amountField = fields.firstOrNull?.id;
    _nowPrefilled = false;
  }

  /// Fills in an edited amount goal's amount, in the unit it's typed in.
  void _prefillAmount(ActivityType type) {
    if (_amountPrefilled) return;
    _amountPrefilled = true;
    final amount = widget.initial?.amount;
    if (amount == null) return;
    final field = _amountField == null ? null : type.fieldById(_amountField!);
    final shown = field == null || field.type == FieldType.duration
        ? amount / Duration.millisecondsPerMinute
        : goalFieldUnit(field)?.fromCanonical(amount) ?? amount;
    _amount.text = formatNumber(shown, 2);
  }

  String _amountSuffix(AppLocalizations l10n, ActivityType? type) {
    final field = _amountField == null ? null : type?.fieldById(_amountField!);
    if (field == null || field.type == FieldType.duration) {
      return l10n.goalMinutesSuffix;
    }
    return goalFieldUnit(field)?.symbol ?? field.name.toLowerCase();
  }

  Future<void> _choose(Future<ActivityTypeId?> Function() pick) async {
    final id = await pick();
    if (id != null && mounted) {
      setState(() {
        _activityId = id;
        _amountField = null;
        _nowPrefilled = false;
      });
    }
  }

  Future<void> _pickStart() async {
    final today = _today;
    final current = _start ?? today;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(current.year, current.month, current.day),
      firstDate: DateTime(2020),
      lastDate: DateTime(today.year, today.month, today.day),
    );
    if (picked != null && mounted) {
      setState(() => _start = LocalDate(picked.year, picked.month, picked.day));
    }
  }

  String _autoTitle(AppLocalizations l10n, ActivityType? type) {
    final amount = _storedAmount(type);
    return goalAutoTitle(
      l10n,
      kind: _kind,
      target: _targetCount,
      timesPerWeek: _timesPerWeek,
      period: _amountPeriod,
      // "Weight to 72 kg": a target is named after what it measures.
      activity: _kind == GoalKind.target && _amountField != null
          ? type?.fieldById(_amountField!)?.name ?? type?.name ?? ''
          : type?.name ?? '',
      amount: amount == null
          ? null
          : formatGoalAmount(l10n, _amountField, type, amount),
    );
  }

  Future<void> _save(ActivityType? type) async {
    final l10n = AppLocalizations.of(context);
    final typed = _title.text.trim();
    final title = typed.isEmpty ? _autoTitle(l10n, type) : typed;
    setState(() {
      _saving = true;
      _issues = const [];
    });
    try {
      final initial = widget.initial;
      if (initial != null) {
        await ref.read(updateChallengeProvider)(
          initial.id,
          title: title,
          targetDays: _storedTarget,
          timesPerWeek: _timesPerWeek,
          amount: _storedAmount(type),
          restDays: _restDays,
          startValue: _stored(_now.text, type),
        );
      } else {
        final activity = _activityId;
        if (activity == null) {
          throw const ValidationException([
            ValidationIssue(ValidationCode.required, target: 'activity'),
          ]);
        }
        await ref.read(createChallengeProvider)(
          ChallengeDraft(
            activityTypeId: activity,
            title: title,
            startDate: _start ?? _today,
            targetDays: _storedTarget,
            kind: _kind,
            timesPerWeek: _timesPerWeek,
            amount: _storedAmount(type),
            amountFieldId: _amountField,
            amountPeriod: _amountPeriod,
            restDays: _restDays,
            startValue: _kind == GoalKind.target
                ? _stored(_now.text, type)
                : null,
          ),
        );
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

  /// A number box with its unit always showing after it.
  Widget _numberInput(TextEditingController controller, String unit) =>
      TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        ],
        decoration: InputDecoration(
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Align(
              widthFactor: 1,
              child: Text(
                unit,
                style: context.textStyles.bodyLarge?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final type = _activityId == null
        ? null
        : ref.watch(activityTypeProvider(_activityId!)).value;
    if (type != null) {
      // An activity picked from the list arrives after the kind was set.
      if (_kind == GoalKind.target && !_editing) _pickTargetField(type);
      _prefillAmount(type);
      _prefillNow(type);
    }
    String? issue(String target) => firstIssueMessage(l10n, _issues, target);
    final chooser = widget.chooser;
    final presets = _kind == GoalKind.target
        ? const [4, 8, 12, 26]
        : _period == GoalPeriod.week
        ? _weekPresets
        : _dayPresets;
    final hint = context.textStyles.bodySmall?.copyWith(color: c.textSecondary);
    return DiscardGuard(
      dirty: _dirty,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
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
                  _editing ? l10n.challengeEditTitle : l10n.challengeNewTitle,
                  style: context.textStyles.titleLarge,
                ),
                const SizedBox(height: AppSpacing.lg),
                FieldEditorShell(
                  label: l10n.challengeActivityLabel,
                  error: issue('activity'),
                  child: type != null
                      ? ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: ActivityBadge(
                            iconId: type.iconId,
                            colorKey: type.colorKey,
                          ),
                          title: Text(type.name),
                          subtitle: Text(switch (_kind) {
                            GoalKind.daily => l10n.challengeActivityHelper,
                            GoalKind.weekly => l10n.goalActivityHelperWeekly,
                            GoalKind.amount => l10n.goalActivityHelperAmount,
                            GoalKind.target => l10n.goalActivityHelperTarget,
                          }),
                          onTap: _editing || chooser == null
                              ? null
                              : () => _choose(chooser.browse),
                        )
                      : Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.xs,
                          children: [
                            // Your own activities first: one tap.
                            for (final t
                                in ref
                                        .watch(activeActivityTypesProvider)
                                        .value ??
                                    const <ActivityType>[])
                              ActionChip(
                                avatar: ActivityBadge(
                                  iconId: t.iconId,
                                  colorKey: t.colorKey,
                                  size: 24,
                                ),
                                label: Text(t.name),
                                onPressed: () => setState(() {
                                  _activityId = t.id;
                                  _amountField = null;
                                  _nowPrefilled = false;
                                  if (_kind == GoalKind.target) {
                                    _pickTargetField(t);
                                  }
                                }),
                              ),
                            if (chooser != null) ...[
                              // Same shape as the activities, so the row
                              // reads as one set of choices.
                              ActionChip(
                                avatar: const Icon(AppIcons.search, size: 18),
                                label: Text(l10n.planBrowseActivities),
                                onPressed: () => _choose(chooser.browse),
                              ),
                              ActionChip(
                                avatar: const Icon(AppIcons.add, size: 18),
                                label: Text(l10n.planMakeOwn),
                                onPressed: () =>
                                    _choose(() => chooser.makeOwn('')),
                              ),
                            ],
                          ],
                        ),
                ),
                if (!_editing)
                  FieldEditorShell(
                    label: l10n.goalKindLabel,
                    child: SegmentedTabs<GoalKind>(
                      values: GoalKind.values,
                      selected: _kind,
                      label: (k) => switch (k) {
                        GoalKind.daily => l10n.goalKindDaily,
                        GoalKind.weekly => l10n.goalKindWeekly,
                        GoalKind.amount => l10n.goalKindAmount,
                        GoalKind.target => l10n.goalKindTarget,
                      },
                      onSelect: (k) => setState(() {
                        _kind = k;
                        final week = _period == GoalPeriod.week;
                        _target.text = k == GoalKind.target
                            ? '12'
                            : '${week ? 8 : 30}';
                        if (k == GoalKind.target) {
                          _pickTargetField(type);
                        } else if (_amountField != null &&
                            type != null &&
                            !goalAmountFields(type)
                                .any((f) => f.id == _amountField)) {
                          _amountField = null;
                        }
                      }),
                    ),
                  ),
                if (_kind == GoalKind.weekly)
                  FieldEditorShell(
                    label: l10n.goalTimesPerWeekLabel,
                    error: issue('amount'),
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: [
                        for (var n = 1; n <= 7; n++)
                          ChoiceChip(
                            label: Text(l10n.goalTimesChip(n)),
                            selected: _timesPerWeek == n,
                            onSelected: (_) =>
                                setState(() => _timesPerWeek = n),
                          ),
                      ],
                    ),
                  ),
                if (_kind == GoalKind.amount) ...[
                  if (!_editing)
                    FieldEditorShell(
                      label: l10n.goalAmountWhatLabel,
                      child: Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: [
                          ChoiceChip(
                            label: Text(l10n.goalAmountTime),
                            selected: _amountField == null,
                            onSelected: (_) =>
                                setState(() => _amountField = null),
                          ),
                          if (type != null)
                            for (final f in goalAmountFields(type))
                              ChoiceChip(
                                label: Text(f.name),
                                selected: _amountField == f.id,
                                onSelected: (_) =>
                                    setState(() => _amountField = f.id),
                              ),
                        ],
                      ),
                    ),
                  FieldEditorShell(
                    label: l10n.goalAmountLabel,
                    error: issue('amount'),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _amount,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]'),
                              ),
                            ],
                            decoration: InputDecoration(
                              hintText: l10n.goalAmountHint,
                              // Always visible (suffixText only shows while
                              // typing), so it's clear what the number is.
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(
                                  right: AppSpacing.md,
                                ),
                                child: Align(
                                  widthFactor: 1,
                                  child: Text(
                                    _amountSuffix(l10n, type),
                                    style: context.textStyles.bodyLarge
                                        ?.copyWith(color: c.textSecondary),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (!_editing) ...[
                          const SizedBox(width: AppSpacing.md),
                          SizedBox(
                            width: 160,
                            child: SegmentedTabs<GoalPeriod>(
                              values: GoalPeriod.values,
                              selected: _amountPeriod,
                              label: (p) => p == GoalPeriod.day
                                  ? l10n.goalPerDay
                                  : l10n.goalPerWeek,
                              onSelect: (p) => setState(() {
                                _amountPeriod = p;
                                _target.text =
                                    '${p == GoalPeriod.week ? 8 : 30}';
                              }),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                if (_kind == GoalKind.target && type != null) ...[
                  if (goalTargetFields(type).isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: Text(
                        l10n.goalTargetNoField(type.name),
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: c.warning,
                        ),
                      ),
                    )
                  else ...[
                    if (!_editing && goalTargetFields(type).length > 1)
                      FieldEditorShell(
                        label: l10n.goalTargetFieldLabel,
                        error: issue('field'),
                        child: Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.xs,
                          children: [
                            for (final f in goalTargetFields(type))
                              ChoiceChip(
                                label: Text(f.name),
                                selected: _amountField == f.id,
                                onSelected: (_) => setState(() {
                                  _amountField = f.id;
                                  _nowPrefilled = false;
                                  _now.clear();
                                }),
                              ),
                          ],
                        ),
                      ),
                    FieldEditorShell(
                      label: l10n.goalTargetNowLabel,
                      child: _numberInput(_now, _amountSuffix(l10n, type)),
                    ),
                    FieldEditorShell(
                      label: l10n.goalTargetLabel,
                      error: issue('amount'),
                      child: _numberInput(_amount, _amountSuffix(l10n, type)),
                    ),
                  ],
                ],
                FieldEditorShell(
                  label: _kind == GoalKind.target
                      ? l10n.goalTargetWeeksLabel
                      : _period == GoalPeriod.week
                      ? l10n.goalWeeksLabel
                      : l10n.challengeDaysLabel,
                  error: issue('target'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _target,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          helperText: switch (_kind) {
                            GoalKind.daily => l10n.challengeDaysHelper,
                            GoalKind.weekly => l10n.goalWeeklyHelper(
                              _timesPerWeek,
                            ),
                            GoalKind.amount => l10n.goalAmountHelper,
                            GoalKind.target => l10n.goalTargetWeeksHelper,
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        children: [
                          for (final n in presets)
                            ChoiceChip(
                              label: Text('$n'),
                              selected: _targetCount == n,
                              onSelected: (_) => _target.text = '$n',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_kind == GoalKind.daily)
                  FieldEditorShell(
                    label: l10n.goalRestDaysLabel,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: AppSpacing.sm,
                          children: [
                            for (var n = 0; n <= Challenge.maxRestDays; n++)
                              ChoiceChip(
                                label: Text(
                                  n == 0
                                      ? l10n.goalRestDaysNone
                                      : l10n.goalRestDaysPerWeek(n),
                                ),
                                selected: _restDays == n,
                                onSelected: (_) =>
                                    setState(() => _restDays = n),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(l10n.goalRestDaysHelper, style: hint),
                      ],
                    ),
                  ),
                if (!_editing)
                  FieldEditorShell(
                    label: l10n.challengeStartLabel,
                    error: issue('start'),
                    child: OutlinedButton(
                      onPressed: _pickStart,
                      child: Text(formatDate(context, _start ?? _today)),
                    ),
                  ),
                FieldEditorShell(
                  label: l10n.challengeNameLabel,
                  error: issue('title'),
                  child: TextField(
                    controller: _title,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText:
                          type == null ||
                              (_kind == GoalKind.amount ||
                                      _kind == GoalKind.target) &&
                                  _storedAmount(type) == null
                          ? null
                          : _autoTitle(l10n, type),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                FilledButton(
                  onPressed: _saving ? null : () => _save(type),
                  child: Text(
                    _editing ? l10n.actionSave : l10n.challengeStartAction,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
