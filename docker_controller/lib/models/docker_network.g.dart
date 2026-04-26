// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'docker_network.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DockerNetworkImpl _$$DockerNetworkImplFromJson(Map<String, dynamic> json) =>
    _$DockerNetworkImpl(
      id: json['Id'] as String,
      name: json['Name'] as String,
      driver: json['Driver'] as String,
      scope: json['Scope'] as String,
      created: json['Created'] as String?,
      internal: json['Internal'] as bool,
      enableIPv6: json['EnableIPv6'] as bool,
      labels: json['Labels'] as Map<String, dynamic>? ?? const {},
      ipam: json['IPAM'] as Map<String, dynamic>?,
      containers: json['Containers'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$DockerNetworkImplToJson(_$DockerNetworkImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
      'Driver': instance.driver,
      'Scope': instance.scope,
      'Created': instance.created,
      'Internal': instance.internal,
      'EnableIPv6': instance.enableIPv6,
      'Labels': instance.labels,
      'IPAM': instance.ipam,
      'Containers': instance.containers,
    };
