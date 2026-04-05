import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Background ───────────────────────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0D0221);
  static const Color backgroundMid = Color(0xFF1A0B3B);

  // Glass card: ~80% opaque deep purple — matches code.html rgba(20, 10, 50, 0.6)
  static const Color glassBg = Color(0xCC140A32);

  // ── Brand ────────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF3A7BD5);
  static const Color accentPurple = Color(0xFF8E24AA);
  static const Color accentMagenta = Color(0xFFD81B60);

  // Aliases kept for backward compat
  static const Color primaryCyan = Color(0xFF3A7BD5);   // → primary
  static const Color secondaryBlue = Color(0xFF2563C0); // slightly darker blue

  // ── Semantic ─────────────────────────────────────────────────────────────────
  static const Color errorRed = Color(0xFFEF4444);
  static const Color warningYellow = Color(0xFFF59E0B);
  static const Color successGreen = Color(0xFF10B981);
  static const Color errorBackground = Color(0x22EF4444);

  // ── Text ─────────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF1F5F9);   // slate-100
  static const Color textMuted = Color(0xFF94A3B8);      // slate-400
  static const Color textSubtle = Color(0xFF64748B);     // slate-500

  // ── Glass borders / overlays ─────────────────────────────────────────────────
  // white with 10% alpha
  static const Color glassBorder = Color(0x1AFFFFFF);
  // white with 5% alpha
  static const Color glassOverlay = Color(0x0DFFFFFF);

  // ── Neutrals (kept for compat) ────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;

  static const Color grey = Color(0xFF94A3B8);
  static const Color grey400 = Color(0xFF94A3B8);
  static const Color grey500 = Color(0xFF64748B);
  static const Color grey600 = Color(0xFF475569);

  // Use backgroundDark as "backgroundColor" everywhere
  static const Color backgroundColor = backgroundDark;
  static const Color lightGray = Color(0xFF1E1040);

  static const Color darkBlue = Color(0xFF1A0B3B);
  static const Color darkSlate = Color(0xFF334155);
  static const Color charcoalGray = Color(0xFF475569);

  static const Color inputIcon = Color(0xFF94A3B8);
  static const Color orange = Colors.orange;
}