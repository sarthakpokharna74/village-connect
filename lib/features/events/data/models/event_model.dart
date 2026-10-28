import 'package:flutter/material.dart';

/// Lifecycle and calendar status of a village event.
enum EventStatus {
  upcoming,
  ongoing,
  completed,
  cancelled,
  postponed;

  String get translationKey {
    switch (this) {
      case EventStatus.upcoming:
        return 'ev_status_upcoming';
      case EventStatus.ongoing:
        return 'ev_status_ongoing';
      case EventStatus.completed:
        return 'ev_status_completed';
      case EventStatus.cancelled:
        return 'ev_status_cancelled';
      case EventStatus.postponed:
        return 'ev_status_postponed';
    }
  }

  Color get color {
    switch (this) {
      case EventStatus.upcoming:
        return const Color(0xFF1976D2); // Blue
      case EventStatus.ongoing:
        return const Color(0xFF2E7D32); // Green
      case EventStatus.completed:
        return const Color(0xFF757575); // Grey
      case EventStatus.cancelled:
        return const Color(0xFFD32F2F); // Red
      case EventStatus.postponed:
        return const Color(0xFFE65100); // Amber / Orange
    }
  }

  IconData get icon {
    switch (this) {
      case EventStatus.upcoming:
        return Icons.event_available_rounded;
      case EventStatus.ongoing:
        return Icons.play_circle_filled_rounded;
      case EventStatus.completed:
        return Icons.check_circle_outline_rounded;
      case EventStatus.cancelled:
        return Icons.cancel_outlined;
      case EventStatus.postponed:
        return Icons.schedule_rounded;
    }
  }
}

/// Verification status for events listed in GramConnect.
enum EventVerificationStatus {
  verified,
  pendingVerification,
  unverified;

  String get translationKey {
    switch (this) {
      case EventVerificationStatus.verified:
        return 'ev_verified';
      case EventVerificationStatus.pendingVerification:
        return 'ev_pending_verification';
      case EventVerificationStatus.unverified:
        return 'ev_unverified';
    }
  }

  Color get color {
    switch (this) {
      case EventVerificationStatus.verified:
        return const Color(0xFF2E7D32);
      case EventVerificationStatus.pendingVerification:
        return const Color(0xFFE65100);
      case EventVerificationStatus.unverified:
        return const Color(0xFF757575);
    }
  }
}

/// Publication status of an event or community proposal.
enum EventPublicationStatus {
  draft,
  pendingApproval,
  published,
  rejected,
}

/// Category metadata for the 10 official categories specified in Blueprint 8.
class EventCategoryInfo {
  final String id;
  final String nameKey;
  final String descriptionKey;
  final IconData icon;
  final Color color;

  const EventCategoryInfo({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    required this.icon,
    required this.color,
  });

  static const List<EventCategoryInfo> allCategories = [
    EventCategoryInfo(
      id: 'festivals_celebrations',
      nameKey: 'cat_ev_festivals_celebrations',
      descriptionKey: 'cat_ev_festivals_celebrations_desc',
      icon: Icons.festival_rounded,
      color: Color(0xFFE65100), // Deep Orange
    ),
    EventCategoryInfo(
      id: 'cultural_programs',
      nameKey: 'cat_ev_cultural_programs',
      descriptionKey: 'cat_ev_cultural_programs_desc',
      icon: Icons.music_note_rounded,
      color: Color(0xFF8E24AA), // Purple
    ),
    EventCategoryInfo(
      id: 'community_gatherings',
      nameKey: 'cat_ev_community_gatherings',
      descriptionKey: 'cat_ev_community_gatherings_desc',
      icon: Icons.groups_rounded,
      color: Color(0xFF00897B), // Teal
    ),
    EventCategoryInfo(
      id: 'sports_youth',
      nameKey: 'cat_ev_sports_youth',
      descriptionKey: 'cat_ev_sports_youth_desc',
      icon: Icons.sports_kabaddi_rounded,
      color: Color(0xFFD32F2F), // Red
    ),
    EventCategoryInfo(
      id: 'educational_activities',
      nameKey: 'cat_ev_educational_activities',
      descriptionKey: 'cat_ev_educational_activities_desc',
      icon: Icons.school_rounded,
      color: Color(0xFF1976D2), // Blue
    ),
    EventCategoryInfo(
      id: 'agricultural_events',
      nameKey: 'cat_ev_agricultural_events',
      descriptionKey: 'cat_ev_agricultural_events_desc',
      icon: Icons.agriculture_rounded,
      color: Color(0xFF2E7D32), // Green
    ),
    EventCategoryInfo(
      id: 'gram_panchayat_meetings',
      nameKey: 'cat_ev_gram_panchayat_meetings',
      descriptionKey: 'cat_ev_gram_panchayat_meetings_desc',
      icon: Icons.account_balance_rounded,
      color: Color(0xFF455A64), // Blue Grey
    ),
    EventCategoryInfo(
      id: 'social_initiatives',
      nameKey: 'cat_ev_social_initiatives',
      descriptionKey: 'cat_ev_social_initiatives_desc',
      icon: Icons.volunteer_activism_rounded,
      color: Color(0xFFC2185B), // Pink
    ),
    EventCategoryInfo(
      id: 'religious_events',
      nameKey: 'cat_ev_religious_events',
      descriptionKey: 'cat_ev_religious_events_desc',
      icon: Icons.temple_hindu_rounded,
      color: Color(0xFFF57C00), // Amber
    ),
    EventCategoryInfo(
      id: 'other_events',
      nameKey: 'cat_ev_other_events',
      descriptionKey: 'cat_ev_other_events_desc',
      icon: Icons.event_note_rounded,
      color: Color(0xFF546E7A), // Slate
    ),
  ];

