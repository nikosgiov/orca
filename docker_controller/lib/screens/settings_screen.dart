import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_paddings.dart';
import '../constants/app_strings.dart';
import '../core/di/service_locator.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import '../widgets/app_background.dart';
import '../widgets/app_card.dart';
import '../widgets/app_gradient_top_bar.dart';
import '../widgets/settings_card_header.dart';
import '../widgets/settings_list_tile.dart';
import '../widgets/settings_switch_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final NotificationService _notificationService;
  bool _dockerMonitoringEnabled = true;
  bool _resourceMonitoringEnabled = true;
  String? _baseUrl;

  @override
  void initState() {
    super.initState();
    _notificationService = getIt<NotificationService>();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final authProvider = context.read<AuthProvider>();
    final connection = authProvider.connectionConfig;
    if (connection != null) {
      final protocol = connection.useTls ? 'https://' : 'http://';
      _baseUrl = '$protocol${connection.uri}';
      await _notificationService.loadPreferences(_baseUrl!);
      setState(() {
        _dockerMonitoringEnabled = _notificationService.dockerMonitoringEnabled;
        _resourceMonitoringEnabled =
            _notificationService.resourceMonitoringEnabled;
      });
    }
  }

  Future<void> _syncNotificationSettings() async {
    final authProvider = context.read<AuthProvider>();
    final connection = authProvider.connectionConfig;
    if (connection == null) {
      return;
    }

    try {
      await _notificationService.registerForNotifications();
    } catch (e) {
      debugPrint('Failed to sync notification settings: $e');
    }
  }

  Future<void> _toggleAllNotifications(bool enabled) async {
    final authProvider = context.read<AuthProvider>();
    final connection = authProvider.connectionConfig;
    if (connection == null) {
      return;
    }

    try {
      if (enabled) {
        await _notificationService.registerForNotifications();
      } else {
        await _notificationService.unregisterFromNotifications();
      }
    } catch (e) {
      debugPrint('Failed to toggle notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      position: const Offset(40, -150),
      scale: 1.4,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const AppGradientTopBar(title: AppStrings.settingsTitle),
        body: SingleChildScrollView(
          padding: AppPaddings.screen.copyWith(bottom: 120),
          child: Column(
            children: [
              _buildConnectionCard(),
              const SizedBox(height: 16),
              _buildNotificationsCard(),
              const SizedBox(height: 16),
              _buildAboutCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SettingsCardHeader(
            icon: Icons.wifi,
            title: AppStrings.connection,
            gradientColors: [AppColors.primary, AppColors.secondary],
          ),
          const SizedBox(height: 16),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Container(
                padding: AppPaddings.statusContainerPadding,
                decoration: BoxDecoration(
                  color: authProvider.isConnected
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: authProvider.isConnected
                        ? AppColors.success
                        : AppColors.error,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      authProvider.isConnected
                          ? Icons.check_circle
                          : Icons.error,
                      color: authProvider.isConnected
                          ? AppColors.success
                          : AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authProvider.isConnected
                                ? AppStrings.connected
                                : AppStrings.disconnected,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: authProvider.isConnected
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                          if (authProvider.connectionConfig != null)
                            Text(
                              authProvider.connectionConfig!.uri,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.slate400,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          SettingsSwitchTile(
            title: 'Auto Refresh',
            subtitle: 'Automatically refresh data',
            value: context.watch<SettingsProvider>().autoRefresh,
            onChanged: (value) =>
                context.read<SettingsProvider>().setAutoRefresh(value),
            activeColor: AppColors.primary,
          ),
          const Divider(),
          SettingsListTile(
            title: 'Refresh Interval',
            subtitle:
                '${context.watch<SettingsProvider>().refreshInterval} seconds',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showRefreshIntervalDialog,
          ),

          const Divider(),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return SettingsListTile(
                title: 'Logout',
                subtitle: 'Disconnect and clear saved data',
                trailing: const Icon(Icons.logout, color: AppColors.error),
                onTap: () => _showLogoutDialog(authProvider),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsCard() {
    final notificationsEnabled = context
        .watch<SettingsProvider>()
        .notificationsEnabled;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SettingsCardHeader(
            icon: Icons.notifications,
            title: AppStrings.notifications,
            gradientColors: [AppColors.primary, AppColors.secondary],
          ),
          const SizedBox(height: 16),
          SettingsSwitchTile(
            title: 'Enable Notifications',
            subtitle: 'Show push notifications',
            value: notificationsEnabled,
            onChanged: (value) async {
              await context.read<SettingsProvider>().setNotificationsEnabled(
                value,
              );
              await _toggleAllNotifications(value);
            },
            activeColor: AppColors.primary,
          ),
          const Divider(),
          SettingsListTile(
            title: 'Container Events',
            subtitle: 'Notify on container state changes',
            trailing: Switch(
              value: notificationsEnabled ? _dockerMonitoringEnabled : false,
              onChanged: notificationsEnabled
                  ? (value) async {
                      setState(() => _dockerMonitoringEnabled = value);
                      await _notificationService.setNotificationPreferences(
                        dockerMonitoring: value,
                        url: _baseUrl,
                      );
                      await _syncNotificationSettings();
                    }
                  : null,
              activeThumbColor: AppColors.primary,
            ),
          ),
          const Divider(),
          SettingsListTile(
            title: 'Resource Alerts',
            subtitle: 'Notify on high resource usage',
            trailing: Switch(
              value: notificationsEnabled ? _resourceMonitoringEnabled : false,
              onChanged: notificationsEnabled
                  ? (value) async {
                      setState(() => _resourceMonitoringEnabled = value);
                      await _notificationService.setNotificationPreferences(
                        resourceMonitoring: value,
                        url: _baseUrl,
                      );
                      await _syncNotificationSettings();
                    }
                  : null,
              activeThumbColor: AppColors.primary,
            ),
          ),
          const Divider(),
          SettingsListTile(
            title: 'Notification Settings',
            subtitle: 'Configure push notifications and thresholds',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              context
                  .pushNamed('notificationSettings')
                  .then((_) => _loadNotificationSettings());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SettingsCardHeader(
            icon: Icons.info,
            title: AppStrings.about,
            gradientColors: [AppColors.primary, AppColors.secondary],
          ),
          const SizedBox(height: 16),
          SettingsListTile(
            title: 'System Information',
            subtitle: 'View detailed system info',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              context.pushNamed('systemInfo');
            },
          ),
        ],
      ),
    );
  }

  void _showRefreshIntervalDialog() {
    int tempInterval = context.read<SettingsProvider>().refreshInterval;
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: const Text('Refresh Interval'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: tempInterval.toDouble(),
                min: 5,
                max: 300,
                divisions: 59,
                label: '$tempInterval seconds',
                onChanged: (value) {
                  setLocalState(() => tempInterval = value.toInt());
                },
              ),
              Text('$tempInterval seconds'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<SettingsProvider>().setRefreshInterval(
                  tempInterval,
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout? This will disconnect from the Docker host and clear all saved connection data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.logout();
              if (!context.mounted) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
