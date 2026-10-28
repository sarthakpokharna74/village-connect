import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Verification states for places in GramConnect
enum PlaceVerificationStatus {
  verified,
  referenceLandmark,
  sample,
  pending,
  unverified,
}

extension PlaceVerificationStatusX on PlaceVerificationStatus {
  String get statusKey {
    switch (this) {
      case PlaceVerificationStatus.verified:
        return 'place_status_verified';
      case PlaceVerificationStatus.referenceLandmark:
        return 'place_status_reference_landmark';
      case PlaceVerificationStatus.sample:
        return 'place_status_sample';
      case PlaceVerificationStatus.pending:
        return 'place_status_pending';
      case PlaceVerificationStatus.unverified:
        return 'place_status_unverified';
    }
  }

  Color get badgeColor {
    switch (this) {
      case PlaceVerificationStatus.verified:
        return AppColors.primaryLight;
      case PlaceVerificationStatus.referenceLandmark:
        return AppColors.secondaryLight;
      case PlaceVerificationStatus.sample:
        return Colors.blueGrey;
      case PlaceVerificationStatus.pending:
        return AppColors.noticeAmber;
      case PlaceVerificationStatus.unverified:
        return Colors.grey.shade600;
    }
  }
}

/// Category metadata for the 10 categories required by Blueprint 5
class PlaceCategoryInfo {
  final String id;
  final String translationKey;
  final IconData icon;
  final Color color;

  const PlaceCategoryInfo({
    required this.id,
    required this.translationKey,
    required this.icon,
    required this.color,
  });

  static const List<PlaceCategoryInfo> categories = [
    PlaceCategoryInfo(
      id: 'temples_landmarks',
      translationKey: 'cat_places_temples_landmarks',
      icon: Icons.temple_hindu_rounded,
      color: Colors.deepOrange,
    ),
    PlaceCategoryInfo(
      id: 'schools_education',
      translationKey: 'cat_places_schools_education',
      icon: Icons.school_rounded,
      color: Colors.indigo,
    ),
    PlaceCategoryInfo(
      id: 'healthcare',
      translationKey: 'cat_places_healthcare',
      icon: Icons.local_hospital_rounded,
      color: Colors.redAccent,
    ),
    PlaceCategoryInfo(
      id: 'government_offices',
      translationKey: 'cat_places_government_offices',
      icon: Icons.account_balance_rounded,
      color: Colors.teal,
    ),
    PlaceCategoryInfo(
      id: 'shops_markets',
      translationKey: 'cat_places_shops_markets',
      icon: Icons.storefront_rounded,
      color: Colors.green,
    ),
    PlaceCategoryInfo(
      id: 'banking_atms',
      translationKey: 'cat_places_banking_atms',
      icon: Icons.account_balance_wallet_rounded,
      color: Colors.purple,
    ),
    PlaceCategoryInfo(
      id: 'transport',
      translationKey: 'cat_places_transport',
      icon: Icons.directions_bus_rounded,
      color: Colors.blue,
    ),
    PlaceCategoryInfo(
      id: 'water_utilities',
      translationKey: 'cat_places_water_utilities',
      icon: Icons.water_drop_rounded,
      color: Colors.cyan,
    ),
    PlaceCategoryInfo(
      id: 'agri_services',
      translationKey: 'cat_places_agri_services',
      icon: Icons.agriculture_rounded,
      color: Color(0xFFD97706),
    ),
    PlaceCategoryInfo(
      id: 'other_places',
      translationKey: 'cat_places_other_places',
      icon: Icons.place_rounded,
      color: Colors.blueGrey,
    ),
  ];

  static PlaceCategoryInfo forCategory(String categoryId) {
    return categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => const PlaceCategoryInfo(
        id: 'other_places',
        translationKey: 'cat_places_other_places',
        icon: Icons.place_rounded,
        color: Colors.blueGrey,
      ),
    );
  }
}

/// Main Place model for Dhawalpuri
class Place {
  final String id;
  final String nameKey;
  final String? descriptionKey;
  final String? addressKey;
  final String category; // One of the 10 categories
  final double? latitude; // Nullable - never invent coordinates
  final double? longitude; // Nullable
  final String? phoneNumber; // Nullable - only when verified
  final String? openingHoursKey; // Nullable
  final List<String>? facilities; // Nullable
  final PlaceVerificationStatus verificationStatus;
  final DateTime? lastVerifiedAt;
  final String? source;
  final String? imageAssetPath;
  final bool isReferenceLandmark;
  final String? mapUrl;

  const Place({
    required this.id,
    required this.nameKey,
    this.descriptionKey,
    this.addressKey,
    required this.category,
    this.latitude,
    this.longitude,
    this.phoneNumber,
    this.openingHoursKey,
    this.facilities,
    required this.verificationStatus,
    this.lastVerifiedAt,
    this.source,
    this.imageAssetPath,
    this.isReferenceLandmark = false,
    this.mapUrl,
  });

  bool get hasValidCoordinates => latitude != null && longitude != null;
  bool get hasVerifiedPhone => phoneNumber != null && phoneNumber!.trim().isNotEmpty;

  IconData get icon => PlaceCategoryInfo.forCategory(category).icon;
  Color get categoryColor => PlaceCategoryInfo.forCategory(category).color;
}

/// Backward compatibility alias
typedef PlaceItem = Place;

/// Model for user-submitted place suggestions
class PlaceSuggestion {
  final String id;
  final String placeName;
  final String category;
  final String? location;
  final String? phoneNumber;
  final String? additionalDetails;
  final String? submittedByUserId;
  final DateTime submittedAt;

  const PlaceSuggestion({
    required this.id,
    required this.placeName,
    required this.category,
    this.location,
    this.phoneNumber,
    this.additionalDetails,
    this.submittedByUserId,
    required this.submittedAt,
  });
}

/// Model for reporting incorrect information about a place
class PlaceReport {
  final String id;
  final String placeId;
  final String placeName;
  final String issueType; // incorrect_name, wrong_location, wrong_phone, outdated_info, duplicate, other
  final String? description;
  final String? reportedByUserId;
  final DateTime reportedAt;

  const PlaceReport({
    required this.id,
    required this.placeId,
    required this.placeName,
    required this.issueType,
    this.description,
    this.reportedByUserId,
    required this.reportedAt,
  });
}
