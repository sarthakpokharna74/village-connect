import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../data/models/news_article_model.dart';
import '../../data/repositories/news_repository.dart';

/// Modal dialog allowing residents to report inaccuracies or outdated information
/// in village news stories, maintaining community trust in Dhawalpuri.
class ReportNewsIssueDialog extends StatefulWidget {
  final NewsArticle article;

  const ReportNewsIssueDialog({super.key, required this.article});

  static Future<void> show(BuildContext context, NewsArticle article) {
    return showDialog(
      context: context,
      builder: (ctx) => ReportNewsIssueDialog(article: article),
    );
  }

  @override
  State<ReportNewsIssueDialog> createState() => _ReportNewsIssueDialogState();
}

class _ReportNewsIssueDialogState extends State<ReportNewsIssueDialog> {
  final _formKey = GlobalKey<FormState>();
  final _detailsController = TextEditingController();
  String _selectedIssueKey = 'issue_inaccurate_facts';
  bool _isSubmitting = false;

  final List<String> _issueKeys = [
    'issue_inaccurate_facts',
    'issue_wrong_date',
    'issue_outdated',
    'news_issue_other',
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final report = NewsReport(
      id: 'rep_${DateTime.now().millisecondsSinceEpoch}',
      articleId: widget.article.id,
      issueType: context.translate(_selectedIssueKey),
      description: _detailsController.text.trim(),
      reportedAt: DateTime.now(),
    );

    try {
      await MockNewsRepository().reportArticleIssue(report);
      if (!mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: AppSizes.space8),
              Expanded(
                child: Text(
                  context.translate('news_report_success'),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryLight,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting report: $e'),
          backgroundColor: AppColors.errorLight,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.space20),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSizes.space8),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.flag_rounded,
                          color: AppColors.errorLight,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSizes.space12),
                      Expanded(
                        child: Text(
                          context.translate('news_report_title'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.space12),
                  Text(
                    context.translate('report_issue_desc'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space16),

                  // Issue Type Selection
                  Text(
                    context.translate('report_issue_type'),
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedIssueKey,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      ),
                    ),
                    items: _issueKeys.map((key) {
                      return DropdownMenuItem<String>(
                        value: key,
                        child: Text(
                          context.translate(key),
                          style: theme.textTheme.bodyMedium,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedIssueKey = val);
                    },
                  ),
                  const SizedBox(height: AppSizes.space16),

                  // Explanation Text Field
                  Text(
                    context.translate('report_description'),
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space8),
                  TextFormField(
                    controller: _detailsController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: context.translate('report_description_hint'),
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter details for the correction';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.space20),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                        child: Text(context.translate('cancel')),
                      ),
                      const SizedBox(width: AppSizes.space8),
                      FilledButton.icon(
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send_rounded, size: 16),
                        label: Text(context.translate('report_submit')),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.errorLight,
                        ),
                        onPressed: _isSubmitting ? null : _submitReport,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
