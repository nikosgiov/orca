import 'dart:convert';

import 'package:flutter/material.dart';

import '../core/di/service_locator.dart';
import '../models/app_error.dart';
import '../providers/auth_provider.dart';
import '../services/container_service.dart';
import '../services/image_service.dart';
import '../utils/container_config_builder.dart';

class CreateContainerProvider extends ChangeNotifier {
  CreateContainerProvider(this.authProvider, {String? preSelectedImage}) {
    if (preSelectedImage != null) {
      selectedImage = preSelectedImage;
      final parts = selectedImage.split(':');
      imageController.text = parts[0];
      if (parts.length > 1) {
        tagController.text = parts[1];
      }
    }
    loadImages();
  }
  final AuthProvider authProvider;
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final imageController = TextEditingController();
  final tagController = TextEditingController(text: 'latest');

  int currentStep = 0;
  bool isCreating = false;
  bool isLoadingImages = false;
  List<String> availableImages = [];
  AppError? error;

  // Form data
  String selectedImage = '';
  String containerName = '';
  List<Map<String, String>> environmentVars = [];
  List<Map<String, String>> portMappings = [];
  List<Map<String, String>> volumeMappings = [];
  String networkMode = 'bridge';
  bool autoRemove = false;
  bool interactive = false;
  bool tty = false;
  bool isManualEdit = false;
  bool startAfterCreate = true;

  final List<String> stepTitles = [
    'Select Image',
    'Basic Config',
    'Advanced Config',
    'Review & Create',
  ];

  void disposeControllers() {
    nameController.dispose();
    imageController.dispose();
    tagController.dispose();
  }

  Future<void> loadImages() async {
    isLoadingImages = true;
    error = null;
    notifyListeners();
    try {
      if (authProvider.connectionConfig != null) {
        final images = await getIt<ImageService>().getImages();
        availableImages = images.map<String>((image) {
          final tags = image.repoTags;
          if (tags.isNotEmpty) {
            return tags.first;
          }
          final repoDigests = image.repoDigests;
          if (repoDigests.isNotEmpty) {
            return repoDigests.first.split('@').first;
          }
          return image.id.substring(0, 12);
        }).toList();
      } else {
        error = AppError(
          message: 'Not connected to Docker daemon',
          type: 'Connection',
        );
      }
    } catch (e, st) {
      error = AppError(
        message: 'Error loading images: $e',
        type: 'Exception',
        stackTrace: st,
      );
    } finally {
      isLoadingImages = false;
      notifyListeners();
    }
  }

  void setStep(int step) {
    currentStep = step;
    notifyListeners();
  }

  void nextStep() {
    if (currentStep < 3) {
      currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      currentStep--;
      notifyListeners();
    }
  }

  void setSelectedImage(String? value) {
    if (value != null) {
      selectedImage = value;
      final parts = value.split(':');
      imageController.text = parts[0];
      if (parts.length > 1) {
        tagController.text = parts[1];
      }
      isManualEdit = false;
    } else {
      selectedImage = '';
      isManualEdit = true;
    }
    notifyListeners();
  }

  void setImageName(String value) {
    selectedImage = '$value:${tagController.text}';
    isManualEdit = true;
    notifyListeners();
  }

  void setImageTag(String value) {
    selectedImage = '${imageController.text}:$value';
    isManualEdit = true;
    notifyListeners();
  }

  void setContainerName(String value) {
    containerName = value;
    notifyListeners();
  }

  void setInteractive(bool value) {
    interactive = value;
    notifyListeners();
  }

  void setTty(bool value) {
    tty = value;
    notifyListeners();
  }

  void setAutoRemove(bool value) {
    autoRemove = value;
    notifyListeners();
  }

  void setStartAfterCreate(bool value) {
    startAfterCreate = value;
    notifyListeners();
  }

  void setNetworkMode(String? value) {
    networkMode = value ?? 'bridge';
    notifyListeners();
  }

  void addPortMapping() {
    portMappings.add({'host': '', 'container': ''});
    notifyListeners();
  }

  void updatePortMapping(int index, String key, String value) {
    portMappings[index][key] = value;
    notifyListeners();
  }

  void removePortMapping(int index) {
    portMappings.removeAt(index);
    notifyListeners();
  }

  void addVolumeMapping() {
    volumeMappings.add({'host': '', 'container': ''});
    notifyListeners();
  }

  void updateVolumeMapping(int index, String key, String value) {
    volumeMappings[index][key] = value;
    notifyListeners();
  }

  void removeVolumeMapping(int index) {
    volumeMappings.removeAt(index);
    notifyListeners();
  }

  void addEnvironmentVar() {
    environmentVars.add({'name': '', 'value': ''});
    notifyListeners();
  }

  void updateEnvironmentVar(int index, String key, String value) {
    environmentVars[index][key] = value;
    notifyListeners();
  }

  void removeEnvironmentVar(int index) {
    environmentVars.removeAt(index);
    notifyListeners();
  }

  Future<String?> createContainer(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return null;
    }
    isCreating = true;
    notifyListeners();
    try {
      if (authProvider.connectionConfig == null) {
        throw Exception('Not connected to Docker daemon');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preparing container creation...'),
          backgroundColor: Color(0xFF2563EB),
          duration: Duration(seconds: 2),
        ),
      );
      final containerConfig = ContainerConfigBuilder.buildConfig(
        selectedImage: selectedImage,
        containerName: containerName,
        tty: tty,
        interactive: interactive,
        networkMode: networkMode,
        autoRemove: autoRemove,
        portMappings: portMappings,
        volumeMappings: volumeMappings,
        environmentVars: environmentVars,
      );
      // Debug: Log the container configuration
      debugPrint(
        'Creating container with config: ${json.encode(containerConfig)}',
      );
      String? containerId;
      if (startAfterCreate) {
        containerId = await getIt<ContainerService>().createAndStartContainer(
          containerConfig,
        );
      } else {
        containerId = await getIt<ContainerService>().createContainer(
          containerConfig,
        );
      }
      isCreating = false;
      notifyListeners();
      return containerId;
    } catch (e) {
      isCreating = false;
      notifyListeners();
      if (!context.mounted) {
        return null;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create container: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return null;
    }
  }
}
