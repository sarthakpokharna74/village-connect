import 'package:flutter/material.dart';
import '../../../../core/localization/translations.dart';
import '../models/contact_model.dart';

/// Contract for Emergency Contacts data operations in GramConnect.
/// Provides decoupled access to verified emergency helplines and local contacts.
abstract class EmergencyContactRepository {
  Future<List<EmergencyContact>> getContacts({String? category});
  Future<EmergencyContact?> getContactById(String id);
  Future<List<EmergencyContact>> searchContacts(String query, {String? category});
  Future<List<EmergencyContact>> getPriorityNationalContacts();
}

/// Mock/Local Emergency Contact Repository implementation.
/// Accurately represents verified Indian official helplines and marks unverified local numbers as pending/null.
class MockEmergencyContactRepository implements EmergencyContactRepository {
  static final MockEmergencyContactRepository _instance =
      MockEmergencyContactRepository._internal();
  factory MockEmergencyContactRepository() => _instance;
  MockEmergencyContactRepository._internal();

  static final List<EmergencyContact> _officialContacts = [
    // 1. National Emergency Response Support System (ERSS)
    EmergencyContact(
      id: 'em_112',
      nameKey: 'con_112_name',
      category: 'disaster_safety',
      phoneNumber: '112',
      descriptionKey: 'con_112_desc',
      purposeKey: 'con_112_purpose',
      coverageKey: 'coverage_national',
      availabilityKey: 'operating_hours_247',
      verificationStatus: ContactVerificationStatus.verified,
      isNationalService: true,
      sourceKey: 'con_112_source',
      lastVerifiedAt: 'October 2026',
      icon: Icons.emergency_rounded,
      color: const Color(0xFFD97706),
    ),

    // 2. Maharashtra Emergency Medical Services (MEMS Ambulance)
    EmergencyContact(
      id: 'em_108',
      nameKey: 'con_108_name',
      category: 'ambulance_medical',
      phoneNumber: '108',
      descriptionKey: 'con_108_desc',
      purposeKey: 'con_108_purpose',
      coverageKey: 'coverage_state',
      availabilityKey: 'operating_hours_247',
      verificationStatus: ContactVerificationStatus.verified,
      isNationalService: false,
      sourceKey: 'con_108_source',
      lastVerifiedAt: 'October 2026',
      icon: Icons.local_hospital_rounded,
      color: Colors.red,
    ),

    // 3. Fire and Rescue Services
    EmergencyContact(
      id: 'em_101',
      nameKey: 'con_101_name',
      category: 'fire_rescue',
      phoneNumber: '101',
      descriptionKey: 'con_101_desc',
      purposeKey: 'con_101_purpose',
      coverageKey: 'coverage_national',
      availabilityKey: 'operating_hours_247',
      verificationStatus: ContactVerificationStatus.verified,
      isNationalService: true,
      sourceKey: 'con_101_source',
      lastVerifiedAt: 'October 2026',
      icon: Icons.fire_truck_rounded,
      color: Colors.deepOrange,
    ),

    // 4. Police Control Room
    EmergencyContact(
      id: 'em_100',
      nameKey: 'con_100_name',
      category: 'police',
      phoneNumber: '100',
      descriptionKey: 'con_100_desc',
      purposeKey: 'con_100_purpose',
      coverageKey: 'coverage_national',
      availabilityKey: 'operating_hours_247',
      verificationStatus: ContactVerificationStatus.verified,
      isNationalService: true,
      sourceKey: 'con_100_source',
      lastVerifiedAt: 'October 2026',
      icon: Icons.local_police_rounded,
      color: Colors.indigo,
    ),

    // 5. Childline India
    EmergencyContact(
      id: 'em_1098',
      nameKey: 'con_1098_name',
      category: 'women_child',
      phoneNumber: '1098',
      descriptionKey: 'con_1098_desc',
      purposeKey: 'con_1098_purpose',
      coverageKey: 'coverage_national',
      availabilityKey: 'operating_hours_247',
      verificationStatus: ContactVerificationStatus.verified,
      isNationalService: true,
      sourceKey: 'con_1098_source',
      lastVerifiedAt: 'October 2026',
      icon: Icons.family_restroom_rounded,
      color: Colors.purple,
    ),

    // 6. Women Helpline
    EmergencyContact(
      id: 'em_181',
      nameKey: 'con_181_name',
      category: 'women_child',
      phoneNumber: '181',
      descriptionKey: 'con_181_desc',
      purposeKey: 'con_181_purpose',
      coverageKey: 'coverage_state',
      availabilityKey: 'operating_hours_247',
      verificationStatus: ContactVerificationStatus.verified,
      isNationalService: false,
      sourceKey: 'con_181_source',
      lastVerifiedAt: 'October 2026',
      icon: Icons.family_restroom_rounded,
      color: Colors.purple,
    ),

    // 7. District Disaster Management Authority (DDMA Ahilyanagar)
    EmergencyContact(
      id: 'em_1077',
      nameKey: 'con_1077_name',
      category: 'disaster_safety',
      phoneNumber: '1077',
      descriptionKey: 'con_1077_desc',
      purposeKey: 'con_1077_purpose',
      coverageKey: 'coverage_state',
      availabilityKey: 'operating_hours_247',
      verificationStatus: ContactVerificationStatus.verified,
      isNationalService: false,
      sourceKey: 'con_1077_source',
      lastVerifiedAt: 'October 2026',
      icon: Icons.warning_amber_rounded,
      color: const Color(0xFFD97706),
    ),

    // 8. MSEDCL Electricity Emergency & Fault Helpline
    EmergencyContact(
      id: 'em_1912',
      nameKey: 'con_1912_name',
      category: 'electricity',
      phoneNumber: '1912',
      descriptionKey: 'con_1912_desc',
      purposeKey: 'con_1912_purpose',
      coverageKey: 'coverage_state',
      availabilityKey: 'operating_hours_247',
      verificationStatus: ContactVerificationStatus.verified,
      isNationalService: false,
      sourceKey: 'con_1912_source',
      lastVerifiedAt: 'October 2026',
      icon: Icons.electric_bolt_rounded,
      color: const Color(0xFFC2410C),
    ),

    // 9. Gram Panchayat Office (Dhawalpuri) - Direct phone pending official publication
    EmergencyContact(
      id: 'em_gp_office',
      nameKey: 'con_gp_office_name',
      category: 'local_govt',
      phoneNumber: null, // Officially pending publication - never invent
      descriptionKey: 'con_gp_office_desc',
      purposeKey: 'con_gp_office_purpose',
      coverageKey: 'coverage_local',
      addressKey: 'con_gp_office_loc',
      availabilityKey: 'operating_hours_office',
      verificationStatus: ContactVerificationStatus.pending,
      isNationalService: false,
      sourceKey: 'con_gp_office_source',
      safeAlternativeKey: 'con_gp_office_alt',
      lastVerifiedAt: 'October 2026',
      icon: Icons.account_balance_rounded,
      color: Colors.teal,
    ),

    // 10. Dhawalpuri Water Supply Complaints - Direct phone pending official publication
    EmergencyContact(
      id: 'em_water_dept',
      nameKey: 'con_water_dept_name',
      category: 'water_supply',
      phoneNumber: null, // Officially pending publication - never invent
      descriptionKey: 'con_water_dept_desc',
      purposeKey: 'con_water_dept_purpose',
      coverageKey: 'coverage_local',
      addressKey: 'con_water_dept_loc',
      availabilityKey: 'operating_hours_office',
      verificationStatus: ContactVerificationStatus.pending,
      isNationalService: false,
      sourceKey: 'con_water_dept_source',
      safeAlternativeKey: 'con_water_dept_alt',
      lastVerifiedAt: 'October 2026',
      icon: Icons.water_drop_rounded,
      color: Colors.cyan,
    ),

    // 11. Primary Health Center Sub-Center (Dhawalpuri) - Direct landline pending publication
    EmergencyContact(
      id: 'em_phc_dhawalpuri',
      nameKey: 'con_phc_dhawalpuri_name',
      category: 'hospital_healthcare',
      phoneNumber: null, // Officially pending publication - never invent
      descriptionKey: 'con_phc_dhawalpuri_desc',
      purposeKey: 'con_phc_dhawalpuri_purpose',
      coverageKey: 'coverage_local',
      addressKey: 'con_phc_dhawalpuri_loc',
      availabilityKey: 'operating_hours_office',
      verificationStatus: ContactVerificationStatus.pending,
      isNationalService: false,
      sourceKey: 'con_phc_dhawalpuri_source',
      safeAlternativeKey: 'con_phc_dhawalpuri_alt',
      lastVerifiedAt: 'October 2026',
      icon: Icons.health_and_safety_rounded,
      color: Colors.redAccent,
    ),
  ];

