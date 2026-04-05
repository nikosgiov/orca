class AppDelays {
  AppDelays._();

  // ── Container operations ──────────────────────────────────────────────────────
  /// Delay before re-fetching data after a container start/stop action.
  static const Duration containerOperationDelay = Duration(milliseconds: 500);

  // ── Network ───────────────────────────────────────────────────────────────────
  static const Duration networkRequestTimeout = Duration(seconds: 10);

  // ── Animations ────────────────────────────────────────────────────────────────
  /// Standard widget transition / progress-bar animation duration.
  static const Duration animationDuration = Duration(milliseconds: 300);

  /// Gap between cascaded entrance animations on the connection screen (step 1).
  static const Duration connectionAnimStep1 = Duration(milliseconds: 200);

  /// Gap between cascaded entrance animations on the connection screen (step 2).
  static const Duration connectionAnimStep2 = Duration(milliseconds: 300);
}