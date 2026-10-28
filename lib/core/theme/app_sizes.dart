
/// Centralized layout, padding, spacing, and shape tokens.
/// Standardizes the interface metrics and guarantees accessibility compliance (e.g. minimum 48dp tap target).
class AppSizes {
  AppSizes._();

  // --- Spacing & Padding ---
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;

  // --- Border Radii ---
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 32.0;

  // --- Card & Button Heights ---
  static const double btnHeightNormal = 48.0;
  static const double btnHeightLarge = 56.0;   // Recommended default for main action buttons
  static const double touchTargetMin = 48.0;   // Accessibility standard

  // --- Icon Sizes ---
  static const double iconSM = 16.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 40.0;           // Used in large feature grids
  static const double iconXXL = 48.0;          // Used for focus dashboard items

  // --- Common Card Dimensions ---
  static const double featureCardMinHeight = 110.0;
  static const double featureCardIconSize = 40.0;

  // --- Elevation ---
  static const double elevationLow = 1.0;
  static const double elevationNormal = 2.0;
  static const double elevationHigh = 4.0;

  // --- Layout Helper Grids ---
  static const double mobileMaxGridWidth = 600.0;
}
