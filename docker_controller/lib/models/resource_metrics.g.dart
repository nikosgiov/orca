// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_metrics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ResourceMetricsImpl _$$ResourceMetricsImplFromJson(
  Map<String, dynamic> json,
) => _$ResourceMetricsImpl(
  containers:
      (json['containers'] as List<dynamic>?)
          ?.map((e) => DockerContainer.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  images:
      (json['images'] as List<dynamic>?)
          ?.map((e) => DockerImage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  systemInfo: json['systemInfo'] as Map<String, dynamic>? ?? const {},
  history:
      (json['history'] as List<dynamic>?)
          ?.map((e) => ResourceDataPoint.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  basicStats: json['basicStats'] as Map<String, dynamic>? ?? const {},
  rawMetrics: json['rawMetrics'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$$ResourceMetricsImplToJson(
  _$ResourceMetricsImpl instance,
) => <String, dynamic>{
  'containers': instance.containers,
  'images': instance.images,
  'systemInfo': instance.systemInfo,
  'history': instance.history,
  'basicStats': instance.basicStats,
  'rawMetrics': instance.rawMetrics,
};
