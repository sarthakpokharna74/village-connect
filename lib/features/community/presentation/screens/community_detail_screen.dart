import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../shared/utils/auth_guard.dart';
import '../../data/models/community_model.dart';
import '../../data/repositories/community_repository.dart';

/// Detailed view for a Community Group, Organization, or Activity in Dhawalpuri.
/// Browsing is 100% public. Protected actions (Join, Volunteer, Register) are guarded by AuthGuard.
class CommunityDetailScreen extends StatefulWidget {
  final CommunityItem item;

  const CommunityDetailScreen({
    super.key,
    required this.item,
  });

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  final CommunityRepository _repository = MockCommunityRepository();
  bool _isActionLoading = false;
  late bool _hasJoined;
  late bool _hasRegistered;
  late bool _hasVolunteered;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  void _checkStatus() {
    _hasJoined = _repository.hasUserJoined(widget.item.id);
    _hasRegistered = _repository.hasUserRegistered(widget.item.id);
    _hasVolunteered = _repository.hasUserVolunteered(widget.item.id);
  }

  bool get _isActionPerformed {
    switch (widget.item.actionType) {
      case 'join':
        return _hasJoined;
      case 'volunteer':
        return _hasVolunteered;
      case 'register':
        return _hasRegistered;
      default:
        return false;
    }
  }

  Future<void> _handleAction() async {
    if (_isActionPerformed || _isActionLoading) return;

    setState(() {
      _isActionLoading = true;
    });

    try {
      const mockUserId = 'villager_user';
      String successKey = 'join_success';

      if (widget.item.actionType == 'join') {
        await _repository.joinGroup(widget.item.id, mockUserId);
        successKey = 'join_success';
      } else if (widget.item.actionType == 'volunteer') {
        await _repository.volunteer(widget.item.id, mockUserId);
        successKey = 'volunteer_success';
      } else if (widget.item.actionType == 'register') {
        await _repository.registerActivity(widget.item.id, mockUserId);
        successKey = 'register_success';
      } else {
        await Future.delayed(const Duration(milliseconds: 200));
        successKey = 'contact_success';
      }

      if (!mounted) return;

      setState(() {
        _checkStatus();
        _isActionLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate(successKey)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _isActionLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final item = widget.item;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate('community_title')),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- 1. Prototype Disclaimer Banner ---
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
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSizes.space8),
                    Expanded(
                      child: Text(
                        context.translate('sample_listing_banner'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.space16),

              // --- 2. Header Hero Card ---
              Card(
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                  side: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.12),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.space20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSizes.space12),
                            decoration: BoxDecoration(
                              color: item.categoryColor.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item.icon,
                              size: AppSizes.iconMD,
                              color: item.categoryColor,
                            ),
                          ),
                          const SizedBox(width: AppSizes.space12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: item.categoryColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                                      ),
                                      child: Text(
                                        context.translate(CommunityItem.getCategoryTitleKey(item.category)),
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: item.categoryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSizes.space8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                                      ),
                                      child: Text(
                                        context.translate('sample_tag'),
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSizes.space8),
                                Text(
                                  context.translate(item.nameKey),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.space16),
                      Text(
                        context.translate(item.descriptionKey),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          height: 1.5,
                          fontSize: 14.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.space16),

              // --- 3. Detail Fields (Purpose, Upcoming, Meeting, Location, Instructions) ---
              if (item.purposeKey != null) ...[
                _buildInfoCard(
                  context,
                  title: context.translate('purpose'),
                  content: context.translate(item.purposeKey!),
                  icon: Icons.lightbulb_outline_rounded,
                  iconColor: Colors.amber[800]!,
                ),
                const SizedBox(height: AppSizes.space12),
              ],

              if (item.upcomingActivityKey != null) ...[
                _buildInfoCard(
                  context,
                  title: context.translate('upcoming_activity'),
                  content: context.translate(item.upcomingActivityKey!),
                  icon: Icons.event_available_rounded,
                  iconColor: theme.colorScheme.primary,
                ),
                const SizedBox(height: AppSizes.space12),
              ],

              if (item.meetingInfoKey != null) ...[
                _buildInfoCard(
                  context,
                  title: context.translate('meeting_schedule'),
                  content: context.translate(item.meetingInfoKey!),
                  icon: Icons.access_time_rounded,
                  iconColor: Colors.blue[700]!,
                ),
                const SizedBox(height: AppSizes.space12),
              ],

              if (item.locationKey != null) ...[
                _buildInfoCard(
                  context,
                  title: context.translate('location'),
                  content: context.translate(item.locationKey!),
                  icon: Icons.place_outlined,
                  iconColor: Colors.red[600]!,
                ),
                const SizedBox(height: AppSizes.space12),
              ],

              if (item.organizerKey != null) ...[
                _buildInfoCard(
                  context,
                  title: context.translate('organizer'),
                  content: context.translate(item.organizerKey!),
                  icon: Icons.badge_outlined,
                  iconColor: Colors.indigo,
                  trailingBadge: item.isVerified
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified_rounded, size: 12, color: Colors.green),
                              const SizedBox(width: 4),
                              Text(
                                context.translate('verified'),
                                style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                          ),
                          child: Text(
                            context.translate('unverified_sample'),
                            style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
                          ),
                        ),
                ),
                const SizedBox(height: AppSizes.space12),
              ],

