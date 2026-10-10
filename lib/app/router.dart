import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/activity_logs/domain/activity_log.dart';
import '../features/activity_types/domain/activity_ids.dart';
import '../features/activity_types/presentation/activities_screen.dart';
import '../features/activity_types/presentation/activity_type_screen.dart';
import '../features/activity_types/presentation/builder/activity_builder_screen.dart';
import '../features/activity_types/presentation/browse_activities_screen.dart';
import '../features/insights/presentation/activity_insights_screen.dart';
import '../features/insights/presentation/insights_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/plans/presentation/activity_chooser.dart';
import '../features/plans/domain/plan.dart';
import '../core/time/clock_provider.dart';
import '../features/plans/presentation/item/item_notifier.dart';
import '../features/plans/presentation/item/item_screen.dart';
import '../features/plans/presentation/plan_date_notifier.dart';
import '../features/plans/presentation/plan_providers.dart';
import '../features/plans/presentation/plan_screen.dart';
import '../features/settings/presentation/appearance_screen.dart';
import '../features/settings/presentation/me_screen.dart';
import '../features/settings/presentation/preferences_providers.dart';
import '../features/today/presentation/today_screen.dart';
import '../l10n/generated/app_localizations.dart';
import '../shared/errors/error_copy.dart';
import '../shared/widgets/state_views.dart';
import '../core/errors/app_exception.dart';
import '../features/challenges/domain/challenge.dart';
import '../features/challenges/presentation/challenge_screen.dart';
import '../features/challenges/presentation/challenges_screen.dart';
import '../features/focus/presentation/focus_providers.dart';
import '../features/focus/presentation/focus_screen.dart';
import '../features/measurements/domain/measurement.dart';
import '../features/measurements/presentation/measurement_type_screen.dart';
import '../features/measurements/presentation/measurements_screen.dart';
import 'app_shell.dart';
import 'dev/demo_data.dart';
import 'dev/dev_tools.dart';
import 'dev/token_showcase_screen.dart';

/// All route paths. Routing lives only here (application_architecture.md §6).
/// Route parameters are public IDs (ADR-017), never entities.
abstract final class AppRoutes {
  static const today = '/today';
  static const plan = '/plan';

  /// The Plan tab's selected date as one day (A1).
  static const insights = '/insights';

  /// An activity's automatic progress (ADR-037), inside the Insights tab.
  static String activityInsights(ActivityTypeId id) =>
      '/insights/activity/${id.value}';
  static const me = '/me';

  /// Reusable activity setup, under Me (ADR-028).
  static const activities = '/me/activities';

  /// The Challenges tab (ADR-044).
  static const challenges = '/challenges';

  /// The app's theme, under Me (ADR-045).
  static const appearance = '/me/appearance';

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

  /// Choosing an activity for a day (ADR-042).
  static const browseActivities = '/activities/browse';

  /// A challenge: progress, streaks and its days (ADR-044).
  static String challenge(ChallengeId id) => '/challenge/${id.value}';
  static String editActivity(ActivityTypeId id) =>
      '/activities/${id.value}/edit';

  /// An item on a day, where you log into it (ADR-035).
  static String item(PlanId id) => '/item/${id.value}';

  /// A record made without a plan, opened as an item.
  static String itemLog(ActivityLogId id) => '/item/log/${id.value}';

  // Inside the Me tab.
  static String activity(ActivityTypeId id) => '/me/activities/${id.value}';

  /// The active focus session (full screen, ADR-031).
  static const focus = '/focus';

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

  /// Opens a record: its plan's item, or the record itself as an item.
  void openLog(BuildContext context, ActivityLog log) => unawaited(
    context.push(
      log.planId == null
          ? AppRoutes.itemLog(log.id)
          : AppRoutes.item(log.planId!),
    ),
  );

  /// Returns to the running timer: its item, or the full-screen timer for a
  /// session without one.
  void openFocus(BuildContext context) {
    final planId = ref.read(activeFocusSessionProvider).value?.planId;
    unawaited(
      context.push(planId == null ? AppRoutes.focus : AppRoutes.item(planId)),
    );
  }

  /// Doing an activity now (from its page): an item for it starts now and
  /// opens, optionally with its timer running (ADR-035).
  Future<void> doNow(
    BuildContext context,
    ActivityTypeId typeId, {
    bool withTimer = false,
  }) async {
    final l10n = AppLocalizations.of(context);
    final clock = ref.read(clockProvider);
    try {
      final planId = await ref.read(createPlanProvider)(
        PlanDraft(
          planDate: currentLocalDate(clock),
          title: '',
          activityTypeId: typeId,
          plannedStartAt: clock.nowUtc(),
        ),
      );
      if (withTimer) {
        await ref.read(startFocusSessionProvider)(typeId, planId: planId);
      }
      if (context.mounted) unawaited(context.push(AppRoutes.item(planId)));
    } on ValidationException catch (e) {
      if (context.mounted) {
        showMessageSnackBar(
          context,
          validationMessage(l10n, e.issues.first.code),
        );
      }
    } catch (error) {
      if (context.mounted) {
        showMessageSnackBar(context, errorMessage(l10n, error));
      }
    }
  }

