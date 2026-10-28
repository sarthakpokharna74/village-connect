import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../shared/utils/auth_guard.dart';
import '../../data/models/news_article_model.dart';
import '../../data/repositories/news_repository.dart';

/// Screen allowing Dhawalpuri community members to suggest news stories.
/// Preserves user inputs, executes AuthGuard on submission, and marks all submissions as
/// Pending Review to safeguard trust.
class SuggestNewsScreen extends StatefulWidget {
  const SuggestNewsScreen({super.key});

  @override
  State<SuggestNewsScreen> createState() => _SuggestNewsScreenState();
}

class _SuggestNewsScreenState extends State<SuggestNewsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _headlineController = TextEditingController();
  final _summaryController = TextEditingController();
  final _bodyController = TextEditingController();
  final _sourceController = TextEditingController();

  String _selectedCategory = NewsCategoryInfo.categories.first.key;
  DateTime? _selectedDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _headlineController.dispose();
    _summaryController.dispose();
    _bodyController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Use AuthGuard to authenticate before final persistence
    AuthGuard.run(
      context,
      explanationKey: 'suggest_news_login_desc',
      onAuthenticated: () async {
        if (_isSubmitting) return; // Prevent duplicate submission
        setState(() => _isSubmitting = true);

        final suggestion = NewsSuggestion(
          id: 'sug_news_${DateTime.now().millisecondsSinceEpoch}',
          headline: _headlineController.text.trim(),
          category: _selectedCategory,
          summary: _summaryController.text.trim(),
          body: _bodyController.text.trim(),
          occurrenceDate: _selectedDate,
          sourceUrl: _sourceController.text.trim().isEmpty ? null : _sourceController.text.trim(),
          submittedAt: DateTime.now(),
          status: NewsPublicationStatus.pendingReview,
        );

        try {
          await MockNewsRepository().submitNewsSuggestion(suggestion);

          if (!mounted) return;

          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusLG),
              ),
              title: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.primaryLight, size: 28),
                  const SizedBox(width: AppSizes.space8),
                  Expanded(
                    child: Text(
                      context.translate('suggest_news_success'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ],
              ),
              content: Text(
                context.translate('suggest_news_notice'),
                style: const TextStyle(height: 1.45),
              ),
              actions: [
                FilledButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } catch (e) {
          if (!mounted) return;
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to submit news: $e'),
              backgroundColor: AppColors.errorLight,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.translate('suggest_news_title'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.space16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notice Header Card
              Container(
                padding: const EdgeInsets.all(AppSizes.space16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  border: Border.all(
                    color: AppColors.primaryLight.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.newspaper_rounded,
                      color: AppColors.primaryLight,
                      size: 24,
                    ),
                    const SizedBox(width: AppSizes.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.translate('suggest_news_title'),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.translate('suggest_news_subtitle'),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.space20),

              // 1. Headline (Required)
              Text(
                '${context.translate('suggest_news_headline')} *',
                style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSizes.space8),
              TextFormField(
                controller: _headlineController,
                decoration: InputDecoration(
                  hintText: context.translate('suggest_news_headline_hint'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  ),
                  prefixIcon: const Icon(Icons.title_rounded),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Headline is required';
                  }
                  if (val.trim().length < 5) {
                    return 'Please enter a descriptive headline (at least 5 characters)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.space16),

              // 2. Category (Required)
              Text(
                '${context.translate('category')} *',
                style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSizes.space8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  ),
                  prefixIcon: const Icon(Icons.category_rounded),
                ),
                items: NewsCategoryInfo.categories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat.key,
                    child: Row(
                      children: [
                        Icon(cat.icon, size: 18, color: cat.color),
                        const SizedBox(width: AppSizes.space8),
                        Expanded(
                          child: Text(
                            context.translate(cat.titleKey),
                            style: theme.textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: AppSizes.space16),

              // 3. Short Summary (Required)
              Text(
                '${context.translate('suggest_news_summary')} *',
                style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSizes.space8),
              TextFormField(
                controller: _summaryController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: context.translate('suggest_news_summary_hint'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Short summary is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.space16),

              // 4. Full Story (Required)
              Text(
                '${context.translate('suggest_news_body')} *',
                style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSizes.space8),
              TextFormField(
                controller: _bodyController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: context.translate('suggest_news_body_hint'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Full story details are required';
                  }
                  if (val.trim().length < 20) {
                    return 'Please provide more details (at least 20 characters)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.space16),

              // 5. Occurrence Date (Optional)
              Text(
                context.translate('suggest_news_date'),
                style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSizes.space8),
              InkWell(
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 20),
                      const SizedBox(width: AppSizes.space12),
                      Text(
                        _selectedDate == null ? 'Select date of occurrence' : _formatDate(_selectedDate!),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _selectedDate == null ? theme.colorScheme.onSurfaceVariant : null,
                        ),
                      ),
                      const Spacer(),
                      if (_selectedDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => setState(() => _selectedDate = null),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.space16),

              // 6. Source or Reference Link (Optional)
              Text(
                context.translate('suggest_news_source'),
                style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSizes.space8),
              TextFormField(
                controller: _sourceController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  hintText: context.translate('suggest_news_source_hint'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  ),
                  prefixIcon: const Icon(Icons.link_rounded),
                ),
                validator: (val) {
                  if (val != null && val.trim().isNotEmpty) {
                    final uri = Uri.tryParse(val.trim());
                    if (uri == null || !uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
                      return 'Please enter a valid URL starting with http:// or https://';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.space24),

              // Pending Review Policy Note
              Container(
                padding: const EdgeInsets.all(AppSizes.space12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariantLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.shield_outlined, size: 18, color: AppColors.primaryLight),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.translate('suggest_news_notice'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.space24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: AppSizes.btnHeightLarge,
                child: FilledButton.icon(
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(
                    context.translate('suggest_news_submit'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _handleSubmit,
                ),
              ),
              const SizedBox(height: AppSizes.space32),
            ],
          ),
        ),
      ),
    );
  }
}
