import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../data/models/agri_models.dart';
import '../../data/repositories/agri_repository.dart';
import 'agri_scheme_detail_screen.dart';

/// Government Agriculture Schemes directory for Dhawalpuri.
class AgriSchemesScreen extends StatefulWidget {
  const AgriSchemesScreen({super.key});

  @override
  State<AgriSchemesScreen> createState() => _AgriSchemesScreenState();
}

class _AgriSchemesScreenState extends State<AgriSchemesScreen> {
  final _repository = MockAgriRepository();
  final _searchController = TextEditingController();
  List<AgriScheme> _schemes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSchemes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSchemes() async {
    setState(() => _isLoading = true);
    final list = await _repository.getAgriSchemes(query: _searchController.text.trim());
    if (mounted) {
      setState(() {
        _schemes = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.translate('cat_agri_schemes'),
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
                hintText: 'Search schemes by name or benefit...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          _loadSchemes();
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
              onChanged: (_) => _loadSchemes(),
            ),
          ),

          // Schemes List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _schemes.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.space32),
                          child: Text(context.translate('no_agri_found')),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppSizes.space16),
                        itemCount: _schemes.length,
                        separatorBuilder: (ctx, idx) => const SizedBox(height: AppSizes.space12),
                        itemBuilder: (ctx, idx) {
                          final scheme = _schemes[idx];
                          return Card(
                            elevation: 0.5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                              side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (ctx) => AgriSchemeDetailScreen(scheme: scheme)),
                                );
                              },
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
                                            color: AppColors.primaryLight.withValues(alpha: 0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.account_balance_rounded, color: AppColors.primaryLight, size: 20),
                                        ),
                                        const SizedBox(width: AppSizes.space12),
                                        Expanded(
                                          child: Text(
                                            scheme.name,
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              height: 1.3,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSizes.space8),
                                    Text(
                                      scheme.purpose,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                        height: 1.4,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: AppSizes.space12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            scheme.department,
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Row(
                                          children: [
                                            Text(
                                              'Details',
                                              style: TextStyle(
                                                color: AppColors.primaryLight,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                            SizedBox(width: 2),
                                            Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primaryLight),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
