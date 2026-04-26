// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'docker_container.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DockerContainerImpl _$$DockerContainerImplFromJson(
  Map<String, dynamic> json,
) => _$DockerContainerImpl(
  id: json['Id'] as String,
  names:
      (json['Names'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  image: json['Image'] as String,
  state: json['State'],
  status: json['Status'] as String?,
  created: json['Created'],
  ports:
      (json['Ports'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
  labels: json['Labels'] as Map<String, dynamic>? ?? const {},
  command: json['Command'] as String?,
  mounts:
      (json['Mounts'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
  config: json['Config'] as Map<String, dynamic>?,
  hostConfig: json['HostConfig'] as Map<String, dynamic>?,
  networkSettings: json['NetworkSettings'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$DockerContainerImplToJson(
  _$DockerContainerImpl instance,
) => <String, dynamic>{
  'Id': instance.id,
  'Names': instance.names,
  'Image': instance.image,
  'State': instance.state,
  'Status': instance.status,
  'Created': instance.created,
  'Ports': instance.ports,
  'Labels': instance.labels,
  'Command': instance.command,
  'Mounts': instance.mounts,
  'Config': instance.config,
  'HostConfig': instance.hostConfig,
  'NetworkSettings': instance.networkSettings,
};
