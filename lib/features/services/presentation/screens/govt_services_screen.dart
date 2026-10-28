import 'package:flutter/material.dart';
import 'package:gram_connect/core/localization/app_localizations.dart';
import 'package:gram_connect/core/theme/app_sizes.dart';
import 'package:gram_connect/core/utils/official_link_launcher.dart';
import 'package:gram_connect/features/home/presentation/screens/home_screen.dart';
import 'package:gram_connect/features/services/data/models/gov_service_model.dart';
import 'package:gram_connect/features/services/data/repositories/gov_services_repository.dart';
import 'package:gram_connect/features/services/data/services/service_favorites_manager.dart';
import 'package:gram_connect/features/services/presentation/screens/gov_service_detail_screen.dart';

/// Government Services Directory Screen for GramConnect (Blueprint 7).
/// Implements responsive 2-column categories grid, search, category filtering,
/// service cards with safe official links, local favorites, and community disclaimers.
class GovtServicesScreen extends StatefulWidget {
  final GovernmentServicesRepository repository;

  const GovtServicesScreen({
    super.key,
    this.repository = const MockGovernmentServicesRepository(),
  });

  @override
  State<GovtServicesScreen> createState() => _GovtServicesScreenState();
}

class _GovtServicesScreenState extends State<GovtServicesScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ServiceFavoritesManager _favoritesManager = ServiceFavoritesManager();

  late TabController _tabController;
  String _searchQuery = '';
  String _selectedCategory = 'all';

  List<GovernmentService> _allServices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    _favoritesManager.addListener(_onFavoritesChanged);
    _favoritesManager.loadFavorites();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });

    _loadServices();
  }

  Future<void> _loadServices() async {
    final services = await widget.repository.getAllServices();
    if (mounted) {
      setState(() {
        _allServices = services;
        _isLoading = false;
      });
    }
  }

  void _onFavoritesChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _favoritesManager.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _selectCategoryAndSwitchToServices(String categoryId) {
    setState(() {
      _selectedCategory = categoryId;
      _tabController.animateTo(1); // Switch to All Services tab
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = 'all';
      _searchController.clear();
      _searchQuery = '';
    });
  }

  List<GovernmentService> _filterServices({bool onlyFavorites = false}) {
    return _allServices.where((service) {
      if (onlyFavorites && !_favoritesManager.isFavorite(service.id)) {
        return false;
      }

      if (_selectedCategory != 'all' && service.category != _selectedCategory) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final name = context.translate(service.nameKey).toLowerCase();
        final desc = context.translate(service.shortDescriptionKey).toLowerCase();
        final dept = context.translate(service.departmentKey).toLowerCase();
        final elig = context.translate(service.eligibilityKey).toLowerCase();
        final cat = context.translate('cat_gov_${service.category}').toLowerCase();

        final matches = name.contains(q) ||
            desc.contains(q) ||
            dept.contains(q) ||
            elig.contains(q) ||
            cat.contains(q);

        if (!matches) return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.translate('govt_services'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? theme.colorScheme.onSurface : theme.colorScheme.onPrimary,
              ),
            ),
            Text(
              context.translate('govt_services_subtitle'),
              style: theme.textTheme.labelSmall?.copyWith(
                color: isDark
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onPrimary.withValues(alpha: 0.85),
                fontSize: 10.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        backgroundColor: isDark ? theme.colorScheme.surface : theme.colorScheme.primary,
        foregroundColor: isDark ? theme.colorScheme.onSurface : theme.colorScheme.onPrimary,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: isDark ? theme.colorScheme.primary : theme.colorScheme.onPrimary,
          labelColor: isDark ? theme.colorScheme.primary : theme.colorScheme.onPrimary,
          unselectedLabelColor: isDark
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.onPrimary.withValues(alpha: 0.7),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(
              icon: const Icon(Icons.grid_view_rounded, size: 18),
              text: context.translate('gov_tab_categories'),
            ),
            Tab(
              icon: const Icon(Icons.list_alt_rounded, size: 18),
              text: context.translate('gov_tab_all_services'),
            ),
            Tab(
              icon: Badge(
                isLabelVisible: _favoritesManager.favoriteIds.isNotEmpty,
                label: Text('${_favoritesManager.favoriteIds.length}'),
                child: const Icon(Icons.bookmark_rounded, size: 18),
              ),
              text: context.translate('gov_tab_saved'),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Categories Grid
                  _buildCategoriesTab(context),

                  // Tab 2: All Services (with search & filter chips)
                  _buildServicesListTab(context, onlyFavorites: false),

                  // Tab 3: Saved Favorites
                  _buildServicesListTab(context, onlyFavorites: true),
                ],
              ),
      ),
    );
  }

  /// Tab 1: Responsive 2-Column Grid of the 10 official categories.
  Widget _buildCategoriesTab(BuildContext context) {
    final theme = Theme.of(context);
    final categories = ServiceCategoryInfo.allCategories;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Community Disclaimer Banner
          _buildCommunityNoticeBanner(context),
          const SizedBox(height: AppSizes.space16),

          // Header title
          Row(
            children: [
              Text(
                context.translate('gov_tab_categories'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedCategory = 'all';
                    _tabController.animateTo(1);
                  });
                },
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: Text(context.translate('view_all')),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.space8),

          // 2-Column Responsive Category Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: AppSizes.space12,
                  mainAxisSpacing: AppSizes.space12,
                  childAspectRatio: 0.86,
                ),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final serviceCount =
                      _allServices.where((s) => s.category == cat.id).length;

                  return _buildCategoryCard(context, cat, serviceCount);
                },
              );
            },
          ),
          const SizedBox(height: AppSizes.space24),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    ServiceCategoryInfo category,
    int serviceCount,
  ) {
    final theme = Theme.of(context);
    final catName = context.translate(category.nameKey);
    final catDesc = context.translate(category.descriptionKey);

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        onTap: () => _selectCategoryAndSwitchToServices(category.id),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.space12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Icon + Service Count
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.space8),
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      category.icon,
                      color: category.color,
                      size: AppSizes.iconMD,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    ),
                    child: Text(
                      '$serviceCount',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Localized Name
              Text(
                catName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Short Description
              Text(
                catDesc,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 11,
                  height: 1.25,
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

  /// Tab 2 & 3: Services list with search and category filter chips.
  Widget _buildServicesListTab(BuildContext context, {required bool onlyFavorites}) {
    final theme = Theme.of(context);
    final services = _filterServices(onlyFavorites: onlyFavorites);
    final categories = ServiceCategoryInfo.allCategories;

    return Column(
      children: [
        // 1. Search Bar
        Padding(
          padding: const EdgeInsets.only(
            left: AppSizes.space16,
            right: AppSizes.space16,
            top: AppSizes.space12,
            bottom: AppSizes.space8,
          ),
          child: SearchField(
            controller: _searchController,
            hintText: context.translate('search_gov_services'),
          ),
        ),

        // 2. Horizontal Categories Filter Bar (All + 10 Categories)
        Container(
          height: 44,
          margin: const EdgeInsets.only(bottom: AppSizes.space4),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
            itemCount: categories.length + 1,
            itemBuilder: (context, index) {
              final isAll = index == 0;
              final catId = isAll ? 'all' : categories[index - 1].id;
              final catName = isAll
                  ? context.translate('cat_gov_all')
                  : context.translate(categories[index - 1].nameKey);
              final isSelected = _selectedCategory == catId;

              return Padding(
                padding: const EdgeInsets.only(right: AppSizes.space8),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(
                    catName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = catId;
                    });
                  },
                  selectedColor: theme.colorScheme.primaryContainer,
                  checkmarkColor: theme.colorScheme.onPrimaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  ),
                ),
              );
            },
          ),
        ),

        // 3. Active filter indicator (if filtered)
        if (_selectedCategory != 'all' || _searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.space16,
              vertical: AppSizes.space4,
            ),
            child: Row(
              children: [
                Text(
                  '${services.length} ${context.translate('services_found_count')}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.close, size: 14),
                  label: Text(
                    context.translate('gov_clear_filter'),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

        // 4. Services List
        Expanded(
          child: services.isEmpty
              ? _buildEmptyState(context, onlyFavorites: onlyFavorites)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.space16,
                    vertical: AppSizes.space8,
                  ),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.space16),
                      child: _buildServiceCard(context, services[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(BuildContext context, GovernmentService service) {
    final theme = Theme.of(context);
    final isFav = _favoritesManager.isFavorite(service.id);
    final categoryColor = service.categoryColor;
    final hasWebsite =
        service.officialWebsiteUrl != null && service.officialWebsiteUrl!.isNotEmpty;

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GovServiceDetailScreen(service: service),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row: Category Badge + Scheme Icon + Favorite Toggle
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.space8),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      service.categoryIcon,
                      size: AppSizes.iconMD,
                      color: categoryColor,
                    ),
                  ),
                  const SizedBox(width: AppSizes.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                          ),
                          child: Text(
                            context.translate('cat_gov_${service.category}').toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: categoryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 9.0,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSizes.space4),
                        Text(
                          context.translate(service.nameKey),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: isFav ? theme.colorScheme.primary : theme.colorScheme.outline,
                    ),
                    tooltip: isFav
                        ? context.translate('gov_favorite_remove')
                        : context.translate('gov_favorite_add'),
                    onPressed: () async {
                      final added = await _favoritesManager.toggleFavorite(service.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              context.translate(
                                added
                                    ? 'gov_favorite_added_toast'
                                    : 'gov_favorite_removed_toast',
                              ),
                            ),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.space8),

              // Short Explanation
              Text(
                context.translate(service.shortDescriptionKey),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSizes.space12),

              // Department info
              Row(
                children: [
                  Icon(
                    Icons.account_balance_outlined,
                    size: 15,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      context.translate(service.departmentKey),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.space8),

              // Required Documents preview tags
              Wrap(
                spacing: AppSizes.space4,
                runSpacing: AppSizes.space4,
                children: service.requiredDocsKeys.take(3).map((docKey) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    ),
                    child: Text(
                      context.translate(docKey),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10.5,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSizes.space12),
              const Divider(height: 1),
              const SizedBox(height: AppSizes.space8),

              // Card Actions (Visit Portal + Details)
              Row(
                children: [
                  if (hasWebsite) ...[
                    OutlinedButton.icon(
                      onPressed: () => OfficialLinkLauncher.launchOfficialPortal(
                        context,
                        url: service.officialWebsiteUrl,
                        serviceName: context.translate(service.nameKey),
                      ),
                      icon: const Icon(Icons.open_in_new_rounded, size: 14),
                      label: Text(
                        context.translate('gov_portal'),
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.space12),
                        minimumSize: const Size(0, AppSizes.touchTargetMin),
                      ),
                    ),
                    const SizedBox(width: AppSizes.space8),
                  ],
                  const Spacer(),
                  FilledButton.tonalIcon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GovServiceDetailScreen(service: service),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                    label: Text(
                      context.translate('view_all'),
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.space12),
                      minimumSize: const Size(0, AppSizes.touchTargetMin),
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

  Widget _buildEmptyState(BuildContext context, {required bool onlyFavorites}) {
    final theme = Theme.of(context);

    if (onlyFavorites) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.space24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bookmark_border_rounded,
                size: 56,
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppSizes.space16),
              Text(
                context.translate('gov_no_saved_title'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.space8),
              Text(
                context.translate('gov_no_saved_desc'),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSizes.space16),
              ElevatedButton(
                onPressed: () => _tabController.animateTo(1),
                child: Text(context.translate('gov_tab_all_services')),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 56,
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSizes.space16),
            Text(
              context.translate('gov_no_results_title'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.space8),
            Text(
              context.translate('gov_no_results_desc'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSizes.space16),
            ElevatedButton(
              onPressed: _clearFilters,
              child: Text(context.translate('gov_clear_filter')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityNoticeBanner(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSizes.space12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: AppSizes.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.translate('govt_disclaimer_title'),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.translate('govt_disclaimer_banner'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
