import 'package:flutter/foundation.dart';
import '../../../../core/localization/translations.dart';
import '../models/community_model.dart';

/// Abstract contract for Community data operations in GramConnect.
/// Prepares the application for future Supabase or REST backend integrations.
abstract class CommunityRepository {
  Future<List<CommunityItem>> getCommunityItems();
  Future<CommunityItem?> getFeaturedActivity();
  Future<List<CommunityItem>> searchCommunity(
    String query, {
    String? category,
    Map<String, String>? localizedNames,
    Map<String, String>? localizedDescriptions,
  });
  Future<bool> joinGroup(String itemId, String userId);
  Future<bool> registerActivity(String itemId, String userId);
  Future<bool> volunteer(String itemId, String userId);
  bool hasUserJoined(String itemId);
  bool hasUserRegistered(String itemId);
  bool hasUserVolunteered(String itemId);
  Future<bool> submitActivity(CommunitySubmission submission);
  List<CommunitySubmission> getSubmissions();
}

/// Mock Community Repository implementation.
/// Tracks prototype join/volunteer/register states and user-submitted suggestions in-memory.
class MockCommunityRepository implements CommunityRepository {
  // Singleton pattern so state persists across tab switches and route transitions
  static final MockCommunityRepository _instance = MockCommunityRepository._internal();
  factory MockCommunityRepository() => _instance;
  MockCommunityRepository._internal();

  final Set<String> _joinedItemIds = {};
  final Set<String> _registeredItemIds = {};
  final Set<String> _volunteeredItemIds = {};
  final List<CommunitySubmission> _submissions = [];

  @override
  Future<List<CommunityItem>> getCommunityItems() async {
    // Simulate brief mobile network latency (150ms)
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(CommunityItem.mockItems);
  }

  @override
  Future<CommunityItem?> getFeaturedActivity() async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return CommunityItem.mockItems.firstWhere((item) => item.isFeatured);
    } catch (_) {
      return CommunityItem.mockItems.isNotEmpty ? CommunityItem.mockItems.first : null;
    }
  }

  @override
  Future<List<CommunityItem>> searchCommunity(
    String query, {
    String? category,
    Map<String, String>? localizedNames,
    Map<String, String>? localizedDescriptions,
  }) async {
    final cleanQuery = query.trim().toLowerCase();
    final items = CommunityItem.mockItems;

    return items.where((item) {
      // Category filter check
      if (category != null && category != 'all' && category.isNotEmpty) {
        if (item.category != category) return false;
      }

      if (cleanQuery.isEmpty) return true;

      // 1. Search in category, name, and description keys
      if (item.nameKey.toLowerCase().contains(cleanQuery) ||
          item.descriptionKey.toLowerCase().contains(cleanQuery) ||
          item.category.toLowerCase().contains(cleanQuery)) {
        return true;
      }

      // 2. Search in caller-provided localized strings if available
      if (localizedNames != null && localizedNames.containsKey(item.nameKey)) {
        if (localizedNames[item.nameKey]!.toLowerCase().contains(cleanQuery)) {
          return true;
        }
      }

      if (localizedDescriptions != null && localizedDescriptions.containsKey(item.descriptionKey)) {
        if (localizedDescriptions[item.descriptionKey]!.toLowerCase().contains(cleanQuery)) {
          return true;
        }
      }

      // 3. Fallback to searching across all supported translations dictionaries
      for (final langMap in AppTranslations.values.values) {
        final name = langMap[item.nameKey]?.toLowerCase() ?? '';
        final desc = langMap[item.descriptionKey]?.toLowerCase() ?? '';
        if (name.contains(cleanQuery) || desc.contains(cleanQuery)) {
          return true;
        }
      }

      return false;
    }).toList();
  }

  @override
  Future<bool> joinGroup(String itemId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _joinedItemIds.add(itemId);
    debugPrint('[MockCommunityRepository] User $userId joined group $itemId');
    return true;
  }

  @override
  Future<bool> registerActivity(String itemId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _registeredItemIds.add(itemId);
    debugPrint('[MockCommunityRepository] User $userId registered for activity $itemId');
    return true;
  }

  @override
  Future<bool> volunteer(String itemId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _volunteeredItemIds.add(itemId);
    debugPrint('[MockCommunityRepository] User $userId volunteered for $itemId');
    return true;
  }

  @override
  bool hasUserJoined(String itemId) => _joinedItemIds.contains(itemId);

  @override
  bool hasUserRegistered(String itemId) => _registeredItemIds.contains(itemId);

  @override
  bool hasUserVolunteered(String itemId) => _volunteeredItemIds.contains(itemId);

  @override
  Future<bool> submitActivity(CommunitySubmission submission) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _submissions.insert(0, submission);
    debugPrint('[MockCommunityRepository] Saved community submission: ${submission.title} (${submission.category})');
    return true;
  }

  @override
  List<CommunitySubmission> getSubmissions() => List.unmodifiable(_submissions);
}
