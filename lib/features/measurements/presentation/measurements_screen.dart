import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../core/time/clock_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/errors/error_copy.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../shared/widgets/settings_group.dart';
import '../../../shared/widgets/state_views.dart';
import '../data/health_connect_import.dart';
import '../domain/measurement.dart';
import 'measurement_copy.dart';
import 'measurement_formatting.dart';
import 'measurement_providers.dart';

/// Me → Body measurements (§23; FR-BM-01/02): each type with its latest
/// value. Tapping one opens its history and chart.
class MeasurementsScreen extends ConsumerWidget {
  const MeasurementsScreen({super.key, required this.onOpenType});

  final ValueChanged<MeasurementType> onOpenType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final margin = WindowSizeClass.of(context).screenMargin;
    return Scaffold(
      appBar: AppBar(),
      body: AsyncValueView<Map<MeasurementType, Measurement>>(
        value: ref.watch(latestMeasurementsProvider),
        onRetry: () => ref.invalidate(latestMeasurementsProvider),
        data: (latest) => ListView(
          padding: EdgeInsets.fromLTRB(margin, 0, margin, AppSpacing.xxxl),
          children: [
            ScreenHeader(
              showMark: false,
              title: l10n.measurementsTitle,
              subtitle: l10n.measurementsIntro,
            ),
            if (HealthConnectImport.isSupported) ...[
              const _HealthConnectCard(),
              const SizedBox(height: AppSpacing.lg),
            ],
            SettingsGroup(
              children: [
                for (final type in MeasurementType.values)
                  SettingsTile(
                    icon: AppIcons.measurements,
                    iconColor: latest[type] == null
                        ? context.colors.textTertiary
                        : context.colors.accent,
                    iconBackground: latest[type] == null
                        ? context.colors.surfaceSunken
                        : context.colors.accentSoft,
                    title: measurementTypeLabel(l10n, type),
                    value: switch (latest[type]) {
                      final m? => formatMeasurement(m),
                      null => l10n.measurementNoneShort,
                    },
                    onTap: () => onOpenType(type),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Import weight, height and body fat from Health Connect, on request.
class _HealthConnectCard extends ConsumerStatefulWidget {
  const _HealthConnectCard();

  @override
  ConsumerState<_HealthConnectCard> createState() => _HealthConnectCardState();
}

class _HealthConnectCardState extends ConsumerState<_HealthConnectCard> {
  bool _busy = false;

  Future<void> _import() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final importer = HealthConnectImport();
      final now = ref.read(clockProvider).nowUtc();
      final (outcome, readings) = await importer.read(nowUtc: now);
      if (!mounted) return;
      switch (outcome) {
        case HealthImportOutcome.unavailable:
          showMessageSnackBar(context, l10n.healthUnavailable);
          await importer.install();
          return;
        case HealthImportOutcome.denied:
          showMessageSnackBar(context, l10n.healthDenied);
          return;
        case HealthImportOutcome.done:
          break;
      }
      final repo = ref.read(measurementRepositoryProvider);
      final existing = {
        for (final type in MeasurementType.values)
          type: await repo.watchForType(type).first,
      };
      final fresh = newReadings(readings, existing);
      final record = ref.read(recordMeasurementProvider);
      for (final r in fresh) {
        await record(
          MeasurementDraft(
            type: r.type,
            value: r.value,
            unitCode: r.unitCode,
            recordedAt: r.at,
            notes: l10n.healthImportedNote,
          ),
        );
      }
      if (mounted) {
        showMessageSnackBar(context, l10n.healthImported(fresh.length));
      }
    } catch (error) {
      if (mounted) showMessageSnackBar(context, errorMessage(l10n, error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return AppCard(
      child: Row(
        children: [
          Icon(AppIcons.health, color: c.danger),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.healthTitle, style: context.textStyles.titleSmall),
                Text(
                  l10n.healthSubtitle,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _busy
              ? const SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : TextButton(
                  onPressed: () => unawaited(_import()),
                  child: Text(l10n.healthImport),
                ),
        ],
      ),
    );
  }
}
