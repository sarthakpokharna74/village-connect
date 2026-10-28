import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_sizes.dart';

/// Reusable loading state widget.
/// Shows a centered, branded circular progress indicator with helpful localized status text.
class LoadingState extends StatelessWidget {
  final String? message;

  const LoadingState({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator.adaptive(
              strokeWidth: 3.5,
            ),
            const SizedBox(height: AppSizes.space16),
            Text(
              message ?? context.translate('loading'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable empty state widget.
/// Displayed when lists or queries return no values. Contains a large icon, title, and optional description.
class EmptyState extends StatelessWidget {
  final String? title;
  final String? description;
  final IconData icon;

  const EmptyState({
    super.key,
    this.title,
    this.description,
    this.icon = Icons.folder_open_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.space32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppSizes.iconXL * 1.5,
              color: theme.colorScheme.outline.withValues(alpha: 0.6),
            ),
            const SizedBox(height: AppSizes.space16),
            Text(
              title ?? context.translate('empty_state'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: AppSizes.space8),
              Text(
                description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Reusable error state widget.
/// Informs the user when an action fails, offering an accessibility-compliant "Retry" button.
class ErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;
  final String? retryLabel;

  const ErrorState({
    super.key,
    this.message,
    required this.onRetry,
    this.retryLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: AppSizes.iconXL * 1.3,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: AppSizes.space16),
            Text(
              context.translate('error_occured'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.space8),
            Text(
              message ?? context.translate('error_loading'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.space24),
            // Clean, high-contrast, large touch-target button
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: AppSizes.iconMD),
              label: Text(retryLabel ?? context.translate('retry')),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                minimumSize: const Size(160, AppSizes.btnHeightLarge),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.space24,
                  vertical: AppSizes.space12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
