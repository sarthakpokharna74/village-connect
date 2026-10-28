import 'package:flutter/foundation.dart';
import '../../../../core/localization/translations.dart';
import '../models/place_model.dart';

/// Contract for Important Places data operations in GramConnect.
/// Keeps data access clean and decoupled for future Supabase or REST API integrations.
abstract class PlaceRepository {
  Future<List<Place>> getPlaces({String? category});
  Future<List<Place>> getReferenceLandmarks();
  Future<Place?> getPlaceById(String id);
  Future<List<Place>> searchPlaces(String query, {String? category});
  Future<bool> suggestPlace(PlaceSuggestion suggestion);
  List<PlaceSuggestion> getSuggestions();
  Future<bool> reportIncorrectInformation(PlaceReport report);
  List<PlaceReport> getReports();
}

/// Mock/Local Place Repository implementation.
/// Implements safe references for Dhawalpuri without fabricating fake coordinates or phone numbers.
class MockPlaceRepository implements PlaceRepository {
  static final MockPlaceRepository _instance = MockPlaceRepository._internal();
  factory MockPlaceRepository() => _instance;
  MockPlaceRepository._internal();

  final List<PlaceSuggestion> _suggestions = [];
  final List<PlaceReport> _reports = [];

  // Local Reference Landmarks (Dhawalpuri)
  // IMPORTANT: No fabricated coordinates, phone numbers, or opening hours.
  static const Place durgadeviTemple = Place(
    id: 'ref_temple',
    nameKey: 'ref_temple_name',
    descriptionKey: 'ref_temple_desc',
    addressKey: 'ref_temple_loc',
    category: 'temples_landmarks',
    verificationStatus: PlaceVerificationStatus.referenceLandmark,
    isReferenceLandmark: true,
    latitude: null, // Precise directions unavailable without verified GPS
    longitude: null,
    phoneNumber: null, // No verified phone number on record
    openingHoursKey: null,
    facilities: null,
    source: 'Local Reference Landmark (Dhawalpuri)',
  );

  static const Place kaluDamArea = Place(
    id: 'ref_dam',
    nameKey: 'ref_dam_name',
    descriptionKey: 'ref_dam_desc',
    addressKey: 'ref_dam_loc',
    category: 'water_utilities',
    verificationStatus: PlaceVerificationStatus.referenceLandmark,
    isReferenceLandmark: true,
    latitude: null,
    longitude: null,
    phoneNumber: null,
    openingHoursKey: null,
    facilities: null,
    source: 'Local Reference Landmark (Dhawalpuri)',
  );

  // Prototype Sample Places (Dhawalpuri)
  // Clearly identified as sample content for development demonstration
  static const List<Place> _initialPlaces = [
    durgadeviTemple,
    kaluDamArea,
    Place(
      id: 'pl1',
      nameKey: 'pl1_name',
      descriptionKey: 'pl1_desc',
      addressKey: 'pl1_loc',
      category: 'schools_education',
      verificationStatus: PlaceVerificationStatus.sample,
      latitude: null,
      longitude: null,
      phoneNumber: null,
      openingHoursKey: null,
      facilities: null,
      source: 'Development Prototype Sample',
    ),
    Place(
      id: 'pl2',
      nameKey: 'pl2_name',
      descriptionKey: 'pl2_desc',
      addressKey: 'pl2_loc',
      category: 'healthcare',
      verificationStatus: PlaceVerificationStatus.sample,
      latitude: null,
      longitude: null,
      phoneNumber: null,
      openingHoursKey: null,
      facilities: null,
      source: 'Development Prototype Sample',
    ),
    Place(
      id: 'pl3',
      nameKey: 'pl3_name',
      descriptionKey: 'pl3_desc',
      addressKey: 'pl3_loc',
      category: 'government_offices',
      verificationStatus: PlaceVerificationStatus.sample,
      latitude: null,
      longitude: null,
      phoneNumber: null,
      openingHoursKey: null,
      facilities: null,
      source: 'Development Prototype Sample',
    ),
    Place(
      id: 'pl4',
      nameKey: 'pl4_name',
      descriptionKey: 'pl4_desc',
      addressKey: 'pl4_loc',
      category: 'temples_landmarks',
      verificationStatus: PlaceVerificationStatus.sample,
      latitude: null,
      longitude: null,
      phoneNumber: null,
      openingHoursKey: null,
      facilities: null,
      source: 'Development Prototype Sample',
    ),
    Place(
      id: 'pl5',
      nameKey: 'pl5_name',
      descriptionKey: 'pl5_desc',
      addressKey: 'pl5_loc',
      category: 'agri_services',
      verificationStatus: PlaceVerificationStatus.sample,
      latitude: null,
      longitude: null,
      phoneNumber: null,
      openingHoursKey: null,
      facilities: null,
      source: 'Development Prototype Sample',
    ),
    Place(
      id: 'pl6',
      nameKey: 'pl6_name',
      descriptionKey: 'pl6_desc',
      addressKey: 'pl6_loc',
      category: 'transport',
      verificationStatus: PlaceVerificationStatus.sample,
      latitude: null,
      longitude: null,
      phoneNumber: null,
      openingHoursKey: null,
      facilities: null,
      source: 'Development Prototype Sample',
    ),
    Place(
      id: 'pl7',
      nameKey: 'pl7_name',
      descriptionKey: 'pl7_desc',
      addressKey: 'pl7_loc',
      category: 'water_utilities',
      verificationStatus: PlaceVerificationStatus.sample,
      latitude: null,
      longitude: null,
      phoneNumber: null,
      openingHoursKey: null,
      facilities: null,
      source: 'Development Prototype Sample',
    ),
    Place(
      id: 'pl8',
      nameKey: 'pl8_name',
      descriptionKey: 'pl8_desc',
      addressKey: 'pl8_loc',
      category: 'other_places',
      verificationStatus: PlaceVerificationStatus.sample,
      latitude: null,
      longitude: null,
      phoneNumber: null,
      openingHoursKey: null,
      facilities: null,
      source: 'Development Prototype Sample',
    ),
  ];

