import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../utils/system_info_utils.dart';
import '../app_button.dart';
import 'home_widgets.dart';

class SystemNodeCard extends StatelessWidget {
  const SystemNodeCard({
    super.key,
    required this.systemInfo,
    required this.connectionUri,
  });
  final Map<String, dynamic>? systemInfo;
  final String? connectionUri;

  @override
  Widget build(BuildContext context) {
    final hostname = SystemInfoUtils.getHostname(systemInfo);
    final os = SystemInfoUtils.getOsInfo(systemInfo);
    final dockerVer = SystemInfoUtils.getDockerVersion(systemInfo);
    final arch = SystemInfoUtils.getCpuInfo(systemInfo);
    final ram = SystemInfoUtils.getMemoryInfo(systemInfo);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Container(
              height: 160,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1565C0),
                    Color(0xFF6A1B9A),
                    Color(0xFFC62828),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.08,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 8,
                            ),
                        itemCount: 80,
                        itemBuilder: (_, __) => Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Icon(
                            Icons.storage_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          hostname.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 9,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 2.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        connectionUri ?? 'Unknown',
                        style: AppTextStyles.heading1.copyWith(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const StatusBadge(
                      label: 'Online',
                      color: AppColors.success,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                InfoGrid2Col(
                  items: [
                    InfoPair(label: 'OS / Kernel', value: os),
                    InfoPair(label: 'Docker Version', value: dockerVer),
                    InfoPair(label: 'Architecture', value: arch),
                    InfoPair(label: 'System RAM', value: ram),
                  ],
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: AppButton(
                    label: 'Inspect Node',
                    onPressed: () => context.pushNamed('systemInfo'),
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
