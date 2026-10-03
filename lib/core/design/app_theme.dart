import 'package:flutter/material.dart';

import 'app_tokens.dart';
import 'tokens/color_tokens.dart';
import 'tokens/radius.dart';
import 'tokens/spacing.dart';
import 'tokens/typography.dart';

/// Builds the light and dark [ThemeData] entirely from design tokens, so any
/// remaining Material widget inherits the product identity
/// (design_system.md §15).
abstract final class AppTheme {
  static final ThemeData light = _build(AppTokens.light);
  static final ThemeData dark = _build(AppTokens.dark);

  static ThemeData _build(AppTokens tokens) {
    final c = tokens.colors;
    final isLight = tokens.brightness == Brightness.light;
    final textTheme = AppTypography.textTheme(c.textPrimary);

    final scheme = ColorScheme(
      brightness: tokens.brightness,
      primary: c.brandPrimary,
      onPrimary: c.onBrandPrimary,
      primaryContainer: c.brandPrimarySoft,
      onPrimaryContainer: c.onBrandPrimarySoft,
      secondary: c.brandPrimary,
      onSecondary: c.onBrandPrimary,
      secondaryContainer: c.brandPrimarySoft,
      onSecondaryContainer: c.onBrandPrimarySoft,
      tertiary: c.accentDawn,
      onTertiary: c.textPrimary,
      error: c.danger,
      onError: isLight ? c.surfaceRaised : c.surfaceCanvas,
      errorContainer: c.dangerContainer,
      onErrorContainer: c.textPrimary,
      surface: c.surfaceBase,
      onSurface: c.textPrimary,
      onSurfaceVariant: c.textSecondary,
      surfaceContainerLowest: c.surfaceCanvas,
      surfaceContainerLow: c.surfaceBase,
      surfaceContainer: c.surfaceBase,
      surfaceContainerHigh: c.surfaceRaised,
      surfaceContainerHighest: c.surfaceSunken,
      outline: c.borderStrong,
      outlineVariant: c.borderSubtle,
      shadow: const Color(0xFF000000),
      scrim: c.scrim,
      inverseSurface: isLight
          ? AppColors.dark.surfaceBase
          : AppColors.light.surfaceBase,
      onInverseSurface: isLight
          ? AppColors.dark.textPrimary
          : AppColors.light.textPrimary,
      inversePrimary: isLight
          ? AppColors.dark.brandPrimary
          : AppColors.light.brandPrimary,
      surfaceTint: Colors.transparent,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: tokens.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.surfaceCanvas,
      canvasColor: c.surfaceCanvas,
      fontFamily: AppTypography.uiFamily,
      textTheme: textTheme,
      extensions: [tokens],
      splashFactory: InkRipple.splashFactory,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      dividerTheme: DividerThemeData(
        color: c.borderSubtle,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(color: c.textSecondary, size: 24),
      appBarTheme: AppBarTheme(
        backgroundColor: c.surfaceCanvas,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLarge.copyWith(color: c.textPrimary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surfaceBase,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        indicatorColor: c.brandPrimarySoft,
        indicatorShape: const StadiumBorder(),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => AppTypography.labelMedium.copyWith(
            color: states.contains(WidgetState.selected)
                ? c.textPrimary
                : c.textSecondary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? c.onBrandPrimarySoft
                : c.textSecondary,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: c.surfaceBase,
        elevation: 0,
        indicatorColor: c.brandPrimarySoft,
        indicatorShape: const StadiumBorder(),
        labelType: NavigationRailLabelType.all,
        selectedIconTheme: IconThemeData(color: c.onBrandPrimarySoft),
        unselectedIconTheme: IconThemeData(color: c.textSecondary),
        selectedLabelTextStyle: AppTypography.labelMedium.copyWith(
          color: c.textPrimary,
        ),
        unselectedLabelTextStyle: AppTypography.labelMedium.copyWith(
          color: c.textSecondary,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.brandPrimary,
        foregroundColor: c.onBrandPrimary,
        elevation: 2,
        highlightElevation: 2,
        shape: const StadiumBorder(),
        extendedTextStyle: AppTypography.labelLarge,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          shape: const StadiumBorder(),
          textStyle: AppTypography.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          shape: const StadiumBorder(),
          side: BorderSide(color: c.borderStrong),
          foregroundColor: c.textPrimary,
          textStyle: AppTypography.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: const StadiumBorder(),
          foregroundColor: c.brandPrimary,
          textStyle: AppTypography.labelLarge,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: c.surfaceSunken,
          selectedBackgroundColor: c.brandPrimarySoft,
          selectedForegroundColor: c.onBrandPrimarySoft,
          foregroundColor: c.textSecondary,
          side: BorderSide(color: c.borderSubtle),
          textStyle: AppTypography.labelMedium,
          minimumSize: const Size(48, 48),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: c.textSecondary,
        textColor: c.textPrimary,
        titleTextStyle: AppTypography.titleMedium.copyWith(
          color: c.textPrimary,
        ),
        subtitleTextStyle: AppTypography.bodyMedium.copyWith(
          color: c.textSecondary,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isLight
            ? AppColors.dark.surfaceRaised
            : AppColors.light.surfaceRaised,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: isLight
              ? AppColors.dark.textPrimary
              : AppColors.light.textPrimary,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surfaceBase,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: c.scrim,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
        showDragHandle: true,
        dragHandleColor: c.borderStrong,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        titleTextStyle: AppTypography.headlineSmall.copyWith(
          color: c.textPrimary,
        ),
        contentTextStyle: AppTypography.bodyLarge.copyWith(
          color: c.textSecondary,
        ),
      ),
    );
  }
}
