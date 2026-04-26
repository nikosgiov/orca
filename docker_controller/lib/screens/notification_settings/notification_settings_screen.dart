import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_paddings.dart';
import '../../core/di/service_locator.dart';
import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';
import '../../widgets/app_background.dart';
import '../../widgets/app_gradient_top_bar.dart';
import 'widgets/monitoring_settings_card.dart';
import 'widgets/status_card.dart';
import 'widgets/threshold_settings_card.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late final NotificationService _notificationService;
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _dockerMonitoringEnabled = true;
  bool _resourceMonitoringEnabled = true;
  String? _baseUrl;

  // Threshold controllers
  final _cpuThresholdController = TextEditingController(text: '80.0');
  final _memoryThresholdController = TextEditingController(text: '85.0');
  final _gpuLoadThresholdController = TextEditingController(text: '80.0');
  final _gpuMemoryThresholdController = TextEditingController(text: '85.0');

  @override
  void initState() {
    super.initState();
    _notificationService = getIt<NotificationService>();
    _loadSettings();
  }

  @override
  void dispose() {
    _cpuThresholdController.dispose();
    _memoryThresholdController.dispose();
    _gpuLoadThresholdController.dispose();
    _gpuMemoryThresholdController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    try {
      await _notificationService.initialize();

      if (!mounted) {
        return;
      }

      final authProvider = context.read<AuthProvider>();
      final connection = authProvider.connectionConfig;
      if (connection != null) {
        final protocol = connection.useTls ? 'https://' : 'http://';
        _baseUrl = '$protocol${connection.uri}';
        await _notificationService.loadPreferences(_baseUrl!);
      }

      setState(() {
        _dockerMonitoringEnabled = _notificationService.dockerMonitoringEnabled;
        _resourceMonitoringEnabled =
            _notificationService.resourceMonitoringEnabled;

        final thresholds = _notificationService.thresholds;
        _cpuThresholdController.text = thresholds['cpu']?.toString() ?? '80.0';
        _memoryThresholdController.text =
            thresholds['memory']?.toString() ?? '85.0';
        _gpuLoadThresholdController.text =
            thresholds['gpu_load']?.toString() ?? '80.0';
        _gpuMemoryThresholdController.text =
            thresholds['gpu_memory']?.toString() ?? '85.0';
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load notification settings: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _registerForNotifications() async {
    final authProvider = context.read<AuthProvider>();
    final connection = authProvider.connectionConfig;

    if (connection == null) {
      _showErrorSnackBar('No active connection');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _notificationService.registerForNotifications();
      _showSuccessSnackBar('Successfully registered for notifications');
    } catch (e) {
      _showErrorSnackBar('Failed to register for notifications: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _syncSettings() async {
    final authProvider = context.read<AuthProvider>();
    final connection = authProvider.connectionConfig;

    if (connection == null) {
      return;
    }

    try {
      await _notificationService.registerForNotifications();
    } catch (e) {
      _showErrorSnackBar('Failed to update server: $e');
    }
  }

  Future<void> _unregisterFromNotifications() async {
    final authProvider = context.read<AuthProvider>();
    final connection = authProvider.connectionConfig;

    if (connection == null) {
      _showErrorSnackBar('No active connection');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _notificationService.unregisterFromNotifications();
      _showSuccessSnackBar('Successfully unregistered from notifications');
    } catch (e) {
      _showErrorSnackBar('Failed to unregister from notifications: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateThresholds() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final connection = authProvider.connectionConfig;

    if (connection == null) {
      _showErrorSnackBar('No active connection');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _notificationService.updateThresholds(
        cpuThreshold: double.tryParse(_cpuThresholdController.text),
        memoryThreshold: double.tryParse(_memoryThresholdController.text),
        gpuLoadThreshold: double.tryParse(_gpuLoadThresholdController.text),
        gpuMemoryThreshold: double.tryParse(_gpuMemoryThresholdController.text),
      );

      _showSuccessSnackBar('Thresholds updated successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to update thresholds: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      position: const Offset(-40, -120),
      scale: 1.4,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppGradientTopBar(
          title: 'Notification Settings',
          leftWidget: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: AppPaddings.screen,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatusCard(
                      notificationService: _notificationService,
                      onRegister: _registerForNotifications,
                      onUnregister: _unregisterFromNotifications,
                    ),
                    const SizedBox(height: 24),
                    MonitoringSettingsCard(
                      dockerMonitoringEnabled: _dockerMonitoringEnabled,
                      resourceMonitoringEnabled: _resourceMonitoringEnabled,
                      onDockerMonitoringChanged: (value) async {
                        setState(() => _dockerMonitoringEnabled = value);
                        await _notificationService.setNotificationPreferences(
                          dockerMonitoring: value,
                          url: _baseUrl,
                        );
                        await _syncSettings();
                      },
                      onResourceMonitoringChanged: (value) async {
                        setState(() => _resourceMonitoringEnabled = value);
                        await _notificationService.setNotificationPreferences(
                          resourceMonitoring: value,
                          url: _baseUrl,
                        );
                        await _syncSettings();
                      },
                    ),
                    const SizedBox(height: 24),
                    ThresholdSettingsCard(
                      formKey: _formKey,
                      cpuController: _cpuThresholdController,
                      memoryController: _memoryThresholdController,
                      gpuLoadController: _gpuLoadThresholdController,
                      gpuMemoryController: _gpuMemoryThresholdController,
                      onUpdate: _updateThresholds,
                      percentValidator: _percentValidator,
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
      ),
    );
  }

  String? _percentValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    final n = double.tryParse(value);
    if (n == null || n < 0 || n > 100) {
      return 'Enter 0–100';
    }
    return null;
  }
}
