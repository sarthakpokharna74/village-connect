import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../data/models/place_model.dart';
import '../../data/repositories/place_repository.dart';

/// Important Places Home Screen for GramConnect (Blueprint 5).
/// Features:
/// - Header with search and instant clear
/// - Responsive 2-column category grid (10 categories)
/// - Featured Local Reference Landmarks (Durgadevi Temple & Kalu Dam)
/// - Nearby & Useful Places listing with verification badges
/// - Real-time multilingual search & filtering
/// - "Suggest a Place" action
class PlacesScreen extends StatefulWidget {
  const PlacesScreen({super.key});

  @override
  State<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PlaceRepository _repository = MockPlaceRepository();

  String _searchQuery = '';
  String? _selectedCategory; // null or category id
  List<Place> _filteredPlaces = [];
  List<Place> _referenceLandmarks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaces();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPlaces() async {
    setState(() => _isLoading = true);
    final landmarks = await _repository.getReferenceLandmarks();

    if (!mounted) return;
    setState(() {
      _referenceLandmarks = landmarks;
      _isLoading = false;
      _applyFilters();
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query != _searchQuery) {
      setState(() {
        _searchQuery = query;
      });
      _applyFilters();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
    _applyFilters();
  }

  void _selectCategory(String? categoryId) {
    setState(() {
      if (_selectedCategory == categoryId) {
        _selectedCategory = null; // Toggle off if clicked again
      } else {
        _selectedCategory = categoryId;
      }
    });
    _applyFilters();
  }

  Future<void> _applyFilters() async {
    final results = await _repository.searchPlaces(
      _searchQuery,
      category: _selectedCategory,
    );
    if (!mounted) return;
    setState(() {
      _filteredPlaces = results;
    });
  }

  void _navigateToDetail(Place place) {
    Navigator.of(context).pushNamed(
      AppRouter.placeDetail,
      arguments: {'place': place},
    );
  }

  void _navigateToSuggest() {
    Navigator.of(context).pushNamed(AppRouter.placeSuggest).then((_) {
      _loadPlaces();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate('places_title')),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        actions: [
          IconButton(
            tooltip: context.translate('suggest_place'),
            icon: const Icon(Icons.add_location_alt_outlined),
            onPressed: _navigateToSuggest,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadPlaces,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSizes.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Subtitle Header
                      Text(
                        context.translate('places_subtitle'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: AppSizes.space12),

                      // Search Field with clear action
                      _buildSearchField(theme, isDark),

                      const SizedBox(height: AppSizes.space20),

                      // Category Grid (2 columns)
                      _buildSectionHeader(
                        context,
                        title: context.translate('places_categories'),
                        actionText: _selectedCategory != null ? context.translate('cat_places_all') : null,
                        onActionTap: _selectedCategory != null ? () => _selectCategory(null) : null,
                      ),
                      const SizedBox(height: AppSizes.space12),
                      _buildCategoryGrid(theme, isDark),

                      const SizedBox(height: AppSizes.space24),

                      // Featured Local Reference Landmarks
                      // Shows when no search filter is active or if matching
                      if (_searchQuery.isEmpty && _selectedCategory == null) ...[
                        _buildSectionHeader(
                          context,
                          title: context.translate('featured_landmarks'),
                          subtitle: context.translate('featured_landmarks_sub'),
                        ),
                        const SizedBox(height: AppSizes.space12),
                        _buildLandmarksSection(theme, isDark),
                        const SizedBox(height: AppSizes.space24),
                      ],

                      // Explore / Nearby Places Section
                      _buildSectionHeader(
                        context,
                        title: _selectedCategory != null
                            ? '${context.translate('places_showing_category')}: ${context.translate(PlaceCategoryInfo.forCategory(_selectedCategory!).translationKey)}'
                            : context.translate('explore_places'),
                        subtitle: _searchQuery.isNotEmpty
                            ? '${context.translate('search_places')}: "$_searchQuery"'
                            : null,
                        actionText: (_selectedCategory != null || _searchQuery.isNotEmpty)
                            ? context.translate('clear_search')
                            : null,
                        onActionTap: () {
                          _clearSearch();
                          _selectCategory(null);
                        },
                      ),
                      const SizedBox(height: AppSizes.space12),
                      _buildPlacesList(theme, isDark),
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToSuggest,
        icon: const Icon(Icons.add_location_rounded),
        label: Text(context.translate('suggest_place')),
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme, bool isDark) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: context.translate('search_places'),
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryLight),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: _clearSearch,
              )
            : null,
        filled: true,
        fillColor: isDark ? theme.colorScheme.surface : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.space16,
          vertical: AppSizes.space12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          borderSide: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          borderSide: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          borderSide: const BorderSide(
            color: AppColors.primaryLight,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    String? subtitle,
    String? actionText,
    VoidCallback? onActionTap,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (actionText != null && onActionTap != null)
              TextButton(
                onPressed: onActionTap,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  actionText,
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSizes.space4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryGrid(ThemeData theme, bool isDark) {
    final categories = PlaceCategoryInfo.categories;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSizes.space8,
        crossAxisSpacing: AppSizes.space8,
        childAspectRatio: 2.2, // Rectangular card with good touch target
      ),
      itemBuilder: (context, index) {
        final cat = categories[index];
        final isSelected = _selectedCategory == cat.id;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _selectCategory(cat.id),
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.space12,
                vertical: AppSizes.space8,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? cat.color.withValues(alpha: isDark ? 0.25 : 0.12)
                    : (isDark ? theme.colorScheme.surface : Colors.white),
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                border: Border.all(
                  color: isSelected
                      ? cat.color
                      : (isDark ? Colors.white10 : Colors.black12),
                  width: isSelected ? 1.5 : 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: cat.color.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.space8),
                    decoration: BoxDecoration(
                      color: cat.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      cat.icon,
                      size: AppSizes.iconMD,
                      color: cat.color,
                    ),
                  ),
                  const SizedBox(width: AppSizes.space8),
                  Expanded(
                    child: Text(
                      context.translate(cat.translationKey),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? cat.color : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLandmarksSection(ThemeData theme, bool isDark) {
    return Column(
      children: _referenceLandmarks.map((landmark) {
        final placeName = context.translate(landmark.nameKey);

        return Card(
          margin: const EdgeInsets.only(bottom: AppSizes.space12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLG),
            side: BorderSide(
              color: AppColors.secondaryLight.withValues(alpha: 0.3),
            ),
          ),
          elevation: AppSizes.elevationLow,
          child: InkWell(
            onTap: () => _navigateToDetail(landmark),
            borderRadius: BorderRadius.circular(AppSizes.radiusLG),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSizes.space12),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryLight.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                        ),
                        child: const Icon(
                          Icons.account_balance_rounded,
                          color: AppColors.secondaryLight,
                          size: AppSizes.iconLG,
                        ),
                      ),
                      const SizedBox(width: AppSizes.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              placeName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSizes.space4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.space8,
                                vertical: AppSizes.space4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryLight.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                              ),
                              child: Text(
                                context.translate('place_status_reference_landmark'),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondaryLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (landmark.descriptionKey != null) ...[
                    const SizedBox(height: AppSizes.space8),
                    Text(
                      context.translate(landmark.descriptionKey!),
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: AppSizes.space8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: AppSizes.space4),
                      Expanded(
                        child: Text(
                          landmark.addressKey != null
                              ? context.translate(landmark.addressKey!)
                              : 'Dhawalpuri',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlacesList(ThemeData theme, bool isDark) {
    if (_filteredPlaces.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.space20,
          vertical: AppSizes.space32,
        ),
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black12,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off_rounded,
              size: AppSizes.iconXL,
              color: Colors.grey,
            ),
            const SizedBox(height: AppSizes.space12),
            Text(
              context.translate('places_empty_title'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.space8),
            Text(
              _searchQuery.isNotEmpty
                  ? context.translate('places_search_empty_desc')
                  : context.translate('places_empty_desc'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.space16),
            ElevatedButton.icon(
              onPressed: _navigateToSuggest,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.add_location_alt_rounded, size: 18),
              label: Text(context.translate('suggest_place')),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredPlaces.length,
      itemBuilder: (context, index) {
        final place = _filteredPlaces[index];
        return _buildPlaceCard(context, place, theme, isDark);
      },
    );
  }

  Widget _buildPlaceCard(
    BuildContext context,
    Place place,
    ThemeData theme,
    bool isDark,
  ) {
    final categoryInfo = PlaceCategoryInfo.forCategory(place.category);
    final placeName = context.translate(place.nameKey);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.space12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      elevation: AppSizes.elevationLow,
      child: InkWell(
        onTap: () => _navigateToDetail(place),
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.space12),
                    decoration: BoxDecoration(
                      color: categoryInfo.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    ),
                    child: Icon(
                      categoryInfo.icon,
                      size: AppSizes.iconMD,
                      color: categoryInfo.color,
                    ),
                  ),
                  const SizedBox(width: AppSizes.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          placeName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSizes.space4),
                        Row(
                          children: [
                            Text(
                              context.translate(categoryInfo.translationKey),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: categoryInfo.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: AppSizes.space8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.space8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: place.verificationStatus.badgeColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                              ),
                              child: Text(
                                context.translate(place.verificationStatus.statusKey),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: place.verificationStatus.badgeColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (place.descriptionKey != null) ...[
                const SizedBox(height: AppSizes.space8),
                Text(
                  context.translate(place.descriptionKey!),
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: AppSizes.space8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: AppSizes.space4),
                  Expanded(
                    child: Text(
                      place.addressKey != null
                          ? context.translate(place.addressKey!)
                          : 'Dhawalpuri',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _navigateToDetail(place),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      context.translate('view_details'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryLight,
                      ),
                    ),
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
