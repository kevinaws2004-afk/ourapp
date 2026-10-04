import 'package:daylog/app/bootstrap.dart';
import 'package:daylog/app/dev/token_showcase_screen.dart';
import 'package:daylog/features/today/presentation/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Launches the real app on a device: real `bootstrap()`, on-device database
/// file and schema v1 migration. The database persists between runs, so the
/// test accepts either a first launch (onboarding) or a returning launch.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'the app boots, passes onboarding, navigates and switches theme',
    (tester) async {
      final originalOnError = FlutterError.onError;
      await bootstrap();
      // bootstrap() installs the app's error handler; the test framework
      // requires its own to be restored before the test ends.
      FlutterError.onError = originalOnError;
      await tester.pumpAndSettle();

      final getStarted = find.text('Get started');
      if (getStarted.evaluate().isNotEmpty) {
        await tester.tap(getStarted);
        await tester.pumpAndSettle();
      }
      expect(find.byType(TodayScreen), findsOneWidget);

      for (final tab in ['Plan', 'Insights', 'Me']) {
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text(tab),
          ),
        );
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text('Design tokens'));
      await tester.pumpAndSettle();
      expect(find.byType(TokenShowcaseScreen), findsOneWidget);

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(
        Theme.of(tester.element(find.byType(TokenShowcaseScreen))).brightness,
        Brightness.dark,
      );

      // Leave the device in its default state.
      await tester.tap(find.text('System'));
      await tester.pumpAndSettle();
    },
  );
}
