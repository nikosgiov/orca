import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_background.dart';
import '../providers/app_provider.dart';
import '../providers/settings_provider.dart';
import 'system_info_screen.dart';


import 'notification_settings_screen.dart';
import '../services/notification_service.dart';
import '../widgets/app_gradient_top_bar.dart';
import '../constants/app_colors.dart';
import '../constants/app_paddings.dart';
import '../widgets/app_card.dart';
import '../constants/app_strings.dart';
import '../widgets/settings_card_header.dart';
import '../widgets/settings_switch_tile.dart';
import '../widgets/settings_list_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _dockerMonitoringEnabled = true;
  bool _resourceMonitoringEnabled = true;
  String? _baseUrl;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final appProvider = context.read<AppProvider>();
    final connection = appProvider.connectionConfig;
    if (connection != null) {
      final protocol = connection.useTls ? 'https://' : 'http://';
      _baseUrl = '$protocol${connection.uri}';
      await _notificationService.loadPreferences(_baseUrl!);
      setState(() {
        _dockerMonitoringEnabled = _notificationService.dockerMonitoringEnabled;
        _resourceMonitoringEnabled = _notificationService.resourceMonitoringEnabled;
      });
    }
  }

  Future<void> _syncNotificationSettings() async {
    final appProvider = context.read<AppProvider>();
    final connection = appProvider.connectionConfig;
    if (connection == null) return;

    try {
      final protocol = connection.useTls ? 'https://' : 'http://';
      final baseUrl = '$protocol${connection.uri}';

      await _notificationService.registerForNotifications(
        baseUrl: baseUrl,
        token: connection.token ?? '',
      );
    } catch (e) {
      debugPrint('Failed to sync notification settings: $e');
    }
  }

  Future<void> _toggleAllNotifications(bool enabled) async {
    final appProvider = context.read<AppProvider>();
    final connection = appProvider.connectionConfig;
    if (connection == null) return;

    try {
      final protocol = connection.useTls ? 'https://' : 'http://';
      final baseUrl = '$protocol${connection.uri}';

      if (enabled) {
        await _notificationService.registerForNotifications(
          baseUrl: baseUrl,
          token: connection.token ?? '',
        );
      } else {
        await _notificationService.unregisterFromNotifications(
          baseUrl: baseUrl,
          token: connection.token ?? '',
        );
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
      appBar: AppGradientTopBar(
        title: AppStrings.settingsTitle,
      ),
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
            gradientColors: [AppColors.primaryCyan, AppColors.secondaryBlue],
          ),
          const SizedBox(height: 16),
          Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              return Container(
                padding: AppPaddings.statusContainerPadding,
                decoration: BoxDecoration(
                  color: appProvider.isConnected 
                      ? AppColors.successGreen.withValues(alpha: 0.1)
                      : AppColors.errorRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: appProvider.isConnected 
                        ? AppColors.successGreen
                        : AppColors.errorRed,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      appProvider.isConnected ? Icons.check_circle : Icons.error,
                      color: appProvider.isConnected 
                          ? AppColors.successGreen
                          : AppColors.errorRed,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appProvider.isConnected ? AppStrings.connected : AppStrings.disconnected,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: appProvider.isConnected 
                                  ? AppColors.successGreen
                                  : AppColors.errorRed,
                            ),
                          ),
                          if (appProvider.connectionConfig != null)
                            Text(
                              appProvider.connectionConfig!.uri,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.grey,
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
            activeColor: AppColors.primaryCyan,
          ),
          const Divider(),
          SettingsListTile(
            title: 'Refresh Interval',
            subtitle: '${context.watch<SettingsProvider>().refreshInterval} seconds',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showRefreshIntervalDialog,
          ),

          const Divider(),
          Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              return SettingsListTile(
                title: 'Logout',
                subtitle: 'Disconnect and clear saved data',
                trailing: const Icon(Icons.logout, color: AppColors.errorRed),
                onTap: () => _showLogoutDialog(appProvider),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsCard() {
    final notificationsEnabled = context.watch<SettingsProvider>().notificationsEnabled;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SettingsCardHeader(
            icon: Icons.notifications,
            title: AppStrings.notifications,
            gradientColors: [AppColors.primaryCyan, AppColors.secondaryBlue],
          ),
          const SizedBox(height: 16),
          SettingsSwitchTile(
            title: 'Enable Notifications',
            subtitle: 'Show push notifications',
            value: notificationsEnabled,
            onChanged: (value) async {
              context.read<SettingsProvider>().setNotificationsEnabled(value);
              await _toggleAllNotifications(value);
            },
            activeColor: AppColors.primaryCyan,
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
                          dockerMonitoring: value, url: _baseUrl);
                      _syncNotificationSettings();
                    }
                  : null,
              activeThumbColor: AppColors.primaryCyan,
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
                          resourceMonitoring: value, url: _baseUrl);
                      _syncNotificationSettings();
                    }
                  : null,
              activeThumbColor: AppColors.primaryCyan,
            ),
          ),
          const Divider(),
          SettingsListTile(
            title: 'Notification Settings',
            subtitle: 'Configure push notifications and thresholds',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsScreen(),
                ),
              ).then((_) => _loadNotificationSettings()); // Reload when returning
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
            gradientColors: [AppColors.primaryCyan, AppColors.secondaryBlue],
          ),
          const SizedBox(height: 16),
          SettingsListTile(
            title: 'System Information',
            subtitle: 'View detailed system info',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SystemInfoScreen(),
                ),
              );
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
                context.read<SettingsProvider>().setRefreshInterval(tempInterval);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(AppProvider appProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout? This will disconnect from the Docker host and clear all saved connection data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await appProvider.logout();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully'),
                  backgroundColor: AppColors.successGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
} 
