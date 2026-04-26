// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'docker_image.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DockerImage _$DockerImageFromJson(Map<String, dynamic> json) {
  return _DockerImage.fromJson(json);
}

/// @nodoc
mixin _$DockerImage {
  @JsonKey(name: 'Id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'RepoTags')
  List<String> get repoTags => throw _privateConstructorUsedError;
  @JsonKey(name: 'RepoDigests')
  List<String> get repoDigests => throw _privateConstructorUsedError;
  @JsonKey(name: 'Size')
  int get size => throw _privateConstructorUsedError;
  @JsonKey(name: 'Created')
  int get created => throw _privateConstructorUsedError;
  @JsonKey(name: 'Labels')
  Map<String, dynamic> get labels => throw _privateConstructorUsedError;
  @JsonKey(name: 'ParentId')
  String? get parentId => throw _privateConstructorUsedError;
  @JsonKey(name: 'Comment')
  String? get comment => throw _privateConstructorUsedError;
  @JsonKey(name: 'Os')
  String? get os => throw _privateConstructorUsedError;
  @JsonKey(name: 'Architecture')
  String? get architecture => throw _privateConstructorUsedError;
  @JsonKey(name: 'VirtualSize')
  int? get virtualSize => throw _privateConstructorUsedError;

  /// Serializes this DockerImage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DockerImage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DockerImageCopyWith<DockerImage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DockerImageCopyWith<$Res> {
  factory $DockerImageCopyWith(
    DockerImage value,
    $Res Function(DockerImage) then,
  ) = _$DockerImageCopyWithImpl<$Res, DockerImage>;
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'RepoTags') List<String> repoTags,
    @JsonKey(name: 'RepoDigests') List<String> repoDigests,
    @JsonKey(name: 'Size') int size,
    @JsonKey(name: 'Created') int created,
    @JsonKey(name: 'Labels') Map<String, dynamic> labels,
    @JsonKey(name: 'ParentId') String? parentId,
    @JsonKey(name: 'Comment') String? comment,
    @JsonKey(name: 'Os') String? os,
    @JsonKey(name: 'Architecture') String? architecture,
    @JsonKey(name: 'VirtualSize') int? virtualSize,
  });
}

/// @nodoc
class _$DockerImageCopyWithImpl<$Res, $Val extends DockerImage>
    implements $DockerImageCopyWith<$Res> {
  _$DockerImageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DockerImage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? repoTags = null,
    Object? repoDigests = null,
    Object? size = null,
    Object? created = null,
    Object? labels = null,
    Object? parentId = freezed,
    Object? comment = freezed,
    Object? os = freezed,
    Object? architecture = freezed,
    Object? virtualSize = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            repoTags: null == repoTags
                ? _value.repoTags
                : repoTags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            repoDigests: null == repoDigests
                ? _value.repoDigests
                : repoDigests // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            size: null == size
                ? _value.size
                : size // ignore: cast_nullable_to_non_nullable
                      as int,
            created: null == created
                ? _value.created
                : created // ignore: cast_nullable_to_non_nullable
                      as int,
            labels: null == labels
                ? _value.labels
                : labels // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            parentId: freezed == parentId
                ? _value.parentId
                : parentId // ignore: cast_nullable_to_non_nullable
                      as String?,
            comment: freezed == comment
                ? _value.comment
                : comment // ignore: cast_nullable_to_non_nullable
                      as String?,
            os: freezed == os
                ? _value.os
                : os // ignore: cast_nullable_to_non_nullable
                      as String?,
            architecture: freezed == architecture
                ? _value.architecture
                : architecture // ignore: cast_nullable_to_non_nullable
                      as String?,
            virtualSize: freezed == virtualSize
                ? _value.virtualSize
                : virtualSize // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DockerImageImplCopyWith<$Res>
    implements $DockerImageCopyWith<$Res> {
  factory _$$DockerImageImplCopyWith(
    _$DockerImageImpl value,
    $Res Function(_$DockerImageImpl) then,
  ) = __$$DockerImageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'Id') String id,
    @JsonKey(name: 'RepoTags') List<String> repoTags,
    @JsonKey(name: 'RepoDigests') List<String> repoDigests,
    @JsonKey(name: 'Size') int size,
    @JsonKey(name: 'Created') int created,
    @JsonKey(name: 'Labels') Map<String, dynamic> labels,
    @JsonKey(name: 'ParentId') String? parentId,
    @JsonKey(name: 'Comment') String? comment,
    @JsonKey(name: 'Os') String? os,
    @JsonKey(name: 'Architecture') String? architecture,
    @JsonKey(name: 'VirtualSize') int? virtualSize,
  });
}

