import 'package:docker_controller/constants/app_colors.dart';
import 'package:docker_controller/constants/app_paddings.dart';
import 'package:docker_controller/constants/app_text_styles.dart';
import 'package:docker_controller/providers/auth_provider.dart';
import 'package:docker_controller/providers/system_info_provider.dart';
import 'package:docker_controller/widgets/app_background.dart';
import 'package:docker_controller/widgets/app_gradient_top_bar.dart';
import 'package:docker_controller/widgets/info_card.dart';
import 'package:docker_controller/widgets/info_row.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';

class SystemInfoScreen extends StatelessWidget {
  const SystemInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SystemInfoProvider(),
      child: const _SystemInfoScreenBody(),
    );
  }
}

class _SystemInfoScreenBody extends StatefulWidget {
  const _SystemInfoScreenBody();

  @override
  State<_SystemInfoScreenBody> createState() => _SystemInfoScreenBodyState();
}

class _SystemInfoScreenBodyState extends State<_SystemInfoScreenBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final provider = Provider.of<SystemInfoProvider>(context, listen: false);
      if (authProvider.connectionConfig != null) {
        provider.fetchSystemData(authProvider.connectionConfig!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SystemInfoProvider>(context);
    final isLoading = provider.staticInfo == null;
    return AppBackground(
      position: const Offset(-40, 100),
      scale: 1.4,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppGradientTopBar(
          title: AppLocalizations.of(context)!.systemInfoTitle,
          leftWidget: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  if (authProvider.connectionConfig != null) {
                    await provider.fetchSystemData(
                      authProvider.connectionConfig!,
                    );
                  }
                },
                color: AppColors.secondary,
                backgroundColor: AppColors.backgroundDark,
                child: SingleChildScrollView(
                  padding: AppPaddings.screen,
                  child: Column(
                    children: [
                      _buildSystemInfoCard(provider),
                      const SizedBox(height: 16),
                      _buildHardwareInfoCard(provider),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSystemInfoCard(SystemInfoProvider provider) {
    final staticInfo = provider.staticInfo;
    final os = staticInfo?['os'] ?? {};
    return InfoCard(
      title: AppLocalizations.of(context)!.operatingSystem,
      children: [
        Row(
          children: [
            Container(
              padding: AppPaddings.cardIconPadding,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.computer,
                color: AppColors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)!.operatingSystem,
              style: AppTextStyles.heading2,
            ),
          ],
        ),
        const SizedBox(height: 16),
        InfoRow(
          label: AppLocalizations.of(context)!.system,
          value: os['system'] ?? '',
          icon: Icons.desktop_windows,
        ),
        InfoRow(
          label: AppLocalizations.of(context)!.release,
          value: os['release'] ?? '',
          icon: Icons.settings,
        ),
        InfoRow(label: AppLocalizations.of(context)!.version, value: os['version'] ?? '', icon: Icons.info),
      ],
    );
  }

  Widget _buildHardwareInfoCard(SystemInfoProvider provider) {
    final staticInfo = provider.staticInfo;
    final cpu = staticInfo?['cpu'] ?? {};
    final gpu = staticInfo?['gpu'] ?? {};
    final disk = staticInfo?['disk'] ?? {};
    return InfoCard(
      title: AppLocalizations.of(context)!.hardware,
      children: [
        Row(
          children: [
            Container(
              padding: AppPaddings.cardIconPadding,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.memory, color: AppColors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(AppLocalizations.of(context)!.hardware, style: AppTextStyles.heading2),
          ],
        ),
        const SizedBox(height: 16),
        InfoRow(
          label: AppLocalizations.of(context)!.cpuCores,
          value: cpu['cores']?.toString() ?? '',
          icon: Icons.memory,
        ),
        InfoRow(
          label: AppLocalizations.of(context)!.cpuThreads,
          value: cpu['threads']?.toString() ?? '',
          icon: Icons.memory,
        ),
        InfoRow(
          label: AppLocalizations.of(context)!.cpuModel,
          value: cpu['model'] ?? '',
          icon: Icons.memory,
          isMultiline: true,
        ),
        InfoRow(
          label: AppLocalizations.of(context)!.gpu,
          value: (gpu['count'] != null && gpu['count'] > 1)
              ? '${gpu['name']} (x${gpu['count']})'
              : gpu['name'] ?? 'N/A',
          icon: Icons.memory,
          isMultiline: true,
        ),
        InfoRow(
          label: AppLocalizations.of(context)!.memory,
          value: provider.getMemoryInfo(),
          icon: Icons.storage,
        ),
        InfoRow(
          label: AppLocalizations.of(context)!.disk,
          value: disk['total_gb'] != null
              ? '${disk['total_gb'] is num ? (disk['total_gb'] as num).toStringAsFixed(1) : disk['total_gb']} GB'
              : '',
          icon: Icons.sd_storage,
        ),
      ],
    );
  }
}
