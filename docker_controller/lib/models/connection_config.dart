import 'package:freezed_annotation/freezed_annotation.dart';

part 'connection_config.freezed.dart';
part 'connection_config.g.dart';

enum AuthType { none, basic }

extension AuthTypeExtension on AuthType {
  String get displayName => switch (this) {
    AuthType.none => 'No Authentication',
    AuthType.basic => 'Basic Authentication',
  };

  String get description => switch (this) {
    AuthType.none => 'Connect without authentication',
    AuthType.basic => 'Use username and password',
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
