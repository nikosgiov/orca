import 'package:freezed_annotation/freezed_annotation.dart';

part 'docker_volume.freezed.dart';
part 'docker_volume.g.dart';

@freezed
class DockerVolume with _$DockerVolume {
  const factory DockerVolume({
    @JsonKey(name: 'Name') required String name,
    @JsonKey(name: 'Driver') required String driver,
    @JsonKey(name: 'Mountpoint') required String mountpoint,
    @JsonKey(name: 'CreatedAt') String? createdAt,
    @JsonKey(name: 'Labels') @Default({}) Map<String, dynamic> labels,
    @JsonKey(name: 'Options') Map<String, dynamic>? options,
    @JsonKey(name: 'Scope') required String scope,
  }) = _DockerVolume;

  factory DockerVolume.fromJson(Map<String, dynamic> json) =>
      _$DockerVolumeFromJson(json);
}
