import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../data/models/agri_models.dart';
import '../../data/repositories/agri_repository.dart';
import '../../data/services/agri_bookmarks_manager.dart';
import 'crop_detail_screen.dart';

/// Searchable regional crop directory for Dhawalpuri.
class CropDirectoryScreen extends StatefulWidget {
  const CropDirectoryScreen({super.key});

  @override
  State<CropDirectoryScreen> createState() => _CropDirectoryScreenState();
}

class _CropDirectoryScreenState extends State<CropDirectoryScreen> {
  final _repository = MockAgriRepository();
  final _bookmarksManager = AgriBookmarksManager();
  final _searchController = TextEditingController();

  String _selectedSeason = 'all';
  List<CropItem> _crops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _bookmarksManager.init();
    _loadCrops();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCrops() async {
    setState(() => _isLoading = true);
    final crops = await _repository.getCrops(
      query: _searchController.text.trim(),
      season: _selectedSeason == 'all' ? null : _selectedSeason,
    );
    if (mounted) {
      setState(() {
        _crops = crops;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.translate('cat_agri_crop_info'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.space16, AppSizes.space8, AppSizes.space16, AppSizes.space8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: context.translate('search_agri_hint'),
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          _loadCrops();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
              onChanged: (_) => _loadCrops(),
            ),
          ),

          // Season Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16, vertical: AppSizes.space4),
            child: Row(
              children: [
                _buildFilterChip('all', context.translate('all')),
                const SizedBox(width: AppSizes.space8),
                _buildFilterChip('season_kharif', context.translate('season_kharif')),
                const SizedBox(width: AppSizes.space8),
                _buildFilterChip('season_rabi', context.translate('season_rabi')),
                const SizedBox(width: AppSizes.space8),
                _buildFilterChip('season_summer', context.translate('season_summer')),
                const SizedBox(width: AppSizes.space8),
                _buildFilterChip('season_year_round', context.translate('season_year_round')),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.space8),

          // List of Crops
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _crops.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.space32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.grass_rounded,
                                size: 48,
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: AppSizes.space16),
                              Text(
                                context.translate('no_agri_found'),
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: AppSizes.space8),
                              Text(
                                context.translate('no_agri_desc'),
                                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppSizes.space16),
                        itemCount: _crops.length,
                        separatorBuilder: (ctx, idx) => const SizedBox(height: AppSizes.space12),
                        itemBuilder: (ctx, idx) {
                          final crop = _crops[idx];
                          return Card(
                            elevation: 0.5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                              side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (ctx) => CropDetailScreen(crop: crop)),
                                ).then((_) => setState(() {}));
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(AppSizes.space16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryLight.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                                          ),
                                          child: Text(
                                            context.translate(crop.seasonKey),
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: AppColors.primaryLight,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        ValueListenableBuilder<List<String>>(
                                          valueListenable: _bookmarksManager.bookmarksNotifier,
                                          builder: (ctx, savedIds, _) {
                                            final isBookmarked = savedIds.contains(crop.id);
                                            return IconButton(
                                              icon: Icon(
                                                isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                                color: isBookmarked ? AppColors.secondaryLight : null,
                                                size: 20,
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              onPressed: () => _bookmarksManager.toggleBookmark(crop.id),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSizes.space8),
                                    Text(
                                      context.translate(crop.nameKey),
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: AppSizes.space8),
                                    Text(
                                      context.translate(crop.descKey),
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                        height: 1.4,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: AppSizes.space12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          crop.sourceName,
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              context.translate('read_more'),
                                              style: const TextStyle(
                                                color: AppColors.primaryLight,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(width: 2),
                                            const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primaryLight),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedSeason == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryLight.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryLight : Theme.of(context).colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedSeason = key);
          _loadCrops();
        }
      },
    );
  }
}
