import 'package:docker_controller/constants/app_colors.dart';
import 'package:docker_controller/constants/app_gradients.dart';
import 'package:docker_controller/constants/app_paddings.dart';
import 'package:docker_controller/constants/app_text_styles.dart';
import 'package:docker_controller/models/app_state.dart';
import 'package:docker_controller/providers/auth_provider.dart';
import 'package:docker_controller/providers/container_detail_provider.dart';
import 'package:docker_controller/widgets/app_gradient_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import 'container_detail/actions_tab.dart';
import 'container_detail/info_tab.dart';
import 'container_detail/logs_tab.dart';
import 'container_detail/stats_tab.dart';

class ContainerDetailScreen extends StatelessWidget {
  const ContainerDetailScreen({
    super.key,
    required this.containerId,
    required this.containerName,
  });
  final String containerId;
  final String containerName;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return ChangeNotifierProvider(
          create: (_) => ContainerDetailProvider(
            authProvider: authProvider,
            containerId: containerId,
            containerName: containerName,
          )..loadContainerData(),
          child: const _ContainerDetailScreenBody(),
        );
      },
    );
  }
}

class _ContainerDetailScreenBody extends StatefulWidget {
  const _ContainerDetailScreenBody();

  @override
  State<_ContainerDetailScreenBody> createState() =>
      _ContainerDetailScreenBodyState();
}

class _ContainerDetailScreenBodyState extends State<_ContainerDetailScreenBody>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    Provider.of<ContainerDetailProvider>(
      context,
      listen: false,
    ).setTabController(_tabController);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ContainerDetailProvider>(context);
    final containerId = provider.containerId;
    final displayId = containerId.length >= 12
        ? containerId.substring(0, 12)
        : containerId;

    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.background),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppGradientTopBar(
          title: '',
          titleWidget: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                provider.containerName,
                style: AppTextStyles.heading2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(displayId, style: AppTextStyles.caption),
            ],
          ),
          leftWidget: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
          height: 100,
          padding: AppPaddings.screen,
        ),
        body: switch (provider.state) {
          AppInitial() => const SizedBox.shrink(),
          AppLoading() => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          AppSuccess() => Column(
            children: [
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
                    controller: _tabController,
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
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                    ),
                    tabs: [
                      Tab(
                        icon: const Icon(Icons.info_outline, size: 16),
                        text: AppLocalizations.of(context)!.infoTab,
                      ),
                      Tab(
                        icon: const Icon(Icons.analytics_outlined, size: 16),
                        text: AppLocalizations.of(context)!.statsTab,
                      ),
                      Tab(
                        icon: const Icon(Icons.description_outlined, size: 16),
                        text: AppLocalizations.of(context)!.logsTab,
                      ),
                      Tab(
                        icon: const Icon(Icons.settings_outlined, size: 16),
                        text: AppLocalizations.of(context)!.actionsTab,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    InfoTab(provider: provider),
                    StatsTab(provider: provider),
                    LogsTab(provider: provider),
                    ActionsTab(provider: provider),
                  ],
                ),
              ),
            ],
          ),
          AppStateError(:final failure) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.errorLoadingContainerData,
                style: AppTextStyles.heading2,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  failure.message,
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: provider.loadContainerData,
                child: Text(AppLocalizations.of(context)!.retry),
              ),
            ],
          ),
        },
      ),
    );
  }
}
