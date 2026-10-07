import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/app_icons.dart';
import '../../../../core/design/context_ext.dart';
import '../../../../core/design/tokens/sizes.dart';
import '../../../../core/design/tokens/spacing.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/time/clock_provider.dart';
import '../../../../core/time/local_date.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/errors/error_copy.dart';
import '../../../../shared/widgets/activity_badge.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../../activity_types/domain/activity_ids.dart';
import '../../../activity_types/domain/activity_type.dart';
import '../../../activity_types/domain/activity_type_definition.dart';
import '../../../activity_types/presentation/built_in_activities.dart';
import '../../../activity_types/presentation/activity_type_providers.dart';
import '../../domain/plan.dart';
import '../../domain/plan_title_match.dart';
import '../activity_chooser.dart';
import '../plan_date_notifier.dart';
import '../plan_providers.dart';
import 'plan_time_sheet.dart';

/// Fast day planning (F3): type what you'll do and press enter (or "+") to
/// add it to the day; the keyboard stays open for the next one. While
/// typing, matching activities are suggested (A6): yours first, then
/// built-in ones, shown the same way (ADR-042),
/// and two actions appear: **Start now** (today only: it starts now and opens
/// right away, ADR-035) and a time, chosen in one sheet (A5).
///
/// Every item comes from an activity. Typing an activity's name ("Gym")
/// plans that activity, so its item has its fields (ADR-030); its chip
/// lights up to show it. A built-in activity's name saves it as yours first,
/// unless one of yours already has the name (names are unique, A8). Any other
/// name ("Bath") opens the builder to make it your own: you choose what to
/// log, and the new activity is added to the day. **Browse activities** and
/// **Make your own** do the same without typing ([chooser]).
class PlanQuickAdd extends ConsumerStatefulWidget {
  const PlanQuickAdd({
    super.key,
    required this.date,
    required this.chooser,
    this.onStartNow,
  });

  /// How many "Recent" chips to show (A7).
  static const maxRecent = 8;

  final LocalDate date;

  /// Picks an activity from the list, or makes a new one, for what's being
  /// added.
  final ActivityChooser chooser;

  /// Offers "Start now" (today only): the item starts now and opens right
  /// away, to log what you're doing (ADR-035).
  final ValueChanged<PlanId>? onStartNow;

  @override
  ConsumerState<PlanQuickAdd> createState() => _PlanQuickAddState();
}

class _PlanQuickAddState extends ConsumerState<PlanQuickAdd> {
  final _title = TextEditingController();
  final _focus = FocusNode();
  ActivityTypeId? _typeId;

  /// The chip was selected by typing its name, not by tapping it.
  bool _matchedByName = false;
  LocalTime? _start;
  LocalTime? _end;

