import 'package:freezed_annotation/freezed_annotation.dart';
import 'docker_container.dart';
import 'docker_image.dart';
import 'resource_data_point.dart';

part 'resource_metrics.freezed.dart';
part 'resource_metrics.g.dart';

@freezed
class ResourceMetrics with _$ResourceMetrics {
  const factory ResourceMetrics({
    @Default([]) List<DockerContainer> containers,
    @Default([]) List<DockerImage> images,
    @Default({}) Map<String, dynamic> systemInfo,
    @Default([]) List<ResourceDataPoint> history,
    @Default({}) Map<String, dynamic> basicStats,
    @Default({}) Map<String, dynamic> rawMetrics,
  }) = _ResourceMetrics;

  factory ResourceMetrics.fromJson(Map<String, dynamic> json) =>
      _$ResourceMetricsFromJson(json);
}
