// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connection_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ConnectionConfig _$ConnectionConfigFromJson(Map<String, dynamic> json) {
  return _ConnectionConfig.fromJson(json);
}

/// @nodoc
mixin _$ConnectionConfig {
  String get uri => throw _privateConstructorUsedError;
  AuthType get authType => throw _privateConstructorUsedError;
  String? get token => throw _privateConstructorUsedError;
  bool get useTls => throw _privateConstructorUsedError;
  Map<String, dynamic>? get firebaseConfig =>
      throw _privateConstructorUsedError;

  /// Serializes this ConnectionConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConnectionConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConnectionConfigCopyWith<ConnectionConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConnectionConfigCopyWith<$Res> {
  factory $ConnectionConfigCopyWith(
    ConnectionConfig value,
    $Res Function(ConnectionConfig) then,
  ) = _$ConnectionConfigCopyWithImpl<$Res, ConnectionConfig>;
  @useResult
  $Res call({
    String uri,
    AuthType authType,
    String? token,
    bool useTls,
    Map<String, dynamic>? firebaseConfig,
  });
}

/// @nodoc
class _$ConnectionConfigCopyWithImpl<$Res, $Val extends ConnectionConfig>
    implements $ConnectionConfigCopyWith<$Res> {
  _$ConnectionConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConnectionConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? authType = null,
    Object? token = freezed,
    Object? useTls = null,
    Object? firebaseConfig = freezed,
  }) {
    return _then(
      _value.copyWith(
            uri: null == uri
                ? _value.uri
                : uri // ignore: cast_nullable_to_non_nullable
                      as String,
            authType: null == authType
                ? _value.authType
                : authType // ignore: cast_nullable_to_non_nullable
                      as AuthType,
            token: freezed == token
                ? _value.token
                : token // ignore: cast_nullable_to_non_nullable
                      as String?,
            useTls: null == useTls
                ? _value.useTls
                : useTls // ignore: cast_nullable_to_non_nullable
                      as bool,
            firebaseConfig: freezed == firebaseConfig
                ? _value.firebaseConfig
                : firebaseConfig // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConnectionConfigImplCopyWith<$Res>
    implements $ConnectionConfigCopyWith<$Res> {
  factory _$$ConnectionConfigImplCopyWith(
    _$ConnectionConfigImpl value,
    $Res Function(_$ConnectionConfigImpl) then,
  ) = __$$ConnectionConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String uri,
    AuthType authType,
    String? token,
    bool useTls,
    Map<String, dynamic>? firebaseConfig,
  });
}

/// @nodoc
class __$$ConnectionConfigImplCopyWithImpl<$Res>
    extends _$ConnectionConfigCopyWithImpl<$Res, _$ConnectionConfigImpl>
    implements _$$ConnectionConfigImplCopyWith<$Res> {
  __$$ConnectionConfigImplCopyWithImpl(
    _$ConnectionConfigImpl _value,
    $Res Function(_$ConnectionConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConnectionConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? authType = null,
    Object? token = freezed,
    Object? useTls = null,
    Object? firebaseConfig = freezed,
  }) {
    return _then(
      _$ConnectionConfigImpl(
        uri: null == uri
            ? _value.uri
            : uri // ignore: cast_nullable_to_non_nullable
                  as String,
        authType: null == authType
            ? _value.authType
            : authType // ignore: cast_nullable_to_non_nullable
                  as AuthType,
        token: freezed == token
            ? _value.token
            : token // ignore: cast_nullable_to_non_nullable
                  as String?,
        useTls: null == useTls
            ? _value.useTls
            : useTls // ignore: cast_nullable_to_non_nullable
                  as bool,
        firebaseConfig: freezed == firebaseConfig
            ? _value._firebaseConfig
            : firebaseConfig // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConnectionConfigImpl extends _ConnectionConfig {
  const _$ConnectionConfigImpl({
    required this.uri,
    this.authType = AuthType.none,
    this.token,
    this.useTls = false,
    final Map<String, dynamic>? firebaseConfig,
  }) : _firebaseConfig = firebaseConfig,
       super._();

  factory _$ConnectionConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConnectionConfigImplFromJson(json);

  @override
  final String uri;
  @override
  @JsonKey()
  final AuthType authType;
  @override
  final String? token;
  @override
  @JsonKey()
  final bool useTls;
  final Map<String, dynamic>? _firebaseConfig;
  @override
  Map<String, dynamic>? get firebaseConfig {
    final value = _firebaseConfig;
    if (value == null) return null;
    if (_firebaseConfig is EqualUnmodifiableMapView) return _firebaseConfig;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ConnectionConfig(uri: $uri, authType: $authType, token: $token, useTls: $useTls, firebaseConfig: $firebaseConfig)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectionConfigImpl &&
            (identical(other.uri, uri) || other.uri == uri) &&
            (identical(other.authType, authType) ||
                other.authType == authType) &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.useTls, useTls) || other.useTls == useTls) &&
            const DeepCollectionEquality().equals(
              other._firebaseConfig,
              _firebaseConfig,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    uri,
    authType,
    token,
    useTls,
    const DeepCollectionEquality().hash(_firebaseConfig),
  );

  /// Create a copy of ConnectionConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConnectionConfigImplCopyWith<_$ConnectionConfigImpl> get copyWith =>
      __$$ConnectionConfigImplCopyWithImpl<_$ConnectionConfigImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ConnectionConfigImplToJson(this);
  }
}

abstract class _ConnectionConfig extends ConnectionConfig {
  const factory _ConnectionConfig({
    required final String uri,
    final AuthType authType,
    final String? token,
    final bool useTls,
    final Map<String, dynamic>? firebaseConfig,
  }) = _$ConnectionConfigImpl;
  const _ConnectionConfig._() : super._();

  factory _ConnectionConfig.fromJson(Map<String, dynamic> json) =
      _$ConnectionConfigImpl.fromJson;

  @override
  String get uri;
  @override
  AuthType get authType;
  @override
  String? get token;
  @override
  bool get useTls;
  @override
  Map<String, dynamic>? get firebaseConfig;

  /// Create a copy of ConnectionConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConnectionConfigImplCopyWith<_$ConnectionConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
