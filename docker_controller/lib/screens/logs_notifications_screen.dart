import 'package:flutter/material.dart';
import '../widgets/app_background.dart';
import '../widgets/app_gradient_top_bar.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_paddings.dart';
import '../widgets/app_button.dart';
import '../constants/app_strings.dart';
import 'package:provider/provider.dart';
import '../providers/logs_notifications_provider.dart';

class LogsNotificationsScreen extends StatelessWidget {
  const LogsNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      position: const Offset(-40, -100),
      scale: 1.4,
      child: const _LogsNotificationsScreenBody(),
    );
  }
}

class _LogsNotificationsScreenBody extends StatelessWidget {
  const _LogsNotificationsScreenBody();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LogsNotificationsProvider>(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppGradientTopBar(
          title: AppStrings.logsNotificationsTitle,
          leftWidget: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
        ),
        body: Column(
          children: [
            // Tab Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.glassBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: AppColors.white,
                  unselectedLabelColor: AppColors.textMuted,
                  labelStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                  tabs: const [
                    Tab(icon: Icon(Icons.description_outlined, size: 16), text: AppStrings.logsTab),
                    Tab(icon: Icon(Icons.notifications_outlined, size: 16), text: AppStrings.notificationsTab),
                  ],
                ),
              ),
            ),
            // Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  _LogsTab(provider: provider),
                  _NotificationsTab(provider: provider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogsTab extends StatelessWidget {
  final LogsNotificationsProvider provider;
  const _LogsTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final filteredLogs = provider.getFilteredLogs();
    return Column(
      children: [
        // Controls
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: AppPaddings.card,
          decoration: BoxDecoration(
            color: AppColors.glassBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: provider.selectedLogLevel,
                      dropdownColor: const Color(0xFF1A0B3B),
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: AppStrings.logLevelLabel,
                        labelStyle: const TextStyle(color: AppColors.textMuted),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.glassBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.glassBorder),
                        ),
                        contentPadding: AppPaddings.dropdownContentPadding,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text(AppStrings.logLevelAll)),
                        DropdownMenuItem(value: 'ERROR', child: Text(AppStrings.logLevelError)),
                        DropdownMenuItem(value: 'WARN', child: Text(AppStrings.logLevelWarn)),
                        DropdownMenuItem(value: 'INFO', child: Text(AppStrings.logLevelInfo)),
                        DropdownMenuItem(value: 'DEBUG', child: Text(AppStrings.logLevelDebug)),
                      ],
                      onChanged: (value) {
                        provider.selectedLogLevel = value ?? 'All';
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: provider.selectedContainer,
                      dropdownColor: const Color(0xFF1A0B3B),
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: AppStrings.containerLabel,
                        labelStyle: const TextStyle(color: AppColors.textMuted),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.glassBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.glassBorder),
                        ),
                        contentPadding: AppPaddings.dropdownContentPadding,
                      ),
                      items: [
                        const DropdownMenuItem(value: 'All', child: Text(AppStrings.logLevelAll)),
                        ...provider.containers.map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(
                                c,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )),
                      ],
                      onChanged: (value) {
                        provider.selectedContainer = value ?? 'All';
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Switch(
                    value: provider.followLogs,
                    onChanged: (value) {
                      provider.followLogs = value;
                    },
                    activeThumbColor: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(AppStrings.followLogs, style: const TextStyle(color: AppColors.textPrimary)),
                  ),
                  const SizedBox(width: 8),
                  AppButton(
                    label: AppStrings.clear,
                    onPressed: provider.clearLogs,
                    color: AppColors.grey,
                    textColor: AppColors.white,
                    outlined: false,
                    padding: AppPaddings.headerButtonPadding,
                  ),
                ],
              ),
            ],
          ),
        ),
        // Logs list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            itemCount: filteredLogs.length,
            itemBuilder: (context, index) {
              final log = filteredLogs[index];
              return _LogItem(log: log);
            },
          ),
        ),
      ],
    );
  }
}

class _LogItem extends StatelessWidget {
  final Map<String, dynamic> log;
  const _LogItem({required this.log});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (log['color'] as Color).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  log['level'],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: log['color'],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                log['timestamp'],
                style: AppTextStyles.caption,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  log['container'],
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            log['message'],
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _NotificationsTab extends StatelessWidget {
  final LogsNotificationsProvider provider;
  const _NotificationsTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final notifications = provider.notifications;
    return Column(
      children: [
        // Header
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: AppPaddings.card,
          decoration: BoxDecoration(
            color: AppColors.glassBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: [
              Text(
                AppStrings.notificationsTab,
                style: AppTextStyles.heading2,
              ),
              const Spacer(),
              AppButton(
                label: AppStrings.markAllRead,
                onPressed: () => _markAllAsRead(context, provider),
                color: AppColors.primary,
                textColor: AppColors.white,
                outlined: false,
                padding: AppPaddings.headerButtonPadding,
              ),
            ],
          ),
        ),
        // Notifications list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _NotificationItem(
                notification: notification,
                provider: provider,
              );
            },
          ),
        ),
      ],
    );
  }

  void _markAllAsRead(BuildContext context, LogsNotificationsProvider provider) {
    provider.markAllAsRead();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final Map<String, dynamic> notification;
  final LogsNotificationsProvider provider;
  const _NotificationItem({required this.notification, required this.provider});

  @override
  Widget build(BuildContext context) {
    Color typeColor;
    IconData typeIcon;

    switch (notification['type']) {
      case 'success':
        typeColor = AppColors.successGreen;
        typeIcon = Icons.check_circle;
        break;
      case 'warning':
        typeColor = AppColors.warningYellow;
        typeIcon = Icons.warning;
        break;
      case 'error':
        typeColor = AppColors.errorRed;
        typeIcon = Icons.error;
        break;
      case 'info':
        typeColor = AppColors.primary;
        typeIcon = Icons.info;
        break;
      default:
        typeColor = AppColors.grey;
        typeIcon = Icons.info_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: notification['read']
            ? AppColors.glassBg
            : typeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification['read']
              ? AppColors.glassBorder
              : typeColor.withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(typeIcon, color: typeColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification['title'] ?? 'Notification',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: (notification['read'] ?? false) ? FontWeight.w500 : FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification['message'] ?? '',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification['timestamp'] ?? '',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            if (!(notification['read'] ?? false))
              Container(
                margin: const EdgeInsets.only(left: 8, top: 2),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: typeColor,
                  shape: BoxShape.circle,
                ),
              ),
            PopupMenuButton<String>(
              color: const Color(0xFF1A0B3B),
              onSelected: (action) {
                if (action == 'mark_read') {
                  provider.markNotificationAsRead(notification);
                } else if (action == 'delete') {
                  _deleteNotification(context, provider, notification);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'mark_read',
                  child: Row(
                    children: [
                      Icon(Icons.done, color: AppColors.successGreen),
                      const SizedBox(width: 8),
                      Text(
                        notification['read'] ? 'Mark Unread' : 'Mark Read',
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: AppColors.errorRed),
                      const SizedBox(width: 8),
                      const Text('Delete', style: TextStyle(color: AppColors.textPrimary)),
                    ],
                  ),
                ),
              ],
              child: const Icon(Icons.more_vert, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteNotification(BuildContext context, LogsNotificationsProvider provider, Map<String, dynamic> notification) {
    provider.deleteNotification(notification);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification deleted'),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }
}