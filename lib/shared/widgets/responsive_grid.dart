import 'package:flutter/material.dart';
import '../../core/theme/app_sizes.dart';

/// Responsive Grid layout designed for displaying feature cards.
/// Dynamically updates cross-axis counts based on width bounds, maintaining readable card dimensions.
class ResponsiveFeatureGrid extends StatelessWidget {
  final List<Widget> children;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry padding;

  const ResponsiveFeatureGrid({
    super.key,
    required this.children,
    this.physics,
    this.shrinkWrap = false,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSizes.space16),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        
        // Calculate appropriate columns dynamically
        // Target card width is roughly 160-180dp
        int crossAxisCount = 2;
        if (width > 900) {
          crossAxisCount = 5;
        } else if (width > 600) {
          crossAxisCount = 3;
        }

        // Keep standard height proportions for grids (taller cards prevent overflows)
        final childAspectRatio = crossAxisCount == 2 ? 0.9 : 1.0;

        return GridView.builder(
          physics: physics,
          shrinkWrap: shrinkWrap,
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSizes.space12,
            mainAxisSpacing: AppSizes.space12,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}
