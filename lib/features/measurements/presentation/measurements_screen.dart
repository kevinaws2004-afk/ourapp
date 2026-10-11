import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../shared/widgets/settings_group.dart';
import '../../../shared/widgets/state_views.dart';
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
          padding: EdgeInsets.fromLTRB(
            margin,
            0,
            margin,
            AppSpacing.xxxl,
          ),
          children: [
            ScreenHeader(
              showMark: false,
              title: l10n.measurementsTitle,
              subtitle: l10n.measurementsIntro,
            ),
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
                      null => l10n.measurementNone,
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
