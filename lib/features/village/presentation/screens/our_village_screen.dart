import 'package:flutter/material.dart';
import 'package:gram_connect/core/localization/app_localizations.dart';
import 'package:gram_connect/core/theme/app_sizes.dart';
import 'package:gram_connect/shared/widgets/section_header.dart';
import 'package:gram_connect/shared/widgets/state_widgets.dart';

// Import data architecture models and repository
import '../../data/models/village_models.dart';
import '../../data/repositories/village_repository.dart';
import '../../../../core/utils/app_share_service.dart';

/// "Our Dhawalpuri" digital identity screen for GramConnect V1.
/// Accessible publicly without login. Displays facts, history, landmarks, facilities, and photo gallery.
class OurVillageScreen extends StatefulWidget {
  const OurVillageScreen({super.key});

  @override
  State<OurVillageScreen> createState() => _OurVillageScreenState();
}

class _OurVillageScreenState extends State<OurVillageScreen> {
  final VillageRepository _repository = const MockVillageRepository();

  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  late VillageInfo _villageInfo;
  List<VillageFact> _facts = [];
  List<VillagePlace> _places = [];
  List<VillageFacility> _facilities = [];
  List<VillagePhoto> _photos = [];

  @override
  void initState() {
    super.initState();
    _loadVillageData();
  }

  Future<void> _loadVillageData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final info = await _repository.getVillageInfo();
      final facts = await _repository.getVillageFacts();
      final places = await _repository.getVillagePlaces();
      final facilities = await _repository.getVillageFacilities();
      final photos = await _repository.getVillagePhotos();

      if (mounted) {
        setState(() {
          _villageInfo = info;
          _facts = facts;
          _places = places;
          _facilities = facilities;
          _photos = photos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate('our_village')),
        backgroundColor: isDark ? theme.colorScheme.surface : theme.colorScheme.primary,
        foregroundColor: isDark ? theme.colorScheme.onSurface : theme.colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: LoadingState());
    }

