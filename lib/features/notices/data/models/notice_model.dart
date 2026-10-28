import 'package:flutter/material.dart';

/// Data model representing a Village Notice circular.
class NoticeItem {
  final String id;
  final String category; // 'water', 'electricity', 'agriculture', 'emergency', 'government', 'education', 'events', 'general'
  final String titleKey;
  final String summaryKey;
  final String contentKey;
  final String dateKey;
  final String sourceKey;
  final bool isUrgent;
  final IconData icon;
  final Color categoryColor;
  final String? updatedAtKey;
  final String? imageUrl;
  final String? attachmentUrl;

  const NoticeItem({
    required this.id,
    required this.category,
    required this.titleKey,
    required this.summaryKey,
    required this.contentKey,
    required this.dateKey,
    required this.sourceKey,
    required this.icon,
    required this.categoryColor,
    this.isUrgent = false,
    this.updatedAtKey,
    this.imageUrl,
    this.attachmentUrl,
  });

  /// Category lookup matching icon metadata
  static IconData getIconForCategory(String category) {
    switch (category) {
      case 'water':
        return Icons.water_drop_rounded;
      case 'electricity':
        return Icons.electric_bolt_rounded;
      case 'agriculture':
        return Icons.agriculture_rounded;
      case 'emergency':
        return Icons.warning_amber_rounded;
      case 'government':
        return Icons.account_balance_rounded;
      case 'education':
        return Icons.school_rounded;
      case 'events':
        return Icons.festival_rounded;
      default:
        return Icons.campaign_rounded;
    }
  }

  /// Category color mapping
  static Color getColorForCategory(String category) {
    switch (category) {
      case 'emergency':
        return Colors.red;
      case 'water':
        return Colors.blue;
      case 'electricity':
        return Colors.orange[800]!;
      case 'agriculture':
        return Colors.green;
      case 'government':
        return Colors.teal;
      case 'education':
        return Colors.indigo;
      case 'events':
        return Colors.purple;
      default:
        return Colors.grey[700]!;
    }
  }

  /// Predefined static mock notices for GramConnect Notice Board.
  static final List<NoticeItem> mockNotices = [
    NoticeItem(
      id: 'n1',
      category: 'water',
      titleKey: 'n1_title',
      summaryKey: 'n1_summary',
      contentKey: 'n1_desc',
      dateKey: 'Sep 4, 2026',
      sourceKey: 'n1_source',
      isUrgent: true,
      icon: getIconForCategory('water'),
      categoryColor: getColorForCategory('water'),
    ),
    NoticeItem(
      id: 'n2',
      category: 'electricity',
      titleKey: 'n2_title',
      summaryKey: 'n2_summary',
      contentKey: 'n2_desc',
      dateKey: 'Sep 2, 2026',
      sourceKey: 'n2_source',
      isUrgent: false,
      icon: getIconForCategory('electricity'),
      categoryColor: getColorForCategory('electricity'),
    ),
    NoticeItem(
      id: 'n3',
      category: 'agriculture',
      titleKey: 'n3_title',
      summaryKey: 'n3_summary',
      contentKey: 'n3_desc',
      dateKey: 'Aug 30, 2026',
      sourceKey: 'n3_source',
      isUrgent: false,
      icon: getIconForCategory('agriculture'),
      categoryColor: getColorForCategory('agriculture'),
    ),
    NoticeItem(
      id: 'n4',
      category: 'emergency',
      titleKey: 'n4_title',
      summaryKey: 'n4_summary',
      contentKey: 'n4_desc',
      dateKey: 'Sep 5, 2026',
      sourceKey: 'n4_source',
      isUrgent: true,
      icon: getIconForCategory('emergency'),
      categoryColor: getColorForCategory('emergency'),
    ),
    NoticeItem(
      id: 'n5',
      category: 'government',
      titleKey: 'n5_title',
      summaryKey: 'n5_summary',
      contentKey: 'n5_desc',
      dateKey: 'Sep 1, 2026',
      sourceKey: 'n5_source',
      isUrgent: false,
      icon: getIconForCategory('government'),
      categoryColor: getColorForCategory('government'),
    ),
    NoticeItem(
      id: 'n6',
      category: 'education',
      titleKey: 'n6_title',
      summaryKey: 'n6_summary',
      contentKey: 'n6_desc',
      dateKey: 'Aug 28, 2026',
      sourceKey: 'n6_source',
      isUrgent: false,
      icon: getIconForCategory('education'),
      categoryColor: getColorForCategory('education'),
    ),
    NoticeItem(
      id: 'n7',
      category: 'events',
      titleKey: 'n7_title',
      summaryKey: 'n7_summary',
      contentKey: 'n7_desc',
      dateKey: 'Sep 3, 2026',
      sourceKey: 'n7_source',
      isUrgent: false,
      icon: getIconForCategory('events'),
      categoryColor: getColorForCategory('events'),
    ),
  ];
}
