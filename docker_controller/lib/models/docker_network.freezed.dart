// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'docker_network.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DockerNetwork _$DockerNetworkFromJson(Map<String, dynamic> json) {
  return _DockerNetwork.fromJson(json);
}

/// @nodoc
mixin _$DockerNetwork {
  @JsonKey(name: 'Id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'Name')
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'Driver')
  String get driver => throw _privateConstructorUsedError;
  @JsonKey(name: 'Scope')
  String get scope => throw _privateConstructorUsedError;
  @JsonKey(name: 'Created')
  String? get created => throw _privateConstructorUsedError;
  @JsonKey(name: 'Internal')
  bool get internal => throw _privateConstructorUsedError;
  @JsonKey(name: 'EnableIPv6')
  bool get enableIPv6 => throw _privateConstructorUsedError;
  @JsonKey(name: 'Labels')
  Map<String, dynamic> get labels => throw _privateConstructorUsedError;
  @JsonKey(name: 'IPAM')
  Map<String, dynamic>? get ipam => throw _privateConstructorUsedError;
  @JsonKey(name: 'Containers')
  Map<String, dynamic>? get containers => throw _privateConstructorUsedError;

  /// Serializes this DockerNetwork to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DockerNetwork
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DockerNetworkCopyWith<DockerNetwork> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DockerNetworkCopyWith<$Res> {
  factory $DockerNetworkCopyWith(
    DockerNetwork value,
    $Res Function(DockerNetwork) then,
  ) = _$DockerNetworkCopyWithImpl<$Res, DockerNetwork>;
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'Name') String name,
    @JsonKey(name: 'Driver') String driver,
    @JsonKey(name: 'Scope') String scope,
    @JsonKey(name: 'Created') String? created,
    @JsonKey(name: 'Internal') bool internal,
    @JsonKey(name: 'EnableIPv6') bool enableIPv6,
    @JsonKey(name: 'Labels') Map<String, dynamic> labels,
    @JsonKey(name: 'IPAM') Map<String, dynamic>? ipam,
    @JsonKey(name: 'Containers') Map<String, dynamic>? containers,
  });
}

/// @nodoc
class _$DockerNetworkCopyWithImpl<$Res, $Val extends DockerNetwork>
    implements $DockerNetworkCopyWith<$Res> {
  _$DockerNetworkCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DockerNetwork
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? driver = null,
    Object? scope = null,
    Object? created = freezed,
    Object? internal = null,
    Object? enableIPv6 = null,
    Object? labels = null,
    Object? ipam = freezed,
    Object? containers = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            driver: null == driver
                ? _value.driver
                : driver // ignore: cast_nullable_to_non_nullable
                      as String,
            scope: null == scope
                ? _value.scope
                : scope // ignore: cast_nullable_to_non_nullable
                      as String,
            created: freezed == created
                ? _value.created
                : created // ignore: cast_nullable_to_non_nullable
                      as String?,
            internal: null == internal
                ? _value.internal
                : internal // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableIPv6: null == enableIPv6
                ? _value.enableIPv6
                : enableIPv6 // ignore: cast_nullable_to_non_nullable
                      as bool,
            labels: null == labels
                ? _value.labels
                : labels // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            ipam: freezed == ipam
                ? _value.ipam
                : ipam // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            containers: freezed == containers
                ? _value.containers
                : containers // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DockerNetworkImplCopyWith<$Res>
    implements $DockerNetworkCopyWith<$Res> {
  factory _$$DockerNetworkImplCopyWith(
    _$DockerNetworkImpl value,
    $Res Function(_$DockerNetworkImpl) then,
  ) = __$$DockerNetworkImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'Name') String name,
    @JsonKey(name: 'Driver') String driver,
    @JsonKey(name: 'Scope') String scope,
    @JsonKey(name: 'Created') String? created,
    @JsonKey(name: 'Internal') bool internal,
    @JsonKey(name: 'EnableIPv6') bool enableIPv6,
    @JsonKey(name: 'Labels') Map<String, dynamic> labels,
    @JsonKey(name: 'IPAM') Map<String, dynamic>? ipam,
    @JsonKey(name: 'Containers') Map<String, dynamic>? containers,
  });
}