  /// Where a new item on a day gets its activity: the list of activities,
  /// or the builder to make your own.
  ActivityChooser chooser(BuildContext context) => ActivityChooser(
    browse: () => context.push<ActivityTypeId>(AppRoutes.browseActivities),
    makeOwn: (name) =>
        context.push<ActivityTypeId>(AppRoutes.newActivityNamed(name)),
  );

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
                  onOpenItem: (id) =>
                      unawaited(context.push(AppRoutes.item(id))),
                  onOpenRecord: (log) => openLog(context, log),
                  onOpenFocus: () => openFocus(context),
                  onOpenChallenge: (id) =>
                      unawaited(context.push(AppRoutes.challenge(id))),
                  onPlanDate: (date) {
                    ref.read(planSelectedDateProvider.notifier).select(date);
                    context.go(AppRoutes.plan);
                  },
                  chooser: chooser(context),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.plan,
                builder: (context, state) => PlanScreen(
                  onOpenItem: (id) =>
                      unawaited(context.push(AppRoutes.item(id))),
                  onOpenRecord: (log) => openLog(context, log),
                  chooser: chooser(context),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.challenges,
                builder: (context, state) => ChallengesScreen(
                  onOpenChallenge: (id) =>
                      unawaited(context.push(AppRoutes.challenge(id))),
                  chooser: chooser(context),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.insights,
                builder: (context, state) => InsightsScreen(
                  onOpenActivity: (id) =>
                      unawaited(context.push(AppRoutes.activityInsights(id))),
                  chooser: chooser(context),
                ),
                routes: [
                  GoRoute(
                    path: 'activity/:typeId',
                    builder: (context, state) => ActivityInsightsScreen(
                      typeId: ActivityTypeId(state.pathParameters['typeId']!),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.me,
                builder: (context, state) => MeScreen(
                  onOpenActivities: () => context.go(AppRoutes.activities),
                  onOpenMeasurements: () => context.go(AppRoutes.measurements),
                  onOpenAppearance: () => context.go(AppRoutes.appearance),
                  onOpenTokenShowcase: devToolsEnabled
                      ? () => context.push(AppRoutes.tokenShowcase)
                      : null,
                  onLoadDemoData: devToolsEnabled
                      ? () => unawaited(_loadDemoData(context))
                      : null,
                  onLoadRecentDemoData: devToolsEnabled
                      ? () => unawaited(_loadDemoData(context, lastDays: 10))
                      : null,
                ),
                routes: [
                  GoRoute(
                    path: 'appearance',
                    builder: (context, state) => const AppearanceScreen(),
                  ),
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
                      onOpenActivity: (id) =>
                          unawaited(context.push(AppRoutes.activity(id))),
                      onRecordType: (type) =>
                          unawaited(doNow(context, type.id)),
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
                            onLog: () => unawaited(doNow(context, typeId)),
                            onStartFocus: () => unawaited(
                              doNow(context, typeId, withTimer: true),
                            ),
                            onEdit: () => unawaited(
                              context.push(AppRoutes.editActivity(typeId)),
                            ),
                            onOpenLog: (log) => openLog(context, log),
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
        path: '/challenge/:id',
        builder: (context, state) => ChallengeScreen(
          challengeId: ChallengeId(state.pathParameters['id']!),
        ),
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
        path: AppRoutes.browseActivities,
        builder: (context, state) => const BrowseActivitiesScreen(),
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
        path: '/item/log/:logId',
        builder: (context, state) => ItemScreen(
          args: ItemArgs.log(ActivityLogId(state.pathParameters['logId']!)),
          onOpenTimer: () => unawaited(context.push(AppRoutes.focus)),
          onEditFields: (typeId) =>
              context.push<ActivityTypeId>(AppRoutes.editActivity(typeId)),
          onOpenItem: (id) => unawaited(context.push(AppRoutes.item(id))),
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/item/:planId',
        builder: (context, state) => ItemScreen(
          args: ItemArgs.plan(PlanId(state.pathParameters['planId']!)),
          onOpenTimer: () => unawaited(context.push(AppRoutes.focus)),
          onEditFields: (typeId) =>
              context.push<ActivityTypeId>(AppRoutes.editActivity(typeId)),
          onOpenItem: (id) => unawaited(context.push(AppRoutes.item(id))),
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.focus,
        builder: (context, state) => FocusScreen(
          // Finishing fills the item's log with the timed span (ADR-035).
          onFinish: (session) async {
            final l10n = AppLocalizations.of(context);
            try {
              await ref.read(finishFocusSessionProvider)(session.id);
            } catch (error) {
              if (context.mounted) {
                showMessageSnackBar(context, errorMessage(l10n, error));
              }
              return;
            }
            if (context.mounted) context.pop();
          },
        ),
      ),
      if (devToolsEnabled)
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

/// Developer tools only: fills the app with demo data (dev/demo_data.dart):
/// six weeks up to today, or with [lastDays] the days ending yesterday.
Future<void> _loadDemoData(BuildContext context, {int? lastDays}) async {
  final messenger = ScaffoldMessenger.of(context);
  final container = ProviderScope.containerOf(context);
  final clock = container.read(clockProvider);
  final yesterday = currentLocalDate(clock).addDays(-1);
  final result = await loadDemoData(
    container,
    AppLocalizations.of(context),
    from: lastDays == null ? null : yesterday.addDays(-(lastDays - 1)),
    to: lastDays == null ? null : yesterday,
  );
  // Developer tooling: intentionally not localized (coding_standards.md §4).
  messenger.showSnackBar(
    SnackBar(
      content: Text(switch (result) {
        DemoDataResult.loaded => 'Demo data loaded',
        DemoDataResult.alreadyLoaded => 'Demo data is already loaded',
        DemoDataResult.namesTaken =>
          'Demo data needs an app without Gym, Reading, Walking or '
              'Focused work activities',
      }),
    ),
  );
}