              if (item.participationInstructionsKey != null) ...[
                _buildInfoCard(
                  context,
                  title: context.translate('participation_instructions'),
                  content: context.translate(item.participationInstructionsKey!),
                  icon: Icons.how_to_reg_outlined,
                  iconColor: Colors.teal[700]!,
                ),
                const SizedBox(height: AppSizes.space12),
              ],

              const SizedBox(height: AppSizes.space20),

              // --- 4. Protected Action Call to Action Button ---
              ElevatedButton(
                onPressed: _isActionLoading || _isActionPerformed
                    ? null
                    : () {
                        AuthGuard.run(
                          context,
                          explanationKey: 'community_login_action',
                          onAuthenticated: _handleAction,
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isActionPerformed
                      ? theme.colorScheme.surfaceContainerHighest
                      : item.categoryColor,
                  foregroundColor: _isActionPerformed
                      ? theme.colorScheme.onSurfaceVariant
                      : Colors.white,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, AppSizes.touchTargetMin),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  ),
                ),
                child: _isActionLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator.adaptive(strokeWidth: 2.5),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isActionPerformed ? Icons.check_circle_rounded : _getActionIcon(item.actionType),
                            size: 18,
                          ),
                          const SizedBox(width: AppSizes.space8),
                          Text(
                            context.translate(_getActionLabelKey(item.actionType, _isActionPerformed)),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: AppSizes.space24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    required Color iconColor,
    Widget? trailingBadge,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: AppSizes.iconSM, color: iconColor),
                const SizedBox(width: AppSizes.space8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                ?trailingBadge,
              ],
            ),
            const SizedBox(height: AppSizes.space8),
            Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActionIcon(String actionType) {
    switch (actionType) {
      case 'join':
        return Icons.group_add_rounded;
      case 'volunteer':
        return Icons.volunteer_activism_rounded;
      case 'register':
        return Icons.app_registration_rounded;
      default:
        return Icons.mail_outline_rounded;
    }
  }

  String _getActionLabelKey(String actionType, bool isPerformed) {
    if (isPerformed) {
      switch (actionType) {
        case 'join':
          return 'joined_group';
        case 'volunteer':
          return 'volunteered';
        case 'register':
          return 'registered_activity';
        default:
          return 'contact_group';
      }
    }
    switch (actionType) {
      case 'join':
        return 'join_group';
      case 'volunteer':
        return 'volunteer_now';
      case 'register':
        return 'register_activity';
      default:
        return 'contact_group';
    }
  }
}
