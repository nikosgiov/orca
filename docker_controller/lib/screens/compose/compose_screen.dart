import 'package:docker_controller/constants/app_colors.dart';
import 'package:docker_controller/constants/app_text_styles.dart';
import 'package:docker_controller/models/app_state.dart';
import 'package:docker_controller/providers/compose_provider.dart';
import 'package:docker_controller/widgets/app_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import 'widgets/project_card.dart';

class ComposeScreen extends StatefulWidget {
  const ComposeScreen({super.key});

  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = context.read<ComposeProvider>();
        if (provider.state is AppInitial) {
          provider.loadProjects();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ComposeProvider>();

    return AppBackground(
      position: const Offset(120, -100),
      scale: 1.5,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: switch (provider.state) {
          AppInitial() => const SizedBox.shrink(),
          AppLoading(:final message) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(message, style: AppTextStyles.caption),
                ],
              ],
            ),
          ),
          AppSuccess(:final data) =>
            data.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.layers_clear,
                          color: AppColors.textMuted,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.noProjectsFound,
                          style: AppTextStyles.heading2,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.composeLabelHint,
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: provider.loadProjects,
                          child: Text(AppLocalizations.of(context)!.refresh),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: provider.loadProjects,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(
                        top: 8,
                        left: 16,
                        right: 16,
                        bottom: 80,
                      ),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return ProjectCard(
                          project: data[index],
                          provider: provider,
                        );
                      },
                    ),
                  ),
          AppStateError(:final failure) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  failure.message,
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: provider.loadProjects,
                  child: Text(AppLocalizations.of(context)!.retry),
                ),
              ],
            ),
          ),
        },
      ),
    );
  }
}
