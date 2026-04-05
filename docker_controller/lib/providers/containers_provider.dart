import 'package:flutter/material.dart';
import 'dart:async';
import '../services/container_service.dart';
import '../providers/app_provider.dart';
import '../utils/container_filter_utils.dart';
import '../constants/app_delays.dart';

class ContainersProvider extends ChangeNotifier {
  final AppProvider appProvider;
  ContainersProvider(this.appProvider);

  List<Map<String, dynamic>>? _containers;
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final List<String> filterOptions = ['All', 'Running', 'Stopped', 'Exited'];
  bool _isRefreshing = false;

  List<Map<String, dynamic>>? get containers => _containers;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedFilter;
  bool get isRefreshing => _isRefreshing;

  set searchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  set selectedFilter(String value) {
    _selectedFilter = value;
    notifyListeners();
  }

  List<Map<String, dynamic>> get filteredContainers {
    return ContainerFilterUtils.filterContainers(
      containers: _containers ?? [],
      searchQuery: _searchQuery,
      selectedFilter: _selectedFilter,
    );
  }

  Future<void> fetchContainers() async {
    final config = appProvider.connectionConfig;
    if (config == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final containers = await ContainerService.getContainers(config);
      _containers = containers;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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

  Future<bool> startContainer(String containerId) async {
    final config = appProvider.connectionConfig;
    if (config == null) return false;
    try {
      final success = await ContainerService.startContainer(config, containerId);
      if (success) {
        // Add delay before refreshing data
        await Future.delayed(AppDelays.containerOperationDelay);
        await fetchContainers();
      }
      return success;
    } catch (_) {
      return false;
    }
  }

  Future<bool> stopContainer(String containerId) async {
    final config = appProvider.connectionConfig;
    if (config == null) return false;
    try {
      final success = await ContainerService.stopContainer(config, containerId);
      if (success) {
        // Add delay before refreshing data
        await Future.delayed(AppDelays.containerOperationDelay);
        await fetchContainers();
      }
      return success;
    } catch (_) {
      return false;
    }
  }
} 