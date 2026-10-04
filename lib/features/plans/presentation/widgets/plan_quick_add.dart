import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/app_icons.dart';
import '../../../../core/design/tokens/spacing.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/time/local_date.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/errors/error_copy.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../../activity_types/domain/activity_ids.dart';
import '../../../activity_types/domain/activity_type.dart';
import '../../../activity_types/domain/activity_type_definition.dart';
import '../../../activity_types/presentation/activity_templates.dart';
import '../../../activity_types/presentation/activity_type_providers.dart';
import '../../domain/plan.dart';
import '../../domain/plan_title_match.dart';
import '../plan_providers.dart';

/// Fast day planning (F3): type what you'll do, optionally a from–to time,
/// press enter. The keyboard stays open for the next one.
///
/// Typing an activity's name ("Gym") plans that activity, so tapping the
/// plan later records the session (ADR-030); its chip lights up to show it.
/// A starter template's name installs that template first. Anything else is
/// a simple task ("Bath").
class PlanQuickAdd extends ConsumerStatefulWidget {
  const PlanQuickAdd({super.key, required this.date});

  final LocalDate date;

  @override
  ConsumerState<PlanQuickAdd> createState() => _PlanQuickAddState();
}

class _PlanQuickAddState extends ConsumerState<PlanQuickAdd> {
  final _title = TextEditingController();
  final _focus = FocusNode();
  ActivityTypeId? _typeId;

  /// The chip was selected by typing its name, not by tapping it.
  bool _matchedByName = false;
  TimeOfDay? _start;
  TimeOfDay? _end;

  @override
  void dispose() {
    _title.dispose();
    _focus.dispose();
    super.dispose();
  }

  List<ActivityType> get _plannable => [
    ...?ref
        .read(activeActivityTypesProvider)
        .value
        ?.where((t) => t.supportsPlanning),
  ];

  void _onTitleChanged(String text) {
    if (_typeId != null && !_matchedByName) return; // a tapped chip wins
    final match = matchByName(text, _plannable, (t) => t.name);
    setState(() {
      _typeId = match?.id;
      _matchedByName = match != null;
    });
  }

  DateTime? _instant(TimeOfDay? time) {
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

  /// The activity for this plan: the chosen chip, or a starter template with
  /// the typed name (installed now).
  Future<ActivityTypeId?> _resolveActivity(AppLocalizations l10n) async {
    if (_typeId case final id?) return id;
    final template = matchByName<ActivityTypeDefinition>(
      _title.text,
      activityTemplates(l10n),
      (t) => t.name,
    );
    if (template == null) return null;
    final id = await ref.read(installActivityTemplateProvider)(template);
    if (mounted) {
      showMessageSnackBar(context, l10n.planActivityAdded(template.name));
    }
    return id;
  }

  Future<void> _add() async {
    if (_title.text.trim().isEmpty && _typeId == null) return;
    final l10n = AppLocalizations.of(context);
    try {
      final typeId = await _resolveActivity(l10n);
      await ref.read(createPlanProvider)(
        PlanDraft(
          planDate: widget.date,
          title: _title.text,
          activityTypeId: typeId,
          plannedStartAt: _instant(_start),
          plannedEndAt: _start == null ? null : _instant(_end),
        ),
      );
      _title.clear();
      setState(() {
        _typeId = null;
        _matchedByName = false;
        _start = null;
        _end = null;
      });
      _focus.requestFocus();
    } on ValidationException catch (e) {
      if (mounted) {
        showMessageSnackBar(
          context,
          validationMessage(l10n, e.issues.first.code),
        );
      }
    } catch (error) {
      if (mounted) showMessageSnackBar(context, errorMessage(l10n, error));
    }
  }

  /// Picks the start, then an optional end (cancel = no end time).
  Future<void> _pickTimes(AppLocalizations l10n) async {
    final start = await showTimePicker(
      context: context,
      helpText: l10n.planPickStart,
      initialTime: _start ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (start == null || !mounted) return;
    final end = await showTimePicker(
      context: context,
      helpText: l10n.planPickEnd,
      initialTime:
          _end ?? TimeOfDay(hour: (start.hour + 1) % 24, minute: start.minute),
    );
    setState(() {
      _start = start;
      _end = end;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    final types = [
      ...?ref
          .watch(activeActivityTypesProvider)
          .value
          ?.where((t) => t.supportsPlanning),
    ];
    final timeLabel = switch ((_start, _end)) {
      (null, _) => l10n.planAddTime,
      (final s?, null) => material.formatTimeOfDay(s),
      (final s?, final e?) => l10n.planTimeRange(
        material.formatTimeOfDay(s),
        material.formatTimeOfDay(e),
      ),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _title,
                focusNode: _focus,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(hintText: l10n.planQuickAddHint),
                onChanged: _onTitleChanged,
                onSubmitted: (_) => _add(),
              ),
            ),
            TextButton.icon(
              icon: const Icon(AppIcons.time),
              label: Text(timeLabel),
              onPressed: () => _pickTimes(l10n),
            ),
            IconButton(
              tooltip: l10n.planAddAction,
              icon: const Icon(AppIcons.add),
              onPressed: _add,
            ),
          ],
        ),
        if (types.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final type in types)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: ChoiceChip(
                      label: Text(type.name),
                      selected: _typeId == type.id,
                      onSelected: (selected) => setState(() {
                        _typeId = selected ? type.id : null;
                        _matchedByName = false;
                      }),
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
