import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_sizes.dart';

/// Branded premium AppBar for GramConnect.
/// Includes an integrated language switcher and user login/profile access status.
class GramAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChanged;
  final bool isLoggedIn;
  final VoidCallback onProfileTap;
  final String title;
  final bool showBackButton;

  const GramAppBar({
    super.key,
    required this.currentLocale,
    required this.onLocaleChanged,
    required this.isLoggedIn,
    required this.onProfileTap,
    this.title = 'GramConnect',
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      elevation: 2.0,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
      backgroundColor: isDark ? theme.colorScheme.surface : theme.colorScheme.primary,
      foregroundColor: isDark ? theme.colorScheme.onSurface : theme.colorScheme.onPrimary,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            )
          : Padding(
              padding: const EdgeInsets.only(left: AppSizes.space12),
              child: Icon(
                Icons.grid_view_rounded,
                color: isDark ? theme.colorScheme.primary : theme.colorScheme.onPrimary,
                size: AppSizes.iconMD,
              ),
            ),
      leadingWidth: showBackButton ? 56.0 : 40.0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? theme.colorScheme.onSurface : theme.colorScheme.onPrimary,
            ),
          ),
          Text(
            context.translate('tagline'),
            style: theme.textTheme.labelMedium?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: isDark 
                  ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8)
                  : theme.colorScheme.onPrimary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
      actions: [
        // Language Dropdown Selector
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.space8),
            decoration: BoxDecoration(
              color: isDark 
                  ? theme.colorScheme.surfaceContainerHighest 
                  : theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusSM),
              border: Border.all(
                color: isDark 
                    ? theme.colorScheme.outline.withValues(alpha: 0.5)
                    : theme.colorScheme.onPrimary.withValues(alpha: 0.3),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currentLocale.languageCode,
                icon: Icon(
                  Icons.translate_rounded,
                  size: 16,
                  color: isDark ? theme.colorScheme.onSurface : theme.colorScheme.onPrimary,
                ),
                dropdownColor: theme.colorScheme.surface,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                onChanged: (langCode) {
                  if (langCode != null) {
                    onLocaleChanged(Locale(langCode, ''));
                  }
                },
                items: const [
                  DropdownMenuItem(
                    value: 'en',
                    child: Text(' EN '),
                  ),
                  DropdownMenuItem(
                    value: 'mr',
                    child: Text(' मराठी '),
                  ),
                  DropdownMenuItem(
                    value: 'hi',
                    child: Text(' हिंदी '),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(width: AppSizes.space8),

        // User Login / Profile Button
        IconButton(
          onPressed: onProfileTap,
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                isLoggedIn ? Icons.account_circle : Icons.account_circle_outlined,
                size: AppSizes.iconLG,
                color: isDark ? theme.colorScheme.onSurface : theme.colorScheme.onPrimary,
              ),
              if (isLoggedIn)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? theme.colorScheme.surface : theme.colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          tooltip: isLoggedIn ? context.translate('profile') : context.translate('login'),
        ),
        const SizedBox(width: AppSizes.space8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
