import 'package:flutter/material.dart';
import 'app_colors.dart';

/// All gradient definitions for the app.
class AppGradients {
  AppGradients._();

  /// Full-screen background gradient matching code.html body.
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.backgroundDark,
      AppColors.backgroundMid,
      AppColors.backgroundDark,
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// System node hero panel gradient (blue → purple → pink).
  static const LinearGradient systemNodeHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x66166FF5), // blue-600/40
      Color(0x669B34D4), // purple-600/40
      Color(0x66EC4899), // pink-600/40
    ],
  );

  /// Primary brand gradient (button, highlights).
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.secondary],
  );

  /// Same as [primary] but horizontal.
  static const LinearGradient primaryHorizontal = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.primary, AppColors.secondary],
  );

  /// Kept for backward compat.
  static const LinearGradient topBar = primary;
}
