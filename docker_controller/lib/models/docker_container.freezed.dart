// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'docker_container.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DockerContainer _$DockerContainerFromJson(Map<String, dynamic> json) {
  return _DockerContainer.fromJson(json);
}

/// @nodoc
mixin _$DockerContainer {
  @JsonKey(name: 'Id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'Names')
  List<String> get names => throw _privateConstructorUsedError;
  @JsonKey(name: 'Image')
  String get image => throw _privateConstructorUsedError;
  @JsonKey(name: 'State')
  dynamic get state => throw _privateConstructorUsedError; // Can be String or Map
  @JsonKey(name: 'Status')
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'Created')
  dynamic get created => throw _privateConstructorUsedError;
  @JsonKey(name: 'Ports')
  List<Map<String, dynamic>> get ports => throw _privateConstructorUsedError;
  @JsonKey(name: 'Labels')
  Map<String, dynamic> get labels => throw _privateConstructorUsedError;
  @JsonKey(name: 'Command')
  String? get command => throw _privateConstructorUsedError;
  @JsonKey(name: 'Mounts')
  List<Map<String, dynamic>> get mounts => throw _privateConstructorUsedError;
  @JsonKey(name: 'Config')
  Map<String, dynamic>? get config => throw _privateConstructorUsedError;
  @JsonKey(name: 'HostConfig')
  Map<String, dynamic>? get hostConfig => throw _privateConstructorUsedError;
  @JsonKey(name: 'NetworkSettings')
  Map<String, dynamic>? get networkSettings =>
      throw _privateConstructorUsedError;

  /// Serializes this DockerContainer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DockerContainer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DockerContainerCopyWith<DockerContainer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DockerContainerCopyWith<$Res> {
  factory $DockerContainerCopyWith(
    DockerContainer value,
    $Res Function(DockerContainer) then,
  ) = _$DockerContainerCopyWithImpl<$Res, DockerContainer>;
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'Names') List<String> names,
    @JsonKey(name: 'Image') String image,
    @JsonKey(name: 'State') dynamic state,
    @JsonKey(name: 'Status') String? status,
    @JsonKey(name: 'Created') dynamic created,
    @JsonKey(name: 'Ports') List<Map<String, dynamic>> ports,
    @JsonKey(name: 'Labels') Map<String, dynamic> labels,
    @JsonKey(name: 'Command') String? command,
    @JsonKey(name: 'Mounts') List<Map<String, dynamic>> mounts,
    @JsonKey(name: 'Config') Map<String, dynamic>? config,
    @JsonKey(name: 'HostConfig') Map<String, dynamic>? hostConfig,
    @JsonKey(name: 'NetworkSettings') Map<String, dynamic>? networkSettings,
  });
}

/// @nodoc
class _$DockerContainerCopyWithImpl<$Res, $Val extends DockerContainer>
    implements $DockerContainerCopyWith<$Res> {
  _$DockerContainerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DockerContainer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? names = null,
    Object? image = null,
    Object? state = freezed,
    Object? status = freezed,
    Object? created = freezed,
    Object? ports = null,
    Object? labels = null,
    Object? command = freezed,
    Object? mounts = null,
    Object? config = freezed,
    Object? hostConfig = freezed,
    Object? networkSettings = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            names: null == names
                ? _value.names
                : names // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            image: null == image
                ? _value.image
                : image // ignore: cast_nullable_to_non_nullable
                      as String,
            state: freezed == state
                ? _value.state
                : state // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String?,
            created: freezed == created
                ? _value.created
                : created // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            ports: null == ports
                ? _value.ports
                : ports // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
            labels: null == labels
                ? _value.labels
                : labels // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            command: freezed == command
                ? _value.command
                : command // ignore: cast_nullable_to_non_nullable
                      as String?,
            mounts: null == mounts
                ? _value.mounts
                : mounts // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
            config: freezed == config
                ? _value.config
                : config // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            hostConfig: freezed == hostConfig
                ? _value.hostConfig
                : hostConfig // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            networkSettings: freezed == networkSettings
                ? _value.networkSettings
                : networkSettings // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DockerContainerImplCopyWith<$Res>
    implements $DockerContainerCopyWith<$Res> {
  factory _$$DockerContainerImplCopyWith(
    _$DockerContainerImpl value,
    $Res Function(_$DockerContainerImpl) then,
  ) = __$$DockerContainerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'Names') List<String> names,
    @JsonKey(name: 'Image') String image,
    @JsonKey(name: 'State') dynamic state,
    @JsonKey(name: 'Status') String? status,
    @JsonKey(name: 'Created') dynamic created,
    @JsonKey(name: 'Ports') List<Map<String, dynamic>> ports,
    @JsonKey(name: 'Labels') Map<String, dynamic> labels,
    @JsonKey(name: 'Command') String? command,
    @JsonKey(name: 'Mounts') List<Map<String, dynamic>> mounts,
    @JsonKey(name: 'Config') Map<String, dynamic>? config,
    @JsonKey(name: 'HostConfig') Map<String, dynamic>? hostConfig,
    @JsonKey(name: 'NetworkSettings') Map<String, dynamic>? networkSettings,
  });
}

