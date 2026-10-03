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
import '../features/plans/presentation/plan_screen.dart';
import '../features/settings/presentation/me_screen.dart';
import '../features/settings/presentation/preferences_providers.dart';
import '../features/today/presentation/today_screen.dart';
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
  static const onboarding = '/onboarding';

  // Full-screen routes (root navigator, outside the tab shell).
  static const newActivity = '/activities/new';
  static const templates = '/activities/templates';
  static String editActivity(ActivityTypeId id) =>
      '/activities/${id.value}/edit';
  static String newLog(ActivityTypeId id) => '/logs/new/${id.value}';
  static String editLog(ActivityLogId id) => '/logs/${id.value}';

  // Inside the Me tab.
  static String activity(ActivityTypeId id) => '/me/activities/${id.value}';

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
        builder: (context, state, navigationShell) => AppShell(
          navigationShell: navigationShell,
          onQuickRecord: () => unawaited(openQuickRecord(context)),
        ),
        branches: [
          _branch(AppRoutes.today, const TodayScreen()),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.plan,
                builder: (context, state) => PlanScreen(
                  onOpenRecord: (log) =>
                      unawaited(context.push(AppRoutes.editLog(log.id))),
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
                  onOpenTokenShowcase: kDebugMode
                      ? () => context.push(AppRoutes.tokenShowcase)
                      : null,
                ),
                routes: [
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
        builder: (context, state) => const ActivityBuilderScreen(),
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
          args: LogEditorArgs.create(
            ActivityTypeId(state.pathParameters['typeId']!),
          ),
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/logs/:logId',
        builder: (context, state) => LogEditorScreen(
          args: LogEditorArgs.edit(
            ActivityLogId(state.pathParameters['logId']!),
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
