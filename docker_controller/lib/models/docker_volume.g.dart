// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'docker_volume.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DockerVolumeImpl _$$DockerVolumeImplFromJson(Map<String, dynamic> json) =>
    _$DockerVolumeImpl(
      name: json['Name'] as String,
      driver: json['Driver'] as String,
      mountpoint: json['Mountpoint'] as String,
      createdAt: json['CreatedAt'] as String?,
      labels: json['Labels'] as Map<String, dynamic>? ?? const {},
      options: json['Options'] as Map<String, dynamic>?,
      scope: json['Scope'] as String,
    );

Map<String, dynamic> _$$DockerVolumeImplToJson(_$DockerVolumeImpl instance) =>
    <String, dynamic>{
      'Name': instance.name,
      'Driver': instance.driver,
      'Mountpoint': instance.mountpoint,
      'CreatedAt': instance.createdAt,
      'Labels': instance.labels,
      'Options': instance.options,
      'Scope': instance.scope,
    };
