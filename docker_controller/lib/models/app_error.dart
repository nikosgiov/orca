import '../l10n/app_localizations.dart';

class AppError {
  AppError({
    required this.message,
    this.l10nKey,
    this.type,
    this.error,
    this.stackTrace,
  });

  final String message;
  final String? l10nKey;
  final String? type;
  final Object? error;
  final StackTrace? stackTrace;

  /// Returns a localized message if l10nKey is present and valid,
  /// otherwise returns the raw message.
  String localizedMessage(AppLocalizations l10n) {
    if (l10nKey == null) {
      return message;
    }

    switch (l10nKey) {
      case 'errorTimeout':
        return l10n.errorTimeout;
      case 'errorConnection':
        return l10n.errorConnection;
      case 'errorUnauthorized':
        return l10n.errorUnauthorized;
      case 'errorForbidden':
        return l10n.errorForbidden;
      case 'errorNotFound':
        return l10n.errorNotFound;
      case 'errorInternal':
        return l10n.errorInternal;
      case 'errorUnknown':
        return l10n.errorUnknown;
      default:
        return message;
    }
  }

  @override
  String toString() => 'AppError(type: $type, l10nKey: $l10nKey, message: $message, error: $error)';
}
