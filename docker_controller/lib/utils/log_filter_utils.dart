class LogFilterUtils {
  static List<Map<String, dynamic>> filterLogs({
    required List<Map<String, dynamic>> logs,
    required String selectedLogLevel,
    required String selectedContainer,
  }) {
    return logs.where((log) {
      final matchesLevel = selectedLogLevel == 'All' || log['level'] == selectedLogLevel;
      final matchesContainer = selectedContainer == 'All' || log['container'] == selectedContainer;
      return matchesLevel && matchesContainer;
    }).toList();
  }
} 