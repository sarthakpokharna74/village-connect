import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../data/models/news_article_model.dart';
import '../../data/services/news_bookmarks_manager.dart';
import '../widgets/report_news_issue_dialog.dart';
import '../../../../core/utils/app_share_service.dart';

/// Full article details screen for GramConnect Village News & Updates.
/// Displays verified reporting, author attribution, clear paragraph typography,
/// safe external source verification, and reader actions.
class NewsArticleDetailScreen extends StatefulWidget {
  final NewsArticle article;

  const NewsArticleDetailScreen({super.key, required this.article});

  @override
  State<NewsArticleDetailScreen> createState() => _NewsArticleDetailScreenState();
}

class _NewsArticleDetailScreenState extends State<NewsArticleDetailScreen> {
  final _bookmarksManager = NewsBookmarksManager();

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  Future<void> _handleShare(BuildContext context, String langCode) async {
    final article = widget.article;
    final headline = article.getHeadline(langCode);
    final summary = article.getSummary(langCode);
    final pubDate = _formatDate(article.publishedAt);
    final author = article.getAuthor(langCode);

    final sb = StringBuffer();
    sb.writeln('📰 $headline');
    sb.writeln();
    sb.writeln(summary);
    sb.writeln();
    sb.writeln('📍 Dhawalpuri (ढवळपुरी) | GramConnect');
    sb.writeln('📅 $pubDate | ✍️ $author');

    if (article.sourceUrl != null && article.sourceUrl!.trim().isNotEmpty) {
      sb.writeln('🔗 Source: ${article.sourceUrl}');
    }

    await AppShareService.share(
      context: context,
      text: sb.toString(),
      subject: headline,
      successMessageKey: 'share_news_copied',
    );
  }

  Future<void> _handleOpenSource(BuildContext context, String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid source link')),
      );
      return;
    }

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open external link: $urlString')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching source: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final langCode = Localizations.localeOf(context).languageCode;
    final article = widget.article;
    final categoryInfo = article.categoryInfo;

    final localizedHeadline = article.getHeadline(langCode);
    final localizedSummary = article.getSummary(langCode);
    final localizedBody = article.getBody(langCode);
    final localizedAuthor = article.getAuthor(langCode);
    final localizedPublisher = article.getPublisher(langCode);

    final paragraphs = localizedBody.split('\n\n').where((p) => p.trim().isNotEmpty).toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          context.translate(categoryInfo.titleKey),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Bookmark Toggle
          ValueListenableBuilder<List<String>>(
            valueListenable: _bookmarksManager.bookmarksNotifier,
            builder: (ctx, savedIds, _) {
              final isBookmarked = savedIds.contains(article.id);
              return IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: isBookmarked ? AppColors.secondaryLight : null,
                ),
                tooltip: context.translate(isBookmarked ? 'news_unbookmarked' : 'news_bookmarked'),
                onPressed: () async {
                  final added = await _bookmarksManager.toggleBookmark(article.id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        context.translate(added ? 'news_bookmarked' : 'news_unbookmarked'),
                      ),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              );
            },
          ),
          // Share Action
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share Article',
            onPressed: () => _handleShare(context, langCode),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Category Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.space16,
                vertical: AppSizes.space12,
              ),
              color: categoryInfo.color.withValues(alpha: 0.08),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.space8),
                    decoration: BoxDecoration(
                      color: categoryInfo.color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      categoryInfo.icon,
                      color: categoryInfo.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSizes.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.translate(categoryInfo.titleKey),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: categoryInfo.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          context.translate(categoryInfo.descKey),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Verification Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: article.verificationStatus.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                      border: Border.all(
                        color: article.verificationStatus.color.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          article.verificationStatus.icon,
                          size: 14,
                          color: article.verificationStatus.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          context.translate(article.verificationStatus.translationKey),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: article.verificationStatus.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
                  // Headline
                  Text(
                    localizedHeadline,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space12),

                  // Metadata Row: Author, Date, Read Time
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person_outline_rounded, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            localizedAuthor,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(article.publishedAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${article.readingTimeMinutes} ${context.translate('read_time')}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.space16),

                  // Summary Card / Lead Paragraph
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.space16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      border: Border(
                        left: BorderSide(
                          color: categoryInfo.color,
                          width: 4,
                        ),
                      ),
                    ),
                    child: Text(
                      localizedSummary,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.space20),

                  // Publisher & Source Attribution
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.space12,
                      vertical: AppSizes.space8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariantLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.source_rounded, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${context.translate('publisher_label')}: $localizedPublisher',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (article.updatedAt != null)
                          Text(
                            '${context.translate('updated_on')}: ${_formatDate(article.updatedAt!)}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.space24),

                  // Article Body Paragraphs
                  ...paragraphs.map((paragraph) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.space16),
                      child: Text(
                        paragraph,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 16.5,
                          height: 1.65,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.95),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: AppSizes.space16),

                  // External Source Link (if provided)
                  if (article.sourceUrl != null && article.sourceUrl!.trim().isNotEmpty) ...[
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                        side: BorderSide(
                          color: theme.colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(AppSizes.space8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.public_rounded,
                            color: AppColors.primaryLight,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          context.translate('source_link_label'),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          article.sourceUrl!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.primaryLight,
                            decoration: TextDecoration.underline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.open_in_new_rounded, size: 20),
                        onTap: () => _handleOpenSource(context, article.sourceUrl!),
                      ),
                    ),
                    const SizedBox(height: AppSizes.space20),
                  ],

                  // Tags
                  if (article.tags.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: article.tags.map((tag) {
                        return Chip(
                          label: Text('#$tag'),
                          labelStyle: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSizes.space24),
                  ],

                  // Community Platform Disclaimer Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.space16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariantLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.primaryLight,
                          size: 20,
                        ),
                        const SizedBox(width: AppSizes.space12),
                        Expanded(
                          child: Text(
                            context.translate('news_disclaimer'),
                            style: theme.textTheme.bodySmall?.copyWith(
                              height: 1.45,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.space24),

                  // Actions Row: Report Incorrect Info & Share
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.flag_outlined, size: 18),
                          label: Text(context.translate('news_report_issue')),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.errorLight,
                            side: BorderSide(
                              color: AppColors.errorLight.withValues(alpha: 0.5),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                            ),
                          ),
                          onPressed: () => ReportNewsIssueDialog.show(context, article),
                        ),
                      ),
                      const SizedBox(width: AppSizes.space12),
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.share_rounded, size: 18),
                          label: const Text('Share Article'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryLight,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                            ),
                          ),
                          onPressed: () => _handleShare(context, langCode),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.space32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
