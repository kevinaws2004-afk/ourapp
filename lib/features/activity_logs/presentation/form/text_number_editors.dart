import 'package:flutter/material.dart';

import '../../../../core/units/unit_registry.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../activity_types/domain/activity_type.dart';
import '../../../activity_types/domain/field_config.dart';
import '../../domain/field_value.dart';
import '../value_formatting.dart';

/// Text field editor; empty text means "no value".
class TextValueEditor extends StatefulWidget {
  const TextValueEditor({
    super.key,
    required this.field,
    required this.value,
    required this.onChanged,
  });

  final ActivityField field;
  final TextValue? value;
  final ValueChanged<FieldValue?> onChanged;

  @override
  State<TextValueEditor> createState() => _TextValueEditorState();
}

class _TextValueEditorState extends State<TextValueEditor> {
  late final _controller = TextEditingController(
    text: widget.value?.text ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final multiline = (widget.field.config as TextFieldConfig).multiline;
    return TextField(
      controller: _controller,
      minLines: multiline ? 3 : 1,
      maxLines: multiline ? 8 : 1,
      textCapitalization: TextCapitalization.sentences,
      onChanged: (text) =>
          widget.onChanged(text.trim().isEmpty ? null : TextValue(text)),
    );
  }
}

/// Number editor with an optional unit picker for dimensioned fields
/// (ADR-020). Unparsable input shows an error and stores no value.
class NumberValueEditor extends StatefulWidget {
  const NumberValueEditor({
    super.key,
    required this.field,
    required this.value,
    required this.onChanged,
  });

  final ActivityField field;
  final NumberValue? value;
  final ValueChanged<FieldValue?> onChanged;

  @override
  State<NumberValueEditor> createState() => _NumberValueEditorState();
}

class _NumberValueEditorState extends State<NumberValueEditor> {
  late final NumberFieldConfig _config =
      widget.field.config as NumberFieldConfig;
  late final _controller = TextEditingController(
    text: widget.value == null
        ? ''
        : formatNumber(widget.value!.value, _config.decimals),
  );
  late String? _unitCode = widget.value?.unitCode ?? _config.defaultUnitCode;
  bool _invalid = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _emit() {
    final text = _controller.text.trim().replaceAll(',', '.');
    if (text.isEmpty) {
      setState(() => _invalid = false);
      widget.onChanged(null);
      return;
    }
    final parsed = double.tryParse(text);
    setState(() => _invalid = parsed == null);
    widget.onChanged(
      parsed == null ? null : NumberValue(parsed, unitCode: _unitCode),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dimension = widget.field.dimension;
    final l10n = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.numberWithOptions(
              decimal: _config.decimals > 0,
              signed: (_config.min ?? 0) < 0,
            ),
            decoration: InputDecoration(
              errorText: _invalid ? l10n.validationNotANumber : null,
            ),
            onChanged: (_) => _emit(),
          ),
        ),
        if (dimension != null) ...[
          const SizedBox(width: 12),
          DropdownButton<String>(
            value: _unitCode,
            items: [
              for (final unit in UnitRegistry.forDimension(dimension))
                DropdownMenuItem(value: unit.code, child: Text(unit.symbol)),
            ],
            onChanged: (code) {
              setState(() => _unitCode = code);
              _emit();
            },
          ),
        ],
      ],
    );
  }
}
