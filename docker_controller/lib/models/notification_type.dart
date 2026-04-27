
enum NotificationType {
  success,
  warning,
  error,
  info;

  static NotificationType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'success':
        return NotificationType.success;
      case 'warning':
        return NotificationType.warning;
      case 'error':
        return NotificationType.error;
      case 'info':
      default:
        return NotificationType.info;
    }
  }

  String toJson() => name;
}
