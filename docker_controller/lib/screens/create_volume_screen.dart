import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_background.dart';
import '../providers/app_provider.dart';
import '../services/volume_service.dart';
import '../widgets/app_gradient_top_bar.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_paddings.dart';
import '../widgets/step_progress_bar.dart';
import '../widgets/step_navigation_buttons.dart';
import '../utils/validators.dart';

class CreateVolumeProvider extends ChangeNotifier {
  final AppProvider appProvider;
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
  
  CreateVolumeProvider(this.appProvider);
  
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
    if (!(formKey.currentState?.validate() ?? false)) return null;
    
    // Validate driver options and labels
    for (final option in driverOptions) {
      if (option['key']?.isNotEmpty == true && option['value']?.isEmpty == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Driver option value cannot be empty'),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }
      if (option['key']?.isEmpty == true && option['value']?.isNotEmpty == true) {
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
    
    final connectionConfig = appProvider.connectionConfig;
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
        if (option['key']?.isNotEmpty == true && option['value']?.isNotEmpty == true) {
          driverOpts[option['key']!] = option['value']!;
        }
      }
      
      final labelsMap = <String, String>{};
      for (final label in labels) {
        if (label['key']?.isNotEmpty == true && label['value']?.isNotEmpty == true) {
          labelsMap[label['key']!] = label['value']!;
        }
      }
      
      final result = await VolumeService.createVolume(
        connectionConfig,
        nameController.text,
        driver: selectedDriver,
        driverOpts: driverOpts.isNotEmpty ? driverOpts : null,
        labels: labelsMap.isNotEmpty ? labelsMap : null,
      );
      
      if (result.success) {
        return nameController.text;
      } else {
        error = result.error?.message ?? 'Failed to create volume';
        if (!context.mounted) return null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error!),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }
    } catch (e) {
      error = 'Error creating volume: $e';
      if (!context.mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error!),
          backgroundColor: Colors.red,
        ),
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

class CreateVolumeScreen extends StatelessWidget {
  const CreateVolumeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        return ChangeNotifierProvider(
          create: (_) => CreateVolumeProvider(appProvider),
          child: const _CreateVolumeScreenBody(),
        );
      },
    );
  }
}

