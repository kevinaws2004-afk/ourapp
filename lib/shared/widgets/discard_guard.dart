import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

/// "Discard your changes?" Returns true to discard.
Future<bool> confirmDiscard(BuildContext context) async {
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

/// Asks before a form with [dirty] input is closed by back or a tap outside
/// it (A15). Saving with an explicit pop (e.g. "Done") is not affected.
class DiscardGuard extends StatelessWidget {
  const DiscardGuard({super.key, required this.dirty, required this.child});

  final bool dirty;
  final Widget child;

  @override
  Widget build(BuildContext context) => PopScope<Object?>(
    canPop: !dirty,
    onPopInvokedWithResult: (didPop, _) async {
      if (didPop) return;
      if (await confirmDiscard(context) && context.mounted) {
        Navigator.of(context).pop();
      }
    },
    child: child,
  );
}