  @override
  Future<List<EmergencyContact>> getContacts({String? category}) async {
    if (category == null || category == 'all' || category.isEmpty) {
      return _officialContacts;
    }
    return _officialContacts.where((c) => c.category == category).toList();
  }

  @override
  Future<EmergencyContact?> getContactById(String id) async {
    try {
      return _officialContacts.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<EmergencyContact>> getPriorityNationalContacts() async {
    return _officialContacts
        .where((c) => ['em_112', 'em_108', 'em_101', 'em_100'].contains(c.id))
        .toList();
  }

  @override
  Future<List<EmergencyContact>> searchContacts(String query,
      {String? category}) async {
    final cleanQuery = query.trim().toLowerCase();

    return _officialContacts.where((contact) {
      // Category filter check
      if (category != null && category != 'all' && category.isNotEmpty) {
        if (contact.category != category) return false;
      }

      if (cleanQuery.isEmpty) return true;

      // Check phone number directly
      if (contact.phoneNumber != null &&
          contact.phoneNumber!.contains(cleanQuery)) {
        return true;
      }

      // Check raw keys
      if (contact.nameKey.toLowerCase().contains(cleanQuery) ||
          contact.category.toLowerCase().contains(cleanQuery) ||
          (contact.descriptionKey?.toLowerCase().contains(cleanQuery) ?? false) ||
          (contact.purposeKey?.toLowerCase().contains(cleanQuery) ?? false)) {
        return true;
      }

      // Match localized text across all supported dictionaries (English, Marathi, Hindi)
      for (final langMap in AppTranslations.values.values) {
        final name = langMap[contact.nameKey]?.toLowerCase() ?? '';
        final desc = contact.descriptionKey != null
            ? (langMap[contact.descriptionKey!]?.toLowerCase() ?? '')
            : '';
        final purpose = contact.purposeKey != null
            ? (langMap[contact.purposeKey!]?.toLowerCase() ?? '')
            : '';
        final catName =
            langMap['cat_em_${contact.category}']?.toLowerCase() ?? '';

        if (name.contains(cleanQuery) ||
            desc.contains(cleanQuery) ||
            purpose.contains(cleanQuery) ||
            catName.contains(cleanQuery)) {
          return true;
        }
      }

      return false;
    }).toList();
  }
}
