import 'dart:async';

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
import '../../measurements/domain/measurement.dart';
import '../../measurements/presentation/body_weight_activity.dart';
import '../../measurements/presentation/measurement_providers.dart';

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
    // Body weight: the latest weight from Body measurements.
    if (canonical == null &&
        (ref.watch(isBodyWeightActivityProvider(type.id)).value ?? false)) {
      final latest = ref.watch(latestMeasurementsProvider);
      if (latest.isLoading) return;
      canonical = latest.value?[MeasurementType.weight]?.normalizedValue;
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

  /// "My weight": the body-weight activity (made the first time), as a
  /// "Reach a number" goal.
  Future<void> _chooseWeight() async {
    final l10n = AppLocalizations.of(context);
    final id = await ensureBodyWeightActivity(ref, l10n);
    if (!mounted) return;
    final type = await ref.read(activityTypeRepositoryProvider).getType(id);
    if (!mounted) return;
    setState(() {
      _activityId = id;
      _amountField = null;
      _nowPrefilled = false;
    });
    _setKind(GoalKind.target, type);
    _pickTargetField(type);
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

  /// Quick lengths for the goal, as people say them: (count, label). In
  /// days for daily and amount-per-day goals, weeks otherwise.
  List<(int, String)> _lengths(AppLocalizations l10n) =>
      switch ((_kind, _period)) {
        (GoalKind.target, _) => [
          (4, l10n.goalLenMonths(1)),
          (12, l10n.goalLenMonths(3)),
          (26, l10n.goalLenMonths(6)),
        ],
        (_, GoalPeriod.week) => [
          (4, l10n.goalLenMonths(1)),
          (8, l10n.goalLenMonths(2)),
          (12, l10n.goalLenMonths(3)),
        ],
        _ => [
          (7, l10n.goalLenWeek),
          (30, l10n.goalLenMonths(1)),
          (90, l10n.goalLenMonths(3)),
        ],
      };

  /// The goal's length as the chips say it ("2 months"), or in its own
  /// unit for another number ("21 days", "10 weeks").
  String _lengthText(AppLocalizations l10n) {
    if (!_customLength) {
      for (final (count, label) in _lengths(l10n)) {
        if (count == _targetCount) return label.toLowerCase();
      }
    }
    return _kind == GoalKind.target || _period == GoalPeriod.week
        ? l10n.goalWeeks(_targetCount)
        : l10n.insightDaysDone(_targetCount);
  }

  /// The goal in one sentence, from what's chosen so far.
  String? _summary(AppLocalizations l10n, ActivityType? type) {
    if (type == null || _targetCount <= 0) return null;
    final length = _lengthText(l10n);
    switch (_kind) {
      case GoalKind.daily:
        return l10n.goalSummaryDaily(type.name, length);
      case GoalKind.weekly:
        return l10n.goalSummaryWeekly(type.name, _timesPerWeek, length);
      case GoalKind.amount:
        final amount = _storedAmount(type);
        if (amount == null) return null;
        final text = formatGoalAmount(l10n, _amountField, type, amount);
        return _amountPeriod == GoalPeriod.week
            ? l10n.goalSummaryAmountWeek(text, type.name, length)
            : l10n.goalSummaryAmountDay(text, type.name, length);
      case GoalKind.target:
        final from = _stored(_now.text, type);
        final to = _storedAmount(type);
        final field = _amountField == null
            ? null
            : type.fieldById(_amountField!);
        if (from == null || to == null || field == null) return null;
        return l10n.goalSummaryTarget(
          field.name,
          formatGoalAmount(l10n, _amountField, type, from),
          formatGoalAmount(l10n, _amountField, type, to),
          length,
        );
    }
  }

  // Editing is mostly renaming or changing the length: show it all.
  late bool _moreOptions = _editing;
  bool _customLength = false;

  void _setKind(GoalKind k, ActivityType? type) => setState(() {
    _kind = k;
    _customLength = false;
    _target.text = switch ((k, _period)) {
      (GoalKind.target, _) => '12',
      (_, GoalPeriod.week) => '8',
      _ => '30',
    };
    if (k == GoalKind.target) {
      _pickTargetField(type);
    } else if (_amountField != null &&
        type != null &&
        !goalAmountFields(type).any((f) => f.id == _amountField)) {
      _amountField = null;
    }
  });

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
    final hint = context.textStyles.bodySmall?.copyWith(color: c.textSecondary);
    final question = context.textStyles.titleMedium;
    final lengths = _lengths(l10n);
    final custom = _customLength || !lengths.any((l) => l.$1 == _targetCount);
    final summary = _summary(l10n, type);
    // "Reach a number" only for an activity with a number to follow.
    final canTarget = type == null || goalTargetFields(type).isNotEmpty;

    Widget section(String title, Widget child, {String? error}) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: question),
          const SizedBox(height: AppSpacing.sm),
          child,
          if (error != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              error,
              style: context.textStyles.bodySmall?.copyWith(color: c.danger),
            ),
          ],
        ],
      ),
    );

    // What the chosen kind needs, right under it.
    Widget kindDetails() => switch (_kind) {
      GoalKind.daily => const SizedBox.shrink(),
      GoalKind.weekly => Row(
        children: [
          IconButton.filledTonal(
            tooltip: l10n.goalFewerDays,
            onPressed: _timesPerWeek > 1
                ? () => setState(() => _timesPerWeek--)
                : null,
            icon: const Icon(AppIcons.minus),
          ),
          Expanded(
            child: Text(
              l10n.goalDaysAWeek(_timesPerWeek),
              textAlign: TextAlign.center,
              style: context.textStyles.titleMedium,
            ),
          ),
          IconButton.filledTonal(
            tooltip: l10n.goalMoreDays,
            onPressed: _timesPerWeek < 7
                ? () => setState(() => _timesPerWeek++)
                : null,
            icon: const Icon(AppIcons.add),
          ),
        ],
      ),
      GoalKind.amount => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_editing && type != null && goalAmountFields(type).isNotEmpty)
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                ChoiceChip(
                  label: Text(l10n.goalAmountTime),
                  selected: _amountField == null,
                  onSelected: (_) => setState(() => _amountField = null),
                ),
                for (final f in goalAmountFields(type))
                  ChoiceChip(
                    label: Text(f.name),
                    selected: _amountField == f.id,
                    onSelected: (_) => setState(() => _amountField = f.id),
                  ),
              ],
            ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(child: _numberInput(_amount, _amountSuffix(l10n, type))),
              if (!_editing) ...[
                const SizedBox(width: AppSpacing.md),
                SizedBox(
                  width: 150,
                  child: SegmentedTabs<GoalPeriod>(
                    values: GoalPeriod.values,
                    selected: _amountPeriod,
                    label: (p) => p == GoalPeriod.day
                        ? l10n.goalPerDay
                        : l10n.goalPerWeek,
                    onSelect: (p) => setState(() {
                      _amountPeriod = p;
                      _customLength = false;
                      _target.text = '${p == GoalPeriod.week ? 8 : 30}';
                    }),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      GoalKind.target =>
        type == null
            ? const SizedBox.shrink()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!_editing && goalTargetFields(type).length > 1)
                    Wrap(
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
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.goalTargetNowLabel, style: hint),
                            const SizedBox(height: AppSpacing.xs),
                            _numberInput(_now, _amountSuffix(l10n, type)),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.goalTargetLabel, style: hint),
                            const SizedBox(height: AppSpacing.xs),
                            _numberInput(_amount, _amountSuffix(l10n, type)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
    };

    final options = [
      (GoalKind.daily, l10n.goalOptDaily, l10n.goalOptDailyEx),
      (GoalKind.weekly, l10n.goalOptWeekly, l10n.goalOptWeeklyEx),
      (GoalKind.amount, l10n.goalOptAmount, l10n.goalOptAmountEx),
      if (canTarget)
        (GoalKind.target, l10n.goalOptTarget, l10n.goalOptTargetEx),
    ];

    return DiscardGuard(
      dirty: _dirty,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.92,
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
                // 1. What.
                section(
                  l10n.goalQWhat,
                  error: issue('activity'),
                  _editing && type != null
                      ? Row(
                          children: [
                            ActivityBadge(
                              iconId: type.iconId,
                              colorKey: type.colorKey,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              type.name,
                              style: context.textStyles.titleMedium,
                            ),
                          ],
                        )
                      : Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.xs,
                          children: [
                            for (final t
                                in ref
                                        .watch(activeActivityTypesProvider)
                                        .value ??
                                    const <ActivityType>[])
                              ChoiceChip(
                                avatar: ActivityBadge(
                                  iconId: t.iconId,
                                  colorKey: t.colorKey,
                                  size: 24,
                                ),
                                showCheckmark: false,
                                label: Text(t.name),
                                selected: _activityId == t.id,
                                onSelected: (_) => setState(() {
                                  _activityId = t.id;
                                  _amountField = null;
                                  _nowPrefilled = false;
                                  if (_kind == GoalKind.target) {
                                    if (goalTargetFields(t).isEmpty) {
                                      _setKind(GoalKind.daily, t);
                                    } else {
                                      _pickTargetField(t);
                                    }
                                  }
                                }),
                              ),
                            if (!(ref
                                        .watch(activeActivityTypesProvider)
                                        .value ??
                                    const <ActivityType>[])
                                .any(
                                  (t) =>
                                      ref
                                          .watch(
                                            isBodyWeightActivityProvider(t.id),
                                          )
                                          .value ??
                                      false,
                                ))
                              Tooltip(
                                message: l10n.goalBodyWeightHint,
                                child: ActionChip(
                                  avatar: const Icon(AppIcons.goal, size: 18),
                                  label: Text(l10n.goalBodyWeight),
                                  onPressed: () => unawaited(_chooseWeight()),
                                ),
                              ),
                            if (chooser != null) ...[
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
                // 2. How often: plain choices, each with an example; what
                // the chosen one needs shows right under it.
                section(
                  l10n.goalQHowOften,
                  error: issue('amount') ?? issue('field'),
                  _editing
                      ? kindDetails()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final (kind, title, example) in options)
                              _KindOption(
                                title: title,
                                example: example,
                                selected: _kind == kind,
                                onTap: () => _setKind(kind, type),
                                details: _kind == kind && kind != GoalKind.daily
                                    ? kindDetails()
                                    : null,
                              ),
                          ],
                        ),
                ),
                // 3. How long.
                section(
                  l10n.goalQHowLong,
                  error: issue('target'),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: [
                          for (final (count, label) in lengths)
                            ChoiceChip(
                              label: Text(label),
                              selected: !custom && _targetCount == count,
                              onSelected: (_) => setState(() {
                                _customLength = false;
                                _target.text = '$count';
                              }),
                            ),
                          ChoiceChip(
                            label: Text(l10n.goalLenOther),
                            selected: custom,
                            onSelected: (_) =>
                                setState(() => _customLength = true),
                          ),
                        ],
                      ),
                      if (custom) ...[
                        const SizedBox(height: AppSpacing.sm),
                        SizedBox(
                          width: 200,
                          child: TextField(
                            controller: _target,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              suffixText:
                                  _kind == GoalKind.target ||
                                      _period == GoalPeriod.week
                                  ? l10n
                                        .goalWeeks(_targetCount)
                                        .replaceAll(RegExp(r'^\d+\s*'), '')
                                  : l10n
                                        .insightDaysDone(_targetCount)
                                        .replaceAll(RegExp(r'^\d+\s*'), ''),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // The goal in a sentence, and how it counts.
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: c.brandPrimarySoft,
                    borderRadius: BorderRadius.circular(AppSpacing.lg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary ??
                            switch ((type, _kind)) {
                              (null, _) => l10n.goalPickActivityFirst,
                              (_, GoalKind.amount) => l10n.goalEnterAmount,
                              (_, GoalKind.target) => l10n.goalEnterTarget,
                              _ => l10n.goalPickActivityFirst,
                            },
                        style: context.textStyles.titleMedium?.copyWith(
                          color: c.onBrandPrimarySoft,
                        ),
                      ),
                      if (type != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.goalSummaryCounts(type.name),
                          style: context.textStyles.bodyMedium?.copyWith(
                            color: c.onBrandPrimarySoft,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // The rest, with good defaults, out of the way.
                InkWell(
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                  onTap: () => setState(() => _moreOptions = !_moreOptions),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.goalMoreOptions,
                                style: context.textStyles.titleSmall,
                              ),
                              Text(l10n.goalMoreOptionsHint, style: hint),
                            ],
                          ),
                        ),
                        AnimatedRotation(
                          turns: _moreOptions ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(AppIcons.expand, color: c.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_moreOptions ||
                    issue('title') != null ||
                    issue('start') != null) ...[
                  const SizedBox(height: AppSpacing.sm),
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
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton(
                          onPressed: _pickStart,
                          child: Text(formatDate(context, _start ?? _today)),
                        ),
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
                ],
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
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

/// One answer to "How often?": a radio, its name and an example; what it
/// needs ([details]) opens under it once chosen.
class _KindOption extends StatelessWidget {
  const _KindOption({
    required this.title,
    required this.example,
    required this.selected,
    required this.onTap,
    this.details,
  });

  final String title;
  final String example;
  final bool selected;
  final VoidCallback onTap;
  final Widget? details;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: selected ? c.brandPrimarySoft : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          side: BorderSide(
            color: selected ? c.brandPrimary : c.borderSubtle,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Semantics(
          selected: selected,
          button: true,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        selected ? AppIcons.taskDone : AppIcons.taskOpen,
                        color: selected ? c.brandPrimary : c.borderStrong,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: context.textStyles.titleSmall),
                            Text(
                              example,
                              style: context.textStyles.bodySmall?.copyWith(
                                color: c.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (details case final d?) ...[
                    const SizedBox(height: AppSpacing.md),
                    d,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
