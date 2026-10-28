import 'package:flutter/material.dart';
import 'package:gram_connect/core/localization/app_localizations.dart';
import 'package:gram_connect/core/theme/app_sizes.dart';
import 'package:gram_connect/core/utils/official_link_launcher.dart';
import 'package:gram_connect/features/services/data/models/gov_service_model.dart';
import 'package:gram_connect/features/services/data/services/service_favorites_manager.dart';

/// Dedicated Service Details Screen (Blueprint 7 Section 5).
/// Displays Overview, Eligibility, Required Documents Checklist with variation disclaimer,
/// Step-by-step Application Process, Fees & Timeline, Official Resources, Source & Verification Date.
class GovServiceDetailScreen extends StatefulWidget {
  final GovernmentService service;

  const GovServiceDetailScreen({
    super.key,
    required this.service,
  });

  @override
  State<GovServiceDetailScreen> createState() => _GovServiceDetailScreenState();
}

class _GovServiceDetailScreenState extends State<GovServiceDetailScreen> {
  final ServiceFavoritesManager _favoritesManager = ServiceFavoritesManager();

  @override
  void initState() {
    super.initState();
    _favoritesManager.addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    _favoritesManager.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = widget.service;
    final isFav = _favoritesManager.isFavorite(service.id);
    final serviceName = context.translate(service.nameKey);
    final deptName = context.translate(service.departmentKey);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          serviceName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: isFav
                ? context.translate('gov_favorite_remove')
                : context.translate('gov_favorite_add'),
            icon: Icon(
              isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: isFav ? theme.colorScheme.primary : null,
            ),
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
          IconButton(
            tooltip: context.translate('gov_share_service'),
            icon: const Icon(Icons.share_outlined),
            onPressed: () => OfficialLinkLauncher.shareServiceInfo(
              context,
              serviceName: serviceName,
              officialUrl: service.officialWebsiteUrl,
              department: deptName,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header Card with Category, Name, and Verification Badge
              _buildHeaderCard(context, service),
              const SizedBox(height: AppSizes.space16),

              // 2. Community Disclaimer Notice
              _buildDisclaimerBanner(context),
              const SizedBox(height: AppSizes.space16),

              // 3. Section: Overview
              _buildOverviewSection(context, service),
              const SizedBox(height: AppSizes.space16),

              // 4. Section: Eligibility
              _buildEligibilitySection(context, service),
              const SizedBox(height: AppSizes.space16),

              // 5. Section: Required Documents (Checklist)
              _buildRequiredDocsSection(context, service),
              const SizedBox(height: AppSizes.space16),

              // 6. Section: Application Process
              _buildApplicationProcessSection(context, service),
              const SizedBox(height: AppSizes.space16),

              // 7. Section: Fees & Timeline
              _buildFeesTimelineSection(context, service),
              const SizedBox(height: AppSizes.space16),

              // 8. Section: Official Resources (External Browser Web Safety)
              _buildOfficialResourcesSection(context, service),
              const SizedBox(height: AppSizes.space16),

              // 9. Section: Source & Verification Details
              _buildSourceAndVerificationCard(context, service),
              const SizedBox(height: AppSizes.space32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, GovernmentService service) {
    final theme = Theme.of(context);
    final categoryColor = service.categoryColor;

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.space8),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    service.categoryIcon,
                    color: categoryColor,
                    size: AppSizes.iconMD,
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
                          color: categoryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                        ),
                        child: Text(
                          context.translate('cat_gov_${service.category}').toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: categoryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 9.5,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.space4),
                      Text(
                        context.translate(service.nameKey),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.space12),
            // Verification Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: service.verificationStatus.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                border: Border.all(
                  color: service.verificationStatus.color.withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    service.verificationStatus.icon,
                    size: 15,
                    color: service.verificationStatus.color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    context.translate(service.verificationStatus.translationKey),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: service.verificationStatus.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (service.lastVerifiedAt != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '• ${context.translate('gov_last_verified')}: ${service.lastVerifiedAt}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
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

  Widget _buildDisclaimerBanner(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSizes.space12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(width: AppSizes.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.translate('gov_disclaimer_title'),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.translate('gov_disclaimer_banner'),
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

  Widget _buildOverviewSection(BuildContext context, GovernmentService service) {
    final theme = Theme.of(context);

    return _buildSectionCard(
      context,
      title: context.translate('gov_overview_title'),
      icon: Icons.info_outline_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.translate('gov_purpose_label'),
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSizes.space4),
          Text(
            context.translate(service.shortDescriptionKey),
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSizes.space12),
          const Divider(height: 1),
          const SizedBox(height: AppSizes.space12),
          Text(
            context.translate('gov_dept_label'),
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSizes.space4),
          Row(
            children: [
              Icon(
                Icons.account_balance_rounded,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.translate(service.departmentKey),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEligibilitySection(BuildContext context, GovernmentService service) {
    final theme = Theme.of(context);

    return _buildSectionCard(
      context,
      title: context.translate('gov_eligibility_title'),
      icon: Icons.how_to_reg_rounded,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 18,
            color: service.categoryColor,
          ),
          const SizedBox(width: AppSizes.space8),
          Expanded(
            child: Text(
              context.translate(service.eligibilityKey),
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequiredDocsSection(BuildContext context, GovernmentService service) {
    final theme = Theme.of(context);

    return _buildSectionCard(
      context,
      title: context.translate('gov_docs_title'),
      icon: Icons.checklist_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checklist items
          ...service.requiredDocsKeys.map((docKey) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.space8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppSizes.space8),
                  Expanded(
                    child: Text(
                      context.translate(docKey),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: AppSizes.space8),
          // Disclaimer: requirements can change
          Container(
            padding: const EdgeInsets.all(AppSizes.space8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 15,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    context.translate('gov_docs_disclaimer'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11.5,
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationProcessSection(BuildContext context, GovernmentService service) {
    final theme = Theme.of(context);

    return _buildSectionCard(
      context,
      title: context.translate('gov_process_title'),
      icon: Icons.timeline_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Method Badges
          Row(
            children: [
              if (service.isOnlineAvailable)
                Container(
                  margin: const EdgeInsets.only(right: AppSizes.space8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.language_rounded, size: 14, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        context.translate('gov_online_method'),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              if (service.isOfflineAvailable)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.storefront_rounded, size: 14, color: theme.colorScheme.secondary),
                      const SizedBox(width: 4),
                      Text(
                        context.translate('gov_offline_method'),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.space12),

          // Steps list
          ...service.applicationStepsKeys.asMap().entries.map((entry) {
            final stepIndex = entry.key + 1;
            final stepKey = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.space8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 11,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      '$stepIndex',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.space8),
                  Expanded(
                    child: Text(
                      context.translate(stepKey),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFeesTimelineSection(BuildContext context, GovernmentService service) {
    final theme = Theme.of(context);

    return _buildSectionCard(
      context,
      title: context.translate('gov_fees_timeline_title'),
      icon: Icons.payments_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.translate('gov_fees_label'),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      service.feesKey != null
                          ? context.translate(service.feesKey!)
                          : context.translate('gov_fees_disclaimer'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.translate('gov_timeline_label'),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      service.timelineKey != null
                          ? context.translate(service.timelineKey!)
                          : 'As per department standards',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.space12),
          Text(
            context.translate('gov_fees_disclaimer'),
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11.5,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficialResourcesSection(BuildContext context, GovernmentService service) {
    final theme = Theme.of(context);
    final hasWebsite = service.officialWebsiteUrl != null && service.officialWebsiteUrl!.isNotEmpty;

    return _buildSectionCard(
      context,
      title: context.translate('gov_official_resources_title'),
      icon: Icons.public_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasWebsite) ...[
            ElevatedButton.icon(
              onPressed: () => OfficialLinkLauncher.launchOfficialPortal(
                context,
                url: service.officialWebsiteUrl,
                serviceName: context.translate(service.nameKey),
              ),
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: Text(context.translate('gov_open_portal')),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: AppSizes.space12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.space8),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(AppSizes.space12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.store_mall_directory_rounded,
                    size: 18,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: AppSizes.space8),
                  Expanded(
                    child: Text(
                      context.translate('gov_offline_instructions'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.space8),
          ],
          OutlinedButton.icon(
            onPressed: () => OfficialLinkLauncher.shareServiceInfo(
              context,
              serviceName: context.translate(service.nameKey),
              officialUrl: service.officialWebsiteUrl,
              department: context.translate(service.departmentKey),
            ),
            icon: const Icon(Icons.share_outlined, size: 16),
            label: Text(context.translate('gov_share_service')),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.space12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceAndVerificationCard(BuildContext context, GovernmentService service) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSizes.space12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.source_rounded,
                size: 15,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                context.translate('gov_source_label'),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            service.sourceName ?? 'Official Government Portal',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (service.lastVerifiedAt != null) ...[
            const SizedBox(height: 4),
            Text(
              '${context.translate('gov_last_verified')}: ${service.lastVerifiedAt}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ],
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

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: theme.colorScheme.primary),
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
      ),
    );
  }
}
