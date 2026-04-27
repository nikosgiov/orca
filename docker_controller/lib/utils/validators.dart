class Validators {
  static String? validateUri(
    String? value, {
    required String requiredError,
    required String invalidError,
  }) {
    if (value == null || value.trim().isEmpty) {
      return requiredError;
    }
    // Accepts IP or hostname, with optional :port
    final regex = RegExp(r'^([a-zA-Z0-9.-]+)(:\d{1,5})?$');
    if (!regex.hasMatch(value.trim())) {
      return invalidError;
    }
    return null;
  }

  static String? validateUsername(String? value, {required String requiredError}) {
    if (value == null || value.trim().isEmpty) {
      return requiredError;
    }
    // Allow any non-empty username
    return null;
  }

  static String? validatePassword(String? value, {required String requiredError}) {
    if (value == null || value.trim().isEmpty) {
      return requiredError;
    }
    // Allow any non-empty password
    return null;
  }

  static String? validateImageName(String? value, {required String requiredError, required String invalidError}) {
    if (value == null || value.trim().isEmpty) {
      return requiredError;
    }
    final namePattern = RegExp(r'^[a-zA-Z0-9_.\-\/]+$');
    if (!namePattern.hasMatch(value.trim())) {
      return invalidError;
    }
    return null;
  }

  static String? validateTag(String? value, {required String requiredError, required String invalidError}) {
    if (value == null || value.trim().isEmpty) {
      return requiredError;
    }
    final tagPattern = RegExp(r'^[a-zA-Z0-9_.\-]+$');
    if (!tagPattern.hasMatch(value.trim())) {
      return invalidError;
    }
    return null;
  }

  static String? validatePort(String? value, {required String requiredError, required String invalidError}) {
    if (value == null || value.trim().isEmpty) {
      return requiredError;
    }
    final port = int.tryParse(value.trim());
    if (port == null || port < 1 || port > 65535) {
      return invalidError;
    }
    return null;
  }

  static String? validateLabelKey(
    String? value, {
    required String requiredError,
    required String invalidError,
  }) {
    if (value == null || value.trim().isEmpty) {
      return requiredError;
    }
    final trimmed = value.trim();
    final keyPattern = RegExp(r'^[a-zA-Z0-9._\-]+$');
    if (!keyPattern.hasMatch(trimmed)) {
      return invalidError;
    }
    return null;
  }

  static String? validateLabelValue(
    String? value, {
    required String requiredError,
    required String noTabsError,
    required String tooLongError,
  }) {
    if (value == null || value.trim().isEmpty) {
      return requiredError;
    }
    final trimmed = value.trim();
    if (trimmed.contains('\n') ||
        trimmed.contains('\r') ||
        trimmed.contains('\t')) {
      return noTabsError;
    }
    if (trimmed.length > 255) {
      return tooLongError;
    }
    return null;
  }

  static String? validateDriverOptionKey(
    String? value, {
    required String requiredError,
    required String invalidError,
  }) {
    if (value == null || value.trim().isEmpty) {
      return requiredError;
    }
    final trimmed = value.trim();
    final keyPattern = RegExp(r'^[a-zA-Z0-9._\-]+$');
    if (!keyPattern.hasMatch(trimmed)) {
      return invalidError;
    }
    return null;
  }

  static String? validateDriverOptionValue(
    String? value, {
    required String requiredError,
    required String noTabsError,
    required String tooLongError,
  }) {
    if (value == null || value.trim().isEmpty) {
      return requiredError;
    }
    final trimmed = value.trim();
    if (trimmed.contains('\n') ||
        trimmed.contains('\r') ||
        trimmed.contains('\t')) {
      return noTabsError;
    }
    if (trimmed.length > 255) {
      return tooLongError;
    }
    return null;
  }
}
