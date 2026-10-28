import 'package:flutter/material.dart';
import 'package:gram_connect/core/localization/app_localizations.dart';
import 'package:gram_connect/core/theme/app_sizes.dart';
import 'package:gram_connect/core/state/global_state.dart';
import 'package:gram_connect/core/navigation/app_router.dart';
import 'package:gram_connect/core/services/otp_service.dart';
import 'package:gram_connect/core/services/otp_gateway_dialog.dart';
import 'package:gram_connect/features/auth/data/repositories/auth_repository.dart';

/// Villager Registration Screen for GramConnect.
/// Validates input, simulates village SMS OTP verification, and creates a real persistent profile.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _villageController = TextEditingController(text: 'Dhawalpuri (ढवळपुरी)');
  final _wardController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _fullnameController.dispose();
    _phoneController.dispose();
    _villageController.dispose();
    _wardController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister(GramConnectStateProvider state) async {
    if (!_formKey.currentState!.validate() || _isLoading) return;

    final phone = _phoneController.text.trim();
    final name = _fullnameController.text.trim();
    final village = _villageController.text.trim();
    final ward = _wardController.text.trim();
    final pin = _passwordController.text.trim();

    setState(() => _isLoading = true);
    final otpRes = await OtpService().sendOtp(phone);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!otpRes.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(otpRes.message ?? 'Failed to send OTP'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final otpController = TextEditingController(
      text: otpRes.otpCode ?? '',
    );
    final verified = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          icon: Icon(Icons.sms_outlined, size: 36, color: theme.colorScheme.primary),
          title: const Text('Verify Mobile Number (OTP)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                otpRes.isRealSmsSent
                    ? 'A real verification code was sent to +91 $phone via ${otpRes.providerName}.'
                    : 'A verification code has been generated for +91 $phone.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSizes.space8),
              Container(
                padding: const EdgeInsets.all(AppSizes.space8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                ),
                child: Row(
                  children: [
                    Icon(
                      otpRes.isRealSmsSent ? Icons.mark_email_read_outlined : Icons.info_outline,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: AppSizes.space8),
                    Expanded(
                      child: Text(
                        otpRes.isRealSmsSent
                            ? 'Check your phone SMS inbox'
                            : 'Demo OTP: ${otpRes.otpCode ?? "1234"} (Auto-filled)',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.space16),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, letterSpacing: 8, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Enter 4-Digit OTP',
                  hintText: otpRes.isRealSmsSent ? '••••' : '1234',
                  border: const OutlineInputBorder(),
                  counterText: '',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.translate('cancel')),
            ),
            FilledButton(
              onPressed: () {
                final entered = otpController.text.trim();
                final isValid = OtpService().verifyOtp(
                  phoneNumber: phone,
                  enteredOtp: entered,
                );
                if (isValid) {
                  Navigator.of(dialogContext).pop(true);
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        otpRes.isRealSmsSent
                            ? 'Incorrect OTP. Please check the SMS sent to your phone.'
                            : 'Invalid code. Use ${otpRes.otpCode ?? "1234"}.',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Verify & Create Account'),
            ),
          ],
        );
      },
    );

    if (verified != true) return;

    setState(() => _isLoading = true);

    final result = await LocalAuthRepository().register(
      fullName: name,
      phoneNumber: phone,
      villageName: village,
      pin: pin,
      wardOrGalli: ward.isNotEmpty ? ward : null,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    final theme = Theme.of(context);

    if (result.isSuccess && result.user != null) {
      if (state.updateUserSession != null) {
        state.updateUserSession!(result.user, true);
      } else {
        state.updateLoginState(true);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Welcome to GramConnect, ${result.user!.fullName}! Digital ID: ${result.user!.digitalIdCode}',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Registration failed'),
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
    final state = GramConnectStateProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate('register_title')),
        backgroundColor: isDark ? theme.colorScheme.surface : theme.colorScheme.primary,
        foregroundColor: isDark ? theme.colorScheme.onSurface : theme.colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(false),
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
                        color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.app_registration_rounded,
                        size: 64,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.space16),

                  Text(
                    context.translate('register_title'),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.space4),
                  Text(
                    context.translate('register_subtitle'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.space24),

                  // Full Name Field
                  TextFormField(
                    controller: _fullnameController,
                    decoration: InputDecoration(
                      labelText: context.translate('fullname_label'),
                      hintText: context.translate('fullname_hint'),
                      prefixIcon: const Icon(Icons.person_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return context.translate('field_required');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.space12),

                  // Phone Field
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
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
                  const SizedBox(height: AppSizes.space12),

                  // Village Name Field
                  TextFormField(
                    controller: _villageController,
                    decoration: InputDecoration(
                      labelText: context.translate('village_label'),
                      hintText: context.translate('village_name'),
                      prefixIcon: const Icon(Icons.location_city_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return context.translate('field_required');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.space12),

                  // Ward / Galli (Optional)
                  TextFormField(
                    controller: _wardController,
                    decoration: InputDecoration(
                      labelText: 'Ward / Galli (Optional)',
                      hintText: 'e.g. Ward No. 3, Mandir Galli',
                      prefixIcon: const Icon(Icons.home_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.space12),

                  // Password PIN Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: context.translate('password_label'),
                      hintText: context.translate('password_hint'),
                      prefixIcon: const Icon(Icons.pin_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return context.translate('field_required');
                      }
                      if (value.trim().length < 4) {
                        return context.translate('pass_error');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.space24),

                  // Register Submit Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _handleRegister(state),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: theme.colorScheme.onSecondary,
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
                            context.translate('register_btn'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: AppSizes.space16),

                  // Back to Login Link
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed(AppRouter.login);
                    },
                    child: Text(
                      context.translate('login_link'),
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
