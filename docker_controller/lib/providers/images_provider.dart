import 'dart:async';

import 'package:docker_controller/constants/app_delays.dart';
import 'package:docker_controller/core/di/service_locator.dart';
import 'package:docker_controller/models/app_state.dart';
import 'package:docker_controller/models/docker_image.dart';
import 'package:docker_controller/providers/auth_provider.dart';
import 'package:docker_controller/services/image_service.dart';
import 'package:docker_controller/utils/image_filter_utils.dart';
import 'package:flutter/material.dart';

/// Provider responsible for managing the state of Docker images.
class ImagesProvider extends ChangeNotifier {
  ImagesProvider(this.authProvider, {ImageService? imageService})
    : _imageService = imageService ?? getIt<ImageService>();
  final AuthProvider authProvider;
  final ImageService _imageService;

  AppState<List<DockerImage>> _state = const AppInitial();
  /// The current state of the images list.
  AppState<List<DockerImage>> get state => _state;

  String _searchQuery = '';
  bool _isRefreshing = false;

  /// Whether a refresh operation is in progress.
  bool get isRefreshing => _isRefreshing;

  /// Whether the provider is currently loading data.
  bool get isLoading => _state is AppLoading;

  /// The current search query for filtering images.
  String get searchQuery => _searchQuery;

  set searchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  /// Returns the current list of images if the state is success.
  List<DockerImage>? get images {
    if (_state is AppSuccess<List<DockerImage>>) {
      return (_state as AppSuccess<List<DockerImage>>).data;
    }
    return null;
  }

  /// Returns the list of images filtered by [searchQuery].
  List<DockerImage> get filteredImages {
    final imagesList = images ?? [];
    return ImageFilterUtils.filterImages(
      images: imagesList.map((i) => i.toJson()).toList(),
      searchQuery: _searchQuery,
    ).map((m) => DockerImage.fromJson(m)).toList();
  }

  Future<void> fetchImages({bool silent = false}) async {
    if (!authProvider.isConnected) {
      return;
    }

    if (!silent) {
      _state = const AppLoading();
      notifyListeners();
    }

    final result = await _imageService.getImages();
    
    result.fold(
      (imagesList) {
        _state = AppSuccess(imagesList);
      },
      (failure) {
        _state = AppStateError(failure);
      },
    );
    notifyListeners();
  }

  Future<void> refreshImages() async {
    _isRefreshing = true;
    notifyListeners();
    try {
      await fetchImages(silent: true);
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<(bool, String?)> removeImage(DockerImage image) async {
    final imageName = image.displayName;
    if (!authProvider.isConnected) {
      return (false, 'Not connected to Docker daemon');
    }

    final result = await _imageService.removeImage(image.id);
    return result.fold(
      (success) async {
        if (success) {
          await Future.delayed(AppDelays.containerOperationDelay);
          await fetchImages(silent: true);
          return (true, imageName);
        }
        return (false, 'Failed to remove $imageName');
      },
      (failure) => (false, failure.message),
    );
  }

  /// Pulls a new image from a registry.
  ///
  /// Returns a tuple containing success status and an optional message.
  Future<(bool, String?)> pullImage(String name, String tag) async {
    if (!authProvider.isConnected) {
      return (false, 'Not connected to Docker daemon');
    }

    final result = await _imageService.pullImage(name, tag);
    return result.fold(
      (success) async {
        if (success) {
          await Future.delayed(AppDelays.containerOperationDelay);
          await fetchImages(silent: true);
          return (true, '$name:$tag');
        }
        return (false, 'Failed to pull $name:$tag');
      },
      (failure) => (false, failure.message),
    );
  }
}
