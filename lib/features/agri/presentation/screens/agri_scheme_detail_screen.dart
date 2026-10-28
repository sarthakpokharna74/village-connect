import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../data/models/agri_models.dart';
import '../../data/services/agri_bookmarks_manager.dart';

/// Detailed view for a Government Agricultural Scheme.
class AgriSchemeDetailScreen extends StatelessWidget {
  final AgriScheme scheme;

  const AgriSchemeDetailScreen({super.key, required this.scheme});

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri == null) return;
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
        SnackBar(content: Text('Error launching portal: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookmarksManager = AgriBookmarksManager();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          scheme.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          ValueListenableBuilder<List<String>>(
            valueListenable: bookmarksManager.bookmarksNotifier,
            builder: (ctx, savedIds, _) {
              final isBookmarked = savedIds.contains(scheme.id);
              return IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: isBookmarked ? AppColors.secondaryLight : null,
                ),
                tooltip: context.translate(isBookmarked ? 'agri_unbookmarked' : 'agri_bookmarked'),
                onPressed: () => bookmarksManager.toggleBookmark(scheme.id),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Scheme Header Card
            Container(
              padding: const EdgeInsets.all(AppSizes.space16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance_rounded, color: AppColors.primaryLight, size: 24),
                      const SizedBox(width: AppSizes.space8),
                      Expanded(
                        child: Text(
                          scheme.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Department: ${scheme.department}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.space20),

            // Purpose
            _buildSection(
              context,
              title: 'Purpose & Benefits',
              content: scheme.purpose,
              icon: Icons.info_outline_rounded,
              color: AppColors.infoBlue,
            ),
            const SizedBox(height: AppSizes.space16),

            // Eligibility Summary
            _buildSection(
              context,
              title: context.translate('eligibility_criteria'),
              content: scheme.eligibilitySummary,
              icon: Icons.how_to_reg_rounded,
              color: AppColors.primaryLight,
            ),
            const SizedBox(height: AppSizes.space16),

            // Required Documents
            Card(
              elevation: 0.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.description_rounded, size: 18, color: AppColors.noticeAmber),
                        const SizedBox(width: AppSizes.space8),
                        Text(
                          context.translate('required_documents'),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.noticeAmber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.space12),
                    ...scheme.requiredDocuments.map((doc) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.primaryLight),
                            const SizedBox(width: AppSizes.space8),
                            Expanded(child: Text(doc, style: theme.textTheme.bodyMedium)),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.space16),

            // Application Process
            _buildSection(
              context,
              title: context.translate('application_process'),
              content: scheme.applicationProcess,
              icon: Icons.touch_app_rounded,
              color: AppColors.eventPurple,
            ),
            const SizedBox(height: AppSizes.space20),

            // Official Portal Button
            SizedBox(
              width: double.infinity,
              height: AppSizes.btnHeightLarge,
              child: FilledButton.icon(
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text(
                  context.translate('view_official_portal'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  ),
                ),
                onPressed: () => _launchUrl(context, scheme.officialPortalUrl),
              ),
            ),
            const SizedBox(height: AppSizes.space16),

            // Source Attribution
            Text(
              '${context.translate('official_source_label')}: ${scheme.sourceName} • Verified: ${scheme.lastVerifiedDate}',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.space16),

            // Portal Disclaimer
            Container(
              padding: const EdgeInsets.all(AppSizes.space12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 18, color: AppColors.tertiaryLight),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'GramConnect is an informational platform and does not process or approve scheme applications.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.space32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: AppSizes.space8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.space8),
            Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}
