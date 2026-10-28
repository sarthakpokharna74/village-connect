import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../data/models/agri_models.dart';
import '../../data/services/agri_bookmarks_manager.dart';
import 'crop_directory_screen.dart';
import 'seasonal_guide_screen.dart';
import 'soil_water_screen.dart';
import 'pest_disease_screen.dart';
import 'agri_weather_screen.dart';
import 'agri_schemes_screen.dart';
import 'market_prices_screen.dart';
import 'equipment_services_screen.dart';
import 'farmer_contacts_screen.dart';
import 'saved_agri_screen.dart';

/// Agriculture Information Home Screen for GramConnect.
/// Provides Dhawalpuri farmers with practical regional crop guidance, seasonal calendars,
/// water stewardship, official scheme directories, and verified contacts.
class AgriScreen extends StatefulWidget {
  const AgriScreen({super.key});

  @override
  State<AgriScreen> createState() => _AgriScreenState();
}

class _AgriScreenState extends State<AgriScreen> {
  final _bookmarksManager = AgriBookmarksManager();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bookmarksManager.init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCategoryTap(BuildContext context, String key) {
    Widget destination;
    switch (key) {
      case 'crop_info':
        destination = const CropDirectoryScreen();
        break;
      case 'seasonal_guide':
        destination = const SeasonalGuideScreen();
        break;
      case 'soil_fertilizers':
      case 'irrigation_water':
        destination = const SoilWaterScreen();
        break;
      case 'pest_disease':
        destination = const PestDiseaseScreen();
        break;
      case 'weather_info':
        destination = const AgriWeatherScreen();
        break;
      case 'agri_schemes':
        destination = const AgriSchemesScreen();
        break;
      case 'market_prices':
        destination = const MarketPricesScreen();
        break;
      case 'equipment_services':
        destination = const EquipmentServicesScreen();
        break;
      case 'farmer_resources_contacts':
        destination = const FarmerContactsScreen();
        break;
      default:
        destination = const CropDirectoryScreen();
    }

    Navigator.push(context, MaterialPageRoute(builder: (ctx) => destination));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = _searchController.text.trim().toLowerCase();

    final filteredCategories = AgriCategoryInfo.categories.where((cat) {
      if (query.isEmpty) return true;
      final title = context.translate(cat.titleKey).toLowerCase();
      final desc = context.translate(cat.descKey).toLowerCase();
      return title.contains(query) || desc.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.translate('agri_home_title'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          ValueListenableBuilder<List<String>>(
            valueListenable: _bookmarksManager.bookmarksNotifier,
            builder: (ctx, savedIds, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.bookmark_border_rounded),
                    tooltip: context.translate('saved_agri_resources'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => const SavedAgriScreen()),
                      );
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
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Intro Subtitle & Search
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.space16, AppSizes.space8, AppSizes.space16, AppSizes.space8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.translate('agri_home_subtitle'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space12),

                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: context.translate('search_agri_hint'),
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                        borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.space8),

            // Two-Column Category Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
              child: filteredCategories.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.space32),
                        child: Text(context.translate('no_agri_found')),
                      ),
                    )
                  : GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: filteredCategories.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.98,
                      ),
                      itemBuilder: (ctx, idx) {
                        final cat = filteredCategories[idx];
                        return _buildCategoryCard(context, cat);
                      },
                    ),
            ),
            const SizedBox(height: AppSizes.space24),

            // Quick Resource Shortcuts
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Direct Farmer Quick Services',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSizes.space12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickButton(
                          context,
                          icon: Icons.support_agent_rounded,
                          title: 'Kisan Call Centre',
                          subtitle: 'Toll-free 1800-180-1551',
                          color: AppColors.primaryLight,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (ctx) => const FarmerContactsScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: AppSizes.space12),
                      Expanded(
                        child: _buildQuickButton(
                          context,
                          icon: Icons.storefront_rounded,
                          title: 'Mandi Rates',
                          subtitle: 'MSAMB Parner',
                          color: AppColors.noticeAmber,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (ctx) => const MarketPricesScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.space20),

            // Educational Platform Disclaimer Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.space16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.primaryLight, size: 20),
                    const SizedBox(width: AppSizes.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.translate('agri_disclaimer_title'),
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.translate('agri_disclaimer_desc'),
                            style: theme.textTheme.bodySmall?.copyWith(
                              height: 1.4,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.space32),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, AgriCategoryInfo cat) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        side: BorderSide(color: cat.color.withValues(alpha: 0.25)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        onTap: () => _onCategoryTap(context, cat.key),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.space12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.space8),
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(cat.icon, color: cat.color, size: 22),
              ),
              const Spacer(),
              Text(
                context.translate(cat.titleKey),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                context.translate(cat.descKey),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 11,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.space12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.space8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppSizes.space8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
