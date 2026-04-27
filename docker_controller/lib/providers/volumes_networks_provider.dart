import 'dart:async';

import 'package:docker_controller/constants/app_delays.dart';
import 'package:docker_controller/core/di/service_locator.dart';
import 'package:docker_controller/models/app_state.dart';
import 'package:docker_controller/models/connection_config.dart';
import 'package:docker_controller/models/docker_network.dart';
import 'package:docker_controller/models/docker_volume.dart';
import 'package:docker_controller/services/network_service.dart';
import 'package:docker_controller/services/volume_service.dart';
import 'package:flutter/material.dart';

/// Provider responsible for managing Docker volumes and networks.
class VolumesNetworksProvider extends ChangeNotifier {
  VolumesNetworksProvider({
    VolumeService? volumeService,
    NetworkService? networkService,
  }) : _volumeService = volumeService ?? getIt<VolumeService>(),
       _networkService = networkService ?? getIt<NetworkService>();

  final VolumeService _volumeService;
  final NetworkService _networkService;
  late TabController tabController;

  AppState<List<DockerVolume>> _volumesState = const AppInitial();
  AppState<List<DockerNetwork>> _networksState = const AppInitial();

  /// Returns the current state of the volumes list.
  AppState<List<DockerVolume>> get volumesState => _volumesState;

  /// Returns the current state of the networks list.
  AppState<List<DockerNetwork>> get networksState => _networksState;

  /// Returns the list of volumes if the state is success.
  List<DockerVolume> get volumes {
    if (_volumesState is AppSuccess<List<DockerVolume>>) {
      return (_volumesState as AppSuccess<List<DockerVolume>>).data;
    }
    return [];
  }

  /// Returns the list of networks if the state is success.
  List<DockerNetwork> get networks {
    if (_networksState is AppSuccess<List<DockerNetwork>>) {
      return (_networksState as AppSuccess<List<DockerNetwork>>).data;
    }
    return [];
  }

  ConnectionConfig? connectionConfig;
  /// Whether volumes are currently being loaded.
  bool get isLoadingVolumes => _volumesState is AppLoading;

  /// Whether networks are currently being loaded.
  bool get isLoadingNetworks => _networksState is AppLoading;

  Future<void> fetchVolumes({bool silent = false}) async {
    if (connectionConfig == null) {
      return;
    }

    if (!silent) {
      _volumesState = const AppLoading();
      notifyListeners();
    }

    final result = await _volumeService.getVolumes();
    result.fold(
      (data) => _volumesState = AppSuccess(data),
      (failure) => _volumesState = AppStateError(failure),
    );
    notifyListeners();
  }

  Future<void> fetchNetworks({bool silent = false}) async {
    if (connectionConfig == null) {
      return;
    }

    if (!silent) {
      _networksState = const AppLoading();
      notifyListeners();
    }

    final result = await _networkService.getNetworks();
    
    await result.fold(
      (networksList) async {
        final detailFutures = networksList.map((network) async {
          final detailResult = await _networkService.inspectNetwork(network.id);
          return detailResult.fold((d) => d, (_) => network);
        }).toList();
        
        final fullDetails = await Future.wait(detailFutures);
        _networksState = AppSuccess(fullDetails);
      },
      (failure) async {
        _networksState = AppStateError(failure);
      },
    );
    notifyListeners();
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

  /// Triggers a silent refresh of both volumes and networks.
  Future<void> refreshData() async {
    await Future.wait([
      fetchVolumes(silent: true),
      fetchNetworks(silent: true),
    ]);
  }

  void setTabController(TabController controller) {
    tabController = controller;
  }

  // Volume actions
  Future<bool> removeVolume(String volumeName) async {
    if (connectionConfig == null) {
      return false;
    }

    final result = await _volumeService.removeVolume(volumeName);
    return result.fold(
      (success) async {
        if (success) {
          await Future.delayed(AppDelays.containerOperationDelay);
          await fetchVolumes(silent: true);
        }
        return success;
      },
      (_) => false,
    );
  }

  // Network actions
  Future<DockerNetwork?> inspectNetwork(String idOrName) async {
    if (connectionConfig == null) {
      return null;
    }
    
    final result = await _networkService.inspectNetwork(idOrName);
    return result.fold((data) => data, (_) => null);
  }

  /// Removes a network and refreshes the list.
  Future<bool> removeNetwork(String networkName) async {
    if (connectionConfig == null) {
      return false;
    }

    final result = await _networkService.removeNetwork(networkName);
    return result.fold(
      (success) async {
        if (success) {
          await Future.delayed(AppDelays.containerOperationDelay);
          await fetchNetworks(silent: true);
        }
        return success;
      },
      (_) => false,
    );
  }
}
