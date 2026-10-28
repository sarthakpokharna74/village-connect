import 'package:flutter/material.dart';
import 'package:gram_connect/core/localization/app_localizations.dart';
import 'package:gram_connect/core/theme/app_sizes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_share_service.dart';

/// Reusable utility for web safety and official government link navigation (Blueprint 7).
/// Ensures users are explicitly aware they are navigating to external government portals,
/// displays destination domains, and protects privacy by reminding users that GramConnect
/// never asks for government passwords, OTPs, or payments.
class OfficialLinkLauncher {
  OfficialLinkLauncher._();

  /// Confirms and launches an official government URL in an external browser.
  static Future<void> launchOfficialPortal(
    BuildContext context, {
    required String? url,
    required String serviceName,
  }) async {
    if (url == null || url.trim().isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.translate('gov_portal_unavailable')),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final cleanUrl = url.trim();
    Uri? uri;
    try {
      uri = Uri.parse(cleanUrl);
      if (!uri.hasScheme || (uri.scheme != 'https' && uri.scheme != 'http')) {
        uri = Uri.parse('https://$cleanUrl');
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.translate('gov_portal_unavailable')),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final domain = uri.host.isNotEmpty ? uri.host : cleanUrl;

    if (!context.mounted) return;

    // Show explicit external safety confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.space8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.open_in_browser_rounded,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: AppSizes.iconMD,
                ),
              ),
              const SizedBox(width: AppSizes.space12),
              Expanded(
                child: Text(
                  dialogContext.translate('gov_external_link_warning_title'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dialogContext.translate('gov_external_link_warning_text'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSizes.space16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.space12,
                  vertical: AppSizes.space8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dialogContext.translate('gov_destination_domain'),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.verified_outlined,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            domain,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(dialogContext.translate('cancel')),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.launch_rounded, size: 16),
              label: Text(dialogContext.translate('gov_proceed_to_portal')),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched) {
          // Fallback to in-app or platform default if external app mode returned false
          await launchUrl(uri);
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.translate('error_loading')),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  /// Copies verified service information and official portal link to clipboard for sharing.
  static Future<void> shareServiceInfo(
    BuildContext context, {
    required String serviceName,
    required String? officialUrl,
    required String department,
  }) async {
    final buffer = StringBuffer();
    buffer.writeln(serviceName);
    buffer.writeln('Department: $department');
    if (officialUrl != null && officialUrl.isNotEmpty) {
      buffer.writeln('Official Portal: $officialUrl');
    }
    buffer.writeln('GramConnect — Dhawalpuri Community Directory');

    await AppShareService.share(
      context: context,
      text: buffer.toString(),
      subject: serviceName,
      successMessageKey: 'gov_share_success',
    );
  }
}