/// @nodoc
class __$$DockerContainerImplCopyWithImpl<$Res>
    extends _$DockerContainerCopyWithImpl<$Res, _$DockerContainerImpl>
    implements _$$DockerContainerImplCopyWith<$Res> {
  __$$DockerContainerImplCopyWithImpl(
    _$DockerContainerImpl _value,
    $Res Function(_$DockerContainerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DockerContainer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? names = null,
    Object? image = null,
    Object? state = freezed,
    Object? status = freezed,
    Object? created = freezed,
    Object? ports = null,
    Object? labels = null,
    Object? command = freezed,
    Object? mounts = null,
    Object? config = freezed,
    Object? hostConfig = freezed,
    Object? networkSettings = freezed,
  }) {
    return _then(
      _$DockerContainerImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        names: null == names
            ? _value._names
            : names // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        image: null == image
            ? _value.image
            : image // ignore: cast_nullable_to_non_nullable
                  as String,
        state: freezed == state
            ? _value.state
            : state // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        created: freezed == created
            ? _value.created
            : created // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        ports: null == ports
            ? _value._ports
            : ports // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
        labels: null == labels
            ? _value._labels
            : labels // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        command: freezed == command
            ? _value.command
            : command // ignore: cast_nullable_to_non_nullable
                  as String?,
        mounts: null == mounts
            ? _value._mounts
            : mounts // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
        config: freezed == config
            ? _value._config
            : config // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        hostConfig: freezed == hostConfig
            ? _value._hostConfig
            : hostConfig // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        networkSettings: freezed == networkSettings
            ? _value._networkSettings
            : networkSettings // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DockerContainerImpl extends _DockerContainer {
  const _$DockerContainerImpl({
    @JsonKey(name: 'Id') required this.id,
    @JsonKey(name: 'Names') final List<String> names = const [],
    @JsonKey(name: 'Image') required this.image,
    @JsonKey(name: 'State') this.state,
    @JsonKey(name: 'Status') this.status,
    @JsonKey(name: 'Created') required this.created,
    @JsonKey(name: 'Ports') final List<Map<String, dynamic>> ports = const [],
    @JsonKey(name: 'Labels') final Map<String, dynamic> labels = const {},
    @JsonKey(name: 'Command') this.command,
    @JsonKey(name: 'Mounts') final List<Map<String, dynamic>> mounts = const [],
    @JsonKey(name: 'Config') final Map<String, dynamic>? config,
    @JsonKey(name: 'HostConfig') final Map<String, dynamic>? hostConfig,
    @JsonKey(name: 'NetworkSettings')
    final Map<String, dynamic>? networkSettings,
  }) : _names = names,
       _ports = ports,
       _labels = labels,
       _mounts = mounts,
       _config = config,
       _hostConfig = hostConfig,
       _networkSettings = networkSettings,
       super._();

  factory _$DockerContainerImpl.fromJson(Map<String, dynamic> json) =>
      _$$DockerContainerImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final String id;
  final List<String> _names;
  @override
  @JsonKey(name: 'Names')
  List<String> get names {
    if (_names is EqualUnmodifiableListView) return _names;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_names);
  }

  @override
  @JsonKey(name: 'Image')
  final String image;
  @override
  @JsonKey(name: 'State')
  final dynamic state;
  // Can be String or Map
  @override
  @JsonKey(name: 'Status')
  final String? status;
  @override
  @JsonKey(name: 'Created')
  final dynamic created;
  final List<Map<String, dynamic>> _ports;
  @override
  @JsonKey(name: 'Ports')
  List<Map<String, dynamic>> get ports {
    if (_ports is EqualUnmodifiableListView) return _ports;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ports);
  }

  final Map<String, dynamic> _labels;
  @override
  @JsonKey(name: 'Labels')
  Map<String, dynamic> get labels {
    if (_labels is EqualUnmodifiableMapView) return _labels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_labels);
  }

  @override
  @JsonKey(name: 'Command')
  final String? command;
  final List<Map<String, dynamic>> _mounts;
  @override
  @JsonKey(name: 'Mounts')
  List<Map<String, dynamic>> get mounts {
    if (_mounts is EqualUnmodifiableListView) return _mounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mounts);
  }

  final Map<String, dynamic>? _config;
  @override
  @JsonKey(name: 'Config')
  Map<String, dynamic>? get config {
    final value = _config;
    if (value == null) return null;
    if (_config is EqualUnmodifiableMapView) return _config;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _hostConfig;
  @override
  @JsonKey(name: 'HostConfig')
  Map<String, dynamic>? get hostConfig {
    final value = _hostConfig;
    if (value == null) return null;
    if (_hostConfig is EqualUnmodifiableMapView) return _hostConfig;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _networkSettings;
  @override
  @JsonKey(name: 'NetworkSettings')
  Map<String, dynamic>? get networkSettings {
    final value = _networkSettings;
    if (value == null) return null;
    if (_networkSettings is EqualUnmodifiableMapView) return _networkSettings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'DockerContainer(id: $id, names: $names, image: $image, state: $state, status: $status, created: $created, ports: $ports, labels: $labels, command: $command, mounts: $mounts, config: $config, hostConfig: $hostConfig, networkSettings: $networkSettings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DockerContainerImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other._names, _names) &&
            (identical(other.image, image) || other.image == image) &&
            const DeepCollectionEquality().equals(other.state, state) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other.created, created) &&
            const DeepCollectionEquality().equals(other._ports, _ports) &&
            const DeepCollectionEquality().equals(other._labels, _labels) &&
            (identical(other.command, command) || other.command == command) &&
            const DeepCollectionEquality().equals(other._mounts, _mounts) &&
            const DeepCollectionEquality().equals(other._config, _config) &&
            const DeepCollectionEquality().equals(
              other._hostConfig,
              _hostConfig,
            ) &&
            const DeepCollectionEquality().equals(
              other._networkSettings,
              _networkSettings,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    const DeepCollectionEquality().hash(_names),
    image,
    const DeepCollectionEquality().hash(state),
    status,
    const DeepCollectionEquality().hash(created),
    const DeepCollectionEquality().hash(_ports),
    const DeepCollectionEquality().hash(_labels),
    command,
    const DeepCollectionEquality().hash(_mounts),
    const DeepCollectionEquality().hash(_config),
    const DeepCollectionEquality().hash(_hostConfig),
    const DeepCollectionEquality().hash(_networkSettings),
  );

  /// Create a copy of DockerContainer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DockerContainerImplCopyWith<_$DockerContainerImpl> get copyWith =>
      __$$DockerContainerImplCopyWithImpl<_$DockerContainerImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DockerContainerImplToJson(this);
  }
}

