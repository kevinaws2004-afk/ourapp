import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/errors/error_copy.dart';
import '../../../shared/widgets/state_views.dart';
import '../../activity_logs/domain/activity_log.dart';
import '../domain/plan.dart';
import '../domain/watch_day_overview.dart';
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

  /// Completes an open task (with Undo) or reopens a done one (F10).
  Future<void> toggleTask(PlannedItem item) {
    final id = item.plan.id;
    if (item.status == EffectivePlanStatus.completed) {
      return _run(() => _setStatus(id, PlanStatus.planned));
    }
    return _run(
      () => _setStatus(id, PlanStatus.completed),
      message: _l10n.planTaskDoneMessage,
      undo: () => _setStatus(id, PlanStatus.planned),
    );
  }

  Future<void> skip(PlannedItem item) => _run(
    () => _setStatus(item.plan.id, PlanStatus.skipped),
    message: _l10n.planSkippedMessage,
    undo: () => _setStatus(item.plan.id, item.plan.status),
  );

  Future<void> reopen(PlannedItem item) =>
      _run(() => _setStatus(item.plan.id, PlanStatus.planned));

  Future<void> moveToTomorrow(PlannedItem item) {
    final id = item.plan.id;
    final from = item.plan.planDate;
    final move = _ref.read(movePlanProvider);
    final restore = _ref.read(restoreItemProvider);
    final delete = _ref.read(deleteItemProvider);
    var moved = id;
    return _run(
      () async => moved = await move(id, from.addDays(1)),
      message: _l10n.planMovedMessage,
      // A repeating occurrence moved as a copy: drop the copy, bring it back.
      undo: () async {
        if (moved == id) return move(id, from).then((_) {});
        await delete(moved);
        await restore(id, const []);
      },
    );
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
      case PlanSheetAction.toggleTask:
        await toggleTask(item);
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
