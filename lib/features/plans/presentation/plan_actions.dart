import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/errors/error_copy.dart';
import '../../../shared/widgets/state_views.dart';
import '../../activity_logs/domain/activity_log.dart';
import '../../activity_logs/presentation/activity_log_providers.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../challenges/presentation/challenge_providers.dart';
import '../../focus/domain/focus_session.dart';
import '../../focus/presentation/focus_providers.dart';
import '../domain/plan.dart';
import '../domain/watch_day_overview.dart';
import 'item/how_did_it_go_sheet.dart';
import 'item/item_notifier.dart';
import 'plan_editor_sheet.dart';
import 'plan_providers.dart';
import 'widgets/repeat_sheet.dart';

/// Reversible plan actions shared by Today and the Plan tab: they act
/// immediately and offer Undo (ui_guidelines.md: no confirmation dialogs).
/// Failures show safe, localized copy.
class PlanActions {
  const PlanActions(this._context, this._ref);

  final BuildContext _context;
  final WidgetRef _ref;

  AppLocalizations get _l10n => AppLocalizations.of(_context);

  Future<void> _run(
    Future<void> Function() action, {
    String? message,
    Future<void> Function()? undo,
  }) async {
    final l10n = _l10n;
    final messenger = ScaffoldMessenger.of(_context);
    try {
      await action();
      if (message == null || !_context.mounted) return;
      if (undo == null) {
        showMessageSnackBar(_context, message);
      } else {
        showUndoSnackBar(
          _context,
          message: message,
          onUndo: () async {
            try {
              await undo();
            } catch (error) {
              messenger.showSnackBar(
                SnackBar(content: Text(errorMessage(l10n, error))),
              );
            }
          },
        );
      }
    } catch (error) {
      if (_context.mounted) {
        showMessageSnackBar(_context, errorMessage(l10n, error));
      }
    }
  }

  Future<void> _setStatus(PlanId id, PlanStatus status) =>
      _ref.read(setPlanStatusProvider)(id, status);

  /// Whether [toggleDone] can act: an open item can be marked done, and one
  /// marked done can be reopened. Something logged on a past day counts as
  /// done by itself (ADR-040) and has nothing to undo here.
  static bool canToggleDone(PlannedItem item) =>
      item.isOpen || item.plan.status == PlanStatus.completed;

  /// Done (with Undo, then "How did it go?" when it applies; [complete]) or
  /// Not done for one marked done (F10, A17).
  Future<void> toggleDone(PlannedItem item) {
    final id = item.plan.id;
    if (!item.isOpen) {
      return _run(() => _setStatus(id, PlanStatus.planned));
    }
    return complete(item);
  }

  /// Done (ADR-046): marks [item] done with a snackbar that shows the
  /// streak it keeps ("Meditation done · 🔥 13", Undo), then, if its activity
  /// has meaningful details, asks "How did it go?". Stays on the current
  /// screen: the row shows the result.
  Future<void> complete(PlannedItem item) async {
    final id = item.plan.id;
    final type = item.type;
    final streak = type == null
        ? null
        : _ref.read(activityStreaksProvider)[type.id];
    final markDone = _ref.read(markItemDoneProvider);
    final deleteLog = _ref.read(deleteActivityLogProvider);
    ActivityLogId? created;
    var ok = false;
    await _run(
      () async {
        created = await markDone(id);
        ok = true;
      },
      message: doneMessage(_l10n, item.plan.title, streak),
      undo: () async {
        await _setStatus(id, PlanStatus.planned);
        if (created case final log?) await deleteLog(log);
      },
    );
    if (ok && (type?.hasMeaningfulDetails ?? false) && _context.mounted) {
      await _howDidItGo(id);
    }
  }

  /// Finish (ADR-046): stops [session]'s timer, which marks its thing done
  /// with the timed length, with the same snackbar and "How did it go?" as
  /// [complete].
  Future<void> finish(
    FocusSession session, {
    required String title,
    ActivityType? type,
  }) async {
    final streak = type == null
        ? null
        : _ref.read(activityStreaksProvider)[type.id];
    var ok = false;
    await _run(() async {
      await _ref.read(finishFocusSessionProvider)(session.id);
      ok = true;
    }, message: doneMessage(_l10n, title, streak));
    final planId = session.planId;
    if (ok &&
        planId != null &&
        (type?.hasMeaningfulDetails ?? false) &&
        _context.mounted) {
      await _howDidItGo(planId);
    }
  }

