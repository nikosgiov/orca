import 'preferences_service.dart';

class NotificationStorageService {
  NotificationStorageService(this._prefs);

  final PreferencesService _prefs;

  Future<Map<String, dynamic>> loadPreferences(String url) async {
    final cleanUrl = _cleanUrl(url);
    
    return {
      'docker_monitoring': _prefs.getBool('docker_monitoring_$cleanUrl', defaultValue: true),
      'resource_monitoring': _prefs.getBool('resource_monitoring_$cleanUrl', defaultValue: true),
      'thresholds': {
        'cpu': _prefs.getDouble('threshold_cpu_$cleanUrl', defaultValue: 80.0),
        'memory': _prefs.getDouble('threshold_memory_$cleanUrl', defaultValue: 85.0),
        'gpu_load': _prefs.getDouble('threshold_gpu_load_$cleanUrl', defaultValue: 80.0),
        'gpu_memory': _prefs.getDouble('threshold_gpu_memory_$cleanUrl', defaultValue: 85.0),
      }
    };
  }

  Future<void> savePreferences(
    String url, {
    required bool dockerMonitoring,
    required bool resourceMonitoring,
    required Map<String, double> thresholds,
  }) async {
    final cleanUrl = _cleanUrl(url);

    await _prefs.setBool('docker_monitoring_$cleanUrl', dockerMonitoring);
    await _prefs.setBool('resource_monitoring_$cleanUrl', resourceMonitoring);

    await _prefs.setDouble('threshold_cpu_$cleanUrl', thresholds['cpu'] ?? 80.0);
    await _prefs.setDouble('threshold_memory_$cleanUrl', thresholds['memory'] ?? 85.0);
    await _prefs.setDouble('threshold_gpu_load_$cleanUrl', thresholds['gpu_load'] ?? 80.0);
    await _prefs.setDouble('threshold_gpu_memory_$cleanUrl', thresholds['gpu_memory'] ?? 85.0);
  }

  String _cleanUrl(String url) => url.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
}
