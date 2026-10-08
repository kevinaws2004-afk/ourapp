import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/design/app_icons.dart';
import '../core/design/tokens/radius.dart';
import '../core/design/tokens/sizes.dart';
import '../core/design/tokens/spacing.dart';
import '../core/design/tokens/treatments.dart';
import '../core/design/context_ext.dart';
import '../core/design/window_size_class.dart';
import '../l10n/generated/app_localizations.dart';

/// Adaptive primary navigation (ADR-028, ADR-044, ui_guidelines.md §2):
/// Today, Plan, Challenges, Insights, Me. Bottom bar on compact windows, rail on medium/expanded. Each
/// tab keeps its own navigation stack. There is no floating Record button
/// (owner, 2026-10-04): everything is an item on a day, added from Today or
/// Plan (with "Now" for what you're doing right now) and logged by opening
/// it (ADR-035).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onSelect(int index) => navigationShell.goBranch(
    index,
    // Re-selecting the current tab returns to its root.
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final destinations = _destinations(l10n);
    if (!WindowSizeClass.of(context).usesNavigationRail) {
      final bar = NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onSelect,
        destinations: [
          for (final d in destinations)
            NavigationDestination(
              icon: Icon(d.icon.outline),
              selectedIcon: Icon(d.icon.filled),
              label: d.label,
            ),
        ],
      );
      final tokens = context.tokens;
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: switch (tokens.treatments.navStyle) {
          NavStyle.bar => DecoratedBox(
            decoration: BoxDecoration(
              color: tokens.colors.surfaceBase,
              border: Border(
                top: BorderSide(color: tokens.colors.borderSubtle),
              ),
            ),
            child: bar,
          ),
          // A rounded bar floating above the bottom edge (ADR-045).
          NavStyle.floating => SafeArea(
            minimum: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: tokens.colors.surfaceBase,
                borderRadius: AppRadius.xlAll,
                boxShadow: tokens.shadows.floating,
              ),
              child: ClipRRect(borderRadius: AppRadius.xlAll, child: bar),
            ),
          ),
        },
      );
    }
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onSelect,
            destinations: [
              for (final d in destinations)
                NavigationRailDestination(
                  icon: Icon(d.icon.outline),
                  selectedIcon: Icon(d.icon.filled),
                  label: Text(d.label),
                ),
            ],
          ),
          VerticalDivider(
            width: AppSizes.hairline,
            color: context.colors.borderSubtle,
          ),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }

  static List<_Destination> _destinations(AppLocalizations l10n) => [
    _Destination(AppIcons.today, l10n.navToday),
    _Destination(AppIcons.plan, l10n.navPlan),
    _Destination(AppIcons.challenges, l10n.navChallenges),
    _Destination(AppIcons.insights, l10n.navInsights),
    _Destination(AppIcons.me, l10n.navMe),
  ];
}

class _Destination {
  const _Destination(this.icon, this.label);

  final AppIconPair icon;
  final String label;
}
