import 'package:docker_controller/constants/app_colors.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

enum LogLevel {
  all,
  error,
  warn,
  info,
  debug;

  String getLabel(AppLocalizations l10n) {
    switch (this) {
      case LogLevel.all:
        return l10n.all;
      case LogLevel.error:
        return l10n.logLevelError;
      case LogLevel.warn:
        return l10n.logLevelWarn;
      case LogLevel.info:
        return l10n.logLevelInfo;
      case LogLevel.debug:
        return l10n.logLevelDebug;
    }
  }

  Color get color {
    switch (this) {
      case LogLevel.error:
        return AppColors.error;
      case LogLevel.warn:
        return AppColors.warning;
      case LogLevel.info:
        return AppColors.success;
      case LogLevel.debug:
        return AppColors.slate400;
      case LogLevel.all:
        return AppColors.textPrimary;
    }
  }

  static LogLevel fromString(String value) {
    switch (value.toUpperCase()) {
      case 'ERROR':
        return LogLevel.error;
      case 'WARN':
        return LogLevel.warn;
      case 'INFO':
        return LogLevel.info;
      case 'DEBUG':
        return LogLevel.debug;
      default:
        return LogLevel.all;
    }
  }
}