/// @nodoc
class __$$DockerImageImplCopyWithImpl<$Res>
    extends _$DockerImageCopyWithImpl<$Res, _$DockerImageImpl>
    implements _$$DockerImageImplCopyWith<$Res> {
  __$$DockerImageImplCopyWithImpl(
    _$DockerImageImpl _value,
    $Res Function(_$DockerImageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DockerImage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? repoTags = null,
    Object? repoDigests = null,
    Object? size = null,
    Object? created = null,
    Object? labels = null,
    Object? parentId = freezed,
    Object? comment = freezed,
    Object? os = freezed,
    Object? architecture = freezed,
    Object? virtualSize = freezed,
  }) {
    return _then(
      _$DockerImageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        repoTags: null == repoTags
            ? _value._repoTags
            : repoTags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        repoDigests: null == repoDigests
            ? _value._repoDigests
            : repoDigests // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        size: null == size
            ? _value.size
            : size // ignore: cast_nullable_to_non_nullable
                  as int,
        created: null == created
            ? _value.created
            : created // ignore: cast_nullable_to_non_nullable
                  as int,
        labels: null == labels
            ? _value._labels
            : labels // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        parentId: freezed == parentId
            ? _value.parentId
            : parentId // ignore: cast_nullable_to_non_nullable
                  as String?,
        comment: freezed == comment
            ? _value.comment
            : comment // ignore: cast_nullable_to_non_nullable
                  as String?,
        os: freezed == os
            ? _value.os
            : os // ignore: cast_nullable_to_non_nullable
                  as String?,
        architecture: freezed == architecture
            ? _value.architecture
            : architecture // ignore: cast_nullable_to_non_nullable
                  as String?,
        virtualSize: freezed == virtualSize
            ? _value.virtualSize
            : virtualSize // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DockerImageImpl extends _DockerImage {
  const _$DockerImageImpl({
    @JsonKey(name: 'Id') required this.id,
    @JsonKey(name: 'RepoTags') final List<String> repoTags = const [],
    @JsonKey(name: 'RepoDigests') final List<String> repoDigests = const [],
    @JsonKey(name: 'Size') required this.size,
    @JsonKey(name: 'Created') required this.created,
    @JsonKey(name: 'Labels') final Map<String, dynamic> labels = const {},
    @JsonKey(name: 'ParentId') this.parentId,
    @JsonKey(name: 'Comment') this.comment,
    @JsonKey(name: 'Os') this.os,
    @JsonKey(name: 'Architecture') this.architecture,
    @JsonKey(name: 'VirtualSize') this.virtualSize,
  }) : _repoTags = repoTags,
       _repoDigests = repoDigests,
       _labels = labels,
       super._();

  factory _$DockerImageImpl.fromJson(Map<String, dynamic> json) =>
      _$$DockerImageImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final String id;
  final List<String> _repoTags;
  @override
  @JsonKey(name: 'RepoTags')
  List<String> get repoTags {
    if (_repoTags is EqualUnmodifiableListView) return _repoTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_repoTags);
  }

  final List<String> _repoDigests;
  @override
  @JsonKey(name: 'RepoDigests')
  List<String> get repoDigests {
    if (_repoDigests is EqualUnmodifiableListView) return _repoDigests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_repoDigests);
  }

  @override
  @JsonKey(name: 'Size')
  final int size;
  @override
  @JsonKey(name: 'Created')
  final int created;
  final Map<String, dynamic> _labels;
  @override
  @JsonKey(name: 'Labels')
  Map<String, dynamic> get labels {
    if (_labels is EqualUnmodifiableMapView) return _labels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_labels);
  }

  @override
  @JsonKey(name: 'ParentId')
  final String? parentId;
  @override
  @JsonKey(name: 'Comment')
  final String? comment;
  @override
  @JsonKey(name: 'Os')
  final String? os;
  @override
  @JsonKey(name: 'Architecture')
  final String? architecture;
  @override
  @JsonKey(name: 'VirtualSize')
  final int? virtualSize;

  @override
  String toString() {
    return 'DockerImage(id: $id, repoTags: $repoTags, repoDigests: $repoDigests, size: $size, created: $created, labels: $labels, parentId: $parentId, comment: $comment, os: $os, architecture: $architecture, virtualSize: $virtualSize)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DockerImageImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other._repoTags, _repoTags) &&
            const DeepCollectionEquality().equals(
              other._repoDigests,
              _repoDigests,
            ) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.created, created) || other.created == created) &&
            const DeepCollectionEquality().equals(other._labels, _labels) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.os, os) || other.os == os) &&
            (identical(other.architecture, architecture) ||
                other.architecture == architecture) &&
            (identical(other.virtualSize, virtualSize) ||
                other.virtualSize == virtualSize));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    const DeepCollectionEquality().hash(_repoTags),
    const DeepCollectionEquality().hash(_repoDigests),
    size,
    created,
    const DeepCollectionEquality().hash(_labels),
    parentId,
    comment,
    os,
    architecture,
    virtualSize,
  );

  /// Create a copy of DockerImage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DockerImageImplCopyWith<_$DockerImageImpl> get copyWith =>
      __$$DockerImageImplCopyWithImpl<_$DockerImageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DockerImageImplToJson(this);
  }
}

