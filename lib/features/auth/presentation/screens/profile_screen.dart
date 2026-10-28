import 'package:flutter/material.dart';
import 'package:gram_connect/core/localization/app_localizations.dart';
import 'package:gram_connect/core/theme/app_sizes.dart';
import 'package:gram_connect/core/state/global_state.dart';
import 'package:gram_connect/features/auth/data/models/user_model.dart';
import 'package:gram_connect/features/auth/data/repositories/auth_repository.dart';
import 'package:gram_connect/core/navigation/app_router.dart';

/// Villager Profile and Digital Identity Status Screen for GramConnect V1.
/// Displays logged-in villager credentials, verification tags, and manages logout actions.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = GramConnectStateProvider.of(context);
    final user = state.currentUser ?? UserProfile.mockUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate('profile')),
        backgroundColor: isDark ? theme.colorScheme.surface : theme.colorScheme.primary,
        foregroundColor: isDark ? theme.colorScheme.onSurface : theme.colorScheme.onPrimary,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: SafeArea(
        child: !state.isLoggedIn
            ? Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.space24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSizes.space20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.account_circle_outlined,
                          size: 80,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.space24),
                      Text(
                        context.translate('login_to_access_profile'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSizes.space8),
                      Text(
                        context.translate('login_desc'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSizes.space32),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final success = await Navigator.of(context).pushNamed(AppRouter.login);
                          if (context.mounted && success == true) {
                            state.updateLoginState(true);
                          }
                        },
                        icon: const Icon(Icons.login_rounded),
                        label: Text(context.translate('login')),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(200, AppSizes.touchTargetMin),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- 1. Circular Avatar + General Info ---
                    Card(
                      elevation: 0.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                        side: BorderSide(
                          color: theme.colorScheme.outline.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.space20),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                              child: Text(
                                user.fullName.trim().split(' ').where((e) => e.isNotEmpty).map((e) => e[0]).take(2).join(),
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSizes.space16),
                            Text(
                              user.fullName,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSizes.space4),
                            Text(
                              user.villageName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.space16),

                    // --- 2. Contact Details ---
                    Text(
                      context.translate('profile'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space8),
                    Card(
                      elevation: 0.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                        side: BorderSide(
                          color: theme.colorScheme.outline.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildInfoTile(
                            context,
                            Icons.phone_rounded,
                            context.translate('phone_label'),
                            user.phoneNumber,
                          ),
                          const Divider(height: 1),
                          _buildInfoTile(
                            context,
                            Icons.location_city_rounded,
                            context.translate('village_label'),
                            user.villageName,
                          ),
                          if (user.wardOrGalli != null && user.wardOrGalli!.isNotEmpty) ...[
                            const Divider(height: 1),
                            _buildInfoTile(
                              context,
                              Icons.home_work_rounded,
                              'Ward / Galli',
                              user.wardOrGalli!,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.space20),

                    // --- 3. Digital Village Identity Box ---
                    Text(
                      context.translate('digital_id_title'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space8),
                    Card(
                      elevation: 0.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                        side: BorderSide(
                          color: theme.colorScheme.outline.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.space16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Status Badge Indicator
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  context.translate('id_status_label'),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: user.digitalIdStatus == 'verified'
                                        ? Colors.green.withValues(alpha: 0.15)
                                        : Colors.amber.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                                    border: Border.all(
                                      color: user.digitalIdStatus == 'verified'
                                          ? Colors.green[800]!
                                          : Colors.amber[800]!,
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    user.digitalIdStatus == 'verified'
                                        ? context.translate('ev_verified')
                                        : context.translate('status_pending'),
                                    style: TextStyle(
                                      color: user.digitalIdStatus == 'verified'
                                          ? Colors.green[900]!
                                          : Colors.amber[900]!,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.space12),

                            // Code Parameter
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  context.translate('id_code_label'),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  user.digitalIdCode,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Courier', // code format font
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.space16),
                            const Divider(height: 1),
                            const SizedBox(height: AppSizes.space12),

                            // Explanatory warning note (not official government ID)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.shield_outlined, color: theme.colorScheme.primary, size: 18),
                                const SizedBox(width: AppSizes.space8),
                                Expanded(
                                  child: Text(
                                    context.translate('profile_warning'),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      height: 1.35,
                                      fontSize: 11.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.space32),

                    // --- 4. Log out Action Button ---
                    ElevatedButton.icon(
                      onPressed: () => _confirmLogout(context, state),
                      icon: const Icon(Icons.logout_rounded),
                      label: Text(
                        context.translate('logout_btn'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, AppSizes.touchTargetMin),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16, vertical: AppSizes.space12),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary.withValues(alpha: 0.7), size: 20),
          const SizedBox(width: AppSizes.space16),
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
      ),
    );
  }

  void _confirmLogout(BuildContext context, GramConnectStateProvider state) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          ),
          title: Row(
            children: [
              Icon(Icons.logout_rounded, color: theme.colorScheme.error),
              const SizedBox(width: AppSizes.space12),
              Text(context.translate('logout_btn')),
            ],
          ),
          content: Text(context.translate('logout_confirm')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Pop dialog
                await LocalAuthRepository().logout();
                if (state.updateUserSession != null) {
                  state.updateUserSession!(null, false);
                } else {
                  state.updateLoginState(false);
                }
                if (context.mounted) {
                  Navigator.pop(context); // Return back to Home
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.translate('logout_btn')),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: Colors.white,
                minimumSize: const Size(120, AppSizes.touchTargetMin),
              ),
              child: Text(context.translate('logout_btn')),
            ),
          ],
        );
      },
    );
  }
}
