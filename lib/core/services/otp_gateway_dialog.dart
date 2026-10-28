import 'package:flutter/material.dart';
import '../theme/app_sizes.dart';
import 'otp_service.dart';

/// Interactive modal allowing administrators or developers to configure real SMS gateways
/// (e.g. Fast2SMS, 2Factor) directly from the mobile app interface.
class OtpGatewaySettingsDialog extends StatefulWidget {
  const OtpGatewaySettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const OtpGatewaySettingsDialog(),
    );
  }

  @override
  State<OtpGatewaySettingsDialog> createState() =>
      _OtpGatewaySettingsDialogState();
}

class _OtpGatewaySettingsDialogState extends State<OtpGatewaySettingsDialog> {
  final _keyController = TextEditingController();
  final _senderController = TextEditingController();
  OtpProvider _selectedProvider = OtpProvider.demo;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final provider = await OtpService().getProvider();
    final key = await OtpService().getApiKey();
    if (mounted) {
      setState(() {
        _selectedProvider = provider;
        if (key != null) _keyController.text = key;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _keyController.dispose();
    _senderController.dispose();
    super.dispose();
  }

  Future<void> _saveConfig() async {
    setState(() => _isSaving = true);
    if (_selectedProvider == OtpProvider.demo) {
      await OtpService().resetToDemo();
    } else {
      await OtpService().saveGatewayConfig(
        provider: _selectedProvider,
        apiKey: _keyController.text.trim(),
        senderId: _senderController.text.trim(),
      );
    }
    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _selectedProvider == OtpProvider.demo
              ? 'Reset to Offline / Demo OTP mode.'
              : 'Real SMS gateway updated to ${_selectedProvider.name.toUpperCase()}!',
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const AlertDialog(
        content: SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.sms_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: AppSizes.space8),
          const Text('Real SMS Gateway Setup'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Switch between offline development mode and real Indian SMS delivery.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSizes.space16),
            DropdownButtonFormField<OtpProvider>(
              initialValue: _selectedProvider,
              decoration: const InputDecoration(
                labelText: 'SMS Gateway Provider',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.hub_outlined),
              ),
              items: const [
                DropdownMenuItem(
                  value: OtpProvider.demo,
                  child: Text('Demo / Local Mode (1234 or On-screen)'),
                ),
                DropdownMenuItem(
                  value: OtpProvider.fast2sms,
                  child: Text('Fast2SMS (India Quick SMS / OTP)'),
                ),
                DropdownMenuItem(
                  value: OtpProvider.twoFactor,
                  child: Text('2Factor.in (India SMS Gateway)'),
                ),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedProvider = val);
              },
            ),
            if (_selectedProvider != OtpProvider.demo) ...[
              const SizedBox(height: AppSizes.space16),
              TextField(
                controller: _keyController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '${_selectedProvider.name.toUpperCase()} API Key',
                  hintText: 'Paste authorization token / API key here',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.key_outlined),
                  helperText: _selectedProvider == OtpProvider.fast2sms
                      ? 'From fast2sms.com > Dev API > Authorization'
                      : 'From 2factor.in dashboard',
                ),
              ),
              const SizedBox(height: AppSizes.space12),
              Container(
                padding: const EdgeInsets.all(AppSizes.space12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.bolt, size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: AppSizes.space8),
                    Expanded(
                      child: Text(
                        'When configured, real SMS messages with OTP codes will be sent instantly to any 10-digit Indian mobile number.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _saveConfig,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Save Gateway'),
        ),
      ],
    );
  }
}