  /// "How did it go?" for a just-done plan. An open item (the one it was
  /// finished from) reloads first, so the sheet has its timed length.
  Future<void> _howDidItGo(PlanId id) async {
    final args = ItemArgs.plan(id);
    if (_ref.exists(itemProvider(args))) {
      await _ref.read(itemProvider(args).notifier).reload();
    }
    if (_context.mounted) await showHowDidItGo(_context, args);
  }

  /// "Meditation done", or "Meditation done · 🔥 13" when it keeps a streak.
  static String doneMessage(
    AppLocalizations l10n,
    String title,
    ActivityStreak? streak,
  ) => streak == null
      ? l10n.itemDoneMessage(title)
      : l10n.itemDoneStreakMessage(title, streak.afterToday);

  Future<void> skip(PlannedItem item) => _run(
    () => _setStatus(item.plan.id, PlanStatus.skipped),
    message: _l10n.planSkippedMessage,
    undo: () => _setStatus(item.plan.id, item.plan.status),
  );

  Future<void> reopen(PlannedItem item) =>
      _run(() => _setStatus(item.plan.id, PlanStatus.planned));

  Future<void> moveToTomorrow(PlannedItem item) =>
      _moveTo(item, item.plan.planDate.addDays(1), _l10n.planMovedMessage);

