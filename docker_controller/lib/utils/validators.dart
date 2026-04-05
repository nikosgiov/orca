import '../constants/app_strings.dart';

class Validators {
  static String? validateUri(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.uriRequired;
    }
    // Accepts IP or hostname, with optional :port
    final regex = RegExp(r'^([a-zA-Z0-9.-]+)(:\d{1,5})?$');
    if (!regex.hasMatch(value.trim())) {
      return AppStrings.invalidIpPort;
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.usernameRequired;
    }
    // Allow any non-empty username
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.passwordRequired;
    }
    // Allow any non-empty password
    return null;
  }

  static String? validateImageName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Image name is required.';
    }
    final namePattern = RegExp(r'^[a-zA-Z0-9_.\-\/]+$');
    if (!namePattern.hasMatch(value.trim())) {
      return 'Image name can only contain letters, numbers, dots, dashes, underscores, and slashes.';
    }
    return null;
  }

  static String? validateTag(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tag is required.';
    }
    final tagPattern = RegExp(r'^[a-zA-Z0-9_.\-]+$');
    if (!tagPattern.hasMatch(value.trim())) {
      return 'Tag can only contain letters, numbers, dots, dashes, and underscores.';
    }
    return null;
  }

  static String? validatePort(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Port is required.';
    }
    final port = int.tryParse(value.trim());
    if (port == null || port < 1 || port > 65535) {
      return 'Port must be a number between 1 and 65535.';
    }
    return null;
  }

  static String? validateLabelKey(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Label key is required.';
    }
    final trimmed = value.trim();
    // Docker label keys should be alphanumeric with dots, dashes, and underscores
    // Spaces are technically allowed but not recommended
    final keyPattern = RegExp(r'^[a-zA-Z0-9._\-]+$');
    if (!keyPattern.hasMatch(trimmed)) {
      return 'Label key can only contain letters, numbers, dots, dashes, and underscores.';
    }
    return null;
  }

  static String? validateLabelValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Label value is required.';
    }
    final trimmed = value.trim();
    // Docker label values can contain spaces and most characters
    // But we should avoid control characters and excessive whitespace
    if (trimmed.contains('\n') || trimmed.contains('\r') || trimmed.contains('\t')) {
      return 'Label value cannot contain newlines or tabs.';
    }
    if (trimmed.length > 255) {
      return 'Label value cannot exceed 255 characters.';
    }
    return null;
  }

  static String? validateDriverOptionKey(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Driver option key is required.';
    }
    final trimmed = value.trim();
    // Driver option keys should be alphanumeric with dots, dashes, and underscores
    // Spaces are technically allowed but not recommended
    final keyPattern = RegExp(r'^[a-zA-Z0-9._\-]+$');
    if (!keyPattern.hasMatch(trimmed)) {
      return 'Driver option key can only contain letters, numbers, dots, dashes, and underscores.';
    }
    return null;
  }

  static String? validateDriverOptionValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Driver option value is required.';
    }
    final trimmed = value.trim();
    // Driver option values can contain spaces and most characters
    // But we should avoid control characters and excessive whitespace
    if (trimmed.contains('\n') || trimmed.contains('\r') || trimmed.contains('\t')) {
      return 'Driver option value cannot contain newlines or tabs.';
    }
    if (trimmed.length > 255) {
      return 'Driver option value cannot exceed 255 characters.';
    }
    return null;
  }
} 