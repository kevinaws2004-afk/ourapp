import 'package:daylog/app/router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('before onboarding, every location redirects to onboarding', () {
    for (final location in [
      AppRoutes.today,
      AppRoutes.me,
      AppRoutes.tokenShowcase,
    ]) {
      expect(
        onboardingRedirect(onboardingCompleted: false, location: location),
        AppRoutes.onboarding,
      );
    }
    expect(
      onboardingRedirect(
        onboardingCompleted: false,
        location: AppRoutes.onboarding,
      ),
      isNull,
    );
  });

  test('after onboarding, the onboarding route redirects to Today', () {
    expect(
      onboardingRedirect(
        onboardingCompleted: true,
        location: AppRoutes.onboarding,
      ),
      AppRoutes.today,
    );
    expect(
      onboardingRedirect(onboardingCompleted: true, location: AppRoutes.plan),
      isNull,
    );
  });
}
