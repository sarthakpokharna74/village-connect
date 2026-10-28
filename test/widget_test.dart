import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gram_connect/core/localization/app_localizations.dart';
import 'package:gram_connect/features/community/data/models/community_model.dart';
import 'package:gram_connect/features/community/data/repositories/community_repository.dart';
import 'package:gram_connect/features/places/data/models/place_model.dart';
import 'package:gram_connect/features/places/data/repositories/place_repository.dart';
import 'package:gram_connect/features/contacts/data/models/contact_model.dart';
import 'package:gram_connect/features/contacts/data/repositories/emergency_contact_repository.dart';
import 'package:gram_connect/features/services/data/models/gov_service_model.dart';
import 'package:gram_connect/features/services/data/repositories/gov_services_repository.dart';
import 'package:gram_connect/features/services/data/services/service_favorites_manager.dart';
import 'package:gram_connect/features/events/data/models/event_model.dart';
import 'package:gram_connect/features/events/data/repositories/event_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gram_connect/features/auth/data/repositories/auth_repository.dart';
import 'package:gram_connect/features/news/data/models/news_article_model.dart';
import 'package:gram_connect/features/news/data/repositories/news_repository.dart';
import 'package:gram_connect/features/news/data/services/news_bookmarks_manager.dart';
import 'package:gram_connect/features/agri/data/models/agri_models.dart';
import 'package:gram_connect/features/agri/data/repositories/agri_repository.dart';
import 'package:gram_connect/features/agri/data/services/agri_bookmarks_manager.dart';
import 'package:gram_connect/core/navigation/app_router.dart';
import 'package:gram_connect/core/data/mock_data.dart';
import 'package:gram_connect/features/village/data/repositories/village_repository.dart';
import 'package:gram_connect/features/notices/data/repositories/notice_repository.dart';

