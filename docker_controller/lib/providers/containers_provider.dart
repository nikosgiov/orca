import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/app_delays.dart';
import '../core/di/service_locator.dart';
import '../models/app_state.dart';
import '../models/docker_container.dart';
import '../providers/auth_provider.dart';
import '../services/container_service.dart';
import '../utils/container_filter_utils.dart';

/// Provider responsible for managing the state of Docker containers.
/// Handles fetching, refreshing, starting, and stopping containers, as well as filtering.
class ContainersProvider extends ChangeNotifier {
  ContainersProvider(this.authProvider, {ContainerService? containerService})
    : _containerService = containerService ?? getIt<ContainerService>();

  /// The authentication provider used to check connection status.
  final AuthProvider authProvider;
  final ContainerService _containerService;

  AppState<List<DockerContainer>> _state = const AppInitial();

  /// The current state of the containers list (Loading, Success, Error).
  AppState<List<DockerContainer>> get state => _state;

  String _searchQuery = '';
  String _selectedFilter = 'All';

  /// Available filter options for the container list.
  final List<String> filterOptions = ['All', 'Running', 'Stopped', 'Exited'];
  bool _isRefreshing = false;

  /// Returns the current list of containers if available in the success state.
  List<DockerContainer>? get containers {
    if (_state is AppSuccess<List<DockerContainer>>) {
      return (_state as AppSuccess<List<DockerContainer>>).data;
    }
    return null;
  }

  /// Whether the provider is currently loading data for the first time.
  bool get isLoading => _state is AppLoading;

  /// The current search query string.
  String get searchQuery => _searchQuery;

  /// The currently selected status filter.
  String get selectedFilter => _selectedFilter;

  /// Whether a background refresh is currently in progress.
  bool get isRefreshing => _isRefreshing;

  set searchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  set selectedFilter(String value) {
    _selectedFilter = value;
    notifyListeners();
  }

  /// Returns a list of containers filtered by the current [searchQuery] and [selectedFilter].
  List<DockerContainer> get filteredContainers {
    return ContainerFilterUtils.filterContainers(
      containers: containers ?? [],
      searchQuery: _searchQuery,
      selectedFilter: _selectedFilter,
    );
  }

  /// Fetches the list of containers from the Docker daemon.
  Future<void> fetchContainers() async {
    if (!authProvider.isConnected) {
      return;
    }

    _state = const AppLoading();
    notifyListeners();

    try {
      final containersList = await _containerService.getContainers();
      _state = AppSuccess(containersList);
    } catch (e, st) {
      _state = AppError(
        message: 'Failed to load containers: $e',
        error: e,
        stackTrace: st,
      );
    } finally {
      notifyListeners();
    }
  }

  /// Refreshes the container list without showing a full-screen loading indicator.
  Future<void> refreshContainers() async {
    _isRefreshing = true;
    notifyListeners();
    try {
      await fetchContainers();
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Starts a container by its ID and refreshes the list.
  Future<bool> startContainer(String containerId) async {
    if (!authProvider.isConnected) {
      return false;
    }
    try {
      final success = await _containerService.startContainer(containerId);
      if (success) {
        await Future.delayed(AppDelays.containerOperationDelay);
        await fetchContainers();
      }
      return success;
    } catch (_) {
      return false;
    }
  }

  /// Stops a container by its ID and refreshes the list.
  Future<bool> stopContainer(String containerId) async {
    if (!authProvider.isConnected) {
      return false;
    }
    try {
      final success = await _containerService.stopContainer(containerId);
      if (success) {
        await Future.delayed(AppDelays.containerOperationDelay);
        await fetchContainers();
      }
      return success;
    } catch (_) {
      return false;
    }
  }
}
