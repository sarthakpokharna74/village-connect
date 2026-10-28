import 'package:flutter/material.dart';
import 'package:gram_connect/core/localization/app_localizations.dart';
import 'package:gram_connect/core/theme/app_sizes.dart';
import 'package:gram_connect/features/notices/data/models/notice_model.dart';
import 'package:gram_connect/shared/utils/auth_guard.dart';

/// Details view for a Village Notice. Accessible publicly.
/// Actions such as saving, receiving alerts, and questioning require login check via AuthGuard.
class NoticeDetailsScreen extends StatefulWidget {
  final NoticeItem notice;

  const NoticeDetailsScreen({
    super.key,
    required this.notice,
  });

  @override
  State<NoticeDetailsScreen> createState() => _NoticeDetailsScreenState();
}

class _NoticeDetailsScreenState extends State<NoticeDetailsScreen> {
  bool _isSaved = false;
  bool _isSubscribed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate('village_notices')),
        backgroundColor: isDark ? theme.colorScheme.surface : theme.colorScheme.primary,
        foregroundColor: isDark ? theme.colorScheme.onSurface : theme.colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- 1. Category Tag & Urgency Badge ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.notice.categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.notice.icon,
                          size: 16,
                          color: widget.notice.categoryColor,
                        ),
                        const SizedBox(width: AppSizes.space8),
                        Text(
                          context.translate('cat_${widget.notice.category}').toUpperCase(),
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: widget.notice.categoryColor,
                            fontSize: 11.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.notice.isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      ),
                      child: Text(
                        context.translate('urgent'),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.red[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 11.0,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSizes.space16),

              // --- 2. Title ---
              Text(
                context.translate(widget.notice.titleKey),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22.0,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: AppSizes.space12),

              // --- 3. Publishing Meta Details Card ---
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.space12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: AppSizes.iconMD,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: AppSizes.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${context.translate('source')}: ${context.translate(widget.notice.sourceKey)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.0,
                              ),
                            ),
                            const SizedBox(height: AppSizes.space4),
                            Text(
                              '${context.translate('published')}: ${widget.notice.dateKey}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 11.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.space16),
              const Divider(),
              const SizedBox(height: AppSizes.space12),

              // --- 4. Complete Description Body ---
              Text(
                context.translate(widget.notice.contentKey),
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  color: theme.colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: AppSizes.space24),
              const Divider(),
              const SizedBox(height: AppSizes.space16),

              // --- 5. Attachments Box Section ---
              Text(
                context.translate('attachments'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.space8),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  side: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.space12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSizes.space8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                        ),
                        child: Icon(
                          Icons.picture_as_pdf_rounded,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: AppSizes.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Official_Notice_Circular.pdf',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSizes.space4),
                            Text(
                              '342 KB • PDF Circular',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.download_rounded),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Downloading file attachment... (Simulated)')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.space24),
              const Divider(),
              const SizedBox(height: AppSizes.space16),

              // --- 6. Protected Interactive Features Card ---
              Card(
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Panchayat Actions',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.space4),
                      Text(
                        'Interact with this circular using village services.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSizes.space16),

                      // Action Row containing Protected Actions
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionTile(
                              context,
                              labelKey: 'save_notice',
                              icon: _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                              color: Colors.blue,
                              onTap: () {
                                AuthGuard.run(
                                  context,
                                  explanationKey: 'login_desc',
                                  onAuthenticated: () {
                                    setState(() {
                                      _isSaved = !_isSaved;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(context.translate('saved_success'))),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: AppSizes.space8),
                          Expanded(
                            child: _buildActionTile(
                              context,
                              labelKey: 'receive_notif',
                              icon: _isSubscribed ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                              color: Colors.green,
                              onTap: () {
                                AuthGuard.run(
                                  context,
                                  explanationKey: 'login_desc',
                                  onAuthenticated: () {
                                    setState(() {
                                      _isSubscribed = !_isSubscribed;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(context.translate('notif_success'))),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.space8),
                      ElevatedButton.icon(
                        onPressed: () {
                          AuthGuard.run(
                            context,
                            explanationKey: 'login_desc',
                            onAuthenticated: () {
                              _showQuestionBottomSheet(context);
                            },
                          );
                        },
                        icon: const Icon(Icons.question_answer_rounded, size: AppSizes.iconMD),
                        label: Text(context.translate('submit_question')),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, AppSizes.touchTargetMin),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.space32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String labelKey,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: color),
      label: Text(
        context.translate(labelKey),
        style: const TextStyle(fontSize: 12.0),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, AppSizes.touchTargetMin),
        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        ),
      ),
    );
  }

  void _showQuestionBottomSheet(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLG)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: EdgeInsets.only(
            left: AppSizes.space16,
            right: AppSizes.space16,
            top: AppSizes.space16,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.space24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.translate('submit_question'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.space12),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Enter your inquiry here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.space16),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.translate('question_success'))),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, AppSizes.touchTargetMin),
                ),
                child: const Text('Send'),
              ),
            ],
          ),
        );
      },
    );
  }
}
