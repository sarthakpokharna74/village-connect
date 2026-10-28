import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_sizes.dart';

/// Application theme configurations for Light and Dark modes.
/// Fully conforms to Material 3 styling and accessibility guidelines.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final colorScheme = const ColorScheme.light(
      primary: AppColors.primaryLight,
      onPrimary: AppColors.onPrimaryLight,
      primaryContainer: AppColors.primaryContainerLight,
      onPrimaryContainer: AppColors.onPrimaryContainerLight,
      secondary: AppColors.secondaryLight,
      onSecondary: AppColors.onSecondaryLight,
      secondaryContainer: AppColors.secondaryContainerLight,
      onSecondaryContainer: AppColors.onSecondaryContainerLight,
      tertiary: AppColors.tertiaryLight,
      onTertiary: AppColors.onTertiaryLight,
      error: AppColors.errorLight,
      onError: AppColors.onErrorLight,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.onSurfaceLight,
      surfaceContainerHighest: AppColors.surfaceVariantLight,
      onSurfaceVariant: AppColors.onSurfaceVariantLight,
      outline: AppColors.outlineLight,
      shadow: AppColors.shadowLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: AppTypography.createTextTheme(AppColors.onBackgroundLight),
      
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.onPrimaryLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.createTextTheme(AppColors.onPrimaryLight).titleMedium,
        iconTheme: const IconThemeData(color: AppColors.onPrimaryLight, size: AppSizes.iconMD),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: AppSizes.elevationLow,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          side: const BorderSide(
            color: AppColors.surfaceVariantLight,
            width: 1.0,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.onPrimaryLight,
          minimumSize: const Size.fromHeight(AppSizes.btnHeightLarge),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
          textStyle: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          elevation: AppSizes.elevationLow,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          minimumSize: const Size(double.minPositive, AppSizes.touchTargetMin),
          textStyle: const TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.surfaceVariantLight,
        thickness: 1.0,
        space: AppSizes.space16,
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: AppTypography.createTextTheme(AppColors.onSurfaceLight).bodyLarge,
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(AppColors.surfaceLight),
          elevation: WidgetStateProperty.all(AppSizes.elevationHigh),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = const ColorScheme.dark(
      primary: AppColors.primaryDark,
      onPrimary: AppColors.onPrimaryDark,
      primaryContainer: AppColors.primaryContainerDark,
      onPrimaryContainer: AppColors.onPrimaryContainerDark,
      secondary: AppColors.secondaryDark,
      onSecondary: AppColors.onSecondaryDark,
      secondaryContainer: AppColors.secondaryContainerDark,
      onSecondaryContainer: AppColors.onSecondaryContainerDark,
      tertiary: AppColors.tertiaryDark,
      onTertiary: AppColors.onTertiaryDark,
      error: AppColors.errorDark,
      onError: AppColors.onErrorDark,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.onSurfaceDark,
      surfaceContainerHighest: AppColors.surfaceVariantDark,
      onSurfaceVariant: AppColors.onSurfaceVariantDark,
      outline: AppColors.outlineDark,
      shadow: AppColors.shadowDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: AppTypography.createTextTheme(AppColors.onBackgroundDark),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.onSurfaceDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.createTextTheme(AppColors.onSurfaceDark).titleMedium,
        iconTheme: const IconThemeData(color: AppColors.onSurfaceDark, size: AppSizes.iconMD),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          side: const BorderSide(
            color: AppColors.surfaceVariantDark,
            width: 1.0,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.onPrimaryDark,
          minimumSize: const Size.fromHeight(AppSizes.btnHeightLarge),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
          textStyle: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          minimumSize: const Size(double.minPositive, AppSizes.touchTargetMin),
          textStyle: const TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.surfaceVariantDark,
        thickness: 1.0,
        space: AppSizes.space16,
      ),
    );
  }
}
