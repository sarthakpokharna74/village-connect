import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/phone_launcher_service.dart';
import '../../data/models/contact_model.dart';
import '../../../../core/utils/app_share_service.dart';

/// Dedicated Emergency Contact Details Screen for GramConnect (Blueprint 6).
/// Displays verified emergency information, safe calling action, and official sources.
class EmergencyContactDetailScreen extends StatelessWidget {
  final EmergencyContact contact;

  const EmergencyContactDetailScreen({
    super.key,
    required this.contact,
  });

  void _shareContact(BuildContext context) {
    final serviceName = context.translate(contact.nameKey);
    final categoryName = context.translate('cat_em_${contact.category}');
    final numberText = contact.hasValidPhoneNumber
        ? contact.phoneNumber!
        : context.translate('call_unavailable_title');
    final coverageText = contact.coverageKey != null
        ? context.translate(contact.coverageKey!)
        : 'Dhawalpuri, Parner, Ahilyanagar';

    final text = 'GramConnect Emergency Contact:\n'
        '$serviceName ($categoryName)\n'
        'Phone: $numberText\n'
        'Coverage: $coverageText\n'
        'Status: ${context.translate(contact.verificationStatus.statusKey)}';

    AppShareService.share(
      context: context,
      text: text,
      subject: serviceName,
      successMessageKey: 'share_contact_success',
    );
  }

  void _onDirections(BuildContext context) {
    if (contact.addressKey == null && contact.latitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('emergency_directions_unavailable')),
          backgroundColor: Colors.blueGrey,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${context.translate(contact.nameKey)}: ${context.translate(contact.addressKey!)}',
        ),
        backgroundColor: AppColors.primaryLight,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final serviceName = context.translate(contact.nameKey);
    final categoryInfo = EmergencyCategoryInfo.forCategory(contact.category);
    final categoryName = context.translate(categoryInfo.translationKey);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.translate('contact_details_title'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: context.translate('share_contact'),
            onPressed: () => _shareContact(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- 1. Service Hero Card ---
              Container(
                padding: const EdgeInsets.all(AppSizes.space20),
                decoration: BoxDecoration(
                  color: isDark
                      ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25)
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Icon in circle
                    Container(
                      padding: const EdgeInsets.all(AppSizes.space16),
                      decoration: BoxDecoration(
                        color: contact.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        contact.icon,
                        size: 40,
                        color: contact.color,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space16),

                    // Service Name
                    Text(
                      serviceName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.space8),

                    // Badges Row
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        // Category Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: categoryInfo.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                categoryInfo.icon,
                                size: 13,
                                color: categoryInfo.color,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                categoryName,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: categoryInfo.color,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Verification Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: contact.verificationStatus.badgeColor
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                contact.verificationStatus.icon,
                                size: 13,
                                color: contact.verificationStatus.badgeColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                context.translate(contact.verificationStatus.statusKey),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: contact.verificationStatus.badgeColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // National or Local Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white10
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            contact.isNationalService
                                ? context.translate('contact_status_national')
                                : context.translate('contact_status_local'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.space16),

              // --- 2. Prominent Call & Action Box ---
              if (contact.hasValidPhoneNumber) ...[
                Container(
                  padding: const EdgeInsets.all(AppSizes.space16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        contact.color.withValues(alpha: 0.12),
                        contact.color.withValues(alpha: 0.04),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                    border: Border.all(
                      color: contact.color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.phone_in_talk_rounded,
                            color: contact.color,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            contact.phoneNumber!,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: contact.color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.space12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: contact.color,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            PhoneLauncherService.confirmAndLaunchDialer(
                              context,
                              phoneNumber: contact.phoneNumber,
                              serviceName: serviceName,
                              isEmergency: contact.isNationalService ||
                                  contact.category == 'ambulance_medical' ||
                                  contact.category == 'disaster_safety',
                            );
                          },
                          icon: const Icon(Icons.call_rounded),
                          label: Text(
                            '${context.translate('call_now')} (${contact.phoneNumber})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Phone number unavailable state
                Container(
                  padding: const EdgeInsets.all(AppSizes.space16),
                  decoration: BoxDecoration(
                    color: AppColors.noticeAmber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                    border: Border.all(
                      color: AppColors.noticeAmber.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.phone_disabled_rounded,
                        color: AppColors.noticeAmber,
                        size: 28,
                      ),
                      const SizedBox(width: AppSizes.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.translate('call_unavailable_title'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.translate('em_call_unavailable_desc'),
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppSizes.space20),

              // --- 3. Service Purpose & Scope ---
              if (contact.purposeKey != null || contact.descriptionKey != null) ...[
                _buildSectionCard(
                  context,
                  title: context.translate('service_purpose_label'),
                  icon: Icons.info_outline_rounded,
                  iconColor: Colors.blue,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (contact.purposeKey != null)
                        Text(
                          context.translate(contact.purposeKey!),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      if (contact.purposeKey != null && contact.descriptionKey != null)
                        const SizedBox(height: AppSizes.space8),
                      if (contact.descriptionKey != null)
                        Text(
                          context.translate(contact.descriptionKey!),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.space12),
              ],

              // --- 4. Operating Hours & Availability ---
              if (contact.availabilityKey != null) ...[
                _buildSectionCard(
                  context,
                  title: context.translate('operating_hours_label'),
                  icon: Icons.access_time_rounded,
                  iconColor: Colors.green,
                  content: Text(
                    context.translate(contact.availabilityKey!),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.space12),
              ],

              // --- 5. Coverage Area & Address ---
              _buildSectionCard(
                context,
                title: context.translate('coverage_area_label'),
                icon: Icons.location_on_rounded,
                iconColor: Colors.orange,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (contact.coverageKey != null)
                      Text(
                        context.translate(contact.coverageKey!),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (contact.addressKey != null) ...[
                      const SizedBox(height: AppSizes.space4),
                      Text(
                        context.translate(contact.addressKey!),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSizes.space12),
                    OutlinedButton.icon(
                      onPressed: () => _onDirections(context),
                      icon: const Icon(Icons.directions_rounded, size: 18),
                      label: Text(
                        contact.addressKey != null
                            ? context.translate('get_directions')
                            : context.translate('emergency_directions_unavailable'),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.space12),

              // --- 6. Safe Alternative Guidance (Crucial when number pending) ---
              if (contact.safeAlternativeKey != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSizes.space16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline_rounded,
                            color: Colors.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.translate('emergency_safe_alt_label'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.space8),
                      Text(
                        context.translate(contact.safeAlternativeKey!),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.space12),
              ],

              // --- 7. Official Source & Verification Info ---
              _buildSectionCard(
                context,
                title: context.translate('source_info_label'),
                icon: Icons.verified_user_rounded,
                iconColor: AppColors.primaryLight,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (contact.sourceKey != null)
                      Text(
                        context.translate(contact.sourceKey!),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else if (contact.sourceName != null)
                      Text(
                        contact.sourceName!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (contact.lastVerifiedAt != null) ...[
                      const SizedBox(height: AppSizes.space4),
                      Text(
                        '${context.translate('last_verified_label')}: ${contact.lastVerifiedAt}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSizes.space8),
                    Text(
                      context.translate('call_reminder_desc'),
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.space24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget content,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2)
            : theme.colorScheme.surface,
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
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.space8),
          content,
        ],
      ),
    );
  }
}
