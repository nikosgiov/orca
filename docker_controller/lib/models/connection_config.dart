import 'package:freezed_annotation/freezed_annotation.dart';
import '../l10n/app_localizations.dart';

part 'connection_config.freezed.dart';
part 'connection_config.g.dart';

enum AuthType { none, basic }

extension AuthTypeExtension on AuthType {
  String getDisplayName(AppLocalizations l10n) => switch (this) {
        AuthType.none => l10n.authNone,
        AuthType.basic => l10n.authBasic,
      };

  String getDescription(AppLocalizations l10n) => switch (this) {
        AuthType.none => l10n.authNoneDesc,
        AuthType.basic => l10n.authBasicDesc,
      };
}

@freezed
class ConnectionConfig with _$ConnectionConfig {
  const factory ConnectionConfig({
    required String uri,
    @Default(AuthType.none) AuthType authType,
    String? token,
    @Default(false) bool useTls,
    Map<String, dynamic>? firebaseConfig,
  }) = _ConnectionConfig;

  const ConnectionConfig._();

  factory ConnectionConfig.fromJson(Map<String, dynamic> json) =>
      _$ConnectionConfigFromJson(json);

  bool get isValid => uri.isNotEmpty;

  String get displayUri => uri;
}
