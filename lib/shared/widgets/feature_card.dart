import 'package:flutter/material.dart';
import '../../core/theme/app_sizes.dart';

/// Premium, responsive 2-column feature grid card.
/// Includes an interactive scale-down micro-animation on press, large touch targets,
/// clear typography, and a modern Material 3 flat-container style.
class FeatureCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedScale(
      scale: _isPressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOutCubic,
      child: Card(
        // Allow tap events to bubble through properly
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          splashColor: widget.accentColor.withValues(alpha: 0.08),
          highlightColor: widget.accentColor.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.space12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon wrapper with premium tinted circle container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: widget.accentColor.withValues(alpha: isDark ? 0.2 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      widget.icon,
                      size: AppSizes.iconMD,
                      color: isDark 
                          ? Color.lerp(widget.accentColor, Colors.white, 0.3) 
                          : widget.accentColor,
                    ),
                  ),
                ),
                
                const SizedBox(height: AppSizes.space8),

                // Text detail section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSizes.space4),
                    Text(
                      widget.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12.0,
                        height: 1.3,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