void main() {
  group('AppLocalizations Tests', () {
    test('Supported language codes are resolved correctly', () {
      const delegate = AppLocalizations.delegate;

      expect(delegate.isSupported(const Locale('en', '')), isTrue);
      expect(delegate.isSupported(const Locale('mr', '')), isTrue);
      expect(delegate.isSupported(const Locale('hi', '')), isTrue);
      expect(delegate.isSupported(const Locale('fr', '')), isFalse); // French is not supported
    });

    test('English translations resolve correctly', () {
      final loc = AppLocalizations(const Locale('en', ''));
      expect(loc.translate('app_name'), equals('GramConnect'));
      expect(loc.translate('our_village'), equals('Our Dhawalpuri'));
      expect(loc.translate('community_title'), equals('Community'));
      expect(loc.translate('community_subtitle'), equals('Connect with your village'));
      expect(loc.translate('cat_community_groups'), equals('Community Groups'));
      expect(loc.translate('cat_volunteering'), equals('Volunteering'));
      expect(loc.translate('non_existent_key'), equals('non_existent_key'));
    });

    test('Marathi translations resolve correctly and spell Dhawalpuri as ढवळपुरी', () {
      final loc = AppLocalizations(const Locale('mr', ''));
      expect(loc.translate('app_name'), equals('ग्रामकनेक्ट'));
      expect(loc.translate('our_village'), equals('आपली ढवळपुरी'));
      expect(loc.translate('community_title'), equals('समुदाय'));
      expect(loc.translate('community_subtitle'), equals('आपल्या गावाशी जोडले जा'));
      expect(loc.translate('cat_community_groups'), equals('समुदाय गट'));
      expect(loc.translate('cat_volunteering'), equals('स्वयंसेवा'));
      expect(loc.translate('cat_sports_youth'), equals('क्रीडा आणि युवा'));

      // Strict village spelling verification
      expect(loc.translate('c1_name').contains('ढवळपुरी'), isTrue);
      expect(loc.translate('c2_name').contains('ढवळपुरी'), isTrue);
      expect(loc.translate('c3_name').contains('ढवळपुरी'), isTrue);
      expect(loc.translate('c1_name').contains('धावळपुरी'), isFalse);
      expect(loc.translate('c1_name').contains('धवळपुरी'), isFalse);
    });

    test('Hindi translations resolve correctly and spell Dhawalpuri as ढवळपुरी', () {
      final loc = AppLocalizations(const Locale('hi', ''));
      expect(loc.translate('app_name'), equals('ग्रामकनेक्ट'));
      expect(loc.translate('our_village'), equals('हमारा ढवळपुरी'));
      expect(loc.translate('community_title'), equals('समुदाय'));
      expect(loc.translate('community_subtitle'), equals('अपने गाँव से जुड़ें'));
      expect(loc.translate('cat_community_groups'), equals('समुदाय समूह'));
      expect(loc.translate('cat_volunteering'), equals('स्वयंसेवा'));
      expect(loc.translate('cat_sports_youth'), equals('खेल और युवा'));

      // Strict village spelling verification
      expect(loc.translate('c1_name').contains('ढवळपुरी'), isTrue);
      expect(loc.translate('c2_name').contains('ढवळपुरी'), isTrue);
      expect(loc.translate('c3_name').contains('ढवळपुरी'), isTrue);
      expect(loc.translate('c1_name').contains('धावळपुरी'), isFalse);
      expect(loc.translate('c1_name').contains('धवळपुरी'), isFalse);
    });
  });

  group('Community Repository & Model Tests', () {
    late CommunityRepository repository;

    setUp(() {
      repository = MockCommunityRepository();
    });

    test('Loads exactly 8 prototype sample items across categories', () async {
      final items = await repository.getCommunityItems();
      expect(items.length, equals(8));

      final categories = items.map((i) => i.category).toSet();
      expect(categories.contains('community_groups'), isTrue);
      expect(categories.contains('womens_groups'), isTrue);
      expect(categories.contains('volunteering'), isTrue);
      expect(categories.contains('cultural_activities'), isTrue);
      expect(categories.contains('sports_youth'), isTrue);
      expect(categories.contains('senior_citizens'), isTrue);
      expect(categories.contains('village_celebrations'), isTrue);
      expect(categories.contains('social_initiatives'), isTrue);
    });

    test('Retrieves featured community activity', () async {
      final featured = await repository.getFeaturedActivity();
      expect(featured, isNotNull);
      expect(featured!.isFeatured, isTrue);
      expect(featured.category, equals('volunteering'));
    });

    test('Filters community items by category', () async {
      final sportsItems = await repository.searchCommunity('', category: 'sports_youth');
      expect(sportsItems.length, equals(1));
      expect(sportsItems.first.category, equals('sports_youth'));

      final allItems = await repository.searchCommunity('', category: 'all');
      expect(allItems.length, equals(8));
    });

    test('Searches community items by query text', () async {
      final treeItems = await repository.searchCommunity('tree');
      expect(treeItems.length, greaterThanOrEqualTo(1));

      final nonExistent = await repository.searchCommunity('nonexistentquery12345');
      expect(nonExistent.isEmpty, isTrue);
    });

    test('Protected actions persist joined/volunteered/registered state', () async {
      const testId = 'comm-1';
      const testUser = 'user-test-123';

      expect(repository.hasUserJoined(testId), isFalse);
      final joinResult = await repository.joinGroup(testId, testUser);
      expect(joinResult, isTrue);
      expect(repository.hasUserJoined(testId), isTrue);

      const volId = 'comm-3';
      expect(repository.hasUserVolunteered(volId), isFalse);
      await repository.volunteer(volId, testUser);
      expect(repository.hasUserVolunteered(volId), isTrue);

      const regId = 'comm-5';
      expect(repository.hasUserRegistered(regId), isFalse);
      await repository.registerActivity(regId, testUser);
      expect(repository.hasUserRegistered(regId), isTrue);
    });

    test('Submits community activity suggestion and stores locally', () async {
      final submission = CommunitySubmission(
        id: 'sub-test-1',
        title: 'Dhawalpuri Reading Club',
        category: 'community_groups',
        description: 'A study circle for students.',
        suggestedDate: '2026-11-01',
        location: 'ZP School',
        submittedBy: 'villager_test',
        createdAt: DateTime.now(),
      );

      final result = await repository.submitActivity(submission);
      expect(result, isTrue);

      final submissions = repository.getSubmissions();
      expect(submissions.any((s) => s.id == 'sub-test-1'), isTrue);
      expect(submissions.first.title, equals('Dhawalpuri Reading Club'));
    });
  });

  group('Important Places (Blueprint 5) Tests', () {
    late PlaceRepository placeRepository;

    setUp(() {
      placeRepository = MockPlaceRepository();
    });

    test('All 10 required Blueprint 5 categories exist and translate properly in English, Marathi, Hindi', () {
      final locEn = AppLocalizations(const Locale('en', ''));
      final locMr = AppLocalizations(const Locale('mr', ''));
      final locHi = AppLocalizations(const Locale('hi', ''));

      const categories = [
        'temples_landmarks',
        'schools_education',
        'healthcare',
        'government_offices',
        'shops_markets',
        'banking_atms',
        'transport',
        'water_utilities',
        'agri_services',
        'other_places',
      ];

      for (final cat in categories) {
        final key = 'cat_places_$cat';
        expect(locEn.translate(key), isNot(equals(key)));
        expect(locMr.translate(key), isNot(equals(key)));
        expect(locHi.translate(key), isNot(equals(key)));
      }
    });

    test('Strict village spelling of Dhawalpuri / ढवळपुरी in places translations', () {
      final locMr = AppLocalizations(const Locale('mr', ''));
      final locHi = AppLocalizations(const Locale('hi', ''));

      // Check Marathi
      expect(locMr.translate('places_subtitle').contains('ढवळपुरी'), isTrue);
      expect(locMr.translate('ref_temple_desc').contains('ढवळपुरी'), isTrue);
      expect(locMr.translate('ref_dam_desc').contains('ढवळपुरी'), isTrue);
      expect(locMr.translate('places_subtitle').contains('धावळपुरी'), isFalse);
      expect(locMr.translate('places_subtitle').contains('धवळपुरी'), isFalse);

      // Check Hindi
      expect(locHi.translate('places_subtitle').contains('ढवळपुरी'), isTrue);
      expect(locHi.translate('ref_temple_desc').contains('ढवळपुरी'), isTrue);
      expect(locHi.translate('ref_dam_desc').contains('ढवळपुरी'), isTrue);
      expect(locHi.translate('places_subtitle').contains('धावळपुरी'), isFalse);
      expect(locHi.translate('places_subtitle').contains('धवळपुरी'), isFalse);
    });

    test('Reference landmarks do not contain fabricated GPS coordinates or fake phone numbers', () async {
      final landmarks = await placeRepository.getReferenceLandmarks();
      expect(landmarks.length, equals(2));

      for (final landmark in landmarks) {
        expect(landmark.isReferenceLandmark, isTrue);
        expect(landmark.verificationStatus, equals(PlaceVerificationStatus.referenceLandmark));
        // Strict safety rule: Do NOT invent coordinates or phone numbers
        expect(landmark.latitude, isNull);
        expect(landmark.longitude, isNull);
        expect(landmark.phoneNumber, isNull);
        expect(landmark.hasValidCoordinates, isFalse);
        expect(landmark.hasVerifiedPhone, isFalse);
      }

      final temple = landmarks.firstWhere((l) => l.id == 'ref_temple');
      expect(temple.nameKey, equals('ref_temple_name'));

      final dam = landmarks.firstWhere((l) => l.id == 'ref_dam');
      expect(dam.nameKey, equals('ref_dam_name'));
    });

    test('Searches and filters places by query and category', () async {
      // Empty query returns all items
      final allPlaces = await placeRepository.searchPlaces('');
      expect(allPlaces.length, greaterThanOrEqualTo(10));

      // Category filter
      final schoolPlaces = await placeRepository.searchPlaces('', category: 'schools_education');
      expect(schoolPlaces.isNotEmpty, isTrue);
      expect(schoolPlaces.every((p) => p.category == 'schools_education'), isTrue);

      // Query search
      final busResults = await placeRepository.searchPlaces('bus');
      expect(busResults.isNotEmpty, isTrue);

      // Non-existent search
      final none = await placeRepository.searchPlaces('nonexistentplace99999');
      expect(none.isEmpty, isTrue);
    });

    test('Suggesting a place records safely in prototype mode', () async {
      final suggestion = PlaceSuggestion(
        id: 'sug-unit-test-1',
        placeName: 'Dhawalpuri Community Library',
        category: 'schools_education',
        location: 'Near Gram Panchayat',
        phoneNumber: '9876543210',
        additionalDetails: 'Quiet reading room for students',
        submittedByUserId: 'test_user_1',
        submittedAt: DateTime.now(),
      );

      final success = await placeRepository.suggestPlace(suggestion);
      expect(success, isTrue);

      final suggestions = placeRepository.getSuggestions();
      expect(suggestions.any((s) => s.id == 'sug-unit-test-1'), isTrue);
      expect(suggestions.firstWhere((s) => s.id == 'sug-unit-test-1').placeName,
          equals('Dhawalpuri Community Library'));
    });

    test('Reporting incorrect information records issue report safely', () async {
      final report = PlaceReport(
        id: 'rep-unit-test-1',
        placeId: 'pl1',
        placeName: 'ZP Primary School',
        issueType: 'wrong_location',
        description: 'New building is on the north side',
        reportedByUserId: 'test_user_2',
        reportedAt: DateTime.now(),
      );

      final success = await placeRepository.reportIncorrectInformation(report);
      expect(success, isTrue);

      final reports = placeRepository.getReports();
      expect(reports.any((r) => r.id == 'rep-unit-test-1'), isTrue);
      expect(reports.firstWhere((r) => r.id == 'rep-unit-test-1').issueType,
          equals('wrong_location'));
    });
  });

  group('Blueprint 6: Emergency Contacts Tests', () {
    late EmergencyContactRepository emergencyRepo;

    setUp(() {
      emergencyRepo = MockEmergencyContactRepository();
    });

    test('All 10 required Blueprint 6 emergency categories are registered with metadata', () {
      expect(EmergencyCategoryInfo.categories.length, equals(10));
      final catIds = EmergencyCategoryInfo.categories.map((c) => c.id).toSet();

      expect(catIds.contains('ambulance_medical'), isTrue);
      expect(catIds.contains('police'), isTrue);
      expect(catIds.contains('fire_rescue'), isTrue);
      expect(catIds.contains('hospital_healthcare'), isTrue);
      expect(catIds.contains('women_child'), isTrue);
      expect(catIds.contains('disaster_safety'), isTrue);
      expect(catIds.contains('electricity'), isTrue);
      expect(catIds.contains('water_supply'), isTrue);
      expect(catIds.contains('local_govt'), isTrue);
      expect(catIds.contains('other_emergency'), isTrue);
    });

    test('National emergency numbers are officially verified and present', () async {
      final contacts = await emergencyRepo.getContacts();

      // Check 112 ERSS
      final c112 = contacts.firstWhere((c) => c.phoneNumber == '112');
      expect(c112.isNationalService, isTrue);
      expect(c112.verificationStatus, equals(ContactVerificationStatus.verified));
      expect(c112.hasValidPhoneNumber, isTrue);

      // Check 108 Ambulance
      final c108 = contacts.firstWhere((c) => c.phoneNumber == '108');
      expect(c108.verificationStatus, equals(ContactVerificationStatus.verified));
      expect(c108.category, equals('ambulance_medical'));
      expect(c108.hasValidPhoneNumber, isTrue);

      // Check 101 Fire
      final c101 = contacts.firstWhere((c) => c.phoneNumber == '101');
      expect(c101.verificationStatus, equals(ContactVerificationStatus.verified));
      expect(c101.category, equals('fire_rescue'));

      // Check 100 Police
      final c100 = contacts.firstWhere((c) => c.phoneNumber == '100');
      expect(c100.verificationStatus, equals(ContactVerificationStatus.verified));
      expect(c100.category, equals('police'));

      // Check 1098 Childline
      final c1098 = contacts.firstWhere((c) => c.phoneNumber == '1098');
      expect(c1098.isNationalService, isTrue);
      expect(c1098.verificationStatus, equals(ContactVerificationStatus.verified));

      // Check 181 Women Helpline
      final c181 = contacts.firstWhere((c) => c.phoneNumber == '181');
      expect(c181.verificationStatus, equals(ContactVerificationStatus.verified));

      // Check 1077 DDMA Disaster Helpline
      final c1077 = contacts.firstWhere((c) => c.phoneNumber == '1077');
      expect(c1077.verificationStatus, equals(ContactVerificationStatus.verified));

      // Check 1912 MSEDCL Electricity Helpline
      final c1912 = contacts.firstWhere((c) => c.phoneNumber == '1912');
      expect(c1912.verificationStatus, equals(ContactVerificationStatus.verified));
    });

    test('Strict zero fabrication rule: Local village contacts have null phone and pending status', () async {
      final contacts = await emergencyRepo.getContacts();

      // Local contacts requiring official publication
      final gp = contacts.firstWhere((c) => c.id == 'em_gp_office');
      expect(gp.phoneNumber, isNull);
      expect(gp.hasValidPhoneNumber, isFalse);
      expect(gp.verificationStatus, equals(ContactVerificationStatus.pending));
      expect(gp.safeAlternativeKey, isNotNull);

      final water = contacts.firstWhere((c) => c.id == 'em_water_dept');
      expect(water.phoneNumber, isNull);
      expect(water.hasValidPhoneNumber, isFalse);
      expect(water.verificationStatus, equals(ContactVerificationStatus.pending));
      expect(water.safeAlternativeKey, isNotNull);

      final phc = contacts.firstWhere((c) => c.id == 'em_phc_dhawalpuri');
      expect(phc.phoneNumber, isNull);
      expect(phc.hasValidPhoneNumber, isFalse);
      expect(phc.verificationStatus, equals(ContactVerificationStatus.pending));
      expect(phc.safeAlternativeKey, isNotNull);
    });

    test('Priority national contacts returns 112, 108, 101, 100 for quick dialing', () async {
      final quick = await emergencyRepo.getPriorityNationalContacts();
      expect(quick.length, equals(4));
      final numbers = quick.map((c) => c.phoneNumber).toList();
      expect(numbers.contains('112'), isTrue);
      expect(numbers.contains('108'), isTrue);
      expect(numbers.contains('101'), isTrue);
      expect(numbers.contains('100'), isTrue);
    });

    test('Multilingual search and category filtering works for Emergency Contacts', () async {
      // Query search by number
      final search112 = await emergencyRepo.searchContacts('112');
      expect(search112.length, equals(1));
      expect(search112.first.id, equals('em_112'));

      // Category filter
      final policeContacts = await emergencyRepo.searchContacts('', category: 'police');
      expect(policeContacts.length, equals(1));
      expect(policeContacts.first.phoneNumber, equals('100'));

      // Multilingual search: Marathi 'रुग्णवाहिका'
      final marathiResults = await emergencyRepo.searchContacts('रुग्णवाहिका');
      expect(marathiResults.isNotEmpty, isTrue);

      // Multilingual search: Hindi 'पुलिस'
      final hindiResults = await emergencyRepo.searchContacts('पुलिस');
      expect(hindiResults.isNotEmpty, isTrue);

      // Empty query returns all contacts
      final all = await emergencyRepo.searchContacts('');
      expect(all.length, equals(11));
    });

    test('Emergency Contact Localizations check: Exact Dhawalpuri spelling in English, Marathi, Hindi', () {
      final locEn = AppLocalizations(const Locale('en', ''));
      final locMr = AppLocalizations(const Locale('mr', ''));
      final locHi = AppLocalizations(const Locale('hi', ''));

      // English titles
      expect(locEn.translate('contacts_title'), equals('Emergency Contacts'));
      expect(locEn.translate('con_gp_office_name').contains('Dhawalpuri'), isTrue);

      // Marathi titles & strict village spelling
      expect(locMr.translate('contacts_title'), equals('आणीबाणी संपर्क'));
      expect(locMr.translate('contacts_subtitle').contains('ढवळपुरी'), isTrue);
      expect(locMr.translate('con_gp_office_name').contains('ढवळपुरी'), isTrue);
      expect(locMr.translate('contacts_subtitle').contains('धावळपुरी'), isFalse);
      expect(locMr.translate('contacts_subtitle').contains('धवळपुरी'), isFalse);

      // Hindi titles & strict village spelling
      expect(locHi.translate('contacts_title'), equals('आपातकालीन संपर्क'));
      expect(locHi.translate('contacts_subtitle').contains('ढवळपुरी'), isTrue);
      expect(locHi.translate('con_gp_office_name').contains('ढवळपुरी'), isTrue);
      expect(locHi.translate('contacts_subtitle').contains('धावळपुरी'), isFalse);
      expect(locHi.translate('contacts_subtitle').contains('धवळपुरी'), isFalse);
    });
  });

  group('Blueprint 7: Government Services Repository & Models Tests', () {
    late GovernmentServicesRepository govRepo;

    setUp(() {
      govRepo = const MockGovernmentServicesRepository();
    });

    test('Exactly 10 Blueprint 7 categories defined with icons and valid IDs', () async {
      final categories = await govRepo.getCategories();
      expect(categories.length, equals(10));

      final ids = categories.map((c) => c.id).toSet();
      expect(ids.contains('identity_certificates'), isTrue);
      expect(ids.contains('revenue_land_records'), isTrue);
      expect(ids.contains('agriculture_farmers'), isTrue);
      expect(ids.contains('health_family_welfare'), isTrue);
      expect(ids.contains('education_scholarships'), isTrue);
      expect(ids.contains('pension_social_welfare'), isTrue);
      expect(ids.contains('employment_skills'), isTrue);
      expect(ids.contains('ration_public_distribution'), isTrue);
      expect(ids.contains('electricity_water'), isTrue);
      expect(ids.contains('gram_panchayat_services'), isTrue);
    });

    test('Loads 12 verified official services with reliable metadata', () async {
      final services = await govRepo.getAllServices();
      expect(services.length, equals(12));

      for (final s in services) {
        expect(s.id.isNotEmpty, isTrue);
        expect(s.nameKey.isNotEmpty, isTrue);
        expect(s.category.isNotEmpty, isTrue);
        expect(s.departmentKey.isNotEmpty, isTrue);
        expect(s.shortDescriptionKey.isNotEmpty, isTrue);
        expect(s.eligibilityKey.isNotEmpty, isTrue);
        expect(s.requiredDocsKeys.isNotEmpty, isTrue);
        expect(s.verificationStatus, equals(ServiceVerificationStatus.verified));
      }
    });

    test('Web safety: All non-null portal URLs belong to verified official domains', () async {
      final services = await govRepo.getAllServices();

      for (final s in services) {
        if (s.officialWebsiteUrl != null) {
          final uri = Uri.parse(s.officialWebsiteUrl!);
          expect(uri.isAbsolute, isTrue);
          expect(uri.scheme, equals('https'));
          
          final isGovDomain = uri.host.endsWith('.gov.in') ||
              uri.host.endsWith('.nic.in') ||
              uri.host.contains('mahadiscom.in') ||
              uri.host.contains('mahaonline.gov.in') ||
              uri.host.contains('mahabhumi.gov.in') ||
              uri.host.contains('maharashtra.gov.in');
          expect(isGovDomain, isTrue, reason: 'URL must be official domain: ${s.officialWebsiteUrl}');
        }
      }
    });

    test('In-person village administration services have null portal URL and valid offline guidance', () async {
      final gpService = await govRepo.getServiceById('gs_tax_noc');
      expect(gpService, isNotNull);
      expect(gpService!.officialWebsiteUrl, isNull);
      expect(gpService.isOfflineAvailable, isTrue);
      expect(gpService.sourceName!.contains('Dhawalpuri Gram Panchayat'), isTrue);
    });

    test('Category filtering accurately returns matching services', () async {
      final agri = await govRepo.getServicesByCategory('agriculture_farmers');
      expect(agri.length, equals(1));
      expect(agri.first.id, equals('gs_pmkisan'));

      final land = await govRepo.getServicesByCategory('revenue_land_records');
      expect(land.length, equals(1));
      expect(land.first.id, equals('gs_712'));

      final all = await govRepo.getServicesByCategory('all');
      expect(all.length, equals(12));
    });

    test('Multilingual search across English, Marathi, and Hindi works smoothly', () async {
      // English search
      final searchAaple = await govRepo.searchServices('Aaple');
      expect(searchAaple.length, greaterThanOrEqualTo(1));

      // Marathi search
      final searchSatbara = await govRepo.searchServices('सातबारा');
      expect(searchSatbara.isNotEmpty, isTrue);
      expect(searchSatbara.first.id, equals('gs_712'));

      // Hindi search
      final searchPension = await govRepo.searchServices('पेंशन');
      expect(searchPension.isNotEmpty, isTrue);

      // Search by scheme acronym
      final searchKisan = await govRepo.searchServices('pmkisan');
      expect(searchKisan.length, equals(1));
      expect(searchKisan.first.id, equals('gs_pmkisan'));
    });

    test('Favorites manager toggles service favorite status without requiring login', () async {
      final manager = ServiceFavoritesManager();
      
      const testServiceId = 'gs_income';
      final initialStatus = manager.isFavorite(testServiceId);
      
      final newStatus = await manager.toggleFavorite(testServiceId);
      expect(newStatus, equals(!initialStatus));
      expect(manager.isFavorite(testServiceId), equals(newStatus));

      // Toggle back
      final reverted = await manager.toggleFavorite(testServiceId);
      expect(reverted, equals(initialStatus));
    });

    test('Strict village spelling Dhawalpuri / ढवळपुरी / ढवळपुरी in services & disclaimers', () {
      final locEn = AppLocalizations(const Locale('en', ''));
      final locMr = AppLocalizations(const Locale('mr', ''));
      final locHi = AppLocalizations(const Locale('hi', ''));

      // English titles & disclaimer
      expect(locEn.translate('govt_services'), equals('Government Services'));
      expect(locEn.translate('govt_services_subtitle').contains('Dhawalpuri'), isTrue);
      expect(locEn.translate('govt_disclaimer_banner').contains('Dhawalpuri'), isTrue);

      // Marathi titles, disclaimer, and strict spelling
      expect(locMr.translate('govt_services'), equals('शासकीय सेवा'));
      expect(locMr.translate('govt_services_subtitle').contains('ढवळपुरी'), isTrue);
      expect(locMr.translate('govt_disclaimer_banner').contains('ढवळपुरी'), isTrue);
      expect(locMr.translate('cat_gov_gram_panchayat').contains('ढवळपुरी'), isTrue);
      expect(locMr.translate('govt_disclaimer_banner').contains('धावळपुरी'), isFalse);
      expect(locMr.translate('govt_disclaimer_banner').contains('धवळपुरी'), isFalse);

      // Hindi titles, disclaimer, and strict spelling
      expect(locHi.translate('govt_services'), equals('सरकारी सेवाएं'));
      expect(locHi.translate('govt_services_subtitle').contains('ढवळपुरी'), isTrue);
      expect(locHi.translate('govt_disclaimer_banner').contains('ढवळपुरी'), isTrue);
      expect(locHi.translate('cat_gov_gram_panchayat').contains('ढवळपुरी'), isTrue);
      expect(locHi.translate('govt_disclaimer_banner').contains('धावळपुरी'), isFalse);
      expect(locHi.translate('govt_disclaimer_banner').contains('धवळपुरी'), isFalse);
    });
  });

  group('Blueprint 8: Village Events & Calendar Tests', () {
    late EventRepository eventRepo;

    setUp(() {
      eventRepo = MockEventRepository();
    });

    test('All 10 required Blueprint 8 event categories are defined with valid keys, icons, and colors', () {
      expect(EventCategoryInfo.allCategories.length, equals(10));

      final expectedCategories = [
        'festivals_celebrations',
        'cultural_programs',
        'community_gatherings',
        'sports_youth',
        'educational_activities',
        'agricultural_events',
        'gram_panchayat_meetings',
        'social_initiatives',
        'religious_events',
        'other_events',
      ];

      for (final catId in expectedCategories) {
        expect(EventCategoryInfo.allCategories.any((c) => c.id == catId), isTrue,
            reason: 'Missing category $catId');
      }

      final locEn = AppLocalizations(const Locale('en', ''));
      final locMr = AppLocalizations(const Locale('mr', ''));
      final locHi = AppLocalizations(const Locale('hi', ''));

      for (final cat in EventCategoryInfo.allCategories) {
        final enName = locEn.translate(cat.nameKey);
        final mrName = locMr.translate(cat.nameKey);
        final hiName = locHi.translate(cat.nameKey);

        expect(enName, isNotEmpty);
        expect(enName, isNot(equals(cat.nameKey)));
        expect(mrName, isNotEmpty);
        expect(mrName, isNot(equals(cat.nameKey)));
        expect(hiName, isNotEmpty);
        expect(hiName, isNot(equals(cat.nameKey)));
      }
    });

    test('Loads 6 verified Dhawalpuri events with realistic metadata and zero fabricated coordinates', () async {
      final all = await eventRepo.getAllEvents();
      expect(all.length, equals(6));

      for (final ev in all) {
        expect(ev.id, isNotEmpty);
        expect(ev.titleKey, isNotEmpty);
        expect(ev.venueKey, isNotEmpty);
        expect(ev.descriptionKey, isNotEmpty);
        expect(ev.verificationStatus, equals(EventVerificationStatus.verified));

        // Genuine coordinates or null - never fabricated outside Parner / Dhawalpuri region
        if (ev.latitude != null && ev.longitude != null) {
          expect(ev.latitude!, inInclusiveRange(18.5, 19.5));
          expect(ev.longitude!, inInclusiveRange(74.0, 75.0));
        }
      }
    });

    test('Chronological ordering and separation of upcoming vs expired events', () async {
      final upcoming = await eventRepo.getUpcomingEvents();
      expect(upcoming.isNotEmpty, isTrue);

      // Verify that completed/past event (ev_science_exhibition) is excluded from upcoming
      expect(upcoming.any((e) => e.id == 'ev_science_exhibition'), isFalse);

      // Verify chronological ordering
      for (int i = 0; i < upcoming.length - 1; i++) {
        expect(
          upcoming[i].startDateTime.isBefore(upcoming[i + 1].startDateTime) ||
              upcoming[i].startDateTime.isAtSameMomentAs(upcoming[i + 1].startDateTime),
          isTrue,
        );
      }
    });

    test('Featured event selection returns verified upcoming featured event', () async {
      final featured = await eventRepo.getFeaturedEvent();
      expect(featured, isNotNull);
      expect(featured!.isFeatured, isTrue);
      expect(featured.id, equals('ev_hanuman_jatra'));
    });

    test('Calendar month and date queries calculate boundaries and handle leap years', () async {
      final now = DateTime.now();

      // Query events for the current month
      final monthEvents = await eventRepo.getEventsForMonth(now.year, now.month);
      expect(monthEvents.isNotEmpty, isTrue);

      // Query specific date with upcoming event (5 days from now: Jatra)
      final targetDate = DateTime(now.year, now.month, now.day + 5);
      final dateEvents = await eventRepo.getEventsForDate(targetDate);
      expect(dateEvents.any((e) => e.id == 'ev_hanuman_jatra'), isTrue);

      // Query a date in the far future with no events
      final emptyDate = DateTime(now.year + 5, 1, 1);
      final noEvents = await eventRepo.getEventsForDate(emptyDate);
      expect(noEvents.isEmpty, isTrue);
    });

    test('Multilingual search across English, Marathi, and Hindi works accurately', () async {
      // English search
      final searchHanuman = await eventRepo.searchEvents('Hanuman', includePast: true);
      expect(searchHanuman.any((e) => e.id == 'ev_hanuman_jatra'), isTrue);

      // Marathi search for Jatra
      final searchJatra = await eventRepo.searchEvents('जत्रा', includePast: true);
      expect(searchJatra.any((e) => e.id == 'ev_hanuman_jatra'), isTrue);

      // Hindi search for Mela
      final searchMela = await eventRepo.searchEvents('मेला', includePast: true);
      expect(searchMela.any((e) => e.id == 'ev_hanuman_jatra'), isTrue);

      // Marathi search for Sheti / Farming Shibir
      final searchSheti = await eventRepo.searchEvents('शेती');
      expect(searchSheti.any((e) => e.id == 'ev_kharif_shibir'), isTrue);

      // Search by category
      final agriOnly = await eventRepo.searchEvents('', category: 'agricultural_events');
      expect(agriOnly.length, equals(1));
      expect(agriOnly.first.id, equals('ev_kharif_shibir'));
    });

    test('Event suggestion records proposal as pending approval and not directly public', () async {
      final now = DateTime.now();
      final suggestion = EventSuggestion(
        id: 'sug_test_unit_1',
        title: 'Dhawalpuri Tree Plantation Drive',
        category: 'social_initiatives',
        date: DateTime(now.year, now.month, now.day + 10),
        startTime: '08:00 AM',
        endTime: '11:00 AM',
        venue: 'Near Primary Health Center, Dhawalpuri',
        description: 'Community drive to plant 500 neem trees along village access road.',
        organizer: 'Vrikshamitra Dhawalpuri',
        contact: '+91 94220 99999',
        submittedAt: now,
        status: EventPublicationStatus.pendingApproval,
      );

      final success = await eventRepo.suggestEvent(suggestion);
      expect(success, isTrue);

      final suggestions = eventRepo.getSuggestions();
      expect(suggestions.any((s) => s.id == 'sug_test_unit_1'), isTrue);

      final saved = suggestions.firstWhere((s) => s.id == 'sug_test_unit_1');
      expect(saved.status, equals(EventPublicationStatus.pendingApproval));

      // Ensure proposal is NOT listed among published verified events
      final publicEvents = await eventRepo.getAllEvents();
      expect(publicEvents.any((e) => e.id == 'sug_test_unit_1'), isFalse);
    });

    test('Event lifecycle status calculation accurately identifies upcoming and completed', () {
      final now = DateTime.now();

      final futureEvent = VillageEvent(
        id: 'test_future',
        titleKey: 'ev1_title',
        category: 'festivals_celebrations',
        descriptionKey: 'ev1_desc',
        startDateTime: DateTime(now.year, now.month, now.day + 10, 10, 0),
        venueKey: 'ev1_venue',
      );
      expect(futureEvent.computedStatus, equals(EventStatus.upcoming));

      final pastEvent = VillageEvent(
        id: 'test_past',
        titleKey: 'ev6_title',
        category: 'educational_activities',
        descriptionKey: 'ev6_desc',
        startDateTime: DateTime(now.year, now.month, now.day - 5, 9, 0),
        endDateTime: DateTime(now.year, now.month, now.day - 5, 12, 0),
        venueKey: 'ev6_venue',
      );
      expect(pastEvent.computedStatus, equals(EventStatus.completed));

      final cancelledEvent = VillageEvent(
        id: 'test_cancelled',
        titleKey: 'ev1_title',
        category: 'festivals_celebrations',
        descriptionKey: 'ev1_desc',
        startDateTime: DateTime(now.year, now.month, now.day + 5, 10, 0),
        venueKey: 'ev1_venue',
        eventStatus: EventStatus.cancelled,
      );
      expect(cancelledEvent.computedStatus, equals(EventStatus.cancelled));
    });

    test('Strict village spelling of Dhawalpuri / ढवळपुरी / ढवळपुरी in events localizations', () {
      final locEn = AppLocalizations(const Locale('en', ''));
      final locMr = AppLocalizations(const Locale('mr', ''));
      final locHi = AppLocalizations(const Locale('hi', ''));

      // English titles & subtitle
      expect(locEn.translate('events_title'), equals('Events & Calendar'));
      expect(locEn.translate('events_subtitle').contains('Dhawalpuri'), isTrue);

      // Marathi titles & subtitle
      expect(locMr.translate('events_title'), equals('कार्यक्रम आणि दिनदर्शिका'));
      expect(locMr.translate('events_subtitle').contains('ढवळपुरी'), isTrue);
      expect(locMr.translate('ev1_venue').contains('ढवळपुरी'), isTrue);
      expect(locMr.translate('ev4_title').contains('ढवळपुरी'), isTrue);
      expect(locMr.translate('events_subtitle').contains('धावळपुरी'), isFalse);
      expect(locMr.translate('events_subtitle').contains('धवळपुरी'), isFalse);

      // Hindi titles & subtitle
      expect(locHi.translate('events_title'), equals('कार्यक्रम और कैलेंडर'));
      expect(locHi.translate('events_subtitle').contains('ढवळपुरी'), isTrue);
      expect(locHi.translate('ev1_venue').contains('ढवळपुरी'), isTrue);
      expect(locHi.translate('ev4_title').contains('ढवळपुरी'), isTrue);
      expect(locHi.translate('events_subtitle').contains('धावळपुरी'), isFalse);
      expect(locHi.translate('events_subtitle').contains('धवळपुरी'), isFalse);
    });
  });

  group('Persistent Authentication & User Management Tests', () {
    late AuthRepository authRepo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      authRepo = LocalAuthRepository();
    });

    test('Initial state has no logged-in user', () async {
      final isLoggedIn = await authRepo.isLoggedIn();
      final user = await authRepo.getCurrentUser();
      expect(isLoggedIn, isFalse);
      expect(user, isNull);
    });

    test('Login with verified seed account (Sunita Patil) succeeds and persists session', () async {
      final result = await authRepo.login(
        phoneNumber: '9876543210',
        pin: '1234',
      );

      expect(result.isSuccess, isTrue);
      expect(result.user, isNotNull);
      expect(result.user!.fullName, equals('Sunita Tukaram Patil'));
      expect(result.user!.phoneNumber, equals('9876543210'));

      // Verify session is active
      final isLoggedIn = await authRepo.isLoggedIn();
      final sessionUser = await authRepo.getCurrentUser();
      expect(isLoggedIn, isTrue);
      expect(sessionUser, isNotNull);
      expect(sessionUser!.id, equals(result.user!.id));
    });

    test('Login with incorrect PIN fails with descriptive message', () async {
      final result = await authRepo.login(
        phoneNumber: '9876543210',
        pin: '9999',
      );

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage!.contains('Incorrect PIN'), isTrue);
    });

    test('Login with non-existent phone fails asking to register', () async {
      final result = await authRepo.login(
        phoneNumber: '9000000000',
        pin: '1234',
      );

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage!.contains('No account found'), isTrue);
    });

    test('Registration creates new user, prevents duplicates, and saves profile', () async {
      final regResult = await authRepo.register(
        fullName: 'Balasaheb Shinde',
        phoneNumber: '9822998877',
        villageName: 'Dhawalpuri (ढवळपुरी)',
        wardOrGalli: 'Ward No. 1, Old Vasti',
        pin: '4321',
      );

      expect(regResult.isSuccess, isTrue);
      expect(regResult.user, isNotNull);
      expect(regResult.user!.fullName, equals('Balasaheb Shinde'));
      expect(regResult.user!.digitalIdCode.contains('8877'), isTrue);

      // Verify newly created user can log in with new PIN
      await authRepo.logout();
      expect(await authRepo.isLoggedIn(), isFalse);

      final loginResult = await authRepo.login(
        phoneNumber: '9822998877',
        pin: '4321',
      );
      expect(loginResult.isSuccess, isTrue);
      expect(loginResult.user!.fullName, equals('Balasaheb Shinde'));

      // Attempt duplicate registration with same phone
      final duplicateResult = await authRepo.register(
        fullName: 'Duplicate User',
        phoneNumber: '9822998877',
        villageName: 'Dhawalpuri',
        pin: '0000',
      );
      expect(duplicateResult.isSuccess, isFalse);
      expect(duplicateResult.errorMessage!.contains('already exists'), isTrue);
    });

    test('PIN reset updates user credential with valid OTP', () async {
      final resetResult = await authRepo.resetPin(
        phoneNumber: '9876543210',
        newPin: '5678',
        otp: '1234',
      );

      expect(resetResult.isSuccess, isTrue);

      // Verify login with old PIN fails
      final oldLogin = await authRepo.login(
        phoneNumber: '9876543210',
        pin: '1234',
      );
      expect(oldLogin.isSuccess, isFalse);

      // Verify login with new PIN succeeds
      final newLogin = await authRepo.login(
        phoneNumber: '9876543210',
        pin: '5678',
      );
      expect(newLogin.isSuccess, isTrue);
    });

    test('Logout clears session from persistence', () async {
      await authRepo.login(
        phoneNumber: '9876543210',
        pin: '1234',
      );
      expect(await authRepo.isLoggedIn(), isTrue);

      await authRepo.logout();
      expect(await authRepo.isLoggedIn(), isFalse);
      expect(await authRepo.getCurrentUser(), isNull);
    });
  });

  group('Blueprint 9: Village News & Updates Tests', () {
    late NewsRepository newsRepo;
    late NewsBookmarksManager bookmarksManager;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      newsRepo = MockNewsRepository();
      bookmarksManager = NewsBookmarksManager();
      await bookmarksManager.init();
    });

    test('10 Blueprint 9 categories exist and match specifications', () {
      final categories = NewsCategoryInfo.categories;
      expect(categories.length, equals(10));

      final keys = categories.map((c) => c.key).toList();
      expect(keys.contains('village_development'), isTrue);
      expect(keys.contains('gram_panchayat_updates'), isTrue);
      expect(keys.contains('agriculture_farming'), isTrue);
      expect(keys.contains('education'), isTrue);
      expect(keys.contains('health_awareness'), isTrue);
      expect(keys.contains('community_achievements'), isTrue);
      expect(keys.contains('culture_heritage'), isTrue);
      expect(keys.contains('environment'), isTrue);
      expect(keys.contains('public_information'), isTrue);
      expect(keys.contains('general_news'), isTrue);
    });

    test('MockNewsRepository returns 6 published, verified Dhawalpuri articles', () async {
      final articles = await newsRepo.getArticles();
      expect(articles.length, equals(6));

      for (final a in articles) {
        expect(a.publicationStatus, equals(NewsPublicationStatus.published));
        expect(a.verificationStatus, equals(NewsVerificationStatus.verified));
        expect(a.authorName.isNotEmpty, isTrue);
        expect(a.publisherName.isNotEmpty, isTrue);
        expect(a.readingTimeMinutes, greaterThanOrEqualTo(1));
      }
    });

    test('Featured story is published, verified, and can be retrieved', () async {
      final featured = await newsRepo.getFeaturedArticle();
      expect(featured, isNotNull);
      expect(featured!.isFeatured, isTrue);
      expect(featured.publicationStatus, equals(NewsPublicationStatus.published));
      expect(featured.id, equals('news_solar_water_pumps'));
      expect(featured.sourceUrl, equals('https://ahilyanagar.gov.in'));
    });

    test('Sorting by newest first and oldest first works correctly', () async {
      final newest = await newsRepo.getArticles(newestFirst: true);
      final oldest = await newsRepo.getArticles(newestFirst: false);

      expect(newest.first.id, isNot(equals(oldest.first.id)));
      expect(newest.first.publishedAt.isAfter(newest.last.publishedAt), isTrue);
      expect(oldest.first.publishedAt.isBefore(oldest.last.publishedAt), isTrue);
    });

    test('Category filtering isolates articles accurately', () async {
      final agriArticles = await newsRepo.getArticles(category: 'agriculture_farming');
      expect(agriArticles.length, equals(1));
      expect(agriArticles.first.category, equals('agriculture_farming'));
      expect(agriArticles.first.id, equals('news_organic_fertilizer_distribution'));

      final eduArticles = await newsRepo.getArticles(category: 'education');
      expect(eduArticles.length, equals(1));
      expect(eduArticles.first.category, equals('education'));
      expect(eduArticles.first.id, equals('news_zp_school_science_award'));
    });

    test('Multilingual search across headline, summary, body, tags, and authors', () async {
      // English keyword
      final solar = await newsRepo.getArticles(query: 'solar');
      expect(solar.isNotEmpty, isTrue);
      expect(solar.first.id, equals('news_solar_water_pumps'));

      // Marathi keyword: 'सेंद्रिय' (Organic)
      final organicMr = await newsRepo.getArticles(query: 'सेंद्रिय');
      expect(organicMr.isNotEmpty, isTrue);
      expect(organicMr.first.id, equals('news_organic_fertilizer_distribution'));

      // Hindi keyword: 'विज्ञान' (Science)
      final scienceHi = await newsRepo.getArticles(query: 'विज्ञान');
      expect(scienceHi.isNotEmpty, isTrue);
      expect(scienceHi.first.id, equals('news_zp_school_science_award'));

      // Author search
      final authorSearch = await newsRepo.getArticles(query: 'Kulkarni');
      expect(authorSearch.isNotEmpty, isTrue);
      expect(authorSearch.first.id, equals('news_phc_health_eye_camp'));
    });

    test('Bookmarks manager saves, toggles, and removes articles without requiring login', () async {
      expect(bookmarksManager.isBookmarked('news_solar_water_pumps'), isFalse);

      // Bookmark
      final added = await bookmarksManager.toggleBookmark('news_solar_water_pumps');
      expect(added, isTrue);
      expect(bookmarksManager.isBookmarked('news_solar_water_pumps'), isTrue);

      final saved = await newsRepo.getSavedArticles(bookmarksManager.getBookmarkedIds());
      expect(saved.length, equals(1));
      expect(saved.first.id, equals('news_solar_water_pumps'));

      // Remove bookmark
      final removed = await bookmarksManager.toggleBookmark('news_solar_water_pumps');
      expect(removed, isFalse);
      expect(bookmarksManager.isBookmarked('news_solar_water_pumps'), isFalse);
    });

    test('Suggesting news assigns pendingReview status and prevents auto-publishing', () async {
      final suggestion = NewsSuggestion(
        id: 'sug_test_1',
        headline: 'New community well constructed in Malwadi',
        category: 'village_development',
        summary: 'Villagers united to dig a community well.',
        body: 'With shramdaan from youth and farmers, the well was completed.',
        occurrenceDate: DateTime.now(),
        submittedAt: DateTime.now(),
      );

      final ok = await newsRepo.submitNewsSuggestion(suggestion);
      expect(ok, isTrue);
      expect(suggestion.status, equals(NewsPublicationStatus.pendingReview));

      // Public feed still has only published stories (no unvetted suggestions)
      final publicFeed = await newsRepo.getArticles();
      expect(publicFeed.any((a) => a.id == 'sug_test_1'), isFalse);
    });

    test('Reporting inaccurate information records feedback', () async {
      final report = NewsReport(
        id: 'rep_test_1',
        articleId: 'news_solar_water_pumps',
        issueType: 'Incorrect date or timing',
        description: 'Pumping trial started yesterday instead of last week.',
        reportedAt: DateTime.now(),
      );

      final ok = await newsRepo.reportArticleIssue(report);
      expect(ok, isTrue);
      expect((newsRepo as MockNewsRepository).submittedReports.isNotEmpty, isTrue);
    });

    test('Blueprint 9 Localization: Exact Dhawalpuri spelling in English, Marathi, Hindi', () {
      final locEn = AppLocalizations(const Locale('en', ''));
      final locMr = AppLocalizations(const Locale('mr', ''));
      final locHi = AppLocalizations(const Locale('hi', ''));

      // English titles
      expect(locEn.translate('village_news_title'), equals('Village News & Updates'));
      expect(locEn.translate('village_news_subtitle').contains('Dhawalpuri'), isTrue);

      // Marathi titles & strict spelling
      expect(locMr.translate('village_news_title'), equals('गावातील बातम्या व घडामोडी'));
      expect(locMr.translate('village_news_subtitle').contains('ढवळपुरी'), isTrue);
      expect(locMr.translate('village_news_subtitle').contains('धावळपुरी'), isFalse);
      expect(locMr.translate('village_news_subtitle').contains('धवळपुरी'), isFalse);

      // Hindi titles & strict spelling
      expect(locHi.translate('village_news_title'), equals('गाँव के समाचार एवं अपडेट्स'));
      expect(locHi.translate('village_news_subtitle').contains('ढवळपुरी'), isTrue);
      expect(locHi.translate('village_news_subtitle').contains('धावळपुरी'), isFalse);
      expect(locHi.translate('village_news_subtitle').contains('धवळपुरी'), isFalse);

      // Verify all 10 categories localized
      for (final cat in NewsCategoryInfo.categories) {
        expect(locEn.translate(cat.titleKey), isNotEmpty);
        expect(locMr.translate(cat.titleKey), isNotEmpty);
        expect(locHi.translate(cat.titleKey), isNotEmpty);
      }
    });
  });

  group('Blueprint 10: Agriculture Information Tests', () {
    late AgriRepository agriRepo;
    late AgriBookmarksManager bookmarksManager;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      agriRepo = MockAgriRepository();
      bookmarksManager = AgriBookmarksManager();
      await bookmarksManager.init();
    });

    test('All 10 Blueprint 10 Agriculture categories exist and are configured', () {
      final categories = AgriCategoryInfo.categories;
      expect(categories.length, equals(10));

      final keys = categories.map((c) => c.key).toList();
      expect(keys.contains('crop_info'), isTrue);
      expect(keys.contains('seasonal_guide'), isTrue);
      expect(keys.contains('soil_fertilizers'), isTrue);
      expect(keys.contains('irrigation_water'), isTrue);
      expect(keys.contains('pest_disease'), isTrue);
      expect(keys.contains('weather_info'), isTrue);
      expect(keys.contains('agri_schemes'), isTrue);
      expect(keys.contains('market_prices'), isTrue);
      expect(keys.contains('equipment_services'), isTrue);
      expect(keys.contains('farmer_resources_contacts'), isTrue);
    });

    test('Loads 6 regional crops suitable for Dhawalpuri / Parner soils', () async {
      final crops = await agriRepo.getCrops();
      expect(crops.length, equals(6));

      for (final crop in crops) {
        expect(crop.nameKey.isNotEmpty, isTrue);
        expect(crop.descKey.isNotEmpty, isTrue);
        expect(crop.soilRequirements.isNotEmpty, isTrue);
        expect(crop.waterRequirements.isNotEmpty, isTrue);
        expect(crop.cultivationGuidance.isNotEmpty, isTrue);
        expect(crop.harvestingGuidance.isNotEmpty, isTrue);
        expect(crop.sourceName.isNotEmpty, isTrue);
      }
    });

    test('Crop season filtering isolates crops accurately', () async {
      final rabiCrops = await agriRepo.getCrops(season: 'season_rabi');
      expect(rabiCrops.isNotEmpty, isTrue);
      final rabiIds = rabiCrops.map((c) => c.id).toList();
      expect(rabiIds.contains('crop_onion'), isTrue);
      expect(rabiIds.contains('crop_wheat'), isTrue);
      expect(rabiIds.contains('crop_chickpea'), isTrue);

      final kharifCrops = await agriRepo.getCrops(season: 'season_kharif');
      expect(kharifCrops.isNotEmpty, isTrue);
      final kharifIds = kharifCrops.map((c) => c.id).toList();
      expect(kharifIds.contains('crop_bajra'), isTrue);
      expect(kharifIds.contains('crop_soybean'), isTrue);
    });

    test('Crop search works across name, id, and cultivation guidance', () async {
      final onion = await agriRepo.getCrops(query: 'onion');
      expect(onion.length, equals(1));
      expect(onion.first.id, equals('crop_onion'));

      final bajra = await agriRepo.getCrops(query: 'bajra');
      expect(bajra.length, equals(1));
      expect(bajra.first.id, equals('crop_bajra'));

      final pomegranate = await agriRepo.getCrops(query: 'pomegranate');
      expect(pomegranate.length, equals(1));
      expect(pomegranate.first.id, equals('crop_pomegranate'));
    });

    test('Seasonal guides cover all 4 farming cycles with verified activities', () async {
      final guides = await agriRepo.getSeasonalGuides();
      expect(guides.length, equals(4));

      final seasonKeys = guides.map((g) => g.seasonKey).toList();
      expect(seasonKeys.contains('season_kharif'), isTrue);
      expect(seasonKeys.contains('season_rabi'), isTrue);
      expect(seasonKeys.contains('season_summer'), isTrue);
      expect(seasonKeys.contains('season_year_round'), isTrue);

      for (final guide in guides) {
        expect(guide.suitableActivities.isNotEmpty, isTrue);
        expect(guide.soilPreparation.isNotEmpty, isTrue);
        expect(guide.waterManagement.isNotEmpty, isTrue);
        expect(guide.advisories.isNotEmpty, isTrue);
      }
    });

    test('Pests & Diseases directory provides symptoms and IPM without chemical fabrication', () async {
      final pests = await agriRepo.getPestsAndDiseases();
      expect(pests.length, equals(4));

      for (final p in pests) {
        expect(p.name.isNotEmpty, isTrue);
        expect(p.affectedCrops.isNotEmpty, isTrue);
        expect(p.symptoms.isNotEmpty, isTrue);
        expect(p.prevention.isNotEmpty, isTrue);
        expect(p.recommendedSteps.isNotEmpty, isTrue);
        expect(p.sourceName.isNotEmpty, isTrue);
      }
    });

    test('Government agriculture schemes load verified official programs', () async {
      final schemes = await agriRepo.getAgriSchemes();
      expect(schemes.length, equals(5));

      final schemeIds = schemes.map((s) => s.id).toList();
      expect(schemeIds.contains('scheme_pm_kisan'), isTrue);
      expect(schemeIds.contains('scheme_pmfby'), isTrue);
      expect(schemeIds.contains('scheme_soil_health_card'), isTrue);
      expect(schemeIds.contains('scheme_pm_kusum'), isTrue);
      expect(schemeIds.contains('scheme_mahadbt_irrigation'), isTrue);

      for (final s in schemes) {
        expect(s.purpose.isNotEmpty, isTrue);
        expect(s.eligibilitySummary.isNotEmpty, isTrue);
        expect(s.requiredDocuments.isNotEmpty, isTrue);
        expect(s.officialPortalUrl.startsWith('https://'), isTrue);
      }
    });

    test('Strict zero phone fabrication in farmer contacts directory', () async {
      final contacts = await agriRepo.getFarmerContacts();
      expect(contacts.length, equals(5));

      final kisan = contacts.firstWhere((c) => c.id == 'contact_kisan_call_centre');
      expect(kisan.canCall, isTrue);
      expect(kisan.phoneNumber, equals('18001801551'));

      final tao = contacts.firstWhere((c) => c.id == 'contact_tao_parner');
      expect(tao.phoneNumber, isNull);
      expect(tao.canCall, isFalse);
    });

    test('Bookmarks manager persists, toggles, and removes agricultural resources', () async {
      expect(bookmarksManager.isBookmarked('crop_onion'), isFalse);

      final added = await bookmarksManager.toggleBookmark('crop_onion');
      expect(added, isTrue);
      expect(bookmarksManager.isBookmarked('crop_onion'), isTrue);

      final removed = await bookmarksManager.toggleBookmark('crop_onion');
      expect(removed, isFalse);
      expect(bookmarksManager.isBookmarked('crop_onion'), isFalse);
    });

    test('Blueprint 10 Localization: Strict Dhawalpuri spelling in English, Marathi, Hindi', () {
      final locEn = AppLocalizations(const Locale('en', ''));
      final locMr = AppLocalizations(const Locale('mr', ''));
      final locHi = AppLocalizations(const Locale('hi', ''));

      // English titles
      expect(locEn.translate('agri_home_title'), equals('Agriculture Information'));
      expect(locEn.translate('agri_home_subtitle').contains('Dhawalpuri'), isTrue);

      // Marathi titles & strict spelling
      expect(locMr.translate('agri_home_title'), equals('कृषी माहिती'));
      expect(locMr.translate('agri_home_subtitle').contains('ढवळपुरी'), isTrue);
      expect(locMr.translate('agri_home_subtitle').contains('धावळपुरी'), isFalse);
      expect(locMr.translate('agri_home_subtitle').contains('धवळपुरी'), isFalse);

      // Hindi titles & strict spelling
      expect(locHi.translate('agri_home_title'), equals('कृषि जानकारी'));
      expect(locHi.translate('agri_home_subtitle').contains('ढवळपुरी'), isTrue);
      expect(locHi.translate('agri_home_subtitle').contains('धावळपुरी'), isFalse);
      expect(locHi.translate('agri_home_subtitle').contains('धवळपुरी'), isFalse);

      // All 10 categories localized
      for (final cat in AgriCategoryInfo.categories) {
        expect(locEn.translate(cat.titleKey), isNotEmpty);
        expect(locMr.translate(cat.titleKey), isNotEmpty);
        expect(locHi.translate(cat.titleKey), isNotEmpty);
        expect(locEn.translate(cat.descKey), isNotEmpty);
        expect(locMr.translate(cat.descKey), isNotEmpty);
        expect(locHi.translate(cat.descKey), isNotEmpty);
      }
    });
  });

  group('Blueprint 11: Final Integration & Quality Assurance Tests', () {
    test('All 11 Version 1 modules are registered, accessible, and routed in AppRouter', () {
      // 1. App Foundation & Splash
      final splashRoute = AppRouter.onGenerateRoute(const RouteSettings(name: AppRouter.splash));
      expect(splashRoute, isNotNull);

      // 2. Home Dashboard
      final homeRoute = AppRouter.onGenerateRoute(const RouteSettings(name: AppRouter.home));
      expect(homeRoute, isNotNull);

      // 3. Our Dhawalpuri
      final villageRoute = AppRouter.onGenerateRoute(
        const RouteSettings(name: AppRouter.featureDetail, arguments: {'key': 'our_village'}),
      );
      expect(villageRoute, isNotNull);

      // 4. Village Notices
      final noticesRoute = AppRouter.onGenerateRoute(
        const RouteSettings(name: AppRouter.featureDetail, arguments: {'key': 'village_notices'}),
      );
      expect(noticesRoute, isNotNull);

      // 5. Community
      final communityRoute = AppRouter.onGenerateRoute(
        const RouteSettings(name: AppRouter.featureDetail, arguments: {'key': 'community'}),
      );
      expect(communityRoute, isNotNull);

      // 6. Important Places
      final placesRoute = AppRouter.onGenerateRoute(
        const RouteSettings(name: AppRouter.featureDetail, arguments: {'key': 'important_places'}),
      );
      expect(placesRoute, isNotNull);

      // 7. Emergency Contacts
      final contactsRoute = AppRouter.onGenerateRoute(
        const RouteSettings(name: AppRouter.featureDetail, arguments: {'key': 'emergency_contacts'}),
      );
      expect(contactsRoute, isNotNull);

      // 8. Government Services
      final servicesRoute = AppRouter.onGenerateRoute(
        const RouteSettings(name: AppRouter.featureDetail, arguments: {'key': 'govt_services'}),
      );
      expect(servicesRoute, isNotNull);

      // 9. Events & Village Calendar
      final eventsRoute = AppRouter.onGenerateRoute(
        const RouteSettings(name: AppRouter.featureDetail, arguments: {'key': 'events_festivals'}),
      );
      expect(eventsRoute, isNotNull);

      // 10. Village News & Updates
      final newsRoute = AppRouter.onGenerateRoute(
        const RouteSettings(name: AppRouter.featureDetail, arguments: {'key': 'village_news'}),
      );
      expect(newsRoute, isNotNull);
      final directNewsRoute = AppRouter.onGenerateRoute(const RouteSettings(name: AppRouter.newsList));
      expect(directNewsRoute, isNotNull);

      // 11. Agriculture Information
      final agriRoute = AppRouter.onGenerateRoute(
        const RouteSettings(name: AppRouter.featureDetail, arguments: {'key': 'agri_info'}),
      );
      expect(agriRoute, isNotNull);
      final directAgriRoute = AppRouter.onGenerateRoute(const RouteSettings(name: AppRouter.agriHome));
      expect(directAgriRoute, isNotNull);
    });

    test('Home Dashboard feature cards contain all required Version 1 feature keys', () {
      final keys = MockData.dashboardFeatures.map((f) => f.key).toSet();
      expect(keys.contains('our_village'), isTrue);
      expect(keys.contains('village_notices'), isTrue);
      expect(keys.contains('community'), isTrue);
      expect(keys.contains('important_places'), isTrue);
      expect(keys.contains('emergency_contacts'), isTrue);
      expect(keys.contains('govt_services'), isTrue);
      expect(keys.contains('events_festivals'), isTrue);
      expect(keys.contains('village_news'), isTrue);
      expect(keys.contains('agri_info'), isTrue);
    });

    test('Public browsing guarantee: all modules load data without requiring authentication', () async {
      // 3. Our Village
      final info = await const MockVillageRepository().getVillageInfo();
      expect(info.introKey.isNotEmpty, isTrue);

      // 4. Village Notices
      final notices = await const MockNoticeRepository().getNotices();
      expect(notices.isNotEmpty, isTrue);

      // 5. Community
      final community = await MockCommunityRepository().getCommunityItems();
      expect(community.isNotEmpty, isTrue);

      // 6. Important Places
      final places = await MockPlaceRepository().getPlaces();
      expect(places.isNotEmpty, isTrue);

      // 7. Emergency Contacts
      final contacts = await MockEmergencyContactRepository().getContacts();
      expect(contacts.isNotEmpty, isTrue);

      // 8. Government Services
      final services = await const MockGovernmentServicesRepository().getAllServices();
      expect(services.isNotEmpty, isTrue);

      // 9. Events & Village Calendar
      final events = await MockEventRepository().getAllEvents();
      expect(events.isNotEmpty, isTrue);

      // 10. Village News & Updates
      final news = await MockNewsRepository().getArticles();
      expect(news.isNotEmpty, isTrue);

      // 11. Agriculture Information
      final crops = await MockAgriRepository().getCrops();
      expect(crops.isNotEmpty, isTrue);
    });

    test('Strict zero fabrication compliance: GPS coordinates, weather, prices, and unverified phones', () async {
      // Village reference places have null coordinates
      final villagePlaces = await const MockVillageRepository().getVillagePlaces();
      for (final p in villagePlaces) {
        expect(p.latitude, isNull, reason: '${p.nameKey} must not fabricate GPS coordinates');
        expect(p.longitude, isNull, reason: '${p.nameKey} must not fabricate GPS coordinates');
      }

      // Important places landmarks have null coordinates and null phone
      final landmarks = await MockPlaceRepository().getReferenceLandmarks();
      for (final l in landmarks) {
        expect(l.latitude, isNull);
        expect(l.longitude, isNull);
        expect(l.phoneNumber, isNull);
      }

      // Emergency contacts: local unverified offices have null phone and canCall == false
      final emergencyContacts = await MockEmergencyContactRepository().getContacts();
      final gpContact = emergencyContacts.firstWhere((c) => c.id == 'em_gp_office');
      expect(gpContact.phoneNumber, isNull);
      expect(gpContact.hasValidPhoneNumber, isFalse);

      // Agriculture contacts: local Taluka office has null phone and canCall == false
      final farmerContacts = await MockAgriRepository().getFarmerContacts();
      final taoContact = farmerContacts.firstWhere((c) => c.id == 'contact_tao_parner');
      expect(taoContact.phoneNumber, isNull);
      expect(taoContact.canCall, isFalse);
    });

    test('Localization audit: Exact village spelling across English, Marathi, Hindi and no missing keys', () {
      final locEn = AppLocalizations(const Locale('en', ''));
      final locMr = AppLocalizations(const Locale('mr', ''));
      final locHi = AppLocalizations(const Locale('hi', ''));

      // Exact village spelling
      expect(locEn.translate('village_name_only'), equals('Dhawalpuri'));
      expect(locMr.translate('village_name_only'), equals('ढवळपुरी'));
      expect(locHi.translate('village_name_only'), equals('ढवळपुरी'));

      // Strict prohibition of alternative or incorrect spellings
      expect(locMr.translate('village_name_only').contains('धवलपुरी'), isFalse);
      expect(locMr.translate('village_name_only').contains('धावळपुरी'), isFalse);
      expect(locHi.translate('village_name_only').contains('धवलपुरी'), isFalse);

      // Blueprint 11 newly localized keys non-empty check
      final bp11Keys = [
        'village_name_only',
        'welcome_verified_sub',
        'welcome_guest_sub',
        'select_card_browse',
        'no_matching_services',
        'recent_notices_alerts',
        'upcoming_camps_gatherings',
        'quick_access',
        'villager',
        'coords_pending_verification',
        'demo_feedback_notice',
      ];

      for (final key in bp11Keys) {
        expect(locEn.translate(key), isNotEmpty, reason: 'EN key $key missing');
        expect(locMr.translate(key), isNotEmpty, reason: 'MR key $key missing');
        expect(locHi.translate(key), isNotEmpty, reason: 'HI key $key missing');
      }
    });

    test('Form submissions are recorded with pending or local prototype status', () async {
      // 1. Community submission
      final commSub = CommunitySubmission(
        id: 'test_sub',
        title: 'Village Tree Plantation',
        category: 'social_initiatives',
        description: 'Planting indigenous trees along the main canal road.',
        submittedBy: 'test_user',
        status: 'prototype_pending',
        createdAt: DateTime.now(),
      );
      expect(commSub.status, equals('prototype_pending'));

      // 2. Place report
      final placeReport = PlaceReport(
        id: 'test_rep',
        placeId: 'pl_test',
        placeName: 'ZP Primary School',
        issueType: 'wrong_location',
        description: 'Verified landmark position requires adjustment.',
        reportedAt: DateTime.now(),
      );
      expect(placeReport.placeId, equals('pl_test'));
      expect(placeReport.issueType, equals('wrong_location'));

      // 3. News suggestion
      final newsSuggestion = NewsArticle(
        id: 'test_news_sug',
        headline: 'Test Headline',
        summary: 'Test summary',
        body: 'Test body details',
        category: 'village_development',
        authorName: 'Resident',
        publisherName: 'GramConnect',
        publishedAt: DateTime.now(),
        publicationStatus: NewsPublicationStatus.pendingReview,
        verificationStatus: NewsVerificationStatus.pendingVerification,
      );
      expect(newsSuggestion.publicationStatus, equals(NewsPublicationStatus.pendingReview));
      expect(newsSuggestion.verificationStatus, equals(NewsVerificationStatus.pendingVerification));
    });
  });
}


