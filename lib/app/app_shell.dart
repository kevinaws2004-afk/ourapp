import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/design/app_icons.dart';
import '../core/design/context_ext.dart';
import '../core/design/window_size_class.dart';
import '../l10n/generated/app_localizations.dart';

/// Adaptive primary navigation (ADR-028, ui_guidelines.md §2): Today, Plan,
/// Insights, Me. Bottom bar on compact windows, rail on medium/expanded. The
/// global **Record** action (Quick Record) is available on every tab. Each
/// tab keeps its own navigation stack.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
    required this.onQuickRecord,
  });

  final StatefulNavigationShell navigationShell;
  final VoidCallback onQuickRecord;

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
      return Scaffold(
        body: navigationShell,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: onQuickRecord,
          icon: const Icon(AppIcons.record),
          label: Text(l10n.actionRecord),
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: context.colors.borderSubtle)),
          ),
          child: NavigationBar(
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
          ),
        ),
      );
    }
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onSelect,
            leading: FloatingActionButton(
              tooltip: l10n.actionRecord,
              onPressed: onQuickRecord,
              child: const Icon(AppIcons.record),
            ),
            destinations: [
              for (final d in destinations)
                NavigationRailDestination(
                  icon: Icon(d.icon.outline),
                  selectedIcon: Icon(d.icon.filled),
                  label: Text(d.label),
                ),
            ],
          ),
          VerticalDivider(width: 1, color: context.colors.borderSubtle),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }

  static List<_Destination> _destinations(AppLocalizations l10n) => [
    _Destination(AppIcons.today, l10n.navToday),
    _Destination(AppIcons.plan, l10n.navPlan),
    _Destination(AppIcons.insights, l10n.navInsights),
    _Destination(AppIcons.me, l10n.navMe),
  ];
}

class _Destination {
  const _Destination(this.icon, this.label);

  final AppIconPair icon;
  final String label;
}
