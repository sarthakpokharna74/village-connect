import 'package:flutter/material.dart';
import 'package:gram_connect/core/localization/app_localizations.dart';
import 'package:gram_connect/core/theme/app_sizes.dart';
import 'package:gram_connect/core/services/otp_service.dart';
import 'package:gram_connect/core/services/otp_gateway_dialog.dart';
import 'package:gram_connect/features/auth/data/repositories/auth_repository.dart';

/// Forgot Password/PIN Recovery Screen for GramConnect.
/// Validates registered mobile number, verifies OTP, and safely updates the user's PIN.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController(text: '1234');
  final _newPinController = TextEditingController();
  bool _otpSent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _newPinController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;

    final phone = _phoneController.text.trim();

    if (!_otpSent) {
      setState(() => _isLoading = true);
      final otpRes = await OtpService().sendOtp(phone);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _otpSent = true;
        if (otpRes.otpCode != null) {
          _otpController.text = otpRes.otpCode!;
        } else {
          _otpController.clear();
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(otpRes.message ?? 'OTP code sent!'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await LocalAuthRepository().resetPin(
      phoneNumber: phone,
      newPin: _newPinController.text.trim(),
      otp: _otpController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    final theme = Theme.of(context);

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN successfully updated! You can now log in with your new PIN.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Password reset failed'),
          backgroundColor: theme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate('forgot_title')),
        backgroundColor: isDark ? theme.colorScheme.surface : theme.colorScheme.primary,
        foregroundColor: isDark ? theme.colorScheme.onSurface : theme.colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configure SMS Gateway',
            onPressed: () => OtpGatewaySettingsDialog.show(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.space24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(AppSizes.space16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_reset_rounded,
                        size: 64,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.space24),

                  Text(
                    context.translate('forgot_title'),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.space8),
                  Text(
                    context.translate('forgot_subtitle'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.space20),

                  // Informational box about Panchayat cooperation & OTP
                  Container(
                    padding: const EdgeInsets.all(AppSizes.space16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: theme.colorScheme.primary,
                          size: AppSizes.iconMD,
                        ),
                        const SizedBox(width: AppSizes.space12),
                        Expanded(
                          child: Text(
                            context.translate('forgot_desc'),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 12.5,
                              height: 1.4,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.space24),

                  // Phone Input Field
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    enabled: !_otpSent,
                    decoration: InputDecoration(
                      labelText: context.translate('phone_label'),
                      hintText: context.translate('phone_hint'),
                      prefixIcon: const Icon(Icons.phone_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return context.translate('field_required');
                      }
                      if (value.trim().length != 10) {
                        return context.translate('phone_error');
                      }
                      return null;
                    },
                  ),

                  if (_otpSent) ...[
                    const SizedBox(height: AppSizes.space16),
                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      decoration: const InputDecoration(
                        labelText: 'Enter 4-Digit OTP',
                        hintText: 'Demo OTP: 1234',
                        prefixIcon: Icon(Icons.sms_rounded),
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'OTP is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.space16),
                    TextFormField(
                      controller: _newPinController,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'New 4-Digit PIN',
                        hintText: 'Enter your new PIN',
                        prefixIcon: Icon(Icons.pin_rounded),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'New PIN is required';
                        }
                        if (value.trim().length < 4) {
                          return 'PIN must be at least 4 digits';
                        }
                        return null;
                      },
                    ),
                  ],

                  const SizedBox(height: AppSizes.space24),

                  // Action Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleReset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      minimumSize: const Size(double.infinity, AppSizes.touchTargetMin),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            _otpSent ? 'Update PIN' : context.translate('reset_btn'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
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
