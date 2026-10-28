import 'package:flutter/material.dart';

/// Centralized typography guidelines for the GramConnect application.
/// Optimized for readability, with slightly larger sizes and generous line heights
/// to assist users with varying visual capabilities and technical literacy.
class AppTypography {
  AppTypography._();

  // Font family fallbacks (uses standard system fonts for maximum compatibility/performance)
  static const String _fontFamily = 'Roboto';

  static TextStyle _base({
    required double size,
    required FontWeight weight,
    required double height,
    double spacing = 0.0,
    required Color color,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: spacing,
      color: color,
    );
  }

  // Generate a complete TextTheme matching Material 3 spec
  static TextTheme createTextTheme(Color textColor) {
    return TextTheme(
      displayLarge: _base(
        size: 34.0,
        weight: FontWeight.bold,
        height: 1.15,
        spacing: -0.5,
        color: textColor,
      ),
      displayMedium: _base(
        size: 28.0,
        weight: FontWeight.bold,
        height: 1.2,
        color: textColor,
      ),
      headlineMedium: _base(
        size: 24.0,
        weight: FontWeight.w600,
        height: 1.25,
        color: textColor,
      ),
      titleLarge: _base(
        size: 20.0,
        weight: FontWeight.bold,
        height: 1.3,
        spacing: 0.15,
        color: textColor,
      ),
      titleMedium: _base(
        size: 18.0,
        weight: FontWeight.w600,
        height: 1.35,
        spacing: 0.1,
        color: textColor,
      ),
      titleSmall: _base(
        size: 16.0,
        weight: FontWeight.w600,
        height: 1.35,
        spacing: 0.1,
        color: textColor,
      ),
      bodyLarge: _base(
        size: 16.0,
        weight: FontWeight.normal,
        height: 1.5,
        spacing: 0.5,
        color: textColor,
      ),
      bodyMedium: _base(
        size: 14.0,
        weight: FontWeight.normal,
        height: 1.5,
        spacing: 0.25,
        color: textColor,
      ),
      labelLarge: _base(
        size: 16.0, // Enlarged from standard 14 for visibility on buttons
        weight: FontWeight.bold,
        height: 1.2,
        spacing: 1.0,
        color: textColor,
      ),
      labelMedium: _base(
        size: 13.0,
        weight: FontWeight.w500,
        height: 1.2,
        spacing: 0.5,
        color: textColor,
      ),
    );
  }
}
