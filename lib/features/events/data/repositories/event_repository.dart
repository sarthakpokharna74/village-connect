import '../../../../core/localization/translations.dart';
import '../models/event_model.dart';

/// Abstract contract for Village Events and Calendar operations in GramConnect.
/// Prepares the application for future Supabase or REST API backend integrations.
abstract class EventRepository {
  /// Fetches all verified events (both upcoming and past).
  Future<List<VillageEvent>> getAllEvents();

  /// Fetches verified upcoming and ongoing events in chronological order.
  /// Completed/past events are excluded from this list.
  Future<List<VillageEvent>> getUpcomingEvents();

  /// Fetches a specific event by ID.
  Future<VillageEvent?> getEventById(String id);

  /// Fetches the featured upcoming event (if any exists).
  Future<VillageEvent?> getFeaturedEvent();

  /// Searches events by text query and filters by category.
  Future<List<VillageEvent>> searchEvents(
    String query, {
    String? category,
    bool includePast = false,
  });

  /// Fetches events occurring on a specific calendar date (day/month/year).
  Future<List<VillageEvent>> getEventsForDate(DateTime date);

  /// Fetches all events scheduled in a specific month and year.
  Future<List<VillageEvent>> getEventsForMonth(int year, int month);

  /// Submits a citizen event suggestion for moderation.
  Future<bool> suggestEvent(EventSuggestion suggestion);

  /// Returns citizen-submitted event proposals stored in-memory.
  List<EventSuggestion> getSuggestions();
}

/// In-memory mock implementation of [EventRepository] for Dhawalpuri.
/// Anchors event dates dynamically relative to current date for realistic testing.
class MockEventRepository implements EventRepository {
  static final MockEventRepository _instance = MockEventRepository._internal();
  factory MockEventRepository() => _instance;
  MockEventRepository._internal();

  final List<EventSuggestion> _suggestions = [];

