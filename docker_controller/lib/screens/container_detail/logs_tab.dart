import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/container_detail_provider.dart';
import '../../widgets/app_search_bar.dart';

class LogsTab extends StatelessWidget {
  const LogsTab({super.key, required this.provider});
  final ContainerDetailProvider provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _LogControls(provider: provider),
        Expanded(
          child: _LogDisplay(
            logs: provider.filteredLogs,
            searchQuery: provider.logSearch,
          ),
        ),
      ],
    );
  }
}

class _LogControls extends StatelessWidget {
  const _LogControls({required this.provider});
  final ContainerDetailProvider provider;

  @override
  Widget build(BuildContext context) {
    final hasLogs = provider.logs != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: const BoxDecoration(
        color: AppColors.glassBg,
        border: Border(bottom: BorderSide(color: AppColors.glassBorder)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AppSearchBar(
                  value: provider.logSearch,
                  hintText: 'Search logs...',
                  onChanged: provider.setLogSearch,
                ),
              ),
              const SizedBox(width: 8),
              _GlassPillButton(
                label: AppStrings.refresh,
                icon: Icons.refresh,
                color: AppColors.primary,
                onPressed: hasLogs ? provider.loadContainerData : null,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTimeChip('15m', '15m'),
                const SizedBox(width: 6),
                _buildTimeChip('1h', '1h'),
                const SizedBox(width: 6),
                _buildTimeChip('24h', '24h'),
                const SizedBox(width: 6),
                _buildTimeChip('All Time', null),

                const SizedBox(width: 16),
                Container(width: 1, height: 20, color: AppColors.glassBorder),
                const SizedBox(width: 16),

                const Text('Lines:', style: AppTextStyles.caption),
                const SizedBox(width: 8),
                _buildTailDropdown(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeChip(String label, String? sinceValue) {
    final isSelected = provider.logSince == sinceValue;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: isSelected ? Colors.white : AppColors.textMuted,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          provider.setLogSince(sinceValue);
        }
      },
      backgroundColor: Colors.transparent,
      selectedColor: AppColors.primary.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.glassBorder,
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildTailDropdown() {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: provider.logTail,
          isDense: true,
          dropdownColor: AppColors.backgroundMid,
          icon: const Icon(
            Icons.arrow_drop_down,
            color: AppColors.textMuted,
            size: 16,
          ),
          style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
          onChanged: (int? newValue) {
            if (newValue != null) {
              provider.setLogTail(newValue);
            }
          },
          items: const [
            DropdownMenuItem(value: 100, child: Text('100')),
            DropdownMenuItem(value: 500, child: Text('500')),
            DropdownMenuItem(value: 1000, child: Text('1000')),
            DropdownMenuItem(value: 0, child: Text('All')),
          ],
        ),
      ),
    );
  }
}

class _GlassPillButton extends StatelessWidget {
  const _GlassPillButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onPressed,
  });
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 38, // matches AppSearchBar height
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: disabled
              ? AppColors.glassOverlay
              : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: disabled
                ? AppColors.glassBorder
                : color.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: disabled ? AppColors.textSubtle : color,
            ),
            const SizedBox(width: 6),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: disabled ? AppColors.textSubtle : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogDisplay extends StatelessWidget {
  const _LogDisplay({required this.logs, required this.searchQuery});
  final String? logs;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF050014),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: logs == null || logs!.isEmpty
          ? const Center(
              child: Text(
                AppStrings.noLogsAvailable,
                style: AppTextStyles.caption,
              ),
            )
          : SingleChildScrollView(child: _buildLogText()),
    );
  }

  Widget _buildLogText() {
    // If no search query, return normal text.
    if (searchQuery.isEmpty) {
      return Text(
        logs!,
        style: const TextStyle(
          color: Color(0xFF4ADE80), // green terminal text
          fontSize: 11,
          fontFamily: 'monospace',
          height: 1.5,
        ),
      );
    }

    // Build highlighted text spans
    final queryLower = searchQuery.toLowerCase();
    final lowerText = logs!.toLowerCase();

    final List<TextSpan> spans = [];
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(queryLower, start);
      if (index == -1) {
        spans.add(TextSpan(text: logs!.substring(start)));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: logs!.substring(start, index)));
      }

      spans.add(
        TextSpan(
          text: logs!.substring(index, index + queryLower.length),
          style: const TextStyle(
            color: Colors.black,
            backgroundColor: Colors.yellow,
          ),
        ),
      );

      start = index + queryLower.length;
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Color(0xFF4ADE80), // green terminal text
          fontSize: 11,
          fontFamily: 'monospace',
          height: 1.5,
        ),
        children: spans,
      ),
    );
  }
}

// Public aliases kept for backward compat (used in tab bar view)
class LogControls extends StatelessWidget {
  const LogControls({
    super.key,
    required this.isFollowingLogs,
    required this.hasLogs,
    this.onToggleFollow,
    this.onRefresh,
  });
  final bool isFollowingLogs;
  final bool hasLogs;
  final VoidCallback? onToggleFollow;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink(); // Legacy removed
}

class LogDisplay extends StatelessWidget {
  const LogDisplay({super.key, required this.logs});
  final String? logs;

  @override
  Widget build(BuildContext context) =>
      _LogDisplay(logs: logs, searchQuery: '');
}
