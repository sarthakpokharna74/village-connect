import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local storage manager for Government Services favorites (saved services).
/// Implements Blueprint 7 Section 8: Zero login required, stored locally.
class ServiceFavoritesManager extends ChangeNotifier {
  static const String _storageKey = 'gramconnect_saved_gov_services';
  
  static final ServiceFavoritesManager _instance = ServiceFavoritesManager._internal();
  factory ServiceFavoritesManager() => _instance;
  ServiceFavoritesManager._internal();

  Set<String> _favoriteIds = {};
  bool _isInitialized = false;

  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);
  bool get isInitialized => _isInitialized;

  /// Loads saved service IDs from local SharedPreferences.
  Future<void> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_storageKey) ?? [];
      _favoriteIds = list.toSet();
      _isInitialized = true;
      notifyListeners();
    } catch (_) {
      // In-memory fallback if SharedPreferences is unavailable
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Checks if a service ID is currently favorited.
  bool isFavorite(String serviceId) {
    return _favoriteIds.contains(serviceId);
  }

  /// Toggles favorite status for a service and persists locally.
  Future<bool> toggleFavorite(String serviceId) async {
    final willBeFavorite = !_favoriteIds.contains(serviceId);
    
    if (willBeFavorite) {
      _favoriteIds.add(serviceId);
    } else {
      _favoriteIds.remove(serviceId);
    }
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKey, _favoriteIds.toList());
    } catch (_) {
      // Memory state preserved
    }

    return willBeFavorite;
  }
}
