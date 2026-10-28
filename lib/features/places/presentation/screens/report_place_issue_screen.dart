import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/state/global_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../shared/utils/auth_guard.dart';
import '../../data/models/place_model.dart';
import '../../data/repositories/place_repository.dart';

/// Form screen for reporting incorrect information regarding a place listing.
/// Publicly accessible, with AuthGuard checking only upon submission.
class ReportPlaceIssueScreen extends StatefulWidget {
  final Place place;

  const ReportPlaceIssueScreen({
    super.key,
    required this.place,
  });

  @override
  State<ReportPlaceIssueScreen> createState() => _ReportPlaceIssueScreenState();
}

class _ReportPlaceIssueScreenState extends State<ReportPlaceIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();

  String _selectedIssueType = 'wrong_location';
  bool _isSubmitting = false;

  final List<Map<String, String>> _issueTypes = const [
    {'id': 'wrong_location', 'key': 'issue_wrong_location'},
    {'id': 'wrong_name', 'key': 'issue_wrong_name'},
    {'id': 'wrong_phone', 'key': 'issue_wrong_phone'},
    {'id': 'outdated_info', 'key': 'issue_outdated_info'},
    {'id': 'duplicate', 'key': 'issue_duplicate'},
    {'id': 'other', 'key': 'issue_other'},
  ];

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  void _submitReport() {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    AuthGuard.run(
      context,
      explanationKey: 'places_login_report',
      onAuthenticated: () async {
        setState(() => _isSubmitting = true);

        final state = GramConnectStateProvider.of(context);
        final report = PlaceReport(
          id: 'rep_${DateTime.now().millisecondsSinceEpoch}',
          placeId: widget.place.id,
          placeName: context.translate(widget.place.nameKey),
          issueType: _selectedIssueType,
          description: _descController.text.trim().isNotEmpty
              ? _descController.text.trim()
              : null,
          reportedByUserId: state.isLoggedIn ? 'authenticated_user' : 'guest',
          reportedAt: DateTime.now(),
        );

        await MockPlaceRepository().reportIncorrectInformation(report);

        if (!mounted) return;
        setState(() => _isSubmitting = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.translate('report_success')),
            backgroundColor: AppColors.primaryLight,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final placeName = context.translate(widget.place.nameKey);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate('report_issue_title')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.space16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Target Place info card
              Container(
                padding: const EdgeInsets.all(AppSizes.space16),
                decoration: BoxDecoration(
                  color: isDark ? theme.colorScheme.surface : Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black12,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSizes.space8),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                          ),
                          child: const Icon(
                            Icons.report_problem_rounded,
                            color: Colors.red,
                            size: AppSizes.iconMD,
                          ),
                        ),
                        const SizedBox(width: AppSizes.space12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                placeName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                context.translate('report_issue_sub'),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.space12),
                    Container(
                      padding: const EdgeInsets.all(AppSizes.space12),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: Colors.blueGrey),
                          const SizedBox(width: AppSizes.space8),
                          Expanded(
                            child: Text(
                              context.translate('report_issue_proto'),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.blueGrey.shade200 : Colors.blueGrey.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.space20),

              // Form fields
              Container(
                padding: const EdgeInsets.all(AppSizes.space16),
                decoration: BoxDecoration(
                  color: isDark ? theme.colorScheme.surface : Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black12,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Issue Type
                    Text(
                      '${context.translate('issue_type_label')} *',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedIssueType,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.error_outline_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                        ),
                      ),
                      items: _issueTypes.map((item) {
                        return DropdownMenuItem<String>(
                          value: item['id'],
                          child: Text(context.translate(item['key']!)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedIssueType = val);
                        }
                      },
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return context.translate('issue_type_req');
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSizes.space16),

                    // Description (Optional)
                    Text(
                      context.translate('report_desc_label'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space8),
                    TextFormField(
                      controller: _descController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Please describe the discrepancy or correct details...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSizes.space24),

                    // Submit Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(AppSizes.btnHeightLarge),
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                        ),
                      ),
                      onPressed: _isSubmitting ? null : _submitReport,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              context.translate('submit_report_btn'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
