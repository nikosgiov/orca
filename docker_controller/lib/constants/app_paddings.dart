import 'package:flutter/material.dart';

/// All [EdgeInsets] padding/margin definitions for the app.
///
/// Prefer these over inline [EdgeInsets] literals.
class AppPaddings {
  AppPaddings._();

  // ── Page / screen level ───────────────────────────────────────────────────────
  static const EdgeInsets screen = EdgeInsets.all(16);
  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(horizontal: 24);
  static const EdgeInsets pageHorizontalNarrow = EdgeInsets.symmetric(
    horizontal: 32,
  );

  // ── Cards ─────────────────────────────────────────────────────────────────────
  static const EdgeInsets card = EdgeInsets.all(16);
  static const EdgeInsets cardMargin = EdgeInsets.only(bottom: 12);
  static const EdgeInsets cardVerticalSpacing = EdgeInsets.symmetric(
    vertical: 24,
  );

  // ── Sections / items ──────────────────────────────────────────────────────────
  static const EdgeInsets section = EdgeInsets.only(bottom: 16);
  static const EdgeInsets item = EdgeInsets.symmetric(vertical: 4);

  // ── Buttons ───────────────────────────────────────────────────────────────────
  static const EdgeInsets button = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 12,
  );
  static const EdgeInsets headerButtonPadding = EdgeInsets.symmetric(
    vertical: 8,
    horizontal: 12,
  );

  // ── Icons ─────────────────────────────────────────────────────────────────────
  static const EdgeInsets iconPadding = EdgeInsets.all(8);

  // ── Chips / badges ────────────────────────────────────────────────────────────
  static const EdgeInsets statusBadgePadding = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 4,
  );
  static const EdgeInsets pluginBadgePadding = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 4,
  );
  static const EdgeInsets filterChipGap = EdgeInsets.only(right: 8);

  // ── Logs / notifications ───────────────────────────────────────────────────────
  static const EdgeInsets logCardMargin = EdgeInsets.only(bottom: 8);
  static const EdgeInsets logCardPadding = EdgeInsets.all(12);

  // ── Dropdowns / selects ───────────────────────────────────────────────────────
  static const EdgeInsets dropdownContentPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 8,
  );

  // ── Charts ───────────────────────────────────────────────────────────────────
  static const EdgeInsets chartSectionHorizontal = EdgeInsets.symmetric(
    horizontal: 16,
  );

  // ── Settings ─────────────────────────────────────────────────────────────────
  static const EdgeInsets statusContainerPadding = EdgeInsets.all(12);

  // ── Not-connected view ────────────────────────────────────────────────────────
  static const EdgeInsets notConnectedViewPadding = EdgeInsets.all(32);

  // ── Info rows ─────────────────────────────────────────────────────────────────
  static const EdgeInsets infoRowIconPadding = EdgeInsets.all(8);
  static const EdgeInsets expandedInfoRowValuePadding = EdgeInsets.only(
    left: 44,
  );
  static const EdgeInsetsGeometry inspectRowPadding = EdgeInsets.symmetric(
    vertical: 4,
  );

  // ── Progress indicator ────────────────────────────────────────────────────────
  static const EdgeInsets progressIndicatorRight = EdgeInsets.only(right: 8);

  // ── Error messages ────────────────────────────────────────────────────────────
  static const EdgeInsets errorMessagePadding = EdgeInsets.all(12);
  static const EdgeInsets errorMessageMargin = EdgeInsets.only(bottom: 16);

  // ── Create-container flow ─────────────────────────────────────────────────────
  static const EdgeInsets loadingImagesPadding = EdgeInsets.all(16);
  static const EdgeInsets detailCard = EdgeInsets.all(16);

  // ── Log controls / content ────────────────────────────────────────────────────
  static const EdgeInsets logControls = EdgeInsets.all(16);
  static const EdgeInsets logContent = EdgeInsets.all(16);
  static const EdgeInsets tabContent = EdgeInsets.all(16);
  static const EdgeInsets infoBoxPadding = EdgeInsets.all(12);
  static const EdgeInsets advancedDrawerPadding = EdgeInsets.all(20);

  // ── Misc ─────────────────────────────────────────────────────────────────────
  static const double gridSpacing = 16.0;

  // ── Screen-specific aliases (point to identical base constants) ───────────────
  /// Used in images_screen.dart – same as [cardMargin].
  static const EdgeInsets imageCardMargin = cardMargin;

  /// Used in images_screen.dart – same as [iconPadding].
  static const EdgeInsets imageIconPadding = iconPadding;

  /// Used in volumes_networks_screen.dart – same as [cardMargin].
  static const EdgeInsets volumeCardMargin = cardMargin;

  /// Used in volumes_networks_screen.dart – same as [iconPadding].
  static const EdgeInsets volumeIconPadding = iconPadding;

  /// Used in volumes_networks_screen.dart – same as [cardMargin].
  static const EdgeInsets networkCardMargin = cardMargin;

  /// Used in volumes_networks_screen.dart – same as [iconPadding].
  static const EdgeInsets networkIconPadding = iconPadding;

  /// Used in system_info_screen.dart – same as [iconPadding].
  static const EdgeInsets cardIconPadding = iconPadding;

  /// Used in settings_screen.dart – same as [iconPadding].
  static const EdgeInsets settingsCardIconPadding = iconPadding;

  /// Used in logs_notifications_screen.dart – same as [statusBadgePadding].
  static const EdgeInsets logLevelBadgePadding = statusBadgePadding;

  /// Used in logs_notifications_screen.dart – same as [logCardMargin].
  static const EdgeInsets notificationCardMargin = logCardMargin;

  /// Used in logs_notifications_screen.dart – same as [logCardPadding].
  static const EdgeInsets notificationCardPadding = logCardPadding;
}
