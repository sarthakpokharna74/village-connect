import 'package:flutter/material.dart';

/// Centralized color palette for the GramConnect application.
/// Uses a warm, organic earth-inspired color palette designed for high contrast and readability.
class AppColors {
  AppColors._();

  // --- Light Palette ---
  static const Color primaryLight = Color(0xFF1B5E20);      // Forest Green
  static const Color onPrimaryLight = Colors.white;
  static const Color primaryContainerLight = Color(0xFFC8E6C9); // Soft Sage Green
  static const Color onPrimaryContainerLight = Color(0xFF002105);

  static const Color secondaryLight = Color(0xFFD84315);    // Terracotta Clay
  static const Color onSecondaryLight = Colors.white;
  static const Color secondaryContainerLight = Color(0xFFFFCCBC); // Warm Clay Cream
  static const Color onSecondaryContainerLight = Color(0xFF3D0C00);

  static const Color tertiaryLight = Color(0xFF00796B);     // Deep Teal Water
  static const Color onTertiaryLight = Colors.white;

  static const Color backgroundLight = Color(0xFFFAF8F5);   // Warm Ivory/Off-White
  static const Color onBackgroundLight = Color(0xFF1B1C1A);
  static const Color surfaceLight = Color(0xFFFFFFFF);      // Clean White Card
  static const Color onSurfaceLight = Color(0xFF1B1C1A);
  static const Color surfaceVariantLight = Color(0xFFF1EDE6); // Slightly darker ivory for contrast
  static const Color onSurfaceVariantLight = Color(0xFF4C473E);

  static const Color errorLight = Color(0xFFC62828);        // Clear Alert Red
  static const Color onErrorLight = Colors.white;

  static const Color shadowLight = Color(0x0A000000);
  static const Color outlineLight = Color(0xFF817767);

  // --- Dark Palette ---
  static const Color primaryDark = Color(0xFF81C784);       // Light Sage Green
  static const Color onPrimaryDark = Color(0xFF00330E);
  static const Color primaryContainerDark = Color(0xFF00531B);
  static const Color onPrimaryContainerDark = Color(0xFFC8E6C9);

  static const Color secondaryDark = Color(0xFFFF8A65);     // Soft Terracotta
  static const Color onSecondaryDark = Color(0xFF4E1A00);
  static const Color secondaryContainerDark = Color(0xFF7E2A00);
  static const Color onSecondaryContainerDark = Color(0xFFFFCCBC);

  static const Color tertiaryDark = Color(0xFF4DB6AC);       // Light Teal
  static const Color onTertiaryDark = Color(0xFF003730);

  static const Color backgroundDark = Color(0xFF121411);     // Organic Deep Black
  static const Color onBackgroundDark = Color(0xFFE3E3DC);
  static const Color surfaceDark = Color(0xFF191C18);        // Deep Forest Slate Card
  static const Color onSurfaceDark = Color(0xFFE3E3DC);
  static const Color surfaceVariantDark = Color(0xFF2C2F29);
  static const Color onSurfaceVariantDark = Color(0xFFCFC6B8);

  static const Color errorDark = Color(0xFFE57373);
  static const Color onErrorDark = Color(0xFF600004);

  static const Color shadowDark = Color(0x33000000);
  static const Color outlineDark = Color(0xFF998F80);

  // --- Utility & Feature Colors ---
  static const Color noticeAmber = Color(0xFFF57C00);       // Notices / Alert Orange
  static const Color eventPurple = Color(0xFF673AB7);       // Festivals / Events Purple
  static const Color agriBrown = Color(0xFF8D6E63);         // Agriculture Brown
  static const Color emergencyRed = Color(0xFFD32F2F);      // Emergency Contacts Red
  static const Color infoBlue = Color(0xFF1976D2);          // Government Info Blue
}
