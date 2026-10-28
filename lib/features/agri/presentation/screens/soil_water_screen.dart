import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';

/// Soil Health, Fertilizers, and Water Management Educational Screen.
class SoilWaterScreen extends StatelessWidget {
  const SoilWaterScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.translate('cat_agri_soil_fertilizers'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Intro Banner
            Container(
              padding: const EdgeInsets.all(AppSizes.space16),
              decoration: BoxDecoration(
                color: AppColors.agriBrown.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                border: Border.all(color: AppColors.agriBrown.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.landscape_rounded, color: AppColors.agriBrown, size: 28),
                  const SizedBox(width: AppSizes.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Soil Health & Water Stewardship',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.agriBrown,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sustainable practices to protect fertility and optimize irrigation water in Dhawalpuri.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.space20),

            // 1. Soil Testing & Soil Health Card
            _buildCard(
              context,
              icon: Icons.science_rounded,
              title: 'Soil Testing & Nutrient Balance',
              content: 'Periodic soil testing (every 2-3 years) identifies electrical conductivity (EC), pH, and organic carbon levels. Apply fertilizers strictly based on soil test recommendations rather than habitual over-application of Urea and DAP, which deteriorates soil biology.',
              color: AppColors.agriBrown,
            ),
            const SizedBox(height: AppSizes.space16),

            // 2. Composting & Soil Organic Carbon
            _buildCard(
              context,
              icon: Icons.compost_rounded,
              title: 'Composting & Organic Matter',
              content: 'Soil organic carbon in dryland zones should ideally remain above 0.75%. Incorporate 5 to 10 tonnes/ha of well-aerated farmyard manure, vermicompost, or green manure crops (Dhaincha/Sunhemp) during summer to enhance soil moisture retention during dry spells.',
              color: AppColors.primaryLight,
            ),
            const SizedBox(height: AppSizes.space16),

            // 3. Drip & Micro-Irrigation Efficiency
            _buildCard(
              context,
              icon: Icons.water_drop_rounded,
              title: 'Micro-Irrigation & Water Efficiency',
              content: 'Flood irrigation loses over 50% of water through seepage and evaporation. Drip irrigation delivers water and water-soluble fertilizers directly to the crop root zone, reducing consumption by 35-50% while suppressing weed growth in onion and horticulture plots.',
              color: AppColors.infoBlue,
            ),
            const SizedBox(height: AppSizes.space16),

            // 4. Farm Ponds & Groundwater Recharge
            _buildCard(
              context,
              icon: Icons.pool_rounded,
              title: 'Farm Ponds (Shet Tale) & Recharge',
              content: 'Store peak monsoon runoff in lined farm ponds for protective life-saving irrigation during Kharif dry spells and early Rabi sowing. Channel excess rooftop and contour runoff into recharge pits near dry open wells to replenish groundwater tables.',
              color: AppColors.tertiaryLight,
            ),
            const SizedBox(height: AppSizes.space20),

            // Official Link Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
              ),
              child: ListTile(
                leading: const Icon(Icons.open_in_new_rounded, color: AppColors.primaryLight),
                title: const Text(
                  'Soil Health Card National Portal',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('View sample collection and testing guidelines (GoI)'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () => _launchUrl('https://soilhealth.dac.gov.in'),
              ),
            ),
            const SizedBox(height: AppSizes.space32),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
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
                Icon(icon, size: 20, color: color),
                const SizedBox(width: AppSizes.space8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
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
