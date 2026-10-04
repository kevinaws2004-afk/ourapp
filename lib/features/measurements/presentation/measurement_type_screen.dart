import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/time/clock_provider.dart';
import '../../../core/units/unit_registry.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/errors/error_copy.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/charts/app_chart.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/state_views.dart';
import '../domain/measurement.dart';
import 'measurement_copy.dart';
import 'measurement_formatting.dart';
import 'measurement_providers.dart';

/// One measurement type: its time series (FR-BM-03) and history, newest
/// first. Add, edit and delete (with Undo) happen here.
class MeasurementTypeScreen extends ConsumerWidget {
  const MeasurementTypeScreen({super.key, required this.type});

  final MeasurementType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final margin = WindowSizeClass.of(context).screenMargin;
    final unit = UnitRegistry.byCode(type.defaultUnitCode)!;
    return Scaffold(
      appBar: AppBar(title: Text(measurementTypeLabel(l10n, type))),
      body: AsyncValueView<List<Measurement>>(
        value: ref.watch(measurementsForTypeProvider(type)),
        onRetry: () => ref.invalidate(measurementsForTypeProvider(type)),
        data: (history) {
          final material = MaterialLocalizations.of(context);
          final ordered = history.reversed.toList(); // oldest first
          return ListView(
            padding: EdgeInsets.fromLTRB(
              margin,
              AppSpacing.sm,
              margin,
              AppSpacing.huge,
            ),
            children: [
              AppButton(
                label: l10n.measurementAdd,
                icon: AppIcons.add,
                onPressed: () => showMeasurementSheet(context, type: type),
              ),
              if (ordered.length >= 2) ...[
                const SizedBox(height: AppSpacing.xl),
                AppChart(
                  kind: AppChartKind.line,
                  labels: [
                    for (final m in ordered)
                      material.formatShortMonthDay(m.recordedAt.toLocal()),
                  ],
                  formatValue: (v) => v.toStringAsFixed(unit.displayDecimals),
                  series: [
                    ChartSeries(
                      values: [
                        for (final m in ordered)
                          unit.fromCanonical(m.normalizedValue),
                      ],
                      color: context.colors.brandPrimary,
                    ),
                  ],
                ),
              ],
              SectionHeader(title: l10n.measurementHistory),
              if (history.isEmpty)
                Text(
                  l10n.measurementNone,
                  style: context.textStyles.bodyLarge?.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              for (final m in history)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(formatMeasurement(m)),
                  subtitle: Text(
                    [
                      material.formatMediumDate(m.recordedAt.toLocal()),
                      ?m.notes,
                    ].join(' · '),
                  ),
                  trailing: const Icon(AppIcons.chevron),
                  onTap: () =>
                      showMeasurementSheet(context, type: type, existing: m),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Adds or edits a measurement: value, unit, date and notes.
Future<void> showMeasurementSheet(
  BuildContext context, {
  required MeasurementType type,
  Measurement? existing,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (_) => _MeasurementSheet(type: type, existing: existing),
);

class _MeasurementSheet extends ConsumerStatefulWidget {
  const _MeasurementSheet({required this.type, this.existing});

  final MeasurementType type;
  final Measurement? existing;

  @override
  ConsumerState<_MeasurementSheet> createState() => _MeasurementSheetState();
}

class _MeasurementSheetState extends ConsumerState<_MeasurementSheet> {
  late final _value = TextEditingController(
    text: widget.existing == null ? '' : '${widget.existing!.value}',
  );
  late final _notes = TextEditingController(text: widget.existing?.notes ?? '');
  late String _unit = widget.existing?.unitCode ?? widget.type.defaultUnitCode;
  late DateTime _when =
      widget.existing?.recordedAt.toLocal() ??
      ref.read(clockProvider).nowUtc().toLocal();
  List<ValidationIssue> _issues = const [];

  @override
  void dispose() {
    _value.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final draft = MeasurementDraft(
      type: widget.type,
      value:
          double.tryParse(_value.text.trim().replaceAll(',', '.')) ??
          double.nan,
      unitCode: _unit,
      recordedAt: _when.toUtc(),
      notes: _notes.text,
    );
    try {
      if (widget.existing case final existing?) {
        await ref.read(updateMeasurementProvider)(existing, draft);
      } else {
        await ref.read(recordMeasurementProvider)(draft);
      }
      if (mounted) Navigator.of(context).pop();
    } on ValidationException catch (e) {
      setState(() => _issues = e.issues);
    } catch (error) {
      if (mounted) showMessageSnackBar(context, errorMessage(l10n, error));
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final id = widget.existing!.id;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final restore = ref.read(restoreMeasurementProvider);
    try {
      await ref.read(deleteMeasurementProvider)(id);
    } catch (error) {
      if (mounted) showMessageSnackBar(context, errorMessage(l10n, error));
      return;
    }
    navigator.pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.measurementDeleted),
          action: SnackBarAction(
            label: l10n.actionUndo,
            onPressed: () => unawaited(restore(id)),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                measurementTypeLabel(l10n, widget.type),
                style: context.textStyles.titleLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _value,
                      autofocus: widget.existing == null,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.measurementValue,
                        errorText: firstIssueMessage(l10n, _issues, 'value'),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  DropdownButton<String>(
                    value: _unit,
                    items: [
                      for (final u in UnitRegistry.forDimension(
                        widget.type.dimension,
                      ))
                        DropdownMenuItem(value: u.code, child: Text(u.symbol)),
                    ],
                    onChanged: (code) => setState(() => _unit = code!),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                icon: const Icon(AppIcons.date),
                label: Text(material.formatMediumDate(_when)),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _when,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2200),
                  );
                  if (picked != null) {
                    setState(
                      () => _when = DateTime(
                        picked.year,
                        picked.month,
                        picked.day,
                        _when.hour,
                        _when.minute,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _notes,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: l10n.notesLabel),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(onPressed: _save, child: Text(l10n.actionSave)),
              if (widget.existing != null)
                TextButton(
                  onPressed: _delete,
                  child: Text(
                    l10n.measurementDelete,
                    style: TextStyle(color: context.colors.danger),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