/// @nodoc
class __$$DockerNetworkImplCopyWithImpl<$Res>
    extends _$DockerNetworkCopyWithImpl<$Res, _$DockerNetworkImpl>
    implements _$$DockerNetworkImplCopyWith<$Res> {
  __$$DockerNetworkImplCopyWithImpl(
    _$DockerNetworkImpl _value,
    $Res Function(_$DockerNetworkImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DockerNetwork
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? driver = null,
    Object? scope = null,
    Object? created = freezed,
    Object? internal = null,
    Object? enableIPv6 = null,
    Object? labels = null,
    Object? ipam = freezed,
    Object? containers = freezed,
  }) {
    return _then(
      _$DockerNetworkImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        driver: null == driver
            ? _value.driver
            : driver // ignore: cast_nullable_to_non_nullable
                  as String,
        scope: null == scope
            ? _value.scope
            : scope // ignore: cast_nullable_to_non_nullable
                  as String,
        created: freezed == created
            ? _value.created
            : created // ignore: cast_nullable_to_non_nullable
                  as String?,
        internal: null == internal
            ? _value.internal
            : internal // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableIPv6: null == enableIPv6
            ? _value.enableIPv6
            : enableIPv6 // ignore: cast_nullable_to_non_nullable
                  as bool,
        labels: null == labels
            ? _value._labels
            : labels // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        ipam: freezed == ipam
            ? _value._ipam
            : ipam // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        containers: freezed == containers
            ? _value._containers
            : containers // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DockerNetworkImpl implements _DockerNetwork {
  const _$DockerNetworkImpl({
    @JsonKey(name: 'Id') required this.id,
    @JsonKey(name: 'Name') required this.name,
    @JsonKey(name: 'Driver') required this.driver,
    @JsonKey(name: 'Scope') required this.scope,
    @JsonKey(name: 'Created') this.created,
    @JsonKey(name: 'Internal') required this.internal,
    @JsonKey(name: 'EnableIPv6') required this.enableIPv6,
    @JsonKey(name: 'Labels') final Map<String, dynamic> labels = const {},
    @JsonKey(name: 'IPAM') final Map<String, dynamic>? ipam,
    @JsonKey(name: 'Containers') final Map<String, dynamic>? containers,
  }) : _labels = labels,
       _ipam = ipam,
       _containers = containers;

  factory _$DockerNetworkImpl.fromJson(Map<String, dynamic> json) =>
      _$$DockerNetworkImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final String id;
  @override
  @JsonKey(name: 'Name')
  final String name;
  @override
  @JsonKey(name: 'Driver')
  final String driver;
  @override
  @JsonKey(name: 'Scope')
  final String scope;
  @override
  @JsonKey(name: 'Created')
  final String? created;
  @override
  @JsonKey(name: 'Internal')
  final bool internal;
  @override
  @JsonKey(name: 'EnableIPv6')
  final bool enableIPv6;
  final Map<String, dynamic> _labels;
  @override
  @JsonKey(name: 'Labels')
  Map<String, dynamic> get labels {
    if (_labels is EqualUnmodifiableMapView) return _labels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_labels);
  }

  final Map<String, dynamic>? _ipam;
  @override
  @JsonKey(name: 'IPAM')
  Map<String, dynamic>? get ipam {
    final value = _ipam;
    if (value == null) return null;
    if (_ipam is EqualUnmodifiableMapView) return _ipam;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _containers;
  @override
  @JsonKey(name: 'Containers')
  Map<String, dynamic>? get containers {
    final value = _containers;
    if (value == null) return null;
    if (_containers is EqualUnmodifiableMapView) return _containers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'DockerNetwork(id: $id, name: $name, driver: $driver, scope: $scope, created: $created, internal: $internal, enableIPv6: $enableIPv6, labels: $labels, ipam: $ipam, containers: $containers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DockerNetworkImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.driver, driver) || other.driver == driver) &&
            (identical(other.scope, scope) || other.scope == scope) &&
            (identical(other.created, created) || other.created == created) &&
            (identical(other.internal, internal) ||
                other.internal == internal) &&
            (identical(other.enableIPv6, enableIPv6) ||
                other.enableIPv6 == enableIPv6) &&
            const DeepCollectionEquality().equals(other._labels, _labels) &&
            const DeepCollectionEquality().equals(other._ipam, _ipam) &&
            const DeepCollectionEquality().equals(
              other._containers,
              _containers,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    driver,
    scope,
    created,
    internal,
    enableIPv6,
    const DeepCollectionEquality().hash(_labels),
    const DeepCollectionEquality().hash(_ipam),
    const DeepCollectionEquality().hash(_containers),
  );

  /// Create a copy of DockerNetwork
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DockerNetworkImplCopyWith<_$DockerNetworkImpl> get copyWith =>
      __$$DockerNetworkImplCopyWithImpl<_$DockerNetworkImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DockerNetworkImplToJson(this);
  }
}

abstract class _DockerNetwork implements DockerNetwork {
  const factory _DockerNetwork({
    @JsonKey(name: 'Id') required final String id,
    @JsonKey(name: 'Name') required final String name,
    @JsonKey(name: 'Driver') required final String driver,
    @JsonKey(name: 'Scope') required final String scope,
    @JsonKey(name: 'Created') final String? created,
    @JsonKey(name: 'Internal') required final bool internal,
    @JsonKey(name: 'EnableIPv6') required final bool enableIPv6,
    @JsonKey(name: 'Labels') final Map<String, dynamic> labels,
    @JsonKey(name: 'IPAM') final Map<String, dynamic>? ipam,
    @JsonKey(name: 'Containers') final Map<String, dynamic>? containers,
  }) = _$DockerNetworkImpl;

  factory _DockerNetwork.fromJson(Map<String, dynamic> json) =
      _$DockerNetworkImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  String get id;
  @override
  @JsonKey(name: 'Name')
  String get name;
  @override
  @JsonKey(name: 'Driver')
  String get driver;
  @override
  @JsonKey(name: 'Scope')
  String get scope;
  @override
  @JsonKey(name: 'Created')
  String? get created;
  @override
  @JsonKey(name: 'Internal')
  bool get internal;
  @override
  @JsonKey(name: 'EnableIPv6')
  bool get enableIPv6;
  @override
  @JsonKey(name: 'Labels')
  Map<String, dynamic> get labels;
  @override
  @JsonKey(name: 'IPAM')
  Map<String, dynamic>? get ipam;
  @override
  @JsonKey(name: 'Containers')
  Map<String, dynamic>? get containers;

  /// Create a copy of DockerNetwork
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DockerNetworkImplCopyWith<_$DockerNetworkImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
