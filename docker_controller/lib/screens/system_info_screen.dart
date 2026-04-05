import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_background.dart';
import '../widgets/app_gradient_top_bar.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_paddings.dart';
import '../constants/app_strings.dart';
import '../providers/system_info_provider.dart';
import '../providers/app_provider.dart';
import '../widgets/info_card.dart';
import '../widgets/info_row.dart';

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
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final provider = Provider.of<SystemInfoProvider>(context, listen: false);
      if (appProvider.connectionConfig != null) {
        provider.fetchSystemData(appProvider.connectionConfig!);
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
        title: AppStrings.systemInfoTitle,
        leftWidget: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                final appProvider = Provider.of<AppProvider>(context, listen: false);
                if (appProvider.connectionConfig != null) {
                  await provider.fetchSystemData(appProvider.connectionConfig!);
                }
              },
              color: AppColors.secondaryBlue,
              backgroundColor: AppColors.backgroundColor,
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
      title: AppStrings.operatingSystem,
      children: [
        Row(
          children: [
            Container(
              padding: AppPaddings.cardIconPadding,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryCyan, AppColors.secondaryBlue],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.computer, color: AppColors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              AppStrings.operatingSystem,
              style: AppTextStyles.heading2,
            ),
          ],
        ),
        const SizedBox(height: 16),
        InfoRow(label: 'System', value: os['system'] ?? '', icon: Icons.desktop_windows),
        InfoRow(label: 'Release', value: os['release'] ?? '', icon: Icons.settings),
        InfoRow(label: 'Version', value: os['version'] ?? '', icon: Icons.info),
      ],
    );
  }

  Widget _buildHardwareInfoCard(SystemInfoProvider provider) {
    final staticInfo = provider.staticInfo;
    final cpu = staticInfo?['cpu'] ?? {};
    final gpu = staticInfo?['gpu'] ?? {};
    final disk = staticInfo?['disk'] ?? {};
    return InfoCard(
      title: AppStrings.hardware,
      children: [
        Row(
          children: [
            Container(
              padding: AppPaddings.cardIconPadding,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryCyan, AppColors.secondaryBlue],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.memory, color: AppColors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              AppStrings.hardware,
              style: AppTextStyles.heading2,
            ),
          ],
        ),
        const SizedBox(height: 16),
        InfoRow(label: 'CPU Cores', value: cpu['cores']?.toString() ?? '', icon: Icons.memory),
        InfoRow(label: 'CPU Threads', value: cpu['threads']?.toString() ?? '', icon: Icons.memory),
        InfoRow(
          label: 'CPU Model', 
          value: cpu['model'] ?? '', 
          icon: Icons.memory,
          isMultiline: true,
        ),
        InfoRow(
          label: 'GPU', 
          value: (gpu['count'] != null && gpu['count'] > 1)
              ? '${gpu['name']} (x${gpu['count']})'
              : gpu['name'] ?? 'N/A', 
          icon: Icons.memory,
          isMultiline: true,
        ),
        InfoRow(
          label: 'Memory', 
          value: provider.getMemoryInfo(), 
          icon: Icons.storage
        ),
        InfoRow(
          label: 'Disk', 
          value: disk['total_gb'] != null 
              ? '${disk['total_gb'] is num ? (disk['total_gb'] as num).toStringAsFixed(1) : disk['total_gb']} GB' 
              : '', 
          icon: Icons.sd_storage
        ),
      ],
    );
  }
} 