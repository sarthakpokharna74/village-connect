import 'package:flutter/material.dart';
import 'package:gram_connect/core/data/mock_data.dart';
import 'package:gram_connect/core/localization/app_localizations.dart';
import 'package:gram_connect/core/theme/app_sizes.dart';
import 'package:gram_connect/shared/widgets/section_header.dart';
import 'package:gram_connect/shared/widgets/state_widgets.dart';
import '../../../shared/utils/auth_guard.dart';

class FeatureDetailScreen extends StatefulWidget {
  final String featureKey;
  final IconData icon;
  final Color accentColor;

  const FeatureDetailScreen({
    super.key,
    required this.featureKey,
    required this.icon,
    required this.accentColor,
  });

  @override
  State<FeatureDetailScreen> createState() => _FeatureDetailScreenState();
}

enum ScreenState { loading, success, empty, error }

class _FeatureDetailScreenState extends State<FeatureDetailScreen> {
  ScreenState _state = ScreenState.loading;
  List<Map<String, String>> _data = [];
  String _errorMessage = '';

  // Direct test toggles to verify the different states
  bool _forceEmpty = false;
  bool _forceError = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _state = ScreenState.loading;
    });

    try {
      final results = await MockData.fetchFeatureData(
        widget.featureKey,
        simulateError: _forceError,
        simulateEmpty: _forceEmpty,
      );

      if (!mounted) return;

      if (results.isEmpty) {
        setState(() {
          _state = ScreenState.empty;
          _data = [];
        });
      } else {
        setState(() {
          _state = ScreenState.success;
          _data = results;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = ScreenState.error;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Resolve localized title
    final localizedTitle = context.translate(widget.featureKey);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizedTitle),
        backgroundColor: isDark ? theme.colorScheme.surface : widget.accentColor,
        foregroundColor: isDark ? theme.colorScheme.onSurface : theme.colorScheme.onPrimary,
        actions: [
          // Control buttons to easily toggle mock states for review
          IconButton(
            icon: Icon(Icons.settings_backup_restore, 
              color: isDark ? theme.colorScheme.primary : theme.colorScheme.onPrimary),
            tooltip: 'Simulate States',
            onPressed: _showStateSelectorBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Summary Block
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.space24),
            color: isDark 
                ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                : widget.accentColor.withValues(alpha: 0.06),
            child: Row(
              children: [
                Icon(widget.icon, size: AppSizes.iconXL * 1.5, color: widget.accentColor),
                const SizedBox(width: AppSizes.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizedTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.space4),
                      Text(
                        context.translate('${widget.featureKey}_desc'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),

          // Main Scrollable List Area
          Expanded(
            child: _buildStatefulBody(),
          ),
          
          if (widget.featureKey == 'help_feedback')
            Padding(
              padding: const EdgeInsets.all(AppSizes.space16),
              child: ElevatedButton.icon(
                onPressed: () {
                  AuthGuard.run(
                    context,
                    explanationKey: 'login_desc',
                    onAuthenticated: () {
                      _showFeedbackSubmittedDialog(context);
                    },
                  );
                },
                icon: const Icon(Icons.send_rounded),
                label: Text(
                  context.translate('submit_feedback'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, AppSizes.touchTargetMin),
                  backgroundColor: widget.accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showFeedbackSubmittedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          ),
          title: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green),
              const SizedBox(width: AppSizes.space12),
              Text(ctx.translate('success')),
            ],
          ),
          content: Text(
            ctx.translate('demo_feedback_notice'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(ctx.translate('ok')),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatefulBody() {
    switch (_state) {
      case ScreenState.loading:
        return const LoadingState();
      case ScreenState.empty:
        return EmptyState(
          title: 'No Data Available',
          description: 'There is no current information for ${context.translate(widget.featureKey)}.',
          icon: widget.icon,
        );
      case ScreenState.error:
        return ErrorState(
          message: _errorMessage,
          onRetry: _loadData,
        );
      case ScreenState.success:
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: AppSizes.space32),
          itemCount: _data.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return SectionHeader(
                title: 'Available Information',
                subtitle: '${_data.length} records found',
              );
            }
            final item = _data[index - 1];
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.space16,
                vertical: AppSizes.space8,
              ),
              child: Card(
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] ?? '',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: widget.accentColor,
                        ),
                      ),
                      const SizedBox(height: AppSizes.space8),
                      Text(
                        item['value'] ?? '',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
    }
  }

  /// Floating sheet picker to show state transition options (Success, Empty, Error)
  void _showStateSelectorBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXL)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.space24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Simulation Testing Options',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.space20),
                ListTile(
                  leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                  title: const Text('Simulate Success (Data Available)'),
                  trailing: (!_forceEmpty && !_forceError) ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    setState(() {
                      _forceEmpty = false;
                      _forceError = false;
                    });
                    Navigator.pop(context);
                    _loadData();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.folder_open_outlined, color: Colors.amber),
                  title: const Text('Simulate Empty State'),
                  trailing: _forceEmpty ? const Icon(Icons.check, color: Colors.amber) : null,
                  onTap: () {
                    setState(() {
                      _forceEmpty = true;
                      _forceError = false;
                    });
                    Navigator.pop(context);
                    _loadData();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.error_outline, color: Colors.red),
                  title: const Text('Simulate Network Error State'),
                  trailing: _forceError ? const Icon(Icons.check, color: Colors.red) : null,
                  onTap: () {
                    setState(() {
                      _forceEmpty = false;
                      _forceError = true;
                    });
                    Navigator.pop(context);
                    _loadData();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
