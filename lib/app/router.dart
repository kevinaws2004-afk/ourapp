import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/activity_logs/domain/activity_log.dart';
import '../features/activity_logs/presentation/log_editor_notifier.dart';
import '../features/activity_logs/presentation/log_editor_screen.dart';
import '../features/activity_logs/presentation/quick_record_sheet.dart';
import '../features/activity_types/domain/activity_ids.dart';
import '../features/activity_types/domain/activity_type.dart';
import '../features/activity_types/presentation/activities_screen.dart';
import '../features/activity_types/presentation/activity_type_screen.dart';
import '../features/activity_types/presentation/builder/activity_builder_screen.dart';
import '../features/activity_types/presentation/template_picker_screen.dart';
import '../features/insights/presentation/insights_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/plans/domain/plan.dart';
import '../features/plans/domain/watch_day_overview.dart';
import '../features/plans/presentation/plan_date_notifier.dart';
import '../features/plans/presentation/plan_providers.dart';
import '../features/plans/presentation/plan_screen.dart';
import '../features/settings/presentation/me_screen.dart';
import '../features/settings/presentation/preferences_providers.dart';
import '../features/today/presentation/today_screen.dart';
import '../l10n/generated/app_localizations.dart';
import '../shared/errors/error_copy.dart';
import '../shared/widgets/state_views.dart';
import '../core/errors/app_exception.dart';
import '../features/focus/domain/focus_session.dart';
import '../features/focus/presentation/focus_providers.dart';
import '../features/focus/presentation/focus_screen.dart';
import '../features/focus/presentation/start_choice_sheet.dart';
import '../features/measurements/domain/measurement.dart';
import '../features/measurements/presentation/measurement_type_screen.dart';
import '../features/measurements/presentation/measurements_screen.dart';
import 'app_shell.dart';
import 'dev/token_showcase_screen.dart';

/// All route paths. Routing lives only here (application_architecture.md §6).
/// Route parameters are public IDs (ADR-017), never entities.
abstract final class AppRoutes {
  static const today = '/today';
  static const plan = '/plan';
  static const insights = '/insights';
  static const me = '/me';

  /// Reusable activity setup, under Me (ADR-028).
  static const activities = '/me/activities';

  /// Body measurements, under Me (Phase 6).
  static const measurements = '/me/measurements';
  static String measurementType(MeasurementType type) =>
      '/me/measurements/${type.storageKey}';
  static const onboarding = '/onboarding';

  // Full-screen routes (root navigator, outside the tab shell).
  static const newActivity = '/activities/new';

  /// A new activity named up front (e.g. a plan's title, ADR-030).
  static String newActivityNamed(String name) =>
      '$newActivity?name=${Uri.encodeQueryComponent(name)}';
  static const templates = '/activities/templates';
  static String editActivity(ActivityTypeId id) =>
      '/activities/${id.value}/edit';

  /// A new record; with [planId] it fulfils that plan (F5).
  static String newLog(ActivityTypeId id, {PlanId? planId}) =>
      '/logs/new/${id.value}${planId == null ? '' : '?plan=${planId.value}'}';
  static String editLog(ActivityLogId id) => '/logs/${id.value}';

  // Inside the Me tab.
  static String activity(ActivityTypeId id) => '/me/activities/${id.value}';

  /// The active focus session (full screen, ADR-031).
  static const focus = '/focus';
  static String finishFocus(FocusSessionId id) => '/focus/finish/${id.value}';

  /// Debug builds only.
  static const tokenShowcase = '/dev/tokens';
}

/// Sends users to onboarding until it's completed, and away from it after.
String? onboardingRedirect({
  required bool onboardingCompleted,
  required String location,
}) {
  final atOnboarding = location == AppRoutes.onboarding;
  if (!onboardingCompleted && !atOnboarding) return AppRoutes.onboarding;
  if (onboardingCompleted && atOnboarding) return AppRoutes.today;
  return null;
}

final routerProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final onboardingCompleted = ValueNotifier<bool>(
    ref.read(initialPreferencesProvider).onboardingCompleted,
  );
  ref.listen(onboardingCompletedProvider, (_, next) {
    final value = next.value;
    if (value != null) onboardingCompleted.value = value;
  });

  Future<void> openNewActivity(BuildContext context) async {
    final id = await context.push<ActivityTypeId>(AppRoutes.newActivity);
    if (id != null && context.mounted) {
      unawaited(context.push(AppRoutes.activity(id)));
    }
  }

  /// Quick Record (ADR-028): pick an activity, then record it.
  Future<void> openQuickRecord(BuildContext context) async {
    final result = await showModalBottomSheet<Object>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const QuickRecordSheet(),
    );
    if (!context.mounted) return;
    if (result is ActivityType) {
      unawaited(context.push(AppRoutes.newLog(result.id)));
    } else if (identical(result, QuickRecordSheet.newActivity)) {
      unawaited(openNewActivity(context));
    }
  }

  /// Starts a focus session (optionally doing a plan) and opens the timer.
  /// If one is already running, opens that one instead (OQ-11).
  Future<void> startFocus(
    BuildContext context,
    ActivityTypeId typeId, {
    PlanId? planId,
  }) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(startFocusSessionProvider)(typeId, planId: planId);
    } on ValidationException catch (e) {
      if (!context.mounted) return;
      showMessageSnackBar(
        context,
        validationMessage(l10n, e.issues.first.code),
      );
      if (e.issues.first.code != ValidationCode.focusAlreadyActive) return;
    } catch (error) {
      if (context.mounted) {
        showMessageSnackBar(context, errorMessage(l10n, error));
      }
      return;
    }
    if (context.mounted) unawaited(context.push(AppRoutes.focus));
  }

  /// Records an activity plan (F5): timer activities offer a focus session
  /// or recording now; others open the record form, prefilled and linked.
  Future<void> recordPlan(BuildContext context, PlannedItem item) async {
    final type = item.type;
    if (type == null) return;
    if (item.status == EffectivePlanStatus.inProgress) {
      unawaited(context.push(AppRoutes.focus)); // back to its running timer
      return;
    }
    if (type.supportsTimer && item.records.isEmpty) {
      final choice = await showStartChoice(context, item.plan.title);
      if (!context.mounted || choice == null) return;
      if (choice == StartChoice.focus) {
        return startFocus(context, type.id, planId: item.plan.id);
      }
    }
    if (context.mounted) {
      unawaited(context.push(AppRoutes.newLog(type.id, planId: item.plan.id)));
    }
  }

  /// Tracks a task plan: set up what to record for it (an activity named
  /// after the plan, fields of the user's choosing), link the plan to it,
  /// then record it (ADR-030).
  Future<void> trackPlan(BuildContext context, PlannedItem item) async {
    final id = await context.push<ActivityTypeId>(
      AppRoutes.newActivityNamed(item.plan.title),
    );
    if (id == null || !context.mounted) return;
    try {
      await ref.read(assignPlanActivityProvider)(item.plan.id, id);
    } catch (error) {
      if (context.mounted) {
        showMessageSnackBar(
          context,
          errorMessage(AppLocalizations.of(context), error),
        );
      }
      return;
    }
    if (context.mounted) {
      unawaited(context.push(AppRoutes.newLog(id, planId: item.plan.id)));
    }
  }

  Future<void> openTemplates(BuildContext context) async {
    final id = await context.push<ActivityTypeId>(AppRoutes.templates);
    if (id != null && context.mounted) {
      unawaited(context.push(AppRoutes.activity(id)));
    }
  }

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: onboardingCompleted.value
        ? AppRoutes.today
        : AppRoutes.onboarding,
    refreshListenable: onboardingCompleted,
    redirect: (context, state) => onboardingRedirect(
      onboardingCompleted: onboardingCompleted.value,
      location: state.matchedLocation,
    ),
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.today,
                builder: (context, state) => TodayScreen(
                  onOpenRecord: (log) =>
                      unawaited(context.push(AppRoutes.editLog(log.id))),
                  onRecordPlan: (item) => unawaited(recordPlan(context, item)),
                  onTrackPlan: (item) => unawaited(trackPlan(context, item)),
                  onOpenFocus: () => unawaited(context.push(AppRoutes.focus)),
                  onPlanDay: () {
                    ref.read(planSelectedDateProvider.notifier).goToToday();
                    context.go(AppRoutes.plan);
                  },
                  onQuickRecord: () => unawaited(openQuickRecord(context)),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.plan,
                builder: (context, state) => PlanScreen(
                  onOpenRecord: (log) =>
                      unawaited(context.push(AppRoutes.editLog(log.id))),
                  onRecordPlan: (item) => unawaited(recordPlan(context, item)),
                  onTrackPlan: (item) => unawaited(trackPlan(context, item)),
                ),
              ),
            ],
          ),
          _branch(AppRoutes.insights, const InsightsScreen()),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.me,
                builder: (context, state) => MeScreen(
                  onOpenActivities: () => context.go(AppRoutes.activities),
                  onOpenMeasurements: () => context.go(AppRoutes.measurements),
                  onOpenTokenShowcase: kDebugMode
                      ? () => context.push(AppRoutes.tokenShowcase)
                      : null,
                ),
                routes: [
                  GoRoute(
                    path: 'measurements',
                    builder: (context, state) => MeasurementsScreen(
                      onOpenType: (type) => unawaited(
                        context.push(AppRoutes.measurementType(type)),
                      ),
                    ),
                    routes: [
                      GoRoute(
                        path: ':type',
                        builder: (context, state) => MeasurementTypeScreen(
                          type:
                              MeasurementType.fromStorageKey(
                                state.pathParameters['type']!,
                              ) ??
                              MeasurementType.weight,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'activities',
                    builder: (context, state) => ActivitiesScreen(
                      onNewActivity: () => unawaited(openNewActivity(context)),
                      onFromTemplate: () => unawaited(openTemplates(context)),
                      onOpenType: (type) =>
                          unawaited(context.push(AppRoutes.activity(type.id))),
                      onRecordType: (type) =>
                          unawaited(context.push(AppRoutes.newLog(type.id))),
                    ),
                    routes: [
                      GoRoute(
                        path: ':typeId',
                        builder: (context, state) {
                          final typeId = ActivityTypeId(
                            state.pathParameters['typeId']!,
                          );
                          return ActivityTypeScreen(
                            typeId: typeId,
                            onLog: () => unawaited(
                              context.push(AppRoutes.newLog(typeId)),
                            ),
                            onStartFocus: () =>
                                unawaited(startFocus(context, typeId)),
                            onEdit: () => unawaited(
                              context.push(AppRoutes.editActivity(typeId)),
                            ),
                            onOpenLog: (log) => unawaited(
                              context.push(AppRoutes.editLog(log.id)),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.newActivity,
        builder: (context, state) => ActivityBuilderScreen(
          initialName: state.uri.queryParameters['name'] ?? '',
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.templates,
        builder: (context, state) => const TemplatePickerScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/activities/:typeId/edit',
        builder: (context, state) => ActivityBuilderScreen(
          typeId: ActivityTypeId(state.pathParameters['typeId']!),
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/logs/new/:typeId',
        builder: (context, state) => LogEditorScreen(
          onEditFields: (typeId) =>
              context.push<ActivityTypeId>(AppRoutes.editActivity(typeId)),
          args: LogEditorArgs.create(
            ActivityTypeId(state.pathParameters['typeId']!),
            planId: switch (state.uri.queryParameters['plan']) {
              final id? => PlanId(id),
              null => null,
            },
          ),
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/logs/:logId',
        builder: (context, state) => LogEditorScreen(
          onEditFields: (typeId) =>
              context.push<ActivityTypeId>(AppRoutes.editActivity(typeId)),
          args: LogEditorArgs.edit(
            ActivityLogId(state.pathParameters['logId']!),
          ),
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.focus,
        builder: (context, state) => FocusScreen(
          onFinish: (session) async {
            final saved = await context.push<bool>(
              AppRoutes.finishFocus(session.id),
            );
            if (saved == true && context.mounted) context.pop();
          },
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/focus/finish/:sessionId',
        builder: (context, state) => LogEditorScreen(
          onEditFields: (typeId) =>
              context.push<ActivityTypeId>(AppRoutes.editActivity(typeId)),
          args: LogEditorArgs.finishFocus(
            FocusSessionId(state.pathParameters['sessionId']!),
          ),
        ),
      ),
      if (kDebugMode)
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          path: AppRoutes.tokenShowcase,
          builder: (context, state) => const TokenShowcaseScreen(),
        ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    onboardingCompleted.dispose();
  });
  return router;
});

StatefulShellBranch _branch(String path, Widget screen) => StatefulShellBranch(
  routes: [GoRoute(path: path, builder: (context, state) => screen)],
);
