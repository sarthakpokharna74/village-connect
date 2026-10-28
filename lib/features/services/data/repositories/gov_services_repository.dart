import 'package:gram_connect/core/localization/translations.dart';
import '../models/gov_service_model.dart';

/// Repository interface for fetching and filtering Government Services in GramConnect.
abstract class GovernmentServicesRepository {
  Future<List<ServiceCategoryInfo>> getCategories();
  Future<List<GovernmentService>> getAllServices();
  Future<GovernmentService?> getServiceById(String id);
  Future<List<GovernmentService>> getServicesByCategory(String categoryId);
  Future<List<GovernmentService>> searchServices(String query, {String? categoryId});
}

/// Mock / Local implementation of [GovernmentServicesRepository] populated with
/// verified government schemes and local Dhawalpuri administration services.
class MockGovernmentServicesRepository implements GovernmentServicesRepository {
  const MockGovernmentServicesRepository();

  /// Official verified dataset of 12 services in Maharashtra / Dhawalpuri.
  static const List<GovernmentService> verifiedServices = [
    // 1. Income Certificate (Identity & Certificates)
    GovernmentService(
      id: 'gs_income',
      nameKey: 'gs_income_name',
      category: 'identity_certificates',
      shortDescriptionKey: 'gs_income_exp',
      detailedDescriptionKey: 'gs_income_exp',
      departmentKey: 'gs_income_dept',
      eligibilityKey: 'gs_income_elig',
      requiredDocsKeys: [
        'doc_aadhar',
        'doc_ration',
        'doc_income_rep',
        'doc_self_declaration',
      ],
      applicationStepsKeys: [
        'step_portal_register',
        'step_fill_application',
        'step_upload_docs',
        'step_pay_gov_fee',
        'step_track_portal',
      ],
      isOnlineAvailable: true,
      isOfflineAvailable: true,
      applicationMethodKey: 'gov_hybrid_method',
      officialWebsiteUrl: 'https://aaplesarkar.mahaonline.gov.in',
      officialInformationUrl: 'https://aaplesarkar.mahaonline.gov.in',
      sourceName: 'Revenue Department, Government of Maharashtra',
      feesKey: 'gs_income_fees',
      timelineKey: 'gs_income_time',
      verificationStatus: ServiceVerificationStatus.verified,
      lastVerifiedAt: 'October 2026',
    ),

    // 2. Caste Certificate (Identity & Certificates)
    GovernmentService(
      id: 'gs_caste',
      nameKey: 'gs_caste_name',
      category: 'identity_certificates',
      shortDescriptionKey: 'gs_caste_exp',
      detailedDescriptionKey: 'gs_caste_exp',
      departmentKey: 'gs_caste_dept',
      eligibilityKey: 'gs_caste_elig',
      requiredDocsKeys: [
        'doc_aadhar',
        'doc_ration',
        'doc_caste_proof',
        'doc_self_declaration',
      ],
      applicationStepsKeys: [
        'step_portal_register',
        'step_fill_application',
        'step_upload_docs',
        'step_pay_gov_fee',
        'step_track_portal',
      ],
      isOnlineAvailable: true,
      isOfflineAvailable: true,
      applicationMethodKey: 'gov_hybrid_method',
      officialWebsiteUrl: 'https://aaplesarkar.mahaonline.gov.in',
      officialInformationUrl: 'https://aaplesarkar.mahaonline.gov.in',
      sourceName: 'Aaple Sarkar Portal, Govt. of Maharashtra',
      feesKey: 'gs_caste_fees',
      timelineKey: 'gs_caste_time',
      verificationStatus: ServiceVerificationStatus.verified,
      lastVerifiedAt: 'October 2026',
    ),

    // 3. Digital 7/12 & 8A (Revenue & Land Records)
    GovernmentService(
      id: 'gs_712',
      nameKey: 'gs_712_name',
      category: 'revenue_land_records',
      shortDescriptionKey: 'gs_712_exp',
      detailedDescriptionKey: 'gs_712_exp',
      departmentKey: 'gs_712_dept',
      eligibilityKey: 'gs_712_elig',
      requiredDocsKeys: [
        'doc_land_712',
        'doc_land_8a',
      ],
      applicationStepsKeys: [
        'step_portal_register',
        'step_fill_application',
        'step_pay_gov_fee',
        'step_track_portal',
      ],
      isOnlineAvailable: true,
      isOfflineAvailable: false,
      applicationMethodKey: 'gov_online_method',
      officialWebsiteUrl: 'https://digitalsatbara.mahabhumi.gov.in',
      officialInformationUrl: 'https://bhulekh.mahabhumi.gov.in',
      sourceName: 'Revenue & Land Records Department, Maharashtra',
      feesKey: 'gs_712_fees',
      timelineKey: 'gs_712_time',
      verificationStatus: ServiceVerificationStatus.verified,
      lastVerifiedAt: 'October 2026',
    ),

    // 4. PM-KISAN (Agriculture & Farmers)
    GovernmentService(
      id: 'gs_pmkisan',
      nameKey: 'gs_pmkisan_name',
      category: 'agriculture_farmers',
      shortDescriptionKey: 'gs_pmkisan_exp',
      detailedDescriptionKey: 'gs_pmkisan_exp',
      departmentKey: 'gs_pmkisan_dept',
      eligibilityKey: 'gs_pmkisan_elig',
      requiredDocsKeys: [
        'doc_aadhar',
        'doc_land_712',
        'doc_bank_passbook',
      ],
      applicationStepsKeys: [
        'step_portal_register',
        'step_fill_application',
        'step_upload_docs',
        'step_track_portal',
      ],
      isOnlineAvailable: true,
      isOfflineAvailable: true,
      applicationMethodKey: 'gov_hybrid_method',
      officialWebsiteUrl: 'https://pmkisan.gov.in',
      officialInformationUrl: 'https://pmkisan.gov.in',
      sourceName: 'Ministry of Agriculture & Farmers Welfare, India',
      feesKey: 'gs_pmkisan_fees',
      timelineKey: 'gs_pmkisan_time',
      verificationStatus: ServiceVerificationStatus.verified,
      lastVerifiedAt: 'October 2026',
    ),

    // 5. Ayushman Bharat - PMJAY / MJPJAY (Health & Family Welfare)
    GovernmentService(
      id: 'gs_ayushman',
      nameKey: 'gs_ayushman_name',
      category: 'health_family_welfare',
      shortDescriptionKey: 'gs_ayushman_exp',
      detailedDescriptionKey: 'gs_ayushman_exp',
      departmentKey: 'gs_ayushman_dept',
      eligibilityKey: 'gs_ayushman_elig',
      requiredDocsKeys: [
        'doc_aadhar',
        'doc_ration',
      ],
      applicationStepsKeys: [
        'step_portal_register',
        'step_fill_application',
        'step_track_portal',
      ],
      isOnlineAvailable: true,
      isOfflineAvailable: true,
      applicationMethodKey: 'gov_hybrid_method',
      officialWebsiteUrl: 'https://beneficiary.nha.gov.in',
      officialInformationUrl: 'https://beneficiary.nha.gov.in',
      sourceName: 'National Health Authority & SHAS Maharashtra',
      feesKey: 'gs_ayushman_fees',
      timelineKey: 'gs_ayushman_time',
      verificationStatus: ServiceVerificationStatus.verified,
      lastVerifiedAt: 'October 2026',
    ),

    // 6. MahaDBT Scholarships (Education & Scholarships)
    GovernmentService(
      id: 'gs_mahadbt',
      nameKey: 'gs_mahadbt_name',
      category: 'education_scholarships',
      shortDescriptionKey: 'gs_mahadbt_exp',
      detailedDescriptionKey: 'gs_mahadbt_exp',
      departmentKey: 'gs_mahadbt_dept',
      eligibilityKey: 'gs_mahadbt_elig',
      requiredDocsKeys: [
        'doc_aadhar',
        'doc_ration',
        'doc_income_rep',
        'doc_caste_proof',
        'doc_bank_passbook',
      ],
      applicationStepsKeys: [
        'step_portal_register',
        'step_fill_application',
        'step_upload_docs',
        'step_track_portal',
      ],
      isOnlineAvailable: true,
      isOfflineAvailable: false,
      applicationMethodKey: 'gov_online_method',
      officialWebsiteUrl: 'https://mahadbt.maharashtra.gov.in',
      officialInformationUrl: 'https://mahadbt.maharashtra.gov.in',
      sourceName: 'Directorate of Higher Education, Maharashtra',
      feesKey: 'gs_mahadbt_fees',
      timelineKey: 'gs_mahadbt_time',
      verificationStatus: ServiceVerificationStatus.verified,
      lastVerifiedAt: 'October 2026',
    ),

    // 7. Sanjay Gandhi Niradhar Pension (Pension & Social Welfare)
    GovernmentService(
      id: 'gs_sanjay_gandhi',
      nameKey: 'gs_sanjay_gandhi_name',
      category: 'pension_social_welfare',
      shortDescriptionKey: 'gs_sanjay_gandhi_exp',
      detailedDescriptionKey: 'gs_sanjay_gandhi_exp',
      departmentKey: 'gs_sanjay_gandhi_dept',
      eligibilityKey: 'gs_sanjay_gandhi_elig',
      requiredDocsKeys: [
        'doc_aadhar',
        'doc_ration',
        'doc_income_rep',
        'doc_domicile_proof',
        'doc_passport_photo',
      ],
      applicationStepsKeys: [
        'step_visit_gram_panchayat',
        'step_verify_talathi',
      ],
      isOnlineAvailable: false,
      isOfflineAvailable: true,
      applicationMethodKey: 'gov_offline_method',
      officialWebsiteUrl: 'https://sjsa.maharashtra.gov.in',
      officialInformationUrl: 'https://sjsa.maharashtra.gov.in',
      sourceName: 'Social Justice Dept, Maharashtra / Tahsil Parner',
      feesKey: 'gs_sanjay_gandhi_fees',
      timelineKey: 'gs_sanjay_gandhi_time',
      verificationStatus: ServiceVerificationStatus.verified,
      lastVerifiedAt: 'October 2026',
    ),

    // 8. MGNREGA Job Card (Employment & Skills)
    GovernmentService(
      id: 'gs_mgnrega',
      nameKey: 'gs_mgnrega_name',
      category: 'employment_skills',
      shortDescriptionKey: 'gs_mgnrega_exp',
      detailedDescriptionKey: 'gs_mgnrega_exp',
      departmentKey: 'gs_mgnrega_dept',
      eligibilityKey: 'gs_mgnrega_elig',
      requiredDocsKeys: [
        'doc_aadhar',
        'doc_ration',
        'doc_bank_passbook',
        'doc_passport_photo',
      ],
      applicationStepsKeys: [
        'step_visit_gram_panchayat',
        'step_fill_application',
      ],
      isOnlineAvailable: false,
      isOfflineAvailable: true,
      applicationMethodKey: 'gov_offline_method',
      officialWebsiteUrl: 'https://nrega.nic.in',
      officialInformationUrl: 'https://nrega.nic.in',
      sourceName: 'Ministry of Rural Development & Dhawalpuri GP',
      feesKey: 'gs_mgnrega_fees',
      timelineKey: 'gs_mgnrega_time',
      verificationStatus: ServiceVerificationStatus.verified,
      lastVerifiedAt: 'October 2026',
    ),

    // 9. Ration Card Services (Ration & Public Distribution)
    GovernmentService(
      id: 'gs_ration',
      nameKey: 'gs_ration_name',
      category: 'ration_public_distribution',
      shortDescriptionKey: 'gs_ration_exp',
      detailedDescriptionKey: 'gs_ration_exp',
      departmentKey: 'gs_ration_dept',
      eligibilityKey: 'gs_ration_elig',
      requiredDocsKeys: [
        'doc_aadhar',
        'doc_income_rep',
        'doc_electricity_bill',
        'doc_passport_photo',
      ],
      applicationStepsKeys: [
        'step_portal_register',
        'step_fill_application',
        'step_upload_docs',
        'step_pay_gov_fee',
        'step_track_portal',
      ],
      isOnlineAvailable: true,
      isOfflineAvailable: true,
      applicationMethodKey: 'gov_hybrid_method',
      officialWebsiteUrl: 'https://epds.mahafood.gov.in',
      officialInformationUrl: 'https://mahafood.gov.in',
      sourceName: 'Food, Civil Supplies & Consumer Protection Dept',
      feesKey: 'gs_ration_fees',
      timelineKey: 'gs_ration_time',
      verificationStatus: ServiceVerificationStatus.verified,
      lastVerifiedAt: 'October 2026',
    ),

    // 10. MSEDCL Electricity Connection (Electricity & Water)
    GovernmentService(
      id: 'gs_msedcl',
      nameKey: 'gs_msedcl_name',
      category: 'electricity_water',
      shortDescriptionKey: 'gs_msedcl_exp',
      detailedDescriptionKey: 'gs_msedcl_exp',
      departmentKey: 'gs_msedcl_dept',
      eligibilityKey: 'gs_msedcl_elig',
      requiredDocsKeys: [
        'doc_aadhar',
        'doc_land_712',
        'doc_property_tax',
      ],
      applicationStepsKeys: [
        'step_portal_register',
        'step_fill_application',
        'step_upload_docs',
        'step_pay_gov_fee',
        'step_track_portal',
      ],
      isOnlineAvailable: true,
      isOfflineAvailable: true,
      applicationMethodKey: 'gov_hybrid_method',
      officialWebsiteUrl: 'https://www.mahadiscom.in',
      officialInformationUrl: 'https://www.mahadiscom.in',
      sourceName: 'Maharashtra State Electricity Distribution Co.',
      feesKey: 'gs_msedcl_fees',
      timelineKey: 'gs_msedcl_time',
      verificationStatus: ServiceVerificationStatus.verified,
      lastVerifiedAt: 'October 2026',
    ),

    // 11. Birth & Death Registration (Identity & Certificates)
    GovernmentService(
      id: 'gs_birth_death',
      nameKey: 'gs_birth_death_name',
      category: 'identity_certificates',
      shortDescriptionKey: 'gs_birth_death_exp',
      detailedDescriptionKey: 'gs_birth_death_exp',
      departmentKey: 'gs_birth_death_dept',
      eligibilityKey: 'gs_birth_death_elig',
      requiredDocsKeys: [
        'doc_aadhar',
        'doc_self_declaration',
      ],
      applicationStepsKeys: [
        'step_visit_gram_panchayat',
        'step_verify_talathi',
      ],
      isOnlineAvailable: true,
      isOfflineAvailable: true,
      applicationMethodKey: 'gov_hybrid_method',
      officialWebsiteUrl: 'https://crsorgi.gov.in',
      officialInformationUrl: 'https://crsorgi.gov.in',
      sourceName: 'Civil Registration System & Dhawalpuri GP',
      feesKey: 'gs_birth_death_fees',
      timelineKey: 'gs_birth_death_time',
      verificationStatus: ServiceVerificationStatus.verified,
      lastVerifiedAt: 'October 2026',
    ),

    // 12. Gram Panchayat Assessment & Village NOC (Gram Panchayat Services)
    GovernmentService(
      id: 'gs_tax_noc',
      nameKey: 'gs_tax_noc_name',
      category: 'gram_panchayat_services',
      shortDescriptionKey: 'gs_tax_noc_exp',
      detailedDescriptionKey: 'gs_tax_noc_exp',
      departmentKey: 'gs_tax_noc_dept',
      eligibilityKey: 'gs_tax_noc_elig',
      requiredDocsKeys: [
        'doc_aadhar',
        'doc_property_tax',
      ],
      applicationStepsKeys: [
        'step_visit_gram_panchayat',
        'step_fill_application',
        'step_verify_talathi',
      ],
      isOnlineAvailable: false,
      isOfflineAvailable: true,
      applicationMethodKey: 'gov_offline_method',
      officialWebsiteUrl: null, // In-person village administration service
      officialInformationUrl: null,
      sourceName: 'Dhawalpuri Gram Panchayat Office, Taluka Parner',
      feesKey: 'gs_tax_noc_fees',
      timelineKey: 'gs_tax_noc_time',
      verificationStatus: ServiceVerificationStatus.verified,
      lastVerifiedAt: 'October 2026',
    ),
  ];

