import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_paddings.dart';
import '../../../constants/app_strings.dart';
import '../../../models/log_level.dart';
import '../../../providers/logs_notifications_provider.dart';
import '../../../widgets/app_button.dart';
import 'log_item.dart';

class LogsTab extends StatelessWidget {
  const LogsTab({super.key, required this.provider});
  final LogsNotificationsProvider provider;

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
                    child: DropdownButtonFormField<LogLevel>(
                      isExpanded: true,
                      initialValue: provider.selectedLogLevel,
                      dropdownColor: const Color(0xFF1A0B3B),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        labelText: AppStrings.logLevelLabel,
                        labelStyle: const TextStyle(color: AppColors.textMuted),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.glassBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.glassBorder,
                          ),
                        ),
                        contentPadding: AppPaddings.dropdownContentPadding,
                      ),
                      items: LogLevel.values.map((level) {
                        return DropdownMenuItem(
                          value: level,
                          child: Text(level.label),
                        );
                      }).toList(),
                      onChanged: (value) {
                        provider.selectedLogLevel = value ?? LogLevel.all;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: provider.selectedContainer,
                      dropdownColor: const Color(0xFF1A0B3B),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        labelText: AppStrings.containerLabel,
                        labelStyle: const TextStyle(color: AppColors.textMuted),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.glassBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.glassBorder,
                          ),
                        ),
                        contentPadding: AppPaddings.dropdownContentPadding,
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: 'All',
                          child: Text(AppStrings.logLevelAll),
                        ),
                        ...provider.containers.map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(c, overflow: TextOverflow.ellipsis),
                          ),
                        ),
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
                  const Expanded(
                    child: Text(
                      AppStrings.followLogs,
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppButton(
                    label: AppStrings.clear,
                    onPressed: provider.clearLogs,
                    color: AppColors.slate400,
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
              return LogItem(log: log);
            },
          ),
        ),
      ],
    );
  }
}
