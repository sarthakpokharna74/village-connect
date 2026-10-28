import 'package:flutter/material.dart';
import '../models/village_models.dart';

abstract class VillageRepository {
  Future<VillageInfo> getVillageInfo();
  Future<List<VillageFact>> getVillageFacts();
  Future<List<VillagePlace>> getVillagePlaces();
  Future<List<VillageFacility>> getVillageFacilities();
  Future<List<VillagePhoto>> getVillagePhotos();
}

class MockVillageRepository implements VillageRepository {
  const MockVillageRepository();

  @override
  Future<VillageInfo> getVillageInfo() async {
    return const VillageInfo(
      introKey: 'village_intro_text',
      historyKey: 'history_placeholder',
    );
  }

  @override
  Future<List<VillageFact>> getVillageFacts() async {
    return const [
      VillageFact(
        titleKey: 'population_title',
        valueKey: 'total_pop_val',
        subtitleKey: 'census_2011',
        icon: Icons.groups_rounded,
      ),
      VillageFact(
        titleKey: 'households_title',
        valueKey: 'households_val',
        subtitleKey: 'census_2011',
        icon: Icons.home_rounded,
      ),
      VillageFact(
        titleKey: 'taluka',
        valueKey: 'taluka_val',
        icon: Icons.explore_rounded,
      ),
      VillageFact(
        titleKey: 'district',
        valueKey: 'district_val',
        icon: Icons.domain_rounded,
      ),
      VillageFact(
        titleKey: 'occupation',
        valueKey: 'occupation_val',
        icon: Icons.agriculture_rounded,
      ),
      VillageFact(
        titleKey: 'panchayat',
        valueKey: 'panchayat_val',
        icon: Icons.corporate_fare_rounded,
      ),
    ];
  }

  @override
  Future<List<VillagePlace>> getVillagePlaces() async {
    return const [
      VillagePlace(
        id: 'pl1',
        nameKey: 'place_temple_title',
        descriptionKey: 'place_temple_desc',
        locationKey: 'place_temple_loc',
        latitude: null, // Precise GPS pending official surveying
        longitude: null,
      ),
      VillagePlace(
        id: 'pl2',
        nameKey: 'place_dam_title',
        descriptionKey: 'place_dam_desc',
        locationKey: 'place_dam_loc',
        latitude: null, // Precise GPS pending official surveying
        longitude: null,
      ),
    ];
  }

  @override
  Future<List<VillageFacility>> getVillageFacilities() async {
    return const [
      VillageFacility(
        id: 'fa1',
        categoryKey: 'schools',
        nameKey: 'facility_school_name',
        descriptionKey: 'facility_school_desc',
        icon: Icons.school_rounded,
      ),
      VillageFacility(
        id: 'fa2',
        categoryKey: 'health',
        nameKey: 'facility_health_name',
        descriptionKey: 'facility_health_desc',
        icon: Icons.health_and_safety_rounded,
      ),
      VillageFacility(
        id: 'fa3',
        categoryKey: 'govt_offices',
        nameKey: 'facility_office_name',
        descriptionKey: 'facility_office_desc',
        icon: Icons.account_balance_rounded,
      ),
      VillageFacility(
        id: 'fa4',
        categoryKey: 'markets_shops',
        nameKey: 'facility_market_name',
        descriptionKey: 'facility_market_desc',
        icon: Icons.storefront_rounded,
      ),
      VillageFacility(
        id: 'fa5',
        categoryKey: 'transport',
        nameKey: 'facility_transport_name',
        descriptionKey: 'facility_transport_desc',
        icon: Icons.directions_bus_rounded,
      ),
      VillageFacility(
        id: 'fa6',
        categoryKey: 'water_facilities',
        nameKey: 'facility_water_name',
        descriptionKey: 'facility_water_desc',
        icon: Icons.water_drop_rounded,
      ),
    ];
  }

  @override
  Future<List<VillagePhoto>> getVillagePhotos() async {
    return const [
      VillagePhoto(
        id: 'ph1',
        imageUrl: 'placeholder_1',
        titleKey: 'photo_panchayat_title',
        descriptionKey: 'photo_panchayat_desc',
        categoryKey: 'admin',
      ),
      VillagePhoto(
        id: 'ph2',
        imageUrl: 'placeholder_2',
        titleKey: 'photo_temple_title',
        descriptionKey: 'photo_temple_desc',
        categoryKey: 'culture',
      ),
      VillagePhoto(
        id: 'ph3',
        imageUrl: 'placeholder_3',
        titleKey: 'photo_fields_title',
        descriptionKey: 'photo_fields_desc',
        categoryKey: 'agriculture',
      ),
    ];
  }
}
