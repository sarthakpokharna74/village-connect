import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../data/models/news_article_model.dart';
import '../../data/repositories/news_repository.dart';
import '../../data/services/news_bookmarks_manager.dart';
import 'news_article_detail_screen.dart';

/// Screen displaying all articles bookmarked by the user for offline reading.
/// Persisted locally across app launches without requiring login.
class SavedNewsScreen extends StatefulWidget {
  const SavedNewsScreen({super.key});

  @override
  State<SavedNewsScreen> createState() => _SavedNewsScreenState();
}

class _SavedNewsScreenState extends State<SavedNewsScreen> {
  final _repository = MockNewsRepository();
  final _bookmarksManager = NewsBookmarksManager();

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final langCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.translate('saved_stories'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ValueListenableBuilder<List<String>>(
        valueListenable: _bookmarksManager.bookmarksNotifier,
        builder: (ctx, savedIds, _) {
          if (savedIds.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.space32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSizes.space20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.bookmark_border_rounded,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: AppSizes.space20),
                    Text(
                      context.translate('no_saved_news'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.space8),
                    Text(
                      context.translate('no_saved_news_desc'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return FutureBuilder<List<NewsArticle>>(
            future: _repository.getSavedArticles(savedIds),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final articles = snapshot.data ?? [];

              if (articles.isEmpty) {
                return Center(
                  child: Text(
                    context.translate('no_saved_news'),
                    style: theme.textTheme.bodyMedium,
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(AppSizes.space16),
                itemCount: articles.length,
                separatorBuilder: (ctx, idx) => const SizedBox(height: AppSizes.space12),
                itemBuilder: (ctx, idx) {
                  final article = articles[idx];
                  final categoryInfo = article.categoryInfo;
                  final headline = article.getHeadline(langCode);
                  final summary = article.getSummary(langCode);
                  final author = article.getAuthor(langCode);

                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      side: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.15),
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => NewsArticleDetailScreen(article: article),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.space16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category & Remove Action Row
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: categoryInfo.color.withValues(alpha: 0.12),
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
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(
                                    Icons.bookmark_remove_rounded,
                                    color: AppColors.secondaryLight,
                                    size: 22,
                                  ),
                                  tooltip: context.translate('news_unbookmarked'),
                                  onPressed: () async {
                                    await _bookmarksManager.removeBookmark(article.id);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(context.translate('news_unbookmarked')),
                                        duration: const Duration(seconds: 2),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
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

                            // Metadata: Author & Date
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  author,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _formatDate(article.publishedAt),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
