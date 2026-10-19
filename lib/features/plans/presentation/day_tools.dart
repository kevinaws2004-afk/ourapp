import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/json_preferences.dart';
import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/ids/id_generator_provider.dart';
import '../../../core/time/clock_provider.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/errors/error_copy.dart';
import '../../../shared/widgets/state_views.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../domain/plan.dart';
import '../domain/routines.dart';
import 'plan_providers.dart';
import '../../../shared/widgets/text_input_dialog.dart';

const routinesKey = 'routines';

/// Saved routines, in the order they were made.
final routinesProvider = StreamProvider<List<Routine>>(
  (ref) => ref
      .watch(jsonPreferencesProvider)
      .watch(routinesKey)
      .map(Routine.listFromJson),
);

final applyRoutineItemsProvider = Provider(
  (ref) => ApplyRoutineItems(
    ref.watch(createPlanProvider),
    ref.watch(clockProvider),
    (id) async {
      final type = await ref.read(activityTypeRepositoryProvider).getType(id);
      return type != null && !type.isDeleted && type.supportsPlanning;
    },
  ),
);

enum _DayTool { copyFromYesterday, copyTo, saveRoutine, applyRoutine }

/// The selected day's tools in the Plan tab (P5): copy yesterday onto it,
/// copy it to another day, save it as a routine, or lay a routine onto it.
/// Each acts at once with Undo.
class DayToolsButton extends ConsumerWidget {
  const DayToolsButton({super.key, required this.date});

