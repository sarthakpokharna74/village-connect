import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/state/global_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../shared/utils/auth_guard.dart';
import '../../data/models/place_model.dart';
import '../../data/repositories/place_repository.dart';

/// Form screen allowing villagers to suggest a missing place in Dhawalpuri.
/// Validates input safely and invokes AuthGuard only at submission.
class SuggestPlaceScreen extends StatefulWidget {
  const SuggestPlaceScreen({super.key});

  @override
  State<SuggestPlaceScreen> createState() => _SuggestPlaceScreenState();
}

class _SuggestPlaceScreenState extends State<SuggestPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _detailsController = TextEditingController();

  String _selectedCategory = 'temples_landmarks';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Require authentication check only before submission
    AuthGuard.run(
      context,
      explanationKey: 'places_login_suggest',
      onAuthenticated: () async {
        setState(() => _isSubmitting = true);

        final state = GramConnectStateProvider.of(context);
        final suggestion = PlaceSuggestion(
          id: 'sug_${DateTime.now().millisecondsSinceEpoch}',
          placeName: _nameController.text.trim(),
          category: _selectedCategory,
          location: _locationController.text.trim().isNotEmpty
              ? _locationController.text.trim()
              : null,
          phoneNumber: _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
          additionalDetails: _detailsController.text.trim().isNotEmpty
              ? _detailsController.text.trim()
              : null,
          submittedByUserId: state.isLoggedIn ? 'authenticated_user' : 'guest',
          submittedAt: DateTime.now(),
        );

        await MockPlaceRepository().suggestPlace(suggestion);

        if (!mounted) return;
        setState(() => _isSubmitting = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.translate('suggest_place_success')),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate('suggest_place_title')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.space16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Intro Card explaining prototype & submission
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
                            color: AppColors.primaryLight.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                          ),
                          child: const Icon(
                            Icons.add_location_alt_rounded,
                            color: AppColors.primaryLight,
                            size: AppSizes.iconMD,
                          ),
                        ),
                        const SizedBox(width: AppSizes.space12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.translate('suggest_place'),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                context.translate('suggest_place_sub'),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: Colors.blueGrey),
                          const SizedBox(width: AppSizes.space8),
                          Expanded(
                            child: Text(
                              context.translate('suggest_place_proto'),
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

              // Form Card
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
                    // Place Name (Required)
                    Text(
                      '${context.translate('form_place_name')} *',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: context.translate('form_place_name'),
                        prefixIcon: const Icon(Icons.place_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return context.translate('form_place_name_req');
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSizes.space16),

                    // Category Dropdown (Required)
                    Text(
                      '${context.translate('form_place_cat')} *',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.category_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                        ),
                      ),
                      items: PlaceCategoryInfo.categories.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat.id,
                          child: Row(
                            children: [
                              Icon(cat.icon, size: 20, color: cat.color),
                              const SizedBox(width: AppSizes.space8),
                              Text(context.translate(cat.translationKey)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedCategory = val);
                        }
                      },
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return context.translate('form_place_cat_req');
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSizes.space16),

                    // Location or Address (Optional)
                    Text(
                      context.translate('form_place_location'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space8),
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Near ZP School, Dhawalpuri',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSizes.space16),

                    // Phone Number (Optional)
                    Text(
                      context.translate('form_place_phone'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space8),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'e.g. 9876543210',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return null; // Optional
                        }
                        final clean = val.trim().replaceAll(RegExp(r'\s+|-'), '');
                        if (!RegExp(r'^\d{10}$').hasMatch(clean)) {
                          return context.translate('form_place_phone_invalid');
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSizes.space16),

                    // Additional Details (Optional)
                    Text(
                      context.translate('form_place_details'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.space8),
                    TextFormField(
                      controller: _detailsController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: context.translate('form_description'),
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
                        backgroundColor: AppColors.primaryLight,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                        ),
                      ),
                      onPressed: _isSubmitting ? null : _submitForm,
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
                              context.translate('form_place_submit'),
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
