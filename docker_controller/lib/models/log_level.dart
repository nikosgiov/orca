import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum LogLevel {
  all,
  error,
  warn,
  info,
  debug;

  String get label {
    switch (this) {
      case LogLevel.all:
        return 'All';
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.warn:
        return 'WARN';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.debug:
        return 'DEBUG';
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
