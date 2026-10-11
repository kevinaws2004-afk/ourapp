import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../core/design/app_icons.dart';
import '../core/design/context_ext.dart';
import '../core/design/tokens/motion.dart';
import '../core/design/tokens/radius.dart';
import '../core/design/tokens/sizes.dart';
import '../core/design/tokens/spacing.dart';
import '../core/design/window_size_class.dart';
import '../l10n/generated/app_localizations.dart';

/// The tab shell: Today, Plan, **+**, Progress, Me. On phones a bottom bar
/// with a raised center button that opens Quick start from any tab; on
/// larger windows a rail with the same button on top. Goals (challenges)
/// live inside Progress, so its branch lights the Progress tab. Each tab
/// keeps its own navigation stack.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
    required this.onQuickStart,
  });

  final StatefulNavigationShell navigationShell;

  /// Opens the Quick start sheet.
  final ValueChanged<BuildContext> onQuickStart;

  /// Branch order in the router.
  static const today = 0;
  static const plan = 1;
  static const goals = 2;
  static const progress = 3;
  static const me = 4;

  void _onSelect(int branch) {
    unawaited(HapticFeedback.selectionClick());
    navigationShell.goBranch(
      branch,
      // Re-selecting the current tab returns to its root.
      initialLocation: branch == navigationShell.currentIndex,
    );
  }

  /// The tab that shows as selected for the current branch.
  int get _selectedBranch => navigationShell.currentIndex == goals
      ? progress
      : navigationShell.currentIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tabs = [
      _Tab(today, AppIcons.today, l10n.navToday),
      _Tab(plan, AppIcons.plan, l10n.navPlan),
      _Tab(progress, AppIcons.insights, l10n.navInsights),
      _Tab(me, AppIcons.me, l10n.navMe),
    ];
    if (!WindowSizeClass.of(context).usesNavigationRail) {
      return Scaffold(
        body: navigationShell,
        extendBody: false,
        bottomNavigationBar: _BottomBar(
          tabs: tabs,
          selected: _selectedBranch,
          onSelect: _onSelect,
          onQuickStart: () => onQuickStart(context),
          quickStartLabel: l10n.quickTitle,
        ),
      );
    }
    final railIndex = tabs.indexWhere((t) => t.branch == _selectedBranch);
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: railIndex < 0 ? 0 : railIndex,
            onDestinationSelected: (i) => _onSelect(tabs[i].branch),
            leading: Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.md,
                bottom: AppSpacing.xl,
              ),
              child: _QuickStartButton(
                onPressed: () => onQuickStart(context),
                label: l10n.quickTitle,
              ),
            ),
            destinations: [
              for (final t in tabs)
                NavigationRailDestination(
                  icon: Icon(t.icon.outline),
                  selectedIcon: Icon(t.icon.filled),
                  label: Text(t.label),
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
}

class _Tab {
  const _Tab(this.branch, this.icon, this.label);

  final int branch;
  final AppIconPair icon;
  final String label;
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.tabs,
    required this.selected,
    required this.onSelect,
    required this.onQuickStart,
    required this.quickStartLabel,
  });

  final List<_Tab> tabs;
  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onQuickStart;
  final String quickStartLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget tab(_Tab t) => Expanded(
      child: _TabButton(
        tab: t,
        selected: t.branch == selected,
        onTap: () => onSelect(t.branch),
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surfaceBase,
        border: Border(top: BorderSide(color: c.borderSubtle)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              tab(tabs[0]),
              tab(tabs[1]),
              Expanded(
                child: Center(
                  child: _QuickStartButton(
                    onPressed: onQuickStart,
                    label: quickStartLabel,
                  ),
                ),
              ),
              tab(tabs[2]),
              tab(tabs[3]),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final _Tab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = selected ? c.brandPrimary : c.textTertiary;
    return Semantics(
      selected: selected,
      button: true,
      label: tab.label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: AppMotion.standard,
              curve: AppMotion.standardCurve,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xxs + 1,
              ),
              decoration: BoxDecoration(
                color: selected ? c.brandPrimarySoft : Colors.transparent,
                borderRadius: AppRadius.pillAll,
              ),
              child: Icon(
                selected ? tab.icon.filled : tab.icon.outline,
                size: 22,
                color: color,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs + 1),
            Text(
              tab.label,
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: context.textStyles.labelSmall?.copyWith(
                color: selected ? c.textPrimary : c.textTertiary,
                letterSpacing: 0.2,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The raised **+**: the theme's signature color with a soft glow.
class _QuickStartButton extends StatelessWidget {
  const _QuickStartButton({required this.onPressed, required this.label});

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: c.brandPrimary,
              boxShadow: context.tokens.shadows.glow(c.brandPrimary),
            ),
            alignment: Alignment.center,
            child: Icon(AppIcons.quickAdd, size: 26, color: c.onBrandPrimary),
          ),
        ),
      ),
    );
  }
}
