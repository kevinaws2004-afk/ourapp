import 'package:flutter/material.dart';

import '../../../../core/design/app_icons.dart';
import '../../../../core/design/tokens/sizes.dart';
import '../../../../core/design/tokens/spacing.dart';
import '../../../../core/time/local_date.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/field_value.dart';
import '../value_formatting.dart';

class DateValueEditor extends StatelessWidget {
  const DateValueEditor({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final DateValue? value;
  final ValueChanged<FieldValue?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = value?.date;
    return OutlinedButton.icon(
      icon: const Icon(AppIcons.date),
      label: Text(current == null ? l10n.notSet : formatDate(context, current)),
      onPressed: () async {
        final initial = current == null
            ? DateTime.now()
            : DateTime(current.year, current.month, current.day);
        final picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(1900),
          lastDate: DateTime(2200),
        );
        if (picked != null) {
          onChanged(
            DateValue(LocalDate(picked.year, picked.month, picked.day)),
          );
        }
      },
    );
  }
}

class TimeValueEditor extends StatelessWidget {
  const TimeValueEditor({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final TimeValue? value;
  final ValueChanged<FieldValue?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = value?.time;
    return OutlinedButton.icon(
      icon: const Icon(AppIcons.time),
      label: Text(current == null ? l10n.notSet : formatTime(context, current)),
      onPressed: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: current == null
              ? TimeOfDay.now()
              : TimeOfDay(hour: current.hour, minute: current.minute),
        );
        if (picked != null) {
          onChanged(TimeValue(LocalTime.hm(picked.hour, picked.minute)));
        }
      },
    );
  }
}

/// Hours + minutes input, used by Duration fields and the log's built-in
/// duration. Emits milliseconds, or null when both inputs are empty.
class DurationInput extends StatefulWidget {
  const DurationInput({
    super.key,
    required this.milliseconds,
    required this.onChanged,
  });

  final int? milliseconds;
  final ValueChanged<int?> onChanged;

  @override
  State<DurationInput> createState() => _DurationInputState();
}

class _DurationInputState extends State<DurationInput> {
  late final _hours = TextEditingController(text: _initial(60));
  late final _minutes = TextEditingController(text: _initial(1));

  String _initial(int unitMinutes) {
    final ms = widget.milliseconds;
    if (ms == null) return '';
    final totalMinutes = ms ~/ Duration.millisecondsPerMinute;
    final value = unitMinutes == 60 ? totalMinutes ~/ 60 : totalMinutes % 60;
    return value == 0 ? '' : '$value';
  }

  @override
  void dispose() {
    _hours.dispose();
    _minutes.dispose();
    super.dispose();
  }

  void _emit() {
    final h = int.tryParse(_hours.text.trim());
    final m = int.tryParse(_minutes.text.trim());
    if (h == null && m == null) {
      widget.onChanged(null);
      return;
    }
    widget.onChanged(
      ((h ?? 0) * 60 + (m ?? 0)) * Duration.millisecondsPerMinute,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget box(TextEditingController controller, String suffix) => SizedBox(
      width: AppSizes.durationBox,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(suffixText: suffix),
        onChanged: (_) => _emit(),
      ),
    );
    return Row(
      children: [
        box(_hours, l10n.hoursShort),
        const SizedBox(width: AppSpacing.md),
        box(_minutes, l10n.minutesShort),
      ],
    );
  }
}
