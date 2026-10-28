import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/calendar_service.dart';
import '../../data/models/event_model.dart';

/// Detailed Village Event Screen for GramConnect (Blueprint 8).
/// Displays verified event details, category metadata, real-time lifecycle status,
/// verified location directions, and actions to share or add to calendar.
class EventDetailsScreen extends StatelessWidget {
  final VillageEvent event;

  const EventDetailsScreen({
    super.key,
    required this.event,
  });

  Future<void> _handleGetDirections(BuildContext context) async {
    if (event.latitude != null && event.longitude != null) {
      final mapUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${event.latitude},${event.longitude}',
      );
      try {
        if (await canLaunchUrl(mapUri)) {
          await launchUrl(mapUri, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (_) {}
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
              const SizedBox(width: AppSizes.space8),
              Expanded(
                child: Text(context.translate('event_directions_unavailable')),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final status = event.computedStatus;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate('event_details')),
        backgroundColor: isDark ? theme.colorScheme.surface : theme.colorScheme.primary,
        foregroundColor: isDark ? theme.colorScheme.onSurface : theme.colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: context.translate('event_share'),
            onPressed: () => CalendarService.shareEvent(context, event),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. Visual Category Header Banner ---
            Container(
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    event.color.withValues(alpha: 0.85),
                    event.color.withValues(alpha: 0.55),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Hero(
                  tag: 'event_icon_${event.id}',
                  child: Icon(
                    event.icon,
                    size: 68,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSizes.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- 2. Category & Status Badges Row ---
                  Wrap(
                    spacing: AppSizes.space8,
                    runSpacing: AppSizes.space8,
                    children: [
                      // Category Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: event.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                          border: Border.all(
                            color: event.color.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(event.icon, size: 14, color: event.color),
                            const SizedBox(width: 6),
                            Text(
                              context.translate('cat_ev_${event.category}').toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: event.color,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: status.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                          border: Border.all(
                            color: status.color.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(status.icon, size: 14, color: status.color),
                            const SizedBox(width: 6),
                            Text(
                              context.translate(status.translationKey),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: status.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.space12),

                  // --- 3. Event Title ---
                  Text(
                    context.translate(event.titleKey),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space16),

                  // --- 4. Timeline Card (Date, Time, Venue, Address, Organizer) ---
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                      side: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.space16),
                      child: Column(
                        children: [
                          _buildTimelineRow(
                            context,
                            Icons.calendar_month_rounded,
                            context.translate('event_date'),
                            event.dateKey,
                            event.color,
                          ),
                          const Divider(height: AppSizes.space20),
                          _buildTimelineRow(
                            context,
                            Icons.access_time_rounded,
                            context.translate('event_time'),
                            event.timeKey,
                            event.color,
                          ),
                          const Divider(height: AppSizes.space20),
                          _buildTimelineRow(
                            context,
                            Icons.location_on_rounded,
                            context.translate('event_venue'),
                            context.translate(event.venueKey),
                            event.color,
                          ),
                          if (event.address != null && event.address!.isNotEmpty) ...[
                            const Divider(height: AppSizes.space20),
                            _buildTimelineRow(
                              context,
                              Icons.home_work_outlined,
                              context.translate('event_address'),
                              event.address!,
                              event.color,
                            ),
                          ],
                          if (event.organizerKey != null) ...[
                            const Divider(height: AppSizes.space20),
                            _buildTimelineRow(
                              context,
                              Icons.groups_outlined,
                              context.translate('event_organizer'),
                              context.translate(event.organizerKey!),
                              event.color,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.space16),

                  // --- 5. Quick Actions: Add to Calendar & Directions ---
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.add_alert_rounded, size: 18),
                          label: Text(
                            context.translate('add_to_calendar'),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          onPressed: () => CalendarService.addToDeviceCalendar(context, event),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.space12),
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.directions_rounded, size: 18),
                          label: Text(
                            context.translate('event_directions'),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          onPressed: () => _handleGetDirections(context),
                          style: FilledButton.styleFrom(
                            backgroundColor: event.color,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.space24),

                  // --- 6. Description Section ---
                  Text(
                    context.translate('event_description'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space8),
                  Text(
                    context.translate(event.descriptionKey),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space20),

                  // --- 7. Instructions Card (if available) ---
                  if (event.instructionsKey != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSizes.space16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                        border: Border.all(
                          color: theme.colorScheme.tertiary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.assignment_outlined,
                                size: 18,
                                color: theme.colorScheme.tertiary,
                              ),
                              const SizedBox(width: AppSizes.space8),
                              Text(
                                context.translate('event_instructions'),
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.tertiary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.space8),
                          Text(
                            context.translate(event.instructionsKey!),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.4,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.space20),
                  ],

                  // --- 8. Contact Information (if available) ---
                  if (event.contactInformation != null && event.contactInformation!.isNotEmpty) ...[
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                        side: BorderSide(
                          color: theme.colorScheme.outline.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.space16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSizes.space8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.phone_rounded,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: AppSizes.space12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.translate('event_contact_info'),
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    event.contactInformation!,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.space20),
                  ],

                  // --- 9. Source & Verification Badge ---
                  Container(
                    padding: const EdgeInsets.all(AppSizes.space12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 18,
                          color: event.verificationStatus.color,
                        ),
                        const SizedBox(width: AppSizes.space8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${context.translate('event_source')}: ${event.sourceName ?? 'GramConnect Village Record'}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                context.translate(event.verificationStatus.translationKey),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: event.verificationStatus.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.space32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: AppSizes.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
