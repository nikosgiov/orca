import 'package:flutter/widgets.dart';
import '../../l10n/app_localizations.dart';

/// Extensions for [BuildContext] to simplify common accessors.
extension ContextExtensions on BuildContext {
  /// Quick access to [AppLocalizations].
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
