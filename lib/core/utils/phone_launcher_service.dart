import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';

/// Safe Phone Launcher Service for GramConnect
/// Opens the device dialer with user confirmation. Never makes silent calls.
class PhoneLauncherService {
  /// Confirms with the user (displaying the genuine emergency notice) and opens the device dialer.
  static Future<void> confirmAndLaunchDialer(
    BuildContext context, {
    required String? phoneNumber,
    required String serviceName,
    bool isEmergency = false,
  }) async {
    // Guard: Missing or empty phone number
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.phone_disabled_rounded,
                  color: AppColors.noticeAmber, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ctx.translate('call_unavailable_title'),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Text(
            ctx.translate('em_call_unavailable_desc'),
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(ctx.translate('close')),
            ),
          ],
        ),
      );
      return;
    }

    final cleanNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');

    // Show Confirmation Modal before launching dialer
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isEmergency
                  ? Icons.warning_amber_rounded
                  : Icons.phone_forwarded_rounded,
              color: isEmergency ? AppColors.emergencyRed : AppColors.primaryLight,
              size: 26,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                ctx.translate('call_reminder_title'),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ctx.translate('call_reminder_desc'),
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(ctx).brightness == Brightness.dark
                    ? Colors.white10
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isEmergency
                      ? AppColors.emergencyRed.withValues(alpha: 0.3)
                      : AppColors.primaryLight.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.phone_rounded,
                    color: isEmergency
                        ? AppColors.emergencyRed
                        : AppColors.primaryLight,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          phoneNumber,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                            color: isEmergency
                                ? AppColors.emergencyRed
                                : AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.translate('cancel')),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: isEmergency
                  ? AppColors.emergencyRed
                  : AppColors.primaryLight,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.call_rounded, size: 18),
            label: Text(ctx.translate('call_action_dial')),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final dialerError = context.translate('dialer_error');
    final shareSuccess = context.translate('share_contact_success');

    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanNumber,
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback if device dialer is not accessible (e.g. tablet/desktop)
        await Clipboard.setData(ClipboardData(text: cleanNumber));
        messenger.showSnackBar(
          SnackBar(
            content: Text('$dialerError $phoneNumber. $shareSuccess'),
            backgroundColor: AppColors.noticeAmber,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: cleanNumber));
      messenger.showSnackBar(
        SnackBar(
          content: Text('$dialerError $phoneNumber. $shareSuccess'),
          backgroundColor: AppColors.emergencyRed,
        ),
      );
    }
  }
}