    if (_hasError) {
      return Center(
        child: ErrorState(
          message: _errorMessage,
          onRetry: _loadVillageData,
        ),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- 1. Visually Attractive But Lightweight Village Hero Section ---
          Container(
            height: 180,
            margin: const EdgeInsets.all(AppSizes.space16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(AppSizes.radiusLG),
              border: Border.all(
                color: isDark 
                    ? theme.colorScheme.surfaceContainerHighest 
                    : theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.landscape_rounded,
                        size: 48,
                        color: theme.colorScheme.primary.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: AppSizes.space8),
                      Text(
                        'Dhawalpuri, Parner',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: AppSizes.space16,
                  left: AppSizes.space16,
                  child: Row(
                    children: [
                      const Text(
                        '🌾 ',
                        style: TextStyle(fontSize: 24),
                      ),
                      Text(
                        'Dhawalpuri',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: AppSizes.space16,
                  left: AppSizes.space16,
                  child: Text(
                    '"Your Digital Village"',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dhawalpuri',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.space4),
                Text(
                  'Parner, Ahilyanagar, Maharashtra',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.space16),

          // --- 2. Quick Facts 2-Column Grid ---
          SectionHeader(
            title: context.translate('quick_facts'),
            subtitle: 'Key administrative details',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSizes.space12,
                mainAxisSpacing: AppSizes.space12,
                childAspectRatio: 2.1,
              ),
              itemCount: _facts.length,
              itemBuilder: (context, index) {
                return _buildFactCard(context, _facts[index]);
              },
            ),
          ),

          const SizedBox(height: AppSizes.space16),

          // --- 3. About the Village ---
          SectionHeader(
            title: context.translate('our_village'),
            subtitle: 'Dhawalpuri Overview',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
            child: Card(
              elevation: 0.5,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.space16),
                child: Text(
                  context.translate(_villageInfo.introKey),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    fontSize: 13.0,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSizes.space16),

          // --- 4. Village History ---
          SectionHeader(
            title: '📖 ${context.translate('history_title')}',
            subtitle: 'Our heritage',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
            child: Card(
              elevation: 0.5,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.space16),
                child: Text(
                  context.translate(_villageInfo.historyKey),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    fontSize: 13.0,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSizes.space16),

          // --- 5. Local Identity ("Places That Define Dhawalpuri") ---
          SectionHeader(
            title: context.translate('places_that_define'),
            subtitle: 'Iconic landmarks',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _places.length,
              itemBuilder: (context, index) {
                return _buildPlaceCard(context, _places[index]);
              },
            ),
          ),

          const SizedBox(height: AppSizes.space16),

          // --- 6. Village Facilities 2-Column Grid ---
          SectionHeader(
            title: context.translate('facilities_title'),
            subtitle: 'Essential village directories',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSizes.space12,
                mainAxisSpacing: AppSizes.space12,
                childAspectRatio: 1.1,
              ),
              itemCount: _facilities.length,
              itemBuilder: (context, index) {
                return _buildFacilityCard(context, _facilities[index]);
              },
            ),
          ),

          const SizedBox(height: AppSizes.space16),

          // --- 7. Location Card & View on Map ---
          SectionHeader(
            title: '📍 ${context.translate('district')}',
            subtitle: 'Geographical center',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
            child: Card(
              elevation: 0.5,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.pin_drop_rounded, color: Colors.red, size: 28),
                        const SizedBox(width: AppSizes.space12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '📍 Dhawalpuri',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Parner, Ahilyanagar, Maharashtra, India',
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
                    const SizedBox(height: AppSizes.space16),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('📍 Dhawalpuri Center: 19.14° N, 74.28° E (Parner, Ahilyanagar)'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      },
                      icon: const Icon(Icons.map_rounded),
                      label: Text(context.translate('view_on_map')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        foregroundColor: theme.colorScheme.onPrimaryContainer,
                        elevation: 0,
                        minimumSize: const Size(double.infinity, AppSizes.touchTargetMin),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSizes.space16),

          // --- 8. Village Photo Gallery ("Explore Dhawalpuri") ---
          SectionHeader(
            title: context.translate('gallery_title'),
            subtitle: 'Snapshots of local life',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSizes.space12,
                mainAxisSpacing: AppSizes.space12,
                childAspectRatio: 0.9,
              ),
              itemCount: _photos.length,
              itemBuilder: (context, index) {
                return _buildPhotoGalleryCard(context, _photos[index]);
              },
            ),
          ),

          const SizedBox(height: AppSizes.space16),

          // --- 9. Share Dhawalpuri Section ---
          Padding(
            padding: const EdgeInsets.all(AppSizes.space16),
            child: Card(
              elevation: 0.5,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.space16),
                child: Column(
                  children: [
                    Text(
                      context.translate('share_dhawalpuri'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space8),
                    Text(
                      context.translate('share_dhawalpuri_desc'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.space16),
                    OutlinedButton.icon(
                      onPressed: () {
                        final shareText = '🌾 Dhawalpuri (ढवळपुरी) - Your Digital Village\n'
                            'Taluka: Parner | District: Ahilyanagar, Maharashtra\n'
                            'Explore GramConnect for village notices, government schemes, local contacts, and agriculture resources.';
                        AppShareService.share(
                          context: context,
                          text: shareText,
                          subject: 'Dhawalpuri Digital Village Profile',
                        );
                      },
                      icon: const Icon(Icons.share_rounded),
                      label: Text(context.translate('share_dhawalpuri')),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, AppSizes.touchTargetMin),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSizes.space16),
        ],
      ),
    );
  }

  Widget _buildFactCard(BuildContext context, VillageFact fact) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0.5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.space12),
        child: Row(
          children: [
            Icon(fact.icon, size: 28, color: theme.colorScheme.primary),
            const SizedBox(width: AppSizes.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.translate(fact.titleKey),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                      fontSize: 10.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    context.translate(fact.valueKey),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (fact.subtitleKey != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      context.translate(fact.subtitleKey!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        fontSize: 9.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceCard(BuildContext context, VillagePlace place) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: AppSizes.space12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  place.id == 'pl1' ? Icons.temple_hindu_rounded : Icons.water_rounded,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: AppSizes.space12),
                Expanded(
                  child: Text(
                    context.translate(place.nameKey),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.space8),
            Text(
              context.translate(place.descriptionKey),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 13.0,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSizes.space12),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSizes.space4),
                Expanded(
                  child: Text(
                    context.translate(place.locationKey),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.map_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () {
                    if (place.latitude != null && place.longitude != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Viewing ${context.translate(place.nameKey)} on Map... (Coordinates: ${place.latitude}, ${place.longitude})',
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${context.translate(place.nameKey)}: ${context.translate('coords_pending_verification')}',
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilityCard(BuildContext context, VillageFacility facility) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0.2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.space12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(facility.icon, size: 20, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: AppSizes.space8),
            Text(
              context.translate(facility.nameKey),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 12.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSizes.space4),
            Text(
              context.translate(facility.descriptionKey),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 10.0,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGalleryCard(BuildContext context, VillagePhoto photo) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSizes.radiusMD),
              ),
            ),
            child: Center(
              child: Icon(
                photo.categoryKey == 'admin'
                    ? Icons.corporate_fare_rounded
                    : photo.categoryKey == 'culture'
                        ? Icons.festival_rounded
                        : Icons.agriculture_rounded,
                size: 28,
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.space8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    ),
                    child: Text(
                      photo.categoryKey.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 8.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.space4),
                  Text(
                    context.translate(photo.titleKey),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 11.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    context.translate(photo.descriptionKey),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 9.0,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