  static IconData getIconForCategory(String categoryId) {
    for (final cat in allCategories) {
      if (cat.id == categoryId) return cat.icon;
    }
    // Backward-compatibility fallback for legacy category ids
    switch (categoryId) {
      case 'festival':
        return Icons.festival_rounded;
      case 'cultural':
        return Icons.music_note_rounded;
      case 'sports':
        return Icons.sports_kabaddi_rounded;
      case 'meeting':
        return Icons.groups_rounded;
      case 'community':
        return Icons.volunteer_activism_rounded;
      default:
        return Icons.event_available_rounded;
    }
  }

  static Color getColorForCategory(String categoryId) {
    for (final cat in allCategories) {
      if (cat.id == categoryId) return cat.color;
    }
    switch (categoryId) {
      case 'festival':
        return const Color(0xFFE65100);
      case 'cultural':
        return const Color(0xFF8E24AA);
      case 'sports':
        return const Color(0xFFD32F2F);
      case 'meeting':
        return const Color(0xFF00897B);
      case 'community':
        return const Color(0xFFC2185B);
      default:
        return const Color(0xFF1976D2);
    }
  }
}

/// Comprehensive model representing a Village Event in GramConnect (Blueprint 8).
class VillageEvent {
  final String id;
  final String titleKey;
  final String category;
  final String descriptionKey;
  final DateTime startDateTime;
  final DateTime? endDateTime;
  final String venueKey;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? organizerKey;
  final String? contactInformation;
  final String? imageAssetPath;
  final String? eventUrl;
  final EventPublicationStatus publicationStatus;
  final EventStatus eventStatus;
  final String? sourceName;
  final EventVerificationStatus verificationStatus;
  final String? instructionsKey;
  final bool isFeatured;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const VillageEvent({
    required this.id,
    required this.titleKey,
    required this.category,
    required this.descriptionKey,
    required this.startDateTime,
    this.endDateTime,
    required this.venueKey,
    this.address,
    this.latitude,
    this.longitude,
    this.organizerKey,
    this.contactInformation,
    this.imageAssetPath,
    this.eventUrl,
    this.publicationStatus = EventPublicationStatus.published,
    this.eventStatus = EventStatus.upcoming,
    this.sourceName,
    this.verificationStatus = EventVerificationStatus.verified,
    this.instructionsKey,
    this.isFeatured = false,
    this.createdAt,
    this.updatedAt,
  });

  Color get color => EventCategoryInfo.getColorForCategory(category);
  IconData get icon => EventCategoryInfo.getIconForCategory(category);

  // Backward compatibility getters for legacy screens
  String get locationKey => venueKey;
  String get dateKey {
    final s = startDateTime;
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (endDateTime != null && endDateTime!.day != s.day) {
      return '${months[s.month - 1]} ${s.day} - ${months[endDateTime!.month - 1]} ${endDateTime!.day}';
    }
    return '${months[s.month - 1]} ${s.day}, ${s.year}';
  }

  String get timeKey {
    final s = startDateTime;
    final startStr = _formatTime(s);
    if (endDateTime != null) {
      final endStr = _formatTime(endDateTime!);
      return '$startStr - $endStr';
    }
    return startStr;
  }

  static String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  /// Calculates real-time computed status from dates if not cancelled or postponed.
  EventStatus get computedStatus {
    if (eventStatus == EventStatus.cancelled || eventStatus == EventStatus.postponed) {
      return eventStatus;
    }
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final eventEnd = endDateTime ?? startDateTime.add(const Duration(hours: 3));

    if (now.isAfter(eventEnd)) {
      return EventStatus.completed;
    } else if (startDateTime.isBefore(todayEnd) && eventEnd.isAfter(todayStart)) {
      return EventStatus.ongoing;
    }
    return EventStatus.upcoming;
  }

  static List<VillageEvent> get mockEvents {
    // Import-free dynamic fallback or initialized via repository
    return [];
  }

  static IconData getIconForCategory(String category) =>
      EventCategoryInfo.getIconForCategory(category);

  static Color getColorForCategory(String category) =>
      EventCategoryInfo.getColorForCategory(category);
}

/// Community-submitted event proposal (Blueprint 8 Section 8).
class EventSuggestion {
  final String id;
  final String title;
  final String category;
  final DateTime date;
  final String? startTime;
  final String? endTime;
  final String venue;
  final String description;
  final String? organizer;
  final String? contact;
  final DateTime submittedAt;
  final EventPublicationStatus status;

  const EventSuggestion({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    this.startTime,
    this.endTime,
    required this.venue,
    required this.description,
    this.organizer,
    this.contact,
    required this.submittedAt,
    this.status = EventPublicationStatus.pendingApproval,
  });
}

/// Backward compatibility typedef
typedef EventItem = VillageEvent;
