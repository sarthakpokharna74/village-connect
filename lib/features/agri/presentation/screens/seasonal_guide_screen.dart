import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../data/models/agri_models.dart';
import '../../data/repositories/agri_repository.dart';

/// Seasonal Farming Guide Screen for Kharif, Rabi, Summer, and Year-Round practices in Dhawalpuri.
class SeasonalGuideScreen extends StatefulWidget {
  const SeasonalGuideScreen({super.key});

  @override
  State<SeasonalGuideScreen> createState() => _SeasonalGuideScreenState();
}

class _SeasonalGuideScreenState extends State<SeasonalGuideScreen> with SingleTickerProviderStateMixin {
  final _repository = MockAgriRepository();
  late TabController _tabController;
  List<SeasonalGuideItem> _guides = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadGuides();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadGuides() async {
    final guides = await _repository.getSeasonalGuides();
    if (mounted) {
      setState(() {
        _guides = guides;
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.translate('cat_agri_seasonal_guide'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primaryLight,
          indicatorColor: AppColors.primaryLight,
          tabs: [
            Tab(text: context.translate('season_kharif')),
            Tab(text: context.translate('season_rabi')),
            Tab(text: context.translate('season_summer')),
            Tab(text: context.translate('season_year_round')),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildGuideView('season_kharif'),
                _buildGuideView('season_rabi'),
                _buildGuideView('season_summer'),
                _buildGuideView('season_year_round'),
              ],
            ),
    );
  }

  Widget _buildGuideView(String seasonKey) {
    final theme = Theme.of(context);
    final guide = _guides.firstWhere(
      (g) => g.seasonKey == seasonKey,
      orElse: () => _guides.first,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Card
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
                    const Icon(Icons.calendar_today_rounded, color: AppColors.primaryLight, size: 20),
                    const SizedBox(width: AppSizes.space8),
                    Text(
                      guide.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.space8),
                Text(
                  guide.overview,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.space20),

          // Suitable Activities
          Text(
            'Recommended Seasonal Field Work',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.space8),
          Card(
            elevation: 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.space16),
              child: Column(
                children: guide.suitableActivities.map((act) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.space8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, size: 18, color: AppColors.primaryLight),
                        const SizedBox(width: AppSizes.space8),
                        Expanded(
                          child: Text(
                            act,
                            style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.space16),

          // Soil Preparation Guidance
          _buildDetailCard(
            title: context.translate('soil_requirements'),
            content: guide.soilPreparation,
            icon: Icons.landscape_rounded,
            color: AppColors.agriBrown,
          ),
          const SizedBox(height: AppSizes.space16),

          // Water Management Considerations
          _buildDetailCard(
            title: context.translate('water_requirements'),
            content: guide.waterManagement,
            icon: Icons.water_drop_rounded,
            color: AppColors.infoBlue,
          ),
          const SizedBox(height: AppSizes.space16),

          // Seasonal Advisories
          _buildDetailCard(
            title: 'Important Agricultural Advisory',
            content: guide.advisories,
            icon: Icons.lightbulb_outline_rounded,
            color: AppColors.noticeAmber,
          ),
          const SizedBox(height: AppSizes.space20),

          // Official Resource Link Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
            ),
            child: ListTile(
              leading: const Icon(Icons.verified_outlined, color: AppColors.primaryLight),
              title: Text(
                '${context.translate('official_source_label')}: ${guide.sourceName}',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${context.translate('last_verified_date')}: ${guide.lastVerifiedDate}',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              trailing: const Icon(Icons.open_in_new_rounded, size: 20),
              onTap: () => _launchUrl(guide.officialResourceUrl),
            ),
          ),
          const SizedBox(height: AppSizes.space32),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
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
