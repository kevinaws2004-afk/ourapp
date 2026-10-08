import 'package:flutter/material.dart';

import 'app_tokens.dart';
import 'themes/app_theme_id.dart';
import 'tokens/color_tokens.dart';
import 'tokens/radius.dart';
import 'tokens/spacing.dart';
import 'tokens/typography.dart';

/// Builds each theme's [ThemeData] entirely from its design tokens, so any
/// remaining Material widget inherits the product identity
/// (design_system.md §15). All themes are light (ADR-045).
abstract final class AppTheme {
  static final Map<AppThemeId, ThemeData> _cache = {};

  static ThemeData of(AppThemeId id) =>
      _cache.putIfAbsent(id, () => _build(AppTokens.of(id)));

  static ThemeData _build(AppTokens tokens) {
    final c = tokens.colors;
    final textTheme = AppTypography.textTheme(c.textPrimary);

    final scheme = ColorScheme(
      brightness: Brightness.light,
      primary: c.brandPrimary,
      onPrimary: c.onBrandPrimary,
      primaryContainer: c.brandPrimarySoft,
      onPrimaryContainer: c.onBrandPrimarySoft,
      secondary: c.action,
      onSecondary: c.onAction,
      secondaryContainer: c.actionSoft,
      onSecondaryContainer: c.onActionSoft,
      tertiary: c.accent,
      onTertiary: c.surfaceBase,
      tertiaryContainer: c.accentSoft,
      onTertiaryContainer: c.onAccentSoft,
      error: c.danger,
      onError: c.surfaceRaised,
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
      shadow: c.scrim.withValues(alpha: 1),
      scrim: c.scrim,
      inverseSurface: c.textPrimary,
      onInverseSurface: c.surfaceBase,
      inversePrimary: c.brandPrimarySoft,
      surfaceTint: Colors.transparent,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.surfaceCanvas,
      canvasColor: c.surfaceCanvas,
      fontFamily: AppTypography.family,
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
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        indicatorColor: c.brandPrimarySoft,
        indicatorShape: const StadiumBorder(),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => AppTypography.labelMedium.copyWith(
            color: states.contains(WidgetState.selected)
                ? c.onBrandPrimarySoft
                : c.textSecondary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? c.brandPrimary
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
        elevation: 0,
        highlightElevation: 0,
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
          side: BorderSide(color: c.borderSubtle, width: 1.5),
          foregroundColor: c.textPrimary,
          backgroundColor: c.surfaceBase,
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
          selectedBackgroundColor: c.surfaceBase,
          selectedForegroundColor: c.brandPrimary,
          foregroundColor: c.textSecondary,
          side: BorderSide(color: c.surfaceSunken),
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
        backgroundColor: c.textPrimary,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: c.surfaceBase,
        ),
        actionTextColor: c.brandPrimarySoft,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      ),
      // Inputs are soft pill wells; focus draws the theme's color (ADR-045).
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceSunken,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        hintStyle: AppTypography.bodyLarge.copyWith(color: c.textTertiary),
        labelStyle: AppTypography.bodyMedium.copyWith(color: c.textSecondary),
        floatingLabelStyle: AppTypography.labelMedium.copyWith(
          color: c.brandPrimary,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.lgAll,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.lgAll,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgAll,
          borderSide: BorderSide(color: c.brandPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgAll,
          borderSide: BorderSide(color: c.danger, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgAll,
          borderSide: BorderSide(color: c.danger, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceBase,
        selectedColor: c.brandPrimarySoft,
        side: BorderSide(color: c.borderSubtle),
        shape: const StadiumBorder(),
        labelStyle: AppTypography.labelMedium.copyWith(color: c.textPrimary),
        secondaryLabelStyle: AppTypography.labelMedium.copyWith(
          color: c.onBrandPrimarySoft,
        ),
        iconTheme: IconThemeData(color: c.brandPrimary, size: 18),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        textStyle: AppTypography.bodyLarge.copyWith(color: c.textPrimary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surfaceBase,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: c.scrim,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
        showDragHandle: true,
        dragHandleColor: c.borderSubtle,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.cardAll),
        titleTextStyle: AppTypography.headlineSmall.copyWith(
          color: c.textPrimary,
        ),
        contentTextStyle: AppTypography.bodyLarge.copyWith(
          color: c.textSecondary,
        ),
      ),
      // The pickers match the app instead of stock Material (A26).
      datePickerTheme: _datePicker(c),
      timePickerTheme: _timePicker(c),
    );
  }

  /// Selected = brand; everything else neutral.
  static WidgetStateProperty<Color?> _selected(Color on, Color off) =>
      WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? on : off,
      );

  /// [_selected] for theme slots that take a state-aware [Color].
  static Color _selectedColor(Color on, Color off) =>
      WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected) ? on : off,
      );

  static DatePickerThemeData _datePicker(AppColors c) => DatePickerThemeData(
    backgroundColor: c.surfaceRaised,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
    headerBackgroundColor: c.surfaceRaised,
    headerForegroundColor: c.textPrimary,
    headerHeadlineStyle: AppTypography.headlineSmall.copyWith(
      color: c.textPrimary,
    ),
    headerHelpStyle: AppTypography.labelLarge.copyWith(color: c.textSecondary),
    weekdayStyle: AppTypography.labelMedium.copyWith(color: c.textSecondary),
    dayStyle: AppTypography.bodyMedium,
    dayForegroundColor: _selected(c.onBrandPrimary, c.textPrimary),
    dayBackgroundColor: _selected(c.brandPrimary, Colors.transparent),
    todayForegroundColor: _selected(c.onBrandPrimary, c.brandPrimary),
    todayBackgroundColor: _selected(c.brandPrimary, Colors.transparent),
    todayBorder: BorderSide(color: c.brandPrimary),
    yearForegroundColor: _selected(c.onBrandPrimary, c.textPrimary),
    yearBackgroundColor: _selected(c.brandPrimary, Colors.transparent),
    dividerColor: c.borderSubtle,
    rangePickerBackgroundColor: c.surfaceRaised,
    rangeSelectionBackgroundColor: c.brandPrimarySoft,
  );

  static TimePickerThemeData _timePicker(AppColors c) => TimePickerThemeData(
    backgroundColor: c.surfaceRaised,
    elevation: 0,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
    helpTextStyle: AppTypography.labelLarge.copyWith(color: c.textSecondary),
    hourMinuteColor: _selectedColor(c.brandPrimarySoft, c.surfaceSunken),
    hourMinuteTextColor: _selectedColor(c.onBrandPrimarySoft, c.textPrimary),
    hourMinuteTextStyle: AppTypography.numericLarge,
    hourMinuteShape: const RoundedRectangleBorder(
      borderRadius: AppRadius.mdAll,
    ),
    // AM/PM in brand soft, not the coral accent the scheme would give it.
    dayPeriodColor: _selectedColor(c.brandPrimarySoft, Colors.transparent),
    dayPeriodTextColor: _selectedColor(c.onBrandPrimarySoft, c.textSecondary),
    dayPeriodBorderSide: BorderSide(color: c.borderStrong),
    dayPeriodShape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
    dayPeriodTextStyle: AppTypography.labelLarge,
    dialBackgroundColor: c.surfaceSunken,
    dialHandColor: c.brandPrimary,
    dialTextColor: _selectedColor(c.onBrandPrimary, c.textPrimary),
    dialTextStyle: AppTypography.bodyLarge,
    entryModeIconColor: c.textSecondary,
    timeSelectorSeparatorColor: WidgetStatePropertyAll(c.textSecondary),
  );
}