abstract class _DockerContainer extends DockerContainer {
  const factory _DockerContainer({
    @JsonKey(name: 'Id') required final String id,
    @JsonKey(name: 'Names') final List<String> names,
    @JsonKey(name: 'Image') required final String image,
    @JsonKey(name: 'State') final dynamic state,
    @JsonKey(name: 'Status') final String? status,
    @JsonKey(name: 'Created') required final dynamic created,
    @JsonKey(name: 'Ports') final List<Map<String, dynamic>> ports,
    @JsonKey(name: 'Labels') final Map<String, dynamic> labels,
    @JsonKey(name: 'Command') final String? command,
    @JsonKey(name: 'Mounts') final List<Map<String, dynamic>> mounts,
    @JsonKey(name: 'Config') final Map<String, dynamic>? config,
    @JsonKey(name: 'HostConfig') final Map<String, dynamic>? hostConfig,
    @JsonKey(name: 'NetworkSettings')
    final Map<String, dynamic>? networkSettings,
  }) = _$DockerContainerImpl;
  const _DockerContainer._() : super._();

  factory _DockerContainer.fromJson(Map<String, dynamic> json) =
      _$DockerContainerImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  String get id;
  @override
  @JsonKey(name: 'Names')
  List<String> get names;
  @override
  @JsonKey(name: 'Image')
  String get image;
  @override
  @JsonKey(name: 'State')
  dynamic get state; // Can be String or Map
  @override
  @JsonKey(name: 'Status')
  String? get status;
  @override
  @JsonKey(name: 'Created')
  dynamic get created;
  @override
  @JsonKey(name: 'Ports')
  List<Map<String, dynamic>> get ports;
  @override
  @JsonKey(name: 'Labels')
  Map<String, dynamic> get labels;
  @override
  @JsonKey(name: 'Command')
  String? get command;
  @override
  @JsonKey(name: 'Mounts')
  List<Map<String, dynamic>> get mounts;
  @override
  @JsonKey(name: 'Config')
  Map<String, dynamic>? get config;
  @override
  @JsonKey(name: 'HostConfig')
  Map<String, dynamic>? get hostConfig;
  @override
  @JsonKey(name: 'NetworkSettings')
  Map<String, dynamic>? get networkSettings;

  /// Create a copy of DockerContainer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DockerContainerImplCopyWith<_$DockerContainerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
