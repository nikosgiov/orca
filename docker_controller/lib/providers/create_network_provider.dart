import 'package:docker_controller/core/di/service_locator.dart';
import 'package:docker_controller/providers/auth_provider.dart';
import 'package:docker_controller/services/network_service.dart';
import 'package:flutter/material.dart';

/// Provider responsible for handling the creation of a new Docker network.
class CreateNetworkProvider extends ChangeNotifier {
  CreateNetworkProvider(this.authProvider);
  final AuthProvider authProvider;

  /// The [GlobalKey] for the creation form.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Step management
  /// The currently active step in the creation wizard.
  int currentStep = 0;

  // Form controllers
  /// Controller for the network name input field.
  final TextEditingController nameController = TextEditingController();

  /// The selected driver for the new network (e.g., 'bridge').
  String selectedDriver = 'bridge';

  /// Controller for the subnet configuration.
  final TextEditingController subnetController = TextEditingController();

  /// Controller for the gateway configuration.
  final TextEditingController gatewayController = TextEditingController();

  // Dynamic lists
  /// List of custom options for the network.
  List<Map<String, String>> options = [];

  /// List of labels to apply to the network.
  List<Map<String, String>> labels = [];

  // State
  /// Whether the creation process is in progress.
  bool isCreating = false;

  /// The most recent error message, if any.
  String? error;

  // Step navigation
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

  // Form setters
  void setNetworkName(String value) {
    nameController.text = value;
    notifyListeners();
  }

  void setDriver(String? value) {
    selectedDriver = value ?? 'bridge';
    notifyListeners();
  }

  void setSubnet(String value) {
    subnetController.text = value;
    notifyListeners();
  }

  void setGateway(String value) {
    gatewayController.text = value;
    notifyListeners();
  }

  // Dynamic list management
  void addOption() {
    options.add({'key': '', 'value': ''});
    notifyListeners();
  }

  void updateOption(int index, String key, String value) {
    if (index < options.length) {
      options[index]['key'] = key;
      options[index]['value'] = value;
      notifyListeners();
    }
  }

  void removeOption(int index) {
    if (index < options.length) {
      options.removeAt(index);
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

  // Network creation
  /// Orchestrates the network creation process using the current form data.
  ///
  /// Returns a tuple containing success status and an optional error message.
  Future<(bool, String?)> createNetwork() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return (false, null);
    }

    // Validate options and labels
    for (final option in options) {
      if (option['key']?.isNotEmpty == true &&
          option['value']?.isEmpty == true) {
        return (false, 'Option value cannot be empty');
      }
      if (option['key']?.isEmpty == true &&
          option['value']?.isNotEmpty == true) {
        return (false, 'Option key cannot be empty');
      }
    }

    for (final label in labels) {
      if (label['key']?.isNotEmpty == true && label['value']?.isEmpty == true) {
        return (false, 'Label value cannot be empty');
      }
      if (label['key']?.isEmpty == true && label['value']?.isNotEmpty == true) {
        return (false, 'Label key cannot be empty');
      }
    }

    final connectionConfig = authProvider.connectionConfig;
    if (connectionConfig == null) {
      return (false, 'Not connected to Docker. Please connect first.');
    }

    isCreating = true;
    error = null;
    notifyListeners();

    try {
      // Convert lists to maps
      final optionsMap = <String, String>{};
      for (final option in options) {
        if (option['key']?.isNotEmpty == true &&
            option['value']?.isNotEmpty == true) {
          optionsMap[option['key']!] = option['value']!;
        }
      }

      final labelsMap = <String, String>{};
      for (final label in labels) {
        if (label['key']?.isNotEmpty == true &&
            label['value']?.isNotEmpty == true) {
          labelsMap[label['key']!] = label['value']!;
        }
      }

      Map<String, dynamic>? ipamConfig;
      if (subnetController.text.isNotEmpty ||
          gatewayController.text.isNotEmpty) {
        ipamConfig = {
          'Config': [
            {
              if (subnetController.text.isNotEmpty)
                'Subnet': subnetController.text,
              if (gatewayController.text.isNotEmpty)
                'Gateway': gatewayController.text,
            },
          ],
        };
      }

      final result = await getIt<NetworkService>().createNetwork(
        nameController.text,
        driver: selectedDriver,
        options: optionsMap.isNotEmpty ? optionsMap : null,
        labels: labelsMap.isNotEmpty ? labelsMap : null,
        ipam: ipamConfig,
      );

      return result.fold(
        (success) {
          if (success) {
            return (true, nameController.text);
          } else {
            error = 'Failed to create network';
            return (false, error);
          }
        },
        (failure) {
          error = failure.message;
          return (false, error);
        },
      );
    } catch (e) {
      error = 'Error creating network: $e';
      return (false, error);
    } finally {
      isCreating = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    subnetController.dispose();
    gatewayController.dispose();
    super.dispose();
  }
}
