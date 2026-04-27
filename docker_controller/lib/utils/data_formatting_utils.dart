import 'dart:math';

class DataFormattingUtils {
  /// Formats a byte value into a human-readable string (e.g., 1.5 GB).
  static String formatBytes(double bytes, {int decimals = 1}) {
    if (bytes <= 0) {
      return '0 B';
    }
    
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    
    // Use log base 1024 to find the appropriate unit index
    final i = (log(bytes) / log(1024)).floor();
    
    // Clamp the index to the available suffixes
    final suffixIndex = i.clamp(0, suffixes.length - 1);
    
    // Calculate the value in the target unit
    final value = bytes / pow(1024, suffixIndex);
    
    // Only show decimals for KB and above
    final formattedValue = value.toStringAsFixed(suffixIndex == 0 ? 0 : decimals);
    
    return '$formattedValue ${suffixes[suffixIndex]}';
  }

  /// Formats a bitrate or transfer speed (e.g., 5.2 MB/s).
  static String formatNetworkSpeed(double bytesPerSecond) {
    return '${formatBytes(bytesPerSecond)}/s';
  }

  /// Provides a compact representation for tight UI spaces (e.g., 1.5G, 500K).
  static String formatNetworkSpeedCompact(double bytes) {
    if (bytes <= 0) {
      return '0B';
    }
    
    const suffixes = ['', 'K', 'M', 'G', 'T', 'P'];
    final i = (log(bytes) / log(1024)).floor();
    final suffixIndex = i.clamp(0, suffixes.length - 1);
    final value = bytes / pow(1024, suffixIndex);
    
    final formattedValue = value.toStringAsFixed(value >= 100 ? 0 : 1);
    return '$formattedValue${suffixes[suffixIndex]}${suffixIndex == 0 ? 'B' : ''}';
  }

  /// Formats a decimal percentage to a string (e.g., 85.5%).
  static String formatPercentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }
}