  @override
  void dispose() {
    _title.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _hasInput => _title.text.trim().isNotEmpty || _typeId != null;

  List<ActivityType> get _plannable => ref.read(recentActivityTypesProvider);

  List<ActivityType> get _active =>
      ref.read(activeActivityTypesProvider).value ?? const [];

  void _onTitleChanged(String text) {
    if (_typeId != null && !_matchedByName) {
      setState(() {}); // a tapped chip wins; refresh the actions
      return;
    }
    final match = matchByName(text, _plannable, (t) => t.name);
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

  /// The activity for this plan: the chosen chip, one of yours with the typed
  /// name, or a built-in one with that name (saved as yours now). Null when
  /// nothing has the name yet.
  Future<ActivityTypeId?> _resolveActivity(AppLocalizations l10n) async {
    if (_typeId case final id?) return id;
    if (matchByName(_title.text, _active, (t) => t.name) case final type?) {
      // Not plannable (or it would be a chip): validation says so.
      return type.id;
    }
    final builtIn = matchByName<ActivityTypeDefinition>(
      _title.text,
      builtInActivities(l10n),
      (t) => t.name,
    );
    if (builtIn == null) return null;
    // No pop-up: it was suggested like any activity (A9).
    return ref.read(addBuiltInActivityProvider)(builtIn);
  }

  Future<void> _add({bool now = false}) async {
    if (!_hasInput) return;
    final l10n = AppLocalizations.of(context);
    try {
      var title = _title.text;
      var typeId = await _resolveActivity(l10n);
      if (typeId == null) {
        // A new name: make it your own first, choosing what to log.
        typeId = await widget.chooser.makeOwn(title.trim());
        if (typeId == null || !mounted) return;
        title = ''; // the activity's name, even if renamed in the builder
      }
      final id = await ref.read(createPlanProvider)(
        PlanDraft(
          planDate: widget.date,
          title: title,
          activityTypeId: typeId,
          plannedStartAt: now
              ? ref.read(clockProvider).nowUtc()
              : _instant(_start),
          plannedEndAt: now || _start == null ? null : _instant(_end),
        ),
      );
      _title.clear();
      setState(() {
        _typeId = null;
        _matchedByName = false;
        _start = null;
        _end = null;
      });
      if (now) {
        widget.onStartNow?.call(id);
      } else {
        _focus.requestFocus();
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
    }
  }

  /// Chooses the activity from [pick] (the list of activities, or a new one
  /// of your own); its chip lights up, ready to add or give a time.
  Future<void> _choose(Future<ActivityTypeId?> Function() pick) async {
    final id = await pick();
    if (id == null || !mounted) return;
    setState(() {
      _typeId = id;
      _matchedByName = false;
    });
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final recent = ref.watch(recentActivityTypesProvider);
    final active =
        ref.watch(activeActivityTypesProvider).value ?? const <ActivityType>[];
    final onStartNow = widget.onStartNow;
    final start = _start;
    final end = _end;
    final timeLabel = switch ((start, end)) {
      (null, _) => l10n.planAddTime,
      (final s?, null) => formatLocalTime(context, s),
      (final s?, final e?) => l10n.planTimeRange(
        formatLocalTime(context, s),
        formatLocalTime(context, e),
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
            IconButton(
              tooltip: l10n.planAddAction,
              icon: const Icon(AppIcons.add),
              onPressed: _hasInput ? _add : null,
            ),
          ],
        ),
        if (_typeId == null)
          _Suggestions(
            text: _title.text,
            types: recent,
            builtIns: [
              for (final d in builtInActivities(l10n))
                if (matchByName(d.name, active, (a) => a.name) == null) d,
            ],
            onType: (type) => _useName(type.name),
            onBuiltIn: (definition) => _useName(definition.name),
            onMakeOwn: _add,
          ),
        if (!_hasInput) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              AppButton(
                label: l10n.planBrowseActivities,
                icon: AppIcons.browse,
                variant: AppButtonVariant.tertiary,
                onPressed: () => _choose(widget.chooser.browse),
              ),
              AppButton(
                label: l10n.planMakeOwn,
                icon: AppIcons.add,
                variant: AppButtonVariant.tertiary,
                onPressed: () => _choose(() => widget.chooser.makeOwn('')),
              ),
            ],
          ),
        ],
        if (_hasInput) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              if (onStartNow != null)
                AppButton(
                  label: l10n.planStartNow,
                  icon: AppIcons.start,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => _add(now: true),
                ),
              AppButton(
                label: timeLabel,
                icon: AppIcons.time,
                variant: AppButtonVariant.tertiary,
                onPressed: _pickTime,
              ),
            ],
          ),
        ],
        if (recent.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.planRecent,
            style: context.textStyles.labelMedium?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final type in recent.take(PlanQuickAdd.maxRecent))
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

/// Activities matching what's being typed (A6): yours, then built-in ones,
/// each with what it logs and nothing marking which is which (ADR-042).
class _Suggestions extends StatelessWidget {
  const _Suggestions({
    required this.text,
    required this.types,
    required this.builtIns,
    required this.onType,
    required this.onBuiltIn,
    required this.onMakeOwn,
  });

  static const _limit = 4;

  final String text;
  final List<ActivityType> types;

  /// Built-in activities none of yours has the name of.
  final List<ActivityTypeDefinition> builtIns;
  final ValueChanged<ActivityType> onType;
  final ValueChanged<ActivityTypeDefinition> onBuiltIn;

  /// Makes the typed name a new activity of your own.
  final VoidCallback onMakeOwn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final matchingTypes = suggestByName(
      text,
      types,
      (t) => t.name,
      limit: _limit,
    );
    final matchingBuiltIns = suggestByName(
      text,
      builtIns,
      (t) => t.name,
      limit: _limit - matchingTypes.length,
    );
    final exact = matchByName(text, matchingBuiltIns, (t) => t.name);
    // Offer to make it your own unless the name is already taken (A8).
    final name = text.trim();
    final isNew =
        name.isNotEmpty &&
        exact == null &&
        matchByName(text, types, (t) => t.name) == null;
    if (matchingTypes.isEmpty && matchingBuiltIns.isEmpty && !isNew) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final type in matchingTypes)
            _SuggestionTile(
              iconId: type.iconId,
              colorKey: type.colorKey,
              title: type.name,
              subtitle: type.activeFields.map((f) => f.name).join(' · '),
              onTap: () => onType(type),
            ),
          for (final definition in matchingBuiltIns)
            _SuggestionTile(
              iconId: definition.iconId,
              colorKey: definition.colorKey,
              title: definition.name,
              subtitle: definition.fields.map((f) => f.name).join(' · '),
              selected: identical(definition, exact),
              onTap: () => onBuiltIn(definition),
            ),
          if (isNew)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(AppIcons.add),
              title: Text(l10n.planMakeOwnNamed(name)),
              subtitle: Text(l10n.planMakeOwnHint),
              onTap: onMakeOwn,
            ),
        ],
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.iconId,
    required this.colorKey,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.selected = false,
  });

  final String iconId;
  final String colorKey;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: ActivityBadge(
      iconId: iconId,
      colorKey: colorKey,
      size: AppSizes.badgeSmall,
    ),
    title: Text(title),
    subtitle: subtitle.isEmpty
        ? null
        : Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
    trailing: selected
        ? Icon(AppIcons.check, color: context.colors.brandPrimary)
        : null,
    selected: selected,
    onTap: onTap,
  );
}
