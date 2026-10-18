import 'dart:async';

import 'package:daylog/core/design/app_theme.dart';
import 'package:daylog/core/design/themes/app_theme_id.dart';
import 'package:daylog/features/settings/presentation/app_lock.dart';
import 'package:daylog/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';

/// The phone's lock, answering each prompt with the next queued result.
class _FakeAuth implements LocalAuthentication {
  final results = <FutureOr<bool> Function()>[];
  var prompts = 0;

  @override
  Future<bool> authenticate({
    required String localizedReason,
    Iterable<Object> authMessages = const [],
    bool biometricOnly = false,
    bool sensitiveTransaction = true,
    bool persistAcrossBackgrounding = false,
  }) async {
    prompts++;
    return results.removeAt(0)();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// App lock (Me → App lock): only passing the phone's lock opens the app.
void main() {
  late _FakeAuth auth;
  late StreamController<bool> enabled;

  setUp(() {
    auth = _FakeAuth();
    enabled = StreamController<bool>.broadcast();
  });

  tearDown(() => enabled.close());

  Future<void> pumpGate(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialAppLockProvider.overrideWithValue(true),
          appLockEnabledProvider.overrideWith((ref) => enabled.stream),
          localAuthProvider.overrideWithValue(auth),
        ],
        child: MaterialApp(
          theme: AppTheme.of(AppThemeId.lavender),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AppLockGate(child: Text('Private plans')),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  bool locked() => find.text('DayCraft is locked').evaluate().isNotEmpty;

  testWidgets('it opens locked and asks at once; passing unlocks', (
    tester,
  ) async {
    auth.results.add(() => true);
    await pumpGate(tester);

    expect(auth.prompts, 1);
    expect(locked(), isFalse);
  });

  testWidgets('a cancelled or failed prompt keeps it locked', (tester) async {
    auth.results
      ..add(
        () => throw const LocalAuthException(
          code: LocalAuthExceptionCode.userCanceled,
        ),
      )
      ..add(() => false);
    await pumpGate(tester);
    expect(locked(), isTrue);

    await tester.tap(find.text('Unlock'));
    await tester.pump();
    await tester.pump();
    expect(auth.prompts, 2);
    expect(locked(), isTrue);
  });

  testWidgets('the setting reading off mid-change never unlocks it', (
    tester,
  ) async {
    auth.results.add(
      () => throw const LocalAuthException(
        code: LocalAuthExceptionCode.userCanceled,
      ),
    );
    await pumpGate(tester);
    expect(locked(), isTrue);

    enabled.add(false);
    await tester.pump();
    await tester.pump();

    expect(locked(), isTrue);
  });

  testWidgets('locked content is hidden from screen readers', (tester) async {
    final semantics = tester.ensureSemantics();
    auth.results.add(
      () => throw const LocalAuthException(
        code: LocalAuthExceptionCode.userCanceled,
      ),
    );
    await pumpGate(tester);

    expect(find.bySemanticsLabel('Private plans'), findsNothing);
    expect(find.bySemanticsLabel(RegExp('DayCraft is locked')), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('coming back to a locked app asks again', (tester) async {
    auth.results
      ..add(
        () => throw const LocalAuthException(
          code: LocalAuthExceptionCode.systemCanceled,
        ),
      )
      ..add(() => true);
    await pumpGate(tester);
    expect(locked(), isTrue);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump();

    expect(auth.prompts, 2);
    expect(locked(), isFalse);
  });
}
