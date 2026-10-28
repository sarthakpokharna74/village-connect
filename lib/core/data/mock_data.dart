import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Representation of a dashboard feature block.
class FeatureItem {
  final String key;
  final IconData icon;
  final Color color;

  const FeatureItem({
    required this.key,
    required this.icon,
    required this.color,
  });
}

/// Simulated central data repository for GramConnect V1.
/// Implements network latency simulation and randomized or triggerable error/empty results.
class MockData {
  MockData._();

  /// List of core features displayed on the Home Dashboard.
  static const List<FeatureItem> dashboardFeatures = [
    FeatureItem(
      key: 'our_village',
      icon: Icons.gite_rounded,
      color: AppColors.primaryLight,
    ),
    FeatureItem(
      key: 'village_notices',
      icon: Icons.campaign_rounded,
      color: AppColors.noticeAmber,
    ),
    FeatureItem(
      key: 'community',
      icon: Icons.people_alt_rounded,
      color: AppColors.tertiaryLight,
    ),
    FeatureItem(
      key: 'important_places',
      icon: Icons.map_rounded,
      color: AppColors.agriBrown,
    ),
    FeatureItem(
      key: 'emergency_contacts',
      icon: Icons.contact_phone_rounded,
      color: AppColors.emergencyRed,
    ),
    FeatureItem(
      key: 'govt_services',
      icon: Icons.account_balance_rounded,
      color: AppColors.infoBlue,
    ),
    FeatureItem(
      key: 'events_festivals',
      icon: Icons.festival_rounded,
      color: AppColors.eventPurple,
    ),
    FeatureItem(
      key: 'village_news',
      icon: Icons.newspaper_rounded,
      color: AppColors.tertiaryLight,
    ),
    FeatureItem(
      key: 'agri_info',
      icon: Icons.agriculture_rounded,
      color: AppColors.primaryLight,
    ),
    FeatureItem(
      key: 'help_feedback',
      icon: Icons.feedback_rounded,
      color: AppColors.agriBrown,
    ),
    FeatureItem(
      key: 'more_info',
      icon: Icons.info_rounded,
      color: AppColors.infoBlue,
    ),
  ];

  /// Simulates fetching items for a given feature.
  /// Set [simulateError] or [simulateEmpty] to explicitly test resilience.
  static Future<List<Map<String, String>>> fetchFeatureData(
    String featureKey, {
    bool simulateError = false,
    bool simulateEmpty = false,
  }) async {
    // Simulate mobile network delay (1.2 seconds)
    await Future.delayed(const Duration(milliseconds: 1200));

    if (simulateError) {
      throw Exception('Simulated network error. Please try again.');
    }

    if (simulateEmpty) {
      return [];
    }

    // Static details data based on feature key
    switch (featureKey) {
      case 'our_village':
        return [
          {'title': 'Demographics', 'value': 'Population: ~7,873 (Census 2011) | Households: ~1,535'},
          {'title': 'Village Sarpanch', 'value': 'Mrs. Sunita Patil (Term: 2025-2030)'},
          {'title': 'History & Landmarks', 'value': 'Historically rich village near Kalu Dam. Renowned for Durgadevi Temple and local farming.'},
          {'title': 'Main Activity', 'value': 'Cooperative Agriculture (Onion, Millet, Sugarcane)'},
        ];

      case 'village_notices':
        return [
          {'title': 'Gram Sabha Meeting Scheduled', 'value': 'Date: Sep 5, 2026. Time: 10:00 AM. Location: Gram Panchayat Hall.'},
          {'title': 'Free Vaccination Drive', 'value': 'Polio & MMR immunizations at Primary Health Center on Monday from 9 AM to 4 PM.'},
          {'title': 'Electricity Maintenance Outage', 'value': 'Power shut down for grid repair on Aug 30 from 10 AM to 2 PM.'},
        ];

      case 'community':
        return [
          {'title': 'Ramesh Kumar', 'value': 'Looking to purchase 50kg organic fertilizer. Any recommendations?'},
          {'title': 'Sita Sharma', 'value': 'Lost key chain near the milk dairy. Please contact if found.'},
          {'title': 'Youth Club', 'value': 'Volunteers needed for village cleaning drive this Saturday at 7 AM.'},
        ];

      case 'important_places':
        return [
          {'title': 'Zilla Parishad Primary School', 'value': 'Location: East Block | Contact: 023-456789'},
          {'title': 'Primary Health Center (PHC)', 'value': 'Location: Main Road | 24/7 Emergency Ward'},
          {'title': 'Weekly Vegetable Market', 'value': 'Location: Gram Panchayat Ground | Every Sunday 7 AM - 6 PM'},
          {'title': 'Gram Panchayat Office', 'value': 'Location: Village Center | Mon-Fri 10 AM - 5 PM'},
        ];

      case 'emergency_contacts':
        return [
          {'title': 'Primary Health Center Ambulance', 'value': '+91 98765 43210'},
          {'title': 'Local Police Outpost', 'value': '+91 91234 56789'},
          {'title': 'Fire Station District HQ', 'value': '+91 92345 67890'},
          {'title': 'Electricity Board Office', 'value': '0231-234567'},
          {'title': 'Village Panchayat Sarpanch', 'value': '+91 99999 88888'},
        ];

      case 'govt_services':
        return [
          {'title': 'Income Certificate Form', 'value': 'Apply online or submit Form 1-A at Panchayat Office. Fee: ₹50.'},
          {'title': 'PM Kisan Samman Nidhi', 'value': 'Verification drive active. Link Aadhar card at Common Service Center (CSC).'},
          {'title': 'Ration Card Upgradation', 'value': 'Apply before Sep 15 to link family members. Bring proof of residence.'},
        ];

      case 'events_festivals':
        return [
          {'title': 'Ganesh Chaturthi Utsav', 'value': 'Date: Sep 7 to Sep 17. Mega cultural drama on Sep 10 at 7:00 PM.'},
          {'title': 'Farmers Training Workshop', 'value': 'Date: Sep 12. Learn soil test techniques. Led by Krishi Vigyan Kendra.'},
          {'title': 'Independence Day Assembly', 'value': 'Flag hoisting at ZP School ground on Aug 15 at 7:30 AM.'},
        ];

      case 'agri_info':
        return [
          {'title': 'Mandi Price Rates', 'value': 'Official rates via MSAMB & Agmarknet for Parner & Ahilyanagar mandis.'},
          {'title': 'Weather Advisory', 'value': 'IMD Agromet bulletins and forecast for Parner taluka.'},
          {'title': 'Crop Guidance', 'value': 'Regional cultivation guidance for Onion, Bajra, Soybean, and Wheat.'},
        ];

      case 'help_feedback':
        return [
          {'title': 'Submit Feedback', 'value': 'Propose local suggestions or community activities for Dhawalpuri.'},
          {'title': 'Panchayat Desk', 'value': 'Contact the Gram Panchayat office during standard office hours.'},
        ];

      case 'more_info':
        return [
          {'title': 'About GramConnect', 'value': 'GramConnect is a digital identity and services ecosystem platform designed specifically for village administration and residents.'},
          {'title': 'Software Version', 'value': 'v1.0.0 (Material 3 Ready)'},
          {'title': 'Support Email', 'value': 'support@gramconnect.org'},
        ];

      default:
        return [
          {'title': 'Default Title', 'value': 'Default mock description value.'}
        ];
    }
  }
}
