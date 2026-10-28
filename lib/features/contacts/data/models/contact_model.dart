import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Official verification status for emergency contacts.
enum ContactVerificationStatus {
  verified,
  pending,
  unverified,
}

extension ContactVerificationStatusX on ContactVerificationStatus {
  String get statusKey {
    switch (this) {
      case ContactVerificationStatus.verified:
        return 'contact_status_verified';
      case ContactVerificationStatus.pending:
        return 'contact_status_pending';
      case ContactVerificationStatus.unverified:
        return 'contact_status_unverified';
    }
  }

  Color get badgeColor {
    switch (this) {
      case ContactVerificationStatus.verified:
        return AppColors.primaryLight;
      case ContactVerificationStatus.pending:
        return AppColors.noticeAmber;
      case ContactVerificationStatus.unverified:
        return Colors.grey.shade600;
    }
  }

  IconData get icon {
    switch (this) {
      case ContactVerificationStatus.verified:
        return Icons.verified_rounded;
      case ContactVerificationStatus.pending:
        return Icons.hourglass_top_rounded;
      case ContactVerificationStatus.unverified:
        return Icons.help_outline_rounded;
    }
  }
}

/// Metadata for the 10 Emergency Categories required by Blueprint 6
class EmergencyCategoryInfo {
  final String id;
  final String translationKey;
  final IconData icon;
  final Color color;

  const EmergencyCategoryInfo({
    required this.id,
    required this.translationKey,
    required this.icon,
    required this.color,
  });

  static const List<EmergencyCategoryInfo> categories = [
    EmergencyCategoryInfo(
      id: 'ambulance_medical',
      translationKey: 'cat_em_ambulance_medical',
      icon: Icons.local_hospital_rounded,
      color: Colors.red,
    ),
    EmergencyCategoryInfo(
      id: 'police',
      translationKey: 'cat_em_police',
      icon: Icons.local_police_rounded,
      color: Colors.indigo,
    ),
    EmergencyCategoryInfo(
      id: 'fire_rescue',
      translationKey: 'cat_em_fire_rescue',
      icon: Icons.fire_truck_rounded,
      color: Colors.deepOrange,
    ),
    EmergencyCategoryInfo(
      id: 'hospital_healthcare',
      translationKey: 'cat_em_hospital_healthcare',
      icon: Icons.health_and_safety_rounded,
      color: Colors.redAccent,
    ),
    EmergencyCategoryInfo(
      id: 'women_child',
      translationKey: 'cat_em_women_child',
      icon: Icons.family_restroom_rounded,
      color: Colors.purple,
    ),
    EmergencyCategoryInfo(
      id: 'disaster_safety',
      translationKey: 'cat_em_disaster_safety',
      icon: Icons.warning_amber_rounded,
      color: Color(0xFFD97706),
    ),
    EmergencyCategoryInfo(
      id: 'electricity',
      translationKey: 'cat_em_electricity',
      icon: Icons.electric_bolt_rounded,
      color: Color(0xFFC2410C),
    ),
    EmergencyCategoryInfo(
      id: 'water_supply',
      translationKey: 'cat_em_water_supply',
      icon: Icons.water_drop_rounded,
      color: Colors.cyan,
    ),
    EmergencyCategoryInfo(
      id: 'local_govt',
      translationKey: 'cat_em_local_govt',
      icon: Icons.account_balance_rounded,
      color: Colors.teal,
    ),
    EmergencyCategoryInfo(
      id: 'other_emergency',
      translationKey: 'cat_em_other_emergency',
      icon: Icons.emergency_rounded,
      color: Colors.blueGrey,
    ),
  ];

  static EmergencyCategoryInfo forCategory(String categoryId) {
    return categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => const EmergencyCategoryInfo(
        id: 'other_emergency',
        translationKey: 'cat_em_other_emergency',
        icon: Icons.emergency_rounded,
        color: Colors.blueGrey,
      ),
    );
  }
}

/// Official Emergency Contact Model
class EmergencyContact {
  final String id;
  final String nameKey;
  final String category;
  final String? phoneNumber; // Nullable - only verified official numbers!
  final String? descriptionKey;
  final String? purposeKey;
  final String? coverageKey;
  final String? addressKey;
  final double? latitude;
  final double? longitude;
  final String? availabilityKey;
  final ContactVerificationStatus verificationStatus;
  final bool isNationalService;
  final String? sourceKey;
  final String? sourceName;
  final String? sourceUrl;
  final String? lastVerifiedAt;
  final String? safeAlternativeKey;
  final IconData icon;
  final Color color;

  const EmergencyContact({
    required this.id,
    required this.nameKey,
    required this.category,
    this.phoneNumber,
    this.descriptionKey,
    this.purposeKey,
    this.coverageKey,
    this.addressKey,
    this.latitude,
    this.longitude,
    this.availabilityKey,
    this.verificationStatus = ContactVerificationStatus.verified,
    this.isNationalService = false,
    this.sourceKey,
    this.sourceName,
    this.sourceUrl,
    this.lastVerifiedAt,
    this.safeAlternativeKey,
    required this.icon,
    required this.color,
  });

  /// True if there is a valid verified phone number that can be called
  bool get hasValidPhoneNumber =>
      phoneNumber != null && phoneNumber!.trim().isNotEmpty;

  /// Backward compatibility helper for legacy code accessing .number
  String get number => phoneNumber ?? '';

  /// Copies contact with modified parameters
  EmergencyContact copyWith({
    String? id,
    String? nameKey,
    String? category,
    String? phoneNumber,
    String? descriptionKey,
    String? purposeKey,
    String? coverageKey,
    String? addressKey,
    double? latitude,
    double? longitude,
    String? availabilityKey,
    ContactVerificationStatus? verificationStatus,
    bool? isNationalService,
    String? sourceKey,
    String? sourceUrl,
    String? lastVerifiedAt,
    String? safeAlternativeKey,
    IconData? icon,
    Color? color,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      nameKey: nameKey ?? this.nameKey,
      category: category ?? this.category,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      descriptionKey: descriptionKey ?? this.descriptionKey,
      purposeKey: purposeKey ?? this.purposeKey,
      coverageKey: coverageKey ?? this.coverageKey,
      addressKey: addressKey ?? this.addressKey,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      availabilityKey: availabilityKey ?? this.availabilityKey,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      isNationalService: isNationalService ?? this.isNationalService,
      sourceKey: sourceKey ?? this.sourceKey,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
      safeAlternativeKey: safeAlternativeKey ?? this.safeAlternativeKey,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }
}

/// Backward compatibility alias
typedef EmergencyContactItem = EmergencyContact;
