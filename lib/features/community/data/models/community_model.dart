import 'package:flutter/material.dart';

/// Data model representing a Community Group, Organization, or Activity in Dhawalpuri.
/// Supports localized keys for dynamic English, Marathi (ढवळपुरी), and Hindi translations.
class CommunityItem {
  final String id;
  final String category; // 'community_groups', 'cultural_activities', 'sports_youth', 'volunteering', 'womens_groups', 'senior_citizens', 'village_celebrations', 'social_initiatives'
  final String nameKey;
  final String descriptionKey;
  final String? imageUrl;
  final String? organizerKey;
  final String? locationKey;
  final String? upcomingActivityKey;
  final String? purposeKey;
  final String? meetingInfoKey;
  final String? participationInstructionsKey;
  final bool isVerified;
  final String status; // 'sample', 'active'
  final String actionType; // 'join', 'volunteer', 'register', 'contact'
  final bool isFeatured;
  final IconData icon;
  final Color categoryColor;

  const CommunityItem({
    required this.id,
    required this.category,
    required this.nameKey,
    required this.descriptionKey,
    this.imageUrl,
    this.organizerKey,
    this.locationKey,
    this.upcomingActivityKey,
    this.purposeKey,
    this.meetingInfoKey,
    this.participationInstructionsKey,
    this.isVerified = false,
    this.status = 'sample',
    this.actionType = 'join',
    this.isFeatured = false,
    required this.icon,
    required this.categoryColor,
  });

  /// Retrieve standard icon for community category
  static IconData getIconForCategory(String category) {
    switch (category) {
      case 'community_groups':
      case 'orgs':
        return Icons.groups_rounded;
      case 'cultural_activities':
      case 'cultural':
        return Icons.theater_comedy_rounded;
      case 'sports_youth':
      case 'sports':
      case 'youth':
        return Icons.sports_cricket_rounded;
      case 'volunteering':
      case 'volunteer':
        return Icons.volunteer_activism_rounded;
      case 'womens_groups':
      case 'womens':
        return Icons.woman_rounded;
      case 'senior_citizens':
      case 'seniors':
        return Icons.elderly_rounded;
      case 'village_celebrations':
      case 'announcements':
        return Icons.celebration_rounded;
      case 'social_initiatives':
        return Icons.handshake_rounded;
      default:
        return Icons.people_alt_rounded;
    }
  }

  /// Retrieve color styling for community category
  static Color getColorForCategory(String category) {
    switch (category) {
      case 'community_groups':
      case 'orgs':
        return const Color(0xFF3F51B5); // Indigo
      case 'cultural_activities':
      case 'cultural':
        return const Color(0xFF8E24AA); // Purple
      case 'sports_youth':
      case 'sports':
      case 'youth':
        return const Color(0xFFE65100); // Deep Orange
      case 'volunteering':
      case 'volunteer':
        return const Color(0xFF2E7D32); // Forest Green
      case 'womens_groups':
      case 'womens':
        return const Color(0xFFD81B60); // Rose Pink
      case 'senior_citizens':
      case 'seniors':
        return const Color(0xFF00796B); // Deep Teal
      case 'village_celebrations':
      case 'announcements':
        return const Color(0xFFF57F17); // Amber Gold
      case 'social_initiatives':
        return const Color(0xFF1976D2); // Blue
      default:
        return const Color(0xFF546E7A); // Blue Grey
    }
  }

  /// Retrieve translation key for a category code
  static String getCategoryTitleKey(String category) {
    switch (category) {
      case 'community_groups':
        return 'cat_community_groups';
      case 'cultural_activities':
        return 'cat_cultural_activities';
      case 'sports_youth':
        return 'cat_sports_youth';
      case 'volunteering':
        return 'cat_volunteering';
      case 'womens_groups':
        return 'cat_womens_groups';
      case 'senior_citizens':
        return 'cat_senior_citizens';
      case 'village_celebrations':
        return 'cat_village_celebrations';
      case 'social_initiatives':
        return 'cat_social_initiatives';
      default:
        return 'cat_community_groups';
    }
  }

