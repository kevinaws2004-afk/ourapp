import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/app_icons.dart';
import '../../../../core/design/context_ext.dart';
import '../../../../core/design/window_size_class.dart';
import '../../../../core/design/tokens/radius.dart';
import '../../../../core/design/tokens/spacing.dart';
import '../../../../core/design/tokens/typography.dart';
import '../../../../core/units/unit_registry.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../activity_types/domain/activity_type.dart';
import '../../../activity_types/domain/field_config.dart';
import '../../domain/field_value.dart';
import '../activity_log_providers.dart';
import '../value_formatting.dart';

/// Text field editor; empty text means "no value". With
/// `suggestFromHistory`, previously recorded values are offered as the user
/// types (matching anywhere, case-insensitive).
class TextValueEditor extends ConsumerStatefulWidget {
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
  ConsumerState<TextValueEditor> createState() => _TextValueEditorState();
}

class _TextValueEditorState extends ConsumerState<TextValueEditor> {
  static const _maxSuggestions = 6;

  late final _controller = TextEditingController(
    text: widget.value?.text ?? '',
  );
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _emit(String text) =>
      widget.onChanged(text.trim().isEmpty ? null : TextValue(text));

  @override
  Widget build(BuildContext context) {
    final config = widget.field.config as TextFieldConfig;
    final input = TextField(
      controller: _controller,
      focusNode: _focusNode,
      minLines: config.multiline ? 3 : 1,
      maxLines: config.multiline ? 8 : 1,
      textCapitalization: TextCapitalization.sentences,
      onChanged: _emit,
    );
    if (!config.suggestFromHistory || config.multiline) return input;

    final suggestions =
        ref.watch(textSuggestionsProvider(widget.field.id)).value ?? const [];
    return RawAutocomplete<String>(
      textEditingController: _controller,
      focusNode: _focusNode,
      optionsBuilder: (editing) {
        final query = editing.text.trim().toLowerCase();
        if (query.isEmpty) return const [];
        return suggestions
            .where((s) {
              final lower = s.toLowerCase();
              return lower != query && lower.contains(query);
            })
            .take(_maxSuggestions);
      },
      onSelected: _emit,
      fieldViewBuilder: (_, _, _, _) => input,
      optionsViewBuilder: (context, onSelected, options) =>
          _SuggestionList(options: options.toList(), onSelected: onSelected),
    );
  }
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList({required this.options, required this.onSelected});

  final List<String> options;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topLeft,
    child: Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surfaceRaised,
          borderRadius: AppRadius.mdAll,
          boxShadow: context.tokens.shadows.overlay,
        ),
        child: ConstrainedBox(
          // Room for about four suggestions, at most a phone's width.
          constraints: const BoxConstraints(
            maxHeight: AppSpacing.giant * 4,
            maxWidth: AppContentWidth.reading,
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: [
              for (final option in options)
                Material(
                  type: MaterialType.transparency,
                  child: ListTile(
                    title: Text(option),
                    onTap: () => onSelected(option),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Number editor with an optional unit picker for dimensioned fields
/// (ADR-020). Unparsable input shows an error and stores no value.
///
/// With [stepper] it's the big entry of a list row being filled in
/// (ADR-045): − and + around the value, one step at a time (1, or 0.5 for a
/// number with decimals), never below the field's minimum (or 0 when it has
/// none and the value isn't negative). The value can still be typed.
class NumberValueEditor extends StatefulWidget {
  const NumberValueEditor({
    super.key,
    required this.field,
    required this.value,
    required this.onChanged,
    this.label,
    this.errorText,
    this.stepper = false,
  });

  final ActivityField field;
  final NumberValue? value;
  final ValueChanged<FieldValue?> onChanged;

  /// Inline label, for compact rows without a [FieldEditorShell].
  final String? label;

  /// A validation message shown under the input.
  final String? errorText;

  final bool stepper;

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

  double get _step => _config.decimals == 0 ? 1 : 0.5;

  /// Moves the value one step ([direction] -1 or 1) and shows it.
  void _nudge(int direction) {
    final text = _controller.text.trim().replaceAll(',', '.');
    final current = double.tryParse(text) ?? 0;
    var next = current + _step * direction;
    final min = _config.min ?? (current >= 0 ? 0 : null);
    if (min != null && next < min) next = min.toDouble();
    if (_config.max case final max? when next > max) next = max.toDouble();
    _controller.text = formatNumber(next, _config.decimals);
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    final dimension = widget.field.dimension;
    final l10n = AppLocalizations.of(context);
    final unitPicker = dimension == null
        ? null
        : DropdownButton<String>(
            value: _unitCode,
            isDense: true,
            isExpanded: widget.stepper,
            underline: const SizedBox.shrink(),
            items: [
              for (final unit in UnitRegistry.forDimension(dimension))
                DropdownMenuItem(value: unit.code, child: Text(unit.symbol)),
            ],
            onChanged: (code) {
              setState(() => _unitCode = code);
              _emit();
            },
          );
    if (widget.stepper) {
      return _stepperLayout(context, l10n, unitPicker);
    }
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
              labelText: widget.label,
              errorText: _invalid
                  ? l10n.validationNotANumber
                  : widget.errorText,
            ),
            onChanged: (_) => _emit(),
          ),
        ),
        if (unitPicker != null) ...[
          const SizedBox(width: AppSpacing.md),
          unitPicker,
        ],
      ],
    );
  }

  Widget _stepperLayout(
    BuildContext context,
    AppLocalizations l10n,
    Widget? unitPicker,
  ) {
    final c = context.colors;
    final name = widget.label ?? widget.field.name;
    Widget nudge(int direction) => IconButton.filledTonal(
      style: IconButton.styleFrom(
        backgroundColor: c.brandPrimarySoft,
        foregroundColor: c.onBrandPrimarySoft,
        visualDensity: VisualDensity.compact,
      ),
      tooltip: direction < 0
          ? l10n.stepperDecrease(widget.field.name)
          : l10n.stepperIncrease(widget.field.name),
      icon: Icon(direction < 0 ? AppIcons.minus : AppIcons.add),
      onPressed: () => _nudge(direction),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surfaceBase,
        borderRadius: AppRadius.lgAll,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              textAlign: TextAlign.center,
              style: AppTypography.numericMedium.copyWith(
                fontSize: 24,
                color: c.textPrimary,
              ),
              keyboardType: TextInputType.numberWithOptions(
                decimal: _config.decimals > 0,
                signed: (_config.min ?? 0) < 0,
              ),
              decoration: InputDecoration(
                labelText: name,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                floatingLabelAlignment: FloatingLabelAlignment.center,
                filled: false,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorText: _invalid
                    ? l10n.validationNotANumber
                    : widget.errorText,
              ),
              onChanged: (_) => _emit(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                nudge(-1),
                if (unitPicker != null) Flexible(child: unitPicker),
                nudge(1),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
