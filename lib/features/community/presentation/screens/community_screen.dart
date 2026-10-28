import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../shared/utils/auth_guard.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/state_widgets.dart';
import '../../data/models/community_model.dart';
import '../../data/repositories/community_repository.dart';
import 'community_detail_screen.dart';
import 'suggest_activity_screen.dart';

/// Community Directory Screen for GramConnect (Blueprint 4: Dhawalpuri).
/// Features:
/// - Screen title & subtitle in English, Marathi (ढवळपुरी), and Hindi
/// - Search with clear functionality
/// - Category filters (All + 8 categories)
/// - Featured community activity card
/// - Two-column category grid with large touch targets
/// - Explore Community listings with sample disclaimer tags
/// - Public browsing with protected actions (join, volunteer, register, suggest) guarded by AuthGuard
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final CommunityRepository _repository = MockCommunityRepository();
  final TextEditingController _searchController = TextEditingController();

  List<CommunityItem> _allItems = [];
  CommunityItem? _featuredItem;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  String _searchQuery = '';
  String _selectedCategory = 'all';

  final List<String> _categories = [
    'all',
    'community_groups',
    'cultural_activities',
    'sports_youth',
    'volunteering',
    'womens_groups',
    'senior_citizens',
    'village_celebrations',
    'social_initiatives',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadData();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final items = await _repository.getCommunityItems();
      final featured = await _repository.getFeaturedActivity();

      if (mounted) {
        setState(() {
          _allItems = items;
          _featuredItem = featured;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategory = 'all';
    });
  }

  void _navigateToSuggest(BuildContext context) {
    AuthGuard.run(
      context,
      explanationKey: 'community_login_suggest',
      onAuthenticated: () async {
        final result = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (context) => const SuggestActivityScreen(),
          ),
        );
        if (result == true) {
          _loadData();
        }
      },
    );
  }

  void _navigateToDetail(BuildContext context, CommunityItem item) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CommunityDetailScreen(item: item),
      ),
    );
    // Refresh to reflect any join/volunteer/register state changes made on detail screen
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handleCardAction(BuildContext context, CommunityItem item) async {
    final hasDone = _hasUserDoneAction(item);
    if (hasDone) return;

    AuthGuard.run(
      context,
      explanationKey: 'community_login_action',
      onAuthenticated: () async {
        const mockUserId = 'villager_user';
        String successKey = 'join_success';

        if (item.actionType == 'join') {
          await _repository.joinGroup(item.id, mockUserId);
          successKey = 'join_success';
        } else if (item.actionType == 'volunteer') {
          await _repository.volunteer(item.id, mockUserId);
          successKey = 'volunteer_success';
        } else if (item.actionType == 'register') {
          await _repository.registerActivity(item.id, mockUserId);
          successKey = 'register_success';
        } else {
          successKey = 'contact_success';
        }

        if (!context.mounted) return;

        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.translate(successKey)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  bool _hasUserDoneAction(CommunityItem item) {
    if (item.actionType == 'join') {
      return _repository.hasUserJoined(item.id);
    } else if (item.actionType == 'volunteer') {
      return _repository.hasUserVolunteered(item.id);
    } else if (item.actionType == 'register') {
      return _repository.hasUserRegistered(item.id);
    }
    return false;
  }

  String _getActionKey(CommunityItem item, bool isDone) {
    if (isDone) {
      if (item.actionType == 'join') return 'joined_group';
      if (item.actionType == 'volunteer') return 'volunteered';
      if (item.actionType == 'register') return 'registered_activity';
      return 'contact_group';
    }
    if (item.actionType == 'join') return 'join_group';
    if (item.actionType == 'volunteer') return 'volunteer_now';
    if (item.actionType == 'register') return 'register_activity';
    return 'contact_group';
  }

  List<CommunityItem> _getFilteredItems(BuildContext context) {
    return _allItems.where((item) {
      if (_selectedCategory != 'all' && item.category != _selectedCategory) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final localizedName = context.translate(item.nameKey).toLowerCase();
        final localizedDesc = context.translate(item.descriptionKey).toLowerCase();
        final localizedCat = context.translate(CommunityItem.getCategoryTitleKey(item.category)).toLowerCase();
        return localizedName.contains(_searchQuery) ||
            localizedDesc.contains(_searchQuery) ||
            localizedCat.contains(_searchQuery);
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canPop = Navigator.canPop(context);

    return Scaffold(
      appBar: canPop
          ? AppBar(
              title: Text(context.translate('community_title')),
              backgroundColor: isDark ? theme.colorScheme.surface : theme.colorScheme.primary,
              foregroundColor: isDark ? theme.colorScheme.onSurface : theme.colorScheme.onPrimary,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  tooltip: context.translate('suggest_activity'),
                  onPressed: () => _navigateToSuggest(context),
                ),
              ],
            )
          : null,
      body: SafeArea(
        child: _isLoading
            ? const LoadingState()
            : _hasError
                ? ErrorState(
                    message: _errorMessage,
                    onRetry: _loadData,
                  )
                : _buildBody(context),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToSuggest(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(context.translate('suggest_activity')),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final filteredItems = _getFilteredItems(context);

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 96.0), // Padding for FAB
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. Header (Title, Subtitle, Suggest Action) ---
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.space16,
                AppSizes.space16,
                AppSizes.space16,
                AppSizes.space8,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.translate('community_title'),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.translate('community_subtitle'),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _navigateToSuggest(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(
                      context.translate('suggest_activity'),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: const Size(0, 36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- 2. Search Field ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.space16,
                vertical: AppSizes.space8,
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: context.translate('search_community'),
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          tooltip: context.translate('clear_search'),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  contentPadding: const EdgeInsets.symmetric(vertical: AppSizes.space12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // --- 3. Horizontal Category Filter Chips ---
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final catKey = _categories[index];
                  final isSelected = _selectedCategory == catKey;
                  final label = catKey == 'all'
                      ? context.translate('comm_cat_all')
                      : context.translate(CommunityItem.getCategoryTitleKey(catKey));

                  return Padding(
                    padding: const EdgeInsets.only(right: AppSizes.space8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? catKey : 'all';
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

            const SizedBox(height: AppSizes.space12),

            // --- 4. Featured Community Activity Section (Shown when on "All" and no search) ---
            if (_searchQuery.isEmpty && _selectedCategory == 'all' && _featuredItem != null) ...[
              SectionHeader(
                title: context.translate('featured_activity'),
                trailing: TextButton(
                  onPressed: () => _navigateToDetail(context, _featuredItem!),
                  child: Text(context.translate('view_details')),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
                child: _buildFeaturedCard(context, _featuredItem!),
              ),
              const SizedBox(height: AppSizes.space20),
            ],

            // --- 5. Community Categories (Two-Column Grid) ---
            if (_searchQuery.isEmpty && _selectedCategory == 'all') ...[
              SectionHeader(
                title: context.translate('community_categories'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
                child: _buildCategoryGrid(context),
              ),
              const SizedBox(height: AppSizes.space24),
            ],

            // --- 6. Explore Community Section ---
            SectionHeader(
              title: context.translate('explore_community'),
              trailing: (_selectedCategory != 'all' || _searchQuery.isNotEmpty)
                  ? TextButton.icon(
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                      label: Text(
                        context.translate('clear_search'),
                        style: const TextStyle(fontSize: 12),
                      ),
                    )
                  : null,
            ),

            // Active category indicator if filtered
            if (_selectedCategory != 'all')
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSizes.space16,
                  right: AppSizes.space16,
                  bottom: AppSizes.space12,
                ),
                child: Row(
                  children: [
                    Text(
                      '${context.translate('showing_category')}: ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Chip(
                      label: Text(
                        context.translate(CommunityItem.getCategoryTitleKey(_selectedCategory)),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      onDeleted: () {
                        setState(() {
                          _selectedCategory = 'all';
                        });
                      },
                      deleteIcon: const Icon(Icons.close, size: 14),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ),

            // --- 7. Community Items List ---
            if (filteredItems.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.space32),
                child: EmptyState(
                  icon: Icons.search_off_rounded,
                  title: context.translate('community_search_empty'),
                  description: context.translate('community_search_empty_desc'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.space12),
                    child: _buildCommunityListingCard(context, filteredItems[index]),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Two-Column Category Grid (Blueprint 3)
  /// Clean, accessible cards with large touch targets, rounded corners, icons, and titles.
  Widget _buildCategoryGrid(BuildContext context) {
    final theme = Theme.of(context);
    final categoryKeys = _categories.where((c) => c != 'all').toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categoryKeys.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSizes.space12,
        crossAxisSpacing: AppSizes.space12,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, index) {
        final catKey = categoryKeys[index];
        final icon = CommunityItem.getIconForCategory(catKey);
        final color = CommunityItem.getColorForCategory(catKey);
        final title = context.translate(CommunityItem.getCategoryTitleKey(catKey));

        return Card(
          elevation: 0.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLG),
            side: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedCategory = catKey;
              });
            },
            borderRadius: BorderRadius.circular(AppSizes.radiusLG),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.space12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 24,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: AppSizes.space8),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        height: 1.25,
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

  /// Featured Community Activity Hero Card
  Widget _buildFeaturedCard(BuildContext context, CommunityItem item) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        side: BorderSide(
          color: item.categoryColor.withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(context, item),
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
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
                      color: item.categoryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item.icon, size: 14, color: item.categoryColor),
                        const SizedBox(width: 4),
                        Text(
                          context.translate('featured_activity').toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: item.categoryColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    ),
                    child: Text(
                      context.translate('sample_tag'),
                      style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.space8),
              Text(
                context.translate(item.nameKey),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: AppSizes.space4),
              Text(
                context.translate(item.descriptionKey),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (item.upcomingActivityKey != null) ...[
                const SizedBox(height: AppSizes.space8),
                Row(
                  children: [
                    Icon(Icons.event_rounded, size: 14, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        context.translate(item.upcomingActivityKey!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Community Listing Card (Explore Section)
  Widget _buildCommunityListingCard(BuildContext context, CommunityItem item) {
    final theme = Theme.of(context);
    final isDone = _hasUserDoneAction(item);

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(context, item),
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Category tag and sample badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: item.categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item.icon, size: 14, color: item.categoryColor),
                        const SizedBox(width: 5),
                        Text(
                          context.translate(CommunityItem.getCategoryTitleKey(item.category)),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: item.categoryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    ),
                    child: Text(
                      context.translate('sample_tag'),
                      style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.space8),

              // Group or Activity Name
              Text(
                context.translate(item.nameKey),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: AppSizes.space4),

              // Short Description
              Text(
                context.translate(item.descriptionKey),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Organizer (if available)
              if (item.organizerKey != null) ...[
                const SizedBox(height: AppSizes.space8),
                Row(
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${context.translate('organizer')}: ${context.translate(item.organizerKey!)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Location (if available)
              if (item.locationKey != null) ...[
                const SizedBox(height: AppSizes.space4),
                Row(
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        context.translate(item.locationKey!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Upcoming Activity info (if available)
              if (item.upcomingActivityKey != null) ...[
                const SizedBox(height: AppSizes.space4),
                Row(
                  children: [
                    Icon(
                      Icons.event_available_rounded,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        context.translate(item.upcomingActivityKey!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: AppSizes.space12),
              const Divider(height: 1),
              const SizedBox(height: AppSizes.space8),

              // Action Buttons Row: Relevant action (Join/Volunteer/Register) + Details
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isDone
                          ? null
                          : () => _handleCardAction(context, item),
                      icon: Icon(
                        isDone ? Icons.check_circle_rounded : _getActionIcon(item.actionType),
                        size: 16,
                      ),
                      label: Text(
                        context.translate(_getActionKey(item, isDone)),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDone
                            ? theme.colorScheme.surfaceContainerHighest
                            : item.categoryColor.withValues(alpha: 0.12),
                        foregroundColor: isDone
                            ? theme.colorScheme.onSurfaceVariant
                            : item.categoryColor,
                        elevation: 0,
                        minimumSize: const Size(0, AppSizes.touchTargetMin),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.space8),
                  OutlinedButton(
                    onPressed: () => _navigateToDetail(context, item),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, AppSizes.touchTargetMin),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      ),
                    ),
                    child: Text(
                      context.translate('view_details'),
                      style: const TextStyle(fontSize: 13),
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

  IconData _getActionIcon(String actionType) {
    switch (actionType) {
      case 'join':
        return Icons.group_add_rounded;
      case 'volunteer':
        return Icons.volunteer_activism_rounded;
      case 'register':
        return Icons.app_registration_rounded;
      default:
        return Icons.mail_outline_rounded;
    }
  }
}
