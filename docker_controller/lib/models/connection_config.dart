enum AuthType {
  none,
  basic,
}

extension AuthTypeExtension on AuthType {
  String get displayName {
    switch (this) {
      case AuthType.none:
        return 'No Authentication';
      case AuthType.basic:
        return 'Basic Authentication';
    }
  }
  String get description {
    switch (this) {
      case AuthType.none:
        return 'Connect without authentication';
      case AuthType.basic:
        return 'Use username and password';
    }
  }
}

class ConnectionConfig {
  final String uri;
  final AuthType authType;
  final String? token;
  final bool useTls;
  final Map<String, dynamic>? firebaseConfig;


  ConnectionConfig({
    required this.uri,
    this.authType = AuthType.none,
    this.token,
    this.useTls = false,
    this.firebaseConfig,
  });


  ConnectionConfig copyWith({
    String? uri,
    AuthType? authType,
    String? token,
    bool? useTls,
    Map<String, dynamic>? firebaseConfig,
  }) {
    return ConnectionConfig(
      uri: uri ?? this.uri,
      authType: authType ?? this.authType,
      token: token ?? this.token,
      useTls: useTls ?? this.useTls,
      firebaseConfig: firebaseConfig ?? this.firebaseConfig,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'uri': uri,
      'authType': authType.name,
      'token': token,
      'useTls': useTls,
      'firebaseConfig': firebaseConfig,
    };
  }


  factory ConnectionConfig.fromJson(Map<String, dynamic> json) {
    return ConnectionConfig(
      uri: json['uri'] ?? '',
      authType: AuthType.values.firstWhere(
        (e) => e.name == json['authType'],
        orElse: () => AuthType.none,
      ),
      token: json['token'],
      useTls: _parseBool(json['useTls']),
      firebaseConfig: json['firebaseConfig'] != null 
          ? Map<String, dynamic>.from(json['firebaseConfig']) 
          : null,
    );
  }


  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return false;
  }

  bool get isValid {
    if (uri.isEmpty) return false;
    return true;
  }

  String get displayUri {
    return uri;
  }
} 