  @override
  Future<List<ServiceCategoryInfo>> getCategories() async {
    return ServiceCategoryInfo.allCategories;
  }

  @override
  Future<List<GovernmentService>> getAllServices() async {
    return verifiedServices;
  }

  @override
  Future<GovernmentService?> getServiceById(String id) async {
    try {
      return verifiedServices.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<GovernmentService>> getServicesByCategory(String categoryId) async {
    if (categoryId == 'all') return verifiedServices;
    return verifiedServices.where((s) => s.category == categoryId).toList();
  }

  @override
  Future<List<GovernmentService>> searchServices(String query, {String? categoryId}) async {
    final cleanQuery = query.trim().toLowerCase();
    
    return verifiedServices.where((service) {
      if (categoryId != null && categoryId != 'all' && service.category != categoryId) {
        return false;
      }

      if (cleanQuery.isEmpty) return true;

      // Check raw keys, URLs, and source names
      if (service.id.toLowerCase().contains(cleanQuery) ||
          service.category.toLowerCase().contains(cleanQuery) ||
          service.nameKey.toLowerCase().contains(cleanQuery) ||
          service.departmentKey.toLowerCase().contains(cleanQuery) ||
          (service.officialWebsiteUrl?.toLowerCase().contains(cleanQuery) ?? false) ||
          (service.sourceName?.toLowerCase().contains(cleanQuery) ?? false)) {
        return true;
      }

      // Check across all three supported languages (en, mr, hi)
      for (final lang in ['en', 'mr', 'hi']) {
        final dict = AppTranslations.values[lang];
        if (dict != null) {
          final localizedName = dict[service.nameKey]?.toLowerCase() ?? '';
          final localizedDesc = dict[service.shortDescriptionKey]?.toLowerCase() ?? '';
          final localizedDept = dict[service.departmentKey]?.toLowerCase() ?? '';
          final localizedElig = dict[service.eligibilityKey]?.toLowerCase() ?? '';
          final localizedMethod = dict[service.applicationMethodKey]?.toLowerCase() ?? '';

          if (localizedName.contains(cleanQuery) ||
              localizedDesc.contains(cleanQuery) ||
              localizedDept.contains(cleanQuery) ||
              localizedElig.contains(cleanQuery) ||
              localizedMethod.contains(cleanQuery)) {
            return true;
          }
        }
      }

      return false;
    }).toList();
  }
}
