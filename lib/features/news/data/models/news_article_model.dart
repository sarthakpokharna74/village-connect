import 'package:flutter/material.dart';

/// Publication lifecycle state of a village news article.
enum NewsPublicationStatus {
  draft,
  pendingReview,
  published,
  rejected;

  String get translationKey {
    switch (this) {
      case NewsPublicationStatus.draft:
        return 'status_draft';
      case NewsPublicationStatus.pendingReview:
        return 'status_pending_review';
      case NewsPublicationStatus.published:
        return 'status_published';
      case NewsPublicationStatus.rejected:
        return 'status_rejected';
    }
  }

  Color get color {
    switch (this) {
      case NewsPublicationStatus.draft:
        return const Color(0xFF757575);
      case NewsPublicationStatus.pendingReview:
        return const Color(0xFFF57C00); // Amber/Orange
      case NewsPublicationStatus.published:
        return const Color(0xFF2E7D32); // Green
      case NewsPublicationStatus.rejected:
        return const Color(0xFFD32F2F); // Red
    }
  }
}

/// Verification status for news stories to build trust.
enum NewsVerificationStatus {
  verified,
  unverified,
  pendingVerification;

  String get translationKey {
    switch (this) {
      case NewsVerificationStatus.verified:
        return 'verification_verified';
      case NewsVerificationStatus.unverified:
        return 'verification_unverified';
      case NewsVerificationStatus.pendingVerification:
        return 'verification_pending';
    }
  }

  Color get color {
    switch (this) {
      case NewsVerificationStatus.verified:
        return const Color(0xFF1B5E20); // Dark Green
      case NewsVerificationStatus.unverified:
        return const Color(0xFFE65100); // Orange
      case NewsVerificationStatus.pendingVerification:
        return const Color(0xFF0277BD); // Light Blue
    }
  }

  IconData get icon {
    switch (this) {
      case NewsVerificationStatus.verified:
        return Icons.verified_rounded;
      case NewsVerificationStatus.unverified:
        return Icons.info_outline_rounded;
      case NewsVerificationStatus.pendingVerification:
        return Icons.pending_actions_rounded;
    }
  }
}

/// 10 Blueprint 9 News Categories for Dhawalpuri
class NewsCategoryInfo {
  final String key;
  final String titleKey;
  final String descKey;
  final IconData icon;
  final Color color;

  const NewsCategoryInfo({
    required this.key,
    required this.titleKey,
    required this.descKey,
    required this.icon,
    required this.color,
  });

  static const List<NewsCategoryInfo> categories = [
    NewsCategoryInfo(
      key: 'village_development',
      titleKey: 'cat_news_village_development',
      descKey: 'cat_news_village_development_desc',
      icon: Icons.foundation_rounded,
      color: Color(0xFF0277BD), // Blue
    ),
    NewsCategoryInfo(
      key: 'gram_panchayat_updates',
      titleKey: 'cat_news_gram_panchayat_updates',
      descKey: 'cat_news_gram_panchayat_updates_desc',
      icon: Icons.account_balance_rounded,
      color: Color(0xFF2E7D32), // Forest Green
    ),
    NewsCategoryInfo(
      key: 'agriculture_farming',
      titleKey: 'cat_news_agriculture_farming',
      descKey: 'cat_news_agriculture_farming_desc',
      icon: Icons.agriculture_rounded,
      color: Color(0xFF558B2F), // Light Green
    ),
    NewsCategoryInfo(
      key: 'education',
      titleKey: 'cat_news_education',
      descKey: 'cat_news_education_desc',
      icon: Icons.school_rounded,
      color: Color(0xFF6A1B9A), // Purple
    ),
    NewsCategoryInfo(
      key: 'health_awareness',
      titleKey: 'cat_news_health_awareness',
      descKey: 'cat_news_health_awareness_desc',
      icon: Icons.health_and_safety_rounded,
      color: Color(0xFFC2185B), // Pink/Red
    ),
    NewsCategoryInfo(
      key: 'community_achievements',
      titleKey: 'cat_news_community_achievements',
      descKey: 'cat_news_community_achievements_desc',
      icon: Icons.emoji_events_rounded,
      color: Color(0xFFF57F17), // Gold/Amber
    ),
    NewsCategoryInfo(
      key: 'culture_heritage',
      titleKey: 'cat_news_culture_heritage',
      descKey: 'cat_news_culture_heritage_desc',
      icon: Icons.temple_hindu_rounded,
      color: Color(0xFFD84315), // Deep Orange / Terracotta
    ),
    NewsCategoryInfo(
      key: 'environment',
      titleKey: 'cat_news_environment',
      descKey: 'cat_news_environment_desc',
      icon: Icons.eco_rounded,
      color: Color(0xFF00695C), // Teal
    ),
    NewsCategoryInfo(
      key: 'public_information',
      titleKey: 'cat_news_public_information',
      descKey: 'cat_news_public_information_desc',
      icon: Icons.campaign_rounded,
      color: Color(0xFF1565C0), // Royal Blue
    ),
    NewsCategoryInfo(
      key: 'general_news',
      titleKey: 'cat_news_general_news',
      descKey: 'cat_news_general_news_desc',
      icon: Icons.newspaper_rounded,
      color: Color(0xFF455A64), // Blue Grey
    ),
  ];

