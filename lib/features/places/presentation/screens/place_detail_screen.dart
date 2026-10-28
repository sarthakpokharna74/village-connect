import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../data/models/place_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/utils/app_share_service.dart';

/// Comprehensive Place Details Screen in GramConnect
/// Displays verified place information while safely handling unverified/missing data.
/// Directions and call actions are disabled or hidden if accurate data is unavailable.
class PlaceDetailScreen extends StatelessWidget {
  final Place place;

  const PlaceDetailScreen({
    super.key,
    required this.place,
  });

  void _sharePlace(BuildContext context) {
    final placeName = context.translate(place.nameKey);
    final categoryName = context.translate('cat_places_${place.category}');
    final location = place.addressKey != null ? context.translate(place.addressKey!) : '';
    final shareText = '$placeName ($categoryName)\nDhawalpuri, Parner, Ahilyanagar\n$location';

    AppShareService.share(
      context: context,
      text: shareText,
      subject: placeName,
      successMessageKey: 'share_place_success',
    );
  }

  Future<void> _onGetDirections(BuildContext context) async {
    if (!place.hasValidCoordinates && place.mapUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('directions_unavailable_desc')),
          backgroundColor: Colors.blueGrey,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final target = place.mapUrl ?? 'https://www.google.com/maps/search/?api=1&query=${place.latitude},${place.longitude}';
    final uri = Uri.tryParse(target);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _onCall(BuildContext context) {
    if (!place.hasVerifiedPhone) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('call_unavailable_desc')),
          backgroundColor: Colors.blueGrey,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Safe simulated call confirmation dialog matching GramConnect conventions
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        ),
        title: Text(dialogCtx.translate('call_confirm_title')),
        content: Text('${dialogCtx.translate('call_confirm_desc')} ${place.phoneNumber}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(dialogCtx.translate('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${context.translate('call_started')} ${place.phoneNumber}'),
                  backgroundColor: AppColors.primaryLight,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(dialogCtx.translate('call')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categoryInfo = PlaceCategoryInfo.forCategory(place.category);
    final placeName = context.translate(place.nameKey);
    final categoryName = context.translate('cat_places_${place.category}');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          placeName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: context.translate('share_place'),
            icon: const Icon(Icons.share_rounded),
            onPressed: () => _sharePlace(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Header Card
            Container(
              padding: const EdgeInsets.all(AppSizes.space16),
              decoration: BoxDecoration(
                color: isDark ? theme.colorScheme.surface : Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
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
                          size: AppSizes.iconLG,
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
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSizes.space4),
                            Text(
                              categoryName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: categoryInfo.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.space12),
                  const Divider(height: 1),
                  const SizedBox(height: AppSizes.space12),
                  // Badges Row
                  Wrap(
                    spacing: AppSizes.space8,
                    runSpacing: AppSizes.space8,
                    children: [
                      // Verification Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.space8,
                          vertical: AppSizes.space4,
                        ),
                        decoration: BoxDecoration(
                          color: place.verificationStatus.badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                          border: Border.all(
                            color: place.verificationStatus.badgeColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              place.verificationStatus == PlaceVerificationStatus.verified
                                  ? Icons.verified_rounded
                                  : (place.isReferenceLandmark
                                      ? Icons.location_on_rounded
                                      : Icons.info_outline_rounded),
                              size: AppSizes.iconSM,
                              color: place.verificationStatus.badgeColor,
                            ),
                            const SizedBox(width: AppSizes.space4),
                            Text(
                              context.translate(place.verificationStatus.statusKey),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: place.verificationStatus.badgeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Village tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.space8,
                          vertical: AppSizes.space4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                        ),
                        child: Text(
                          context.translate('dhawalpuri_title'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.space16),

            // Reference Landmark Notice Banner
            if (place.isReferenceLandmark)
              Container(
                margin: const EdgeInsets.only(bottom: AppSizes.space16),
                padding: const EdgeInsets.all(AppSizes.space12),
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  border: Border.all(
                    color: AppColors.secondaryLight.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.account_balance_rounded,
                      color: AppColors.secondaryLight,
                      size: AppSizes.iconMD,
                    ),
                    const SizedBox(width: AppSizes.space8),
                    Expanded(
                      child: Text(
                        context.translate('reference_landmark_notice'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.orange.shade200 : AppColors.secondaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Sample Content Banner
            if (place.verificationStatus == PlaceVerificationStatus.sample)
              Container(
                margin: const EdgeInsets.only(bottom: AppSizes.space16),
                padding: const EdgeInsets.all(AppSizes.space12),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  border: Border.all(
                    color: Colors.blueGrey.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.science_outlined,
                      color: Colors.blueGrey,
                      size: AppSizes.iconMD,
                    ),
                    const SizedBox(width: AppSizes.space8),
                    Expanded(
                      child: Text(
                        context.translate('sample_place_banner'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.blueGrey.shade200 : Colors.blueGrey.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Description Section
            _buildSectionCard(
              context,
              title: context.translate('form_description'),
              icon: Icons.notes_rounded,
              child: Text(
                place.descriptionKey != null
                    ? context.translate(place.descriptionKey!)
                    : context.translate('details_not_available'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: AppSizes.space16),

            // Address & Location Section
            _buildSectionCard(
              context,
              title: context.translate('address_label'),
              icon: Icons.place_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.addressKey != null
                        ? context.translate(place.addressKey!)
                        : context.translate('details_not_available'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space8),
                  Text(
                    'Dhawalpuri, Parner, Ahilyanagar, Maharashtra 414302',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Opening Hours Section (only when verified)
            if (place.openingHoursKey != null) ...[
              const SizedBox(height: AppSizes.space16),
              _buildSectionCard(
                context,
                title: context.translate('opening_hours_label'),
                icon: Icons.access_time_rounded,
                child: Text(
                  context.translate(place.openingHoursKey!),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],

            // Facilities Section (only when verified)
            if (place.facilities != null && place.facilities!.isNotEmpty) ...[
              const SizedBox(height: AppSizes.space16),
              _buildSectionCard(
                context,
                title: context.translate('facilities_label'),
                icon: Icons.checklist_rounded,
                child: Wrap(
                  spacing: AppSizes.space8,
                  runSpacing: AppSizes.space8,
                  children: place.facilities!.map((facility) {
                    return Chip(
                      label: Text(facility),
                      avatar: const Icon(Icons.check_circle_outline, size: 16),
                    );
                  }).toList(),
                ),
              ),
            ],

            const SizedBox(height: AppSizes.space16),

            // Metadata & Verification Section
            _buildSectionCard(
              context,
              title: context.translate('verification_label'),
              icon: Icons.verified_user_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.translate('source_label'),
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                      Text(
                        place.source ?? 'Dhawalpuri Community Reference',
                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.space8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.translate('verification_label'),
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                      Text(
                        context.translate(place.verificationStatus.statusKey),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: place.verificationStatus.badgeColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.space24),

            // Actions: Directions & Call
            // Directions Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSizes.btnHeightLarge),
                backgroundColor: place.hasValidCoordinates || place.mapUrl != null
                    ? AppColors.primaryLight
                    : Colors.grey.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                ),
              ),
              onPressed: (place.hasValidCoordinates || place.mapUrl != null)
                  ? () => _onGetDirections(context)
                  : () => _onGetDirections(context),
              icon: Icon(
                place.hasValidCoordinates || place.mapUrl != null
                    ? Icons.directions_rounded
                    : Icons.directions_off_rounded,
              ),
              label: Text(
                place.hasValidCoordinates || place.mapUrl != null
                    ? context.translate('get_directions')
                    : context.translate('directions_unavailable'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            if (!place.hasValidCoordinates && place.mapUrl == null) ...[
              const SizedBox(height: AppSizes.space4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.space4),
                child: Text(
                  context.translate('directions_unavailable_desc'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            const SizedBox(height: AppSizes.space12),

            // Call Button (Only enabled if verified phone exists)
            if (place.hasVerifiedPhone)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(AppSizes.btnHeightLarge),
                  backgroundColor: AppColors.secondaryLight,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  ),
                ),
                onPressed: () => _onCall(context),
                icon: const Icon(Icons.phone_rounded),
                label: Text(
                  '${context.translate('call_place')} (${place.phoneNumber})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(AppSizes.space12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.phone_disabled_rounded, size: AppSizes.iconMD, color: Colors.grey),
                    const SizedBox(width: AppSizes.space8),
                    Text(
                      context.translate('call_unavailable_desc'),
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: AppSizes.space20),

            // Report Issue Action
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSizes.btnHeightNormal),
                side: BorderSide(
                  color: Colors.red.shade300,
                ),
                foregroundColor: Colors.red.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRouter.placeReport,
                  arguments: {'place': place},
                );
              },
              icon: const Icon(Icons.flag_outlined, size: AppSizes.iconMD),
              label: Text(context.translate('report_issue')),
            ),

            const SizedBox(height: AppSizes.space24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: AppSizes.iconMD, color: AppColors.primaryLight),
              const SizedBox(width: AppSizes.space8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.space12),
          child,
        ],
      ),
    );
  }
}
