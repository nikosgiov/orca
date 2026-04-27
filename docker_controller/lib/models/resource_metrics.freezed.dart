// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'resource_metrics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ResourceMetrics _$ResourceMetricsFromJson(Map<String, dynamic> json) {
  return _ResourceMetrics.fromJson(json);
}

/// @nodoc
mixin _$ResourceMetrics {
  List<DockerContainer> get containers => throw _privateConstructorUsedError;
  List<DockerImage> get images => throw _privateConstructorUsedError;
  Map<String, dynamic> get systemInfo => throw _privateConstructorUsedError;
  List<ResourceDataPoint> get history => throw _privateConstructorUsedError;
  Map<String, dynamic> get basicStats => throw _privateConstructorUsedError;
  Map<String, dynamic> get rawMetrics => throw _privateConstructorUsedError;

  /// Serializes this ResourceMetrics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ResourceMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResourceMetricsCopyWith<ResourceMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResourceMetricsCopyWith<$Res> {
  factory $ResourceMetricsCopyWith(
    ResourceMetrics value,
    $Res Function(ResourceMetrics) then,
  ) = _$ResourceMetricsCopyWithImpl<$Res, ResourceMetrics>;
  @useResult
  $Res call({
    List<DockerContainer> containers,
    List<DockerImage> images,
    Map<String, dynamic> systemInfo,
    List<ResourceDataPoint> history,
    Map<String, dynamic> basicStats,
    Map<String, dynamic> rawMetrics,
  });
}

