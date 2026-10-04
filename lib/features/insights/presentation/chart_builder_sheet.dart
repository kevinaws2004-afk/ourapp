import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/errors/error_copy.dart';
import '../../../shared/widgets/state_views.dart';
import '../../activity_logs/presentation/activity_log_providers.dart';
import '../../activity_logs/presentation/form/field_editor_shell.dart';
import '../../activity_types/domain/activity_ids.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../activity_types/domain/field_type.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../../measurements/domain/measurement.dart';
import '../../measurements/presentation/measurement_copy.dart';
import '../domain/insight.dart';
import 'insight_formatting.dart';
import 'insight_providers.dart';

/// What a chart measures, as offered in the builder.
enum _Kind { time, count, field, volume, body, plannedVsActual }

/// Builds or edits a chart (FR-AN-07): what to measure (any activity's time
/// or count, any number field at any depth with an optional text filter, set
/// volume, a body measurement, planned vs actual), how to aggregate, how to
/// group, and line or bar.
Future<void> showChartBuilder(
  BuildContext context, {
  InsightChartConfig? initial,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (_) => _ChartBuilderSheet(initial: initial),
);

/// Number/rating fields of [type] at any depth, with their group path.
List<(ActivityField, String)> _numberFields(ActivityType type) {
  String path(ActivityField f) {
    final names = <String>[f.name];
    var parent = f.parentId;
    while (parent != null) {
      final p = type.fieldById(parent);
      if (p == null) break;
      names.insert(0, p.name);
      parent = p.parentId;
    }
    return names.join(' › ');
  }

  return [
    for (final f in type.fields)
      if (!f.isRemoved &&
          (f.type == FieldType.number || f.type == FieldType.rating))
        (f, path(f)),
  ];
}

/// Groups with at least two number sub-fields (volume candidates).
List<ActivityField> _volumeGroups(ActivityType type) => [
  for (final g in type.fields)
    if (!g.isRemoved &&
        g.type == FieldType.repeatingGroup &&
        type
                .subFieldsOf(g.id)
                .where((f) => f.type == FieldType.number)
                .length >=
            2)
      g,
];

/// Text fields that can filter values living in an item of group [groupId]:
/// the same item, its parent item, or the record's top level.
List<ActivityField> _filterFields(ActivityType type, ActivityFieldId? groupId) {
  final grand = groupId == null ? null : type.fieldById(groupId)?.parentId;
  final scopes = {groupId, grand, null};
  return [
    for (final f in type.fields)
      if (!f.isRemoved &&
          f.type == FieldType.text &&
          scopes.contains(f.parentId))
        f,
  ];
}

class _ChartBuilderSheet extends ConsumerStatefulWidget {
  const _ChartBuilderSheet({this.initial});

  final InsightChartConfig? initial;

  @override
  ConsumerState<_ChartBuilderSheet> createState() => _ChartBuilderSheetState();
}

class _ChartBuilderSheetState extends ConsumerState<_ChartBuilderSheet> {
  late _Kind _kind;
  ActivityTypeId? _typeId;
  ActivityFieldId? _fieldId;
  ActivityFieldId? _groupId;
  ActivityFieldId? _amountId;
  ActivityFieldId? _countId;
  ActivityFieldId? _filterFieldId;
  final _filterValue = TextEditingController();
  MeasurementType _measurement = MeasurementType.weight;
  late Aggregation _aggregation;
  Bucket _bucket = Bucket.week;
  ChartKind _chartKind = ChartKind.line;
  late final _title = TextEditingController(text: widget.initial?.title ?? '');
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _kind = _Kind.time;
    _aggregation = Aggregation.sum;
    if (initial == null) return;
    _aggregation = initial.aggregation;
    _bucket = initial.bucket;
    _chartKind = initial.kind;
    TextFilter? filter;
    switch (initial.source) {
      case ActivityDurationSource(:final typeId):
        _kind = _Kind.time;
        _typeId = typeId;
      case ActivityCountSource(:final typeId):
        _kind = _Kind.count;
        _typeId = typeId;
      case FieldValueSource(:final typeId, :final fieldId, filter: final f):
        _kind = _Kind.field;
        _typeId = typeId;
        _fieldId = fieldId;
        filter = f;
      case VolumeSource(
        :final typeId,
        :final groupFieldId,
        :final amountFieldId,
        :final countFieldId,
        filter: final f,
      ):
        _kind = _Kind.volume;
        _typeId = typeId;
        _groupId = groupFieldId;
        _amountId = amountFieldId;
        _countId = countFieldId;
        filter = f;
      case MeasurementSource(:final type):
        _kind = _Kind.body;
        _measurement = type;
      case PlannedVsActualSource(:final typeId):
        _kind = _Kind.plannedVsActual;
        _typeId = typeId;
    }
    if (filter != null) {
      _filterFieldId = filter.fieldId;
      _filterValue.text = filter.value;
    }
  }

  @override
  void dispose() {
    _filterValue.dispose();
    _title.dispose();
    super.dispose();
  }

  TextFilter? get _filter =>
      _filterFieldId == null || _filterValue.text.trim().isEmpty
      ? null
      : TextFilter(fieldId: _filterFieldId!, value: _filterValue.text.trim());

  /// The source as configured, or null while incomplete.
  InsightSource? get _source => switch (_kind) {
    _Kind.time when _typeId != null => ActivityDurationSource(_typeId!),
    _Kind.count when _typeId != null => ActivityCountSource(_typeId!),
    _Kind.field when _typeId != null && _fieldId != null => FieldValueSource(
      _typeId!,
      _fieldId!,
      filter: _filter,
    ),
    _Kind.volume
        when _typeId != null &&
            _groupId != null &&
            _amountId != null &&
            _countId != null =>
      VolumeSource(
        _typeId!,
        groupFieldId: _groupId!,
        amountFieldId: _amountId!,
        countFieldId: _countId!,
        filter: _filter,
      ),
    _Kind.body => MeasurementSource(_measurement),
    _Kind.plannedVsActual => PlannedVsActualSource(_typeId),
    _ => null,
  };

  String _defaultTitle(AppLocalizations l10n, ActivityType? type) {
    final name = type?.name ?? '';
    String field(ActivityFieldId? id) =>
        id == null ? '' : type?.fieldById(id)?.name ?? '';
    final filter = _filter == null ? '' : ' (${_filter!.value})';
    return switch (_kind) {
      _Kind.time => l10n.insightTitleTime(name),
      _Kind.count => l10n.insightTitleCount(name),
      _Kind.field => '$name · ${field(_fieldId)}$filter',
      _Kind.volume => '${l10n.insightTitleVolume(name)}$filter',
      _Kind.body => measurementTypeLabel(l10n, _measurement),
      _Kind.plannedVsActual =>
        type == null
            ? l10n.insightKindPlannedVsActual
            : '${l10n.insightKindPlannedVsActual} · $name',
    };
  }

  void _setKind(_Kind kind) => setState(() {
    _kind = kind;
    _fieldId = null;
    _groupId = _amountId = _countId = null;
    _filterFieldId = null;
    _filterValue.clear();
    final source = _source;
    _aggregation = source == null
        ? (kind == _Kind.field ? Aggregation.max : Aggregation.sum)
        : InsightChartConfig.defaultAggregation(source);
    if (kind == _Kind.body) _aggregation = Aggregation.latest;
    if (kind == _Kind.plannedVsActual) _chartKind = ChartKind.bar;
  });

  void _setGroup(ActivityType type, ActivityFieldId? groupId) => setState(() {
    _groupId = groupId;
    if (groupId == null) return;
    final numbers = type
        .subFieldsOf(groupId)
        .where((f) => f.type == FieldType.number)
        .toList();
    final amount = numbers.firstWhere(
      (f) => f.dimension != null,
      orElse: () => numbers.first,
    );
    _amountId = amount.id;
    _countId = numbers.firstWhere((f) => f.id != amount.id).id;
  });

  Future<void> _save(ActivityType? type) async {
    final source = _source;
    if (source == null) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      await ref.read(saveInsightChartProvider)(
        InsightChartConfig(
          id: widget.initial?.id ?? const InsightChartId(''),
          title: _title.text.trim().isEmpty
              ? _defaultTitle(l10n, type)
              : _title.text,
          source: source,
          aggregation: _aggregation,
          bucket: _bucket,
          kind: _chartKind,
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) showMessageSnackBar(context, errorMessage(l10n, error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final types = ref.watch(activeActivityTypesProvider).value ?? const [];
    ActivityType? type;
    for (final t in types) {
      if (t.id == _typeId) type = t;
    }
    final needsActivity = _kind != _Kind.body;
    final fieldChoices = type == null
        ? const <(ActivityField, String)>[]
        : _numberFields(type);
    final groups = type == null ? const <ActivityField>[] : _volumeGroups(type);
    final filterScope = switch (_kind) {
      _Kind.field when _fieldId != null => type?.fieldById(_fieldId!)?.parentId,
      _Kind.volume => _groupId,
      _ => null,
    };
    final filterFields =
        type == null ||
            !(_kind == _Kind.field && _fieldId != null ||
                _kind == _Kind.volume && _groupId != null)
        ? const <ActivityField>[]
        : _filterFields(type, filterScope);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.9,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              0,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            children: [
              Text(
                widget.initial == null
                    ? l10n.insightAddChart
                    : l10n.insightEditChart,
                style: context.textStyles.titleLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              FieldEditorShell(
                label: l10n.insightWhatLabel,
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final (kind, label) in [
                      (_Kind.time, l10n.insightKindTime),
                      (_Kind.count, l10n.insightKindCount),
                      (_Kind.field, l10n.insightKindField),
                      (_Kind.volume, l10n.insightKindVolume),
                      (_Kind.body, l10n.insightKindBody),
                      (_Kind.plannedVsActual, l10n.insightKindPlannedVsActual),
                    ])
                      ChoiceChip(
                        label: Text(label),
                        selected: _kind == kind,
                        onSelected: (_) => _setKind(kind),
                      ),
                  ],
                ),
              ),
              if (needsActivity)
                FieldEditorShell(
                  label: l10n.planActivityLabel,
                  child: DropdownButton<ActivityTypeId?>(
                    isExpanded: true,
                    value: _typeId,
                    hint: Text(l10n.insightChooseActivity),
                    items: [
                      if (_kind == _Kind.plannedVsActual)
                        DropdownMenuItem(
                          child: Text(l10n.insightAllActivities),
                        ),
                      for (final t in types)
                        DropdownMenuItem(value: t.id, child: Text(t.name)),
                    ],
                    onChanged: (id) => setState(() {
                      _typeId = id;
                      _fieldId = _groupId = _amountId = _countId = null;
                      _filterFieldId = null;
                    }),
                  ),
                ),
              if (_kind == _Kind.body)
                FieldEditorShell(
                  label: l10n.insightKindBody,
                  child: DropdownButton<MeasurementType>(
                    isExpanded: true,
                    value: _measurement,
                    items: [
                      for (final m in MeasurementType.values)
                        DropdownMenuItem(
                          value: m,
                          child: Text(measurementTypeLabel(l10n, m)),
                        ),
                    ],
                    onChanged: (m) => setState(() => _measurement = m!),
                  ),
                ),
              if (_kind == _Kind.field && type != null)
                FieldEditorShell(
                  label: l10n.insightFieldLabel,
                  child: fieldChoices.isEmpty
                      ? Text(l10n.insightNoNumberFields)
                      : DropdownButton<ActivityFieldId>(
                          isExpanded: true,
                          value: _fieldId,
                          hint: Text(l10n.insightChooseField),
                          items: [
                            for (final (f, path) in fieldChoices)
                              DropdownMenuItem(value: f.id, child: Text(path)),
                          ],
                          onChanged: (id) => setState(() {
                            _fieldId = id;
                            _filterFieldId = null;
                          }),
                        ),
                ),
              if (_kind == _Kind.volume && type != null)
                FieldEditorShell(
                  label: l10n.insightGroupLabel,
                  child: groups.isEmpty
                      ? Text(l10n.insightNoVolumeGroups)
                      : DropdownButton<ActivityFieldId>(
                          isExpanded: true,
                          value: _groupId,
                          hint: Text(l10n.insightChooseField),
                          items: [
                            for (final g in groups)
                              DropdownMenuItem(
                                value: g.id,
                                child: Text(g.name),
                              ),
                          ],
                          onChanged: (id) => _setGroup(type!, id),
                        ),
                ),
              if (_kind == _Kind.volume && type != null && _groupId != null)
                Text(
                  l10n.insightVolumeFormula(
                    type.fieldById(_amountId!)?.name ?? '',
                    type.fieldById(_countId!)?.name ?? '',
                  ),
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              if (filterFields.isNotEmpty) ...[
                FieldEditorShell(
                  label: l10n.insightFilterLabel,
                  child: DropdownButton<ActivityFieldId?>(
                    isExpanded: true,
                    value: _filterFieldId,
                    items: [
                      DropdownMenuItem(child: Text(l10n.insightNoFilter)),
                      for (final f in filterFields)
                        DropdownMenuItem(value: f.id, child: Text(f.name)),
                    ],
                    onChanged: (id) => setState(() {
                      _filterFieldId = id;
                      _filterValue.clear();
                    }),
                  ),
                ),
                if (_filterFieldId != null)
                  _FilterValue(
                    fieldId: _filterFieldId!,
                    controller: _filterValue,
                    onChanged: () => setState(() {}),
                  ),
              ],
              if (_kind != _Kind.plannedVsActual)
                FieldEditorShell(
                  label: l10n.insightHowLabel,
                  child: DropdownButton<Aggregation>(
                    isExpanded: true,
                    value: _aggregation,
                    items: [
                      for (final a in Aggregation.values)
                        DropdownMenuItem(
                          value: a,
                          child: Text(aggregationLabel(l10n, a)),
                        ),
                    ],
                    onChanged: (a) => setState(() => _aggregation = a!),
                  ),
                ),
              FieldEditorShell(
                label: l10n.insightGroupByLabel,
                child: SegmentedButton<Bucket>(
                  segments: [
                    for (final b in Bucket.values)
                      ButtonSegment(value: b, label: Text(bucketName(l10n, b))),
                  ],
                  selected: {_bucket},
                  onSelectionChanged: (s) => setState(() => _bucket = s.first),
                ),
              ),
              if (_kind != _Kind.plannedVsActual)
                FieldEditorShell(
                  label: l10n.insightChartTypeLabel,
                  child: SegmentedButton<ChartKind>(
                    segments: [
                      ButtonSegment(
                        value: ChartKind.line,
                        label: Text(l10n.insightChartLine),
                      ),
                      ButtonSegment(
                        value: ChartKind.bar,
                        label: Text(l10n.insightChartBar),
                      ),
                    ],
                    selected: {_chartKind},
                    onSelectionChanged: (s) =>
                        setState(() => _chartKind = s.first),
                  ),
                ),
              TextField(
                controller: _title,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.insightTitleLabel,
                  hintText: _defaultTitle(l10n, type),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: _saving || _source == null
                    ? null
                    : () => _save(type),
                child: Text(l10n.actionSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The filter's text value, with values recorded before as chips.
class _FilterValue extends ConsumerWidget {
  const _FilterValue({
    required this.fieldId,
    required this.controller,
    required this.onChanged,
  });

  final ActivityFieldId fieldId;
  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final suggestions =
        ref.watch(textSuggestionsProvider(fieldId)).value ?? const [];
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(hintText: l10n.insightFilterValueHint),
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (final s in suggestions.take(8))
                ActionChip(
                  label: Text(s),
                  onPressed: () {
                    controller.text = s;
                    onChanged();
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
