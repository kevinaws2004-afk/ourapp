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
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/state_views.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/clock_provider.dart';
import '../../activity_types/domain/activity_type.dart';
import '../../activity_types/domain/activity_type_definition.dart';
import '../../activity_types/presentation/activity_type_providers.dart';
import '../../activity_types/presentation/starter_activities.dart';
import '../../focus/presentation/focus_providers.dart';
import '../../notifications/domain/plan_reminder.dart';
import '../../notifications/presentation/notification_providers.dart';
import '../../notifications/presentation/reminder_prompt.dart';
import '../../plans/domain/plan.dart';
import '../../plans/domain/plan_title_match.dart';
import '../../plans/presentation/plan_date_notifier.dart';
import '../../plans/presentation/plan_providers.dart';
import '../../settings/presentation/preferences_providers.dart';

/// First run, five short steps: what Daylog is, what to call you, what you
/// want to make time for (which picks your starting activities), the
/// activities themselves (installed in one tap), and your first thing for
/// today — so Today never opens empty. Notification permission is asked
/// only when that first thing gets a reminder. Finishing sets the
/// onboarding flag, and the router moves to Today.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pages = PageController();
  final _name = TextEditingController();
  int _page = 0;
  final Set<FocusArea> _areas = {};
  Set<String>? _picked;
  bool _busy = false;

  static const _steps = 5;

  /// Chosen for you to start with when no area is picked; change them
  /// freely.
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

  /// The areas picked decide the activities picked for you.
  void _areasChosen(List<ActivityTypeDefinition> options) {
    final l10n = AppLocalizations.of(context);
    if (_areas.isNotEmpty) {
      final names = {for (final a in _areas) ...a.starters(l10n)};
      _picked = {
        for (final d in options)
          if (names.contains(d.name)) d.name,
      };
    }
    _go(3);
  }

  /// Installs the picked activities (skipping ones already there), then
  /// moves on to the first thing for today.
  Future<void> _install(List<ActivityTypeDefinition> options) async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(preferencesNotifierProvider.notifier).setName(_name.text);
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
      if (!mounted) return;
      setState(() => _busy = false);
      if (picked.isEmpty) {
        await _complete();
      } else {
        _go(4);
      }
    } catch (error) {
      if (mounted) {
        showMessageSnackBar(context, errorMessage(l10n, error));
        setState(() => _busy = false);
      }
    }
  }

  /// Adds the first thing to today: started now (with its timer), at a
  /// time (with a reminder, asking for permission only then), or anytime.
  Future<void> _firstPlan(
    ActivityType type,
    FirstPlanTime when, {
    required bool remind,
  }) async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final clock = ref.read(clockProvider);
      final now = clock.nowUtc();
      final start = when.startFrom(now, clock);
      final id = await ref.read(createPlanProvider)(
        PlanDraft(
          planDate: currentLocalDate(clock),
          title: '',
          activityTypeId: type.id,
          plannedStartAt: start,
        ),
      );
      if (when == FirstPlanTime.now && type.supportsTimer) {
        await ref.read(startFocusSessionProvider)(type.id, planId: id);
      } else if (remind && start != null && start.isAfter(now)) {
        await ref.read(notificationServiceProvider).requestPermission();
        await setRemindersFor(ref, id, const [ReminderBefore(10)]);
      }
      await _complete();
    } catch (error) {
      if (mounted) {
        showMessageSnackBar(context, errorMessage(l10n, error));
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _complete() async {
    unawaited(HapticFeedback.mediumImpact());
    await ref.read(preferencesNotifierProvider.notifier).completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final options = starterActivities(l10n);
    _picked ??= {for (final d in options.take(_defaultPicks)) d.name};
    final installed = [
      for (final t
          in ref.watch(activeActivityTypesProvider).value ??
              const <ActivityType>[])
        if (_picked!.contains(t.name)) t,
    ];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                // Progress and Back.
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
                      // Activities are installed by step 4: no going back.
                      if (_page > 0 && _page < 4)
                        TextButton(
                          onPressed: _busy ? null : () => _go(_page - 1),
                          child: Text(l10n.onboardingBack),
                        ),
                      if (_page == 4)
                        TextButton(
                          onPressed: _busy
                              ? null
                              : () => unawaited(_complete()),
                          child: Text(l10n.onboardingSkip),
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
                      _AreaStep(
                        picked: _areas,
                        onToggle: (area) => setState(() {
                          unawaited(HapticFeedback.selectionClick());
                          _areas.contains(area)
                              ? _areas.remove(area)
                              : _areas.add(area);
                        }),
                        onNext: () => _areasChosen(options),
                      ),
                      _PickStep(
                        options: options,
                        picked: _picked!,
                        busy: _busy,
                        onToggle: (name) => setState(() {
                          unawaited(HapticFeedback.selectionClick());
                          final p = _picked!;
                          p.contains(name) ? p.remove(name) : p.add(name);
                        }),
                        onFinish: () => unawaited(_install(options)),
                      ),
                      _FirstPlanStep(
                        types: installed,
                        busy: _busy,
                        onDone: (type, when, {required remind}) =>
                            unawaited(_firstPlan(type, when, remind: remind)),
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
          style: context.textStyles.bodyLarge?.copyWith(color: c.textSecondary),
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
        // A square tile on the left (a ListView would stretch it).
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: c.brandPrimarySoft,
              borderRadius: AppRadius.lgAll,
            ),
            alignment: Alignment.center,
            child: Icon(AppIcons.wave, color: c.brandPrimary, size: 32),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(l10n.meNameTitle, style: context.textStyles.displayMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.onboardingNameBody,
          style: context.textStyles.bodyLarge?.copyWith(color: c.textSecondary),
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
          style: context.textStyles.bodyLarge?.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xl),
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = AppSpacing.md;
            final columns = constraints.maxWidth > 440 ? 4 : 3;
            final width =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
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
          style: context.textStyles.bodySmall?.copyWith(color: c.textTertiary),
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
                      // Room for two lines on every tile, so they line up.
                      SizedBox(
                        height: 36,
                        child: Center(
                          child: Text(
                            definition.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: context.textStyles.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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

/// What someone wants to make time for (step 3): each brings its starting
/// activities.
enum FocusArea {
  study('graduation-cap', 'sky'),
  work('laptop', 'lilac'),
  fitness('barbell', 'coral'),
  reading('book-open', 'teal'),
  mind('flower-lotus', 'rose'),
  health('drop', 'slate');

  const FocusArea(this.iconId, this.colorKey);

  final String iconId;
  final String colorKey;

  String label(AppLocalizations l10n) => switch (this) {
    study => l10n.focusAreaStudy,
    work => l10n.focusAreaWork,
    fitness => l10n.focusAreaFitness,
    reading => l10n.focusAreaReading,
    mind => l10n.focusAreaMind,
    health => l10n.focusAreaHealth,
  };

  /// The starter activities it picks (by their localized names).
  List<String> starters(AppLocalizations l10n) => switch (this) {
    study => [l10n.builtInStudy, l10n.builtInFocusedWork],
    work => [l10n.builtInFocusedWork, l10n.builtInMeeting],
    fitness => [l10n.builtInGym, l10n.builtInWalking, l10n.builtInRunning],
    reading => [l10n.builtInReading, l10n.builtInLanguage],
    mind => [l10n.builtInMeditation, l10n.builtInMood],
    health => [l10n.builtInWater, l10n.builtInSleep, l10n.builtInWalking],
  };
}

/// When the first thing happens (step 5).
enum FirstPlanTime {
  now,
  inAnHour,
  evening,
  anytime;

  /// Its start, or null for anytime. "This evening" is 19:00, or an hour
  /// from now once that has passed.
  DateTime? startFrom(DateTime nowUtc, Clock clock) {
    final offset = clock.offsetAt(nowUtc);
    final local = nowUtc.add(offset);
    DateTime atLocal(int hour, int minute) => DateTime.utc(
      local.year,
      local.month,
      local.day,
      hour,
      minute,
    ).subtract(offset);
    switch (this) {
      case now:
        return nowUtc;
      case inAnHour:
        // The next quarter hour after an hour from now.
        final inHour = local.add(const Duration(hours: 1));
        final quarter = (inHour.minute / 15).ceil() * 15;
        return DateTime.utc(
          inHour.year,
          inHour.month,
          inHour.day,
          inHour.hour,
        ).add(Duration(minutes: quarter)).subtract(offset);
      case evening:
        final seven = atLocal(19, 0);
        return seven.isAfter(nowUtc)
            ? seven
            : FirstPlanTime.inAnHour.startFrom(nowUtc, clock);
      case anytime:
        return null;
    }
  }

  String label(AppLocalizations l10n) => switch (this) {
    now => l10n.firstPlanNow,
    inAnHour => l10n.firstPlanInAnHour,
    evening => l10n.firstPlanEvening,
    anytime => l10n.firstPlanAnytime,
  };
}

class _AreaStep extends StatelessWidget {
  const _AreaStep({
    required this.picked,
    required this.onToggle,
    required this.onNext,
  });

  final Set<FocusArea> picked;
  final ValueChanged<FocusArea> onToggle;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return _Step(
      action: AppButton(
        label: picked.isEmpty ? l10n.onboardingSkip : l10n.onboardingContinue,
        icon: AppIcons.arrowRight,
        expand: true,
        onPressed: onNext,
      ),
      children: [
        const SizedBox(height: AppSpacing.xl),
        Text(l10n.focusAreaTitle, style: context.textStyles.displayMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.focusAreaBody,
          style: context.textStyles.bodyLarge?.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xl),
        for (final area in FocusArea.values)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Semantics(
              selected: picked.contains(area),
              button: true,
              child: Material(
                color: picked.contains(area)
                    ? c.brandPrimarySoft
                    : c.surfaceBase,
                borderRadius: AppRadius.lgAll,
                child: InkWell(
                  borderRadius: AppRadius.lgAll,
                  onTap: () => onToggle(area),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.lgAll,
                      border: Border.all(
                        color: picked.contains(area)
                            ? c.brandPrimary
                            : c.borderSubtle,
                        width: picked.contains(area) ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        ActivityBadge(
                          iconId: area.iconId,
                          colorKey: area.colorKey,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            area.label(l10n),
                            style: context.textStyles.titleMedium,
                          ),
                        ),
                        Icon(
                          picked.contains(area)
                              ? AppIcons.taskDone
                              : AppIcons.taskOpen,
                          color: picked.contains(area)
                              ? c.brandPrimary
                              : c.textTertiary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Step 5: the first thing for today — which activity and when — so Today
/// opens with something on it.
class _FirstPlanStep extends StatefulWidget {
  const _FirstPlanStep({
    required this.types,
    required this.busy,
    required this.onDone,
  });

  final List<ActivityType> types;
  final bool busy;
  final void Function(
    ActivityType type,
    FirstPlanTime when, {
    required bool remind,
  })
  onDone;

  @override
  State<_FirstPlanStep> createState() => _FirstPlanStepState();
}

class _FirstPlanStepState extends State<_FirstPlanStep> {
  /// Times that still fall today and say something different: no "In an
  /// hour" past midnight, no "This evening" once the evening has begun.
  bool _fitsToday(FirstPlanTime when) {
    final now = DateTime.now();
    return switch (when) {
      FirstPlanTime.inAnHour =>
        now.add(const Duration(minutes: 75)).day == now.day,
      FirstPlanTime.evening => now.hour < 18,
      _ => true,
    };
  }

  /// "In an hour · 7:15 PM": the time it will be planned for.
  String _chipLabel(
    BuildContext context,
    AppLocalizations l10n,
    FirstPlanTime when,
  ) {
    if (when != FirstPlanTime.inAnHour && when != FirstPlanTime.evening) {
      return when.label(l10n);
    }
    final start = when.startFrom(DateTime.now().toUtc(), const SystemClock());
    if (start == null) return when.label(l10n);
    final time = MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay.fromDateTime(start.toLocal()));
    return '${when.label(l10n)} · $time';
  }

  ActivityType? _type;
  late FirstPlanTime _when = _fitsToday(FirstPlanTime.inAnHour)
      ? FirstPlanTime.inAnHour
      : FirstPlanTime.anytime;
  bool _remind = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final type =
        _type ??
        widget.types.where((t) => t.supportsTimer).firstOrNull ??
        widget.types.firstOrNull;
    final timed =
        _when == FirstPlanTime.inAnHour || _when == FirstPlanTime.evening;
    return _Step(
      action: AppButton(
        label: _when == FirstPlanTime.now
            ? l10n.firstPlanStartNow
            : l10n.firstPlanAdd,
        icon: _when == FirstPlanTime.now ? AppIcons.start : AppIcons.check,
        variant: AppButtonVariant.action,
        expand: true,
        onPressed: widget.busy || type == null
            ? null
            : () => widget.onDone(type, _when, remind: timed && _remind),
      ),
      children: [
        const SizedBox(height: AppSpacing.xl),
        Text(l10n.firstPlanTitle, style: context.textStyles.displayMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.firstPlanBody,
          style: context.textStyles.bodyLarge?.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xl),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final t in widget.types)
              ChoiceChip(
                avatar: ActivityBadge(
                  iconId: t.iconId,
                  colorKey: t.colorKey,
                  size: 24,
                ),
                label: Text(t.name),
                // Keep the activity's icon; the chip's own color shows it's
                // chosen.
                showCheckmark: false,
                selected: t.id == type?.id,
                onSelected: (_) => setState(() => _type = t),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(l10n.firstPlanWhen, style: context.textStyles.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final when in FirstPlanTime.values)
              if ((when != FirstPlanTime.now ||
                      (type?.supportsTimer ?? false)) &&
                  _fitsToday(when))
                ChoiceChip(
                  label: Text(_chipLabel(context, l10n, when)),
                  selected: _when == when,
                  onSelected: (_) => setState(() => _when = when),
                ),
          ],
        ),
        if (timed) ...[
          const SizedBox(height: AppSpacing.lg),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _remind,
            onChanged: (v) => setState(() => _remind = v),
            title: Text(l10n.firstPlanRemind),
            subtitle: Text(l10n.firstPlanRemindHint),
          ),
        ],
      ],
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
          // The app's own mark, in the current theme.
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: context.tokens.shadows.glow(c.brandPrimary),
            ),
            child: const AppLogo(size: 104),
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