abstract class _DockerImage extends DockerImage {
  const factory _DockerImage({
    @JsonKey(name: 'Id') required final String id,
    @JsonKey(name: 'RepoTags') final List<String> repoTags,
    @JsonKey(name: 'RepoDigests') final List<String> repoDigests,
    @JsonKey(name: 'Size') required final int size,
    @JsonKey(name: 'Created') required final int created,
    @JsonKey(name: 'Labels') final Map<String, dynamic> labels,
    @JsonKey(name: 'ParentId') final String? parentId,
    @JsonKey(name: 'Comment') final String? comment,
    @JsonKey(name: 'Os') final String? os,
    @JsonKey(name: 'Architecture') final String? architecture,
    @JsonKey(name: 'VirtualSize') final int? virtualSize,
  }) = _$DockerImageImpl;
  const _DockerImage._() : super._();

  factory _DockerImage.fromJson(Map<String, dynamic> json) =
      _$DockerImageImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  String get id;
  @override
  @JsonKey(name: 'RepoTags')
  List<String> get repoTags;
  @override
  @JsonKey(name: 'RepoDigests')
  List<String> get repoDigests;
  @override
  @JsonKey(name: 'Size')
  int get size;
  @override
  @JsonKey(name: 'Created')
  int get created;
  @override
  @JsonKey(name: 'Labels')
  Map<String, dynamic> get labels;
  @override
  @JsonKey(name: 'ParentId')
  String? get parentId;
  @override
  @JsonKey(name: 'Comment')
  String? get comment;
  @override
  @JsonKey(name: 'Os')
  String? get os;
  @override
  @JsonKey(name: 'Architecture')
  String? get architecture;
  @override
  @JsonKey(name: 'VirtualSize')
  int? get virtualSize;

  /// Create a copy of DockerImage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DockerImageImplCopyWith<_$DockerImageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
