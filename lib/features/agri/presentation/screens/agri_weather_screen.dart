import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';

/// Weather Resources Screen.
/// Prepared for future API integration; explicitly provides transparent unavailable standby status
/// with verified official links to IMD and Agromet advisory services for Parner taluka.
class AgriWeatherScreen extends StatelessWidget {
  const AgriWeatherScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      try {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched) {
          await launchUrl(uri);
        }
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.translate('cat_agri_weather_info'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Standby Banner
            Container(
              padding: const EdgeInsets.all(AppSizes.space16),
              decoration: BoxDecoration(
                color: AppColors.infoBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                border: Border.all(color: AppColors.infoBlue.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSizes.space8),
                        decoration: BoxDecoration(
                          color: AppColors.infoBlue.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.cloud_sync_rounded, color: AppColors.infoBlue, size: 24),
                      ),
                      const SizedBox(width: AppSizes.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Live Sensor Integration Standby',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.infoBlue,
                              ),
                            ),
                            Text(
                              'Dhawalpuri (Parner, Ahilyanagar)',
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
                    context.translate('weather_standby_notice'),
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.space24),

            Text(
              'Official Agricultural Weather Resources',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.space12),

            // 1. IMD Mausam Agromet Advisory Bulletin
            _buildResourceCard(
              context,
              icon: Icons.wb_sunny_rounded,
              title: 'IMD Agromet Advisory (Mausam)',
              subtitle: 'District Ahilyanagar bi-weekly farmer weather advisories and rainfall forecasts.',
              portalUrl: 'https://mausam.imd.gov.in',
              color: Colors.amber[800]!,
            ),
            const SizedBox(height: AppSizes.space12),

            // 2. Meghdoot App / Krishi Mausam Portal
            _buildResourceCard(
              context,
              icon: Icons.grain_rounded,
              title: 'Krishi Mausam Agromet Portal',
              subtitle: 'ICAR and Ministry of Earth Sciences taluka-level crop advisories.',
              portalUrl: 'https://imdagrimet.gov.in',
              color: AppColors.primaryLight,
            ),
            const SizedBox(height: AppSizes.space12),

            // 3. Mahavedh Weather Network
            _buildResourceCard(
              context,
              icon: Icons.radar_rounded,
              title: 'Mahavedh (Govt of Maharashtra)',
              subtitle: 'Automated weather station (AWS) circle-level rainfall statistics in Parner.',
              portalUrl: 'https://mahavedh.maharashtra.gov.in',
              color: AppColors.infoBlue,
            ),
            const SizedBox(height: AppSizes.space24),

            // Note on Location Permissions
            Container(
              padding: const EdgeInsets.all(AppSizes.space12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_off_rounded, size: 18, color: AppColors.tertiaryLight),
                  const SizedBox(width: AppSizes.space8),
                  Expanded(
                    child: Text(
                      'GramConnect never tracks background GPS without explicit consent. Weather info will configure specifically for Dhawalpuri village.',
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

  Widget _buildResourceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String portalUrl,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSizes.space8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        trailing: const Icon(Icons.open_in_new_rounded, size: 18),
        onTap: () => _launchUrl(portalUrl),
      ),
    );
  }
}