  static NewsCategoryInfo findByKey(String key) {
    return categories.firstWhere(
      (c) => c.key == key,
      orElse: () => categories.last,
    );
  }
}

/// Core News Article Model for GramConnect
class NewsArticle {
  final String id;
  final String headline;
  final Map<String, String>? localizedHeadlines;
  final String summary;
  final Map<String, String>? localizedSummaries;
  final String body;
  final Map<String, String>? localizedBodies;
  final String category; // Maps to NewsCategoryInfo.key
  final String? coverImageUrl;
  final String authorName;
  final Map<String, String>? localizedAuthors;
  final String publisherName;
  final Map<String, String>? localizedPublishers;
  final String? sourceUrl;
  final DateTime publishedAt;
  final DateTime? updatedAt;
  final DateTime? occurrenceDate;
  final NewsPublicationStatus publicationStatus;
  final NewsVerificationStatus verificationStatus;
  final bool isFeatured;
  final List<String> tags;
  final List<String> relatedPlaceIds;

  const NewsArticle({
    required this.id,
    required this.headline,
    this.localizedHeadlines,
    required this.summary,
    this.localizedSummaries,
    required this.body,
    this.localizedBodies,
    required this.category,
    this.coverImageUrl,
    required this.authorName,
    this.localizedAuthors,
    required this.publisherName,
    this.localizedPublishers,
    this.sourceUrl,
    required this.publishedAt,
    this.updatedAt,
    this.occurrenceDate,
    this.publicationStatus = NewsPublicationStatus.published,
    this.verificationStatus = NewsVerificationStatus.verified,
    this.isFeatured = false,
    this.tags = const [],
    this.relatedPlaceIds = const [],
  });

  /// Get localized headline based on language code ('en', 'mr', 'hi')
  String getHeadline(String langCode) {
    if (localizedHeadlines != null && localizedHeadlines!.containsKey(langCode)) {
      final val = localizedHeadlines![langCode];
      if (val != null && val.trim().isNotEmpty) return val;
    }
    return headline;
  }

  /// Get localized summary based on language code
  String getSummary(String langCode) {
    if (localizedSummaries != null && localizedSummaries!.containsKey(langCode)) {
      final val = localizedSummaries![langCode];
      if (val != null && val.trim().isNotEmpty) return val;
    }
    return summary;
  }

  /// Get localized body based on language code
  String getBody(String langCode) {
    if (localizedBodies != null && localizedBodies!.containsKey(langCode)) {
      final val = localizedBodies![langCode];
      if (val != null && val.trim().isNotEmpty) return val;
    }
    return body;
  }

  /// Get localized author name based on language code
  String getAuthor(String langCode) {
    if (localizedAuthors != null && localizedAuthors!.containsKey(langCode)) {
      final val = localizedAuthors![langCode];
      if (val != null && val.trim().isNotEmpty) return val;
    }
    return authorName;
  }

