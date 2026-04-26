import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/app_delays.dart';
import '../core/di/service_locator.dart';
import '../models/app_state.dart';
import '../models/docker_image.dart';
import '../providers/auth_provider.dart';
import '../services/image_service.dart';
import '../utils/image_filter_utils.dart';

class ImagesProvider extends ChangeNotifier {
  ImagesProvider(this.authProvider, {ImageService? imageService})
    : _imageService = imageService ?? getIt<ImageService>();
  final AuthProvider authProvider;
  final ImageService _imageService;

  AppState<List<DockerImage>> _state = const AppInitial();
  AppState<List<DockerImage>> get state => _state;

  String _searchQuery = '';
  bool _isRefreshing = false;

  bool get isRefreshing => _isRefreshing;
  bool get isLoading => _state is AppLoading;
  String get searchQuery => _searchQuery;

  set searchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  List<DockerImage>? get images {
    if (_state is AppSuccess<List<DockerImage>>) {
      return (_state as AppSuccess<List<DockerImage>>).data;
    }
    return null;
  }

  List<DockerImage> get filteredImages {
    final imagesList = images ?? [];
    return ImageFilterUtils.filterImages(
      images: imagesList.map((i) => i.toJson()).toList(),
      searchQuery: _searchQuery,
    ).map((m) => DockerImage.fromJson(m)).toList();
  }

  Future<void> fetchImages() async {
    if (!authProvider.isConnected) {
      return;
    }

    _state = const AppLoading();
    notifyListeners();

    try {
      final imagesList = await _imageService.getImages();
      _state = AppSuccess(imagesList);
    } catch (e, st) {
      _state = AppError(
        message: 'Failed to load images: $e',
        error: e,
        stackTrace: st,
      );
    } finally {
      notifyListeners();
    }
  }

  Future<void> refreshImages() async {
    _isRefreshing = true;
    notifyListeners();
    try {
      await fetchImages();
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<(bool, String?)> removeImage(DockerImage image) async {
    final imageName = image.displayName;
    try {
      if (!authProvider.isConnected) {
        return (false, 'Not connected to Docker daemon');
      }
      final success = await _imageService.removeImage(image.id);
      if (success) {
        await Future.delayed(AppDelays.containerOperationDelay);
        await fetchImages();
        return (true, imageName);
      } else {
        return (false, 'Failed to remove $imageName');
      }
    } catch (e) {
      return (false, 'Error removing image: $e');
    }
  }

  Future<(bool, String?)> pullImage(String name, String tag) async {
    try {
      if (!authProvider.isConnected) {
        return (false, 'Not connected to Docker daemon');
      }
      final success = await _imageService.pullImage(name, tag);
      if (success) {
        await Future.delayed(AppDelays.containerOperationDelay);
        await fetchImages();
        return (true, '$name:$tag');
      } else {
        return (false, 'Failed to pull $name:$tag');
      }
    } catch (e) {
      return (false, 'Error pulling image: $e');
    }
  }
}
