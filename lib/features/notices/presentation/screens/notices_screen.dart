import 'package:flutter/material.dart';
import 'package:gram_connect/core/localization/app_localizations.dart';
import 'package:gram_connect/core/navigation/app_router.dart';
import 'package:gram_connect/core/theme/app_sizes.dart';
import 'package:gram_connect/features/notices/data/models/notice_model.dart';
import 'package:gram_connect/features/home/presentation/screens/home_screen.dart';
import 'package:gram_connect/shared/widgets/state_widgets.dart';

// Import notice repository
import '../../data/repositories/notice_repository.dart';

/// Village Notices Screen for GramConnect V1.
/// Displays a searchable list of notices filterable by category and sortable by date.
/// Priorities important notices at the top. Does not require login.
class NoticesScreen extends StatefulWidget {
  const NoticesScreen({super.key});

  @override
  State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  final NoticeRepository _repository = const MockNoticeRepository();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  List<NoticeItem> _allNotices = [];

  String _searchQuery = '';
  String _selectedCategory = 'all';
  bool _isNewestFirst = true;

  // Available categories list matching NoticeItem keys
  final List<String> _categories = [
    'all',
    'general',
    'government',
    'water',
    'electricity',
    'education',
    'agriculture',
    'events',
    'emergency',
  ];

