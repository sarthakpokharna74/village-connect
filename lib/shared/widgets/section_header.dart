import 'package:flutter/material.dart';
import '../../core/theme/app_sizes.dart';

/// Reusable header for sections.
/// Includes a bold title, an organic vertical indicator strip for visual anchoring,
/// and an optional action widget (like a "View All" button).
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.space16,
        vertical: AppSizes.space12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Vertical anchor bar (premium detail)
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(AppSizes.radiusXS),
            ),
          ),
          const SizedBox(width: AppSizes.space12),
          
          // Header Text details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSizes.space4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          if (trailing != null) ...[
            const SizedBox(width: AppSizes.space8),
            trailing!,
          ],
        ],
      ),
    );
  }
}
