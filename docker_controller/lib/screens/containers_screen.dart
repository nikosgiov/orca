import 'package:docker_controller/constants/app_colors.dart';
import 'package:docker_controller/models/app_state.dart';
import 'package:docker_controller/providers/auth_provider.dart';
import 'package:docker_controller/providers/containers_provider.dart';
import 'package:docker_controller/widgets/app_background.dart';
import 'package:docker_controller/widgets/app_empty_state.dart';
import 'package:docker_controller/widgets/app_filter_chips.dart';
import 'package:docker_controller/widgets/app_loading_indicator.dart';
import 'package:docker_controller/widgets/app_search_bar.dart';
import 'package:docker_controller/widgets/container_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';

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
      AppLoading() => AppLoadingIndicator(message: AppLocalizations.of(context)!.loadingContainers),
      AppSuccess(:final data) => data.isEmpty
          ? AppEmptyState(
              icon: Icons.inbox_outlined,
              title: AppLocalizations.of(context)!.noContainersFound,
              message: AppLocalizations.of(context)!.createFirstContainer,
            )
          : _ContainersList(provider: provider),
      AppStateError(:final failure) => AppEmptyState(
          icon: Icons.error_outline,
          title: AppLocalizations.of(context)!.error,
          message: failure.localizedMessage(AppLocalizations.of(context)!),
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
            hintText: AppLocalizations.of(context)!.searchContainersHint,
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
