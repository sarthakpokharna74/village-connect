import 'package:flutter/material.dart';
import 'package:gram_connect/core/data/mock_data.dart';
import 'package:gram_connect/core/localization/app_localizations.dart';
import 'package:gram_connect/core/navigation/app_router.dart';
import 'package:gram_connect/core/theme/app_sizes.dart';
import 'package:gram_connect/shared/widgets/feature_card.dart';
import 'package:gram_connect/shared/widgets/gram_app_bar.dart';
import 'package:gram_connect/shared/widgets/responsive_grid.dart';
import 'package:gram_connect/shared/widgets/section_header.dart';

import 'package:gram_connect/core/state/global_state.dart';
import 'package:gram_connect/features/notices/presentation/screens/notices_screen.dart';
import 'package:gram_connect/features/services/presentation/screens/govt_services_screen.dart';
import 'package:gram_connect/features/community/presentation/screens/community_screen.dart';
import 'package:gram_connect/features/auth/presentation/screens/profile_screen.dart';

/// Complete tabbed navigation shell for GramConnect V1.
/// Hosts the GramAppBar, NavigationBar (Bottom Navigation), and dynamically switches
/// between 5 main tabs: Home, Updates, Services, Community, and Profile.
class HomeScreen extends StatefulWidget {
  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChanged;
  final bool isLoggedIn;
  final ValueChanged<bool> onLoginStateChanged;

