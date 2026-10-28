import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../data/models/news_article_model.dart';
import '../../data/repositories/news_repository.dart';
import '../../data/services/news_bookmarks_manager.dart';
import 'news_article_detail_screen.dart';
import 'saved_news_screen.dart';
import 'suggest_news_screen.dart';

/// Village News & Updates Home Screen for GramConnect.
/// Provides Dhawalpuri residents with verified local developments, Gram Panchayat
/// announcements, agricultural updates, and community stories.
class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final _repository = MockNewsRepository();
  final _bookmarksManager = NewsBookmarksManager();

  final _searchController = TextEditingController();
  String _selectedCategory = 'all';
  bool _newestFirst = true;

  List<NewsArticle> _articles = [];
  NewsArticle? _featuredArticle;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _bookmarksManager.init();
    _loadNews();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNews() async {
    setState(() => _isLoading = true);

    final query = _searchController.text.trim();
    final articles = await _repository.getArticles(
      category: _selectedCategory == 'all' ? null : _selectedCategory,
      query: query.isEmpty ? null : query,
      newestFirst: _newestFirst,
    );

    NewsArticle? featured;
    if (query.isEmpty && _selectedCategory == 'all') {
      featured = await _repository.getFeaturedArticle();
    }

    if (mounted) {
      setState(() {
        _articles = articles;
        _featuredArticle = featured;
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLG)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.space16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.space20, vertical: AppSizes.space8),
                  child: Text(
                    context.translate('sort_by'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.arrow_downward_rounded),
                  title: Text(context.translate('sort_newest')),
                  trailing: _newestFirst ? const Icon(Icons.check, color: AppColors.primaryLight) : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    if (!_newestFirst) {
                      setState(() => _newestFirst = true);
                      _loadNews();
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.arrow_upward_rounded),
                  title: Text(context.translate('sort_oldest')),
                  trailing: !_newestFirst ? const Icon(Icons.check, color: AppColors.primaryLight) : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    if (_newestFirst) {
                      setState(() => _newestFirst = false);
                      _loadNews();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final langCode = Localizations.localeOf(context).languageCode;

    // If a featured article is displayed separately, filter it out from the regular list
    final feedArticles = (_featuredArticle != null && _searchController.text.trim().isEmpty && _selectedCategory == 'all')
        ? _articles.where((a) => a.id != _featuredArticle!.id).toList()
        : _articles;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.translate('village_news_title'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Saved Stories Action
          ValueListenableBuilder<List<String>>(
            valueListenable: _bookmarksManager.bookmarksNotifier,
            builder: (ctx, savedIds, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.bookmark_border_rounded),
                    tooltip: context.translate('saved_stories'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => const SavedNewsScreen()),
                      ).then((_) => _loadNews());
                    },
                  ),
                  if (savedIds.isNotEmpty)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.secondaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${savedIds.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // Sort Action
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            tooltip: context.translate('sort_by'),
            onPressed: _showSortMenu,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_rounded),
        label: Text(context.translate('suggest_news')),
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => const SuggestNewsScreen()),
          );
        },
      ),
      body: RefreshIndicator(
        onRefresh: _loadNews,
        child: CustomScrollView(
          slivers: [
            // Subtitle & Search Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSizes.space16, AppSizes.space8, AppSizes.space16, AppSizes.space8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.translate('village_news_subtitle'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space12),

                    // Search Field
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: context.translate('search_news_hint'),
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  _loadNews();
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withValues(alpha: 0.3),
                          ),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      ),
                      onChanged: (_) => _loadNews(),
                    ),
                  ],
                ),
              ),
            ),

            // Category Chips Carousel
            SliverToBoxAdapter(
              child: Container(
                height: 48,
                margin: const EdgeInsets.symmetric(vertical: AppSizes.space8),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
                  scrollDirection: Axis.horizontal,
                  itemCount: NewsCategoryInfo.categories.length + 1,
                  separatorBuilder: (ctx, idx) => const SizedBox(width: AppSizes.space8),
                  itemBuilder: (ctx, idx) {
                    if (idx == 0) {
                      final isSelected = _selectedCategory == 'all';
                      return ChoiceChip(
                        label: Text(context.translate('all')),
                        selected: isSelected,
                        selectedColor: AppColors.primaryLight.withValues(alpha: 0.15),
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primaryLight : theme.colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = 'all');
                            _loadNews();
                          }
                        },
                      );
                    }

                    final cat = NewsCategoryInfo.categories[idx - 1];
                    final isSelected = _selectedCategory == cat.key;

                    return FilterChip(
                      avatar: Icon(cat.icon, size: 16, color: isSelected ? cat.color : theme.colorScheme.onSurfaceVariant),
                      label: Text(context.translate(cat.titleKey)),
                      selected: isSelected,
                      selectedColor: cat.color.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: isSelected ? cat.color : theme.colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? cat.key : 'all';
                        });
                        _loadNews();
                      },
                    );
                  },
                ),
              ),
            ),

            // Loading Indicator
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            // Empty State
            else if (_articles.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.space32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSizes.space16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.newspaper_outlined,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: AppSizes.space16),
                        Text(
                          context.translate('no_news_found'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSizes.space8),
                        Text(
                          context.translate('no_news_desc'),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else ...[
              // Featured Story Card (if available and no filter active)
              if (_featuredArticle != null && _searchController.text.trim().isEmpty && _selectedCategory == 'all')
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16, vertical: AppSizes.space8),
                    child: _buildFeaturedCard(context, _featuredArticle!, langCode),
                  ),
                ),

              // Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSizes.space16, AppSizes.space12, AppSizes.space16, AppSizes.space8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.translate('latest_news_feed'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${feedArticles.length} ${context.translate('items')}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Feed of News Articles
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(AppSizes.space16, 0, AppSizes.space16, 80),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, idx) {
                      final article = feedArticles[idx];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.space12),
                        child: _buildNewsCard(context, article, langCode),
                      );
                    },
                    childCount: feedArticles.length,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Featured Story Card Layout
  Widget _buildFeaturedCard(BuildContext context, NewsArticle article, String langCode) {
    final theme = Theme.of(context);
    final categoryInfo = article.categoryInfo;
    final headline = article.getHeadline(langCode);
    final summary = article.getSummary(langCode);
    final author = article.getAuthor(langCode);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        side: BorderSide(
          color: categoryInfo.color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => NewsArticleDetailScreen(article: article)),
          ).then((_) => setState(() {}));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Featured Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16, vertical: AppSizes.space8),
              decoration: BoxDecoration(
                color: categoryInfo.color.withValues(alpha: 0.12),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLG)),
              ),
              child: Row(
                children: [
                  Icon(Icons.star_rounded, color: categoryInfo.color, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    context.translate('featured_story').toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: categoryInfo.color,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: categoryInfo.color,
                      borderRadius: BorderRadius.circular(AppSizes.radiusXS),
                    ),
                    child: Text(
                      context.translate(categoryInfo.titleKey),
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSizes.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    headline,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space8),
                  Text(
                    summary,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSizes.space16),

                  // Metadata & Actions
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$author • ${_formatDate(article.publishedAt)}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Bookmark Action
                      ValueListenableBuilder<List<String>>(
                        valueListenable: _bookmarksManager.bookmarksNotifier,
                        builder: (ctx, savedIds, _) {
                          final isBookmarked = savedIds.contains(article.id);
                          return IconButton(
                            icon: Icon(
                              isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                              color: isBookmarked ? AppColors.secondaryLight : null,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _bookmarksManager.toggleBookmark(article.id),
                          );
                        },
                      ),
                      const SizedBox(width: AppSizes.space12),
                      Text(
                        context.translate('read_more'),
                        style: TextStyle(
                          color: categoryInfo.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.arrow_forward_ios_rounded, size: 12, color: categoryInfo.color),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Compact News Card Layout for Feed
  Widget _buildNewsCard(BuildContext context, NewsArticle article, String langCode) {
    final theme = Theme.of(context);
    final categoryInfo = article.categoryInfo;
    final headline = article.getHeadline(langCode);
    final summary = article.getSummary(langCode);
    final author = article.getAuthor(langCode);

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.18),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => NewsArticleDetailScreen(article: article)),
          ).then((_) => setState(() {}));
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category, Verification & Bookmark Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: categoryInfo.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(categoryInfo.icon, size: 14, color: categoryInfo.color),
                        const SizedBox(width: 4),
                        Text(
                          context.translate(categoryInfo.titleKey),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: categoryInfo.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Verification Badge
                  if (article.verificationStatus == NewsVerificationStatus.verified)
                    Icon(
                      Icons.verified_rounded,
                      size: 16,
                      color: article.verificationStatus.color,
                    ),

                  const Spacer(),

                  // Bookmark Button
                  ValueListenableBuilder<List<String>>(
                    valueListenable: _bookmarksManager.bookmarksNotifier,
                    builder: (ctx, savedIds, _) {
                      final isBookmarked = savedIds.contains(article.id);
                      return IconButton(
                        icon: Icon(
                          isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          color: isBookmarked ? AppColors.secondaryLight : null,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _bookmarksManager.toggleBookmark(article.id),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.space8),

              // Headline
              Text(
                headline,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSizes.space8),

              // Summary
              Text(
                summary,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSizes.space12),

              // Footer: Author & Date & Read More
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '$author • ${_formatDate(article.publishedAt)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.translate('read_more'),
                        style: TextStyle(
                          color: categoryInfo.color,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.chevron_right_rounded, size: 16, color: categoryInfo.color),
                    ],
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
