import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

/// Asks for one line of text (a name, a title). Returns what was typed, or
/// null when cancelled. The dialog owns its text controller, so nothing is
/// disposed while it's still animating closed.
Future<String?> showTextInputDialog(
  BuildContext context, {
  required String title,
  String initial = '',
  String? hint,
  String? helper,
  int? maxLength,
  TextCapitalization capitalization = TextCapitalization.sentences,
}) => showDialog<String>(
  context: context,
  builder: (_) => _TextInputDialog(
    title: title,
    initial: initial,
    hint: hint,
    helper: helper,
    maxLength: maxLength,
    capitalization: capitalization,
  ),
);

class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({
    required this.title,
    required this.initial,
    required this.hint,
    required this.helper,
    required this.maxLength,
    required this.capitalization,
  });

  final String title;
  final String initial;
  final String? hint;
  final String? helper;
  final int? maxLength;
  final TextCapitalization capitalization;

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: widget.maxLength,
        textCapitalization: widget.capitalization,
        decoration: InputDecoration(
          hintText: widget.hint,
          helperText: widget.helper,
        ),
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }
}
