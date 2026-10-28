import 'package:flutter/material.dart';

/// 10 Blueprint 10 Agriculture Categories for Dhawalpuri
class AgriCategoryInfo {
  final String key;
  final String titleKey;
  final String descKey;
  final IconData icon;
  final Color color;

  const AgriCategoryInfo({
    required this.key,
    required this.titleKey,
    required this.descKey,
    required this.icon,
    required this.color,
  });

  static const List<AgriCategoryInfo> categories = [
    AgriCategoryInfo(
      key: 'crop_info',
      titleKey: 'cat_agri_crop_info',
      descKey: 'cat_agri_crop_info_desc',
      icon: Icons.grass_rounded,
      color: Color(0xFF2E7D32), // Forest Green
    ),
    AgriCategoryInfo(
      key: 'seasonal_guide',
      titleKey: 'cat_agri_seasonal_guide',
      descKey: 'cat_agri_seasonal_guide_desc',
      icon: Icons.calendar_month_rounded,
      color: Color(0xFF00796B), // Teal
    ),
    AgriCategoryInfo(
      key: 'soil_fertilizers',
      titleKey: 'cat_agri_soil_fertilizers',
      descKey: 'cat_agri_soil_fertilizers_desc',
      icon: Icons.landscape_rounded,
      color: Color(0xFF6D4C41), // Rich Earth Brown
    ),
    AgriCategoryInfo(
      key: 'irrigation_water',
      titleKey: 'cat_agri_irrigation_water',
      descKey: 'cat_agri_irrigation_water_desc',
      icon: Icons.water_drop_rounded,
      color: Color(0xFF0277BD), // Blue
    ),
    AgriCategoryInfo(
      key: 'pest_disease',
      titleKey: 'cat_agri_pest_disease',
      descKey: 'cat_agri_pest_disease_desc',
      icon: Icons.pest_control_rounded,
      color: Color(0xFFC62828), // Red
    ),
    AgriCategoryInfo(
      key: 'weather_info',
      titleKey: 'cat_agri_weather_info',
      descKey: 'cat_agri_weather_info_desc',
      icon: Icons.wb_cloudy_rounded,
      color: Color(0xFF1565C0), // Sky Blue
    ),
    AgriCategoryInfo(
      key: 'agri_schemes',
      titleKey: 'cat_agri_schemes',
      descKey: 'cat_agri_schemes_desc',
      icon: Icons.account_balance_rounded,
      color: Color(0xFF558B2F), // Green
    ),
    AgriCategoryInfo(
      key: 'market_prices',
      titleKey: 'cat_agri_market_prices',
      descKey: 'cat_agri_market_prices_desc',
      icon: Icons.storefront_rounded,
      color: Color(0xFFE65100), // Orange/Amber
    ),
    AgriCategoryInfo(
      key: 'equipment_services',
      titleKey: 'cat_agri_equipment_services',
      descKey: 'cat_agri_equipment_services_desc',
      icon: Icons.precision_manufacturing_rounded,
      color: Color(0xFF455A64), // Blue Grey
    ),
    AgriCategoryInfo(
      key: 'farmer_resources_contacts',
      titleKey: 'cat_agri_farmer_contacts',
      descKey: 'cat_agri_farmer_contacts_desc',
      icon: Icons.support_agent_rounded,
      color: Color(0xFF6A1B9A), // Purple
    ),
  ];

  static AgriCategoryInfo findByKey(String key) {
    return categories.firstWhere(
      (c) => c.key == key,
      orElse: () => categories.first,
    );
  }
}

/// Regional Crop Item with educational guidance
class CropItem {
  final String id;
  final String nameKey;
  final String descKey;
  final String seasonKey;
  final String soilRequirements;
  final String waterRequirements;
  final String cultivationGuidance;
  final String commonPests;
  final String harvestingGuidance;
  final String sourceName;
  final String sourceUrl;
  final String lastVerifiedDate;

  const CropItem({
    required this.id,
    required this.nameKey,
    required this.descKey,
    required this.seasonKey,
    required this.soilRequirements,
    required this.waterRequirements,
    required this.cultivationGuidance,
    required this.commonPests,
    required this.harvestingGuidance,
    required this.sourceName,
    required this.sourceUrl,
    required this.lastVerifiedDate,
  });
}

/// Seasonal Farming Guide Item
class SeasonalGuideItem {
  final String id;
  final String seasonKey; // 'season_kharif', 'season_rabi', 'season_summer', 'season_year_round'
  final String title;
  final String overview;
  final List<String> suitableActivities;
  final String soilPreparation;
  final String waterManagement;
  final String advisories;
  final String officialResourceUrl;
  final String sourceName;
  final String lastVerifiedDate;

  const SeasonalGuideItem({
    required this.id,
    required this.seasonKey,
    required this.title,
    required this.overview,
    required this.suitableActivities,
    required this.soilPreparation,
    required this.waterManagement,
    required this.advisories,
    required this.officialResourceUrl,
    required this.sourceName,
    required this.lastVerifiedDate,
  });
}

/// Pest and Disease Educational Entry
class PestDiseaseItem {
  final String id;
  final String name;
  final String affectedCrops;
  final String symptoms;
  final String prevention;
  final String recommendedSteps;
  final String sourceName;
  final String sourceUrl;
  final String lastVerifiedDate;

  const PestDiseaseItem({
    required this.id,
    required this.name,
    required this.affectedCrops,
    required this.symptoms,
    required this.prevention,
    required this.recommendedSteps,
    required this.sourceName,
    required this.sourceUrl,
    required this.lastVerifiedDate,
  });
}

/// Government Agriculture Scheme
class AgriScheme {
  final String id;
  final String name;
  final String department;
  final String purpose;
  final String eligibilitySummary;
  final List<String> requiredDocuments;
  final String applicationProcess;
  final String officialPortalUrl;
  final String sourceName;
  final String lastVerifiedDate;

  const AgriScheme({
    required this.id,
    required this.name,
    required this.department,
    required this.purpose,
    required this.eligibilitySummary,
    required this.requiredDocuments,
    required this.applicationProcess,
    required this.officialPortalUrl,
    required this.sourceName,
    required this.lastVerifiedDate,
  });
}

/// Farmer Resource & Verified Contact
class FarmerContactItem {
  final String id;
  final String title;
  final String designation;
  final String department;
  final String? phoneNumber;
  final String address;
  final String? websiteUrl;
  final bool isVerified;

  const FarmerContactItem({
    required this.id,
    required this.title,
    required this.designation,
    required this.department,
    this.phoneNumber,
    required this.address,
    this.websiteUrl,
    this.isVerified = true,
  });

  bool get canCall => phoneNumber != null && phoneNumber!.trim().isNotEmpty;
}

/// Equipment or Machinery Service
class EquipmentServiceItem {
  final String id;
  final String name;
  final String category;
  final String description;
  final String availabilityNotice;
  final String officialSchemeUrl;
  final String sourceName;

  const EquipmentServiceItem({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.availabilityNotice,
    required this.officialSchemeUrl,
    required this.sourceName,
  });
}
