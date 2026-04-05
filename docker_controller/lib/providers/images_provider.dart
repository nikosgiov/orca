import 'package:flutter/material.dart';
import 'dart:async';
import '../services/image_service.dart';
import '../providers/app_provider.dart';
import '../utils/image_filter_utils.dart';
import '../utils/image_format_utils.dart';
import '../constants/app_delays.dart';

class ImagesProvider extends ChangeNotifier {
  final AppProvider appProvider;
  ImagesProvider(this.appProvider);

  List<Map<String, dynamic>>? _images;
  bool _isLoading = false;
  String _searchQuery = '';
  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  set searchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  List<Map<String, dynamic>>? get images => _images;

  List<Map<String, dynamic>> get filteredImages {
    return ImageFilterUtils.filterImages(
      images: _images ?? [],
      searchQuery: _searchQuery,
    );
  }

  Future<void> fetchImages() async {
    final config = appProvider.connectionConfig;
    if (config == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final images = await ImageService.getImages(config);
      _images = images;
    } finally {
      _isLoading = false;
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

  Future<(bool, String?)> removeImage(Map<String, dynamic> image) async {
    final imageName = ImageFormatUtils.getImageDisplayName(image);
    try {
      if (appProvider.connectionConfig == null) {
        return (false, 'Not connected to Docker daemon');
      }
      final imageId = image['Id'] as String?;
      if (imageId == null) {
        return (false, 'Invalid image ID');
      }
      final success = await ImageService.removeImage(appProvider.connectionConfig!, imageId);
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
      if (appProvider.connectionConfig == null) {
        return (false, 'Not connected to Docker daemon');
      }
      final success = await ImageService.pullImage(appProvider.connectionConfig!, name, tag);
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
