import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing bookmarked village news stories locally.
/// Persists across app launches via SharedPreferences without requiring login.
class NewsBookmarksManager {
  static const String _key = 'gc_bookmarked_news_ids';

  static final NewsBookmarksManager _instance = NewsBookmarksManager._internal();
  factory NewsBookmarksManager() => _instance;
  NewsBookmarksManager._internal();

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
      debugPrint('Error loading saved news bookmarks: $e');
    }
  }

  /// Check whether an article is bookmarked
  bool isBookmarked(String articleId) {
    return bookmarksNotifier.value.contains(articleId);
  }

  /// Toggle bookmark state for an article.
  /// Returns `true` if article was added to bookmarks, `false` if removed.
  Future<bool> toggleBookmark(String articleId) async {
    await init();
    final currentList = List<String>.from(bookmarksNotifier.value);
    bool added = false;
    if (currentList.contains(articleId)) {
      currentList.remove(articleId);
      added = false;
    } else {
      currentList.add(articleId);
      added = true;
    }

    bookmarksNotifier.value = List<String>.unmodifiable(currentList);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, currentList);
    } catch (e) {
      debugPrint('Error saving news bookmarks: $e');
    }

    return added;
  }

  /// Remove an article from bookmarks directly
  Future<void> removeBookmark(String articleId) async {
    await init();
    if (bookmarksNotifier.value.contains(articleId)) {
      final currentList = List<String>.from(bookmarksNotifier.value)..remove(articleId);
      bookmarksNotifier.value = List<String>.unmodifiable(currentList);
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(_key, currentList);
      } catch (e) {
        debugPrint('Error saving news bookmarks: $e');
      }
    }
  }

  /// Get list of bookmarked article IDs
  List<String> getBookmarkedIds() {
    return bookmarksNotifier.value;
  }
}
