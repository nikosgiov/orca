// lib/screens/notification_settings_screen.dart

import 'package:flutter/material.dart';
import '../widgets/app_background.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/notification_service.dart';
import '../widgets/app_gradient_top_bar.dart';
import '../widgets/settings_card_header.dart';
import '../widgets/settings_switch_tile.dart';
import '../widgets/app_button.dart';
import '../constants/app_colors.dart';
import '../constants/app_paddings.dart';
import '../constants/app_text_styles.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
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

      if (!mounted) return;

      final appProvider = context.read<AppProvider>();
      final connection = appProvider.connectionConfig;
      if (connection != null) {
        final protocol = connection.useTls ? 'https://' : 'http://';
        _baseUrl = '$protocol${connection.uri}';
        await _notificationService.loadPreferences(_baseUrl!);
      }

      setState(() {
        _dockerMonitoringEnabled = _notificationService.dockerMonitoringEnabled;
        _resourceMonitoringEnabled = _notificationService.resourceMonitoringEnabled;

        final thresholds = _notificationService.thresholds;
        _cpuThresholdController.text = thresholds['cpu']?.toString() ?? '80.0';
        _memoryThresholdController.text = thresholds['memory']?.toString() ?? '85.0';
        _gpuLoadThresholdController.text = thresholds['gpu_load']?.toString() ?? '80.0';
        _gpuMemoryThresholdController.text = thresholds['gpu_memory']?.toString() ?? '85.0';
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load notification settings: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _registerForNotifications() async {
    final appProvider = context.read<AppProvider>();
    final connection = appProvider.connectionConfig;

    if (connection == null) {
      _showErrorSnackBar('No active connection');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final protocol = connection.useTls ? 'https://' : 'http://';
      final baseUrl = '$protocol${connection.uri}';

      await _notificationService.registerForNotifications(
        baseUrl: baseUrl,
        token: connection.token ?? '',
      );

      _showSuccessSnackBar('Successfully registered for notifications');
    } catch (e) {
      _showErrorSnackBar('Failed to register for notifications: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _syncSettings() async {
    final appProvider = context.read<AppProvider>();
    final connection = appProvider.connectionConfig;

    if (connection == null) return;

    try {
      final protocol = connection.useTls ? 'https://' : 'http://';
      final baseUrl = '$protocol${connection.uri}';

      await _notificationService.registerForNotifications(
        baseUrl: baseUrl,
        token: connection.token ?? '',
      );
    } catch (e) {
      _showErrorSnackBar('Failed to update server: $e');
    }
  }

  Future<void> _unregisterFromNotifications() async {
    final appProvider = context.read<AppProvider>();
    final connection = appProvider.connectionConfig;

    if (connection == null) {
      _showErrorSnackBar('No active connection');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final protocol = connection.useTls ? 'https://' : 'http://';
      final baseUrl = '$protocol${connection.uri}';

      await _notificationService.unregisterFromNotifications(
        baseUrl: baseUrl,
        token: connection.token ?? '',
      );

      _showSuccessSnackBar('Successfully unregistered from notifications');
    } catch (e) {
      _showErrorSnackBar('Failed to unregister from notifications: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateThresholds() async {
    if (!_formKey.currentState!.validate()) return;

    final appProvider = context.read<AppProvider>();
    final connection = appProvider.connectionConfig;

    if (connection == null) {
      _showErrorSnackBar('No active connection');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final protocol = connection.useTls ? 'https://' : 'http://';
      final baseUrl = '$protocol${connection.uri}';

      await _notificationService.updateThresholds(
        baseUrl: baseUrl,
        token: connection.token ?? '',
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
      SnackBar(content: Text(message), backgroundColor: AppColors.errorRed),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.successGreen),
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
            onPressed: () => Navigator.pop(context),
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
                    _buildNotificationStatus(),
                    const SizedBox(height: 24),
                    _buildMonitoringSettings(),
                    const SizedBox(height: 24),
                    _buildThresholdSettings(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
      ),
    );
  }

  // ── Helper: glass card decorator ──────────────────────────────────────────

  BoxDecoration get _glassCard => BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      );

  // ── Sections ──────────────────────────────────────────────────────────────

  Widget _buildNotificationStatus() {
    return Container(
      padding: AppPaddings.card,
      decoration: _glassCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsCardHeader(
            title: 'Notification Status',
            icon: Icons.notifications,
            gradientColors: const [AppColors.primaryCyan, AppColors.secondaryBlue],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                _notificationService.isInitialized ? Icons.check_circle : Icons.error,
                color: _notificationService.isInitialized
                    ? AppColors.successGreen
                    : AppColors.errorRed,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _notificationService.isInitialized
                      ? 'Notifications initialized'
                      : 'Notifications not initialized',
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                ),
              ),
            ],
          ),
          if (_notificationService.deviceToken != null) ...[
            const SizedBox(height: 8),
            Text(
              'Device Token: ${_notificationService.deviceToken!.substring(0, 20)}...',
              style: AppTextStyles.caption,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  onPressed: _registerForNotifications,
                  label: 'Register',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  onPressed: _unregisterFromNotifications,
                  label: 'Unregister',
                  outlined: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonitoringSettings() {
    return Container(
      padding: AppPaddings.card,
      decoration: _glassCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsCardHeader(
            title: 'Monitoring Settings',
            icon: Icons.monitor,
            gradientColors: const [AppColors.primaryCyan, AppColors.secondaryBlue],
          ),
          const SizedBox(height: 16),
          SettingsSwitchTile(
            title: 'Docker Monitoring',
            subtitle: 'Receive notifications for container and image changes',
            value: _dockerMonitoringEnabled,
            onChanged: (value) async {
              setState(() => _dockerMonitoringEnabled = value);
              await _notificationService.setNotificationPreferences(dockerMonitoring: value, url: _baseUrl);
              _syncSettings();
            },
          ),
          SettingsSwitchTile(
            title: 'Resource Monitoring',
            subtitle: 'Receive notifications for high resource usage',
            value: _resourceMonitoringEnabled,
            onChanged: (value) async {
              setState(() => _resourceMonitoringEnabled = value);
              await _notificationService.setNotificationPreferences(resourceMonitoring: value, url: _baseUrl);
              _syncSettings();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdSettings() {
    return Container(
      padding: AppPaddings.card,
      decoration: _glassCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsCardHeader(
            title: 'Resource Thresholds',
            icon: Icons.tune,
            gradientColors: const [AppColors.primaryCyan, AppColors.secondaryBlue],
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              children: [
                _DarkInputField(
                  controller: _cpuThresholdController,
                  label: 'CPU Threshold (%)',
                  validator: _percentValidator,
                ),
                const SizedBox(height: 16),
                _DarkInputField(
                  controller: _memoryThresholdController,
                  label: 'Memory Threshold (%)',
                  validator: _percentValidator,
                ),
                const SizedBox(height: 16),
                _DarkInputField(
                  controller: _gpuLoadThresholdController,
                  label: 'GPU Load Threshold (%)',
                  validator: _percentValidator,
                ),
                const SizedBox(height: 16),
                _DarkInputField(
                  controller: _gpuMemoryThresholdController,
                  label: 'GPU Memory Threshold (%)',
                  validator: _percentValidator,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    onPressed: _updateThresholds,
                    label: 'Update Thresholds',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  String? _percentValidator(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final n = double.tryParse(value);
    if (n == null || n < 0 || n > 100) return 'Enter 0–100';
    return null;
  }
}

// ── Dark-styled text field ────────────────────────────────────────────────────

class _DarkInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;

  const _DarkInputField({
    required this.controller,
    required this.label,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      validator: validator,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        filled: true,
        fillColor: AppColors.glassOverlay,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}