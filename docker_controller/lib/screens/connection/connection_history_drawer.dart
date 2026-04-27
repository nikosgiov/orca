import 'package:docker_controller/constants/app_colors.dart';
import 'package:docker_controller/constants/app_text_styles.dart';
import 'package:docker_controller/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ConnectionHistoryDrawer extends StatelessWidget {
  const ConnectionHistoryDrawer({
    super.key,
    required this.history,
    required this.onSelect,
  });

  final List<String> history;
  final Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppLocalizations.of(context)!.recentConnections,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.slate400,
              ),
        ),
        const SizedBox(height: 20),
        if (history.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: 48,
                    color: AppColors.slate400.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noHistory,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.slate400.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final uri = history[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.dns_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    uri,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.slate400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () => onSelect(uri),
                );
              },
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}
