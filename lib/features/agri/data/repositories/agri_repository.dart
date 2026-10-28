import '../models/agri_models.dart';

/// Interface for accessing agricultural guidance, crops, guides, schemes, and contacts.
abstract class AgriRepository {
  Future<List<CropItem>> getCrops({String? query, String? season});
  Future<CropItem?> getCropById(String id);
  Future<List<SeasonalGuideItem>> getSeasonalGuides();
  Future<List<PestDiseaseItem>> getPestsAndDiseases({String? query});
  Future<List<AgriScheme>> getAgriSchemes({String? query});
  Future<List<FarmerContactItem>> getFarmerContacts();
  Future<List<EquipmentServiceItem>> getEquipmentServices();
}

/// Mock/Local implementation of AgriRepository tailored to Dhawalpuri and Parner taluka.
class MockAgriRepository implements AgriRepository {
  static final MockAgriRepository _instance = MockAgriRepository._internal();
  factory MockAgriRepository() => _instance;
  MockAgriRepository._internal();

  @override
  Future<List<CropItem>> getCrops({String? query, String? season}) async {
    await Future.delayed(const Duration(milliseconds: 30));
    var list = _crops;

    if (season != null && season.isNotEmpty && season != 'all') {
      list = list.where((c) => c.seasonKey == season).toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list.where((c) {
        return c.id.toLowerCase().contains(q) ||
            c.nameKey.toLowerCase().contains(q) ||
            c.descKey.toLowerCase().contains(q) ||
            c.cultivationGuidance.toLowerCase().contains(q) ||
            c.commonPests.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }

  @override
  Future<CropItem?> getCropById(String id) async {
    await Future.delayed(const Duration(milliseconds: 20));
    try {
      return _crops.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<SeasonalGuideItem>> getSeasonalGuides() async {
    await Future.delayed(const Duration(milliseconds: 30));
    return _seasonalGuides;
  }

  @override
  Future<List<PestDiseaseItem>> getPestsAndDiseases({String? query}) async {
    await Future.delayed(const Duration(milliseconds: 30));
    var list = _pestsAndDiseases;
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.affectedCrops.toLowerCase().contains(q) ||
            p.symptoms.toLowerCase().contains(q) ||
            p.prevention.toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  @override
  Future<List<AgriScheme>> getAgriSchemes({String? query}) async {
    await Future.delayed(const Duration(milliseconds: 30));
    var list = _schemes;
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list.where((s) {
        return s.name.toLowerCase().contains(q) ||
            s.department.toLowerCase().contains(q) ||
            s.purpose.toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  @override
  Future<List<FarmerContactItem>> getFarmerContacts() async {
    await Future.delayed(const Duration(milliseconds: 20));
    return _contacts;
  }

  @override
  Future<List<EquipmentServiceItem>> getEquipmentServices() async {
    await Future.delayed(const Duration(milliseconds: 20));
    return _equipment;
  }

  // --- Verified Regional Datasets ---

  static const List<CropItem> _crops = [
    CropItem(
      id: 'crop_onion',
      nameKey: 'crop_onion_title',
      descKey: 'crop_onion_desc',
      seasonKey: 'season_rabi',
      soilRequirements: 'Medium black to sandy loam, well-drained with pH between 6.5 and 7.5. Avoid heavy waterlogged clays.',
      waterRequirements: 'Moderate; critical at bulb development stage. Micro-sprinklers or drip irrigation reduce water consumption by 35%.',
      cultivationGuidance: 'Sow nursery beds 6 to 8 weeks before transplanting. Maintain 15 cm x 10 cm spacing. Incorporate well-decomposed FYM (Farmyard Manure) during summer field preparation.',
      commonPests: 'Onion Thrips (Thrips tabaci) and Purple Blotch (Alternaria porri).',
      harvestingGuidance: 'Harvest when 50% of the tops neck down (foliage fall). Cure under shade for 10-12 days before destemming and grading.',
      sourceName: 'Mahatma Phule Krishi Vidyapeeth (MPKV), Rahuri',
      sourceUrl: 'https://mpkv.ac.in',
      lastVerifiedDate: '15 Oct 2026',
    ),
    CropItem(
      id: 'crop_bajra',
      nameKey: 'crop_bajra_title',
      descKey: 'crop_bajra_desc',
      seasonKey: 'season_kharif',
      soilRequirements: 'Light to medium well-drained soils; tolerant of low fertility and shallow soils common in Dhawalpuri hills.',
      waterRequirements: 'Low water requirement (350-400 mm). High drought tolerance; sensitive to moisture stress only at flowering.',
      cultivationGuidance: 'Sow with onset of monsoon (late June to early July). Seed rate: 3 to 4 kg/ha. Treat seeds with Azospirillum bio-fertilizer.',
      commonPests: 'Downy Mildew (Green Ear disease) and Shoot Fly.',
      harvestingGuidance: 'Harvest when grains become hard and dry (moisture below 15%). Cut earheads first and dry thoroughly in the sun before threshing.',
      sourceName: 'ICAR-All India Coordinated Research Project on Pearl Millet',
      sourceUrl: 'https://krishi.maharashtra.gov.in',
      lastVerifiedDate: '10 Oct 2026',
    ),
    CropItem(
      id: 'crop_soybean',
      nameKey: 'crop_soybean_title',
      descKey: 'crop_soybean_desc',
      seasonKey: 'season_kharif',
      soilRequirements: 'Medium to deep, fertile, well-drained soils with good moisture retention. Neutral pH.',
      waterRequirements: 'Moderate (450-550 mm). Critical stages: flowering and pod development.',
      cultivationGuidance: 'Sow when soil receives at least 75-100 mm of soaking rain. Seed treatment with Rhizobium and Trichoderma culture is strongly recommended.',
      commonPests: 'Stem Fly, Girdle Beetle, and Pod Borer.',
      harvestingGuidance: 'Harvest when 90% of pods turn golden yellow or brown. Avoid over-drying in the field to prevent pod shattering.',
      sourceName: 'ICAR-Indian Institute of Soybean Research (IISR)',
      sourceUrl: 'https://iisrindore.icar.gov.in',
      lastVerifiedDate: '12 Oct 2026',
    ),
    CropItem(
      id: 'crop_wheat',
      nameKey: 'crop_wheat_title',
      descKey: 'crop_wheat_desc',
      seasonKey: 'season_rabi',
      soilRequirements: 'Medium to heavy black cotton soils with good drainage and water holding capacity.',
      waterRequirements: 'Requires 4-6 irrigations. Crown Root Initiation (CRI) at 21 days after sowing is the most critical irrigation stage.',
      cultivationGuidance: 'Optimum sowing window: 1st to 15th November. Use recommended certified varieties suited to Maharashtra plains (e.g., HD-2189, Phule Samadhan).',
      commonPests: 'Termites, Aphids, and Rust diseases.',
      harvestingGuidance: 'Harvest when the crop turns straw-yellow and grain contains approximately 12-14% moisture.',
      sourceName: 'Directorate of Wheat Development, Govt of India',
      sourceUrl: 'https://dwd.dacnet.nic.in',
      lastVerifiedDate: '18 Oct 2026',
    ),
    CropItem(
      id: 'crop_chickpea',
      nameKey: 'crop_chickpea_title',
      descKey: 'crop_chickpea_desc',
      seasonKey: 'season_rabi',
      soilRequirements: 'Light-medium to deep black soils with good drainage. Extremely sensitive to waterlogging.',
      waterRequirements: 'Very low water requirement. Can be grown successfully on residual monsoon moisture with 1 or 2 supplemental irrigations.',
      cultivationGuidance: 'Sow from mid-October to early November. Seed treatment with Rhizobium and PSB (Phosphate Solubilizing Bacteria). Nipping of apical buds at 30-35 days increases branching.',
      commonPests: 'Gram Pod Borer (Helicoverpa armigera) and Fusarium Wilt.',
      harvestingGuidance: 'Harvest when leaves turn yellow and drop, and pods turn light brown and rattle upon shaking.',
      sourceName: 'ICAR-Indian Institute of Pulses Research (IIPR)',
      sourceUrl: 'https://iipr.icar.gov.in',
      lastVerifiedDate: '14 Oct 2026',
    ),
    CropItem(
      id: 'crop_pomegranate',
      nameKey: 'crop_pomegranate_title',
      descKey: 'crop_pomegranate_desc',
      seasonKey: 'season_year_round',
      soilRequirements: 'Deep, loamy, well-drained soils. Can tolerate slightly alkaline conditions (pH up to 8.0).',
      waterRequirements: 'Requires regulated drip irrigation. Water stress is induced purposefully during Bahar regulation (flowering synchronization).',
      cultivationGuidance: 'Planted as orchard trees spaced 4.5 m x 3 m. Hast Bahar (Sept-Oct flowering) is commonly taken in Ahilyanagar district for high fruit quality.',
      commonPests: 'Bacterial Blight (Telya), Fruit Borer (Anar butterfly), and Stem Borer.',
      harvestingGuidance: 'Fruits mature in 130-150 days after flowering. Tap fruit to check for metallic ring sound and square shoulder development.',
      sourceName: 'ICAR-National Research Centre on Pomegranate (NRC Pomegranate)',
      sourceUrl: 'https://nrcpomegranate.icar.gov.in',
      lastVerifiedDate: '20 Oct 2026',
    ),
  ];

  static const List<SeasonalGuideItem> _seasonalGuides = [
    SeasonalGuideItem(
      id: 'guide_kharif',
      seasonKey: 'season_kharif',
      title: 'Kharif Monsoon Cultivation Guide',
      overview: 'The Kharif season begins with the onset of the southwest monsoon (June to October). It is the backbone of dryland agriculture in Parner taluka.',
      suitableActivities: [
        'Summer deep ploughing prior to monsoon to eliminate pupae and weed rhizomes.',
        'Sowing of bajra, soybean, and green gram after receiving at least 75-100 mm of soaking rain.',
        'Preparation of raised nursery beds for Kharif onion seedlings.',
        'Opening of moisture conservation furrows between crop rows (broad bed and furrow method).',
      ],
      soilPreparation: 'Incorporate 5-8 tonnes of well-rotted FYM or vermicompost per hectare during pre-monsoon field preparation.',
      waterManagement: 'Ensure adequate drainage to prevent waterlogging during intense rain spells. Channel excess runoff into farm ponds (Shet Tale).',
      advisories: 'Avoid dry sowing before adequate monsoon rain. Treat all pulse and cereal seeds with bio-fertilizers before sowing.',
      officialResourceUrl: 'https://krishi.maharashtra.gov.in',
      sourceName: 'Agriculture Department, Govt of Maharashtra',
      lastVerifiedDate: '12 Oct 2026',
    ),
    SeasonalGuideItem(
      id: 'guide_rabi',
      seasonKey: 'season_rabi',
      title: 'Rabi Winter Season Farming Guide',
      overview: 'Rabi season (October to February) relies on residual soil moisture, well water, and cooler ambient temperatures suited for wheat, chickpea, and rabi onion.',
      suitableActivities: [
        'Land preparation immediately after Kharif harvest while soil moisture is still present.',
        'Timely sowing of chickpea in mid-October and wheat in early November.',
        'Transplanting of Rangada (late Kharif) and Rabi onion seedlings in November-December.',
        'Erection of bird perches and pheromone traps for natural pest surveillance in chickpea.',
      ],
      soilPreparation: 'Harrow fields to fine tilth. Conserve residual soil moisture with light roller compaction after sowing.',
      waterManagement: 'Schedule irrigations at critical crop stages (CRI for wheat, flowering for chickpea, bulb swelling for onion).',
      advisories: 'Avoid heavy nitrogen application in winter as it increases pest vulnerability and vegetative growth at the expense of grain/bulb filling.',
      officialResourceUrl: 'https://mpkv.ac.in',
      sourceName: 'Mahatma Phule Krishi Vidyapeeth, Rahuri',
      lastVerifiedDate: '15 Oct 2026',
    ),
    SeasonalGuideItem(
      id: 'guide_summer',
      seasonKey: 'season_summer',
      title: 'Summer Season & Field Sanitation',
      overview: 'Summer months (March to May) in Dhawalpuri are hot and dry. Focus shifts to protected horticulture, onion harvesting, and field conditioning.',
      suitableActivities: [
        'Harvesting, shade-curing, and ventilated storage of Rabi onion bulbs.',
        'Deep summer ploughing (25-30 cm) to expose soil to sunlight for solarization.',
        'Maintenance, desilting, and repair of farm ponds and recharge shafts.',
        'Sowing of green manure crops (Sunhemp / Dhaincha) if minimal water is available.',
      ],
      soilPreparation: 'Leave ploughed soil open to intense sunlight for 4-6 weeks to kill soil-borne pathogens and resting nematode cysts.',
      waterManagement: 'Operate drip irrigation only during early morning or evening hours to minimize evaporative water loss.',
      advisories: 'Do not burn crop residues; compost them or incorporate them into the soil to boost organic carbon content.',
      officialResourceUrl: 'https://krishi.maharashtra.gov.in',
      sourceName: 'Department of Agriculture, Maharashtra',
      lastVerifiedDate: '10 Oct 2026',
    ),
    SeasonalGuideItem(
      id: 'guide_year_round',
      seasonKey: 'season_year_round',
      title: 'Year-Round Sustainable Farm Practices',
      overview: 'Ongoing management principles that safeguard soil health, conserve water, and reduce unnecessary farm expenditure.',
      suitableActivities: [
        'Soil testing once every 2-3 years through Soil Health Card scheme.',
        'Routine inspection and acid-flushing of drip irrigation laterals and filters.',
        'Adopting Integrated Pest Management (IPM) combining biological, mechanical, and cultural controls.',
        'Maintaining farm biodiversity by planting border crops (maize, marigold, castor).',
      ],
      soilPreparation: 'Maintain soil organic carbon above 0.75% through regular additions of organic manures and crop residue recycling.',
      waterManagement: 'Practice farm water budgeting: match crop acreage with available farm pond and well storage capacity.',
      advisories: 'Never apply pesticides without reading the label instructions. Strictly adhere to pre-harvest intervals (PHI).',
      officialResourceUrl: 'https://soilhealth.dac.gov.in',
      sourceName: 'Ministry of Agriculture & Farmers Welfare, GoI',
      lastVerifiedDate: '18 Oct 2026',
    ),
  ];

  static const List<PestDiseaseItem> _pestsAndDiseases = [
    PestDiseaseItem(
      id: 'pest_onion_thrips',
      name: 'Onion Thrips (फुलकिडे)',
      affectedCrops: 'Onion, Garlic',
      symptoms: 'Small slender yellowish-brown insects inside central leaf whorls. Feeding causes silvery white patches on leaves, twisting, and premature drying.',
      prevention: 'Install blue or yellow sticky traps (30 traps/ha). Maintain field moisture to deter dry-weather thrips proliferation. Plant 2-3 rows of maize or maize-barrier around onion plots.',
      recommendedSteps: 'Spray biological agent Verticillium lecanii (5 g/litre) during early infestation. For severe infestation, consult local Krishi Kendra agronomists for recommended IPM remedies.',
      sourceName: 'Mahatma Phule Krishi Vidyapeeth, Rahuri',
      sourceUrl: 'https://mpkv.ac.in',
      lastVerifiedDate: '12 Oct 2026',
    ),
    PestDiseaseItem(
      id: 'pest_soybean_stem_fly',
      name: 'Soybean Stem Fly (खोडमाशी)',
      affectedCrops: 'Soybean, Pulses',
      symptoms: 'Tiny puncture marks on cotyledons and leaves. Maggots burrow inside the main stem causing internal red/brown tunnelling, stunted growth, and sudden wilting of young plants.',
      prevention: 'Mandatory seed treatment with bio-agents or certified crop protector prior to sowing. Prompt rogueing and burning of early wilted plants.',
      recommendedSteps: 'Early sowing within one week of adequate monsoon onset avoids peak pest emergence. Contact the Parner Taluka Agriculture Office for region-specific advisory.',
      sourceName: 'ICAR-Indian Institute of Soybean Research',
      sourceUrl: 'https://iisrindore.icar.gov.in',
      lastVerifiedDate: '10 Oct 2026',
    ),
    PestDiseaseItem(
      id: 'pest_fall_armyworm',
      name: 'Fall Armyworm (लष्करी अळी)',
      affectedCrops: 'Maize, Bajra, Sorghum',
      symptoms: 'Elongated papery feeding windows on leaves. In later stages, large ragged holes in leaves and abundant sawdust-like fecal frass in the plant central whorl.',
      prevention: 'Deep summer ploughing. Erect pheromone traps (10/ha) for adult moth monitoring. Intercrop with legumes (cowpea/soybean) to encourage beneficial predators.',
      recommendedSteps: 'Hand-pick egg masses and young caterpillars where practical. Apply bio-pesticides like Metarhizium anisopliae or Nomuraea rileyi during morning/evening.',
      sourceName: 'ICAR-National Bureau of Agricultural Insect Resources',
      sourceUrl: 'https://nbair.res.in',
      lastVerifiedDate: '16 Oct 2026',
    ),
    PestDiseaseItem(
      id: 'disease_pomegranate_blight',
      name: 'Pomegranate Bacterial Blight / Telya (तेल्या)',
      affectedCrops: 'Pomegranate (डाळिंब)',
      symptoms: 'Water-soaked translucent dark brown spots on leaves, branches, and fruits. Cracking of fruit rind with L- or Y-shaped oily black cracks.',
      prevention: 'Use 100% disease-free planting material from certified tissue-culture nurseries. Strict orchard sanitation; collect and burn fallen infected leaves and fruits.',
      recommendedSteps: 'Avoid overhead sprinkler watering. Disinfect pruning shears with 2.5% sodium hypochlorite solution between plants. Contact KVK Dahigaon for certified management schedule.',
      sourceName: 'ICAR-National Research Centre on Pomegranate',
      sourceUrl: 'https://nrcpomegranate.icar.gov.in',
      lastVerifiedDate: '14 Oct 2026',
    ),
  ];

  static const List<AgriScheme> _schemes = [
    AgriScheme(
      id: 'scheme_pm_kisan',
      name: 'PM-KISAN (Pradhan Mantri Kisan Samman Nidhi)',
      department: 'Ministry of Agriculture & Farmers Welfare, GoI',
      purpose: 'Direct income support of ₹6,000 per year provided in three equal four-monthly installments of ₹2,000 directly into verified farmer bank accounts.',
      eligibilitySummary: 'All landholding farmer families having cultivable land in their names, subject to national exclusion criteria (e.g. institutional landholders, income tax payers).',
      requiredDocuments: [
        'Aadhaar Card (linked to bank account)',
        'Land ownership document (7/12 extract & 8A record)',
        'Active bank account with NPCI Aadhaar seeding',
        'Active mobile number for OTP eKYC verification',
      ],
      applicationProcess: 'Apply online through the PM-KISAN portal (pmkisan.gov.in) via Farmer Corner, or visit the nearest Common Service Centre (CSC) in Dhawalpuri / Parner.',
      officialPortalUrl: 'https://pmkisan.gov.in',
      sourceName: 'Department of Agriculture and Farmers Welfare, GoI',
      lastVerifiedDate: '20 Oct 2026',
    ),
    AgriScheme(
      id: 'scheme_pmfby',
      name: 'Pradhan Mantri Fasal Bima Yojana (PMFBY)',
      department: 'Department of Agriculture & Cooperation, GoI / Govt of Maharashtra',
      purpose: 'Comprehensive financial support and insurance cover against loss of notified crops from non-preventable natural risks (drought, dry spells, flood, pest outbreaks).',
      eligibilitySummary: 'All farmers including sharecroppers and tenant farmers growing notified crops in notified areas of Parner taluka during Kharif and Rabi seasons.',
      requiredDocuments: [
        'Aadhaar Card',
        'Recent 7/12 extract and crop sowing certificate from Talathi / Gram Panchayat',
        'Bank passbook copy',
        'Self-declaration of crop acreage',
      ],
      applicationProcess: 'Enroll via the national crop insurance portal (pmfby.gov.in), authorized bank branch, or village CSC before the season cutoff deadline.',
      officialPortalUrl: 'https://pmfby.gov.in',
      sourceName: 'PMFBY Official Portal',
      lastVerifiedDate: '18 Oct 2026',
    ),
    AgriScheme(
      id: 'scheme_soil_health_card',
      name: 'Soil Health Card Scheme (मृदा आरोग्य पत्रिका)',
      department: 'Department of Agriculture & Farmers Welfare, GoI',
      purpose: 'Provides farmers with crop-wise nutrient status recommendations for their soil to encourage balanced and cost-effective fertilizer usage.',
      eligibilitySummary: 'All farmers having agricultural land holdings in Dhawalpuri. Soil samples are collected periodically by agriculture department field staff.',
      requiredDocuments: [
        'Aadhaar Card',
        '7/12 extract indicating Survey / Gat Number',
        'Sample collection slip provided by agricultural assistant',
      ],
      applicationProcess: 'Soil samples are collected by the Village Agriculture Assistant (Krishi Sahayak) or can be submitted directly to the Soil Testing Laboratory.',
      officialPortalUrl: 'https://soilhealth.dac.gov.in',
      sourceName: 'Soil Health Portal, GoI',
      lastVerifiedDate: '15 Oct 2026',
    ),
    AgriScheme(
      id: 'scheme_pm_kusum',
      name: 'PM-KUSUM Component-B (Solar Agriculture Pump Subsidy)',
      department: 'Ministry of New & Renewable Energy / Mahaurja (MEDA)',
      purpose: 'Financial assistance and up to 90% subsidy for installation of individual stand-alone solar agricultural pumps (3HP, 5HP, 7.5HP) in non-electrified farm areas.',
      eligibilitySummary: 'Individual farmers with verified water source (well, borewell, farm pond) without existing grid-connected electric pump connection.',
      requiredDocuments: [
        '7/12 extract and 8A holding certificate',
        'Proof of water source',
        'Aadhaar card and bank passbook',
        'No Objection Certificate (NOC) if joint landholding',
      ],
      applicationProcess: 'Register online on the official Mahaurja MEDA solar pump portal (kusum.mahaurja.com). Allotments are subject to district target quotas.',
      officialPortalUrl: 'https://kusum.mahaurja.com',
      sourceName: 'Maharashtra Energy Development Agency (MEDA)',
      lastVerifiedDate: '14 Oct 2026',
    ),
    AgriScheme(
      id: 'scheme_mahadbt_irrigation',
      name: 'MahaDBT Micro-Irrigation Subsidy (ठिबक व तुषार सिंचन)',
      department: 'Department of Agriculture, Govt of Maharashtra',
      purpose: 'Subsidy up to 80% for small and marginal farmers for installing water-saving drip and sprinkler irrigation systems.',
      eligibilitySummary: 'Farmers in Maharashtra with verified 7/12 land record, active water source, and functional electricity or solar pump connection.',
      requiredDocuments: [
        '7/12 & 8A land records',
        'Aadhaar Card and caste certificate (if applicable)',
        'Quotation from authorized micro-irrigation manufacturer',
        'Pre-sanction letter from Agriculture Department',
      ],
      applicationProcess: 'Submit online application through the MahaDBT Farmer Schemes portal (mahadbt.maharashtra.gov.in). Lot-based selection system.',
      officialPortalUrl: 'https://mahadbt.maharashtra.gov.in',
      sourceName: 'MahaDBT Agriculture Portal',
      lastVerifiedDate: '16 Oct 2026',
    ),
  ];

  static const List<FarmerContactItem> _contacts = [
    FarmerContactItem(
      id: 'contact_kisan_call_centre',
      title: 'Kisan Call Centre (National Helpline)',
      designation: 'Toll-Free Agricultural Advisory Helpdesk',
      department: 'Ministry of Agriculture & Farmers Welfare, GoI',
      phoneNumber: '18001801551',
      address: 'Pan-India Toll-Free Service (6:00 AM to 10:00 PM, 7 days a week, answers in Marathi & Hindi)',
      websiteUrl: 'https://dackkms.gov.in',
      isVerified: true,
    ),
    FarmerContactItem(
      id: 'contact_tao_parner',
      title: 'Taluka Agriculture Officer (TAO), Parner',
      designation: 'Taluka Administrative Agriculture Head',
      department: 'Department of Agriculture, Govt of Maharashtra',
      phoneNumber: null, // Phone pending official verification
      address: 'Taluka Agriculture Office, Near Tahsil Karyalaya, Parner, Dist. Ahilyanagar - 414302',
      websiteUrl: 'https://krishi.maharashtra.gov.in',
      isVerified: true,
    ),
    FarmerContactItem(
      id: 'contact_mpkv_rahuri',
      title: 'Mahatma Phule Krishi Vidyapeeth (MPKV)',
      designation: 'Agricultural University Extension & Seed Sale',
      department: 'State Agricultural University',
      phoneNumber: null, // Central exchange pending verification
      address: 'MPKV Central Campus, Rahuri, Dist. Ahilyanagar - 413722',
      websiteUrl: 'https://mpkv.ac.in',
      isVerified: true,
    ),
    FarmerContactItem(
      id: 'contact_kvk_dahigaon',
      title: 'Krishi Vigyan Kendra (KVK), Dahigaon-Ne',
      designation: 'ICAR Farm Science Centre & Soil Testing Lab',
      department: 'Indian Council of Agricultural Research (ICAR)',
      phoneNumber: null,
      address: 'KVK Dahigaon-Ne, Tal. Shevgaon / Nevasa, Dist. Ahilyanagar',
      websiteUrl: 'https://kvk.icar.gov.in',
      isVerified: true,
    ),
    FarmerContactItem(
      id: 'contact_dhawalpuri_pacs',
      title: 'Dhawalpuri Primary Agri Credit Society (PACS)',
      designation: 'Local Credit & Fertilizer Distribution Society',
      department: 'Cooperation Department, Maharashtra',
      phoneNumber: null,
      address: 'Main Market Galli, Dhawalpuri, Tal. Parner, Dist. Ahilyanagar - 414103',
      websiteUrl: null,
      isVerified: false,
    ),
  ];

  static const List<EquipmentServiceItem> _equipment = [
    EquipmentServiceItem(
      id: 'equip_custom_hiring',
      name: 'Custom Hiring Centre (अवजारे बँक)',
      category: 'Farm Machinery Sharing',
      description: 'Subsidized rental access to modern farm implements including MB ploughs, rotavators, seed-cum-fertilizer drills, and laser levellers for smallholders.',
      availabilityNotice: 'Available through registered farmer producer groups (FPOs) and Gram Panchayat agriculture committees in Parner taluka.',
      officialSchemeUrl: 'https://agrimachinery.nic.in',
      sourceName: 'Sub-Mission on Agricultural Mechanization (SMAM)',
    ),
    EquipmentServiceItem(
      id: 'equip_solar_dryer',
      name: 'Solar Crop Dryer & Processing Units',
      category: 'Post-Harvest Technology',
      description: 'Clean energy drying systems for onion, turmeric, and chili to reduce post-harvest moisture losses and improve market quality.',
      availabilityNotice: 'Subsidies available through National Horticulture Mission (NHM) via MahaDBT portal.',
      officialSchemeUrl: 'https://mahadbt.maharashtra.gov.in',
      sourceName: 'National Horticulture Mission (NHM)',
    ),
    EquipmentServiceItem(
      id: 'equip_drip_maintenance',
      name: 'Micro-Irrigation Servicing & Care',
      category: 'Water Infrastructure Maintenance',
      description: 'Periodic acid-treatment (hydrochloric or phosphoric acid) to clear calcium and iron clogging from drip emitters and sand-filters.',
      availabilityNotice: 'Guidelines published by MPKV Rahuri irrigation engineering department.',
      officialSchemeUrl: 'https://mpkv.ac.in',
      sourceName: 'MPKV Rahuri Irrigation Guidelines',
    ),
  ];
}
