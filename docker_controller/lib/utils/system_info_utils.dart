class SystemInfoUtils {
  static String getSystemInfoValue(
    Map<String, dynamic>? systemInfo,
    String key,
    String defaultValue,
  ) {
    if (systemInfo == null) {
      return defaultValue;
    }
    return systemInfo[key]?.toString() ?? defaultValue;
  }

  static String getDockerVersion(Map<String, dynamic>? systemInfo) {
    return getSystemInfoValue(systemInfo, 'ServerVersion', 'Unknown');
  }

  static String getOsInfo(Map<String, dynamic>? systemInfo) {
    final os = getSystemInfoValue(systemInfo, 'OperatingSystem', 'Unknown');
    final arch = getSystemInfoValue(systemInfo, 'Architecture', '');
    return '$os $arch'.trim();
  }

  static String getHostname(Map<String, dynamic>? systemInfo) {
    return getSystemInfoValue(systemInfo, 'Name', 'Unknown');
  }

  static String getMemoryInfo(Map<String, dynamic>? systemInfo) {
    if (systemInfo == null) {
      return 'Unknown';
    }
    final memTotal = systemInfo['MemTotal'] ?? 0;
    final memTotalGB = (memTotal / (1024 * 1024 * 1024)).toStringAsFixed(1);
    return '$memTotalGB GB';
  }

  static String getCpuInfo(Map<String, dynamic>? systemInfo) {
    if (systemInfo == null) {
      return 'Unknown';
    }
    final ncpu = systemInfo['NCPU'] ?? 0;
    return ncpu.toString();
  }
}
