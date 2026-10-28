import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../data/models/community_model.dart';
import '../../data/repositories/community_repository.dart';

/// Form screen allowing villagers to propose a community activity or group for Dhawalpuri.
/// Clearly explains that submissions are recorded in local prototype mode and not sent to the Gram Panchayat.
class SuggestActivityScreen extends StatefulWidget {
  const SuggestActivityScreen({super.key});

  @override
  State<SuggestActivityScreen> createState() => _SuggestActivityScreenState();
}

class _SuggestActivityScreenState extends State<SuggestActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedCategory;
  DateTime? _selectedDate;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'community_groups',
    'cultural_activities',
    'sports_youth',
    'volunteering',
    'womens_groups',
    'senior_citizens',
    'village_celebrations',
    'social_initiatives',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final submission = CommunitySubmission(
        id: 'sub-${DateTime.now().millisecondsSinceEpoch}',
        title: _nameController.text.trim(),
        category: _selectedCategory!,
        description: _descController.text.trim(),
        suggestedDate: _selectedDate != null
            ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
            : null,
        location: _locationController.text.trim().isNotEmpty
            ? _locationController.text.trim()
            : null,
        submittedBy: 'villager_user',
        status: 'prototype_pending',
        createdAt: DateTime.now(),
      );

      final repository = MockCommunityRepository();
      await repository.submitActivity(submission);

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      // Show localized confirmation snackbar and pop screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('suggest_success')),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate('suggest_activity_title')),
        backgroundColor: isDark ? theme.colorScheme.surface : theme.colorScheme.primary,
        foregroundColor: isDark ? theme.colorScheme.onSurface : theme.colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.space16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- 1. Explanatory Prototype Notice ---
                Container(
                  padding: const EdgeInsets.all(AppSizes.space12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: AppSizes.iconSM,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: AppSizes.space8),
                      Expanded(
                        child: Text(
                          context.translate('suggest_proto_notice'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.space20),

                // Subtitle
                Text(
                  context.translate('suggest_activity_subtitle'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: AppSizes.space16),

                // --- 2. Activity / Group Name (Required) ---
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: '${context.translate('form_activity_name')} *',
                    hintText: 'e.g. Dhawalpuri Study Circle',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    ),
                    prefixIcon: const Icon(Icons.title_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.translate('form_activity_name_req');
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSizes.space16),

                // --- 3. Category Selector (Required) ---
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: '${context.translate('form_category')} *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    ),
                    prefixIcon: const Icon(Icons.category_rounded),
                  ),
                  items: _categories.map((catKey) {
                    final color = CommunityItem.getColorForCategory(catKey);
                    final icon = CommunityItem.getIconForCategory(catKey);
                    return DropdownMenuItem<String>(
                      value: catKey,
                      child: Row(
                        children: [
                          Icon(icon, size: 18, color: color),
                          const SizedBox(width: 8),
                          Text(context.translate(CommunityItem.getCategoryTitleKey(catKey))),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCategory = val;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.translate('form_category_req');
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSizes.space16),

                // --- 4. Description (Required) ---
                TextFormField(
                  controller: _descController,
                  maxLines: 4,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: '${context.translate('form_description')} *',
                    hintText: 'Describe the purpose and goals...',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    ),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 50.0),
                      child: Icon(Icons.description_rounded),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.translate('form_description_req');
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSizes.space16),

                // --- 5. Suggested Date (Optional) ---
                InkWell(
                  onTap: () => _selectDate(context),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: context.translate('form_suggested_date'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      ),
                      prefixIcon: const Icon(Icons.calendar_month_rounded),
                      suffixIcon: _selectedDate != null
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                setState(() {
                                  _selectedDate = null;
                                });
                              },
                            )
                          : null,
                    ),
                    child: Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}'
                          : context.translate('form_select_date'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _selectedDate != null
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.space16),

                // --- 6. Location (Optional) ---
                TextFormField(
                  controller: _locationController,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: context.translate('form_location'),
                    hintText: 'e.g. ZP High School Ground, Dhawalpuri',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    ),
                    prefixIcon: const Icon(Icons.place_outlined),
                  ),
                ),

                const SizedBox(height: AppSizes.space24),

                // --- 7. Submit Button ---
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    minimumSize: const Size(double.infinity, AppSizes.touchTargetMin),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          context.translate('form_submit'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                ),
                const SizedBox(height: AppSizes.space16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
