// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'docker_volume.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DockerVolume _$DockerVolumeFromJson(Map<String, dynamic> json) {
  return _DockerVolume.fromJson(json);
}

/// @nodoc
mixin _$DockerVolume {
  @JsonKey(name: 'Name')
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'Driver')
  String get driver => throw _privateConstructorUsedError;
  @JsonKey(name: 'Mountpoint')
  String get mountpoint => throw _privateConstructorUsedError;
  @JsonKey(name: 'CreatedAt')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'Labels')
  Map<String, dynamic> get labels => throw _privateConstructorUsedError;
  @JsonKey(name: 'Options')
  Map<String, dynamic>? get options => throw _privateConstructorUsedError;
  @JsonKey(name: 'Scope')
  String get scope => throw _privateConstructorUsedError;

  /// Serializes this DockerVolume to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DockerVolume
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DockerVolumeCopyWith<DockerVolume> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DockerVolumeCopyWith<$Res> {
  factory $DockerVolumeCopyWith(
    DockerVolume value,
    $Res Function(DockerVolume) then,
  ) = _$DockerVolumeCopyWithImpl<$Res, DockerVolume>;
  @useResult
  $Res call({
    @JsonKey(name: 'Name') String name,
    @JsonKey(name: 'Driver') String driver,
    @JsonKey(name: 'Mountpoint') String mountpoint,
    @JsonKey(name: 'CreatedAt') String? createdAt,
    @JsonKey(name: 'Labels') Map<String, dynamic> labels,
    @JsonKey(name: 'Options') Map<String, dynamic>? options,
    @JsonKey(name: 'Scope') String scope,
  });
}

/// @nodoc
class _$DockerVolumeCopyWithImpl<$Res, $Val extends DockerVolume>
    implements $DockerVolumeCopyWith<$Res> {
  _$DockerVolumeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DockerVolume
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? driver = null,
    Object? mountpoint = null,
    Object? createdAt = freezed,
    Object? labels = null,
    Object? options = freezed,
    Object? scope = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            driver: null == driver
                ? _value.driver
                : driver // ignore: cast_nullable_to_non_nullable
                      as String,
            mountpoint: null == mountpoint
                ? _value.mountpoint
                : mountpoint // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            labels: null == labels
                ? _value.labels
                : labels // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            options: freezed == options
                ? _value.options
                : options // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            scope: null == scope
                ? _value.scope
                : scope // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DockerVolumeImplCopyWith<$Res>
    implements $DockerVolumeCopyWith<$Res> {
  factory _$$DockerVolumeImplCopyWith(
    _$DockerVolumeImpl value,
    $Res Function(_$DockerVolumeImpl) then,
  ) = __$$DockerVolumeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Name') String name,
    @JsonKey(name: 'Driver') String driver,
    @JsonKey(name: 'Mountpoint') String mountpoint,
    @JsonKey(name: 'CreatedAt') String? createdAt,
    @JsonKey(name: 'Labels') Map<String, dynamic> labels,
    @JsonKey(name: 'Options') Map<String, dynamic>? options,
    @JsonKey(name: 'Scope') String scope,
  });
}

