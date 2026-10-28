import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../data/models/agri_models.dart';
import '../../data/repositories/agri_repository.dart';
import '../../data/services/agri_bookmarks_manager.dart';
import 'crop_detail_screen.dart';
import 'agri_scheme_detail_screen.dart';

/// Screen displaying all bookmarked agricultural resources.
class SavedAgriScreen extends StatelessWidget {
  const SavedAgriScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookmarksManager = AgriBookmarksManager();
    final repository = MockAgriRepository();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.translate('saved_agri_resources'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ValueListenableBuilder<List<String>>(
        valueListenable: bookmarksManager.bookmarksNotifier,
        builder: (ctx, savedIds, _) {
          if (savedIds.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.space32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSizes.space20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.bookmark_border_rounded,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: AppSizes.space20),
                    Text(
                      context.translate('no_saved_agri'),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.space8),
                    Text(
                      context.translate('no_saved_agri_desc'),
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return FutureBuilder<List<dynamic>>(
            future: Future.wait([
              repository.getCrops(),
              repository.getAgriSchemes(),
            ]),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final allCrops = (snapshot.data?[0] as List<CropItem>?) ?? [];
              final allSchemes = (snapshot.data?[1] as List<AgriScheme>?) ?? [];

              final savedCrops = allCrops.where((c) => savedIds.contains(c.id)).toList();
              final savedSchemes = allSchemes.where((s) => savedIds.contains(s.id)).toList();

              return ListView(
                padding: const EdgeInsets.all(AppSizes.space16),
                children: [
                  if (savedCrops.isNotEmpty) ...[
                    Text(
                      context.translate('cat_agri_crop_info'),
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSizes.space8),
                    ...savedCrops.map((crop) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.space12),
                        child: Card(
                          elevation: 0.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                            side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.grass_rounded, color: AppColors.primaryLight),
                            title: Text(
                              context.translate(crop.nameKey),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              context.translate(crop.descKey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.bookmark_remove_rounded, color: AppColors.secondaryLight),
                              onPressed: () => bookmarksManager.removeBookmark(crop.id),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (ctx) => CropDetailScreen(crop: crop)),
                              );
                            },
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: AppSizes.space16),
                  ],
                  if (savedSchemes.isNotEmpty) ...[
                    Text(
                      context.translate('cat_agri_schemes'),
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSizes.space8),
                    ...savedSchemes.map((scheme) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.space12),
                        child: Card(
                          elevation: 0.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                            side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.account_balance_rounded, color: AppColors.primaryLight),
                            title: Text(
                              scheme.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              scheme.purpose,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.bookmark_remove_rounded, color: AppColors.secondaryLight),
                              onPressed: () => bookmarksManager.removeBookmark(scheme.id),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (ctx) => AgriSchemeDetailScreen(scheme: scheme)),
                              );
                            },
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}
