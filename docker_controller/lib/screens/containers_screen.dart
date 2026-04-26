import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/app_state.dart';
import '../providers/auth_provider.dart';
import '../providers/containers_provider.dart';
import '../widgets/app_background.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_filter_chips.dart';
import '../widgets/app_gradient_top_bar.dart';
import '../widgets/app_loading_indicator.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/container_card.dart';

class ContainersScreen extends StatefulWidget {
  const ContainersScreen({super.key});

  @override
  State<ContainersScreen> createState() => _ContainersScreenState();
}

class _ContainersScreenState extends State<ContainersScreen> {
  @override
  void initState() {
    super.initState();
    _initialFetch();
  }

  void _initialFetch() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = context.read<ContainersProvider>();
        if (provider.state is AppInitial) {
          provider.fetchContainers();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final containersProvider = context.watch<ContainersProvider>();

    return AppBackground(
      position: const Offset(100, -50),
      scale: 1.5,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const AppGradientTopBar(title: AppStrings.containersTitle),
        floatingActionButton: _AddContainerButton(
          authProvider: authProvider,
          containersProvider: containersProvider,
        ),
        body: Column(
          children: [
            _SearchAndFilterHeader(provider: containersProvider),
            Expanded(
              child: _buildContent(containersProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ContainersProvider provider) {
    return switch (provider.state) {
      AppInitial() => const SizedBox.shrink(),
      AppLoading() => const AppLoadingIndicator(message: 'Loading containers...'),
      AppSuccess(:final data) => data.isEmpty
          ? const AppEmptyState(
              icon: Icons.inbox_outlined,
              title: AppStrings.noContainersFound,
              message: AppStrings.createFirstContainer,
            )
          : _ContainersList(provider: provider),
      AppError(:final message) => AppEmptyState(
          icon: Icons.error_outline,
          title: 'Error',
          message: message,
        ),
    };
  }
}

class _ContainersList extends StatelessWidget {
  const _ContainersList({required this.provider});
  final ContainersProvider provider;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: provider.refreshContainers,
      color: AppColors.primary,
      backgroundColor: AppColors.backgroundMid,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
        itemCount: provider.filteredContainers.length,
        itemBuilder: (context, index) {
          return ContainerCard(container: provider.filteredContainers[index]);
        },
      ),
    );
  }
}

class _SearchAndFilterHeader extends StatelessWidget {
  const _SearchAndFilterHeader({required this.provider});
  final ContainersProvider provider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        children: [
          AppSearchBar(
            value: provider.searchQuery,
            onChanged: (v) => provider.searchQuery = v,
            hintText: AppStrings.searchContainersHint,
          ),
          const SizedBox(height: 10),
          AppFilterChips(
            options: provider.filterOptions,
            selected: provider.selectedFilter,
            onSelected: (f) => provider.selectedFilter = f,
          ),
        ],
      ),
    );
  }
}

class _AddContainerButton extends StatelessWidget {

  const _AddContainerButton({
    required this.authProvider,
    required this.containersProvider,
  });
  final AuthProvider authProvider;
  final ContainersProvider containersProvider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 140),
      child: FloatingActionButton(
        heroTag: null,
        onPressed: () {
          context.pushNamed('createContainer').then((_) {
            if (authProvider.isConnected) {
              containersProvider.refreshContainers();
            }
          });
        },
        backgroundColor: AppColors.primary.withValues(alpha: 0.85),
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