/// @nodoc
class _$ResourceMetricsCopyWithImpl<$Res, $Val extends ResourceMetrics>
    implements $ResourceMetricsCopyWith<$Res> {
  _$ResourceMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResourceMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? containers = null,
    Object? images = null,
    Object? systemInfo = null,
    Object? history = null,
    Object? basicStats = null,
    Object? rawMetrics = null,
  }) {
    return _then(
      _value.copyWith(
            containers: null == containers
                ? _value.containers
                : containers // ignore: cast_nullable_to_non_nullable
                      as List<DockerContainer>,
            images: null == images
                ? _value.images
                : images // ignore: cast_nullable_to_non_nullable
                      as List<DockerImage>,
            systemInfo: null == systemInfo
                ? _value.systemInfo
                : systemInfo // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            history: null == history
                ? _value.history
                : history // ignore: cast_nullable_to_non_nullable
                      as List<ResourceDataPoint>,
            basicStats: null == basicStats
                ? _value.basicStats
                : basicStats // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            rawMetrics: null == rawMetrics
                ? _value.rawMetrics
                : rawMetrics // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ResourceMetricsImplCopyWith<$Res>
    implements $ResourceMetricsCopyWith<$Res> {
  factory _$$ResourceMetricsImplCopyWith(
    _$ResourceMetricsImpl value,
    $Res Function(_$ResourceMetricsImpl) then,
  ) = __$$ResourceMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<DockerContainer> containers,
    List<DockerImage> images,
    Map<String, dynamic> systemInfo,
    List<ResourceDataPoint> history,
    Map<String, dynamic> basicStats,
    Map<String, dynamic> rawMetrics,
  });
}

/// @nodoc
class __$$ResourceMetricsImplCopyWithImpl<$Res>
    extends _$ResourceMetricsCopyWithImpl<$Res, _$ResourceMetricsImpl>
    implements _$$ResourceMetricsImplCopyWith<$Res> {
  __$$ResourceMetricsImplCopyWithImpl(
    _$ResourceMetricsImpl _value,
    $Res Function(_$ResourceMetricsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ResourceMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? containers = null,
    Object? images = null,
    Object? systemInfo = null,
    Object? history = null,
    Object? basicStats = null,
    Object? rawMetrics = null,
  }) {
    return _then(
      _$ResourceMetricsImpl(
        containers: null == containers
            ? _value._containers
            : containers // ignore: cast_nullable_to_non_nullable
                  as List<DockerContainer>,
        images: null == images
            ? _value._images
            : images // ignore: cast_nullable_to_non_nullable
                  as List<DockerImage>,
        systemInfo: null == systemInfo
            ? _value._systemInfo
            : systemInfo // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        history: null == history
            ? _value._history
            : history // ignore: cast_nullable_to_non_nullable
                  as List<ResourceDataPoint>,
        basicStats: null == basicStats
            ? _value._basicStats
            : basicStats // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        rawMetrics: null == rawMetrics
            ? _value._rawMetrics
            : rawMetrics // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ResourceMetricsImpl implements _ResourceMetrics {
  const _$ResourceMetricsImpl({
    final List<DockerContainer> containers = const [],
    final List<DockerImage> images = const [],
    final Map<String, dynamic> systemInfo = const {},
    final List<ResourceDataPoint> history = const [],
    final Map<String, dynamic> basicStats = const {},
    final Map<String, dynamic> rawMetrics = const {},
  }) : _containers = containers,
       _images = images,
       _systemInfo = systemInfo,
       _history = history,
       _basicStats = basicStats,
       _rawMetrics = rawMetrics;

  factory _$ResourceMetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResourceMetricsImplFromJson(json);

  final List<DockerContainer> _containers;
  @override
  @JsonKey()
  List<DockerContainer> get containers {
    if (_containers is EqualUnmodifiableListView) return _containers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_containers);
  }

  final List<DockerImage> _images;
  @override
  @JsonKey()
  List<DockerImage> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  final Map<String, dynamic> _systemInfo;
  @override
  @JsonKey()
  Map<String, dynamic> get systemInfo {
    if (_systemInfo is EqualUnmodifiableMapView) return _systemInfo;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_systemInfo);
  }

  final List<ResourceDataPoint> _history;
  @override
  @JsonKey()
  List<ResourceDataPoint> get history {
    if (_history is EqualUnmodifiableListView) return _history;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_history);
  }

  final Map<String, dynamic> _basicStats;
  @override
  @JsonKey()
  Map<String, dynamic> get basicStats {
    if (_basicStats is EqualUnmodifiableMapView) return _basicStats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_basicStats);
  }

  final Map<String, dynamic> _rawMetrics;
  @override
  @JsonKey()
  Map<String, dynamic> get rawMetrics {
    if (_rawMetrics is EqualUnmodifiableMapView) return _rawMetrics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_rawMetrics);
  }

  @override
  String toString() {
    return 'ResourceMetrics(containers: $containers, images: $images, systemInfo: $systemInfo, history: $history, basicStats: $basicStats, rawMetrics: $rawMetrics)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResourceMetricsImpl &&
            const DeepCollectionEquality().equals(
              other._containers,
              _containers,
            ) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            const DeepCollectionEquality().equals(
              other._systemInfo,
              _systemInfo,
            ) &&
            const DeepCollectionEquality().equals(other._history, _history) &&
            const DeepCollectionEquality().equals(
              other._basicStats,
              _basicStats,
            ) &&
            const DeepCollectionEquality().equals(
              other._rawMetrics,
              _rawMetrics,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_containers),
    const DeepCollectionEquality().hash(_images),
    const DeepCollectionEquality().hash(_systemInfo),
    const DeepCollectionEquality().hash(_history),
    const DeepCollectionEquality().hash(_basicStats),
    const DeepCollectionEquality().hash(_rawMetrics),
  );

  /// Create a copy of ResourceMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResourceMetricsImplCopyWith<_$ResourceMetricsImpl> get copyWith =>
      __$$ResourceMetricsImplCopyWithImpl<_$ResourceMetricsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ResourceMetricsImplToJson(this);
  }
}

abstract class _ResourceMetrics implements ResourceMetrics {
  const factory _ResourceMetrics({
    final List<DockerContainer> containers,
    final List<DockerImage> images,
    final Map<String, dynamic> systemInfo,
    final List<ResourceDataPoint> history,
    final Map<String, dynamic> basicStats,
    final Map<String, dynamic> rawMetrics,
  }) = _$ResourceMetricsImpl;

  factory _ResourceMetrics.fromJson(Map<String, dynamic> json) =
      _$ResourceMetricsImpl.fromJson;

  @override
  List<DockerContainer> get containers;
  @override
  List<DockerImage> get images;
  @override
  Map<String, dynamic> get systemInfo;
  @override
  List<ResourceDataPoint> get history;
  @override
  Map<String, dynamic> get basicStats;
  @override
  Map<String, dynamic> get rawMetrics;

  /// Create a copy of ResourceMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResourceMetricsImplCopyWith<_$ResourceMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
