import 'package:flutter/material.dart';

/// Verification state of a government service listing.
enum ServiceVerificationStatus {
  verified,
  pending,
  unverified;

  String get translationKey {
    switch (this) {
      case ServiceVerificationStatus.verified:
        return 'gov_status_verified';
      case ServiceVerificationStatus.pending:
        return 'gov_status_pending';
      case ServiceVerificationStatus.unverified:
        return 'gov_status_unverified';
    }
  }

  Color get color {
    switch (this) {
      case ServiceVerificationStatus.verified:
        return const Color(0xFF2E7D32); // Forest Green
      case ServiceVerificationStatus.pending:
        return const Color(0xFFE65100); // Amber / Orange
      case ServiceVerificationStatus.unverified:
        return const Color(0xFF757575); // Grey
    }
  }

  IconData get icon {
    switch (this) {
      case ServiceVerificationStatus.verified:
        return Icons.verified_rounded;
      case ServiceVerificationStatus.pending:
        return Icons.hourglass_top_rounded;
      case ServiceVerificationStatus.unverified:
        return Icons.help_outline_rounded;
    }
  }
}

/// Metadata representation for the 10 Blueprint 7 government service categories.
class ServiceCategoryInfo {
  final String id;
  final String nameKey;
  final String descriptionKey;
  final IconData icon;
  final Color color;

  const ServiceCategoryInfo({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    required this.icon,
    required this.color,
  });

  /// The 10 official categories specified in Blueprint 7.
  static const List<ServiceCategoryInfo> allCategories = [
    ServiceCategoryInfo(
      id: 'identity_certificates',
      nameKey: 'gov_cat_identity_certificates',
      descriptionKey: 'gov_cat_desc_identity_certificates',
      icon: Icons.badge_rounded,
      color: Color(0xFF1E88E5), // Blue
    ),
    ServiceCategoryInfo(
      id: 'revenue_land_records',
      nameKey: 'gov_cat_revenue_land_records',
      descriptionKey: 'gov_cat_desc_revenue_land_records',
      icon: Icons.landscape_rounded,
      color: Color(0xFF6D4C41), // Brown
    ),
    ServiceCategoryInfo(
      id: 'agriculture_farmers',
      nameKey: 'gov_cat_agriculture_farmers',
      descriptionKey: 'gov_cat_desc_agriculture_farmers',
      icon: Icons.agriculture_rounded,
      color: Color(0xFF2E7D32), // Green
    ),
    ServiceCategoryInfo(
      id: 'health_family_welfare',
      nameKey: 'gov_cat_health_family_welfare',
      descriptionKey: 'gov_cat_desc_health_family_welfare',
      icon: Icons.health_and_safety_rounded,
      color: Color(0xFFD32F2F), // Red
    ),
    ServiceCategoryInfo(
      id: 'education_scholarships',
      nameKey: 'gov_cat_education_scholarships',
      descriptionKey: 'gov_cat_desc_education_scholarships',
      icon: Icons.school_rounded,
      color: Color(0xFF7B1FA2), // Purple
    ),
    ServiceCategoryInfo(
      id: 'pension_social_welfare',
      nameKey: 'gov_cat_pension_social_welfare',
      descriptionKey: 'gov_cat_desc_pension_social_welfare',
      icon: Icons.elderly_rounded,
      color: Color(0xFF00897B), // Teal
    ),
    ServiceCategoryInfo(
      id: 'employment_skills',
      nameKey: 'gov_cat_employment_skills',
      descriptionKey: 'gov_cat_desc_employment_skills',
      icon: Icons.work_rounded,
      color: Color(0xFFF57C00), // Orange
    ),
    ServiceCategoryInfo(
      id: 'ration_public_distribution',
      nameKey: 'gov_cat_ration_public_distribution',
      descriptionKey: 'gov_cat_desc_ration_public_distribution',
      icon: Icons.inventory_2_rounded,
      color: Color(0xFFC2185B), // Pink
    ),
    ServiceCategoryInfo(
      id: 'electricity_water',
      nameKey: 'gov_cat_electricity_water',
      descriptionKey: 'gov_cat_desc_electricity_water',
      icon: Icons.bolt_rounded,
      color: Color(0xFF0288D1), // Light Blue
    ),
    ServiceCategoryInfo(
      id: 'gram_panchayat_services',
      nameKey: 'gov_cat_gram_panchayat_services',
      descriptionKey: 'gov_cat_desc_gram_panchayat_services',
      icon: Icons.holiday_village_rounded,
      color: Color(0xFF455A64), // Blue Grey
    ),
  ];

  static IconData getIconForCategory(String categoryId) {
    for (final cat in allCategories) {
      if (cat.id == categoryId) return cat.icon;
    }
    return Icons.miscellaneous_services_rounded;
  }

  static Color getColorForCategory(String categoryId) {
    for (final cat in allCategories) {
      if (cat.id == categoryId) return cat.color;
    }
    return const Color(0xFF546E7A);
  }
}

/// Comprehensive model for a Government Service in GramConnect (Blueprint 7).
class GovernmentService {
  final String id;
  final String nameKey;
  final String category;
  final String shortDescriptionKey;
  final String detailedDescriptionKey;
  final String departmentKey;
  final String eligibilityKey;
  final List<String> requiredDocsKeys;
  final List<String> applicationStepsKeys;
  final bool isOnlineAvailable;
  final bool isOfflineAvailable;
  final String applicationMethodKey;
  final String? officialWebsiteUrl;
  final String? officialInformationUrl;
  final String? sourceName;
  final String? feesKey;
  final String? timelineKey;
  final ServiceVerificationStatus verificationStatus;
  final String? lastVerifiedAt;

  const GovernmentService({
    required this.id,
    required this.nameKey,
    required this.category,
    required this.shortDescriptionKey,
    required this.detailedDescriptionKey,
    required this.departmentKey,
    required this.eligibilityKey,
    required this.requiredDocsKeys,
    required this.applicationStepsKeys,
    required this.isOnlineAvailable,
    required this.isOfflineAvailable,
    required this.applicationMethodKey,
    this.officialWebsiteUrl,
    this.officialInformationUrl,
    this.sourceName,
    this.feesKey,
    this.timelineKey,
    this.verificationStatus = ServiceVerificationStatus.verified,
    this.lastVerifiedAt,
  });

  Color get categoryColor => ServiceCategoryInfo.getColorForCategory(category);
  IconData get categoryIcon => ServiceCategoryInfo.getIconForCategory(category);

  // Backward-compatibility getters for legacy components
  String get explanationKey => shortDescriptionKey;
  String get methodKey => applicationMethodKey;
  String get website => officialWebsiteUrl ?? '';

  static IconData getIconForCategory(String category) =>
      ServiceCategoryInfo.getIconForCategory(category);

  static Color getColorForCategory(String category) =>
      ServiceCategoryInfo.getColorForCategory(category);
}

/// Alias for backward compatibility with previous prototype references.
typedef GovServiceItem = GovernmentService;
