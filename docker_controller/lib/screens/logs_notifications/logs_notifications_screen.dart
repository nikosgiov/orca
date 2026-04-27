import 'package:docker_controller/constants/app_colors.dart';
import 'package:docker_controller/providers/logs_notifications_provider.dart';
import 'package:docker_controller/widgets/app_background.dart';
import 'package:docker_controller/widgets/app_gradient_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import 'widgets/logs_tab.dart';
import 'widgets/notifications_tab.dart';

class LogsNotificationsScreen extends StatelessWidget {
  const LogsNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppBackground(
      position: Offset(-40, -100),
      scale: 1.4,
      child: _LogsNotificationsScreenBody(),
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
          title: AppLocalizations.of(context)!.logsNotificationsTitle,
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
                  tabs: [
                    Tab(
                      icon: const Icon(Icons.description_outlined, size: 16),
                      text: AppLocalizations.of(context)!.logsTab,
                    ),
                    Tab(
                      icon: const Icon(Icons.notifications_outlined, size: 16),
                      text: AppLocalizations.of(context)!.notificationsTab,
                    ),
                  ],
                ),
              ),
            ),
            // Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  LogsTab(provider: provider),
                  NotificationsTab(provider: provider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
