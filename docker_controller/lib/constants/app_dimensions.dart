/// All numeric sizing tokens for the app.
///
/// Use these instead of raw doubles/integers.
class AppDimensions {
  AppDimensions._();

  // ── Border Radii ────────────────────────────────────────────────────────────
  /// Radius used on text inputs and navigation step buttons (12 px).
  static const double inputBorderRadius = 12;

  /// Radius used on cards and resource cards (16 px).
  static const double cardBorderRadius = 16;

  /// Radius used on filter chips (20 px).
  static const double filterChipRadius = 20;

  /// Radius used on modals / bottom sheets (24 px).
  static const double modalBorderRadius = 24;

  /// Radius used on the connection-screen logo image (32 px).
  static const double logoBorderRadius = 32;

  /// Radius used on the gradient top-bar bottom corners (24 px).
  static const double topBarRadius = 24;

  /// Radius used on status chips (16 px).
  static const double statusChipBorderRadius = 16;

  /// Small radius used on icon containers / settings card headers (8 px).
  static const double iconBorderRadius = 8;

  // ── Heights ─────────────────────────────────────────────────────────────────
  /// Default height of the gradient top bar.
  static const double topBarHeight = 80;

  /// Height of primary action buttons (Connect, Next, Previous, etc.).
  static const double buttonHeight = 48;

  /// Size of the inline loading spinner inside buttons.
  static const double buttonSpinnerSize = 20;

  // ── Card / Resource sizes ───────────────────────────────────────────────────
  /// Fixed width of each resource card on the dashboard.
  static const double resourceCardWidth = 220;

  /// Fixed height of the horizontal resource card scroll area.
  static const double resourceCardHeight = 220;

  /// Mini chart height inside a resource card.
  static const double miniChartHeight = 90;

  /// Height of the progress chart placeholder area in stat cards.
  static const double statChartPlaceholderHeight = 40;

  // ── Icon / Status circle sizes ──────────────────────────────────────────────
  /// Diameter of the status-count circle on the dashboard (running/stopped/exited).
  static const double statusCircleSize = 48;

  /// Icon size in settings card headers.
  static const double settingsIconSize = 20;

  /// Small icon size used inside info rows.
  static const double infoIconSize = 16;

  /// Default icon size used in the connection-screen logo container.
  static const double logoSize = 160;

  /// Size of the "not connected" cloud icon.
  static const double notConnectedIconSize = 48;

  // ── Step progress bar ───────────────────────────────────────────────────────
  /// Track height for StepProgressBar.
  static const double progressBarHeight = 6;

  // ── Miscellaneous ───────────────────────────────────────────────────────────
  /// Stroke width for inline button loading spinners.
  static const double buttonSpinnerStrokeWidth = 2;

  /// Left-padding offset for expanded info row values (icon 16 + gap 12 + border 16 ≈ 44).
  static const double expandedInfoValueIndent = 44;
}
