import 'package:flutter/material.dart';

import '../core/design/app_theme.dart';
import '../core/design/context_ext.dart';
import '../core/design/tokens/spacing.dart';
import '../features/settings/domain/preferences_snapshot.dart';
import '../shared/widgets/app_logo.dart';
import 'launch_theme_cache.dart';

/// Shown while the app opens its database: the logo animating in the
/// theme last used (its strands draw in, then the pulse travels the loop),
/// and the name fading up beneath it.
class LaunchSplash extends StatelessWidget {
  const LaunchSplash({super.key, this.look = const LaunchTheme()});

  final LaunchTheme look;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.of(look.theme),
    darkTheme: AppTheme.of(
      look.theme,
      brightness: Brightness.dark,
      trueBlack: look.trueBlack,
    ),
    themeMode: switch (look.appearance) {
      AppearanceMode.system => ThemeMode.system,
      AppearanceMode.light => ThemeMode.light,
      AppearanceMode.dark => ThemeMode.dark,
    },
    home: const _SplashScreen(),
  );
}

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late final _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.45, 1, curve: Curves.easeOut),
    );
    return Scaffold(
      backgroundColor: c.surfaceCanvas,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AnimatedAppLogo(size: 168),
            const SizedBox(height: AppSpacing.lg),
            FadeTransition(
              opacity: fade,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(fade),
                child: Text(
                  appBrandName,
                  style: context.textStyles.headlineSmall?.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
