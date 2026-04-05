import 'package:flutter/material.dart';
import 'dart:async';
import '../services/volume_service.dart';
import '../services/network_service.dart';
import '../models/connection_config.dart';
import '../constants/app_delays.dart';

class VolumesNetworksProvider extends ChangeNotifier {
  late TabController tabController;

  // Replace mock data with real data
  List<Map<String, dynamic>> volumes = [];
  List<Map<String, dynamic>> networks = [];
  ConnectionConfig? connectionConfig;
  bool isLoadingVolumes = false;
  bool isLoadingNetworks = false;

  Future<void> fetchVolumes() async {
    if (connectionConfig == null) return;
    isLoadingVolumes = true;
    notifyListeners();
    final (result, error) = await VolumeService.getVolumes(connectionConfig!);
    if (result != null) {
      volumes = result;
    } else if (error != null) {
      // Optionally handle error globally
    }
    isLoadingVolumes = false;
    notifyListeners();
  }

  Future<void> fetchNetworks() async {
    if (connectionConfig == null) return;
    isLoadingNetworks = true;
    notifyListeners();
    
    // Get network list
    final (result, error) = await NetworkService.getNetworks(connectionConfig!);
    if (result != null) {
      // Fetch full details for each network
      final fullDetails = <Map<String, dynamic>>[];
      for (final network in result) {
        final idOrName = network['Id'] ?? network['Name'];
        if (idOrName != null) {
          final details = await NetworkService.inspectNetwork(connectionConfig!, idOrName.toString());
          if (details != null) {
            fullDetails.add(details);
          }
        }
      }
      networks = fullDetails;
    } else if (error != null) {
      // Optionally handle error globally
    }
    isLoadingNetworks = false;
    notifyListeners();
  }

  void setConnectionConfig(ConnectionConfig config) {
    connectionConfig = config;
    fetchVolumes();
    fetchNetworks();
  }

  Future<void> refreshData() async {
    await Future.wait([
      fetchVolumes(),
      fetchNetworks(),
    ]);
  }

  void setTabController(TabController controller) {
    tabController = controller;
  }

  // Volume actions
  Future<bool> removeVolume(String volumeName) async {
    if (connectionConfig == null) return false;
    final result = await VolumeService.removeVolume(connectionConfig!, volumeName);
    if (result.success) {
      // Add delay before refreshing data
      await Future.delayed(AppDelays.containerOperationDelay);
      await fetchVolumes();
      return true;
    }
    return false;
  }

  // Network actions
  Future<Map<String, dynamic>?> inspectNetwork(String idOrName) async {
    if (connectionConfig == null) return null;
    return await NetworkService.inspectNetwork(connectionConfig!, idOrName);
  }

  Future<bool> removeNetwork(String networkName) async {
    if (connectionConfig == null) return false;
    final result = await NetworkService.removeNetwork(connectionConfig!, networkName);
    if (result.success) {
      // Add delay before refreshing data
      await Future.delayed(AppDelays.containerOperationDelay);
      await fetchNetworks();
      return true;
    }
    return false;
  }
} 
