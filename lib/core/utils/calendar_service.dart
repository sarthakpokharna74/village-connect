import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../localization/app_localizations.dart';
import '../theme/app_sizes.dart';
import '../../features/events/data/models/event_model.dart';
import 'app_share_service.dart';

/// Reusable utility service for Village Event Calendar integration and sharing (Blueprint 8).
/// Provides clean, lightweight calendar creation without heavy external dependencies,
/// ensuring genuine actions without falsely claiming native hardware calendar write success.
class CalendarService {
  CalendarService._();

  /// Formats event details and allows adding to device/web calendar or clipboard.
  static Future<void> addToDeviceCalendar(
    BuildContext context,
    VillageEvent event,
  ) async {
    final title = context.translate(event.titleKey);
    final venue = context.translate(event.venueKey);
    final desc = context.translate(event.descriptionKey);

    final s = event.startDateTime;
    final e = event.endDateTime ?? s.add(const Duration(hours: 2));

    // Format UTC timestamps for web calendar template: YYYYMMDDTHHMMSSZ
    final startUtc = s.toUtc();
    final endUtc = e.toUtc();
    final startStr = '${startUtc.year}${_pad2(startUtc.month)}${_pad2(startUtc.day)}T${_pad2(startUtc.hour)}${_pad2(startUtc.minute)}00Z';
    final endStr = '${endUtc.year}${_pad2(endUtc.month)}${_pad2(endUtc.day)}T${_pad2(endUtc.hour)}${_pad2(endUtc.minute)}00Z';

    final fullSummary = '''
$title
${context.translate('event_date')}: ${event.dateKey}
${context.translate('event_time')}: ${event.timeKey}
${context.translate('event_venue')}: $venue ${event.address != null ? '(${event.address})' : ''}
${context.translate('event_description')}: $desc
— GramConnect Dhawalpuri (ढवळपुरी)
'''.trim();

    // Copy formatted details to clipboard immediately
    await Clipboard.setData(ClipboardData(text: fullSummary));

    if (!context.mounted) return;

    final theme = Theme.of(context);

    // Show dialog with options: Open Google/Web Calendar or Keep Copied
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Icon(Icons.event_note_rounded, color: theme.colorScheme.primary, size: 36),
          title: Text(
            context.translate('add_to_calendar'),
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.translate('event_add_calendar_desc'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSizes.space12),
              Container(
                padding: const EdgeInsets.all(AppSizes.space12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${event.dateKey} • ${event.timeKey}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      venue,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.translate('close')),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: Text(context.translate('open_google_calendar')),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final uri = Uri.parse(
                  'https://calendar.google.com/calendar/render?action=TEMPLATE'
                  '&text=${Uri.encodeComponent(title)}'
                  '&dates=$startStr/$endStr'
                  '&details=${Uri.encodeComponent(desc)}'
                  '&location=${Uri.encodeComponent(venue)}',
                );

                try {
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.translate('copied_to_clipboard')),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.translate('copied_to_clipboard')),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// Formats public event information and copies to clipboard for sharing via any messenger.
  static Future<void> shareEvent(
    BuildContext context,
    VillageEvent event,
  ) async {
    final title = context.translate(event.titleKey);
    final venue = context.translate(event.venueKey);
    final desc = context.translate(event.descriptionKey);

    final sb = StringBuffer();
    sb.writeln('📅 *$title*');
    sb.writeln('🗓️ ${context.translate('event_date')}: ${event.dateKey}');
    sb.writeln('⏰ ${context.translate('event_time')}: ${event.timeKey}');
    sb.writeln('📍 ${context.translate('event_venue')}: $venue');
    if (event.address != null && event.address!.isNotEmpty) {
      sb.writeln('🏠 ${event.address}');
    }
    sb.writeln();
    sb.writeln('📝 $desc');
    if (event.eventUrl != null && event.eventUrl!.isNotEmpty) {
      sb.writeln();
      sb.writeln('🔗 ${event.eventUrl}');
    }
    sb.writeln();
    sb.writeln('— GramConnect: Dhawalpuri (ढवळपुरी), Parner, Ahilyanagar');

    final shareText = sb.toString();
    await AppShareService.share(
      context: context,
      text: shareText,
      subject: title,
      successMessageKey: 'event_share_copied',
    );
  }

  static String _pad2(int n) => n.toString().padLeft(2, '0');
}