  @override
  Future<List<Place>> getPlaces({String? category}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (category == null || category == 'all' || category.isEmpty) {
      return List.unmodifiable(_initialPlaces);
    }
    return _initialPlaces.where((p) => p.category == category).toList();
  }

  @override
  Future<List<Place>> getReferenceLandmarks() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _initialPlaces.where((p) => p.isReferenceLandmark).toList();
  }

  @override
  Future<Place?> getPlaceById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _initialPlaces.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Place>> searchPlaces(String query, {String? category}) async {
    final cleanQuery = query.trim().toLowerCase();

    return _initialPlaces.where((place) {
      // Category filter check
      if (category != null && category != 'all' && category.isNotEmpty) {
        if (place.category != category) return false;
      }

      if (cleanQuery.isEmpty) return true;

      // Match raw keys
      if (place.nameKey.toLowerCase().contains(cleanQuery) ||
          (place.descriptionKey?.toLowerCase().contains(cleanQuery) ?? false) ||
          (place.addressKey?.toLowerCase().contains(cleanQuery) ?? false) ||
          place.category.toLowerCase().contains(cleanQuery)) {
        return true;
      }

      // Match localized text across all supported dictionaries (English, Marathi, Hindi)
      for (final langMap in AppTranslations.values.values) {
        final name = langMap[place.nameKey]?.toLowerCase() ?? '';
        final desc = place.descriptionKey != null ? (langMap[place.descriptionKey!]?.toLowerCase() ?? '') : '';
        final loc = place.addressKey != null ? (langMap[place.addressKey!]?.toLowerCase() ?? '') : '';
        final catName = langMap['cat_places_${place.category}']?.toLowerCase() ?? '';

        if (name.contains(cleanQuery) ||
            desc.contains(cleanQuery) ||
            loc.contains(cleanQuery) ||
            catName.contains(cleanQuery)) {
          return true;
        }
      }

      return false;
    }).toList();
  }

  @override
  Future<bool> suggestPlace(PlaceSuggestion suggestion) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _suggestions.add(suggestion);
    if (kDebugMode) {
      print('[MockPlaceRepository] Recorded place suggestion: ${suggestion.placeName} (${suggestion.category})');
    }
    return true;
  }

  @override
  List<PlaceSuggestion> getSuggestions() {
    return List.unmodifiable(_suggestions);
  }

  @override
  Future<bool> reportIncorrectInformation(PlaceReport report) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _reports.add(report);
    if (kDebugMode) {
      print('[MockPlaceRepository] Recorded place report: ${report.placeName} - ${report.issueType}');
    }
    return true;
  }

  @override
  List<PlaceReport> getReports() {
    return List.unmodifiable(_reports);
  }
}