  /// Move to… (P7): a date picker, then the same move, with Undo.
  Future<void> moveTo(PlannedItem item) async {
    final from = item.plan.planDate;
    final picked = await showDatePicker(
      context: _context,
      initialDate: DateTime(from.year, from.month, from.day + 1),
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (picked == null || !_context.mounted) return;
    final to = LocalDate(picked.year, picked.month, picked.day);
    if (to == from) return;
    await _moveTo(
      item,
      to,
      _l10n.planMovedTo(
        MaterialLocalizations.of(_context).formatMediumDate(picked),
      ),
    );
  }

  Future<void> _moveTo(PlannedItem item, LocalDate to, String message) {
    final id = item.plan.id;
    final from = item.plan.planDate;
    final move = _ref.read(movePlanProvider);
    final restore = _ref.read(restoreItemProvider);
    final delete = _ref.read(deleteItemProvider);
    var moved = id;
    return _run(
      () async => moved = await move(id, to),
      message: message,
      // A repeating occurrence moved as a copy: drop the copy, bring it back.
      undo: () async {
        if (moved == id) return move(id, from).then((_) {});
        await delete(moved);
        await restore(id, const []);
      },
    );
  }

  /// Brings yesterday's [items] to [today] (T2): each keeps its time, or
  /// becomes Anytime when that time has passed. Undo puts them back.
  Future<void> doToday(List<PlannedItem> items, LocalDate today) {
    final move = _ref.read(movePlanProvider);
    final update = _ref.read(updatePlanProvider);
    final restore = _ref.read(restoreItemProvider);
    final delete = _ref.read(deleteItemProvider);
    final moved = <PlanId, PlanId>{};
    return _run(
      () async {
        for (final item in items) {
          moved[item.plan.id] = await move(
            item.plan.id,
            today,
            anytimeIfPassed: true,
          );
        }
      },
      message: _l10n.fromYesterdayMoved(items.length),
      undo: () async {
        for (final item in items) {
          final id = item.plan.id;
          final copy = moved[id];
          if (copy == null) continue;
          if (copy == id) {
            await update(id, item.plan.toDraft());
          } else {
            // A repeating occurrence moved as a copy.
            await delete(copy);
            await restore(id, const []);
          }
        }
      },
    );
  }

  /// Lets [items] go (T2, T7): skipped where they are, no judgment; Undo.
  Future<void> letGo(List<PlannedItem> items) => _run(
    () async {
      for (final item in items) {
        await _setStatus(item.plan.id, PlanStatus.skipped);
      }
    },
    message: _l10n.letGoMessage(items.length),
    undo: () async {
      for (final item in items) {
        await _setStatus(item.plan.id, item.plan.status);
      }
    },
  );

  /// A copy of the item on the same day (B7), with Undo.
  Future<void> duplicate(PlannedItem item) {
    final duplicate = _ref.read(duplicatePlanProvider);
    final delete = _ref.read(deleteItemProvider);
    PlanId? copy;
    return _run(
      () async => copy = await duplicate(item.plan.id),
      message: _l10n.planDuplicatedMessage,
      undo: () async {
        if (copy case final id?) await delete(id);
      },
    );
  }

  /// The options on a long-press (B7, R1): done / not done, move to
  /// tomorrow, change time and details, duplicate, skip, delete. Each acts
  /// at once, with Undo.
  Future<void> quickActions(PlannedItem item) async {
    final l10n = _l10n;
    final isOpen = item.isOpen;
    final action = await showModalBottomSheet<_QuickAction>(
      context: _context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        ListTile tile(IconData icon, String label, _QuickAction value) =>
            ListTile(
              leading: Icon(icon),
              title: Text(label),
              onTap: () => Navigator.of(context).pop(value),
            );
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canToggleDone(item))
                tile(
                  AppIcons.taskDone,
                  isOpen ? l10n.planCompleteTask : l10n.planReopenTask,
                  _QuickAction.toggleDone,
                ),
              if (isOpen)
                tile(
                  AppIcons.moveToTomorrow,
                  l10n.planMoveToTomorrow,
                  _QuickAction.moveToTomorrow,
                ),
              if (isOpen)
                tile(AppIcons.date, l10n.planMoveTo, _QuickAction.moveTo),
              tile(AppIcons.edit, l10n.planEditAction, _QuickAction.edit),
              tile(
                AppIcons.duplicate,
                l10n.planDuplicate,
                _QuickAction.duplicate,
              ),
              if (item.plan.isRepeating)
                tile(
                  AppIcons.repeat,
                  l10n.planStopRepeating,
                  _QuickAction.stopRepeating,
                )
              else
                tile(AppIcons.repeat, l10n.planRepeat, _QuickAction.repeat),
              if (isOpen) tile(AppIcons.skip, l10n.planSkip, _QuickAction.skip),
              tile(AppIcons.delete, l10n.planDelete, _QuickAction.delete),
            ],
          ),
        );
      },
    );
    if (!_context.mounted) return;
    switch (action) {
      case _QuickAction.toggleDone:
        await toggleDone(item);
      case _QuickAction.moveToTomorrow:
        await moveToTomorrow(item);
      case _QuickAction.moveTo:
        await moveTo(item);
      case _QuickAction.edit:
        await open(item);
      case _QuickAction.duplicate:
        await duplicate(item);
      case _QuickAction.repeat:
        await repeat(item);
      case _QuickAction.stopRepeating:
        await stopRepeating(item);
      case _QuickAction.skip:
        await skip(item);
      case _QuickAction.delete:
        await delete(item);
      case null:
        break;
    }
  }

  /// Makes the plan repeat on chosen days (ADR-036).
  Future<void> repeat(PlannedItem item) async {
    final rule = await showRepeatSheet(_context, date: item.plan.planDate);
    if (rule == null || !_context.mounted) return;
    final days = formatWeekdays(_context, rule.weekdays);
    await _run(
      () => _ref.read(repeatPlanProvider)(item.plan.id, rule),
      message: _l10n.planRepeatSaved(days),
    );
  }

  Future<void> stopRepeating(PlannedItem item) => _run(
    () => _ref.read(stopRepeatingProvider)(item.plan.id),
    message: _l10n.planRepeatStopped,
  );

  /// Deletes the item and what was logged into it (ADR-035), with Undo.
  Future<void> delete(PlannedItem item) {
    var logs = const <ActivityLogId>[];
    // Read now: Undo may run after the screen that deleted it has closed.
    final restore = _ref.read(restoreItemProvider);
    return _run(
      () async => logs = await _ref.read(deleteItemProvider)(item.plan.id),
      message: _l10n.planDeletedMessage,
      undo: () => restore(item.plan.id, logs),
    );
  }

  /// Opens [item]'s plan sheet (edit its title, time and notes) and runs
  /// the action chosen there. Returns that action.
  Future<PlanSheetAction?> open(PlannedItem item) async {
    final action = await showPlanEditor(
      _context,
      date: item.plan.planDate,
      item: item,
    );
    if (!_context.mounted) return action;
    switch (action) {
      case PlanSheetAction.toggleDone:
        await toggleDone(item);
      case PlanSheetAction.repeat:
        await repeat(item);
      case PlanSheetAction.stopRepeating:
        await stopRepeating(item);
      case PlanSheetAction.skip:
        await skip(item);
      case PlanSheetAction.reopen:
        await reopen(item);
      case PlanSheetAction.moveToTomorrow:
        await moveToTomorrow(item);
      case PlanSheetAction.delete:
        await delete(item);
      case null:
        break;
    }
    return action;
  }
}

enum _QuickAction {
  toggleDone,
  moveToTomorrow,
  moveTo,
  edit,
  duplicate,
  repeat,
  stopRepeating,
  skip,
  delete,
}