  /// Verified events for Dhawalpuri (ढवळपुरी), Taluka Parner, District Ahilyanagar.
  /// Uses dynamic dates anchored to current time to ensure upcoming, ongoing, and past events
  /// are always active and accurate regardless of when the app is run.
  static List<VillageEvent> get verifiedEvents {
    final now = DateTime.now();

    return [
      // 1. Featured Upcoming Event: Annual Hanuman Temple Jatra & Palakhi
      VillageEvent(
        id: 'ev_hanuman_jatra',
        titleKey: 'ev1_title',
        category: 'festivals_celebrations',
        descriptionKey: 'ev1_desc',
        startDateTime: DateTime(now.year, now.month, now.day + 5, 9, 0),
        endDateTime: DateTime(now.year, now.month, now.day + 6, 21, 0),
        venueKey: 'ev1_venue',
        address: 'Old Hanuman Mandir Rd, Dhawalpuri, Taluka Parner, District Ahilyanagar - 414304',
        latitude: 19.0345,
        longitude: 74.3721,
        organizerKey: 'ev1_organizer',
        contactInformation: '+91 2488 245100',
        eventStatus: EventStatus.upcoming,
        sourceName: 'Dhawalpuri Devasthan Trust',
        verificationStatus: EventVerificationStatus.verified,
        instructionsKey: 'ev1_instructions',
        isFeatured: true,
        createdAt: DateTime(now.year, now.month, 1),
      ),

      // 2. Agricultural Event: Kharif Soil Health & Organic Farming Shibir
      VillageEvent(
        id: 'ev_kharif_shibir',
        titleKey: 'ev2_title',
        category: 'agricultural_events',
        descriptionKey: 'ev2_desc',
        startDateTime: DateTime(now.year, now.month, now.day + 12, 10, 0),
        endDateTime: DateTime(now.year, now.month, now.day + 12, 16, 30),
        venueKey: 'ev2_venue',
        address: 'Near Gram Panchayat Bhavan, Dhawalpuri, Parner, Ahilyanagar',
        latitude: 19.0341,
        longitude: 74.3718,
        organizerKey: 'ev2_organizer',
        contactInformation: '+91 94220 12345',
        eventStatus: EventStatus.upcoming,
        sourceName: 'Taluka Krishi Adhikari Parner & Dhawalpuri Shetkari Gat',
        verificationStatus: EventVerificationStatus.verified,
        instructionsKey: 'ev2_instructions',
        isFeatured: false,
        createdAt: DateTime(now.year, now.month, 3),
      ),

      // 3. Gram Panchayat Meeting: Special Gram Sabha on Water Conservation & Sanitation
      VillageEvent(
        id: 'ev_gram_sabha_water',
        titleKey: 'ev3_title',
        category: 'gram_panchayat_meetings',
        descriptionKey: 'ev3_desc',
        startDateTime: DateTime(now.year, now.month, now.day + 18, 11, 0),
        endDateTime: DateTime(now.year, now.month, now.day + 18, 14, 0),
        venueKey: 'ev3_venue',
        address: 'Main Square, Gram Panchayat Hall, Dhawalpuri',
        latitude: 19.0348,
        longitude: 74.3725,
        organizerKey: 'ev3_organizer',
        contactInformation: '+91 2488 245201',
        eventStatus: EventStatus.upcoming,
        sourceName: 'Gram Panchayat Dhawalpuri Official Record',
        verificationStatus: EventVerificationStatus.verified,
        instructionsKey: 'ev3_instructions',
        isFeatured: false,
        createdAt: DateTime(now.year, now.month, 5),
      ),

      // 4. Sports & Youth: Dhawalpuri Gramin Kabaddi & Wrestling Chashak
      VillageEvent(
        id: 'ev_kabaddi_chashak',
        titleKey: 'ev4_title',
        category: 'sports_youth',
        descriptionKey: 'ev4_desc',
        startDateTime: DateTime(now.year, now.month, now.day + 24, 8, 30),
        endDateTime: DateTime(now.year, now.month, now.day + 25, 19, 0),
        venueKey: 'ev4_venue',
        address: 'ZP Primary School Sports Ground, Dhawalpuri',
        latitude: 19.0335,
        longitude: 74.3710,
        organizerKey: 'ev4_organizer',
        contactInformation: '+91 98221 54321',
        eventStatus: EventStatus.upcoming,
        sourceName: 'Dhawalpuri Tarun Mandal',
        verificationStatus: EventVerificationStatus.verified,
        instructionsKey: 'ev4_instructions',
        isFeatured: false,
        createdAt: DateTime(now.year, now.month, 8),
      ),

      // 5. Religious Event: Weekly Devotional Haripath & Bhajan
      VillageEvent(
        id: 'ev_weekly_bhajan',
        titleKey: 'ev5_title',
        category: 'religious_events',
        descriptionKey: 'ev5_desc',
        startDateTime: DateTime(now.year, now.month, now.day, 18, 30),
        endDateTime: DateTime(now.year, now.month, now.day, 20, 30),
        venueKey: 'ev5_venue',
        address: 'Mandir Galli, Vitthal Rukmini Mandir, Dhawalpuri',
        latitude: 19.0350,
        longitude: 74.3730,
        organizerKey: 'ev5_organizer',
        contactInformation: '+91 94033 87654',
        eventStatus: EventStatus.ongoing,
        sourceName: 'Varkari Bhajan Mandal Dhawalpuri',
        verificationStatus: EventVerificationStatus.verified,
        instructionsKey: 'ev5_instructions',
        isFeatured: false,
        createdAt: DateTime(now.year, now.month, 10),
      ),

      // 6. Educational Event: Annual Science Exhibition & Primary School Gathering (Past/Completed)
      VillageEvent(
        id: 'ev_science_exhibition',
        titleKey: 'ev6_title',
        category: 'educational_activities',
        descriptionKey: 'ev6_desc',
        startDateTime: DateTime(now.year, now.month, now.day - 7, 9, 30),
        endDateTime: DateTime(now.year, now.month, now.day - 7, 16, 0),
        venueKey: 'ev6_venue',
        address: 'Station Road, ZP Primary School Main Hall, Dhawalpuri',
        latitude: 19.0335,
        longitude: 74.3710,
        organizerKey: 'ev6_organizer',
        contactInformation: '+91 2488 245310',
        eventStatus: EventStatus.completed,
        sourceName: 'ZP Primary School Administration',
        verificationStatus: EventVerificationStatus.verified,
        instructionsKey: 'ev6_instructions',
        isFeatured: false,
        createdAt: DateTime(now.year, now.month, 1),
      ),
    ];
  }

