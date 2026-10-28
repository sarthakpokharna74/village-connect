import 'package:flutter/material.dart';

/// Represents a simple administrative fact card.
class VillageFact {
  final String titleKey;
  final String valueKey;
  final String? subtitleKey;
  final IconData icon;

  const VillageFact({
    required this.titleKey,
    required this.valueKey,
    this.subtitleKey,
    required this.icon,
  });
}

/// Represents a local landmark or place that defines Dhawalpuri.
class VillagePlace {
  final String id;
  final String nameKey;
  final String descriptionKey;
  final String? imageUrl;
  final String locationKey;
  final double? latitude;
  final double? longitude;

  const VillagePlace({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    this.imageUrl,
    required this.locationKey,
    this.latitude,
    this.longitude,
  });
}

/// Represents a village facility category and mock item.
class VillageFacility {
  final String id;
  final String categoryKey; // e.g. 'schools', 'health', 'govt_offices', etc.
  final String nameKey;
  final String descriptionKey;
  final IconData icon;

  const VillageFacility({
    required this.id,
    required this.categoryKey,
    required this.nameKey,
    required this.descriptionKey,
    required this.icon,
  });
}

/// Represents an item in the village photo gallery.
class VillagePhoto {
  final String id;
  final String imageUrl;
  final String titleKey;
  final String descriptionKey;
  final String categoryKey;

  const VillagePhoto({
    required this.id,
    required this.imageUrl,
    required this.titleKey,
    required this.descriptionKey,
    required this.categoryKey,
  });
}

/// Represents general village text like introduction and history.
class VillageInfo {
  final String introKey;
  final String historyKey;

  const VillageInfo({
    required this.introKey,
    required this.historyKey,
  });
}
