import 'package:flutter/material.dart';
import 'app_colors.dart';

/// All [TextStyle] definitions for the app.
class AppTextStyles {
  AppTextStyles._();

  // ── Headings ──────────────────────────────────────────────────────────────────
  static const TextStyle heading1 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w300,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
  );

  // ── Section label (10px uppercase tracking – matches code.html h2 labels) ────
  static const TextStyle sectionLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 1.5,
  );

  // ── Body ─────────────────────────────────────────────────────────────────────
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w300,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  // ── Stat cards ───────────────────────────────────────────────────────────────
  static const TextStyle statValue = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w300,
    color: AppColors.textPrimary,
  );

  static const TextStyle statLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 1.5,
  );

  // ── Top bar ───────────────────────────────────────────────────────────────────
  static const TextStyle topBarTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  // ── Buttons ───────────────────────────────────────────────────────────────────
  static const TextStyle buttonLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
  );

  // ── Chips ────────────────────────────────────────────────────────────────────
  static const TextStyle chip = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.0,
  );

  static const TextStyle filterChipSelected = TextStyle(
    color: AppColors.primary,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle filterChipUnselected = TextStyle(
    color: AppColors.textMuted,
    fontWeight: FontWeight.w500,
  );

  // ── Info rows ─────────────────────────────────────────────────────────────────
  static const TextStyle infoLabel = TextStyle(
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    fontSize: 10,
    letterSpacing: 1.5,
  );

  static const TextStyle infoValue = TextStyle(
    fontWeight: FontWeight.w300,
    fontSize: 13,
    color: AppColors.textPrimary,
  );

  // ── Section headers (inside cards) ────────────────────────────────────────────
  static const TextStyle sectionHeader = TextStyle(
    fontSize: 10,
    color: AppColors.textMuted,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
  );

  // ── Modals ───────────────────────────────────────────────────────────────────
  static const TextStyle modalTitle = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 20,
    color: AppColors.textPrimary,
  );

  // ── Error messages ───────────────────────────────────────────────────────────
  static const TextStyle errorMessage = TextStyle(
    color: AppColors.errorRed,
    fontWeight: FontWeight.w600,
    fontSize: 14,
  );

  // ── Step progress ─────────────────────────────────────────────────────────────
  static const TextStyle stepLabel = TextStyle(
    fontSize: 13,
    color: AppColors.textMuted,
  );

  // ── Loading indicator ─────────────────────────────────────────────────────────
  static const TextStyle loadingMessage = TextStyle(
    color: AppColors.textMuted,
    fontSize: 14,
  );
}