import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/app_delays.dart';
import '../core/di/service_locator.dart';
import '../models/app_state.dart';
import '../models/connection_config.dart';
import '../models/docker_network.dart';
import '../models/docker_volume.dart';
import '../services/network_service.dart';
import '../services/volume_service.dart';

class VolumesNetworksProvider extends ChangeNotifier {
  VolumesNetworksProvider();
  late TabController tabController;

  AppState<List<DockerVolume>> _volumesState = const AppInitial();
  AppState<List<DockerNetwork>> _networksState = const AppInitial();

  AppState<List<DockerVolume>> get volumesState => _volumesState;
  AppState<List<DockerNetwork>> get networksState => _networksState;

  List<DockerVolume> get volumes {
    if (_volumesState is AppSuccess<List<DockerVolume>>) {
      return (_volumesState as AppSuccess<List<DockerVolume>>).data;
    }
    return [];
  }

  List<DockerNetwork> get networks {
    if (_networksState is AppSuccess<List<DockerNetwork>>) {
      return (_networksState as AppSuccess<List<DockerNetwork>>).data;
    }
    return [];
  }

  ConnectionConfig? connectionConfig;
  bool get isLoadingVolumes => _volumesState is AppLoading;
  bool get isLoadingNetworks => _networksState is AppLoading;

  Future<void> fetchVolumes() async {
    if (connectionConfig == null) {
      return;
    }

    _volumesState = const AppLoading();
    notifyListeners();

    try {
      final result = await getIt<VolumeService>().getVolumes();
      _volumesState = AppSuccess(result);
    } catch (e, st) {
      _volumesState = AppError(
        message: 'Failed to load volumes: $e',
        error: e,
        stackTrace: st,
      );
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchNetworks() async {
    if (connectionConfig == null) {
      return;
    }

    _networksState = const AppLoading();
    notifyListeners();

    try {
      final result = await getIt<NetworkService>().getNetworks();
      final fullDetails = <DockerNetwork>[];
      for (final network in result) {
        final details = await getIt<NetworkService>().inspectNetwork(
          network.id,
        );
        fullDetails.add(details ?? network);
      }
      _networksState = AppSuccess(fullDetails);
    } catch (e, st) {
      _networksState = AppError(
        message: 'Failed to load networks: $e',
        error: e,
        stackTrace: st,
      );
    } finally {
      notifyListeners();
    }
  }

  void setConnectionConfig(ConnectionConfig config) {
    if (connectionConfig?.uri == config.uri &&
        connectionConfig?.token == config.token) {
      return;
    }

    connectionConfig = config;
    fetchVolumes();
    fetchNetworks();
  }

  Future<void> refreshData() async {
    await Future.wait([fetchVolumes(), fetchNetworks()]);
  }

  void setTabController(TabController controller) {
    tabController = controller;
  }

  // Volume actions
  Future<bool> removeVolume(String volumeName) async {
    if (connectionConfig == null) {
      return false;
    }
    final success = await getIt<VolumeService>().removeVolume(volumeName);
    if (success) {
      await Future.delayed(AppDelays.containerOperationDelay);
      await fetchVolumes();
      return true;
    }
    return false;
  }

  // Network actions
  Future<DockerNetwork?> inspectNetwork(String idOrName) async {
    if (connectionConfig == null) {
      return null;
    }
    return await getIt<NetworkService>().inspectNetwork(idOrName);
  }

  Future<bool> removeNetwork(String networkName) async {
    if (connectionConfig == null) {
      return false;
    }
    final success = await getIt<NetworkService>().removeNetwork(networkName);
    if (success) {
      await Future.delayed(AppDelays.containerOperationDelay);
      await fetchNetworks();
      return true;
    }
    return false;
  }
}
