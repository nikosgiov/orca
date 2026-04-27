import 'package:docker_controller/constants/app_colors.dart';
import 'package:docker_controller/constants/app_paddings.dart';
import 'package:docker_controller/core/di/service_locator.dart';
import 'package:docker_controller/providers/auth_provider.dart';
import 'package:docker_controller/providers/settings_provider.dart';
import 'package:docker_controller/services/notification_service.dart';
import 'package:docker_controller/widgets/app_background.dart';
import 'package:docker_controller/widgets/app_card.dart';
import 'package:docker_controller/widgets/settings_card_header.dart';
import 'package:docker_controller/widgets/settings_list_tile.dart';
import 'package:docker_controller/widgets/settings_switch_tile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';

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
          SettingsCardHeader(
            icon: Icons.wifi,
            title: AppLocalizations.of(context)!.connection,
            gradientColors: const [AppColors.primary, AppColors.secondary],
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
                                ? AppLocalizations.of(context)!.connected
                                : AppLocalizations.of(context)!.disconnected,
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
            title: AppLocalizations.of(context)!.autoRefresh,
            subtitle: AppLocalizations.of(context)!.autoRefreshSubtitle,
            value: context.watch<SettingsProvider>().autoRefresh,
            onChanged: (value) =>
                context.read<SettingsProvider>().setAutoRefresh(value),
            activeColor: AppColors.primary,
          ),
          const Divider(),
          SettingsListTile(
            title: AppLocalizations.of(context)!.refreshInterval,
            subtitle:
                AppLocalizations.of(context)!.seconds(context.watch<SettingsProvider>().refreshInterval),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showRefreshIntervalDialog,
          ),

          const Divider(),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return SettingsListTile(
                title: AppLocalizations.of(context)!.logout,
                subtitle: AppLocalizations.of(context)!.logoutSubtitle,
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
          SettingsCardHeader(
            icon: Icons.notifications,
            title: AppLocalizations.of(context)!.notifications,
            gradientColors: const [AppColors.primary, AppColors.secondary],
          ),
          const SizedBox(height: 16),
          SettingsSwitchTile(
            title: AppLocalizations.of(context)!.enableNotifications,
            subtitle: AppLocalizations.of(context)!.showPushNotifications,
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
            title: AppLocalizations.of(context)!.containerEvents,
            subtitle: AppLocalizations.of(context)!.notifyContainerChanges,
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
            title: AppLocalizations.of(context)!.resourceAlerts,
            subtitle: AppLocalizations.of(context)!.notifyHighUsage,
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
            title: AppLocalizations.of(context)!.notificationSettings,
            subtitle: AppLocalizations.of(context)!.configPushThresholds,
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
          SettingsCardHeader(
            icon: Icons.info,
            title: AppLocalizations.of(context)!.about,
            gradientColors: const [AppColors.primary, AppColors.secondary],
          ),
          const SizedBox(height: 16),
          SettingsListTile(
            title: AppLocalizations.of(context)!.systemInformation,
            subtitle: AppLocalizations.of(context)!.viewDetailedInfo,
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
          title: Text(AppLocalizations.of(context)!.refreshInterval),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: tempInterval.toDouble(),
                min: 5,
                max: 300,
                divisions: 59,
                label: AppLocalizations.of(context)!.seconds(tempInterval),
                onChanged: (value) {
                  setLocalState(() => tempInterval = value.toInt());
                },
              ),
              Text(AppLocalizations.of(context)!.seconds(tempInterval)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<SettingsProvider>().setRefreshInterval(
                  tempInterval,
                );
              },
              child: Text(AppLocalizations.of(context)!.save),
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
        title: Text(AppLocalizations.of(context)!.logout),
        content: Text(
          AppLocalizations.of(context)!.logoutConfirm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.logout();
              if (!context.mounted) {
                return;
              }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.loggedOutSuccessfully),
                    backgroundColor: AppColors.success,
                  ),
                );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(AppLocalizations.of(context)!.logout),
          ),
        ],
      ),
    );
  }
}
