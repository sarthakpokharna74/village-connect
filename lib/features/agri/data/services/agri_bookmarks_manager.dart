import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing bookmarked agricultural resources locally in GramConnect.
/// Persists across app launches via SharedPreferences without requiring login.
class AgriBookmarksManager {
  static const String _key = 'gc_saved_agri_resource_ids';

  static final AgriBookmarksManager _instance = AgriBookmarksManager._internal();
  factory AgriBookmarksManager() => _instance;
  AgriBookmarksManager._internal();

  final ValueNotifier<List<String>> bookmarksNotifier = ValueNotifier<List<String>>([]);
  bool _initialized = false;

  /// Initialize bookmarks from SharedPreferences
  Future<void> init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedList = prefs.getStringList(_key) ?? [];
      bookmarksNotifier.value = List<String>.unmodifiable(savedList);
      _initialized = true;
    } catch (e) {
      debugPrint('Error loading saved agri bookmarks: $e');
    }
  }

  /// Check whether an item is bookmarked
  bool isBookmarked(String id) {
    return bookmarksNotifier.value.contains(id);
  }

  /// Toggle bookmark state for an item.
  /// Returns `true` if added, `false` if removed.
  Future<bool> toggleBookmark(String id) async {
    await init();
    final currentList = List<String>.from(bookmarksNotifier.value);
    bool added = false;
    if (currentList.contains(id)) {
      currentList.remove(id);
      added = false;
    } else {
      currentList.add(id);
      added = true;
    }

    bookmarksNotifier.value = List<String>.unmodifiable(currentList);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, currentList);
    } catch (e) {
      debugPrint('Error saving agri bookmarks: $e');
    }

    return added;
  }

  /// Remove an item from bookmarks directly
  Future<void> removeBookmark(String id) async {
    await init();
    if (bookmarksNotifier.value.contains(id)) {
      final currentList = List<String>.from(bookmarksNotifier.value)..remove(id);
      bookmarksNotifier.value = List<String>.unmodifiable(currentList);
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(_key, currentList);
      } catch (e) {
        debugPrint('Error removing agri bookmark: $e');
      }
    }
  }

  /// Get list of bookmarked resource IDs
  List<String> getBookmarkedIds() {
    return bookmarksNotifier.value;
  }
}
