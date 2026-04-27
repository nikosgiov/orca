import 'package:docker_controller/core/di/service_locator.dart';
import 'package:docker_controller/providers/auth_provider.dart';
import 'package:docker_controller/services/volume_service.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Provider responsible for handling the creation of a new Docker volume.
class CreateVolumeProvider extends ChangeNotifier {
  CreateVolumeProvider(this.authProvider);
  final AuthProvider authProvider;

  /// The [GlobalKey] for the creation form.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Step management
  /// The currently active step in the creation wizard.
  int currentStep = 0;

  // Form controllers
  /// Controller for the volume name input field.
  final TextEditingController nameController = TextEditingController();

  /// The selected driver for the new volume (e.g., 'local').
  String selectedDriver = 'local';

  // Dynamic lists
  /// List of custom driver options for the volume.
  List<Map<String, String>> driverOptions = [];

  /// List of labels to apply to the volume.
  List<Map<String, String>> labels = [];

  // State
  /// Whether the creation process is in progress.
  bool isCreating = false;

  /// The most recent error message, if any.
  String? error;

  // Step navigation
  /// Advances to the next step in the wizard.
  void nextStep() {
    if (currentStep < 2) {
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

  // Form setters
  void setVolumeName(String value) {
    nameController.text = value;
    notifyListeners();
  }

  void setDriver(String? value) {
    selectedDriver = value ?? 'local';
    notifyListeners();
  }

  // Dynamic list management
  void addDriverOption() {
    driverOptions.add({'key': '', 'value': ''});
    notifyListeners();
  }

  void updateDriverOption(int index, String key, String value) {
    if (index < driverOptions.length) {
      driverOptions[index]['key'] = key;
      driverOptions[index]['value'] = value;
      notifyListeners();
    }
  }

  void removeDriverOption(int index) {
    if (index < driverOptions.length) {
      driverOptions.removeAt(index);
      notifyListeners();
    }
  }

  void addLabel() {
    labels.add({'key': '', 'value': ''});
    notifyListeners();
  }

  void updateLabel(int index, String key, String value) {
    if (index < labels.length) {
      labels[index]['key'] = key;
      labels[index]['value'] = value;
      notifyListeners();
    }
  }

  void removeLabel(int index) {
    if (index < labels.length) {
      labels.removeAt(index);
      notifyListeners();
    }
  }

  // Volume creation
  /// Orchestrates the volume creation process using the current form data.
  ///
  /// Returns the name of the created volume on success, or null on failure.
  Future<String?> createVolume(BuildContext context) async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return null;
    }

    // Validate driver options and labels
    for (final option in driverOptions) {
      if (option['key']?.isNotEmpty == true &&
          option['value']?.isEmpty == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.driverOptionValueRequired),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }
      if (option['key']?.isEmpty == true &&
          option['value']?.isNotEmpty == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.driverOptionKeyRequired),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }
    }

    for (final label in labels) {
      if (label['key']?.isNotEmpty == true && label['value']?.isEmpty == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.labelValueRequired),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }
      if (label['key']?.isEmpty == true && label['value']?.isNotEmpty == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.labelKeyRequired),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }
    }

    final connectionConfig = authProvider.connectionConfig;
    if (connectionConfig == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.notConnectedDocker),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }

    isCreating = true;
    notifyListeners();

    try {
      // Convert lists to maps
      final driverOpts = <String, String>{};
      for (final option in driverOptions) {
        if (option['key']?.isNotEmpty == true &&
            option['value']?.isNotEmpty == true) {
          driverOpts[option['key']!] = option['value']!;
        }
      }

      final labelsMap = <String, String>{};
      for (final label in labels) {
        if (label['key']?.isNotEmpty == true &&
            label['value']?.isNotEmpty == true) {
          labelsMap[label['key']!] = label['value']!;
        }
      }

      final result = await getIt<VolumeService>().createVolume(
        nameController.text,
        driver: selectedDriver,
        driverOpts: driverOpts.isNotEmpty ? driverOpts : null,
        labels: labelsMap.isNotEmpty ? labelsMap : null,
      );

      return result.fold(
        (success) {
          if (success) {
            return nameController.text;
          } else {
            error = 'Failed to create volume';
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.failedToCreateVolume), backgroundColor: Colors.red),
              );
            }
            return null;
          }
        },
        (failure) {
          error = failure.message;
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
            );
          }
          return null;
        },
      );
    } catch (e) {
      error = 'Error creating volume: $e';
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorCreatingVolume(e.toString())), backgroundColor: Colors.red),
        );
      }
      return null;
    } finally {
      isCreating = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}
