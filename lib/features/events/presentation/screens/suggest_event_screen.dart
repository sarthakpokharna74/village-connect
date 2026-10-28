import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../shared/utils/auth_guard.dart';
import '../../data/models/event_model.dart';
import '../../data/repositories/event_repository.dart';

/// Form screen allowing Dhawalpuri residents to suggest community events (Blueprint 8).
/// Enforces comprehensive client-side validation, date/time logic, and auth gating.
class SuggestEventScreen extends StatefulWidget {
  const SuggestEventScreen({super.key});

  @override
  State<SuggestEventScreen> createState() => _SuggestEventScreenState();
}

class _SuggestEventScreenState extends State<SuggestEventScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _venueController = TextEditingController();
  final _descController = TextEditingController();
  final _organizerController = TextEditingController();
  final _contactController = TextEditingController();

  String _selectedCategory = 'festivals_celebrations';
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  String? _dateError;
  String? _timeError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _venueController.dispose();
    _descController.dispose();
    _organizerController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      helpText: context.translate('event_suggest_date'),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateError = null;
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? const TimeOfDay(hour: 10, minute: 0),
      helpText: context.translate('event_suggest_start_time'),
    );

    if (picked != null) {
      setState(() {
        _startTime = picked;
        _validateTimeRange();
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? const TimeOfDay(hour: 12, minute: 0),
      helpText: context.translate('event_suggest_end_time'),
    );

    if (picked != null) {
      setState(() {
        _endTime = picked;
        _validateTimeRange();
      });
    }
  }

  bool _validateTimeRange() {
    if (_startTime != null && _endTime != null) {
      final startMin = _startTime!.hour * 60 + _startTime!.minute;
      final endMin = _endTime!.hour * 60 + _endTime!.minute;
      if (endMin <= startMin) {
        setState(() {
          _timeError = context.translate('event_suggest_time_invalid');
        });
        return false;
      }
    }
    setState(() {
      _timeError = null;
    });
    return true;
  }

  void _submitForm() {
    if (_isSubmitting) return;

    // Validate date
    if (_selectedDate == null) {
      setState(() {
        _dateError = context.translate('field_required');
      });
      return;
    } else {
      setState(() {
        _dateError = null;
      });
    }

    // Validate time range
    if (!_validateTimeRange()) {
      return;
    }

    // Validate text fields
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Authentication Guard before persisting proposal
    AuthGuard.run(
      context,
      explanationKey: 'event_suggest_login_desc',
      onAuthenticated: () async {
        setState(() => _isSubmitting = true);

        final title = _titleController.text.trim();
        final venue = _venueController.text.trim();
        final desc = _descController.text.trim();
        final org = _organizerController.text.trim();
        final contact = _contactController.text.trim();

        final suggestion = EventSuggestion(
          id: 'sug_ev_${DateTime.now().millisecondsSinceEpoch}',
          title: title,
          category: _selectedCategory,
          date: _selectedDate!,
          startTime: _startTime?.format(context),
          endTime: _endTime?.format(context),
          venue: venue,
          description: desc,
          organizer: org.isNotEmpty ? org : null,
          contact: contact.isNotEmpty ? contact : null,
          submittedAt: DateTime.now(),
          status: EventPublicationStatus.pendingApproval,
        );

        await MockEventRepository().suggestEvent(suggestion);

        if (!mounted) return;
        setState(() => _isSubmitting = false);

        // Show confirmation dialog explaining moderation state
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            final theme = Theme.of(dialogContext);
            return AlertDialog(
              icon: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 48),
              title: Text(
                context.translate('event_suggest_success'),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              content: Text(
                context.translate('event_suggest_notice'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text(context.translate('close')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate('event_suggest_title')),
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Banner / Notice
                Container(
                  padding: const EdgeInsets.all(AppSizes.space12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: AppSizes.space8),
                      Expanded(
                        child: Text(
                          context.translate('event_suggest_notice'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.space20),

                // 1. Title (Required)
                Text(
                  '${context.translate('event_suggest_name')} *',
                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSizes.space8),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: context.translate('event_suggest_name_hint'),
                    prefixIcon: const Icon(Icons.title_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return context.translate('field_required');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.space16),

                // 2. Category Dropdown (Required - 10 Categories)
                Text(
                  '${context.translate('event_suggest_cat')} *',
                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
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
                  items: EventCategoryInfo.allCategories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat.id,
                      child: Row(
                        children: [
                          Icon(cat.icon, size: 18, color: cat.color),
                          const SizedBox(width: AppSizes.space8),
                          Text(context.translate(cat.nameKey)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedCategory = val);
                    }
                  },
                ),
                const SizedBox(height: AppSizes.space16),

                // 3. Date Selection (Required)
                Text(
                  '${context.translate('event_suggest_date')} *',
                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSizes.space8),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.space12,
                      vertical: AppSizes.space16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _dateError != null
                            ? theme.colorScheme.error
                            : theme.colorScheme.outline.withValues(alpha: 0.5),
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: AppSizes.space12),
                        Expanded(
                          child: Text(
                            _selectedDate != null
                                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                : context.translate('event_suggest_date_hint'),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _selectedDate != null
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                if (_dateError != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _dateError!,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                  ),
                ],
                const SizedBox(height: AppSizes.space16),

                // 4. Start & End Times (Optional)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.translate('event_suggest_start_time'),
                            style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppSizes.space8),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.access_time_rounded, size: 16),
                            label: Text(
                              _startTime != null
                                  ? _startTime!.format(context)
                                  : context.translate('event_time'),
                            ),
                            onPressed: _pickStartTime,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSizes.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.translate('event_suggest_end_time'),
                            style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppSizes.space8),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.access_time_filled_rounded, size: 16),
                            label: Text(
                              _endTime != null
                                  ? _endTime!.format(context)
                                  : context.translate('event_time'),
                            ),
                            onPressed: _pickEndTime,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_timeError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _timeError!,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                  ),
                ],
                const SizedBox(height: AppSizes.space16),

                // 5. Venue (Required)
                Text(
                  '${context.translate('event_suggest_venue')} *',
                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSizes.space8),
                TextFormField(
                  controller: _venueController,
                  decoration: InputDecoration(
                    hintText: context.translate('event_suggest_venue_hint'),
                    prefixIcon: const Icon(Icons.location_on_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return context.translate('field_required');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.space16),

                // 6. Description (Required)
                Text(
                  '${context.translate('event_suggest_desc')} *',
                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSizes.space8),
                TextFormField(
                  controller: _descController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: context.translate('event_suggest_desc_hint'),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return context.translate('field_required');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.space16),

                // 7. Organizer (Optional)
                Text(
                  context.translate('event_suggest_org'),
                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSizes.space8),
                TextFormField(
                  controller: _organizerController,
                  decoration: InputDecoration(
                    hintText: context.translate('event_suggest_org_hint'),
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.space16),

                // 8. Contact Information (Optional)
                Text(
                  context.translate('event_suggest_contact'),
                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSizes.space8),
                TextFormField(
                  controller: _contactController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: context.translate('event_suggest_contact_hint'),
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.space24),

                // Submit Button
                FilledButton.icon(
                  onPressed: _isSubmitting ? null : _submitForm,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(
                    context.translate('event_suggest_submit'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    minimumSize: const Size(double.infinity, AppSizes.touchTargetMin),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    ),
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
