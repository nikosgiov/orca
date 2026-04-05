import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';

/// Reusable [BoxDecoration] definitions for the app.
class AppDecorations {
  AppDecorations._();

  /// Glassmorphism card – the main card style matching code.html glass cards.
  static BoxDecoration get glassCard => BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        border: Border.all(color: AppColors.glassBorder, width: 1),
        boxShadow: glassShadow,
      );

  /// Alias 'card' → glass card (replaces old white card).
  static BoxDecoration get card => glassCard;

  /// Card with a slightly brighter border for emphasis.
  static BoxDecoration get cardBordered => BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        border: Border.all(color: AppColors.glassBorder, width: 1),
        boxShadow: glassShadow,
      );

  /// Dark glass modal (bottom sheets / dialogs).
  static BoxDecoration get modal => const BoxDecoration(
        color: Color(0xFF110530),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.modalBorderRadius),
        ),
      );

  /// Error message box (dark red tint).
  static BoxDecoration get errorBox => BoxDecoration(
        color: AppColors.errorBackground,
        borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
        border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.4)),
      );

  /// Gradient pill button decoration.
  static BoxDecoration get gradientButton => BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const LinearGradient(
          colors: [Color(0xFF3A7BD5), Color(0xFF2563C0)],
        ),
      );

  /// Tinted glass pill button (hollow, with border + bg).
  static BoxDecoration glassPillButton(Color color) => BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      );

  /// Small icon container (rounded square).
  static BoxDecoration iconContainer(Color color) => BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.iconBorderRadius),
      );

  /// Error icon container.
  static BoxDecoration get errorIconContainer => BoxDecoration(
        color: AppColors.errorRed.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
      );

  /// Glass row item (used in Infrastructure list tiles).
  static BoxDecoration get glassListItem => BoxDecoration(
        color: AppColors.glassOverlay,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.5)),
      );

  /// Standard glass box shadow.
  static List<BoxShadow> get glassShadow => [
        BoxShadow(
          // ignore: deprecated_member_use
          color: Colors.black.withOpacity(0.4),
          blurRadius: 30,
          offset: const Offset(0, 8),
        ),
      ];

  /// Kept for backward compat (was card shadow in light theme).
  static List<BoxShadow> get cardShadow => glassShadow;
}