  @override
  void initState() {
    super.initState();
    _loadNotices();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotices() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final notices = await _repository.getNotices();
      if (mounted) {
        setState(() {
          _allNotices = notices;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  DateTime _parseNoticeDate(String dateStr) {
    try {
      // dateStr is like "Sep 4, 2026"
      final parts = dateStr.replaceAll(',', '').split(' ');
      if (parts.length == 3) {
        final monthStr = parts[0];
        final day = int.parse(parts[1]);
        final year = int.parse(parts[2]);

        int month = 9;
        switch (monthStr.substring(0, 3).toLowerCase()) {
          case 'jan': month = 1; break;
          case 'feb': month = 2; break;
          case 'mar': month = 3; break;
          case 'apr': month = 4; break;
          case 'may': month = 5; break;
          case 'jun': month = 6; break;
          case 'jul': month = 7; break;
          case 'aug': month = 8; break;
          case 'sep': month = 9; break;
          case 'oct': month = 10; break;
          case 'nov': month = 11; break;
          case 'dec': month = 12; break;
        }
        return DateTime(year, month, day);
      }
    } catch (_) {}
    return DateTime(2026, 9, 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: Navigator.canPop(context)
          ? AppBar(
              title: Text(context.translate('village_notices')),
              backgroundColor: isDark ? theme.colorScheme.surface : theme.colorScheme.primary,
              foregroundColor: isDark ? theme.colorScheme.onSurface : theme.colorScheme.onPrimary,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      body: SafeArea(
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: LoadingState());
    }

    if (_hasError) {
      return Center(
        child: ErrorState(
          message: _errorMessage,
          onRetry: _loadNotices,
        ),
      );
    }

    // 1. Filter notices dynamically in real-time
    final filteredNotices = _allNotices.where((notice) {
      // Category Filter
      if (_selectedCategory != 'all' && notice.category != _selectedCategory) {
        return false;
      }
      // Search Query Filter (Title, Summary, Description, Category)
      if (_searchQuery.isNotEmpty) {
        final localizedTitle = context.translate(notice.titleKey).toLowerCase();
        final localizedSummary = context.translate(notice.summaryKey).toLowerCase();
        final localizedDesc = context.translate(notice.contentKey).toLowerCase();
        final cat = notice.category.toLowerCase();
        
        final matchesTitle = localizedTitle.contains(_searchQuery);
        final matchesSummary = localizedSummary.contains(_searchQuery);
        final matchesDesc = localizedDesc.contains(_searchQuery);
        final matchesCat = cat.contains(_searchQuery);

        return matchesTitle || matchesSummary || matchesDesc || matchesCat;
      }
      return true;
    }).toList();

    // 2. Sort notices (Urgent notices go to the top, then date sorting)
    filteredNotices.sort((a, b) {
      if (a.isUrgent && !b.isUrgent) return -1;
      if (!a.isUrgent && b.isUrgent) return 1;

      final dateA = _parseNoticeDate(a.dateKey);
      final dateB = _parseNoticeDate(b.dateKey);

      if (_isNewestFirst) {
        return dateB.compareTo(dateA);
      } else {
        return dateA.compareTo(dateB);
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- 1. Subtitle Banner ---
        Padding(
          padding: const EdgeInsets.only(
            left: AppSizes.space16,
            right: AppSizes.space16,
            top: AppSizes.space16,
            bottom: AppSizes.space4,
          ),
          child: Text(
            context.translate('notices_subtitle'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),

        // --- 2. Search & Sorting Row ---
        Padding(
          padding: const EdgeInsets.only(
            left: AppSizes.space16,
            right: AppSizes.space16,
            top: AppSizes.space8,
            bottom: AppSizes.space8,
          ),
          child: Row(
            children: [
              Expanded(child: SearchField(controller: _searchController)),
              const SizedBox(width: AppSizes.space8),
              IconButton.filledTonal(
                icon: Icon(_isNewestFirst ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded),
                tooltip: _isNewestFirst ? 'Newest First' : 'Oldest First',
                onPressed: () {
                  setState(() {
                    _isNewestFirst = !_isNewestFirst;
                  });
                },
              ),
            ],
          ),
        ),

        // --- 3. Horizontal Category Select Filter ---
        Container(
          height: 48,
          margin: const EdgeInsets.only(bottom: AppSizes.space8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = _selectedCategory == cat;

              return Padding(
                padding: const EdgeInsets.only(right: AppSizes.space8),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(
                    context.translate('cat_$cat'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = cat;
                    });
                  },
                  selectedColor: theme.colorScheme.primaryContainer,
                  checkmarkColor: theme.colorScheme.onPrimaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  ),
                ),
              );
            },
          ),
        ),

        // --- 4. Scrollable List of Notices ---
        Expanded(
          child: filteredNotices.isEmpty
              ? Center(
                  child: Text(
                    context.translate('notices_empty'),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(
                    left: AppSizes.space16,
                    right: AppSizes.space16,
                    bottom: AppSizes.space24,
                  ),
                  itemCount: filteredNotices.length,
                  itemBuilder: (context, index) {
                    final notice = filteredNotices[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.space12),
                      child: _buildNoticeCard(context, notice),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildNoticeCard(BuildContext context, NoticeItem notice) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        side: BorderSide(
          color: notice.isUrgent
              ? Colors.red.withValues(alpha: 0.4)
              : theme.colorScheme.outline.withValues(alpha: 0.1),
          width: notice.isUrgent ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRouter.noticeDetail,
            arguments: {'notice': notice},
          );
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge Category Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSizes.space8),
                        decoration: BoxDecoration(
                          color: notice.categoryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          notice.icon,
                          size: 16,
                          color: notice.categoryColor,
                        ),
                      ),
                      const SizedBox(width: AppSizes.space8),
                      Text(
                        context.translate('cat_${notice.category}').toUpperCase(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: notice.categoryColor,
                          fontSize: 10.0,
                        ),
                      ),
                    ],
                  ),
                  if (notice.isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                      ),
                      child: Text(
                        context.translate('urgent'),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.red[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 9.0,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSizes.space12),

              // Title text
              Text(
                context.translate(notice.titleKey),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: AppSizes.space8),

              // Summary paragraph
              Text(
                context.translate(notice.summaryKey),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 13.0,
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppSizes.space12),
              const Divider(height: 1),
              const SizedBox(height: AppSizes.space8),

              // Source and Date stamp footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${context.translate('source')}: ${context.translate(notice.sourceKey)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                        fontSize: 11.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSizes.space8),
                  Text(
                    notice.dateKey,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      fontSize: 11.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
