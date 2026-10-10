import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/time/clock_provider.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/errors/error_copy.dart';
import '../../../shared/widgets/activity_badge.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/discard_guard.dart';
import '../../../shared/widgets/state_views.dart';
import '../../activity_logs/presentation/form/field_editor_shell.dart';
import '../../activity_logs/presentation/value_formatting.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../../plans/presentation/activity_chooser.dart';
import '../../plans/presentation/plan_date_notifier.dart';
import '../domain/challenge.dart';
import 'challenge_providers.dart';

/// The numbers of days offered as quick picks.
const _presets = [7, 21, 30, 75, 100];

/// Starts a challenge ([initial] null; [chooser] picks its activity) or edits
/// one's name and number of days ([initial]); ADR-044. Everything else is
/// worked out: recording the activity is what counts a day.
Future<void> showChallengeSheet(
  BuildContext context, {
  Challenge? initial,
  ActivityChooser? chooser,
  ActivityTypeId? activityId,
  int? days,
}) => showModalBottomSheet<void>(
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
  late final _days = TextEditingController(
    text: '${widget.initial?.targetDays ?? widget.presetDays ?? 30}',
  );
  late ActivityTypeId? _activityId =
      widget.initial?.activityTypeId ?? widget.presetActivity;
  LocalDate? _start;
  List<ValidationIssue> _issues = const [];
  bool _saving = false;

  bool get _editing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    // Rebuild on typing so the hint and the discard guard follow it.
    _title.addListener(() => setState(() {}));
    _days.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    _days.dispose();
    super.dispose();
  }

  int get _targetDays => int.tryParse(_days.text.trim()) ?? 0;

  LocalDate get _today => currentLocalDate(ref.read(clockProvider));

  bool get _dirty {
    if (_saving) return false;
    final initial = widget.initial;
    if (initial == null) {
      return _activityId != null || _title.text.isNotEmpty || _start != null;
    }
    return _title.text != initial.title || _targetDays != initial.targetDays;
  }

  Future<void> _choose(Future<ActivityTypeId?> Function() pick) async {
    final id = await pick();
    if (id != null && mounted) setState(() => _activityId = id);
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

  String _autoTitle(AppLocalizations l10n, String? activityName) =>
      l10n.challengeAutoTitle(
        _targetDays < 1 ? 1 : _targetDays,
        activityName ?? '',
      );

  Future<void> _save(String? activityName) async {
    final l10n = AppLocalizations.of(context);
    final typed = _title.text.trim();
    final title = typed.isEmpty ? _autoTitle(l10n, activityName) : typed;
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
          targetDays: _targetDays,
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
            targetDays: _targetDays,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final type = _activityId == null
        ? null
        : ref.watch(activityTypeProvider(_activityId!)).value;
    String? issue(String target) => firstIssueMessage(l10n, _issues, target);
    final chooser = widget.chooser;
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
                          subtitle: Text(l10n.challengeActivityHelper),
                          onTap: _editing || chooser == null
                              ? null
                              : () => _choose(chooser.browse),
                        )
                      : Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.xs,
                          children: [
                            if (chooser != null) ...[
                              AppButton(
                                label: l10n.planBrowseActivities,
                                variant: AppButtonVariant.secondary,
                                onPressed: () => _choose(chooser.browse),
                              ),
                              AppButton(
                                label: l10n.planMakeOwn,
                                variant: AppButtonVariant.tertiary,
                                onPressed: () =>
                                    _choose(() => chooser.makeOwn('')),
                              ),
                            ],
                          ],
                        ),
                ),
                FieldEditorShell(
                  label: l10n.challengeDaysLabel,
                  error: issue('target'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _days,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          helperText: l10n.challengeDaysHelper,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        children: [
                          for (final n in _presets)
                            ChoiceChip(
                              label: Text('$n'),
                              selected: _targetDays == n,
                              onSelected: (_) => _days.text = '$n',
                            ),
                        ],
                      ),
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
                      hintText: type == null
                          ? null
                          : _autoTitle(l10n, type.name),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                FilledButton(
                  onPressed: _saving ? null : () => _save(type?.name),
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
