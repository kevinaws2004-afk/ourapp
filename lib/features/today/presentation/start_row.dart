import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/activity_badge.dart';
import '../../../shared/widgets/section_header.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../plans/presentation/plan_providers.dart';

/// "Start something": your most used activities as a scrolling row; one tap
/// starts it now (its timer when it has one). Fast logging without opening
/// a sheet (spec §37).
class StartRow extends ConsumerWidget {
  const StartRow({super.key, required this.onStart, required this.margin});

  final ValueChanged<ActivityType> onStart;

  /// The screen's side margin, so the row can scroll edge to edge.
  final double margin;

  static const _max = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final types = ref.watch(recentActivityTypesProvider).take(_max).toList();
    if (types.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.todayStartSomething),
        SizedBox(
          height: 42,
          child: LayoutBuilder(
            builder: (context, constraints) => OverflowBox(
              maxWidth: constraints.maxWidth + 2 * margin,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: margin),
                itemCount: types.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, i) =>
                    _StartChip(type: types[i], onTap: () => onStart(types[i])),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StartChip extends StatelessWidget {
  const _StartChip({required this.type, required this.onTap});

  final ActivityType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Semantics(
      button: true,
      label: l10n.quickStartActivity(type.name),
      excludeSemantics: true,
      child: Material(
        color: c.surfaceBase,
        shape: StadiumBorder(side: BorderSide(color: c.borderSubtle)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xs + AppSpacing.xxs,
              AppSpacing.xs + AppSpacing.xxs,
              AppSpacing.lg,
              AppSpacing.xs + AppSpacing.xxs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ActivityBadge(
                  iconId: type.iconId,
                  colorKey: type.colorKey,
                  size: 28,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  type.name,
                  style: context.textStyles.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  type.supportsTimer ? AppIcons.start : AppIcons.add,
                  size: 14,
                  color: c.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
