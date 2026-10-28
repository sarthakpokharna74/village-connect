import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../data/models/agri_models.dart';
import '../../data/services/agri_bookmarks_manager.dart';

/// Detailed Crop Information Page in GramConnect Agriculture Module.
/// Displays regional cultivation guidance, soil/water needs, pests, and verified sources.
class CropDetailScreen extends StatelessWidget {
  final CropItem crop;

  const CropDetailScreen({super.key, required this.crop});

  Future<void> _launchSourceUrl(BuildContext context, String urlString) async {
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
        SnackBar(content: Text('Error launching source: $e')),
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
          context.translate(crop.nameKey),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          ValueListenableBuilder<List<String>>(
            valueListenable: bookmarksManager.bookmarksNotifier,
            builder: (ctx, savedIds, _) {
              final isBookmarked = savedIds.contains(crop.id);
              return IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: isBookmarked ? AppColors.secondaryLight : null,
                ),
                tooltip: context.translate(isBookmarked ? 'agri_unbookmarked' : 'agri_bookmarked'),
                onPressed: () async {
                  final added = await bookmarksManager.toggleBookmark(crop.id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.translate(added ? 'agri_bookmarked' : 'agri_unbookmarked')),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
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
            // Top Header Card
            Container(
              width: double.infinity,
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
                      Container(
                        padding: const EdgeInsets.all(AppSizes.space8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.grass_rounded, color: AppColors.primaryLight, size: 24),
                      ),
                      const SizedBox(width: AppSizes.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.translate(crop.nameKey),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryLight,
                              ),
                            ),
                            Text(
                              '${context.translate('season_kharif')}: ${context.translate(crop.seasonKey)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.space12),
                  Text(
                    context.translate(crop.descKey),
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.space20),

            // 1. Soil Requirements
            _buildSection(
              context,
              icon: Icons.landscape_rounded,
              title: context.translate('soil_requirements'),
              content: crop.soilRequirements,
              color: AppColors.agriBrown,
            ),
            const SizedBox(height: AppSizes.space16),

            // 2. Water Requirements
            _buildSection(
              context,
              icon: Icons.water_drop_rounded,
              title: context.translate('water_requirements'),
              content: crop.waterRequirements,
              color: AppColors.infoBlue,
            ),
            const SizedBox(height: AppSizes.space16),

            // 3. Cultivation Guidance
            _buildSection(
              context,
              icon: Icons.agriculture_rounded,
              title: context.translate('cultivation_guidance'),
              content: crop.cultivationGuidance,
              color: AppColors.primaryLight,
            ),
            const SizedBox(height: AppSizes.space16),

            // 4. Common Pests & Diseases
            _buildSection(
              context,
              icon: Icons.pest_control_rounded,
              title: context.translate('common_pests'),
              content: crop.commonPests,
              color: AppColors.emergencyRed,
            ),
            const SizedBox(height: AppSizes.space16),

            // 5. Harvesting Guidance
            _buildSection(
              context,
              icon: Icons.inventory_2_rounded,
              title: context.translate('harvesting_guidance'),
              content: crop.harvestingGuidance,
              color: AppColors.noticeAmber,
            ),
            const SizedBox(height: AppSizes.space20),

            // Source Attribution & Link Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
              ),
              child: ListTile(
                leading: const Icon(Icons.verified_outlined, color: AppColors.primaryLight),
                title: Text(
                  '${context.translate('official_source_label')}: ${crop.sourceName}',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${context.translate('last_verified_date')}: ${crop.lastVerifiedDate}',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                trailing: const Icon(Icons.open_in_new_rounded, size: 20),
                onTap: () => _launchSourceUrl(context, crop.sourceUrl),
              ),
            ),
            const SizedBox(height: AppSizes.space20),

            // Educational Disclaimer
            Container(
              padding: const EdgeInsets.all(AppSizes.space12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primaryLight),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.translate('agri_disclaimer_desc'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
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
    required IconData icon,
    required String title,
    required String content,
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
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