  @override
  Future<List<VillageEvent>> getAllEvents() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final events = verifiedEvents;
    events.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    return events;
  }

  @override
  Future<List<VillageEvent>> getUpcomingEvents() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final events = verifiedEvents.where((e) {
      // Keep upcoming and ongoing, exclude completed
      return e.computedStatus == EventStatus.upcoming ||
          e.computedStatus == EventStatus.ongoing ||
          e.computedStatus == EventStatus.postponed;
    }).toList();

    // Sort chronologically
    events.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    return events;
  }

  @override
  Future<VillageEvent?> getEventById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return verifiedEvents.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<VillageEvent?> getFeaturedEvent() async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return verifiedEvents.firstWhere(
        (e) => e.isFeatured && e.computedStatus != EventStatus.completed,
      );
    } catch (_) {
      final upcoming = await getUpcomingEvents();
      return upcoming.isNotEmpty ? upcoming.first : null;
    }
  }

  @override
  Future<List<VillageEvent>> searchEvents(
    String query, {
    String? category,
    bool includePast = false,
  }) async {
    final cleanQuery = query.trim().toLowerCase();
    var events = includePast ? await getAllEvents() : await getUpcomingEvents();

    if (category != null && category != 'all' && category.isNotEmpty) {
      events = events.where((e) => e.category == category).toList();
    }

    if (cleanQuery.isEmpty) return events;

    return events.where((e) {
      // 1. Direct key and raw fields matching
      if (e.titleKey.toLowerCase().contains(cleanQuery) ||
          e.descriptionKey.toLowerCase().contains(cleanQuery) ||
          e.venueKey.toLowerCase().contains(cleanQuery) ||
          e.category.toLowerCase().contains(cleanQuery) ||
          (e.organizerKey != null && e.organizerKey!.toLowerCase().contains(cleanQuery)) ||
          (e.address != null && e.address!.toLowerCase().contains(cleanQuery)) ||
          (e.sourceName != null && e.sourceName!.toLowerCase().contains(cleanQuery))) {
        return true;
      }

      // 2. Search across all localized translations (EN, MR, HI)
      for (final langMap in AppTranslations.values.values) {
        final title = langMap[e.titleKey]?.toLowerCase() ?? '';
        final desc = langMap[e.descriptionKey]?.toLowerCase() ?? '';
        final venue = langMap[e.venueKey]?.toLowerCase() ?? '';
        final org = e.organizerKey != null ? (langMap[e.organizerKey!]?.toLowerCase() ?? '') : '';

        if (title.contains(cleanQuery) ||
            desc.contains(cleanQuery) ||
            venue.contains(cleanQuery) ||
            org.contains(cleanQuery)) {
          return true;
        }
      }

      return false;
    }).toList();
  }

  @override
  Future<List<VillageEvent>> getEventsForDate(DateTime date) async {
    final all = await getAllEvents();
    return all.where((e) {
      final s = e.startDateTime;
      final startDay = DateTime(s.year, s.month, s.day);

      if (e.endDateTime != null) {
        final endDay = DateTime(
          e.endDateTime!.year,
          e.endDateTime!.month,
          e.endDateTime!.day,
        );
        final checkDay = DateTime(date.year, date.month, date.day);
        return (checkDay.isAtSameMomentAs(startDay) || checkDay.isAfter(startDay)) &&
            (checkDay.isAtSameMomentAs(endDay) || checkDay.isBefore(endDay));
      }

      return s.year == date.year && s.month == date.month && s.day == date.day;
    }).toList();
  }

  @override
  Future<List<VillageEvent>> getEventsForMonth(int year, int month) async {
    final all = await getAllEvents();
    return all.where((e) {
      final s = e.startDateTime;
      if (s.year == year && s.month == month) return true;
      if (e.endDateTime != null) {
        final end = e.endDateTime!;
        if (end.year == year && end.month == month) return true;
        // Spans across months
        final monthStart = DateTime(year, month, 1);
        final monthEnd = DateTime(year, month + 1, 0, 23, 59, 59);
        return s.isBefore(monthEnd) && end.isAfter(monthStart);
      }
      return false;
    }).toList();
  }

  @override
  Future<bool> suggestEvent(EventSuggestion suggestion) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _suggestions.add(suggestion);
    return true;
  }

  @override
  List<EventSuggestion> getSuggestions() {
    return List.unmodifiable(_suggestions);
  }
}
