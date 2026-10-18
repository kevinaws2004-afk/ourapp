import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/database/json_preferences.dart';
import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/state_views.dart';

const appLockKey = 'app_lock';

/// Whether app lock was on at launch, read by `bootstrap()` so the first
/// frame is already locked (nothing private flashes).
final initialAppLockProvider = Provider<bool>((ref) => false);

/// App lock (Me → App lock): the phone's own fingerprint, face or screen
/// lock before Daylog opens.
final appLockEnabledProvider = StreamProvider<bool>(
  (ref) => ref
      .watch(jsonPreferencesProvider)
      .watch(appLockKey)
      .map((json) => readJson(json, 'enabled', false)),
);

/// The phone's fingerprint, face or screen lock (overridden in tests).
final localAuthProvider = Provider<LocalAuthentication>(
  (ref) => LocalAuthentication(),
);

/// Turns app lock on (after one successful unlock, so nobody locks
/// themselves out with a phone that has no screen lock) or off.
Future<void> setAppLock(
  BuildContext context,
  WidgetRef ref, {
  required bool enabled,
}) async {
  final l10n = AppLocalizations.of(context);
  if (enabled) {
    final auth = ref.read(localAuthProvider);
    var ok = false;
    try {
      if (!await auth.isDeviceSupported()) {
        if (context.mounted) {
          showMessageSnackBar(context, l10n.appLockNoScreenLock);
        }
        return;
      }
      ok = await auth.authenticate(localizedReason: l10n.appLockReason);
    } on LocalAuthException catch (e) {
      if (context.mounted) {
        showMessageSnackBar(
          context,
          e.code == LocalAuthExceptionCode.noCredentialsSet
              ? l10n.appLockNoScreenLock
              : l10n.appLockFailed,
        );
      }
      return;
    }
    if (!ok) return;
  }
  await ref.read(jsonPreferencesProvider).write(appLockKey, {
    'enabled': enabled,
  });
}

/// Covers the app until the phone's lock is passed, at launch and when
/// coming back after [_grace] away. Without app lock it's just [child].
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> {
  /// Away for less than this (a quick look at another app, the share sheet,
  /// the unlock prompt itself) doesn't lock again.
  static const _grace = Duration(seconds: 30);

  late bool _locked = ref.read(initialAppLockProvider);
  late final AppLifecycleListener _lifecycle;
  DateTime? _leftAt;
  bool _asking = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onHide: () => _leftAt ??= DateTime.now(),
      onShow: _cameBack,
    );
    if (_locked) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
    }
    unawaited(_hideInRecents(_enabled));
  }

  static const _privacy = MethodChannel('daylog/privacy');

  /// With app lock on, the app switcher shows no thumbnail of your day.
  Future<void> _hideInRecents(bool hide) async {
    try {
      await _privacy.invokeMethod<void>('hideInRecents', {'hide': hide});
    } on MissingPluginException {
      // Not Android (or a test): nothing to hide.
    } on PlatformException {
      // Best effort.
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  bool get _enabled =>
      ref.read(appLockEnabledProvider).value ??
      ref.read(initialAppLockProvider);

  void _cameBack() {
    final left = _leftAt;
    _leftAt = null;
    if (!_enabled || _asking) return;
    // Still locked from before (the prompt was dismissed or went away
    // with the app): ask again.
    if (_locked) {
      unawaited(_unlock());
      return;
    }
    if (left == null || DateTime.now().difference(left) < _grace) return;
    setState(() => _locked = true);
    unawaited(_unlock());
  }

  Future<void> _unlock() async {
    if (_asking || !mounted) return;
    _asking = true;
    final l10n = AppLocalizations.of(context);
    try {
      final ok = await ref
          .read(localAuthProvider)
          // Not kept across backgrounding: the plugin would re-show its own
          // prompt on return, outside this gate's control. Coming back
          // asks again instead (_cameBack).
          .authenticate(localizedReason: l10n.appLockReason);
      if (ok && mounted) setState(() => _locked = false);
    } on LocalAuthException catch (e) {
      // No screen lock any more: there's nothing to unlock with, so don't
      // keep the person out of their own data.
      if (e.code == LocalAuthExceptionCode.noCredentialsSet && mounted) {
        setState(() => _locked = false);
      }
    } finally {
      _asking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only passing the phone's lock unlocks: the setting can only be
    // turned off from inside the app (already unlocked), and a value read
    // mid-change (a restore) must never open it.
    ref.listen(appLockEnabledProvider, (_, next) {
      if (next.value case final on?) unawaited(_hideInRecents(on));
    });
    return Stack(
      children: [
        // Kept alive (where you were stays), but hidden from screen readers
        // and accessibility services while locked.
        ExcludeSemantics(excluding: _locked, child: widget.child),
        if (_locked) Positioned.fill(child: _LockedView(onUnlock: _unlock)),
      ],
    );
  }
}

class _LockedView extends StatelessWidget {
  const _LockedView({required this.onUnlock});

  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Material(
      color: c.surfaceCanvas,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: c.brandPrimarySoft,
                  borderRadius: AppRadius.lgAll,
                ),
                alignment: Alignment.center,
                child: Icon(AppIcons.appLock, size: 44, color: c.brandPrimary),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                l10n.appLockLockedTitle,
                textAlign: TextAlign.center,
                style: context.textStyles.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.appLockLockedBody,
                textAlign: TextAlign.center,
                style: context.textStyles.bodyMedium?.copyWith(
                  color: c.textSecondary,
                ),
              ),
              const Spacer(),
              AppButton(
                label: l10n.appLockUnlock,
                icon: AppIcons.appLock,
                expand: true,
                onPressed: onUnlock,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
