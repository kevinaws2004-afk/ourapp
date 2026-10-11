import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/motion.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/errors/error_copy.dart';
import '../../../shared/widgets/activity_badge.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/state_views.dart';
import '../../activity_types/domain/activity_type_definition.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../../activity_types/presentation/starter_activities.dart';
import '../../plans/domain/plan_title_match.dart';
import '../../settings/presentation/preferences_providers.dart';

/// First run, three short steps: what Daylog is, what to call you, and what
/// you want to track (your first activities, installed in one tap). Finishing
/// sets the onboarding flag, and the router moves to Today.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pages = PageController();
  final _name = TextEditingController();
  int _page = 0;
  Set<String>? _picked;
  bool _busy = false;

  static const _steps = 3;

  /// Chosen for you to start with; change them freely.
  static const _defaultPicks = 3;

  @override
  void dispose() {
    _pages.dispose();
    _name.dispose();
    super.dispose();
  }

  void _go(int page) {
    FocusScope.of(context).unfocus();
    unawaited(HapticFeedback.selectionClick());
    unawaited(
      _pages.animateToPage(
        page,
        duration: AppMotion.emphasized,
        curve: AppMotion.emphasizedCurve,
      ),
    );
  }

  Future<void> _finish(List<ActivityTypeDefinition> options) async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final prefs = ref.read(preferencesNotifierProvider.notifier);
      await prefs.setName(_name.text);
      final picked = _picked ?? const <String>{};
      final existing = await ref
          .read(activityTypeRepositoryProvider)
          .getActiveTypes();
      final install = ref.read(addBuiltInActivityProvider);
      for (final definition in options) {
        if (!picked.contains(definition.name)) continue;
        if (matchByName(definition.name, existing, (t) => t.name) != null) {
          continue;
        }
        await install(definition);
      }
      unawaited(HapticFeedback.mediumImpact());
      await prefs.completeOnboarding();
    } catch (error) {
      if (mounted) {
        showMessageSnackBar(context, errorMessage(l10n, error));
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final options = starterActivities(l10n);
    _picked ??= {for (final d in options.take(_defaultPicks)) d.name};

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                // Progress and Skip.
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.md,
                    AppSpacing.md,
                    0,
                  ),
                  child: Row(
                    children: [
                      for (var i = 0; i < _steps; i++)
                        AnimatedContainer(
                          duration: AppMotion.standard,
                          margin: const EdgeInsets.only(right: AppSpacing.xs),
                          width: i == _page ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i <= _page
                                ? c.brandPrimary
                                : c.brandPrimarySoft,
                            borderRadius: AppRadius.pillAll,
                          ),
                        ),
                      const Spacer(),
                      if (_page > 0)
                        TextButton(
                          onPressed: _busy ? null : () => _go(_page - 1),
                          child: Text(l10n.onboardingBack),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pages,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (p) => setState(() => _page = p),
                    children: [
                      _Welcome(onNext: () => _go(1)),
                      _NameStep(controller: _name, onNext: () => _go(2)),
                      _PickStep(
                        options: options,
                        picked: _picked!,
                        busy: _busy,
                        onToggle: (name) => setState(() {
                          unawaited(HapticFeedback.selectionClick());
                          final p = _picked!;
                          p.contains(name) ? p.remove(name) : p.add(name);
                        }),
                        onFinish: () => unawaited(_finish(options)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    Widget point(IconData icon, Color tint, String title, String body) =>
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.14),
                  borderRadius: AppRadius.mdAll,
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: tint, size: 22),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.textStyles.titleMedium),
                    Text(
                      body,
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
    return _Step(
      action: AppButton(
        label: l10n.onboardingStart,
        icon: AppIcons.arrowRight,
        expand: true,
        onPressed: onNext,
      ),
      children: [
        const Center(child: _Orbit()),
        const SizedBox(height: AppSpacing.lg),
        Text(l10n.onboardingTitle, style: context.textStyles.displayMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.onboardingBody,
          style: context.textStyles.bodyLarge?.copyWith(
            color: c.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        point(
          AppIcons.plan.outline,
          c.brandPrimary,
          l10n.onboardingPointPlan,
          l10n.onboardingPointPlanBody,
        ),
        point(
          AppIcons.timer,
          c.action,
          l10n.onboardingPointDo,
          l10n.onboardingPointDoBody,
        ),
        point(
          AppIcons.insights.outline,
          c.accent,
          l10n.onboardingPointSee,
          l10n.onboardingPointSeeBody,
        ),
      ],
    );
  }
}

class _NameStep extends StatelessWidget {
  const _NameStep({required this.controller, required this.onNext});

  final TextEditingController controller;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return _Step(
      action: ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, value, _) => AppButton(
          label: value.text.trim().isEmpty
              ? l10n.onboardingSkip
              : l10n.onboardingContinue,
          icon: AppIcons.arrowRight,
          expand: true,
          onPressed: onNext,
        ),
      ),
      children: [
        const SizedBox(height: AppSpacing.giant),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: c.brandPrimarySoft,
            borderRadius: AppRadius.lgAll,
          ),
          alignment: Alignment.center,
          child: Icon(AppIcons.wave, color: c.brandPrimary, size: 32),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(l10n.meNameTitle, style: context.textStyles.displayMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.onboardingNameBody,
          style: context.textStyles.bodyLarge?.copyWith(
            color: c.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        TextField(
          controller: controller,
          maxLength: 40,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          style: context.textStyles.titleLarge,
          decoration: InputDecoration(
            hintText: l10n.meNameHint,
            counterText: '',
          ),
          onSubmitted: (_) => onNext(),
        ),
      ],
    );
  }
}

class _PickStep extends StatelessWidget {
  const _PickStep({
    required this.options,
    required this.picked,
    required this.busy,
    required this.onToggle,
    required this.onFinish,
  });

  final List<ActivityTypeDefinition> options;
  final Set<String> picked;
  final bool busy;
  final ValueChanged<String> onToggle;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return _Step(
      action: AppButton(
        label: picked.isEmpty
            ? l10n.onboardingFinishEmpty
            : l10n.onboardingFinish(picked.length),
        icon: AppIcons.check,
        variant: AppButtonVariant.action,
        expand: true,
        onPressed: busy ? null : onFinish,
      ),
      children: [
        const SizedBox(height: AppSpacing.xl),
        Text(l10n.onboardingPickTitle, style: context.textStyles.displayMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.onboardingPickBody,
          style: context.textStyles.bodyLarge?.copyWith(
            color: c.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = AppSpacing.md;
            final columns = constraints.maxWidth > 440 ? 4 : 3;
            final width = (constraints.maxWidth - gap * (columns - 1)) /
                columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final d in options)
                  SizedBox(
                    width: width,
                    child: _PickTile(
                      definition: d,
                      selected: picked.contains(d.name),
                      onTap: () => onToggle(d.name),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.onboardingPickHint,
          textAlign: TextAlign.center,
          style: context.textStyles.bodySmall?.copyWith(
            color: c.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _PickTile extends StatelessWidget {
  const _PickTile({
    required this.definition,
    required this.selected,
    required this.onTap,
  });

  final ActivityTypeDefinition definition;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      selected: selected,
      button: true,
      label: definition.name,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        decoration: BoxDecoration(
          color: selected ? c.brandPrimarySoft : c.surfaceBase,
          borderRadius: AppRadius.lgAll,
          border: Border.all(
            color: selected ? c.brandPrimary : c.borderSubtle,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: AppRadius.lgAll,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.lg,
              horizontal: AppSpacing.xs,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: Column(
                    children: [
                      ActivityBadge(
                        iconId: definition.iconId,
                        colorKey: definition.colorKey,
                        size: 48,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        definition.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: context.textStyles.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Positioned(
                    top: -AppSpacing.sm,
                    right: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: c.brandPrimary,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        AppIcons.check,
                        size: 13,
                        color: c.onBrandPrimary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One step: scrolling content with its action pinned at the bottom.
class _Step extends StatelessWidget {
  const _Step({required this.children, required this.action});

  final List<Widget> children;
  final Widget action;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          children: children,
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.md,
          AppSpacing.xl,
          AppSpacing.lg,
        ),
        child: action,
      ),
    ],
  );
}

/// The welcome picture: the app's mark in the middle of your day, with
/// activities circling it.
class _Orbit extends StatelessWidget {
  const _Orbit();

  static const _size = 240.0;
  static const _badges = [
    ('book-open', 'sky'),
    ('barbell', 'coral'),
    ('person-simple-walk', 'teal'),
    ('laptop', 'lilac'),
    ('flower-lotus', 'rose'),
    ('coffee', 'slate'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox.square(
      dimension: _size + 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final r in [_size, _size * 0.68])
            Container(
              width: r,
              height: r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: c.borderSubtle, width: 1.5),
              ),
            ),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: c.brandPrimary,
              boxShadow: context.tokens.shadows.glow(c.brandPrimary),
            ),
            alignment: Alignment.center,
            child: Icon(AppIcons.dayDone, size: 46, color: c.onBrandPrimary),
          ),
          for (final (i, (icon, color)) in _badges.indexed)
            Transform.translate(
              offset: Offset.fromDirection(
                -math.pi / 2 + i * 2 * math.pi / _badges.length,
                i.isEven ? _size / 2 : _size * 0.34,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: context.tokens.shadows.card,
                ),
                child: ActivityBadge(iconId: icon, colorKey: color, size: 48),
              ),
            ),
        ],
      ),
    );
  }
}
