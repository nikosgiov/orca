import 'package:shared_preferences/shared_preferences.dart';

class NotificationStorageService {
  NotificationStorageService();

  Future<Map<String, dynamic>> loadPreferences(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final cleanUrl = _cleanUrl(url);
    
    return {
      'docker_monitoring': prefs.getBool('docker_monitoring_$cleanUrl') ?? true,
      'resource_monitoring': prefs.getBool('resource_monitoring_$cleanUrl') ?? true,
      'thresholds': {
        'cpu': prefs.getDouble('threshold_cpu_$cleanUrl') ?? 80.0,
        'memory': prefs.getDouble('threshold_memory_$cleanUrl') ?? 85.0,
        'gpu_load': prefs.getDouble('threshold_gpu_load_$cleanUrl') ?? 80.0,
        'gpu_memory': prefs.getDouble('threshold_gpu_memory_$cleanUrl') ?? 85.0,
      }
    };
  }

  Future<void> savePreferences(
    String url, {
    required bool dockerMonitoring,
    required bool resourceMonitoring,
    required Map<String, double> thresholds,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cleanUrl = _cleanUrl(url);

    await prefs.setBool('docker_monitoring_$cleanUrl', dockerMonitoring);
    await prefs.setBool('resource_monitoring_$cleanUrl', resourceMonitoring);

    await prefs.setDouble('threshold_cpu_$cleanUrl', thresholds['cpu'] ?? 80.0);
    await prefs.setDouble('threshold_memory_$cleanUrl', thresholds['memory'] ?? 85.0);
    await prefs.setDouble('threshold_gpu_load_$cleanUrl', thresholds['gpu_load'] ?? 80.0);
    await prefs.setDouble('threshold_gpu_memory_$cleanUrl', thresholds['gpu_memory'] ?? 85.0);
  }

  String _cleanUrl(String url) => url.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
}