  /// Get localized publisher name based on language code
  String getPublisher(String langCode) {
    if (localizedPublishers != null && localizedPublishers!.containsKey(langCode)) {
      final val = localizedPublishers![langCode];
      if (val != null && val.trim().isNotEmpty) return val;
    }
    return publisherName;
  }

  /// Estimated reading time in minutes (based on average 150 words per minute)
  int get readingTimeMinutes {
    final words = body.split(RegExp(r'\s+')).length;
    final mins = (words / 150).ceil();
    return mins < 1 ? 1 : mins;
  }

  NewsCategoryInfo get categoryInfo => NewsCategoryInfo.findByKey(category);

  NewsArticle copyWith({
    String? id,
    String? headline,
    Map<String, String>? localizedHeadlines,
    String? summary,
    Map<String, String>? localizedSummaries,
    String? body,
    Map<String, String>? localizedBodies,
    String? category,
    String? coverImageUrl,
    String? authorName,
    Map<String, String>? localizedAuthors,
    String? publisherName,
    Map<String, String>? localizedPublishers,
    String? sourceUrl,
    DateTime? publishedAt,
    DateTime? updatedAt,
    DateTime? occurrenceDate,
    NewsPublicationStatus? publicationStatus,
    NewsVerificationStatus? verificationStatus,
    bool? isFeatured,
    List<String>? tags,
    List<String>? relatedPlaceIds,
  }) {
    return NewsArticle(
      id: id ?? this.id,
      headline: headline ?? this.headline,
      localizedHeadlines: localizedHeadlines ?? this.localizedHeadlines,
      summary: summary ?? this.summary,
      localizedSummaries: localizedSummaries ?? this.localizedSummaries,
      body: body ?? this.body,
      localizedBodies: localizedBodies ?? this.localizedBodies,
      category: category ?? this.category,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      authorName: authorName ?? this.authorName,
      localizedAuthors: localizedAuthors ?? this.localizedAuthors,
      publisherName: publisherName ?? this.publisherName,
      localizedPublishers: localizedPublishers ?? this.localizedPublishers,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      publishedAt: publishedAt ?? this.publishedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      occurrenceDate: occurrenceDate ?? this.occurrenceDate,
      publicationStatus: publicationStatus ?? this.publicationStatus,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      isFeatured: isFeatured ?? this.isFeatured,
      tags: tags ?? this.tags,
      relatedPlaceIds: relatedPlaceIds ?? this.relatedPlaceIds,
    );
  }
}

/// Model for user suggested news stories awaiting community moderation
class NewsSuggestion {
  final String id;
  final String headline;
  final String category;
  final String summary;
  final String body;
  final DateTime? occurrenceDate;
  final String? sourceUrl;
  final String? imageUrl;
  final DateTime submittedAt;
  final String? submittedBy;
  final NewsPublicationStatus status;

  const NewsSuggestion({
    required this.id,
    required this.headline,
    required this.category,
    required this.summary,
    required this.body,
    this.occurrenceDate,
    this.sourceUrl,
    this.imageUrl,
    required this.submittedAt,
    this.submittedBy,
    this.status = NewsPublicationStatus.pendingReview,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'headline': headline,
    'category': category,
    'summary': summary,
    'body': body,
    'occurrenceDate': occurrenceDate?.toIso8601String(),
    'sourceUrl': sourceUrl,
    'imageUrl': imageUrl,
    'submittedAt': submittedAt.toIso8601String(),
    'submittedBy': submittedBy,
    'status': status.name,
  };
}

/// Model for reporting inaccurate news information
class NewsReport {
  final String id;
  final String articleId;
  final String issueType;
  final String description;
  final DateTime reportedAt;
  final String? reportedBy;

  const NewsReport({
    required this.id,
    required this.articleId,
    required this.issueType,
    required this.description,
    required this.reportedAt,
    this.reportedBy,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'articleId': articleId,
    'issueType': issueType,
    'description': description,
    'reportedAt': reportedAt.toIso8601String(),
    'reportedBy': reportedBy,
  };
}
