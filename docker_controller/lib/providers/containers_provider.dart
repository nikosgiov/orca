import 'dart:async';

import 'package:docker_controller/constants/app_delays.dart';
import 'package:docker_controller/core/di/service_locator.dart';
import 'package:docker_controller/models/app_state.dart';
import 'package:docker_controller/models/docker_container.dart';
import 'package:docker_controller/providers/auth_provider.dart';
import 'package:docker_controller/services/container_service.dart';
import 'package:docker_controller/utils/container_filter_utils.dart';
import 'package:flutter/material.dart';

/// Provider responsible for managing the state of Docker containers.
class ContainersProvider extends ChangeNotifier {
  ContainersProvider(this.authProvider, {ContainerService? containerService})
    : _containerService = containerService ?? getIt<ContainerService>();

  final AuthProvider authProvider;
  final ContainerService _containerService;

  AppState<List<DockerContainer>> _state = const AppInitial();

  /// The current state of the containers list.
  AppState<List<DockerContainer>> get state => _state;

  String _searchQuery = '';
  String _selectedFilter = 'All';

  final List<String> filterOptions = ['All', 'Running', 'Stopped', 'Exited'];
  bool _isRefreshing = false;

  /// Returns the current list of containers if the state is success.
  List<DockerContainer>? get containers {
    if (_state is AppSuccess<List<DockerContainer>>) {
      return (_state as AppSuccess<List<DockerContainer>>).data;
    }
    return null;
  }

  /// Whether the provider is currently loading data.
  bool get isLoading => _state is AppLoading;

  /// The current search query for filtering the container list.
  String get searchQuery => _searchQuery;

  /// The currently selected filter (e.g., 'All', 'Running').
  String get selectedFilter => _selectedFilter;

  /// Whether a refresh operation is in progress.
  bool get isRefreshing => _isRefreshing;

  set searchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  set selectedFilter(String value) {
    _selectedFilter = value;
    notifyListeners();
  }

  /// Returns the list of containers filtered by [searchQuery] and [selectedFilter].
  List<DockerContainer> get filteredContainers {
    return ContainerFilterUtils.filterContainers(
      containers: containers ?? [],
      searchQuery: _searchQuery,
      selectedFilter: _selectedFilter,
    );
  }

  /// Fetches the list of containers from the Docker daemon.
  /// If [silent] is true, the state remains unchanged (no loading spinner).
  Future<void> fetchContainers({bool silent = false}) async {
    if (!authProvider.isConnected) {
      return;
    }

    if (!silent) {
      _state = const AppLoading();
      notifyListeners();
    }

    final result = await _containerService.getContainers();
    
    result.fold(
      (containersList) {
        _state = AppSuccess(containersList);
      },
      (failure) {
        _state = AppStateError(failure);
      },
    );
    notifyListeners();
  }

  /// Refreshes the container list silently.
  Future<void> refreshContainers() async {
    _isRefreshing = true;
    notifyListeners();
    try {
      await fetchContainers(silent: true);
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Starts a container and refreshes the list.
  Future<bool> startContainer(String containerId) async {
    if (!authProvider.isConnected) {
      return false;
    }
    
    final result = await _containerService.startContainer(containerId);
    return result.fold(
      (success) async {
        if (success) {
          await Future.delayed(AppDelays.containerOperationDelay);
          await fetchContainers(silent: true);
        }
        return success;
      },
      (_) => false,
    );
  }

  /// Stops a container and refreshes the list.
  Future<bool> stopContainer(String containerId) async {
    if (!authProvider.isConnected) {
      return false;
    }
    
    final result = await _containerService.stopContainer(containerId);
    return result.fold(
      (success) async {
        if (success) {
          await Future.delayed(AppDelays.containerOperationDelay);
          await fetchContainers(silent: true);
        }
        return success;
      },
      (_) => false,
    );
  }
}