  /// Predefined static mock community sample items (Blueprint 4: Dhawalpuri)
  /// Clearly labelled sample prototype content; no fake real organizations or real phone numbers.
  static final List<CommunityItem> mockItems = [
    CommunityItem(
      id: 'comm-1',
      category: 'community_groups',
      nameKey: 'c1_name',
      descriptionKey: 'c1_desc',
      organizerKey: 'c1_org',
      locationKey: 'c1_loc',
      upcomingActivityKey: 'c1_upcoming',
      purposeKey: 'c1_purpose',
      meetingInfoKey: 'c1_meeting',
      participationInstructionsKey: 'c1_instructions',
      isVerified: false,
      status: 'sample',
      actionType: 'join',
      isFeatured: false,
      icon: getIconForCategory('community_groups'),
      categoryColor: getColorForCategory('community_groups'),
    ),
    CommunityItem(
      id: 'comm-2',
      category: 'womens_groups',
      nameKey: 'c2_name',
      descriptionKey: 'c2_desc',
      organizerKey: 'c2_org',
      locationKey: 'c2_loc',
      upcomingActivityKey: 'c2_upcoming',
      purposeKey: 'c2_purpose',
      meetingInfoKey: 'c2_meeting',
      participationInstructionsKey: 'c2_instructions',
      isVerified: false,
      status: 'sample',
      actionType: 'join',
      isFeatured: false,
      icon: getIconForCategory('womens_groups'),
      categoryColor: getColorForCategory('womens_groups'),
    ),
    CommunityItem(
      id: 'comm-3',
      category: 'volunteering',
      nameKey: 'c3_name',
      descriptionKey: 'c3_desc',
      organizerKey: 'c3_org',
      locationKey: 'c3_loc',
      upcomingActivityKey: 'c3_upcoming',
      purposeKey: 'c3_purpose',
      meetingInfoKey: 'c3_meeting',
      participationInstructionsKey: 'c3_instructions',
      isVerified: false,
      status: 'sample',
      actionType: 'volunteer',
      isFeatured: true, // Featured Activity for demonstration
      icon: getIconForCategory('volunteering'),
      categoryColor: getColorForCategory('volunteering'),
    ),
    CommunityItem(
      id: 'comm-4',
      category: 'cultural_activities',
      nameKey: 'c4_name',
      descriptionKey: 'c4_desc',
      organizerKey: 'c4_org',
      locationKey: 'c4_loc',
      upcomingActivityKey: 'c4_upcoming',
      purposeKey: 'c4_purpose',
      meetingInfoKey: 'c4_meeting',
      participationInstructionsKey: 'c4_instructions',
      isVerified: false,
      status: 'sample',
      actionType: 'join',
      isFeatured: false,
      icon: getIconForCategory('cultural_activities'),
      categoryColor: getColorForCategory('cultural_activities'),
    ),
    CommunityItem(
      id: 'comm-5',
      category: 'sports_youth',
      nameKey: 'c5_name',
      descriptionKey: 'c5_desc',
      organizerKey: 'c5_org',
      locationKey: 'c5_loc',
      upcomingActivityKey: 'c5_upcoming',
      purposeKey: 'c5_purpose',
      meetingInfoKey: 'c5_meeting',
      participationInstructionsKey: 'c5_instructions',
      isVerified: false,
      status: 'sample',
      actionType: 'register',
      isFeatured: false,
      icon: getIconForCategory('sports_youth'),
      categoryColor: getColorForCategory('sports_youth'),
    ),
    CommunityItem(
      id: 'comm-6',
      category: 'senior_citizens',
      nameKey: 'c6_name',
      descriptionKey: 'c6_desc',
      organizerKey: 'c6_org',
      locationKey: 'c6_loc',
      upcomingActivityKey: 'c6_upcoming',
      purposeKey: 'c6_purpose',
      meetingInfoKey: 'c6_meeting',
      participationInstructionsKey: 'c6_instructions',
      isVerified: false,
      status: 'sample',
      actionType: 'join',
      isFeatured: false,
      icon: getIconForCategory('senior_citizens'),
      categoryColor: getColorForCategory('senior_citizens'),
    ),
    CommunityItem(
      id: 'comm-7',
      category: 'village_celebrations',
      nameKey: 'c7_name',
      descriptionKey: 'c7_desc',
      organizerKey: 'c7_org',
      locationKey: 'c7_loc',
      upcomingActivityKey: 'c7_upcoming',
      purposeKey: 'c7_purpose',
      meetingInfoKey: 'c7_meeting',
      participationInstructionsKey: 'c7_instructions',
      isVerified: false,
      status: 'sample',
      actionType: 'volunteer',
      isFeatured: false,
      icon: getIconForCategory('village_celebrations'),
      categoryColor: getColorForCategory('village_celebrations'),
    ),
    CommunityItem(
      id: 'comm-8',
      category: 'social_initiatives',
      nameKey: 'c8_name',
      descriptionKey: 'c8_desc',
      organizerKey: 'c8_org',
      locationKey: 'c8_loc',
      upcomingActivityKey: 'c8_upcoming',
      purposeKey: 'c8_purpose',
      meetingInfoKey: 'c8_meeting',
      participationInstructionsKey: 'c8_instructions',
      isVerified: false,
      status: 'sample',
      actionType: 'volunteer',
      isFeatured: false,
      icon: getIconForCategory('social_initiatives'),
      categoryColor: getColorForCategory('social_initiatives'),
    ),
  ];
}

/// Model representing a user-submitted community activity suggestion.
/// Clearly designated as local prototype submission.
class CommunitySubmission {
  final String id;
  final String title;
  final String category;
  final String description;
  final String? suggestedDate;
  final String? location;
  final String submittedBy;
  final String status; // 'prototype_pending', 'reviewed'
  final DateTime createdAt;

  const CommunitySubmission({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    this.suggestedDate,
    this.location,
    required this.submittedBy,
    this.status = 'prototype_pending',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'suggestedDate': suggestedDate,
      'location': location,
      'submittedBy': submittedBy,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
