import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../data/models/agri_models.dart';
import '../../data/repositories/agri_repository.dart';

/// Farmer Resources & Helplines Screen.
/// Provides verified phone calls only for verified numbers (e.g. Kisan Call Centre),
/// without fabricating local officer phone numbers.
class FarmerContactsScreen extends StatefulWidget {
  const FarmerContactsScreen({super.key});

  @override
  State<FarmerContactsScreen> createState() => _FarmerContactsScreenState();
}

class _FarmerContactsScreenState extends State<FarmerContactsScreen> {
  final _repository = MockAgriRepository();
  List<FarmerContactItem> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final list = await _repository.getFarmerContacts();
    if (mounted) {
      setState(() {
        _contacts = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _makeCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWebsite(String url) async {
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
          context.translate('cat_agri_farmer_contacts'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(AppSizes.space16),
              itemCount: _contacts.length,
              separatorBuilder: (ctx, idx) => const SizedBox(height: AppSizes.space16),
              itemBuilder: (ctx, idx) {
                final contact = _contacts[idx];
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSizes.space8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.support_agent_rounded, color: AppColors.primaryLight, size: 22),
                            ),
                            const SizedBox(width: AppSizes.space12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    contact.title,
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    contact.designation,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.primaryLight,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    contact.department,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.space12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16, color: AppColors.agriBrown),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                contact.address,
                                style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.space16),

                        // Action Buttons
                        Row(
                          children: [
                            if (contact.canCall)
                              FilledButton.icon(
                                icon: const Icon(Icons.call_rounded, size: 16),
                                label: Text(context.translate('direct_call')),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primaryLight,
                                ),
                                onPressed: () => _makeCall(contact.phoneNumber!),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.phone_locked_rounded, size: 14, color: AppColors.noticeAmber),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Phone Pending Verification',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const Spacer(),
                            if (contact.websiteUrl != null)
                              OutlinedButton.icon(
                                icon: const Icon(Icons.language_rounded, size: 16),
                                label: const Text('Portal'),
                                onPressed: () => _launchWebsite(contact.websiteUrl!),
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