class _CreateVolumeScreenBody extends StatelessWidget {
  const _CreateVolumeScreenBody();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CreateVolumeProvider>(context);
    return AppBackground(
      position: const Offset(-80, 100),
      scale: 1.5,
      child: Scaffold(
        backgroundColor: Colors.transparent,
      appBar: AppGradientTopBar(
        title: 'Create Volume',
        leftWidget: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),

      ),
      body: Column(
        children: [
          // Horizontal Progress Bar
          Padding(
            padding: AppPaddings.card,
            child: StepProgressBar(
              stepTitles: provider.stepTitles,
              currentStep: provider.currentStep,
              width: 320,
              backgroundColor: AppColors.grey400,
              fillColor: AppColors.primaryCyan,
              titleStyle: AppTextStyles.heading2,
            ),
          ),
          // Form Content
          Expanded(
            child: Form(
              key: provider.formKey,
              child: Padding(
                padding: AppPaddings.screen,
                child: Column(
                  children: [
                    Expanded(
                      child: _buildCurrentStep(provider),
                    ),
                    const SizedBox(height: 24),
                    SafeArea(
                      bottom: true,
                      child: StepNavigationButtons(
                        currentStep: provider.currentStep,
                        totalSteps: provider.stepTitles.length,
                        onPrevious: provider.previousStep,
                        onNextOrCreate: provider.currentStep == provider.stepTitles.length - 1
                            ? () async {
                                final volumeName = await provider.createVolume(context);
                                if (volumeName != null) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Volume $volumeName created successfully!'),
                                      backgroundColor: const Color(0xFF10B981),
                                    ),
                                  );
                                  if (!context.mounted) return;
                                  Navigator.pop(context);
                                }
                              }
                            : () {
                                if (provider.formKey.currentState?.validate() ?? false) {
                                  provider.nextStep();
                                }
                              },
                        isCreating: provider.isCreating,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
   );
  }

  Widget _buildCurrentStep(CreateVolumeProvider provider) {
    switch (provider.currentStep) {
      case 0:
        return _buildBasicInfoStep(provider);
      case 1:
        return _buildAdvancedOptionsStep(provider);
      case 2:
        return _buildReviewStep(provider);
      default:
        return const SizedBox();
    }
  }

  Widget _buildBasicInfoStep(CreateVolumeProvider provider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          TextFormField(
            controller: provider.nameController,
            decoration: InputDecoration(
              labelText: 'Volume Name',
              hintText: 'my-volume',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              prefixIcon: const Icon(Icons.folder),
            ),
            onChanged: provider.setVolumeName,
            validator: Validators.validateImageName, // Reuse image name validation
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: provider.selectedDriver,
            decoration: InputDecoration(
              labelText: 'Driver',
              prefixIcon: const Icon(Icons.settings),
            ),
            items: const [
              DropdownMenuItem(value: 'local', child: Text('Local')),
              DropdownMenuItem(value: 'nfs', child: Text('NFS')),
              DropdownMenuItem(value: 'cifs', child: Text('CIFS')),
              DropdownMenuItem(value: 'tmpfs', child: Text('Tmpfs')),
            ],
            onChanged: provider.setDriver,
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedOptionsStep(CreateVolumeProvider provider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Driver Options Section
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.glassBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.settings, color: AppColors.secondaryBlue),
                      const SizedBox(width: 8),
                      const Text('Driver Options', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        onPressed: provider.addDriverOption,
                        icon: const Icon(Icons.add, color: AppColors.secondaryBlue),
                        tooltip: 'Add driver option',
                      ),
                    ],
                  ),
                ),
                if (provider.driverOptions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No driver options added', style: TextStyle(color: Colors.grey)),
                  ),
                ...provider.driverOptions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Key',
                            ),
                            onChanged: (value) => provider.updateDriverOption(index, value, option['value'] ?? ''),
                            validator: Validators.validateDriverOptionKey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Value',
                            ),
                            onChanged: (value) => provider.updateDriverOption(index, option['key'] ?? '', value),
                            validator: Validators.validateDriverOptionValue,
                          ),
                        ),
                        IconButton(
                          onPressed: () => provider.removeDriverOption(index),
                          icon: const Icon(Icons.remove, color: Colors.red),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Labels Section
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.glassBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.label, color: AppColors.secondaryBlue),
                      const SizedBox(width: 8),
                      const Text('Labels', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        onPressed: provider.addLabel,
                        icon: const Icon(Icons.add, color: AppColors.secondaryBlue),
                        tooltip: 'Add label',
                      ),
                    ],
                  ),
                ),
                if (provider.labels.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No labels added', style: TextStyle(color: Colors.grey)),
                  ),
                ...provider.labels.asMap().entries.map((entry) {
                  final index = entry.key;
                  final label = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Key',
                            ),
                            onChanged: (value) => provider.updateLabel(index, value, label['value'] ?? ''),
                            validator: Validators.validateLabelKey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Value',
                            ),
                            onChanged: (value) => provider.updateLabel(index, label['key'] ?? '', value),
                            validator: Validators.validateLabelValue,
                          ),
                        ),
                        IconButton(
                          onPressed: () => provider.removeLabel(index),
                          icon: const Icon(Icons.remove, color: Colors.red),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep(CreateVolumeProvider provider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReviewCard('Name', provider.nameController.text, Icons.folder),
          _buildReviewCard('Driver', provider.selectedDriver, Icons.settings),
          if (provider.driverOptions.isNotEmpty)
            _buildReviewCard('Driver Options', 
              provider.driverOptions.map((o) => '${o['key']}=${o['value']}').join(', '), 
              Icons.settings),
          if (provider.labels.isNotEmpty)
            _buildReviewCard('Labels', 
              provider.labels.map((l) => '${l['key']}=${l['value']}').join(', '), 
              Icons.label),
        ],
      ),
    );
  }

  Widget _buildReviewCard(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondaryBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 
