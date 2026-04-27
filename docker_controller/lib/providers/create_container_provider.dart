import 'dart:convert';

import 'package:docker_controller/core/di/service_locator.dart';
import 'package:docker_controller/models/app_error.dart';
import 'package:docker_controller/providers/auth_provider.dart';
import 'package:docker_controller/services/container_service.dart';
import 'package:docker_controller/services/image_service.dart';
import 'package:docker_controller/utils/container_config_builder.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Provider responsible for handling the multi-step form for creating a new container.
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
  /// The [GlobalKey] for the creation form.
  final formKey = GlobalKey<FormState>();

  /// Controller for the container name input field.
  final nameController = TextEditingController();

  /// Controller for the image name input field.
  final imageController = TextEditingController();

  /// Controller for the image tag input field.
  final tagController = TextEditingController(text: 'latest');

  /// The currently active step in the creation wizard.
  int currentStep = 0;

  /// Whether the creation process is currently in progress.
  bool isCreating = false;

  /// Whether the list of available images is currently being loaded.
  bool isLoadingImages = false;

  /// A list of available image tags fetched from the Docker daemon.
  List<String> availableImages = [];

  /// The most recent error encountered during image loading or container creation.
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


  /// Disposes of all [TextEditingController]s used by this provider.
  void disposeControllers() {
    nameController.dispose();
    imageController.dispose();
    tagController.dispose();
  }

  Future<void> loadImages() async {
    if (authProvider.connectionConfig == null) {
      error = AppError(message: 'Not connected to Docker daemon');
      notifyListeners();
      return;
    }

    isLoadingImages = true;
    error = null;
    notifyListeners();

    final result = await getIt<ImageService>().getImages();
    
    result.fold(
      (images) {
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
      },
      (failure) {
        error = failure;
      },
    );

    isLoadingImages = false;
    notifyListeners();
  }

  /// Jumps to a specific step in the wizard.
  void setStep(int step) {
    currentStep = step;
    notifyListeners();
  }

  /// Advances to the next step in the wizard.
  void nextStep() {
    if (currentStep < 3) {
      currentStep++;
      notifyListeners();
    }
  }

  /// Returns to the previous step in the wizard.
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

  /// Orchestrates the container creation process using the current form data.
  ///
  /// Returns the ID of the created container on success, or null on failure.
  Future<String?> createContainer(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return null;
    }
    if (authProvider.connectionConfig == null) {
      return null;
    }

    isCreating = true;
    notifyListeners();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.preparingContainerCreation),
        backgroundColor: const Color(0xFF2563EB),
        duration: const Duration(seconds: 2),
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

    debugPrint('Creating container with config: ${json.encode(containerConfig)}');

    final containerService = getIt<ContainerService>();
    final result = startAfterCreate
        ? await containerService.createAndStartContainer(containerConfig)
        : await containerService.createContainer(containerConfig);

    isCreating = false;
    notifyListeners();

    return result.fold(
      (containerId) => containerId,
      (failure) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.failedToCreateContainer(failure.message)),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
        return null;
      },
    );
  }
}
