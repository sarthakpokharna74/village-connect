import 'package:flutter/material.dart';
import 'package:gram_connect/core/localization/app_localizations.dart';
import 'package:gram_connect/core/theme/app_sizes.dart';
import 'package:gram_connect/core/state/global_state.dart';
import 'package:gram_connect/core/navigation/app_router.dart';
import 'package:gram_connect/features/auth/data/repositories/auth_repository.dart';

/// Villager Login Screen for GramConnect.
/// Provides real authentication against persistent local accounts with instant feedback.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(GramConnectStateProvider state) async {
    if (!_formKey.currentState!.validate() || _isLoading) return;

    setState(() => _isLoading = true);

    final result = await LocalAuthRepository().login(
      phoneNumber: _phoneController.text.trim(),
      pin: _passwordController.text.trim(),
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
            '${context.translate('welcome_back')}, ${result.user!.fullName}!',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.errorMessage ?? context.translate('field_required'),
          ),
          backgroundColor: theme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _fillAccount(String phone, String pin) {
    setState(() {
      _phoneController.text = phone;
      _passwordController.text = pin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = GramConnectStateProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate('login_title')),
        backgroundColor: isDark ? theme.colorScheme.surface : theme.colorScheme.primary,
        foregroundColor: isDark ? theme.colorScheme.onSurface : theme.colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(false),
        ),
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
                  // Circular Brand Logo Stub
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(AppSizes.space16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_person_rounded,
                        size: 64,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.space24),

                  // Welcoming text headers
                  Text(
                    context.translate('welcome_back'),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.space8),
                  Text(
                    context.translate('login_subtitle'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.space24),

                  // Quick-fill test accounts
                  Container(
                    padding: const EdgeInsets.all(AppSizes.space12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick-Fill Verified Accounts (Dhawalpuri):',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSizes.space8),
                        Wrap(
                          spacing: AppSizes.space8,
                          runSpacing: AppSizes.space8,
                          children: [
                            ActionChip(
                              avatar: const Icon(Icons.person, size: 16),
                              label: const Text('Sunita Patil (Villager)'),
                              onPressed: () => _fillAccount('9876543210', '1234'),
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.account_balance, size: 16),
                              label: const Text('Ramesh Thube (Sarpanch)'),
                              onPressed: () => _fillAccount('9422012345', '1234'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.space20),

                  // Phone Input Field
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
                  const SizedBox(height: AppSizes.space16),

                  // Password PIN Input Field
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

                  // Sign In Action Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _handleLogin(state),
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
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            context.translate('login_btn'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: AppSizes.space16),

                  // Recovery and Registration links
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRouter.forgotPassword);
                    },
                    child: Text(
                      context.translate('forgot_link'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: AppSizes.space8),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed(AppRouter.register);
                    },
                    child: Text(
                      context.translate('register_link'),
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
