import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/errors/error_copy.dart';
import '../../../shared/widgets/activity_badge.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/state_views.dart';
import 'activity_log_providers.dart';
import 'form/activity_log_form.dart';
import 'form/date_time_editors.dart';
import 'form/field_editor_shell.dart';
import 'log_editor_notifier.dart';

/// Create or edit a log (ui_guidelines.md §4.4): built-in time, duration and
/// notes around the generic form renderer.
class LogEditorScreen extends ConsumerWidget {
  const LogEditorScreen({super.key, required this.args});

  final LogEditorArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final editor = ref.watch(logEditorProvider(args));
    final state = editor.value;
    return PopScope(
      canPop: !(state?.isDirty ?? false),
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard(context) && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: state == null
              ? null
              : Row(
                  children: [
                    ActivityBadge(
                      iconId: state.type.iconId,
                      colorKey: state.type.colorKey,
                      size: 32,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Flexible(
                      child: Text(
                        state.isNew
                            ? l10n.recordNewTitle(state.type.name)
                            : l10n.recordEditTitle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
          actions: [
            if (state != null && !state.isNew)
              IconButton(
                tooltip: l10n.actionDelete,
                icon: const Icon(AppIcons.delete),
                onPressed: () => _delete(context, ref, state),
              ),
          ],
        ),
        body: AsyncValueView(
          value: editor,
          onRetry: () => ref.invalidate(logEditorProvider(args)),
          data: (state) => _LogForm(args: args, state: state),
        ),
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    LogEditorState state,
  ) async {
    final l10n = AppLocalizations.of(context);
    final logId = state.logId!;
    final messenger = ScaffoldMessenger.of(context);
    final restore = ref.read(restoreActivityLogProvider);
    try {
      await ref.read(deleteActivityLogProvider)(logId);
    } catch (error) {
      if (context.mounted) {
        showMessageSnackBar(context, errorMessage(l10n, error));
      }
      return;
    }
    if (!context.mounted) return;
    Navigator.of(context).pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.recordDeleted),
          action: SnackBarAction(
            label: l10n.actionUndo,
            onPressed: () => unawaited(restore(logId)),
          ),
        ),
      );
  }
}

/// Irreversible: discarding unsaved input needs confirmation (§7.2).
Future<bool> _confirmDiscard(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.discardChangesTitle),
      content: Text(l10n.discardChangesMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.actionKeepEditing),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.actionDiscard),
        ),
      ],
    ),
  );
  return result ?? false;
}

class _LogForm extends ConsumerWidget {
  const _LogForm({required this.args, required this.state});

  final LogEditorArgs args;
  final LogEditorState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(logEditorProvider(args).notifier);
    final margin = WindowSizeClass.of(context).screenMargin;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppContentWidth.reading),
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            margin,
            AppSpacing.lg,
            margin,
            AppSpacing.huge,
          ),
          children: [
            FieldEditorShell(
              label: l10n.whenLabel,
              child: _StartedAtPicker(
                value: state.startedAt,
                onChanged: notifier.setStartedAt,
              ),
            ),
            FieldEditorShell(
              label: l10n.durationLabel,
              error: firstIssueMessage(l10n, state.issues, 'duration'),
              child: DurationInput(
                milliseconds: state.durationMs,
                onChanged: notifier.setDuration,
              ),
            ),
            ActivityLogFormFields(
              fields: state.visibleFields,
              values: state.values,
              issues: state.issues,
              onChanged: notifier.setValue,
            ),
            FieldEditorShell(
              label: l10n.notesLabel,
              error: firstIssueMessage(l10n, state.issues, 'notes'),
              child: TextFormField(
                initialValue: state.notes,
                minLines: 3,
                maxLines: 8,
                textCapitalization: TextCapitalization.sentences,
                onChanged: notifier.setNotes,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l10n.actionSave,
              onPressed: state.isSaving ? null : () => _save(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final saved = await ref.read(logEditorProvider(args).notifier).save();
      if (!context.mounted) return;
      if (saved) {
        Navigator.of(context).pop();
        showMessageSnackBar(context, l10n.recordSaved);
      } else {
        showMessageSnackBar(context, l10n.errorValidation);
      }
    } catch (error) {
      if (context.mounted) {
        showMessageSnackBar(context, errorMessage(l10n, error));
      }
    }
  }
}

class _StartedAtPicker extends StatelessWidget {
  const _StartedAtPicker({required this.value, required this.onChanged});

  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final material = MaterialLocalizations.of(context);
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        OutlinedButton.icon(
          icon: const Icon(AppIcons.date),
          label: Text(material.formatMediumDate(value)),
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: value,
              firstDate: DateTime(1900),
              lastDate: DateTime(2200),
            );
            if (date != null) {
              onChanged(
                DateTime(
                  date.year,
                  date.month,
                  date.day,
                  value.hour,
                  value.minute,
                ),
              );
            }
          },
        ),
        OutlinedButton.icon(
          icon: const Icon(AppIcons.time),
          label: Text(material.formatTimeOfDay(TimeOfDay.fromDateTime(value))),
          onPressed: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(value),
            );
            if (time != null) {
              onChanged(
                DateTime(
                  value.year,
                  value.month,
                  value.day,
                  time.hour,
                  time.minute,
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
