import 'package:flutter/material.dart';

import '../core/di/service_locator.dart';
import '../providers/auth_provider.dart';
import '../services/volume_service.dart';

class CreateVolumeProvider extends ChangeNotifier {
  CreateVolumeProvider(this.authProvider);
  final AuthProvider authProvider;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Step management
  int currentStep = 0;
  final List<String> stepTitles = ['Basic Info', 'Advanced Options', 'Review'];

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  String selectedDriver = 'local';

  // Dynamic lists
  List<Map<String, String>> driverOptions = [];
  List<Map<String, String>> labels = [];

  // State
  bool isCreating = false;
  String? error;

  // Step navigation
  void nextStep() {
    if (currentStep < stepTitles.length - 1) {
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
  Future<String?> createVolume(BuildContext context) async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return null;
    }

    // Validate driver options and labels
    for (final option in driverOptions) {
      if (option['key']?.isNotEmpty == true &&
          option['value']?.isEmpty == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Driver option value cannot be empty'),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }
      if (option['key']?.isEmpty == true &&
          option['value']?.isNotEmpty == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Driver option key cannot be empty'),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }
    }

    for (final label in labels) {
      if (label['key']?.isNotEmpty == true && label['value']?.isEmpty == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Label value cannot be empty'),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }
      if (label['key']?.isEmpty == true && label['value']?.isNotEmpty == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Label key cannot be empty'),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }
    }

    final connectionConfig = authProvider.connectionConfig;
    if (connectionConfig == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not connected to Docker. Please connect first.'),
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

      if (result) {
        return nameController.text;
      } else {
        error = 'Failed to create volume';
        if (!context.mounted) {
          return null;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error!), backgroundColor: Colors.red),
        );
        return null;
      }
    } catch (e) {
      error = 'Error creating volume: $e';
      if (!context.mounted) {
        return null;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error!), backgroundColor: Colors.red),
      );
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