  final LocalDate date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<_DayTool>(
      tooltip: l10n.dayToolsTooltip,
      icon: const Icon(AppIcons.more),
      onSelected: (tool) => unawaited(switch (tool) {
        _DayTool.copyFromYesterday => _copy(
          context,
          ref,
          from: date.addDays(-1),
          to: date,
        ),
        _DayTool.copyTo => _copyTo(context, ref),
        _DayTool.saveRoutine => _saveRoutine(context, ref),
        _DayTool.applyRoutine => _applyRoutine(context, ref),
      }),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: _DayTool.copyFromYesterday,
          child: ListTile(
            leading: const Icon(AppIcons.copy),
            title: Text(l10n.dayToolsCopyYesterday),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: _DayTool.copyTo,
          child: ListTile(
            leading: const Icon(AppIcons.planNext),
            title: Text(l10n.dayToolsCopyTo),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: _DayTool.saveRoutine,
          child: ListTile(
            leading: const Icon(AppIcons.routine),
            title: Text(l10n.dayToolsSaveRoutine),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: _DayTool.applyRoutine,
          child: ListTile(
            leading: const Icon(AppIcons.repeat),
            title: Text(l10n.dayToolsApplyRoutine),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Future<void> _copyTo(BuildContext context, WidgetRef ref) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(date.year, date.month, date.day + 1),
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (picked == null || !context.mounted) return;
    await _copy(
      context,
      ref,
      from: date,
      to: LocalDate(picked.year, picked.month, picked.day),
    );
  }

  Future<void> _copy(
    BuildContext context,
    WidgetRef ref, {
    required LocalDate from,
    required LocalDate to,
  }) => copyDayPlans(context, ref, from: from, to: to);

  Future<void> _saveRoutine(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final items = routineItemsFrom(
      await _plansOf(ref, date),
      ref.read(clockProvider),
    );
    if (!context.mounted) return;
    if (items.isEmpty) {
      showMessageSnackBar(context, l10n.dayToolsNothingToSave);
      return;
    }
    final name = await showTextInputDialog(
      context,
      title: l10n.routineNameTitle,
      hint: l10n.routineNameHint,
      helper: l10n.routineItemCount(items.length),
      maxLength: Routine.maxNameLength,
    );
    final trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty || !context.mounted) return;
    final routines = ref.read(routinesProvider).value ?? const [];
    await ref.read(jsonPreferencesProvider).write(routinesKey, [
      for (final r in routines) r.toJson(),
      Routine(
        id: ref.read(idGeneratorProvider).newId(),
        name: trimmed,
        items: items,
      ).toJson(),
    ]);
    if (context.mounted) {
      showMessageSnackBar(context, l10n.routineSaved(trimmed));
    }
  }

  Future<void> _applyRoutine(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final routine = await showModalBottomSheet<Routine>(
      useRootNavigator: true,
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => const _RoutinePicker(),
    );
    if (routine == null || !context.mounted) return;
    try {
      final created = await ref.read(applyRoutineItemsProvider)(
        routine.items,
        date,
      );
      if (context.mounted) {
        _undoable(
          context,
          ref,
          l10n.routineApplied(created.length, routine.name),
          created,
        );
      }
    } catch (error) {
      if (context.mounted) {
        showMessageSnackBar(context, errorMessage(l10n, error));
      }
    }
  }
}

/// The plans of [day], with repeating ones made first.
Future<List<Plan>> _plansOf(WidgetRef ref, LocalDate day) async {
  final overview = await ref.read(dayOverviewProvider(day).future);
  return [for (final item in overview.planned) item.plan];
}

void _undoable(
  BuildContext context,
  WidgetRef ref,
  String message,
  List<PlanId> created,
) {
  final delete = ref.read(deleteItemProvider);
  showUndoSnackBar(
    context,
    message: message,
    onUndo: () async {
      for (final id in created) {
        await delete(id);
      }
    },
  );
}

/// Copies [from]'s plans onto [to], with Undo. Repeating plans are left
/// out: they follow their own days (Gym on Mon/Wed/Fri isn't copied onto a
/// Tuesday).
Future<void> copyDayPlans(
  BuildContext context,
  WidgetRef ref, {
  required LocalDate from,
  required LocalDate to,
}) async {
  final l10n = AppLocalizations.of(context);
  if (from == to) return;
  try {
    final plans = [
      for (final p in await _plansOf(ref, from))
        if (p.seriesId == null) p,
    ];
    final items = routineItemsFrom(plans, ref.read(clockProvider));
    if (items.isEmpty) {
      if (context.mounted) {
        showMessageSnackBar(context, l10n.dayToolsNothingToCopy);
      }
      return;
    }
    final created = await ref.read(applyRoutineItemsProvider)(items, to);
    if (context.mounted) {
      _undoable(
        context,
        ref,
        l10n.dayToolsCopied(
          created.length,
          MaterialLocalizations.of(context)
              .formatMediumDate(DateTime(to.year, to.month, to.day)),
        ),
        created,
      );
    }
  } catch (error) {
    if (context.mounted) {
      showMessageSnackBar(context, errorMessage(l10n, error));
    }
  }
}

/// Picks a routine to lay onto the day; each can be deleted from here.
class _RoutinePicker extends ConsumerWidget {
  const _RoutinePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final routines = ref.watch(routinesProvider).value ?? const [];
    final material = MaterialLocalizations.of(context);
    String summary(Routine r) {
      final timed = r.items.where((i) => i.startMinute != null).toList();
      final first = timed.isEmpty
          ? null
          : material.formatTimeOfDay(
              TimeOfDay(
                hour: timed.first.startMinute! ~/ 60,
                minute: timed.first.startMinute! % 60,
              ),
            );
      return [
        l10n.routineItemCount(r.items.length),
        ?first,
        r.items.take(3).map((i) => i.title).join(', '),
      ].join(' · ');
    }

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
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
              l10n.routinesTitle,
              style: context.textStyles.headlineSmall,
            ),
          ),
          if (routines.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                l10n.routinesEmpty,
                style: context.textStyles.bodyMedium?.copyWith(
                  color: c.textSecondary,
                ),
              ),
            ),
          for (final r in routines)
            ListTile(
              leading: Icon(AppIcons.routine, color: c.brandPrimary),
              title: Text(r.name),
              subtitle: Text(
                summary(r),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                tooltip: l10n.routineDelete,
                icon: const Icon(AppIcons.delete),
                onPressed: () => unawaited(
                  ref.read(jsonPreferencesProvider).write(routinesKey, [
                    for (final other in routines)
                      if (other.id != r.id) other.toJson(),
                  ]),
                ),
              ),
              onTap: () => Navigator.of(context).pop(r),
            ),
        ],
      ),
    );
  }
}
