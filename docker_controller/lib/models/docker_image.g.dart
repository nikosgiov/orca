// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'docker_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DockerImageImpl _$$DockerImageImplFromJson(Map<String, dynamic> json) =>
    _$DockerImageImpl(
      id: json['Id'] as String,
      repoTags:
          (json['RepoTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      repoDigests:
          (json['RepoDigests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      size: (json['Size'] as num).toInt(),
      created: (json['Created'] as num).toInt(),
      labels: json['Labels'] as Map<String, dynamic>? ?? const {},
      parentId: json['ParentId'] as String?,
      comment: json['Comment'] as String?,
      os: json['Os'] as String?,
      architecture: json['Architecture'] as String?,
      virtualSize: (json['VirtualSize'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$DockerImageImplToJson(_$DockerImageImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'RepoTags': instance.repoTags,
      'RepoDigests': instance.repoDigests,
      'Size': instance.size,
      'Created': instance.created,
      'Labels': instance.labels,
      'ParentId': instance.parentId,
      'Comment': instance.comment,
      'Os': instance.os,
      'Architecture': instance.architecture,
      'VirtualSize': instance.virtualSize,
    };
