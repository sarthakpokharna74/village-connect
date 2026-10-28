import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';

/// Market Rates (APMC) Screen.
/// Prepared for live mandi data integration; currently provides transparent standby notice
/// and verified direct links to official MSAMB and Agmarknet portals for Parner and Ahilyanagar APMCs.
class MarketPricesScreen extends StatelessWidget {
  const MarketPricesScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      try {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched) {
          await launchUrl(uri);
        }
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.translate('cat_agri_market_prices'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Standby Banner
            Container(
              padding: const EdgeInsets.all(AppSizes.space16),
              decoration: BoxDecoration(
                color: AppColors.noticeAmber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                border: Border.all(color: AppColors.noticeAmber.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSizes.space8),
                        decoration: BoxDecoration(
                          color: AppColors.noticeAmber.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.sync_rounded, color: AppColors.noticeAmber, size: 24),
                      ),
                      const SizedBox(width: AppSizes.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Live APMC Mandi Link Standby',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.noticeAmber,
                              ),
                            ),
                            Text(
                              'Parner, Ahilyanagar & Rahuri APMCs',
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
                  Text(
                    context.translate('market_standby_notice'),
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.space24),

            Text(
              'Verified Official Mandi Price Portals',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.space12),

            // 1. MSAMB (Maharashtra State Agricultural Marketing Board)
            _buildMandiCard(
              context,
              title: 'MSAMB Official Daily Rates',
              subtitle: 'Official daily modal prices for onion, bajra, soybean, and pulses in Maharashtra.',
              portalUrl: 'https://www.msamb.com',
              icon: Icons.storefront_rounded,
              color: AppColors.primaryLight,
            ),
            const SizedBox(height: AppSizes.space12),

            // 2. Agmarknet (National Portal)
            _buildMandiCard(
              context,
              title: 'Agmarknet (Govt of India)',
              subtitle: 'National daily wholesale arrivals and commodity rates for Parner & Ahilyanagar mandis.',
              portalUrl: 'https://agmarknet.gov.in',
              icon: Icons.account_balance_rounded,
              color: AppColors.infoBlue,
            ),
            const SizedBox(height: AppSizes.space12),

            // 3. e-NAM (National Agriculture Market)
            _buildMandiCard(
              context,
              title: 'e-NAM Unified Platform',
              subtitle: 'Electronic trading portal facilitating transparent online bidding across participating APMCs.',
              portalUrl: 'https://enam.gov.in',
              icon: Icons.hub_rounded,
              color: AppColors.eventPurple,
            ),
            const SizedBox(height: AppSizes.space24),

            // Transparency Policy
            Container(
              padding: const EdgeInsets.all(AppSizes.space12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 18, color: AppColors.primaryLight),
                  const SizedBox(width: AppSizes.space8),
                  Expanded(
                    child: Text(
                      'GramConnect never publishes estimated or fabricated commodity rates. Live prices will connect directly from certified APMC feeds.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.space32),
          ],
        ),
      ),
    );
  }

  Widget _buildMandiCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String portalUrl,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSizes.space8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        trailing: const Icon(Icons.open_in_new_rounded, size: 18),
        onTap: () => _launchUrl(portalUrl),
      ),
    );
  }
}
