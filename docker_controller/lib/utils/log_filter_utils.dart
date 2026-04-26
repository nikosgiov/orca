import '../models/log_entry.dart';
import '../models/log_level.dart';

class LogFilterUtils {
  static List<LogEntry> filterLogs({
    required List<LogEntry> logs,
    required LogLevel selectedLogLevel,
    required String selectedContainer,
  }) {
    return logs.where((log) {
      final matchesLevel =
          selectedLogLevel == LogLevel.all || log.level == selectedLogLevel;
      final matchesContainer =
          selectedContainer == 'All' || log.container == selectedContainer;
      return matchesLevel && matchesContainer;
    }).toList();
  }
}
