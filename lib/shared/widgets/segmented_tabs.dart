import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/design/context_ext.dart';
import '../../core/design/tokens/motion.dart';
import '../../core/design/tokens/radius.dart';
import '../../core/design/tokens/spacing.dart';

/// A pill track with a sliding white thumb under the selected option: the
/// app's one segmented control (Plan's Week | Month, Progress's ranges).
class SegmentedTabs<T> extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelect,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) label;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final index = values.indexOf(selected);
    // Taller with large text (Settings → font size), so labels never clip.
    final height = math.max(
      44.0,
      MediaQuery.textScalerOf(context).scale(16) + 28,
    );
    return Container(
      height: height,
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: c.surfaceSunken,
        borderRadius: AppRadius.pillAll,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth / values.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: AppMotion.standard,
                curve: AppMotion.standardCurve,
                left: width * index,
                top: 0,
                bottom: 0,
                width: width,
                child: Container(
                  decoration: BoxDecoration(
                    color: c.surfaceBase,
                    borderRadius: AppRadius.pillAll,
                    boxShadow: context.tokens.shadows.card,
                  ),
                ),
              ),
              Row(
                children: [
                  for (final v in values)
                    Expanded(
                      child: Semantics(
                        selected: v == selected,
                        button: true,
                        child: InkWell(
                          borderRadius: AppRadius.pillAll,
                          onTap: () {
                            unawaited(HapticFeedback.selectionClick());
                            onSelect(v);
                          },
                          child: Center(
                            child: Text(
                              label(v),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: context.textStyles.labelMedium?.copyWith(
                                color: v == selected
                                    ? c.textPrimary
                                    : c.textSecondary,
                                fontWeight: v == selected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
