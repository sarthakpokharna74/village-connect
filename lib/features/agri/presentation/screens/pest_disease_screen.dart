import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../data/models/agri_models.dart';
import '../../data/repositories/agri_repository.dart';

/// Pest & Disease Educational Directory for Dhawalpuri farmers.
class PestDiseaseScreen extends StatefulWidget {
  const PestDiseaseScreen({super.key});

  @override
  State<PestDiseaseScreen> createState() => _PestDiseaseScreenState();
}

class _PestDiseaseScreenState extends State<PestDiseaseScreen> {
  final _repository = MockAgriRepository();
  final _searchController = TextEditingController();
  List<PestDiseaseItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPests();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPests() async {
    setState(() => _isLoading = true);
    final list = await _repository.getPestsAndDiseases(query: _searchController.text.trim());
    if (mounted) {
      setState(() {
        _items = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.translate('cat_agri_pest_disease'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.all(AppSizes.space16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search pest by name or crop...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          _loadPests();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
              onChanged: (_) => _loadPests(),
            ),
          ),

          // Educational Disclaimer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
            child: Container(
              padding: const EdgeInsets.all(AppSizes.space12),
              decoration: BoxDecoration(
                color: AppColors.emergencyRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                border: Border.all(color: AppColors.emergencyRed.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined, size: 18, color: AppColors.emergencyRed),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Educational guide only. For exact chemical dosages, always consult qualified agronomic extension officers at Parner Agriculture Office or MPKV Rahuri.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.space8),

          // Pests List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.space32),
                          child: Text(context.translate('no_agri_found')),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppSizes.space16),
                        itemCount: _items.length,
                        separatorBuilder: (ctx, idx) => const SizedBox(height: AppSizes.space16),
                        itemBuilder: (ctx, idx) {
                          final item = _items[idx];
                          return Card(
                            elevation: 0.5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                              side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSizes.space16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(AppSizes.space8),
                                        decoration: BoxDecoration(
                                          color: AppColors.emergencyRed.withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.pest_control_rounded, color: AppColors.emergencyRed, size: 20),
                                      ),
                                      const SizedBox(width: AppSizes.space12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name,
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Affected Crops: ${item.affectedCrops}',
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: AppColors.primaryLight,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSizes.space12),

                                  // Symptoms
                                  Text(
                                    'Symptoms:',
                                    style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.symptoms,
                                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                                  ),
                                  const SizedBox(height: AppSizes.space8),

                                  // Prevention & Management
                                  Text(
                                    'Non-Chemical & Cultural Prevention:',
                                    style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryLight),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.prevention,
                                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                                  ),
                                  const SizedBox(height: AppSizes.space8),

                                  // Recommended Steps
                                  Text(
                                    'Recommended Action:',
                                    style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.noticeAmber),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.recommendedSteps,
                                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                                  ),
                                  const SizedBox(height: AppSizes.space12),

                                  // Source
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Source: ${item.sourceName}',
                                        style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                      ),
                                      InkWell(
                                        onTap: () => _launchUrl(item.sourceUrl),
                                        child: const Row(
                                          children: [
                                            Text(
                                              'Open Source',
                                              style: TextStyle(color: AppColors.infoBlue, fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(width: 2),
                                            Icon(Icons.open_in_new_rounded, size: 14, color: AppColors.infoBlue),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