  const HomeScreen({
    super.key,
    required this.currentLocale,
    required this.onLocaleChanged,
    required this.isLoggedIn,
    required this.onLoginStateChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {

    // Define the tab contents
    final List<Widget> tabs = [
      HomeTabContent(
        isLoggedIn: widget.isLoggedIn,
        onLoginStateChanged: widget.onLoginStateChanged,
        onTabChange: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      const NoticesScreen(),
      const GovtServicesScreen(),
      const CommunityScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: GramAppBar(
        currentLocale: widget.currentLocale,
        onLocaleChanged: widget.onLocaleChanged,
        isLoggedIn: widget.isLoggedIn,
        onProfileTap: () {
          // Switch to Profile Tab
          setState(() {
            _currentIndex = 4;
          });
        },
        title: _getTabTitle(context, _currentIndex),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: context.translate('tab_home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.campaign_outlined),
            selectedIcon: const Icon(Icons.campaign_rounded),
            label: context.translate('tab_updates'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.widgets_outlined),
            selectedIcon: const Icon(Icons.widgets_rounded),
            label: context.translate('tab_services'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline_rounded),
            selectedIcon: const Icon(Icons.people_rounded),
            label: context.translate('tab_community'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_circle_outlined),
            selectedIcon: const Icon(Icons.account_circle_rounded),
            label: context.translate('tab_profile'),
          ),
        ],
      ),
    );
  }

  String _getTabTitle(BuildContext context, int index) {
    switch (index) {
      case 0:
        return 'GramConnect';
      case 1:
        return context.translate('village_notices');
      case 2:
        return context.translate('govt_services');
      case 3:
        return context.translate('community');
      case 4:
        return context.translate('profile');
      default:
        return 'GramConnect';
    }
  }
}

/// Content widget for the primary Dashboard Home Tab.
/// Houses the Welcome Banner, Real-time search, Feature Grid, Updates & Events feeds,
/// Quick Access shortcuts, and Footer block.
class HomeTabContent extends StatefulWidget {
  final bool isLoggedIn;
  final ValueChanged<bool> onLoginStateChanged;
  final Function(int) onTabChange;

  const HomeTabContent({
    super.key,
    required this.isLoggedIn,
    required this.onLoginStateChanged,
    required this.onTabChange,
  });

  @override
  State<HomeTabContent> createState() => _HomeTabContentState();
}

class _HomeTabContentState extends State<HomeTabContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final user = GramConnectStateProvider.of(context).currentUser;
    final userName = (user != null && user.fullName.isNotEmpty) ? user.fullName : context.translate('villager');

    // Filter features list in real-time based on localized search title match
    final filteredFeatures = MockData.dashboardFeatures.where((feature) {
      if (_searchQuery.isEmpty) return true;
      final localizedTitle = context.translate(feature.key).toLowerCase();
      return localizedTitle.contains(_searchQuery);
    }).toList();

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. Welcome Banner Widget (M3 Card) ---
            Padding(
              padding: const EdgeInsets.only(
                left: AppSizes.space16,
                right: AppSizes.space16,
                top: AppSizes.space16,
              ),
              child: Card(
                elevation: 0.5,
                color: isDark 
                    ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                    : theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                  side: BorderSide(
                    color: isDark 
                        ? theme.colorScheme.surfaceContainerHighest 
                        : theme.colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.space16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.isLoggedIn 
                                  ? '${context.translate('welcome_back')}, $userName!'
                                  : context.translate('welcome_guest'),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark 
                                    ? theme.colorScheme.onSurface 
                                    : theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: AppSizes.space4),
                            Text(
                              widget.isLoggedIn 
                                  ? context.translate('welcome_verified_sub')
                                  : context.translate('welcome_guest_sub'),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 13.0,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSizes.space16),
                      // Village Identity Badge (Zero Fabricated Weather Data)
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AppRouter.featureDetail,
                            arguments: {'key': 'our_village'},
                          );
                        },
                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.space12,
                            vertical: AppSizes.space8,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.location_on_rounded, size: 26, color: theme.colorScheme.primary),
                              const SizedBox(height: AppSizes.space4),
                              Text(
                                context.translate('village_name_only'),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- 2. Localized Search Bar Widget ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.space16,
                vertical: AppSizes.space12,
              ),
              child: SearchField(controller: _searchController),
            ),

            // --- 3. Section Header (Village Directory) ---
            SectionHeader(
              title: context.translate('village_name'),
              subtitle: context.translate('select_card_browse'),
            ),

            // --- 4. 2-Column Grid Area ---
            if (filteredFeatures.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.space24),
                child: Center(
                  child: Text(
                    context.translate('no_matching_services'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ResponsiveFeatureGrid(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: filteredFeatures.map((feature) {
                  return FeatureCard(
                    title: context.translate(feature.key),
                    description: context.translate('${feature.key}_desc'),
                    icon: feature.icon,
                    accentColor: feature.color,
                    onTap: () => _onFeatureTap(context, feature),
                  );
                }).toList(),
              ),

            const SizedBox(height: AppSizes.space16),

            // --- 5. Latest Updates Section ---
            SectionHeader(
              title: context.translate('latest_updates'),
              subtitle: context.translate('recent_notices_alerts'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
              child: Column(
                children: [
                  _buildUpdateCard(
                    context,
                    titleKey: 'update_1_title',
                    descKey: 'update_1_desc',
                    icon: Icons.water_drop_rounded,
                    color: Colors.blue,
                    onTap: () {
                      // Navigate to Notices screen
                      Navigator.of(context).pushNamed(
                        AppRouter.featureDetail,
                        arguments: {'key': 'village_notices'},
                      );
                    },
                  ),
                  const SizedBox(height: AppSizes.space8),
                  _buildUpdateCard(
                    context,
                    titleKey: 'update_2_title',
                    descKey: 'update_2_desc',
                    icon: Icons.document_scanner_rounded,
                    color: Colors.amber[700]!,
                    onTap: () {
                      // Navigate to Notices screen
                      Navigator.of(context).pushNamed(
                        AppRouter.featureDetail,
                        arguments: {'key': 'village_notices'},
                      );
                    },
                  ),
                  const SizedBox(height: AppSizes.space8),
                  _buildUpdateCard(
                    context,
                    titleKey: 'update_3_title',
                    descKey: 'update_3_desc',
                    icon: Icons.school_rounded,
                    color: Colors.green,
                    onTap: () {
                      // Navigate to Notices screen
                      Navigator.of(context).pushNamed(
                        AppRouter.featureDetail,
                        arguments: {'key': 'village_notices'},
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.space16),

            // --- 6. Upcoming Events Section ---
            SectionHeader(
              title: context.translate('upcoming_events_title'),
              subtitle: context.translate('upcoming_camps_gatherings'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
              child: Column(
                children: [
                  _buildEventCard(
                    context,
                    titleKey: 'event_1_title',
                    descKey: 'event_1_desc',
                    icon: Icons.health_and_safety_rounded,
                    color: Colors.red,
                    onTap: () {
                      // Navigate to Events screen
                      Navigator.of(context).pushNamed(
                        AppRouter.featureDetail,
                        arguments: {'key': 'events_festivals'},
                      );
                    },
                  ),
                  const SizedBox(height: AppSizes.space8),
                  _buildEventCard(
                    context,
                    titleKey: 'event_2_title',
                    descKey: 'event_2_desc',
                    icon: Icons.meeting_room_rounded,
                    color: Colors.deepPurple,
                    onTap: () {
                      // Navigate to Events screen
                      Navigator.of(context).pushNamed(
                        AppRouter.featureDetail,
                        arguments: {'key': 'events_festivals'},
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.space16),

            // --- 7. Quick Access Shortcuts Row ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16, vertical: AppSizes.space12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.translate('quick_access'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickAccessCard(
                          context,
                          icon: Icons.contact_phone_rounded,
                          label: context.translate('emergency_contacts'),
                          color: Colors.red[600]!,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AppRouter.featureDetail,
                              arguments: {'key': 'emergency_contacts'},
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: AppSizes.space12),
                      Expanded(
                        child: _buildQuickAccessCard(
                          context,
                          icon: Icons.map_rounded,
                          label: context.translate('important_places'),
                          color: Colors.brown[600]!,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AppRouter.featureDetail,
                              arguments: {'key': 'important_places'},
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: AppSizes.space12),
                      Expanded(
                        child: _buildQuickAccessCard(
                          context,
                          icon: Icons.account_balance_rounded,
                          label: context.translate('govt_services'),
                          color: Colors.blue[600]!,
                          onTap: () => widget.onTabChange(2), // Switch to Services tab
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.space32),

            // --- 8. Footer Block ---
            Container(
              padding: const EdgeInsets.all(AppSizes.space24),
              color: isDark 
                  ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1)
                  : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              child: Column(
                children: [
                  Text(
                    context.translate('footer_text'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12.0,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.space8),
                  Text(
                    context.translate('version'),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontSize: 10.0,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1.0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.space16, horizontal: AppSizes.space8),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: AppSizes.space8),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 11.0,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateCard(
    BuildContext context, {
    required String titleKey,
    required String descKey,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0.2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.space12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.space8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: AppSizes.iconMD, color: color),
              ),
              const SizedBox(width: AppSizes.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.translate(titleKey),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space4),
                    Text(
                      context.translate(descKey),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12.0,
                      ),
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

  Widget _buildEventCard(
    BuildContext context, {
    required String titleKey,
    required String descKey,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0.2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.space12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.space8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                ),
                child: Icon(icon, size: AppSizes.iconMD, color: color),
              ),
              const SizedBox(width: AppSizes.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.translate(titleKey),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space4),
                    Text(
                      context.translate(descKey),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12.0,
                      ),
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

  void _onFeatureTap(BuildContext context, FeatureItem feature) {
    // Navigate to the feature detail page. Guests can open all screens (including Help & Feedback).
    Navigator.of(context).pushNamed(
      AppRouter.featureDetail,
      arguments: {
        'key': feature.key,
        'icon': feature.icon,
        'color': feature.color,
      },
    );
  }
}

/// Simple search field with rounded borders and localized placeholder
class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;

  const SearchField({
    super.key,
    required this.controller,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextField(
      controller: controller,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: hintText ?? context.translate('search_placeholder'),
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () => controller.clear(),
              )
            : null,
        filled: true,
        fillColor: isDark 
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.space16,
          vertical: AppSizes.space12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.15),
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.15),
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
