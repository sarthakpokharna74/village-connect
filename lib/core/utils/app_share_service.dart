import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../localization/app_localizations.dart';

/// Centralized utility for real-time native operating system sharing.
/// Opens native Android share sheet (WhatsApp, Messages, Email, etc.)
/// with automatic clipboard fallback.
class AppShareService {
  AppShareService._();

  /// Shares [text] via the native OS share sheet.
  /// If sharing fails or is cancelled, falls back to copying to clipboard.
  static Future<void> share({
    required BuildContext context,
    required String text,
    String? subject,
    String? successMessageKey,
  }) async {
    try {
      final result = await Share.share(
        text,
        subject: subject,
      );

      // On mobile platforms where share sheet opens, if user copies or shares,
      // Provide positive feedback if context is still active
      if (context.mounted && result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              successMessageKey != null 
                  ? context.translate(successMessageKey) 
                  : context.translate('share_success'),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      // Safe fallback to system clipboard
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              successMessageKey != null 
                  ? context.translate(successMessageKey) 
                  : context.translate('share_success'),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
