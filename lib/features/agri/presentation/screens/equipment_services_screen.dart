import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../data/models/agri_models.dart';
import '../../data/repositories/agri_repository.dart';

/// Farming Equipment & Machinery Services Screen for Dhawalpuri.
class EquipmentServicesScreen extends StatefulWidget {
  const EquipmentServicesScreen({super.key});

  @override
  State<EquipmentServicesScreen> createState() => _EquipmentServicesScreenState();
}

class _EquipmentServicesScreenState extends State<EquipmentServicesScreen> {
  final _repository = MockAgriRepository();
  List<EquipmentServiceItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEquipment();
  }

  Future<void> _loadEquipment() async {
    final list = await _repository.getEquipmentServices();
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
          context.translate('cat_agri_equipment_services'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                                color: AppColors.infoBlue.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.precision_manufacturing_rounded, color: AppColors.infoBlue, size: 20),
                            ),
                            const SizedBox(width: AppSizes.space12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    item.category,
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
                        Text(
                          item.description,
                          style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                        ),
                        const SizedBox(height: AppSizes.space12),
                        Container(
                          padding: const EdgeInsets.all(AppSizes.space8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primaryLight),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  item.availabilityNotice,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSizes.space12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.sourceName,
                              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.open_in_new_rounded, size: 14),
                              label: const Text('Guidelines'),
                              onPressed: () => _launchUrl(item.officialSchemeUrl),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