/// @nodoc
class __$$DockerVolumeImplCopyWithImpl<$Res>
    extends _$DockerVolumeCopyWithImpl<$Res, _$DockerVolumeImpl>
    implements _$$DockerVolumeImplCopyWith<$Res> {
  __$$DockerVolumeImplCopyWithImpl(
    _$DockerVolumeImpl _value,
    $Res Function(_$DockerVolumeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DockerVolume
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? driver = null,
    Object? mountpoint = null,
    Object? createdAt = freezed,
    Object? labels = null,
    Object? options = freezed,
    Object? scope = null,
  }) {
    return _then(
      _$DockerVolumeImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        driver: null == driver
            ? _value.driver
            : driver // ignore: cast_nullable_to_non_nullable
                  as String,
        mountpoint: null == mountpoint
            ? _value.mountpoint
            : mountpoint // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        labels: null == labels
            ? _value._labels
            : labels // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        options: freezed == options
            ? _value._options
            : options // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        scope: null == scope
            ? _value.scope
            : scope // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DockerVolumeImpl implements _DockerVolume {
  const _$DockerVolumeImpl({
    @JsonKey(name: 'Name') required this.name,
    @JsonKey(name: 'Driver') required this.driver,
    @JsonKey(name: 'Mountpoint') required this.mountpoint,
    @JsonKey(name: 'CreatedAt') this.createdAt,
    @JsonKey(name: 'Labels') final Map<String, dynamic> labels = const {},
    @JsonKey(name: 'Options') final Map<String, dynamic>? options,
    @JsonKey(name: 'Scope') required this.scope,
  }) : _labels = labels,
       _options = options;

  factory _$DockerVolumeImpl.fromJson(Map<String, dynamic> json) =>
      _$$DockerVolumeImplFromJson(json);

  @override
  @JsonKey(name: 'Name')
  final String name;
  @override
  @JsonKey(name: 'Driver')
  final String driver;
  @override
  @JsonKey(name: 'Mountpoint')
  final String mountpoint;
  @override
  @JsonKey(name: 'CreatedAt')
  final String? createdAt;
  final Map<String, dynamic> _labels;
  @override
  @JsonKey(name: 'Labels')
  Map<String, dynamic> get labels {
    if (_labels is EqualUnmodifiableMapView) return _labels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_labels);
  }

  final Map<String, dynamic>? _options;
  @override
  @JsonKey(name: 'Options')
  Map<String, dynamic>? get options {
    final value = _options;
    if (value == null) return null;
    if (_options is EqualUnmodifiableMapView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'Scope')
  final String scope;

  @override
  String toString() {
    return 'DockerVolume(name: $name, driver: $driver, mountpoint: $mountpoint, createdAt: $createdAt, labels: $labels, options: $options, scope: $scope)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DockerVolumeImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.driver, driver) || other.driver == driver) &&
            (identical(other.mountpoint, mountpoint) ||
                other.mountpoint == mountpoint) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._labels, _labels) &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            (identical(other.scope, scope) || other.scope == scope));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    driver,
    mountpoint,
    createdAt,
    const DeepCollectionEquality().hash(_labels),
    const DeepCollectionEquality().hash(_options),
    scope,
  );

  /// Create a copy of DockerVolume
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DockerVolumeImplCopyWith<_$DockerVolumeImpl> get copyWith =>
      __$$DockerVolumeImplCopyWithImpl<_$DockerVolumeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DockerVolumeImplToJson(this);
  }
}

abstract class _DockerVolume implements DockerVolume {
  const factory _DockerVolume({
    @JsonKey(name: 'Name') required final String name,
    @JsonKey(name: 'Driver') required final String driver,
    @JsonKey(name: 'Mountpoint') required final String mountpoint,
    @JsonKey(name: 'CreatedAt') final String? createdAt,
    @JsonKey(name: 'Labels') final Map<String, dynamic> labels,
    @JsonKey(name: 'Options') final Map<String, dynamic>? options,
    @JsonKey(name: 'Scope') required final String scope,
  }) = _$DockerVolumeImpl;

  factory _DockerVolume.fromJson(Map<String, dynamic> json) =
      _$DockerVolumeImpl.fromJson;

  @override
  @JsonKey(name: 'Name')
  String get name;
  @override
  @JsonKey(name: 'Driver')
  String get driver;
  @override
  @JsonKey(name: 'Mountpoint')
  String get mountpoint;
  @override
  @JsonKey(name: 'CreatedAt')
  String? get createdAt;
  @override
  @JsonKey(name: 'Labels')
  Map<String, dynamic> get labels;
  @override
  @JsonKey(name: 'Options')
  Map<String, dynamic>? get options;
  @override
  @JsonKey(name: 'Scope')
  String get scope;

  /// Create a copy of DockerVolume
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DockerVolumeImplCopyWith<_$DockerVolumeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
