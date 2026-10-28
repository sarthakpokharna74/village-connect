import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/navigation/app_router.dart';
import '../../core/state/global_state.dart';
import '../../core/theme/app_sizes.dart';

/// Reusable authentication interceptor for protecting specific GramConnect features.
/// If user is authenticated, executes action directly.
/// If user is guest, pops a warning dialog and prompts to login/cancel.
class AuthGuard {
  AuthGuard._();

  /// Intercepts a user action and prompts for login if guest.
  /// Executes [onAuthenticated] immediately if user is already logged in.
  static void run(
    BuildContext context, {
    required String explanationKey,
    required VoidCallback onAuthenticated,
  }) async {
    final state = GramConnectStateProvider.of(context);

    if (state.isLoggedIn) {
      onAuthenticated();
      return;
    }

    // Explain why login is required and provide action buttons
    showDialog(
      context: context,
      builder: (dialogCtx) {
        final theme = Theme.of(dialogCtx);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          ),
          title: Row(
            children: [
              Icon(Icons.lock_outline, color: theme.colorScheme.secondary),
              const SizedBox(width: AppSizes.space12),
              Text(dialogCtx.translate('login_required')),
            ],
          ),
          content: Text(dialogCtx.translate(explanationKey)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(dialogCtx.translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogCtx); // Close the dialog
                // Navigate to Login screen and await result
                final success = await Navigator.of(context).pushNamed(AppRouter.login);
                if (!context.mounted) return;
                
                if (success == true) {
                  state.updateLoginState(true);
                  // Action completed successfully upon login
                  onAuthenticated();
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(120, AppSizes.touchTargetMin),
              ),
              child: Text(dialogCtx.translate('login')),
            ),
          ],
        );
      },
    );
  }
}
